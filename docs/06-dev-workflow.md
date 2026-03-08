# Dev Workflow — close-the-loop

## Prerequisites

- Docker Desktop (for devcontainer)
- [VS Code](https://code.visualstudio.com/) (or compatible editor like Cursor) with [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
- [Doppler CLI](https://docs.doppler.com/docs/install-cli)

> **Recommended**: Use the devcontainer. It has everything pre-configured —
> runtime, database, and tooling. No local install of Elixir >= 1.20 (rc), Erlang/OTP >= 28 required.

## First-Time Setup (Devcontainer)

```bash
# 1. Clone the repo
git clone <repo-url>
cd close-the-loop

# 2. Open in your editor
#    "Reopen in Container" when prompted (or Command Palette → "Dev Containers: Reopen in Container")

# 3. Set up Doppler (inside the container)
doppler setup --project close-the-loop --config local

# 4. Run migrations
scripts/migrate

# 5. Seed data (optional)
scripts/seed

# 6. Start dev server
scripts/dev
```

## First-Time Setup (Without Devcontainer)

```bash
# 1. Clone the repo
git clone <repo-url>
cd close-the-loop

# 2. Bootstrap (checks tools, installs deps, inits git)
scripts/bootstrap

# 3. Set up Doppler
doppler setup --project close-the-loop --config dev

# 4. Run migrations
scripts/migrate

# 5. Start dev server
scripts/dev
```

## Devcontainer Details

The `.devcontainer/` directory contains the full development environment:

- **Dockerfile**: Runtime, tooling, and system deps
- **docker-compose.yml**: App container + Postgres + MinIO (S3-compatible storage) — **Ona-compatible**
- **devcontainer.json**: IDE settings, extensions, port forwarding

This repo also includes a local devcontainer config at `.devcontainer/local/` that uses
standard Docker networking (bridge) for better compatibility on developer machines.

Services available inside the devcontainer:

| Service | Host | Port |
|---------|------|------|
| App | `localhost` | 3000 |
| PostgreSQL | `localhost` | 5432 |
| MinIO (S3 API) | `localhost` | 9000 |
| MinIO (Console) | `localhost` | 9001 |

The database is automatically created and available at the `DATABASE_URL`
set in `docker-compose.yml`. No manual `createdb` needed.

> Note: Ona requires `network_mode: host` for Docker Compose-based devcontainers.
> In the Ona-compatible devcontainer, services are reachable via `localhost`.
> In the local devcontainer (`.devcontainer/local/`), services are reachable via
> Docker Compose DNS names (`db`, `minio`).

## AI Agent Environment

Cloud-based AI agents (Cursor, Claude Code, etc.) can use the devcontainer
Dockerfile as their runtime environment.

The `.agents/` directory contains shared agent scripts:

- **`.agents/cloud/install.sh`** — Idempotent setup: installs deps, compiles
  assets, warms compilation caches, installs local Postgres for tests.
- **`.agents/cloud/start.sh`** — Starts Postgres and sets up the test database.
- **`.agents/setup-worktree-mac.sh`** — Worktree setup for local agents on macOS.

Editor-specific config (e.g. `.cursor/environment.json`) references these
shared scripts so the setup stays consistent across tools.

## Daily Workflow

```bash
# Start dev server
scripts/dev

# Run tests
scripts/test

# Run linter
scripts/lint
```

## Branch Strategy

- `main` — Production branch, auto-deploys to prod
- Feature branches — Create PR against main
- Preview deploys — Automatic on PR (via Coolify)

## Testing

```bash
# Run all tests
scripts/test

# Run specific test (runtime-dependent)
mix test test/path/to/test.exs
```

## Code Review Checklist

- [ ] Tests pass (`scripts/test`)
- [ ] Linter passes (`scripts/lint`)
- [ ] No secrets in code
- [ ] Docs updated if architecture changed
- [ ] Migrations are backward-compatible
- [ ] New env vars added to Doppler (all configs)
- [ ] Runbooks updated for new operational procedures
