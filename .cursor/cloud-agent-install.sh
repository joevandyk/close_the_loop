#!/usr/bin/env bash
set -euo pipefail

# Ona / Cursor Cloud Agents run this from the repo root, but be defensive.
if root="$(git rev-parse --show-toplevel 2>/dev/null)"; then
  cd "$root"
fi

if ! command -v mix >/dev/null 2>&1; then
  echo "[cloud-agent] mix not found; skipping Elixir setup"
  exit 0
fi

# Match the Makefile's Linux build/deps isolation (avoids ELF NIFs leaking across OSes).
if [ "$(uname -s)" = "Linux" ]; then
  export MIX_BUILD_PATH="${MIX_BUILD_PATH:-_build_linux}"
  export MIX_DEPS_PATH="${MIX_DEPS_PATH:-deps_linux}"
fi

echo "[cloud-agent] mix deps.get (dev)"
mix deps.get

echo "[cloud-agent] mix deps.get (test)"
MIX_ENV=test mix deps.get

# Ensure esbuild/tailwind binaries exist for assets-related tasks.
echo "[cloud-agent] mix assets.setup"
mix assets.setup

# Prefer `mix precompile` (warms caches), but fall back to `mix compile` if unavailable.
if mix help precompile >/dev/null 2>&1; then
  echo "[cloud-agent] mix precompile (dev)"
  mix precompile

  echo "[cloud-agent] MIX_ENV=test mix precompile"
  MIX_ENV=test mix precompile
else
  echo "[cloud-agent] mix precompile task not found; falling back to mix compile"
  echo "[cloud-agent] mix compile (dev)"
  mix compile

  echo "[cloud-agent] MIX_ENV=test mix compile"
  MIX_ENV=test mix compile
fi

