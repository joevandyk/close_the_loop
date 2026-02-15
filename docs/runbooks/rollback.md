# Rollback Runbook — close-the-loop

## When to Rollback

- Health check failing after deploy
- Error rate spike
- Critical bug in production
- Data integrity issues

## Rollback Process

### Via Coolify

1. Open Coolify dashboard
2. Navigate to close-the-loop service
3. Select the previous successful deployment
4. Click "Rollback" / redeploy previous version

### Via Git

```bash
# Find the last known good commit
git log --oneline -10

# Revert to previous commit
git revert HEAD
git push origin main

# Or force deploy a specific SHA
# (Coolify will pick up the push)
```

### Database Considerations

⚠️ **If the deploy included migrations:**

1. Check if migrations are backward-compatible
2. If yes, rollback code only — migrations can stay
3. If no, you need to manually reverse the migration:

```bash
# Connect to database and reverse the migration
# This is runtime-specific — see your migration tool docs
mix ecto.rollback
```

## Post-Rollback

1. Verify `/health` returns `200`
2. Verify `/version` returns the rolled-back SHA
3. Check error reporting — error rate should drop
4. Notify team of rollback
5. Create incident report if needed

## Prevention

- Always make migrations backward-compatible
- Use feature flags for risky changes
- Deploy during low-traffic hours for major changes
- Test in preview environment first
