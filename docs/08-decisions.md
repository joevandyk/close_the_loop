# Architectural Decisions — close-the-loop

Record important architectural decisions here using the ADR format.

## Template

```markdown
## ADR-NNN: Title

**Date**: YYYY-MM-DD
**Status**: Proposed | Accepted | Deprecated | Superseded

### Context
What is the issue we're seeing that is motivating this decision?

### Decision
What is the change that we're proposing or have agreed to implement?

### Consequences
What becomes easier or more difficult because of this change?
```

## Decisions

### ADR-001: Use Doppler for Secrets Management

**Date**: 2026-02-14
**Status**: Accepted

#### Context
We need a consistent, secure way to manage secrets across local, preview, and production environments without committing them to the repository.

#### Decision
Use Doppler as the single source of truth for all secrets and configuration. No `.env` files committed. No GitHub Secrets for app config.

#### Consequences
- All developers need Doppler CLI installed
- CI needs a `DOPPLER_TOKEN` secret
- Adding new env vars requires updating Doppler in all configs
- Secrets are never at risk of being committed

### ADR-002: Use Coolify for Deployment

**Date**: 2026-02-14
**Status**: Accepted

#### Context
We need a deployment platform that supports Docker containers with minimal configuration.

#### Decision
Use Coolify with Dockerfile build pack. Deploy the same image as multiple services (web, worker, cron) when needed.

#### Consequences
- Single Dockerfile for all process types
- Coolify handles TLS, reverse proxy, health checks
- Multi-service pattern requires Coolify configuration
- No vendor lock-in — standard Docker containers

### ADR-003: Structured JSON Logging

**Date**: 2026-02-14
**Status**: Accepted

#### Context
We need consistent, searchable, machine-readable logs across all services.

#### Decision
All logging must be structured JSON to stdout. Required fields: timestamp, level, msg, request_id, env, app.

#### Consequences
- Logs are easily parseable by log aggregation tools
- Developers must use the app logger, not console.log
- Request tracing is straightforward via request_id
