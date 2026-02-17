# Dev Workflow — close-the-loop

## Prerequisites

- Docker Desktop (for devcontainer)
- [VS Code](https://code.visualstudio.com/) with [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) **or** [Cursor](https://cursor.sh/)
- [Doppler CLI](https://docs.doppler.com/docs/install-cli)

> **Recommended**: Use the devcontainer. It has everything pre-configured —
> runtime, database, and tooling. No local install of Elixir >= 1.20 (rc), Erlang/OTP >= 28 required.

## First-Time Setup (Devcontainer)

```bash
# 1. Clone the repo
git clone <repo-url>
cd close-the-loop

# 2. Open in VS Code / Cursor
#    VS Code: "Reopen in Container" when prompted
#    Cursor:  Same prompt, or use Command Palette → "Dev Containers: Reopen in Container"

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
- **docker-compose.yml**: App container + Postgres + MinIO (S3-compatible storage)
- **devcontainer.json**: IDE settings, extensions, port forwarding

Services available inside the devcontainer:

| Service | Host | Port |
|---------|------|------|
| App | `localhost` | 3000 |
| PostgreSQL | `localhost` | 5432 |
| MinIO (S3 API) | `localhost` | 9000 |
| MinIO (Console) | `localhost` | 9001 |

The database is automatically created and available at the `DATABASE_URL`
set in `docker-compose.yml`. No manual `createdb` needed.

## Cursor Cloud Agents

The `.cursor/environment.json` file configures Cursor's cloud agent
environment (Ona). It points to the devcontainer Dockerfile so that cloud
agents have the same runtime/tooling as the devcontainer.

This repo also includes an install hook (`.cursor/cloud-agent-install.sh`)
that runs idempotent setup (deps/assets + warm compilation caches) so new
agent VMs start faster.

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
