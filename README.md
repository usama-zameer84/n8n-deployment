<p align="center">
  <img src="logo.png" alt="n8n Deployment Suite" width="200"/>
</p>

<h1 align="center">n8n Deployment Suite</h1>

<p align="center">
  <strong>Complete deployment solution for n8n workflow automation</strong>
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#quick-start">Quick Start</a> •
  <a href="#deployment-options">Deployment Options</a> •
  <a href="#documentation">Documentation</a> •
  <a href="#contributing">Contributing</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/n8n-latest-orange" alt="n8n"/>
  <img src="https://img.shields.io/badge/docker-required-blue" alt="Docker"/>
  <img src="https://img.shields.io/badge/terraform-1.0+-purple" alt="Terraform"/>
  <img src="https://img.shields.io/badge/license-MIT-green" alt="License"/>
</p>

---

## 🌟 Features

<table>
  <tr>
    <td>🐳 <strong>Docker-based</strong></td>
    <td>Consistent deployments across environments</td>
  </tr>
  <tr>
    <td>☁️ <strong>Multi-platform</strong></td>
    <td>Local, GCP, or any cloud provider</td>
  </tr>
  <tr>
    <td>🔒 <strong>Secure by default</strong></td>
    <td>HTTPS with Cloudflare Tunnel integration</td>
  </tr>
  <tr>
    <td>🚀 <strong>One-command deploy</strong></td>
    <td>Automated setup scripts for all scenarios</td>
  </tr>
  <tr>
    <td>📦 <strong>Production-ready</strong></td>
    <td>Auto-restart, data persistence</td>
  </tr>
  <tr>
    <td>🎯 <strong>Flexible configs</strong></td>
    <td>Environment-specific configurations</td>
  </tr>
</table>

## 🚀 Quick Start

### Option 1: Interactive Menu (Recommended for beginners)

```bash
# Clone the repository
git clone https://github.com/yourusername/n8n-deployment-suite.git
cd n8n-deployment-suite

# Run the interactive deployment manager
./deploy.sh
```

### Option 2: Direct Deployment

**Local Development:**
```bash
./scripts/deploy-local.sh
```
Access at: http://localhost:5678

**Production (GCP with HTTPS):**
```bash
# One-time configuration
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
# Edit terraform.tfvars with your details

# Deploy (includes automated tunnel setup!)
./scripts/deploy-vm-with-tunnel.sh
```
Access at: https://your-domain.com

## 📋 Deployment Options

| Option | Use Case | Command | Access |
|--------|----------|---------|--------|
| **Local** | Development & Testing | `./scripts/deploy-local.sh` | http://localhost:5678 |
| **Local + Tunnel** | Remote access to local | `./scripts/deploy-local-with-tunnel.sh` | https://your-domain.com |
| **GCP VM** | Cloud deployment | `./scripts/deploy-vm.sh` | Via VM IP |
| **GCP VM + Tunnel** ⭐ | Production (Recommended) | `./scripts/deploy-vm-with-tunnel.sh` | https://your-domain.com |

## 📂 Project Structure

```
n8n-deployment-suite/
├── deploy.sh                 # Interactive deployment manager
├── scripts/                  # Deployment automation scripts
│   ├── deploy-local.sh
│   ├── deploy-local-with-tunnel.sh
│   ├── deploy-vm.sh
│   ├── deploy-vm-with-tunnel.sh
│   ├── setup-tunnel.sh
│   ├── check_tunnel.sh
│   └── ...
├── deployments/              # Environment-specific configs
│   ├── local/
│   └── local-with-tunnel/
├── terraform/                # Infrastructure as Code
│   ├── main.tf
│   ├── variables.tf
│   └── ...
├── docs/                     # Documentation
│   ├── DEPLOYMENT_GUIDE.md
│   ├── QUICK_REFERENCE.md
│   └── ...
└── local-files/             # Shared files directory
```

## 📚 Documentation

- **[Quick Reference](docs/QUICK_REFERENCE.md)** - Fast command lookup
- **[Deployment Guide](docs/DEPLOYMENT_GUIDE.md)** - Detailed step-by-step instructions
- **[Terraform Documentation](docs/TERRAFORM.md)** - Infrastructure details
- **[Tunnel Setup](docs/TUNNEL_SETUP.md)** - Cloudflare Tunnel configuration
- **[Cloudflared Installation](docs/INSTALL_CLOUDFLARED.md)** - Install cloudflared CLI

