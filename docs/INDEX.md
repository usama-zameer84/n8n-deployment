# Documentation Index

Welcome to the n8n Deployment Suite documentation! This index will help you find what you need.

## 📖 Getting Started

**New to this project?** Start here:

1. **[README.md](../README.md)** - Project overview and quick start
2. **[Quick Reference](QUICK_REFERENCE.md)** - Fast command lookup
3. **[Deployment Guide](DEPLOYMENT_GUIDE.md)** - Detailed step-by-step instructions

## 📚 Core Documentation

### Main Guides

| Document | Description | Audience |
|----------|-------------|----------|
| **[README.md](../README.md)** | Project overview, features, quick start | Everyone |
| **[Quick Reference](QUICK_REFERENCE.md)** | Command cheat sheet, decision matrix | Users |
| **[Deployment Guide](DEPLOYMENT_GUIDE.md)** | Complete deployment instructions | Deployers |
| **[Setup Complete](SETUP_COMPLETE.md)** | Post-setup summary and next steps | New setups |

### Technical Documentation

| Document | Description | Audience |
|----------|-------------|----------|
| **[Terraform README](../terraform/README.md)** | Infrastructure as Code details | DevOps |
| **[Terraform Docs](TERRAFORM.md)** | Original terraform documentation | Reference |
| **[Tunnel Setup](TUNNEL_SETUP.md)** | Cloudflare Tunnel configuration | Advanced users |
| **[Tunnel Troubleshooting](TUNNEL_TROUBLESHOOTING.md)** | Fix inactive tunnels & Zero Trust issues | Users |
| **[Install Cloudflared](INSTALL_CLOUDFLARED.md)** | cloudflared CLI installation | Users |

### Project Standards

| Document | Description | Audience |
|----------|-------------|----------|
| **[Contributing](../CONTRIBUTING.md)** | How to contribute to this project | Contributors |
| **[Code of Conduct](../CODE_OF_CONDUCT.md)** | Community guidelines | Everyone |
| **[Security](../SECURITY.md)** | Security policy and best practices | Everyone |
| **[Changelog](../CHANGELOG.md)** | Version history and changes | Users |
| **[License](../LICENSE)** | MIT License | Everyone |

## 🎯 Documentation by Use Case

### I want to...

