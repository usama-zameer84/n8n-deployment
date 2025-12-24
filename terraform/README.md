# Terraform Configuration for n8n on GCP

This directory contains Terraform configuration for deploying n8n on Google Cloud Platform's free tier.

## Overview

This Terraform configuration creates:
- New GCP Project with unique ID
- Compute Engine API enablement
- e2-micro VM instance (free tier eligible)
- Firewall rules for SSH access
- Docker Compose deployment on the VM
- Optional Cloudflare Tunnel integration

## Files

- `main.tf` - Main Terraform configuration
- `variables.tf` - Input variable definitions
- `terraform.tfvars.example` - Example configuration file
- `docker-compose.yml.tpl` - Template for VM's docker-compose.yml
- `.gitignore` - Git ignore rules for sensitive files

## Quick Start

### Prerequisites

1. **GCP Account** with billing enabled
2. **Terraform** installed (>= 1.0)
3. **gcloud CLI** installed and authenticated

### Configuration

1. Copy the example configuration:
```bash
cp terraform.tfvars.example terraform.tfvars
```

2. Edit `terraform.tfvars` and provide:
```hcl
billing_account_id = "YOUR-BILLING-ACCOUNT-ID"  # Required
project_name       = "n8n-automation"            # Optional
tunnel_token       = "your-tunnel-token"         # Required for tunnel
domain            = "n8n.example.com"            # Required for tunnel
timezone          = "UTC"                        # Optional
region            = "us-central1"                # Optional
zone              = "us-central1-a"              # Optional
```

### Get Your Billing Account ID

1. Go to: https://console.cloud.google.com/billing
2. Copy your Billing Account ID (format: `XXXXXX-XXXXXX-XXXXXX`)

### Deploy

#### Using Automated Script (Recommended)

```bash
# From project root
./scripts/deploy-vm-with-tunnel.sh
```

This script:
- ✅ Checks prerequisites
- ✅ Sets up Cloudflare Tunnel automatically
- ✅ Initializes Terraform
- ✅ Applies configuration
- ✅ Provides access information

#### Manual Deployment

```bash
# Authenticate with GCP
gcloud auth login
gcloud auth application-default login

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply

# View outputs
terraform output
```

## Deployment Options

### With Cloudflare Tunnel (Recommended)

Provides HTTPS access without exposing ports.

**Requirements:**
- Cloudflare account
- Domain managed by Cloudflare
- Tunnel token

**Setup:**
```bash
# Use automated script
../scripts/setup-tunnel.sh

# Or configure manually in Cloudflare dashboard
```

**Then deploy:**
```bash
../scripts/deploy-vm-with-tunnel.sh
```

### Without Tunnel

Basic deployment with public IP access.

**Deploy:**
```bash
../scripts/deploy-vm.sh
```

**Note:** You'll need to configure firewall rules manually to access n8n.

## Variables

### Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `billing_account_id` | GCP Billing Account ID | `XXXXXX-XXXXXX-XXXXXX` |

### Tunnel Variables (Required if using tunnel)

| Variable | Description | Example |
|----------|-------------|---------|
| `tunnel_token` | Cloudflare Tunnel token | `eyJh...` |
| `domain` | Your domain for n8n | `n8n.example.com` |

### Optional Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `project_name` | GCP project name prefix | `n8n-automation` |
| `timezone` | Timezone for n8n | `UTC` |
| `region` | GCP region | `us-central1` |
| `zone` | GCP zone | `us-central1-a` |

## Outputs

After successful deployment, Terraform provides:

| Output | Description |
|--------|-------------|
| `project_id` | Created GCP project ID |
| `vm_external_ip` | VM's public IP address |
| `domain` | n8n domain (if using tunnel) |
| `ssh_command` | Command to SSH into VM |

**View outputs:**
```bash
terraform output
```

## GCP Free Tier

This configuration uses GCP's Always Free tier:

- ✅ **e2-micro** VM (1 vCPU, 1GB RAM)
- ✅ **30GB** standard persistent disk
- ✅ **1GB** network egress per month
- ✅ **Available regions:** us-west1, us-central1, us-east1

**Important:**
- Stay within limits to avoid charges
- Monitor usage in GCP Console
- Resources outside these limits will incur charges

## Customization

### Modify VM Configuration

