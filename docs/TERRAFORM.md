# n8n on GCP with Cloudflare Tunnel - Terraform

This Terraform configuration deploys n8n (workflow automation tool) on Google Cloud Platform's free tier (e2-micro VM) with Cloudflare Tunnel for secure access.

## Features

- ✅ **Free Tier**: Uses GCP's Always Free e2-micro instance
- ✅ **PostgreSQL**: Persistent database storage
- ✅ **Cloudflare Tunnel**: Secure HTTPS access without exposing ports
- ✅ **Docker Compose**: Easy container management
- ✅ **Swap Memory**: 2GB swap for low-memory VM
- ✅ **Auto-start**: Containers start automatically on boot
- ✅ **Automated Setup**: One-command tunnel creation and configuration

## Quick Start

```bash
# 1. Clone and navigate
git clone <your-repo-url> && cd terraform

# 2. Install prerequisites
brew install cloudflared terraform  # macOS
gcloud auth login                    # Authenticate with GCP

# 3. Setup Cloudflare Tunnel (automated!)
./setup-tunnel.sh

# 4. Edit terraform.tfvars and add your GCP billing account ID

# 5. Deploy
terraform init
terraform apply

# 6. Access n8n at your configured domain!
```

## Prerequisites

1. **Google Cloud Platform**
   - GCP account with billing enabled
   - Billing Account ID (find at: https://console.cloud.google.com/billing)

2. **Cloudflare**
   - Cloudflare account
   - Domain added to Cloudflare (DNS managed by Cloudflare)
   - [cloudflared CLI](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/downloads/) installed (see [INSTALL_CLOUDFLARED.md](INSTALL_CLOUDFLARED.md))

3. **Local Machine**
   - [Terraform](https://www.terraform.io/downloads) installed
   - [gcloud CLI](https://cloud.google.com/sdk/docs/install) installed
   - Authenticated with GCP: `gcloud auth login`

## Setup Instructions

### 1. Clone this repository

```bash
git clone <your-repo-url>
cd terraform
```

### 2. Set up Cloudflare Tunnel (Automated)

Run the automated setup script:

```bash
./setup-tunnel.sh
```

This script will:
- ✅ Authenticate with Cloudflare
- ✅ Create a new tunnel
- ✅ Configure DNS for your domain
- ✅ Generate the tunnel token
- ✅ Automatically update `terraform.tfvars` with the token and domain

📖 **See [TUNNEL_SETUP.md](TUNNEL_SETUP.md) for detailed explanation of what this script does**

**Or manually create the tunnel:**

If you prefer manual setup or the script doesn't work:

```bash
# Login to Cloudflare
cloudflared tunnel login

# Create tunnel
cloudflared tunnel create n8n-tunnel

# Configure DNS
cloudflared tunnel route dns n8n-tunnel n8n.yourdomain.com

# Get token
cloudflared tunnel token n8n-tunnel
```

### 3. Configure remaining variables

Edit `terraform.tfvars` with your GCP values (tunnel values already set by script):

```hcl
billing_account_id = "YOUR-BILLING-ACCOUNT-ID"  # Get from GCP Console
project_name       = "n8n-automation"            # Change if desired
postgres_password  = "your-secure-password"      # CHANGE THIS!
timezone           = "America/New_York"          # Optional

# These are set by setup-tunnel.sh:
# tunnel_token     = "..." (auto-filled)
# domain           = "..." (auto-filled)
```

### 4. Deploy

```bash
# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Deploy
terraform apply
```

### 5. Access n8n

Visit your configured domain (e.g., `https://n8n.yourdomain.com`) and complete the n8n setup.

## Outputs

After deployment, Terraform outputs:

- `instance_ip`: Public IP of the VM (for SSH access)
- `project_id`: GCP Project ID

## Useful Commands

### SSH into the VM

```bash
gcloud compute ssh n8n-server --project=<project-id> --zone=us-central1-a
```

### Check Status & Logs

**View all container logs (follow mode):**
```bash
# From your local machine
gcloud compute ssh n8n-server --project=<project-id> --zone=us-central1-a --command="cd /home/ubuntu/n8n && sudo docker compose logs -f"

# Or SSH in first, then:
cd /home/ubuntu/n8n
sudo docker compose logs -f
```

**Check container status:**
```bash
# From local machine
gcloud compute ssh n8n-server --project=<project-id> --zone=us-central1-a --command="sudo docker ps -a"

# Or SSH in first
sudo docker ps -a
```

**View specific container logs:**
```bash
# n8n logs
sudo docker logs n8n --tail 100 -f

# PostgreSQL logs
sudo docker logs n8n-postgres --tail 100 -f

# Cloudflare Tunnel logs
sudo docker logs cloudflare-tunnel --tail 100 -f
```

**View startup script logs:**
```bash
# From local machine
gcloud compute ssh n8n-server --project=<project-id> --zone=us-central1-a --command="sudo cat /var/log/startup-script.log"

# Or with tail (last 100 lines)
gcloud compute ssh n8n-server --project=<project-id> --zone=us-central1-a --command="sudo tail -100 /var/log/startup-script.log"
```

**Check Docker service status:**
```bash
sudo systemctl status docker
```

**Check system resources:**
```bash
# Memory usage
free -h

# Disk usage
df -h

# Running processes
htop  # or: top
```

### Container Management

**Restart containers:**
```bash
cd /home/ubuntu/n8n
sudo docker compose restart

# Or restart specific container
sudo docker restart n8n
sudo docker restart cloudflare-tunnel
```

**Stop containers:**
```bash
cd /home/ubuntu/n8n
sudo docker compose down
```

**Start containers:**
```bash
cd /home/ubuntu/n8n
sudo docker compose up -d
```

**Rebuild and restart (if you changed docker-compose.yml):**
```bash
cd /home/ubuntu/n8n
sudo docker compose down
sudo docker compose pull  # Get latest images
sudo docker compose up -d
```

**View container resource usage:**
```bash
sudo docker stats
```

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

## File Structure

```
.
├── main.tf                      # Main Terraform configuration
├── variables.tf                 # Variable definitions
├── terraform.tfvars             # Your values (NOT in git)
├── terraform.tfvars.example     # Template for others
├── docker-compose.yml.tpl       # Docker Compose template (customizable!)
├── setup-tunnel.sh              # Automated Cloudflare Tunnel setup
├── .gitignore                   # Excludes sensitive files
└── README.md                    # This file
```

## Security Notes

- **Never commit `terraform.tfvars`** - it contains sensitive credentials
- Change the default PostgreSQL password
- The `.gitignore` file excludes sensitive files
- Tunnel token is marked as sensitive in Terraform

## Customization

You can customize:
- **Region/Zone**: Change in `terraform.tfvars`
- **Machine Type**: Edit `main.tf` (note: e2-micro is free tier)
- **Docker Compose Configuration**: Edit `docker-compose.yml.tpl` to:
  - Change PostgreSQL version
  - Add/remove n8n environment variables
  - Add additional containers
  - Modify resource limits
- **n8n Environment Variables**: See [n8n documentation](https://docs.n8n.io/hosting/configuration/environment-variables/) for all options

## Troubleshooting

### Containers not starting

Check startup script logs:
```bash
gcloud compute ssh n8n-server --project=<project-id> --zone=us-central1-a --command="sudo cat /var/log/startup-script.log"
```

### 502 Bad Gateway

- Wait 60 seconds for n8n to fully start
- Check tunnel is HEALTHY in Cloudflare dashboard
- Verify tunnel routing is configured correctly

### Docker not installed

The startup script installs Docker automatically. If it fails, check the logs above.

## License

MIT License - feel free to use and modify!

## Contributing

Pull requests welcome! Please ensure sensitive data is not committed.
