# Deployment Readiness Checklist

## 📋 Pre-Deployment Checklist

### Before Pushing to Git

- [ ] Review all sensitive files are in `.gitignore`
- [ ] Remove any hardcoded passwords or tokens
- [ ] Verify `config.env` files are not tracked
- [ ] Check `terraform.tfvars` is not tracked
- [ ] Ensure `.env` files are excluded

### For Local Deployment

- [ ] Docker Desktop installed and running
- [ ] Docker Compose available
- [ ] Scripts are executable (`chmod +x` applied)
- [ ] Port 5678 is available

### For Local with Tunnel

- [ ] All local deployment prerequisites met
- [ ] Cloudflare account created
- [ ] Domain added to Cloudflare
- [ ] cloudflared CLI installed
- [ ] Tunnel token obtained
- [ ] `config.env` created from example in `deployments/local-with-tunnel/`

### For GCP VM Deployment

- [ ] GCP account created
- [ ] Billing enabled on GCP account
- [ ] Billing Account ID obtained
- [ ] gcloud CLI installed
- [ ] Terraform installed
- [ ] Authenticated with `gcloud auth login`
- [ ] `terraform.tfvars` created from example

### For GCP VM with Tunnel

- [ ] All GCP VM prerequisites met
- [ ] All tunnel prerequisites met
- [ ] Cloudflared CLI installed locally
- [ ] Domain DNS managed by Cloudflare

## 🚀 Quick Deployment Guides

### Fastest: Local Without Tunnel

```bash
./deploy.sh
# Choose option 1
# Access at http://localhost:5678
```

**Time to deploy:** ~2 minutes

### Local with Tunnel Setup

```bash
# 1. Copy config
cp deployments/local-with-tunnel/config.env.example deployments/local-with-tunnel/config.env

# 2. Setup tunnel (in Cloudflare dashboard or via CLI)
# Get tunnel token from: https://one.dash.cloudflare.com/

# 3. Edit config.env and add:
#    - TUNNEL_TOKEN
#    - N8N_DOMAIN

# 4. Deploy
./deploy.sh
# Choose option 2
```

**Time to deploy:** ~5-10 minutes (first time with tunnel setup)

### GCP VM with Automated Tunnel Setup

```bash
# 1. Setup GCP config
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
# Edit and add billing_account_id, domain, etc.

# 2. Authenticate
gcloud auth login
gcloud auth application-default login

# 3. Deploy (tunnel setup is automated!)
./deploy.sh
# Choose option 6
```

**Time to deploy:** ~10-15 minutes (first time)

## 📦 What Gets Created

### Local Deployments

- Docker containers: `n8n`, `n8n-postgres`, `cloudflare-tunnel` (if enabled)
- Docker volumes: `n8n_data`, `postgres_data`
- Docker network: `n8n-network`

### GCP VM Deployments

- GCP Project: `n8n-automation-XXXX`
- Compute Instance: `n8n-server` (e2-micro, 30GB)
- Firewall Rules: SSH access
- External IP: Ephemeral
- All containers from local deployment (on VM)

## 🔒 Security Reminders

### DO NOT Commit to Git:
- `*.env` files
- `config.env` files
- `terraform.tfvars`
- `terraform.tfstate*`
- Tunnel tokens
- Database passwords
- GCP credentials

### DO Commit to Git:
- `*.example` files
- Scripts
- Documentation
- `docker-compose.yml` files
- Terraform configuration files
- `.gitignore`

## 📝 Post-Deployment Steps

### After Local Deployment
1. Access n8n at http://localhost:5678
2. Create your first user account
3. Set up workflows
4. Configure webhooks if needed

### After Cloud Deployment
1. Access n8n at your configured domain
2. Verify HTTPS is working
3. Create your first user account
4. Test webhooks
5. Set up backups
6. Monitor GCP billing

## 🔍 Verification Commands

### Check Local Deployment
```bash
docker ps | grep n8n
curl http://localhost:5678
```

### Check Tunnel Status
```bash
cd terraform
./check_tunnel.sh
```

### Check GCP Deployment
```bash
cd terraform
terraform output
gcloud compute instances list --project=$(terraform output -raw project_id)
```

## 🎯 Common First-Time Issues

### Issue: Scripts not executable
```bash
chmod +x deploy.sh scripts/*.sh
```

### Issue: Docker not running
- Start Docker Desktop
- Wait for it to fully start
- Check with: `docker info`

### Issue: Port 5678 in use
```bash
# Find what's using the port
lsof -i :5678
# Kill the process or change port in docker-compose.yml
```

### Issue: Terraform state locked
```bash
cd terraform
terraform force-unlock LOCK_ID
```

## 📊 Resource Usage

### Local Deployment
- RAM: ~500MB (n8n) + ~100MB (postgres)
- Disk: ~2GB for images + data
- CPU: Minimal when idle

### GCP Free Tier Limits
- VM: e2-micro (shared CPU, 1GB RAM)
- Storage: 30GB standard persistent disk
- Egress: 1GB/month to most destinations
- Always free if within limits

## 🎓 Learning Path

### New to Docker?
1. Start with local deployment (option 1)
2. Learn Docker basics
3. Try local with tunnel (option 2)
4. Move to cloud (option 6)

### Familiar with Docker, New to Cloud?
1. Try local with tunnel (option 2)
2. Learn Terraform basics
3. Deploy to GCP (option 6)

### Production Ready?
- Use option 6 (GCP VM with tunnel)
- Set strong passwords
- Enable backups
- Monitor costs
- Set up alerts

## ✅ Ready to Push to Git

Before pushing:
```bash
# Verify no sensitive files will be committed
git status

# Check what will be ignored
git status --ignored

# Ensure these are NOT staged:
# - deployments/*/config.env
# - terraform/terraform.tfvars
# - terraform/.terraform/
# - terraform/*.tfstate*

# Safe to commit:
git add .
git commit -m "Initial n8n deployment suite"
git push
```

## 🎉 You're Ready!

Your n8n deployment suite is now:
- ✅ Structured for multiple deployment types
- ✅ Secured with proper gitignore
- ✅ Documented with comprehensive README
- ✅ Scripted for easy deployment
- ✅ Ready for team collaboration
- ✅ Production-ready with tunnel support

Choose your deployment option and go automate! 🚀
