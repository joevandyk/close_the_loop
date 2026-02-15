# Project-Specific Agent Notes
#
# If this repository also contains an `AGENTS.md`, treat that as the canonical
# framework/runtime guidance and do not edit it lightly (it may be generated).

## Project Overview

- App: `close-the-loop`
- Runtime: `elixir-phoenix`
- Profile: `experiment`
- Deploy target: Coolify (Dockerfile build pack)
- Secrets: Doppler (never commit secrets; never rely on `.env` files)
- Dev environment: devcontainer (`.devcontainer/`)

## Key Conventions

1. Doppler is the single source of truth for secrets. Never commit secrets. Never log secrets.
2. Use `scripts/*` wrappers instead of running commands directly when available (they inject Doppler secrets).
3. Makefile targets are the command contract: `make dev`, `make build`, `make test`, `make lint`, `make migrate`, `make seed`.
4. Structured logging is mandatory. Use the runtime's logger, not ad-hoc prints.
5. All background jobs must be idempotent.

## File Organization

- App code: `src/` (Node) or `lib/` (Elixir)
- `scripts/`: command wrappers (Doppler-aware)
- `docs/`: documentation and runbooks
- `.devcontainer/`: development container config
- `.cursor/`: editor/agent config

## When Making Changes

- Run `make lint` and `make test` before committing
- Update docs when changing architecture or integrations
- Add runbook entries for new operational procedures
- Never hardcode secrets: add to Doppler and reference via env vars

## Product UX Expectations

- Never ship the Phoenix default splash page; keep `GET /` as a real marketing homepage.
- Maintain basic marketing pages: `/how-it-works`, `/pricing`, `/privacy`, `/terms`.
- The end-to-end path must work:
  - Business can register/sign in
  - Business can create an organization (onboarding)
  - Business can view inbox + QR/reporter link
  - Customer can submit a report from the reporter link
  - Business can view the issue + reports and send an update
