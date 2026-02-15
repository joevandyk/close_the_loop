# Operations — close-the-loop

## Environments

| Environment | Doppler Config | Database | Domain |
|-------------|---------------|----------|--------|
| Local | `local` | `close-the-loop_local` | localhost:3000 |
| Preview | `preview` | `close-the-loop_preview` | preview.TODO |
| Production | `prod` | `close-the-loop_prod` | TODO |

## Secrets Management (Doppler)

**Doppler is the single source of truth for all secrets and configuration.**

- Doppler project: `close-the-loop`
- Configs: `local`, `preview`, `prod`
- `APP_ENV` always matches the Doppler config name
- Never commit `.env` files
- Never use GitHub Secrets for app config (only `DOPPLER_TOKEN` for CI)

### Adding a New Secret

1. Add to Doppler project in all configs (local, preview, prod)
2. Update `platform/env.schema.yml` in the sideproj repo
3. Update `.env.example` with placeholder
4. Reference via `process.env.NEW_VAR` (or system env in Phoenix)

## Environment Variables

See `.env.example` for the full schema. Key variables:

### Core
| Variable | Required | Description |
|----------|----------|-------------|
| `APP_NAME` | Yes | Application name |
| `APP_ENV` | Yes | Environment (local/preview/prod) |
| `PORT` | Yes | HTTP port |
| `LOG_LEVEL` | No | Logging level (default: info) |
| `APP_VERSION` | No | Version, set at build time |
| `GIT_SHA` | No | Git SHA, set at build time |


### Database
| Variable | Required | Description |
|----------|----------|-------------|
| `DATABASE_URL` | Yes | PostgreSQL connection string |
| `DATABASE_POOL_SIZE` | No | Connection pool size |





### Email
| Variable | Required | Description |
|----------|----------|-------------|
| `RESEND_API_KEY` | Yes | Resend API key |
| `EMAIL_FROM` | No | Default from address |


## Deployment

See [Deploy Runbook](runbooks/deploy.md).

- Deploy target: Coolify (Dockerfile build pack)
- Build args: `GIT_SHA`, `APP_VERSION`
- Health check: `GET /health`

## Monitoring

- Structured JSON logs (stdout)
- Error reporting via Sentry (if configured)
- Health endpoint: `GET /health`
- Readiness endpoint: `GET /ready`
- Version endpoint: `GET /version`

## Runbooks

- [Deploy](runbooks/deploy.md)
- [Rollback](runbooks/rollback.md)
- [DB Restore](runbooks/db-restore.md)
- [Jobs](runbooks/jobs.md)
- [Cron](runbooks/cron.md)
- [Alerts](runbooks/alerts.md)
- [Support](runbooks/support.md)
- [Sunset](runbooks/sunset.md)
