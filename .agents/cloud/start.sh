#!/usr/bin/env bash
set -euo pipefail

echo "[cloud-agent start] starting"

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

start_postgres_with_pg_ctlcluster() {
  if ! command -v pg_lsclusters >/dev/null 2>&1; then
    return 1
  fi

  local line version name status port
  line="$(pg_lsclusters --no-header | awk 'NR==1 {print $1 \" \" $2 \" \" $4 \" \" $3}')"
  version="$(echo "$line" | awk '{print $1}')"
  name="$(echo "$line" | awk '{print $2}')"
  status="$(echo "$line" | awk '{print $3}')"
  port="$(echo "$line" | awk '{print $4}')"

  if [ -z "${version:-}" ] || [ -z "${name:-}" ]; then
    return 1
  fi

  echo "[cloud-agent start] postgres cluster detected: ${version}/${name} status=${status} port=${port}"

  if [ "${status}" != "online" ]; then
    echo "[cloud-agent start] starting postgres cluster ${version}/${name}"
    pg_ctlcluster "${version}" "${name}" start
  fi

  return 0
}

start_postgres_with_service() {
  if command -v service >/dev/null 2>&1; then
    echo "[cloud-agent start] starting postgres via service"
    service postgresql start
    return 0
  fi

  return 1
}

wait_for_postgres() {
  if ! command -v pg_isready >/dev/null 2>&1; then
    echo "[cloud-agent start] ERROR: pg_isready not found (is postgres installed?)"
    return 1
  fi

  local i
  for i in $(seq 1 30); do
    if pg_isready -h localhost -p 5432 >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
  done

  return 1
}

set_postgres_password() {
  # Tests default to username/password "postgres"/"postgres" against localhost.
  # We set it on every start; it's safe and keeps the environment consistent.
  local sql="ALTER USER postgres PASSWORD 'postgres';"

  if command -v runuser >/dev/null 2>&1; then
    runuser -u postgres -- psql -v ON_ERROR_STOP=1 -c "${sql}"
    return 0
  fi

  if command -v su >/dev/null 2>&1; then
    su - postgres -c "psql -v ON_ERROR_STOP=1 -c \"${sql}\""
    return 0
  fi

  echo "[cloud-agent start] ERROR: cannot switch to postgres user (no runuser/su)"
  return 1
}

if command -v pg_isready >/dev/null 2>&1 && pg_isready -h localhost -p 5432 >/dev/null 2>&1; then
  echo "[cloud-agent start] postgres already accepting connections"
else
  if ! start_postgres_with_pg_ctlcluster; then
    start_postgres_with_service || true
  fi

  if ! wait_for_postgres; then
    echo "[cloud-agent start] ERROR: postgres did not become ready on localhost:5432"
    exit 1
  fi
fi

echo "[cloud-agent start] ensuring postgres password"
set_postgres_password

echo "[cloud-agent start] done"

