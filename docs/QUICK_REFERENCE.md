# Quick Reference Guide

## 🚀 One-Command Deployments

### Local (No Tunnel)
```bash
./scripts/deploy-local.sh
# Access: http://localhost:5678
```

### Local with Tunnel
```bash
# First time: Configure tunnel
cp deployments/local-with-tunnel/config.env.example deployments/local-with-tunnel/config.env
# Edit config.env with your TUNNEL_TOKEN and N8N_DOMAIN

# Deploy
./scripts/deploy-local-with-tunnel.sh
# Access: https://your-domain.com
```

### GCP VM with Tunnel (Full Automation)
```bash
# First time: Configure terraform
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
# Edit terraform.tfvars with your billing_account_id and domain

# Deploy (tunnel setup is automatic!)
./scripts/deploy-vm-with-tunnel.sh
# Access: https://your-domain.com
```

## 📱 Interactive Menu

```bash
./deploy.sh
```

Choose from menu:
- `1` - Deploy locally (no tunnel)
- `2` - Deploy locally with tunnel
- `3` - Stop local
- `4` - Stop local with tunnel
- `5` - Deploy to GCP VM (no tunnel)
- `6` - Deploy to GCP VM with tunnel ⭐ **Recommended**
- `7` - Destroy GCP VM
- `8` - View logs (local)
- `9` - View logs (local + tunnel)
- `10` - Setup Cloudflare tunnel only
- `11` - Activate existing tunnel (fix INACTIVE status)
- `12` - Check tunnel status

## 🔧 Common Commands

### Stop Running Deployments
```bash
./scripts/stop-local.sh              # Stop local
./scripts/stop-local-tunnel.sh       # Stop local with tunnel
./scripts/destroy-vm.sh              # Destroy GCP resources
```

### View Logs
```bash
# Local
cd deployments/local && docker-compose logs -f

# Local with tunnel
cd deployments/local-with-tunnel && docker-compose logs -f
```

### Update n8n
```bash
# Local
cd deployments/local
docker-compose pull
docker-compose up -d

# GCP VM - SSH first, then same commands
```

### Check Status
```bash
# Docker containers
docker ps | grep n8n

# Tunnel status (if using tunnel)
./scripts/check_tunnel.sh
```

### Tunnel Management
```bash
# Setup new tunnel
./scripts/setup-tunnel.sh

# Activate existing tunnel (fix INACTIVE status)
./scripts/activate-tunnel.sh

# Check tunnel status
./scripts/check_tunnel.sh

# List all tunnels
cloudflared tunnel list

# View tunnel logs
docker logs cloudflare-tunnel -f
```

## 📋 File Locations

### Configuration Files
- Local: `deployments/local/config.env`
- Local + Tunnel: `deployments/local-with-tunnel/config.env`
- GCP/Terraform: `terraform/terraform.tfvars`

### Docker Compose Files
- Local: `deployments/local/docker-compose.yml`
- Local + Tunnel: `deployments/local-with-tunnel/docker-compose.yml`
- GCP Template: `terraform/docker-compose.yml.tpl`

### Scripts
All in `scripts/` directory:
- `deploy-local.sh`
- `deploy-local-with-tunnel.sh`
- `deploy-vm.sh`
- `deploy-vm-with-tunnel.sh`
- `stop-local.sh`
- `stop-local-tunnel.sh`
- `destroy-vm.sh`

## 🎯 Decision Matrix

| Need | Solution | Command |
|------|----------|---------|
| Quick local test | Local (no tunnel) | `./scripts/deploy-local.sh` |
| Remote access to local | Local with tunnel | `./scripts/deploy-local-with-tunnel.sh` |
| Cloud deployment | GCP VM with tunnel | `./scripts/deploy-vm-with-tunnel.sh` |
| Production | GCP VM with tunnel | `./scripts/deploy-vm-with-tunnel.sh` |

## 🔒 Security Checklist

Before git push:
- [ ] No `config.env` files committed
- [ ] No `terraform.tfvars` committed
- [ ] No `.env` files committed
- [ ] No tokens/passwords in code
- [ ] `.gitignore` includes sensitive files

## 📞 Quick Troubleshooting

| Problem | Solution |
|---------|----------|
| Scripts not executable | `chmod +x deploy.sh scripts/*.sh` |
| Docker not running | Start Docker Desktop |
| Port 5678 in use | `lsof -i :5678` then kill process |
| Tunnel shows INACTIVE | See [Tunnel Troubleshooting](TUNNEL_TROUBLESHOOTING.md) |
| Tunnel not connecting | Check token in config.env |
| GCP auth failed | `gcloud auth login` |

## 🎓 Recommended Learning Path

1. **Day 1**: Local deployment
   ```bash
   ./scripts/deploy-local.sh
   ```

2. **Day 2**: Explore n8n, create workflows

3. **Day 3**: Try tunnel locally
   ```bash
   ./scripts/deploy-local-with-tunnel.sh
   ```

4. **Day 4**: Deploy to cloud
   ```bash
   ./scripts/deploy-vm-with-tunnel.sh
   ```

## 💡 Pro Tips

1. **Use the interactive menu** for beginners
   ```bash
   ./deploy.sh
   ```

2. **Direct scripts** for automation/CI/CD
   ```bash
   ./scripts/deploy-vm-with-tunnel.sh
   ```

3. **Always backup** before updates
   ```bash
   docker run --rm -v n8n_data:/data -v $(pwd):/backup ubuntu tar czf /backup/n8n-backup.tar.gz /data
   ```

4. **Monitor GCP costs** at console.cloud.google.com/billing

5. **Use strong passwords** in production

## 🌟 Most Common Use Case

**For production deployment with HTTPS:**

```bash
# 1. Setup (one time)
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
# Edit: Add billing_account_id, domain, set strong password

# 2. Authenticate (one time)
gcloud auth login
gcloud auth application-default login

# 3. Deploy (automatic tunnel setup!)
./scripts/deploy-vm-with-tunnel.sh

# 4. Done! Access at https://your-domain.com
```

That's it! 🚀
