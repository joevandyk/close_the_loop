# Close The Loop

## Project Overview

- App: `close-the-loop`
- Runtime: Elixir/Phoenix
- Deploy target: Coolify (Dockerfile build pack)
- Secrets: Doppler (never commit secrets; never rely on `.env` files)
- Dev environment: devcontainer (`.devcontainer/`)

## Dev Commands

Run inside the devcontainer (`docker exec <container> bash -c 'cd /workspace && ...'`):

- `mix test` — run tests (auto-runs `ash.setup --quiet` first via alias)
- `mix precommit` — compile (warnings-as-errors), codegen check, format, test
- `mix ash.setup` — create/migrate database
- `mix ash.codegen <name>` — generate migrations after resource changes

## Key Conventions

1. Doppler is the single source of truth for secrets. Never commit secrets. Never log secrets.
2. Use `scripts/*` wrappers instead of running commands directly when available (they inject Doppler secrets).
3. Makefile targets are the command contract: `make dev`, `make build`, `make test`, `make lint`, `make migrate`, `make seed`.
4. Structured logging is mandatory. Use the runtime's logger, not ad-hoc prints.
5. All background jobs must be idempotent.

## File Organization

- `lib/` — app code
- `test/` — tests
- `scripts/` — command wrappers (Doppler-aware)
- `docs/` — documentation and runbooks
- `.devcontainer/` — development container config
- `.agents/` — shared AI agent scripts (cloud install/start, worktree setup)

## When Making Changes

- Run `mix precommit` before committing
- Update docs when changing architecture or integrations
- Add runbook entries for new operational procedures
- Never hardcode secrets: add to Doppler and reference via env vars
- Add tests for new routes/features (at least 1 happy path + 1 failure/edge case for user-visible pages)

## Product UX Expectations

- Never ship the Phoenix default splash page; keep `GET /` as a real marketing homepage.
- Maintain basic marketing pages: `/how-it-works`, `/pricing`, `/privacy`, `/terms`.
- The end-to-end path must work:
  - Business can register/sign in
  - Business can create an organization (onboarding)
  - Business can view inbox + QR/reporter link
  - Customer can submit a report from the reporter link
  - Business can view the issue + reports and send an update
