# Security Policy

## Supported Versions

We release patches for security vulnerabilities. Currently supported versions:

| Version | Supported          |
| ------- | ------------------ |
| 1.x.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

The n8n Deployment Suite team takes security seriously. We appreciate your efforts to responsibly disclose your findings.

### How to Report

**Please DO NOT report security vulnerabilities through public GitHub issues.**

Instead, please report them via one of the following methods:

1. **GitHub Security Advisory** (Preferred)
   - Go to the Security tab
   - Click "Report a vulnerability"
   - Fill out the form with details

2. **Email**
   - Send details to: [your-security-email@example.com]
   - Include "SECURITY" in the subject line

### What to Include

Please include the following information:

- Type of issue (e.g., secrets exposure, privilege escalation, etc.)
- Full paths of source file(s) related to the issue
- Location of the affected source code (tag/branch/commit or direct URL)
- Step-by-step instructions to reproduce the issue
- Proof-of-concept or exploit code (if possible)
- Impact of the issue, including how an attacker might exploit it

### Response Timeline

- **Initial Response**: Within 48 hours
- **Status Update**: Within 7 days
- **Fix Timeline**: Depends on severity
  - Critical: 7-14 days
  - High: 14-30 days
  - Medium: 30-60 days
  - Low: 60-90 days

## Security Best Practices

When using this deployment suite:

### 1. Secrets Management

- ✅ **DO** use environment variables for sensitive data
- ✅ **DO** keep `.env` and `config.env` files out of version control
- ✅ **DO** use strong passwords for databases
- ❌ **DON'T** commit `terraform.tfvars` with real values
- ❌ **DON'T** hardcode secrets in files

### 2. Network Security

- ✅ **DO** use Cloudflare Tunnel for HTTPS access
- ✅ **DO** restrict SSH access to known IPs
- ✅ **DO** use firewall rules appropriately
- ❌ **DON'T** expose unnecessary ports publicly

### 3. Updates

- ✅ **DO** regularly update n8n Docker images
- ✅ **DO** keep Terraform and gcloud CLI updated
- ✅ **DO** monitor security advisories for dependencies
- ✅ **DO** test updates in non-production first

### 4. Access Control

- ✅ **DO** use strong authentication for n8n
- ✅ **DO** limit GCP service account permissions
- ✅ **DO** enable MFA on cloud accounts
- ❌ **DON'T** share credentials

### 5. Pre-Push Validation

Always run before committing:
```bash
./scripts/pre-push-check.sh
```

This checks for:
- Sensitive files in git
- Hardcoded secrets
- Missing example files
- Proper `.gitignore` configuration

## Known Security Considerations

### Docker Socket Exposure

This project doesn't expose Docker socket by default. If you customize and add Docker socket mounts, be aware of the security implications.

### GCP Free Tier Limitations

The free tier VM has limited resources. Monitor for:
- Resource exhaustion attacks
- Unexpected traffic spikes
- Storage limits

### Cloudflare Tunnel

Tunnel tokens provide access to your services:
- Treat tunnel tokens like passwords
- Rotate tokens periodically
- Revoke unused tunnels
- Monitor tunnel access logs

## Security Features

This project includes:

- ✅ `.gitignore` for sensitive files
- ✅ Pre-push security validation
- ✅ Separate configs per environment
- ✅ Example files for safe sharing
- ✅ HTTPS support via Cloudflare Tunnel
- ✅ Database password configuration
- ✅ No hardcoded secrets

## Dependencies

We rely on:
- Docker/Docker Compose
- n8n (official images)
- Cloudflare Tunnel
- Terraform
- Google Cloud Platform

Monitor security advisories for all dependencies.

## Disclosure Policy

When we receive a security report:

1. We'll confirm receipt within 48 hours
2. We'll provide a detailed response within 7 days
3. We'll work on a fix based on severity
4. We'll coordinate disclosure with the reporter
5. We'll credit the reporter (unless they prefer anonymity)
6. We'll publish a security advisory when fixed

## Bug Bounty

We currently don't have a bug bounty program, but we greatly appreciate responsible disclosure and will acknowledge contributors in our security advisories.

## Contact

For security concerns: [your-security-email@example.com]

For general issues: Use GitHub Issues

---

Thank you for helping keep n8n Deployment Suite and its users safe!
