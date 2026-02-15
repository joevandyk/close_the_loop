#!/usr/bin/env bash
set -euo pipefail

# ─── Elixir Phoenix Setup Script ─────────────────────────────────────
# This script generates a Phoenix app and overlays platform files.
# Run this ONCE after generating the project with sideproj.
# Safe to re-run (uses --force where appropriate).

APP_NAME="close-the-loop"
APP_NAME_UNDER="close_the_loop"
APP_MODULE="CloseTheLoop"
DB_FLAG="--database postgres"

echo ""
echo "==> Setting up Phoenix app: ${APP_NAME}"
echo ""

# Resolve paths up front because we `cd` into a temp dir later.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "${SCRIPT_DIR}")"

# ─── Check prerequisites ─────────────────────────────────────────────

if ! command -v elixir &> /dev/null; then
  echo "  ✖ Elixir is not installed."
  echo "    Install from: https://elixir-lang.org/install.html"
  echo "    Required: Elixir >= 1.20"
  exit 1
fi

if ! command -v mix &> /dev/null; then
  echo "  ✖ Mix is not available."
  exit 1
fi

ELIXIR_VERSION=$(elixir --version | grep "Elixir" | sed 's/Elixir //')
echo "  ✔ Elixir ${ELIXIR_VERSION}"
echo "  ✔ Mix available"

# ─── Install Hex, Rebar, Phoenix generator ────────────────────────────

echo ""
echo "==> Installing Hex, Rebar, and Phoenix generator..."
mix local.hex --force --if-missing
mix local.rebar --force --if-missing
mix archive.install hex phx_new --force
mix archive.install hex igniter_new --force

# ─── Generate Phoenix app in temp directory ───────────────────────────

TEMP_DIR=$(mktemp -d)
trap 'rm -rf "${TEMP_DIR}"' EXIT

echo ""
echo "==> Generating Phoenix app..."
cd "${TEMP_DIR}"

# Use the underscore version for mix phx.new (it converts hyphens to underscores)
mix phx.new "${APP_NAME_UNDER}" ${DB_FLAG} --install

# ─── Overlay Phoenix files onto sideproj scaffold ─────────────────────

echo ""
echo "==> Merging Phoenix files with platform scaffold..."

# Copy Phoenix-generated files, but don't overwrite our platform files
# (Makefile, Dockerfile, README, docs/, scripts/, etc.)
PHOENIX_DIR="${TEMP_DIR}/${APP_NAME_UNDER}"

# Files that Phoenix generates and we always want
for f in mix.exs mix.lock .formatter.exs AGENTS.md; do
  if [ -f "${PHOENIX_DIR}/${f}" ]; then
    cp "${PHOENIX_DIR}/${f}" "${PROJECT_DIR}/${f}"
  fi
done

# Directories that Phoenix owns
for d in lib test priv assets config; do
  if [ -d "${PHOENIX_DIR}/${d}" ]; then
    cp -r "${PHOENIX_DIR}/${d}/." "${PROJECT_DIR}/${d}/" 2>/dev/null || true
  fi
done

# ─── Install dependencies in project directory ───────────────────────

echo ""
echo "==> Installing dependencies..."
cd "${PROJECT_DIR}"
if command -v doppler &> /dev/null; then
  doppler run --preserve-env -- scripts/setup-fluxon-hex-repo
  doppler run --preserve-env -- mix deps.get
else
  echo "  ✖ Doppler CLI is required to fetch Fluxon UI dependencies."
  echo "    Install: https://docs.doppler.com/docs/cli"
  exit 1
fi


if [ "${DB_FLAG}" = "--no-ecto" ]; then
  echo ""
  echo "  ✖ --ash requires Ecto/Postgres (remove --no-db / --no-ecto)"
  echo ""
  exit 1
fi

echo ""
echo "==> Installing Ash stack (Ash/AshPostgres/AshPhoenix/AshAuthentication/AshOban)..."
mix igniter.install ash ash_postgres ash_phoenix ash_authentication ash_authentication_phoenix ash_oban --yes
mix deps.get

echo ""
echo "==> Optional: install Oban Web dashboard (recommended alongside Oban)"
echo "    mix igniter.install oban_web --yes"
echo "    # Then mount + secure it (see lib/close_the_loop_web/router.ex)."


# ─── Done ─────────────────────────────────────────────────────────────

echo ""
echo "  ✔ Phoenix app setup complete!"
echo ""
echo "  Next steps:"
echo "    1. Set up Doppler:    doppler setup --project ${APP_NAME} --config local"
if [ "${DB_FLAG}" != "--no-ecto" ]; then
echo "    2. Create database:   mix ecto.create"
echo "    3. Run migrations:    scripts/migrate"
echo "    4. Start dev server:  scripts/dev"
else
echo "    2. Start dev server:  scripts/dev"
fi
echo ""
echo "  Platform files (Makefile, Dockerfile, docs, scripts) are already in place."
echo "  Add health/version routes — see lib/router_additions.ex for guidance."
echo ""
