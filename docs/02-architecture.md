# Architecture — close-the-loop

## System Diagram

```
┌─────────┐     ┌──────────┐     ┌──────────┐
│ Browser  │────▶│  close-the-loop  │────▶│ Postgres │
└─────────┘     └──────────┘     └──────────┘
                     │
                     ├──▶ Stripe (payments)
                     ├──▶ Resend (email)
                     ├──▶ PostHog (analytics)
                     └──▶ Sentry (errors)
```

## Runtime

- **Type**: Elixir Phoenix
- **Process**: Single web process + optional worker + optional cron
- **Deploy**: Docker container on Coolify

## Request Flow

1. Request arrives at Coolify reverse proxy
2. Routed to Docker container on PORT
3. Request ID assigned (or propagated from header)
4. Auth middleware validates session/token
5. Handler processes request
6. Structured JSON log emitted
7. Response returned

## Key Architectural Decisions

See [Decisions](08-decisions.md) for ADRs.

## Multi-Service Pattern (Coolify)

For apps with background workers or cron:

```
# In Coolify, deploy the same Docker image as multiple services:
# 1. Web service:  CMD ["make", "dev"]    (or production start command)
# 2. Worker:       CMD ["make", "worker"]
# 3. Cron:         CMD ["make", "cron"]
```

All services share the same Doppler config and database.

## Health Checks

| Endpoint | Purpose | Response |
|----------|---------|----------|
| `GET /health` | Liveness check | `{ "status": "ok" }` |
| `GET /ready` | Readiness (DB connected) | `{ "status": "ready" }` |
| `GET /version` | Version info | `{ "version": "...", "sha": "..." }` |

## Security

See [Style Guide](07-style-guide.md) for security headers and CORS policy.
