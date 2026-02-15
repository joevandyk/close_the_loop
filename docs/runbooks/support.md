# Support Runbook — close-the-loop

## Support Channels

| Channel | Address |
|---------|---------|
| Support email | TODO |
| Bug reports | GitHub Issues |

## Triage Process

1. New support request received
2. Categorize: Bug, Feature request, Account issue, Billing
3. Assign severity (P0-P3)
4. Respond with acknowledgment
5. Investigate and resolve
6. Follow up with user

## Common Issues

### Account Issues

#### User Can't Log In

1. Verify account exists in database
2. Check auth provider status (if hosted auth)
3. Reset password / session if needed
4. Check for rate limiting on login endpoint


#### User Wants to Delete Account
1. Confirm identity
2. Export user data if requested (GDPR)

4. Soft-delete or anonymize user record
5. Send confirmation email



### Technical Issues

#### User Reports Bug
1. Ask for: browser, OS, steps to reproduce, screenshots
2. Check error reporting for matching errors
3. Attempt to reproduce
4. Create GitHub issue if confirmed
5. Update user on fix timeline

## Admin Actions

<!-- TODO: Define admin interface location -->

### Manual Intervention Workflows

- **User impersonation**: <!-- TODO: Document how to view app as user -->
- **Manual data fixes**: Connect to DB via `doppler run -- psql $DATABASE_URL`

- **Feature flag override**: Update in Doppler config

## Email Templates

### Acknowledgment
> Hi {name}, we received your support request. We'll get back to you within {SLA}. Reference: {ticket_id}

### Resolution
> Hi {name}, we've resolved your issue. {description of fix}. Let us know if you need anything else.

### Escalation
> Hi {name}, we're still investigating your issue. Here's what we know so far: {update}. We'll follow up by {date}.
