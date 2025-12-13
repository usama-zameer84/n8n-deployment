# Cloudflare Zero Trust Tunnel Troubleshooting

This guide helps you resolve common Cloudflare Tunnel issues, especially when migrating to Zero Trust.

## Table of Contents

- [Tunnel Shows as INACTIVE](#tunnel-shows-as-inactive)
- [Zero Trust Migration](#zero-trust-migration)
- [Common Issues](#common-issues)
- [Diagnostic Commands](#diagnostic-commands)

## Tunnel Shows as INACTIVE

### Why This Happens

Cloudflare Tunnels appear as **INACTIVE** in the dashboard until the `cloudflared` connector is actively running. This is **normal behavior**.

### Solution: Activate Your Tunnel

#### Quick Fix

```bash
# Option 1: Use the activation script
./scripts/activate-tunnel.sh

# Option 2: Deploy with Docker (makes tunnel ACTIVE)
./scripts/deploy-local-with-tunnel.sh    # For local
./scripts/deploy-vm-with-tunnel.sh       # For GCP VM

# Option 3: Check status first
./scripts/check_tunnel.sh
```

#### Step-by-Step Activation

1. **Verify tunnel exists:**
   ```bash
   cloudflared tunnel list
   ```

2. **Activate the tunnel:**
   ```bash
   ./scripts/activate-tunnel.sh
   ```
   This script will:
   - Find your existing tunnel
   - Generate a new token
   - Update configuration files
   - Prepare for deployment

3. **Deploy to make it ACTIVE:**
   ```bash
   ./scripts/deploy-local-with-tunnel.sh
   ```

4. **Verify it's ACTIVE:**
   - Visit: https://one.dash.cloudflare.com/
   - Navigate to: **Networks → Tunnels**
   - Your tunnel should now show as **ACTIVE** (green status)

## Zero Trust Migration

### What Changed

Cloudflare migrated from "Argo Tunnels" to "Zero Trust Tunnels". Old tunnels need to be:
- Registered in the Zero Trust dashboard
- Running with updated `cloudflared` version
- Using proper token authentication

### Migrate Existing Tunnel

If you have an old tunnel that's not in Zero Trust:

1. **List your current tunnels:**
   ```bash
   cloudflared tunnel list
   ```

2. **Option A: Use existing tunnel (Recommended)**
   ```bash
   ./scripts/activate-tunnel.sh
   ```
   - Enter your tunnel name (e.g., `n8n-tunnel`)
   - Enter your domain
   - Script will configure everything

3. **Option B: Create new tunnel**
   ```bash
   # Delete old tunnel
   cloudflared tunnel delete <old-tunnel-name> -f
   
   # Create new Zero Trust tunnel
   ./scripts/setup-tunnel.sh
   ```

### Update cloudflared CLI

Make sure you have the latest version:

```bash
# macOS
brew upgrade cloudflared

# Linux
wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared-linux-amd64.deb

# Check version
cloudflared --version
```

## Common Issues

### Issue 1: "Tunnel not found in dashboard"

**Symptom:** Tunnel exists locally but not visible in Zero Trust dashboard

**Solution:**
```bash
# Re-authenticate with Cloudflare
cloudflared tunnel login

# List tunnels to verify
cloudflared tunnel list

# If tunnel exists, activate it
./scripts/activate-tunnel.sh
```

### Issue 2: "DNS routing not working"

**Symptom:** Tunnel is ACTIVE but domain doesn't resolve

**Solution:**
1. Check DNS routes:
   ```bash
   cloudflared tunnel route dns list
   ```

2. Add route manually if missing:
   ```bash
   cloudflared tunnel route dns <tunnel-id> <your-domain.com>
   ```

3. Or configure in Zero Trust dashboard:
   - Go to: https://one.dash.cloudflare.com/
   - Navigate to: Networks → Tunnels
   - Click your tunnel → Public Hostname
   - Add: `your-domain.com` → `http://n8n:5678`

### Issue 3: "Cannot connect to n8n through tunnel"

**Symptom:** Tunnel is ACTIVE but can't access n8n

**Solution:**
1. Check Docker containers are running:
   ```bash
   docker ps
   ```

2. Verify n8n is accessible from tunnel:
   ```bash
   docker exec cloudflare-tunnel wget -qO- http://n8n:5678
   ```

3. Check Docker network:
   ```bash
   docker network inspect n8n-network
   ```
   Both `n8n` and `cloudflare-tunnel` should be on this network.

4. Check tunnel logs:
   ```bash
   docker logs cloudflare-tunnel --tail 50
   ```

### Issue 4: "Credentials file not found"

**Symptom:** Error: `/home/user/.cloudflared/<tunnel-id>.json` not found

**Solution:**

This happens when:
- Tunnel was created on different machine
- Credentials were deleted

**Fix:**
```bash
# Option 1: Delete and recreate tunnel
cloudflared tunnel delete <tunnel-name> -f
./scripts/setup-tunnel.sh

# Option 2: If you have the credentials, restore them
mkdir -p ~/.cloudflared
cp <your-backup-credentials.json> ~/.cloudflared/<tunnel-id>.json
```

### Issue 5: "Multiple tunnels with same name"

**Symptom:** Confusion about which tunnel is active

**Solution:**
```bash
# List all tunnels
cloudflared tunnel list

# Delete unused tunnels
cloudflared tunnel delete <tunnel-name> -f

# Keep only one tunnel per domain
./scripts/activate-tunnel.sh
```

## Diagnostic Commands

### Check Tunnel Status

```bash
# Full diagnostic
./scripts/check_tunnel.sh

# List all tunnels
cloudflared tunnel list

# Show tunnel info
cloudflared tunnel info <tunnel-name>

# Check routes
cloudflared tunnel route dns list
```

### Check Docker Status

```bash
# List containers
docker ps -a

# Check tunnel logs
docker logs cloudflare-tunnel

# Check n8n logs
docker logs n8n

# Test connectivity
docker exec cloudflare-tunnel wget -qO- http://n8n:5678
```

### Check Configuration

```bash
# View tunnel config
cat ~/.cloudflared/config.yml

# Check credentials exist
ls -la ~/.cloudflared/

# Verify environment variables
cat deployments/local-with-tunnel/config.env | grep TUNNEL
```

## Verification Checklist

After fixing issues, verify:

- [ ] `cloudflared tunnel list` shows your tunnel
- [ ] Tunnel shows as **ACTIVE** in https://one.dash.cloudflare.com/
- [ ] DNS route exists: `cloudflared tunnel route dns list`
- [ ] Docker containers running: `docker ps`
- [ ] Tunnel can reach n8n: `docker exec cloudflare-tunnel wget -qO- http://n8n:5678`
- [ ] Your domain resolves: `nslookup <your-domain.com>`
- [ ] Can access n8n at: `https://<your-domain.com>`

## Quick Reference

### Tunnel Lifecycle

```bash
# 1. Create tunnel (one time)
./scripts/setup-tunnel.sh

# 2. Activate tunnel (if inactive)
./scripts/activate-tunnel.sh

# 3. Deploy (makes tunnel ACTIVE)
./scripts/deploy-local-with-tunnel.sh

# 4. Check status
./scripts/check_tunnel.sh

# 5. View logs
docker logs cloudflare-tunnel -f
```

### Important URLs

- **Zero Trust Dashboard:** https://one.dash.cloudflare.com/
- **Tunnels:** https://one.dash.cloudflare.com/ → Networks → Tunnels
- **DNS:** Your Cloudflare domain dashboard
- **n8n Access:** https://your-domain.com (after deployment)

## Still Having Issues?

1. **Run full diagnostic:**
   ```bash
   ./scripts/check_tunnel.sh
   ```

2. **Check the logs:**
   ```bash
   docker logs cloudflare-tunnel --tail 100
   ```

3. **Try recreating tunnel:**
   ```bash
   cloudflared tunnel delete <tunnel-name> -f
   ./scripts/setup-tunnel.sh
   ```

4. **Verify cloudflared version:**
   ```bash
   cloudflared --version
   # Should be 2024.x.x or newer
   ```

5. **Re-authenticate:**
   ```bash
   cloudflared tunnel login
   ```

## Getting Help

If you're still stuck:

1. Run diagnostic: `./scripts/check_tunnel.sh`
2. Capture the output
3. Check tunnel logs: `docker logs cloudflare-tunnel`
4. Open an issue with:
   - Diagnostic output
   - Tunnel logs
   - Steps you've tried

---

**Remember:** A tunnel showing as INACTIVE is normal until you deploy and run the cloudflared connector!
