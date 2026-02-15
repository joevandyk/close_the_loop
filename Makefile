# close-the-loop Makefile
# All commands assume env vars are injected by Doppler.
# Use scripts/* wrappers for local development.

.PHONY: install dev build test lint migrate seed worker cron docker-build docker-run clean
.PHONY: e2e e2e-install

# ─── Devcontainer (Linux) build isolation ─────────────────────────────
#
# Only Linux (devcontainer) needs isolation to prevent ELF NIFs landing in
# the macOS host `_build/` + `deps/` directories.
UNAME_S := $(shell uname -s 2>/dev/null || echo unknown)
ifeq ($(UNAME_S),Linux)
  MIX_BUILD_PATH ?= _build_linux
  MIX_DEPS_PATH ?= deps_linux
  export MIX_BUILD_PATH MIX_DEPS_PATH
endif

# ─── Development ──────────────────────────────────────────────────────

install:
	mix deps.get

dev:
	mix phx.server

build:
	MIX_ENV=prod mix release

# ─── Quality ─────────────────────────────────────────────────────────

test:
	mix deps.get
	MIX_ENV=test mix test

lint:
	mix format --check-formatted

# ─── Database ────────────────────────────────────────────────────────

migrate:
	mix ecto.migrate

seed:
	mix run priv/repo/seeds.exs

# ─── Background ──────────────────────────────────────────────────────

worker:
	mix worker

cron:
	mix cron

# ─── Docker ──────────────────────────────────────────────────────────

docker-build:
	docker build -t close-the-loop:latest .

docker-run:
	docker run --rm -p 3000:3000 --env-file .env close-the-loop:latest

# ─── Utility ─────────────────────────────────────────────────────────

clean:
	rm -rf _build deps _build_darwin deps_darwin _build_linux deps_linux

# ─── E2E (Playwright) ────────────────────────────────────────────────

e2e-install:
	cd e2e && npm install && npx playwright install --with-deps

e2e:
	cd e2e && npm test