Edit `main.tf`:

```hcl
resource "google_compute_instance" "n8n_server" {
  machine_type = "e2-micro"  # Change to e2-small, e2-medium, etc.
  # ...
}
```

### Add Environment Variables to n8n

Edit `docker-compose.yml.tpl`:

```yaml
n8n:
  environment:
    # ... existing vars ...
    - YOUR_NEW_VAR=value
```

### Add New Services

Edit `docker-compose.yml.tpl`:

```yaml
services:
  # ... existing services ...
  
  redis:
    image: redis:7
    container_name: redis
    networks:
      - n8n-network
```

## Maintenance

### View VM Logs

```bash
# SSH into VM
gcloud compute ssh n8n-server --zone=us-central1-a --project=$(terraform output -raw project_id)

# View n8n logs
docker logs -f n8n

# View all logs
docker-compose logs -f
```

### Update n8n

```bash
# SSH into VM
gcloud compute ssh n8n-server --zone=us-central1-a --project=$(terraform output -raw project_id)

# Update
cd /home/$(whoami)
docker-compose pull
docker-compose up -d
```

### Backup Data

```bash
# SSH into VM
gcloud compute ssh n8n-server --zone=us-central1-a --project=$(terraform output -raw project_id)

# Backup volumes
docker run --rm -v n8n_data:/data -v $(pwd):/backup ubuntu tar czf /backup/n8n-backup.tar.gz /data

# Download backups
exit
gcloud compute scp n8n-server:~/n8n-backup.tar.gz . --zone=us-central1-a --project=YOUR-PROJECT-ID
```

## Destroy Infrastructure

**⚠️ WARNING:** This will permanently delete all resources and data!

```bash
# Using script
../scripts/destroy-vm.sh

# Or manually
terraform destroy
```

## Troubleshooting

### Terraform State Locked

```bash
# Force unlock (use with caution)
terraform force-unlock LOCK_ID
```

### VM Not Accessible

1. Check VM is running:
```bash
gcloud compute instances list --project=$(terraform output -raw project_id)
```

2. Check firewall rules:
```bash
gcloud compute firewall-rules list --project=$(terraform output -raw project_id)
```

3. View VM serial output:
```bash
gcloud compute instances get-serial-port-output n8n-server --zone=us-central1-a --project=$(terraform output -raw project_id)
```

### Docker Compose Not Running

```bash
# SSH into VM
gcloud compute ssh n8n-server --zone=us-central1-a --project=$(terraform output -raw project_id)

# Check Docker status
sudo systemctl status docker

# Check containers
docker ps -a

# Restart Docker Compose
docker-compose down
docker-compose up -d
```

### Tunnel Not Connecting

```bash
# Check tunnel status from local machine
../scripts/check_tunnel.sh

# Or check on VM
docker logs cloudflare-tunnel
```

## Security Considerations

1. **Restrict SSH access** - Modify firewall rules in `main.tf`
2. **Keep secrets secure** - Never commit `terraform.tfvars`
4. **Use tunnel** - Recommended over direct IP access
5. **Enable 2FA** - On GCP and Cloudflare accounts
6. **Monitor costs** - Check GCP billing regularly

## Cost Management

**Free Tier Limits:**
- e2-micro VM: Free
- 30GB standard disk: Free
- 1GB egress/month: Free
- Additional egress: ~$0.12/GB

**Tips to avoid charges:**
- Stay within free tier limits
- Destroy resources when not needed
- Set up billing alerts in GCP Console
- Monitor usage regularly

## Support

- **General Issues:** [GitHub Issues](https://github.com/yourusername/n8n-deployment-suite/issues)
- **Documentation:** [Main README](../README.md)
- **Deployment Guide:** [Deployment Guide](../docs/DEPLOYMENT_GUIDE.md)

## Additional Resources

- [GCP Free Tier](https://cloud.google.com/free)
- [Terraform GCP Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [n8n Documentation](https://docs.n8n.io/)
- [Cloudflare Tunnel Docs](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/)

---

For automated deployment, use the scripts in `../scripts/`:
- `deploy-vm.sh` - Deploy without tunnel
- `deploy-vm-with-tunnel.sh` - Deploy with tunnel (recommended)
- `destroy-vm.sh` - Destroy all resources
