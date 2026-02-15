# close-the-loop Makefile
# All commands assume env vars are injected by Doppler.
# Use scripts/* wrappers for local development.

.PHONY: install dev build test lint migrate seed worker cron docker-build docker-run docker-test clean
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
	./scripts/setup-fluxon-hex-repo
	mix deps.get

dev:
	mix phx.server

build:
	MIX_ENV=prod mix release

# ─── Quality ─────────────────────────────────────────────────────────

test:
	./scripts/setup-fluxon-hex-repo
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
	DOCKER_BUILDKIT=1 docker build \
		--secret id=FLUXON_LICENSE_KEY,env=FLUXON_LICENSE_KEY \
		--secret id=FLUXON_KEY_FINGERPRINT,env=FLUXON_KEY_FINGERPRINT \
		-t close-the-loop:latest .

docker-run:
	@if [ ! -f ".env" ]; then \
		echo "Missing .env file."; \
		echo "Create one from .env.example (do not commit it), then re-run:"; \
		echo "  cp .env.example .env"; \
		exit 1; \
	fi
	docker run --rm -p 3000:3000 --env-file .env close-the-loop:latest

# Run tests in the Dockerized dev environment (Linux + Postgres)
docker-test:
	docker compose -f .devcontainer/docker-compose.yml up -d --build --wait db
	docker compose -f .devcontainer/docker-compose.yml run --rm -e MIX_ENV=test app bash -lc "cd /workspace && doppler run -- make test"

# ─── Utility ─────────────────────────────────────────────────────────

clean:
	rm -rf _build deps _build_darwin deps_darwin _build_linux deps_linux

# ─── E2E (Playwright) ────────────────────────────────────────────────

e2e-install:
	cd e2e && npm install && npx playwright install --with-deps

e2e:
	cd e2e && npm test
