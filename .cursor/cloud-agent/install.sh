#!/usr/bin/env bash
set -euo pipefail

echo "[cloud-agent install] starting"

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

echo "[cloud-agent install] repo_root=$ROOT"

# Cursor Cloud Agents run inside a container built from `.cursor/environment.json`.
# The Dockerfile should provide Erlang/Elixir, Node, build tools, etc.
if ! command -v mix >/dev/null 2>&1; then
  echo "[cloud-agent install] ERROR: mix not found. Check your Dockerfile/image."
  exit 1
fi

# Match the Makefile's Linux build/deps isolation (keeps paths consistent with `make test`).
if [ "$(uname -s)" = "Linux" ]; then
  export MIX_BUILD_PATH="${MIX_BUILD_PATH:-_build_linux}"
  export MIX_DEPS_PATH="${MIX_DEPS_PATH:-deps_linux}"
fi

if command -v apt-get >/dev/null 2>&1; then
  if [ "$(id -u)" -eq 0 ]; then
    echo "[cloud-agent install] apt-get update"
    apt-get update

    # Tests require a local PostgreSQL server (config/test.exs defaults to localhost).
    # We install the server here because only disk state persists from `install`.
    echo "[cloud-agent install] installing postgres server packages"
    DEBIAN_FRONTEND=noninteractive apt-get install -y postgresql postgresql-contrib

    # Keep the image cache smaller for snapshots.
    rm -rf /var/lib/apt/lists/*
  else
    echo "[cloud-agent install] not root; skipping apt-get install"
  fi
else
  echo "[cloud-agent install] apt-get not available; skipping OS package install"
fi

echo "[cloud-agent install] mix local.hex/local.rebar (idempotent)"
mix local.hex --force
mix local.rebar --force

echo "[cloud-agent install] mix deps.get"
mix deps.get

# Ensure esbuild/tailwind binaries exist (precommit may compile modules that reference assets).
echo "[cloud-agent install] mix assets.setup"
mix assets.setup

echo "[cloud-agent install] MIX_ENV=test mix deps.get"
MIX_ENV=test mix deps.get

# Warm compilation caches. Prefer `mix precompile` (when available), but fall back to `mix compile`.
if mix help precompile >/dev/null 2>&1; then
  echo "[cloud-agent install] mix precompile (dev)"
  mix precompile

  echo "[cloud-agent install] MIX_ENV=test mix precompile"
  MIX_ENV=test mix precompile
else
  echo "[cloud-agent install] mix precompile task not found; falling back to mix compile"
  echo "[cloud-agent install] mix compile (dev)"
  mix compile

  echo "[cloud-agent install] MIX_ENV=test mix compile"
  MIX_ENV=test mix compile
fi

echo "[cloud-agent install] done"

