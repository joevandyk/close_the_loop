# Data Model — close-the-loop


## Database

- **Engine**: PostgreSQL
- **Naming**: `close-the-loop_<env>` (e.g., `close-the-loop_prod`)
- **Migrations**: Ecto

## Core Tables

<!-- TODO: Define your data model -->

### users (if auth enabled)

| Column | Type | Notes |
|--------|------|-------|
| id | uuid | Primary key |
| email | text | Unique, not null |
| created_at | timestamptz | Default now() |
| updated_at | timestamptz | Default now() |



## Indexes

<!-- TODO: Define indexes for common queries -->

## Migrations

Run migrations:
```bash
scripts/migrate
```

Seed data:
```bash
scripts/seed
```


