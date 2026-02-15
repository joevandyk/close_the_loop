# close-the-loop

> A experiment application built with Elixir Phoenix

## Quick Start

```bash
# Bootstrap (checks tools, installs deps)
scripts/bootstrap

# Set up Doppler secrets
doppler setup --project close-the-loop --config local_close_the_loop

# Run database migrations (if applicable)
scripts/migrate

# Start development server
scripts/dev

# If port 3000 is in use on your machine:
PORT=4000 scripts/dev
```

## Stack

- **Runtime**: Elixir Phoenix
- **Database**: PostgreSQL
- **Secrets**: Doppler
- **Deploy**: Coolify
- **CI**: GitHub Actions

## Commands

All commands should be run via `scripts/*` wrappers (which inject Doppler secrets) or via `make` targets:

| Command | Description |
|---------|-------------|
| `scripts/dev` | Start development server |
| `scripts/test` | Run tests |
| `scripts/lint` | Run linter |
| `scripts/migrate` | Run database migrations |
| `scripts/seed` | Seed database |
| `scripts/worker` | Start background worker |
| `scripts/cron` | Start cron scheduler |
| `make build` | Build for production |
| `make docker-build` | Build Docker image |
| `make e2e` | Run Playwright E2E tests |

## E2E Tests (Playwright)

```bash
# One-time install (downloads browsers)
make e2e-install

# Run e2e (starts server, runs migrations, uses a dedicated port)
make e2e

# If you're already running the app elsewhere:
E2E_WEB_SERVER=1 BASE_URL=http://localhost:3000 make e2e

# Customize the port used by Playwright's webServer:
E2E_PORT=41731 make e2e
```

## Documentation

- [Overview](docs/00-overview.md)
- [Business](docs/01-business.md)
- [Architecture](docs/02-architecture.md)
- [Data Model](docs/03-data-model.md)
- [Integrations](docs/04-integrations.md)
- [Operations](docs/05-ops.md)
- [Dev Workflow](docs/06-dev-workflow.md)
- [Style Guide](docs/07-style-guide.md)
- [Decisions](docs/08-decisions.md)


## Runbooks

- [Deploy](docs/runbooks/deploy.md)
- [Rollback](docs/runbooks/rollback.md)
- [DB Restore](docs/runbooks/db-restore.md)
- [Jobs](docs/runbooks/jobs.md)
- [Cron](docs/runbooks/cron.md)
- [Alerts](docs/runbooks/alerts.md)
- [Support](docs/runbooks/support.md)
- [Sunset](docs/runbooks/sunset.md)

## Environment

See `.env.example` for the full list of environment variables. All secrets are managed via Doppler.

## License

Private