## ⚙️ Prerequisites

### Basic Requirements
- Docker Desktop (for local deployments)
- Docker Compose (included with Docker Desktop)

### For Cloud Deployments
- Google Cloud Platform account with billing enabled
- gcloud CLI installed and authenticated
- Terraform installed

### For Tunnel (HTTPS) Access
- Cloudflare account
- Domain managed by Cloudflare
- cloudflared CLI installed

📖 **[Complete prerequisites list](docs/DEPLOYMENT_GUIDE.md#prerequisites)**

## 🔧 Configuration

### Local Deployment

1. Copy the example configuration:
```bash
cp deployments/local/config.env.example deployments/local/config.env
```

2. Edit `config.env` with your preferences

3. Deploy:
```bash
./scripts/deploy-local.sh
```

### Local Deployment with Tunnel

1. Copy the example configuration:
```bash
cp deployments/local-with-tunnel/config.env.example deployments/local-with-tunnel/config.env
```

2. Edit `config.env` with your Tunnel Token and Domain.

3. (Optional) Configure Tunnel Ingress:
   If you need custom ingress rules or a specific tunnel ID, copy and edit the config file:
```bash
cp deployments/local-with-tunnel/config.yml.example deployments/local-with-tunnel/config.yml
```
   *Note: This file is git-ignored for security. The deployment script can generate a basic one if missing.*

4. Deploy:
```bash
./scripts/deploy-local-with-tunnel.sh
```

### Cloud Deployment with Tunnel

1. Configure Terraform:
```bash
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
# Edit with your GCP billing account ID and domain
```

2. Authenticate:
```bash
gcloud auth login
gcloud auth application-default login
```

3. Deploy (tunnel setup is automated):
```bash
./scripts/deploy-vm-with-tunnel.sh
```

## 🛠️ Common Tasks

### View Logs
```bash
# From the deployment directory
cd deployments/local
docker-compose logs -f
```

### Stop Deployment
```bash
./scripts/stop-local.sh              # Stop local
./scripts/stop-local-tunnel.sh       # Stop local with tunnel
./scripts/destroy-vm.sh              # Destroy GCP resources
```

### Update n8n
```bash
cd deployments/local
docker-compose pull
docker-compose up -d
```

## 🔒 Security

- ✅ Sensitive files protected by `.gitignore`
- ✅ Pre-push security validation script
- ✅ No hardcoded secrets in code
- ✅ Environment-specific configuration files
- ✅ HTTPS support via Cloudflare Tunnel

Run security check before pushing:
```bash
./scripts/pre-push-check.sh
```

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| Scripts not executable | `chmod +x deploy.sh scripts/*.sh` |
| Docker not running | Start Docker Desktop |
| Port 5678 already in use | `lsof -i :5678` then kill process or change port |
| Tunnel not connecting | Verify token in `config.env` and domain in Cloudflare |
| GCP authentication failed | Run `gcloud auth login` |

📖 **[Full troubleshooting guide](docs/DEPLOYMENT_GUIDE.md#troubleshooting)**

## 🤝 Contributing

Contributions are welcome! Please read our [Contributing Guide](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

### Development Setup
```bash
git clone https://github.com/yourusername/n8n-deployment-suite.git
cd n8n-deployment-suite
./scripts/deploy-local.sh
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [n8n](https://n8n.io/) - The workflow automation tool
- [Cloudflare](https://www.cloudflare.com/) - Tunnel and DNS services
- [Google Cloud Platform](https://cloud.google.com/) - Cloud infrastructure

## 📞 Support

- 📖 [Documentation](docs/)
- 🐛 [Issue Tracker](https://github.com/yourusername/n8n-deployment-suite/issues)
- 💬 [Discussions](https://github.com/yourusername/n8n-deployment-suite/discussions)

## ⭐ Star History

If you find this project useful, please consider giving it a star!

---

<p align="center">
  Made with ❤️ for the n8n community
</p>

<p align="center">
  <a href="#top">Back to top ⬆️</a>
</p>
