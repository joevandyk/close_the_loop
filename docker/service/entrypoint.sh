#!/usr/bin/env bash
set -euo pipefail

log() {
  # RFC3339-ish UTC timestamp
  printf '%s %s\n' "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" "$*"
}

die() {
  log "ERROR: $*"
  exit 1
}

DATA_DIR="${DATA_DIR:-/srv/data}"
APP_DIR="${APP_DIR:-${DATA_DIR}/close_the_loop}"

GIT_REPO_URL="${GIT_REPO_URL:-}"
GIT_BRANCH="${GIT_BRANCH:-main}"
UPDATE_INTERVAL_SECONDS="${UPDATE_INTERVAL_SECONDS:-60}"

AUTO_RESET_ON_MIGRATION_FAILURE="${AUTO_RESET_ON_MIGRATION_FAILURE:-true}"
SEED_ON_RESET="${SEED_ON_RESET:-true}"

MIX_ENV="${MIX_ENV:-dev}"
PORT="${PORT:-3000}"

export MIX_ENV PORT

ensure_repo() {
  if [[ -d "${APP_DIR}/.git" ]]; then
    return 0
  fi

  if [[ -z "${GIT_REPO_URL}" ]]; then
    die "GIT_REPO_URL is required (e.g. https://github.com/<org>/<repo>.git)"
  fi

  log "Cloning repo: ${GIT_REPO_URL} (branch: ${GIT_BRANCH})"
  mkdir -p "${DATA_DIR}"
  rm -rf "${APP_DIR}"
  git clone --depth 1 --branch "${GIT_BRANCH}" "${GIT_REPO_URL}" "${APP_DIR}"
}

git_check_update() {
  # Returns the remote SHA if an update is available; empty string otherwise.
  # NOTE: This function MUST NOT modify the working tree because the server
  # may be running.
  ensure_repo

  cd "${APP_DIR}"

  # If a new URL is provided (e.g. token rotation), keep origin up to date.
  if [[ -n "${GIT_REPO_URL}" ]]; then
    git remote set-url origin "${GIT_REPO_URL}" >/dev/null 2>&1 || true
  fi

  if ! git fetch --prune origin "${GIT_BRANCH}" >/dev/null 2>&1; then
    log "WARN: git fetch failed; keeping current code"
    echo ""
    return 0
  fi

  local_sha="$(git rev-parse HEAD)"
  remote_sha="$(git rev-parse "origin/${GIT_BRANCH}")"

  if [[ "${local_sha}" == "${remote_sha}" ]]; then
    echo ""
    return 0
  fi

  log "Update available: ${local_sha} -> ${remote_sha}"
  echo "${remote_sha}"
}

git_apply_update() {
  local target_sha="${1:?missing target sha}"

  cd "${APP_DIR}"
  git reset --hard "${target_sha}" >/dev/null

  # Remove untracked files (but keep ignored build artifacts like deps/ and _build/)
  git clean -fd >/dev/null
}

mix_prepare() {
  cd "${APP_DIR}"

  log "Mix prepare (MIX_ENV=${MIX_ENV})"
  mix deps.get
  mix deps.compile
  mix compile

  # In prod, we need digested assets.
  if [[ "${MIX_ENV}" == "prod" ]]; then
    mix assets.deploy
  fi
}

run_migrations() {
  cd "${APP_DIR}"

  log "Running migrations"
  mix ecto.create
  mix ash_postgres.migrate
  mix ash_postgres.migrate --tenants
}

run_reset() {
  cd "${APP_DIR}"

  log "Resetting database (drop/create + migrate)"
  mix ecto.drop --force || true
  mix ecto.create
  mix ash_postgres.migrate
  mix ash_postgres.migrate --tenants

  if [[ "${SEED_ON_RESET}" == "true" ]]; then
    if [[ "${MIX_ENV}" == "prod" && "${ALLOW_PROD_SEEDS:-}" != "true" ]]; then
      log "SEED_ON_RESET=true but MIX_ENV=prod without ALLOW_PROD_SEEDS=true; skipping seeds"
      return 0
    fi

    log "Seeding database"
    mix run priv/repo/seeds.exs
  fi
}

migrate_or_reset() {
  if run_migrations; then
    return 0
  fi

  log "WARN: migrations failed"

  if [[ "${AUTO_RESET_ON_MIGRATION_FAILURE}" == "true" ]]; then
    log "AUTO_RESET_ON_MIGRATION_FAILURE=true; attempting reset"
    run_reset
    return 0
  fi

  log "AUTO_RESET_ON_MIGRATION_FAILURE=false; not resetting"
  return 1
}

start_server() {
  cd "${APP_DIR}"

  log "Starting server: mix phx.server (PORT=${PORT}, MIX_ENV=${MIX_ENV})"

  # Start in a separate process (we manage restarts).
  # Use exec so the PID we capture is the Mix process.
  bash -lc "cd \"${APP_DIR}\" && exec mix phx.server" &
  echo "$!"
}

stop_server() {
  local pid="${1:-}"
  if [[ -z "${pid}" ]]; then
    return 0
  fi

  if ! kill -0 "${pid}" >/dev/null 2>&1; then
    return 0
  fi

  log "Stopping server (pid=${pid})"
  kill -TERM "${pid}" >/dev/null 2>&1 || true

  # Wait up to ~30s, then hard kill.
  for _ in $(seq 1 30); do
    if ! kill -0 "${pid}" >/dev/null 2>&1; then
      wait "${pid}" >/dev/null 2>&1 || true
      log "Server stopped"
      return 0
    fi
    sleep 1
  done

  log "Server did not stop in time; killing (pid=${pid})"
  kill -KILL "${pid}" >/dev/null 2>&1 || true
  wait "${pid}" >/dev/null 2>&1 || true
}

main() {
  log "close-the-loop service boot"
  if [[ -n "${GIT_REPO_URL}" ]]; then
    log "Repo: ${GIT_REPO_URL} @ ${GIT_BRANCH}"
  else
    log "Repo: (from existing clone) @ ${GIT_BRANCH}"
  fi
  log "App dir: ${APP_DIR}"
  log "Update interval: ${UPDATE_INTERVAL_SECONDS}s"

  ensure_repo
  mix_prepare
  migrate_or_reset || log "WARN: initial migrate/reset failed; starting server anyway"

  app_pid="$(start_server)"

  trap 'log "Received shutdown signal"; stop_server "${app_pid}"; exit 0' TERM INT

  while true; do
    sleep "${UPDATE_INTERVAL_SECONDS}"

    remote_sha="$(git_check_update)"

    if [[ -n "${remote_sha}" ]]; then
      stop_server "${app_pid}"
      git_apply_update "${remote_sha}"
      mix_prepare
      migrate_or_reset || log "WARN: migrate/reset failed after update; restarting anyway"
      app_pid="$(start_server)"
    fi

    # If the app crashes, restart it (and try to self-heal via migrate/reset).
    if ! kill -0 "${app_pid}" >/dev/null 2>&1; then
      log "WARN: server process exited; restarting"
      mix_prepare || true
      migrate_or_reset || true
      app_pid="$(start_server)"
    fi
  done
}

main "$@"
