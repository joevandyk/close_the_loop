# Background Jobs Runbook — close-the-loop



## Overview

Background jobs run in a separate worker process using the same Docker image.

- **Entrypoint**: `make worker`
- **Queue backend**: Oban (recommended)
- **Deployed as**: Separate Coolify service (same Docker image, different CMD)

## Key Requirements

- **Idempotency**: Every job MUST be idempotent. If a job runs twice, the result should be the same.
- **Retries**: Jobs should handle transient failures gracefully.
- **Timeouts**: Set appropriate timeouts for each job type.
- **Logging**: Jobs must log structured JSON with job name, ID, and duration.

## Starting the Worker

```bash
# Local (with Doppler)
scripts/worker

# Production (in Coolify)
# Set CMD to: make worker
```

## Monitoring

- Watch logs for failed jobs
- Set up alerts for job failure rate > threshold
- Monitor queue depth
- Use the Oban Web dashboard at `/app/oban` (requires sign-in)

## Common Issues

### Jobs Stuck / Not Processing

1. Check worker process is running
2. Check Redis connection (if applicable)
3. Check for errors in worker logs
4. Restart worker process

### Job Failed

1. Check job logs for error details
2. If transient: job will auto-retry
3. If permanent: fix the issue, then retry manually

## Adding a New Job

1. Create job handler (must be idempotent)
2. Register job in the worker
3. Add logging
4. Add tests
5. Document expected runtime and resource usage


