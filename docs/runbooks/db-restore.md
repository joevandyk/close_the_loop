# DB Restore Runbook — close-the-loop



## Backup Strategy

<!-- TODO: Define backup strategy -->

- Automated backups: Daily (configure in your Postgres hosting)
- Retention: 30 days minimum
- Test restores: Monthly

## Restore Process

### 1. Identify the Issue

- What data was lost or corrupted?
- When did the issue occur?
- What is the blast radius?

### 2. Find the Right Backup

```bash
# List available backups (hosting-specific)
# Example for pg_dump backups:
ls -la /backups/close-the-loop/
```

### 3. Restore to a Temporary Database

```bash
# Create temp database
createdb close-the-loop_restore

# Restore backup
pg_restore -d close-the-loop_restore /path/to/backup.dump

# Verify data
psql close-the-loop_restore -c "SELECT count(*) FROM users;"
```

### 4. Swap or Migrate Data

**Option A: Full restore (nuclear)**
```bash
# ⚠️ This replaces ALL data
# Take the app offline first
doppler run -- make maintenance-on

# Drop and restore
dropdb close-the-loop_prod
createdb close-the-loop_prod
pg_restore -d close-the-loop_prod /path/to/backup.dump

# Bring app back online
doppler run -- make maintenance-off
```

**Option B: Selective restore**
```bash
# Copy specific tables or rows from the restore DB
pg_dump -t specific_table close-the-loop_restore | psql close-the-loop_prod
```

### 5. Verify

- Check data integrity
- Run application health checks
- Verify key user flows

### 6. Clean Up

```bash
dropdb close-the-loop_restore
```

## Post-Incident

- Document what happened
- Update backup strategy if needed
- Add monitoring to prevent recurrence


