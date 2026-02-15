# Deploy Runbook — close-the-loop

## Overview

close-the-loop is deployed via **Coolify** using the **Dockerfile build pack**.

## Prerequisites

- Coolify access
- Doppler configured for target environment
- Docker image builds successfully

## Deploy Process

### Automatic (CI/CD)

1. Push to `main` branch
2. CI runs lint + test
3. Docker image built with `GIT_SHA` and `APP_VERSION` build args
4. Coolify detects push and deploys

### Manual Deploy

1. SSH into Coolify server (if needed)
2. Trigger redeploy from Coolify dashboard
3. Verify health endpoint: `curl https://TODO/health`

## Pre-Deploy Checklist

- [ ] All tests pass on CI
- [ ] Database migrations are backward-compatible
- [ ] New env vars added to Doppler (all environments)
- [ ] No breaking API changes (or clients updated)
- [ ] Runbooks updated for new operational procedures

## Post-Deploy Verification

1. Check `/health` returns `200`
2. Check `/version` returns expected SHA
3. Check `/ready` returns `200` (database connected)
4. Verify key user flows
5. Check error reporting for new errors
6. Monitor logs for unexpected warnings

## Multi-Service Deploy

If running worker/cron services:

```
# All services use the same Docker image
# Web:    CMD ["make", "dev"]  (or production start)
# Worker: CMD ["make", "worker"]
# Cron:   CMD ["make", "cron"]
```

Update all services in Coolify when deploying.

## Rollback

See [Rollback Runbook](rollback.md).
