# Integrations — close-the-loop

## Overview

| Service | Purpose | Required | Env Vars |
|---------|---------|----------|----------|
| PostHog | Analytics | No | `POSTHOG_API_KEY`, `POSTHOG_HOST` |

| Resend | Email | Yes | `RESEND_API_KEY`, `EMAIL_FROM` |
| Twilio | SMS | Yes | `TWILIO_ACCOUNT_SID`, `TWILIO_AUTH_TOKEN`, `TWILIO_PHONE_NUMBER` |
| OpenAI | Issue categorization/dedupe helpers | Yes | `OPENAI_API_KEY`, `OPENAI_MODEL` |
| Sentry | Error reporting | No | `ERROR_REPORTING_DSN`, `ERROR_REPORTING_ENV` |
| Doppler | Secrets | Yes | `DOPPLER_TOKEN` (CI only) |


## PostHog (Analytics)

- Track key business events (see metrics in `docs/01-business.md`)
- Required events:
  - `user_signed_up`
  - `user_activated`
  
  - `feature_used` (with feature name property)
- Client-side: Use PostHog JS SDK
- Server-side: Use PostHog Node SDK

### Setup

1. Create PostHog project
2. Add `POSTHOG_API_KEY` to Doppler
3. Events are auto-tracked via the analytics module





## Resend (Email)

- Transactional email delivery
- Dev stub: logs email to console if `RESEND_API_KEY` is not set
- Email patterns:
  - Welcome / onboarding
  - Receipt / invoice
  - Password reset (if local auth)
  - Support acknowledgment

### Setup

1. Create Resend account
2. Verify sending domain
3. Add `RESEND_API_KEY` to Doppler



## Twilio (SMS)

- SMS notifications (optional)
- Dev stub: logs SMS to console if credentials not set
- Use sparingly — SMS costs money

### Setup

1. Create Twilio account
2. Get a phone number
3. Add credentials to Doppler

## OpenAI

- Used for issue categorization (and future dedupe helpers)
- No fallback logic: if OpenAI is not configured/available, issues may remain uncategorized
- Default model: `gpt-5.2` (override with `OPENAI_MODEL`)

### Setup

1. Create an OpenAI API key
2. Add `OPENAI_API_KEY` to Doppler (dev/preview/prod)
3. Optionally add `OPENAI_MODEL` if you want to pin a snapshot model


## Sentry (Error Reporting)

- Optional but recommended for preview/prod
- Provider-agnostic interface: swap providers by changing the DSN
- Captures unhandled exceptions automatically
- Add custom context with `setErrorContext()`

### Setup

1. Create Sentry project
2. Add `ERROR_REPORTING_DSN` to Doppler
3. Errors are auto-captured via the error reporting module
