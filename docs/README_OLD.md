# n8n Deployment Suite

A comprehensive deployment solution for n8n (workflow automation tool) with support for local and GCP VM deployments, with optional Cloudflare Tunnel integration.

## 🚀 Quick Start

```bash
# Clone this repository
git clone <your-repo-url>
cd n8n

# Make the main script executable
chmod +x deploy.sh
chmod +x scripts/*.sh

# Run the deployment manager
./deploy.sh
```

The interactive menu will guide you through all deployment options!

## 📋 Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Deployment Options](#deployment-options)
- [Detailed Setup Instructions](#detailed-setup-instructions)
- [Project Structure](#project-structure)
- [Configuration](#configuration)
- [Troubleshooting](#troubleshooting)

## ✨ Features

### Deployment Options
- ✅ **Local deployment** - Quick setup without tunnel (http://localhost:5678)
- ✅ **Local with Cloudflare Tunnel** - Secure HTTPS access to local instance
- ✅ **GCP VM deployment** - Cloud deployment on GCP free tier
- ✅ **GCP VM with Cloudflare Tunnel** - Production-ready cloud deployment with HTTPS

### Common Features
- 🐘 PostgreSQL database for data persistence
- 🔄 Auto-restart on system reboot
- 📦 Docker-based deployment
- 🔧 Easy configuration management
- 📝 Comprehensive logging

## 📦 Prerequisites

### For Local Deployments
- **Docker Desktop** - [Install Docker](https://www.docker.com/products/docker-desktop)
- **Docker Compose** - Included with Docker Desktop

### For Local with Tunnel
- Everything from local deployment, plus:
- **Cloudflare Account** - [Sign up](https://dash.cloudflare.com/sign-up)
- **Domain added to Cloudflare** - DNS must be managed by Cloudflare
- **cloudflared CLI** - [Installation guide](terraform/INSTALL_CLOUDFLARED.md)

### For GCP VM Deployments
- **Google Cloud Platform Account** - [Sign up](https://cloud.google.com/)
- **GCP Billing Account** - Enable billing to use VM
- **gcloud CLI** - [Install gcloud](https://cloud.google.com/sdk/docs/install)
- **Terraform** - [Install Terraform](https://www.terraform.io/downloads)

### For GCP VM with Tunnel
- Everything from GCP VM deployment, plus:
- Same Cloudflare requirements as local with tunnel

## 🎯 Deployment Options

### Option 1: Local Deployment (No Tunnel)

**Best for:** Development, testing, local use

```bash
./deploy.sh
# Choose option 1

# Or run directly:
./scripts/deploy-local.sh
```

**Access:** http://localhost:5678

**Configuration:**
- Edit `deployments/local/config.env` to customize settings
- Default timezone: UTC
- Default database password: n8n_secure_password

### Option 2: Local with Cloudflare Tunnel

**Best for:** Accessing local n8n from anywhere securely

```bash
./deploy.sh
# Choose option 2

# Or run directly:
./scripts/deploy-local-with-tunnel.sh
```

**Setup Required:**
1. Copy `deployments/local-with-tunnel/config.env.example` to `config.env`
2. Add your Cloudflare Tunnel token
3. Set your domain name
4. Run the deployment script

**Access:** https://your-domain.com

### Option 3: GCP VM Deployment (No Tunnel)

**Best for:** Cloud deployment with custom networking

```bash
./deploy.sh
# Choose option 5

# Or run directly:
./scripts/deploy-vm.sh
```

**Setup Required:**
1. Edit `terraform/terraform.tfvars` and add your GCP billing account ID
2. Run the deployment script

**Access:** Via VM's external IP (requires firewall configuration)

### Option 4: GCP VM with Cloudflare Tunnel (Recommended for Production)

**Best for:** Production deployment with automatic HTTPS

```bash
./deploy.sh
# Choose option 6

# Or run directly:
./scripts/deploy-vm-with-tunnel.sh
```

**This is an automated setup!** The script will:
1. Setup Cloudflare Tunnel automatically
2. Configure DNS records
3. Deploy VM with Terraform
4. Configure everything for you

**Access:** https://your-domain.com

## 📖 Detailed Setup Instructions

### Setting up Cloudflare Tunnel

#### Automated Setup (Recommended)
```bash
./scripts/deploy-vm-with-tunnel.sh
# The script handles everything automatically!
```

#### Manual Setup
If you need to setup the tunnel separately:
```bash
cd terraform
./setup-tunnel.sh
```

Follow the prompts to:
1. Login to Cloudflare
2. Create a tunnel
3. Configure routing
4. Generate tunnel token

See [terraform/TUNNEL_SETUP.md](terraform/TUNNEL_SETUP.md) for detailed instructions.

### Setting up GCP

1. **Get your Billing Account ID:**
   - Go to https://console.cloud.google.com/billing
   - Copy your Billing Account ID (format: `XXXXXX-XXXXXX-XXXXXX`)

2. **Authenticate gcloud:**
   ```bash
   gcloud auth login
   gcloud auth application-default login
   ```

3. **Configure Terraform:**
   ```bash
   cd terraform
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars and add your billing_account_id
   ```

## 📁 Project Structure

```
n8n/
├── deploy.sh                          # Main deployment manager (interactive)
├── docker-compose.yml                 # Legacy compose file (kept for reference)
├── scripts/                           # All deployment scripts
│   ├── deploy-local.sh               # Local deployment
│   ├── deploy-local-with-tunnel.sh   # Local + tunnel
│   ├── deploy-vm.sh                  # GCP VM deployment
│   ├── deploy-vm-with-tunnel.sh      # GCP VM + tunnel
│   ├── stop-local.sh                 # Stop local
│   ├── stop-local-tunnel.sh          # Stop local + tunnel
│   └── destroy-vm.sh                 # Destroy GCP resources
├── deployments/                       # Deployment configurations
│   ├── local/                        # Local deployment files
│   │   ├── docker-compose.yml
│   │   └── config.env.example
│   └── local-with-tunnel/            # Local + tunnel files
│       ├── docker-compose.yml
│       └── config.env.example
├── terraform/                         # GCP deployment
│   ├── main.tf                       # Terraform configuration
│   ├── variables.tf                  # Variables
│   ├── terraform.tfvars.example      # Example config
│   ├── docker-compose.yml.tpl        # Template for VM
│   ├── setup-tunnel.sh               # Tunnel setup script
│   ├── check_tunnel.sh               # Tunnel verification
│   ├── TUNNEL_SETUP.md               # Tunnel docs
│   ├── INSTALL_CLOUDFLARED.md        # cloudflared install guide
│   └── README.md                     # Terraform docs
└── local-files/                       # Shared files directory
```

## ⚙️ Configuration

### Local Deployment Configuration

Edit `deployments/local/config.env`:
```bash
TIMEZONE=UTC
POSTGRES_PASSWORD=your_secure_password
N8N_HOST=localhost
N8N_PROTOCOL=http
```

### Local with Tunnel Configuration

Edit `deployments/local-with-tunnel/config.env`:
```bash
TUNNEL_TOKEN=your_tunnel_token_here
N8N_DOMAIN=your-domain.com
N8N_PROTOCOL=https
TIMEZONE=UTC
POSTGRES_PASSWORD=your_secure_password
```

### GCP VM Configuration

Edit `terraform/terraform.tfvars`:
```hcl
billing_account_id = "XXXXXX-XXXXXX-XXXXXX"
project_name       = "n8n-automation"
tunnel_token       = "your_tunnel_token"  # Only for tunnel deployment
domain            = "your-domain.com"     # Only for tunnel deployment
timezone          = "UTC"
postgres_password  = "your_secure_password"
region            = "us-central1"
zone              = "us-central1-a"
```

## 🔧 Common Tasks

### View Logs

**Local:**
```bash
./deploy.sh  # Choose option 8
# Or directly:
cd deployments/local
docker-compose logs -f
```

**Local with Tunnel:**
```bash
./deploy.sh  # Choose option 9
# Or directly:
cd deployments/local-with-tunnel
docker-compose logs -f
```

**GCP VM:**
```bash
gcloud compute ssh n8n-server --zone=us-central1-a --project=PROJECT_ID
docker-compose logs -f
```

### Stop Deployments

**Local:**
```bash
./scripts/stop-local.sh
```

**Local with Tunnel:**
```bash
./scripts/stop-local-tunnel.sh
```

**GCP VM:**
```bash
./scripts/destroy-vm.sh  # This destroys all resources!
```

### Update n8n

**Local:**
```bash
cd deployments/local  # or local-with-tunnel
docker-compose pull
docker-compose up -d
```

**GCP VM:**
SSH into the VM and run the same commands.

### Backup Data

**Local:**
```bash
# Volumes are stored in Docker
docker volume ls | grep n8n
docker run --rm -v n8n_data:/data -v $(pwd):/backup ubuntu tar czf /backup/n8n-backup.tar.gz /data
```

### Restore Data

```bash
docker run --rm -v n8n_data:/data -v $(pwd):/backup ubuntu tar xzf /backup/n8n-backup.tar.gz -C /
```

## 🐛 Troubleshooting

### Docker not running
**Error:** `Cannot connect to the Docker daemon`
**Solution:** Start Docker Desktop

### Permission denied on scripts
**Error:** `Permission denied: ./deploy.sh`
**Solution:** 
```bash
chmod +x deploy.sh
chmod +x scripts/*.sh
```

### Cloudflare Tunnel not connecting
**Solution:**
1. Check token is correct in `config.env`
2. Verify domain is added to Cloudflare
3. Check DNS settings in Cloudflare dashboard
4. Run: `cd terraform && ./check_tunnel.sh`

### GCP Authentication failed
**Solution:**
```bash
gcloud auth login
gcloud auth application-default login
```

### Port 5678 already in use
**Solution:** Stop other n8n instances or change port in docker-compose.yml

### Terraform state locked
**Solution:**
```bash
cd terraform
terraform force-unlock LOCK_ID
```

### n8n container keeps restarting
**Solution:**
1. Check logs: `docker logs n8n`
2. Verify database is healthy: `docker logs n8n-postgres`
3. Check environment variables in docker-compose.yml

## 📚 Additional Resources

- [n8n Documentation](https://docs.n8n.io/)
- [Cloudflare Tunnel Documentation](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/)
- [GCP Free Tier](https://cloud.google.com/free)
- [Terraform Documentation](https://www.terraform.io/docs)

## 🤝 Contributing

See [terraform/CONTRIBUTING.md](terraform/CONTRIBUTING.md) for contribution guidelines.

## 📄 License

This project is open source and available under the MIT License.

## ⚠️ Important Notes

### Security
- Change default passwords in production
- Use strong passwords for PostgreSQL
- Keep tunnel tokens secret
- Don't commit sensitive files to git

### Cost Management (GCP)
- Free tier includes: e2-micro VM, 30GB storage, 1GB egress/month
- Monitor usage to avoid charges
- Destroy resources when not needed: `./scripts/destroy-vm.sh`

### Data Persistence
- All deployments use Docker volumes for data persistence
- Data survives container restarts
- Backup regularly for production use

## 🆘 Support

If you encounter issues:

1. Check the [Troubleshooting](#troubleshooting) section
2. Review logs using the deployment manager
3. Check individual README files in subdirectories
4. Review n8n documentation for n8n-specific issues

## 🎉 Getting Started Example

Complete beginner example for local deployment:

```bash
# 1. Clone the repository
git clone <your-repo-url>
cd n8n

# 2. Make scripts executable
chmod +x deploy.sh scripts/*.sh

# 3. Start Docker Desktop (if not running)

# 4. Run deployment manager
./deploy.sh

# 5. Choose option 1 for local deployment

# 6. Access n8n at http://localhost:5678

# 7. Create your first workflow!
```

That's it! You're ready to automate! 🚀