#### Deploy Locally for Testing
1. Read: [Quick Reference - Local Deployment](QUICK_REFERENCE.md#local-no-tunnel)
2. Run: `./scripts/deploy-local.sh`
3. Troubleshoot: [Deployment Guide - Troubleshooting](DEPLOYMENT_GUIDE.md#troubleshooting)

#### Deploy to Production
1. Read: [Deployment Guide - GCP VM with Tunnel](DEPLOYMENT_GUIDE.md#option-4-gcp-vm-with-cloudflare-tunnel-recommended-for-production)
2. Setup: [Terraform README](../terraform/README.md)
3. Configure: [Tunnel Setup](TUNNEL_SETUP.md)
4. Run: `./scripts/deploy-vm-with-tunnel.sh`

#### Fix Inactive Cloudflare Tunnel
1. Read: [Tunnel Troubleshooting - Tunnel Shows as INACTIVE](TUNNEL_TROUBLESHOOTING.md#tunnel-shows-as-inactive)
2. Run: `./scripts/activate-tunnel.sh`
3. Deploy: `./scripts/deploy-local-with-tunnel.sh` or `./scripts/deploy-vm-with-tunnel.sh`
4. Verify: `./scripts/check_tunnel.sh`

#### Understand the Infrastructure
1. Read: [Terraform README](../terraform/README.md)
2. Review: [Terraform Docs](TERRAFORM.md)
3. Customize: [Contributing Guide - Customization](../CONTRIBUTING.md#customization-guide)

#### Contribute to the Project
1. Read: [Contributing Guide](../CONTRIBUTING.md)
2. Setup: [Contributing - Development Setup](../CONTRIBUTING.md#development-setup)
3. Follow: [Code of Conduct](../CODE_OF_CONDUCT.md)

#### Report Security Issues
1. Read: [Security Policy](../SECURITY.md)
2. Report: [Security - Reporting](../SECURITY.md#reporting-a-vulnerability)

## 📂 File Organization

```
n8n-deployment-suite/
│
├── README.md                    # Main project README (START HERE!)
├── LICENSE                      # MIT License
├── CONTRIBUTING.md              # How to contribute
├── CODE_OF_CONDUCT.md          # Community guidelines
├── SECURITY.md                  # Security policy
├── CHANGELOG.md                 # Version history
│
├── docs/                        # 📚 All documentation
│   ├── INDEX.md (this file)    # Documentation index
│   ├── QUICK_REFERENCE.md      # Command cheat sheet
│   ├── DEPLOYMENT_GUIDE.md     # Detailed deployment guide
│   ├── SETUP_COMPLETE.md       # Post-setup summary
│   ├── TERRAFORM.md            # Original terraform docs
│   ├── TUNNEL_SETUP.md         # Tunnel configuration
│   ├── TUNNEL_TROUBLESHOOTING.md # Fix inactive tunnels
│   └── INSTALL_CLOUDFLARED.md  # Cloudflared installation
│
├── scripts/                     # 🛠️ All automation scripts
├── deployments/                 # 🎯 Deployment configurations
├── terraform/                   # ☁️ Infrastructure as Code
│   └── README.md               # Terraform-specific README
└── local-files/                # 📂 Shared files
```

## 🔍 Quick Search

### By Topic

**Deployment:**
- Local: [Quick Reference](QUICK_REFERENCE.md), [Deployment Guide](DEPLOYMENT_GUIDE.md#option-1-local-deployment-no-tunnel)
- Cloud: [Terraform README](../terraform/README.md), [Deployment Guide](DEPLOYMENT_GUIDE.md#option-4-gcp-vm-with-cloudflare-tunnel-recommended-for-production)
- Tunnel: [Tunnel Setup](TUNNEL_SETUP.md), [Install Cloudflared](INSTALL_CLOUDFLARED.md)

**Configuration:**
- Environment Variables: [Deployment Guide - Configuration](DEPLOYMENT_GUIDE.md#configuration)
- Terraform Variables: [Terraform README - Variables](../terraform/README.md#variables)
- Docker Compose: [Contributing - Customization](../CONTRIBUTING.md#customization-guide)

**Troubleshooting:**
- Common Issues: [Deployment Guide - Troubleshooting](DEPLOYMENT_GUIDE.md#troubleshooting)
- Terraform Issues: [Terraform README - Troubleshooting](../terraform/README.md#troubleshooting)
- Security: [Security - Best Practices](../SECURITY.md#security-best-practices)

**Development:**
- Contributing: [Contributing Guide](../CONTRIBUTING.md)
- Project Structure: [Contributing - Project Structure](../CONTRIBUTING.md#project-structure)
- Style Guide: [Contributing - Style Guidelines](../CONTRIBUTING.md#style-guidelines)

### By Skill Level

**Beginner:**
1. [README.md](../README.md) - Start here!
2. [Quick Reference](QUICK_REFERENCE.md) - Simple commands
3. [Deployment Guide](DEPLOYMENT_GUIDE.md) - Step-by-step

**Intermediate:**
1. [Terraform README](../terraform/README.md) - Infrastructure details
2. [Tunnel Setup](TUNNEL_SETUP.md) - Advanced networking
3. [Contributing](../CONTRIBUTING.md) - Customization

**Advanced:**
1. [Terraform Docs](TERRAFORM.md) - Deep technical details
2. [Security Policy](../SECURITY.md) - Security considerations
3. [Contributing - Style Guide](../CONTRIBUTING.md#style-guidelines) - Code standards

## 🔄 Document Lifecycle

### Recently Updated
- **README.md** - Restructured to GitHub standards (Dec 2025)
- **CONTRIBUTING.md** - Enhanced with more details (Dec 2025)
- **Terraform README** - New comprehensive guide (Dec 2025)

### Document Status

| Document | Status | Last Updated |
|----------|--------|--------------|
| README.md | ✅ Current | Dec 2025 |
| QUICK_REFERENCE.md | ✅ Current | Dec 2025 |
| DEPLOYMENT_GUIDE.md | ✅ Current | Dec 2025 |
| TERRAFORM.md | 📝 Reference | Original |
| TUNNEL_SETUP.md | 📝 Reference | Original |
| INSTALL_CLOUDFLARED.md | 📝 Reference | Original |

Legend:
- ✅ Current - Actively maintained
- 📝 Reference - Archived for reference
- 🔄 In Progress - Being updated

## 💡 Tips for Reading

1. **Start with README.md** - Get the big picture
2. **Use Quick Reference** - For fast command lookup
3. **Follow Deployment Guide** - For detailed instructions
4. **Check Troubleshooting** - When things go wrong
5. **Read Contributing** - Before modifying

## 🆘 Still Need Help?

1. **Search this documentation** - Use your browser's find (Ctrl/Cmd+F)
2. **Check existing issues** - Someone may have asked already
3. **Read troubleshooting guides** - Common solutions documented
4. **Ask in discussions** - Community can help
5. **Open an issue** - For bugs or feature requests

## 📞 Where to Get Support

- 📖 Documentation (you are here!)
- 🐛 [GitHub Issues](https://github.com/yourusername/n8n-deployment-suite/issues) - Bug reports
- 💬 [GitHub Discussions](https://github.com/yourusername/n8n-deployment-suite/discussions) - Questions
- 🔒 [Security](../SECURITY.md#reporting-a-vulnerability) - Security issues (private)

---

**Document Version:** 1.0  
**Last Updated:** December 2025  
**Maintained By:** n8n Deployment Suite Contributors

[Back to Main README](../README.md) | [Quick Reference](QUICK_REFERENCE.md) | [Deployment Guide](DEPLOYMENT_GUIDE.md)
