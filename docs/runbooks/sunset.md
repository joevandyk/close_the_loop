# Sunset Runbook — close-the-loop

## When to Sunset

- Product is no longer viable
- Low usage / no revenue
- Replaced by a new product
- Cost exceeds value

## Sunset Process

### Phase 1: Decision (Week 0)

- [ ] Evaluate metrics: users, revenue, costs
- [ ] Decide sunset date (minimum 30 days notice)
- [ ] Determine data export obligations

### Phase 2: Notification (Week 1)

- [ ] Email all active users about sunset
- [ ] Update website with sunset notice
- [ ] Disable new signups
- [ ] Post in any community channels

### Phase 3: Grace Period (Weeks 2-4)

- [ ] Provide data export tools
- [ ] Support user migration

- [ ] Continue monitoring

### Phase 4: Shutdown (Week 5+)


- [ ] Take application offline (enable maintenance mode)
- [ ] Export final database backup
- [ ] Remove DNS records from Cloudflare
- [ ] Delete Coolify services
- [ ] Archive GitHub repository
- [ ] Clean up Doppler project
- [ ] Delete database

### Phase 5: Post-Shutdown

- [ ] Retain database backup for required period
- [ ] Keep support email active for 90 days
- [ ] Redirect domain to goodbye page (optional)
- [ ] Final retrospective

## Data Retention

- Database backups: Retain for 90 days after shutdown
- User data: Follow privacy policy obligations
- Logs: Retain for 30 days after shutdown
- Code: Archive in GitHub (don't delete)

## Legal Considerations

- Honor terms of service
- Comply with GDPR / data protection requirements
- Provide data export before shutdown

