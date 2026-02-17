#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${OPENAI_API_KEY:-}" ]]; then
  echo "ERROR: OPENAI_API_KEY is not set (required for e2e)."
  echo "Set it in Doppler for your local config, or export OPENAI_API_KEY in your shell."
  exit 1
fi

# Playwright e2e runs a dev-mode server against the test DB, resetting it for each run.
mix ecto.drop --force || true
mix ecto.create
mix ash_postgres.migrate
mix run priv/repo/seeds.exs
mix run priv/repo/e2e_seeds.exs

exec mix phx.server

