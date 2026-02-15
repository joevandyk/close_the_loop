# Style Guide — close-the-loop

## Code Style

- Follow standard Elixir formatting (`mix format`)
- Use Credo for static analysis (`mix credo`)
- Use the Logger module (never `IO.puts` for logs)
- Follow Phoenix conventions for contexts and schemas

## Logging

- Always use structured JSON logging
- Required fields: `timestamp`, `level`, `msg`, `request_id`, `env`, `app`
- Never log secrets or PII
- Use appropriate log levels:
  - `error` — Something broke, needs attention
  - `warn` — Something unexpected, but handled
  - `info` — Normal business events (user signed up, payment received)
  - `debug` — Detailed debug info (not in production)

```
// Good
logger.info({ userId: user.id, plan: 'pro' }, 'subscription created');

// Bad
console.log('user subscribed', user);  // No structured logging
logger.info({ password: user.password }, 'user login');  // Logging secrets
```

## Security Headers

All responses should include:

```
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
X-XSS-Protection: 0
Referrer-Policy: strict-origin-when-cross-origin
Content-Security-Policy: default-src 'self'
Strict-Transport-Security: max-age=31536000; includeSubDomains
```

## CORS Policy

- Local: Allow `localhost:*`
- Preview: Allow preview domain
- Production: Allow production domain only
- Never use `Access-Control-Allow-Origin: *` in production

## Rate Limiting

- Apply rate limiting to auth endpoints (login, register, password reset)
- Apply rate limiting to API endpoints
- Use reasonable defaults (e.g., 100 requests/minute per IP)
- Return `429 Too Many Requests` with `Retry-After` header

## Error Responses

Use consistent error response format:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Email is required",
    "details": {}
  }
}
```

## API Conventions

- Use kebab-case for URL paths
- Use camelCase for JSON keys
- Use ISO 8601 for dates
- Use UUIDs for IDs
- Paginate list endpoints
- Return appropriate HTTP status codes
