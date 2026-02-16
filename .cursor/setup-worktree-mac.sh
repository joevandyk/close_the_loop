#!/usr/bin/env bash
set -euo pipefail

echo "[cursor worktree] setup: $(pwd)"

if ! command -v mix >/dev/null 2>&1; then
  echo "[cursor worktree] mix not found; skipping Elixir setup"
  exit 0
fi

echo "[cursor worktree] mix deps.get"
mix deps.get

# E2E uses a dev server with watchers; ensure the esbuild/tailwind binaries exist.
echo "[cursor worktree] mix assets.setup"
mix assets.setup

# `mix precommit` runs in MIX_ENV=test (preferred_envs), so compile test once here.
echo "[cursor worktree] MIX_ENV=test mix compile"
MIX_ENV=test mix compile

if [ -f "e2e/package.json" ]; then
  if command -v npm >/dev/null 2>&1; then
    echo "[cursor worktree] installing e2e node deps"
    pushd e2e >/dev/null
    if [ -f package-lock.json ]; then
      npm ci
    else
      npm install
    fi
    # Browser downloads go to Playwright's global cache; this is idempotent.
    npx playwright install
    popd >/dev/null
  else
    echo "[cursor worktree] npm not found; skipping e2e deps"
  fi
fi

