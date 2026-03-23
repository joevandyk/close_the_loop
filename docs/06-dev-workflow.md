# Dev Workflow — close-the-loop

## Prerequisites

- Docker Desktop (for devcontainer)
- [VS Code](https://code.visualstudio.com/) (or compatible editor like Cursor) with [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
- [Doppler CLI](https://docs.doppler.com/docs/install-cli)

> **Recommended**: Use the devcontainer. It has everything pre-configured —
> runtime, database, and tooling. No local install of Elixir >= 1.20 (rc), Erlang/OTP >= 28 required.

## First-Time Setup (Devcontainer via devbox)

```bash
# 1. Create a new environment (clones worktree, starts containers, injects Doppler secrets)
dev new ctl my-feature

# 2. Shell into the running environment
dev shell my-feature

# 3. Run migrations
scripts/migrate

# 4. Seed data (optional)
scripts/seed

# 5. Start dev server
scripts/dev
```

## First-Time Setup (Devcontainer via editor)

```bash
# 1. Clone the repo
git clone <repo-url>
cd close-the-loop

# 2. Generate .env.doppler with secrets (requires Doppler CLI on host)
doppler secrets download --no-file --format env \
  -p close-the-loop -c local_close_the_loop > .devcontainer/.env.doppler

# 3. Open in your editor
#    "Reopen in Container" when prompted (or Command Palette → "Dev Containers: Reopen in Container")

# 4. Run migrations (use `make` directly — secrets are already in env via env_file)
make migrate

# 5. Seed data (optional)
make seed

# 6. Start dev server
make dev
```

> **Note**: The `scripts/*` wrappers use `doppler run` to inject secrets, which requires
> Doppler CLI auth inside the container. In the devcontainer, secrets are already injected
> via `.env.doppler`, so use `make` targets directly instead.

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
- **.env.doppler**: Secrets injected by the `dev` tool from Doppler on the host (local-only; do not commit)

Services available inside the devcontainer (via Docker Compose DNS names):

| Service | Host (inside container) | Host (from browser) | Port |
|---------|------------------------|---------------------|------|
| App | `localhost` | `localhost` | 3000 |
| PostgreSQL | `db` | — | 5432 |
| MinIO (S3 API) | `minio` | — | 9000 |
| MinIO (Console) | `minio` | — | 9001 |

The database is automatically created and available at the `DATABASE_URL`
set in `docker-compose.yml`. No manual `createdb` needed.

## AI Agent Environment

Cloud-based AI agents (Cursor, Claude Code, etc.) can use the devcontainer
Dockerfile as their runtime environment.

The `.agents/` directory contains shared agent scripts:

- **`.agents/cloud/install.sh`** — Idempotent setup: installs deps, compiles
  assets, warms compilation caches, installs local Postgres for tests.
- **`.agents/cloud/start.sh`** — Starts Postgres and sets up the test database.
- **`.agents/setup-worktree-mac.sh`** — Worktree setup for local agents on macOS.

These scripts keep agent setup consistent across tools (Claude Code, Cursor, etc.).

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
