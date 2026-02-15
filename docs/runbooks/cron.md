# Cron Runbook — close-the-loop



## Overview

Cron jobs run on a schedule in a separate process using the same Docker image.

- **Entrypoint**: `make cron`
- **Deployed as**: Separate Coolify service (same Docker image, different CMD)

## Key Requirements

- **Idempotency**: Every cron job MUST be idempotent.
- **Overlap prevention**: Ensure jobs don't overlap if they run longer than the interval.
- **Logging**: Log start, end, and duration of each cron run.
- **Alerting**: Alert if a cron job fails or doesn't run.

## Scheduled Jobs

<!-- TODO: Define your cron jobs -->

| Job | Schedule | Description |
|-----|----------|-------------|
| Example cleanup | `0 3 * * *` | Clean up expired records |
| Example digest | `0 9 * * 1` | Send weekly digest emails |

## Starting the Cron Process

```bash
# Local (with Doppler)
scripts/cron

# Production (in Coolify)
# Set CMD to: make cron
```

## Monitoring

- Verify cron jobs are running on schedule
- Alert if a job misses its window
- Monitor job duration trends

## Manual Trigger

```bash
# Run a specific cron job manually
doppler run -- make cron-<job-name>
```


