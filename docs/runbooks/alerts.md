# Alerts Runbook — close-the-loop

## Alert Policy

### Severity Levels

| Level | Response Time | Examples |
|-------|--------------|---------|
| P0 - Critical | 15 minutes | App down, data loss, security breach |
| P1 - High | 1 hour | Error rate spike, payment failures |
| P2 - Medium | 4 hours | Degraded performance, job failures |
| P3 - Low | Next business day | Non-critical warnings |

## Error Reporting

- **Provider**: Sentry (via `ERROR_REPORTING_DSN`)
- **Environments**: preview, prod
- **Auto-captured**: Unhandled exceptions, promise rejections
- **Manual capture**: Use `captureError()` for handled errors worth tracking

## Alert Channels

<!-- TODO: Configure alert channels -->

| Channel | Severity | Setup |
|---------|----------|-------|
| Sentry dashboard | All | Automatic |
| Email | P0, P1 | Configure in Sentry |
| Slack | P0, P1, P2 | Configure in Sentry |

## Common Alerts

### Health Check Failing

1. Check Coolify dashboard — is container running?
2. Check container logs for crash errors
3. Check database connectivity (`/ready` endpoint)
4. If OOM: increase memory limits
5. If crash loop: check recent deploy, rollback if needed

### Error Rate Spike

1. Check Sentry for new error types
2. Correlate with recent deploys
3. Check if a single user/request is causing the spike
4. If deploy-related: rollback
5. If external: check integration status (Stripe, Resend, etc.)

### Database Connection Errors

1. Check Postgres server status
2. Check connection pool exhaustion (`DATABASE_POOL_SIZE`)
3. Check for long-running queries
4. Restart app if connection pool is corrupted



## Kill Switches

For emergencies, use kill switches:

```bash
# Enable maintenance mode
# Set KILL_SWITCH_MAINTENANCE=true in Doppler (prod config)

# Disable a specific feature
# Remove feature from FEATURE_FLAGS_ENABLED in Doppler
```
