# Setup Summary

This document provides a quick overview of what the `setup-tunnel.sh` script does.

## What the Script Does

### 1. **Checks Prerequisites**
- Verifies `cloudflared` is installed
- Shows installation instructions if missing

### 2. **Collects Information**
- Prompts for your domain (e.g., `n8n.example.com`)
- Prompts for tunnel name (default: `n8n-tunnel`)

### 3. **Authenticates with Cloudflare**
- Opens browser for Cloudflare login
- Stores credentials locally

### 4. **Creates the Tunnel**
- Creates a new Cloudflare Tunnel with your specified name
- Generates tunnel ID and credentials

### 5. **Configures DNS**
- Automatically adds DNS record in Cloudflare
- Points your domain to the tunnel

### 6. **Generates Configuration**
- Creates `~/.cloudflared/config.yml` with tunnel settings
- Configures routing: `domain → http://n8n:5678`

### 7. **Generates Tunnel Token**
- Creates a tunnel token for Docker deployment
- This token is used by the cloudflared container

### 8. **Updates terraform.tfvars**
- Automatically adds/updates `tunnel_token`
- Automatically adds/updates `domain`
- Preserves other existing values

## Files Created/Modified

```
~/.cloudflared/
├── cert.pem                    # Cloudflare credentials
├── <tunnel-id>.json           # Tunnel credentials
└── config.yml                 # Tunnel configuration

terraform/
└── terraform.tfvars           # Updated with token & domain
```

## What You Still Need to Do

After running the script, you need to:

1. **Add GCP Billing Account ID** to `terraform.tfvars`
2. **Change the PostgreSQL password** in `terraform.tfvars`
3. **Run Terraform**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Manual Alternative

If you prefer to do it manually or the script doesn't work:

```bash
# 1. Login
cloudflared tunnel login

# 2. Create tunnel
cloudflared tunnel create n8n-tunnel

# 3. Configure DNS
cloudflared tunnel route dns n8n-tunnel n8n.yourdomain.com

# 4. Get token
cloudflared tunnel token n8n-tunnel

# 5. Manually add to terraform.tfvars:
#    tunnel_token = "YOUR_TOKEN_HERE"
#    domain = "n8n.yourdomain.com"
```

## Testing Your Tunnel

To test the tunnel locally before deploying to GCP:

```bash
# Start a local test server
python3 -m http.server 5678

# In another terminal, run the tunnel
cloudflared tunnel run n8n-tunnel

# Visit your domain in a browser
# It should show the Python server page
```

## Troubleshooting

### "cloudflared: command not found"
Install cloudflared - see [INSTALL_CLOUDFLARED.md](INSTALL_CLOUDFLARED.md)

### "Failed to authenticate with Cloudflare"
- Ensure you have a Cloudflare account
- Check that your browser opens for authentication
- Try `cloudflared tunnel login` manually

### "Failed to configure DNS"
- Ensure your domain is added to Cloudflare
- Verify Cloudflare is managing your domain's DNS
- You can manually add the DNS record in Cloudflare dashboard

### Script updates wrong values
- Check `terraform.tfvars` after running
- You can manually edit the file
- Format: `variable = "value"`

## Security Notes

- The tunnel token is sensitive - keep it secret
- The script adds it to `terraform.tfvars` which is `.gitignore`d
- Never commit `terraform.tfvars` to git
- Credentials are stored in `~/.cloudflared/` - keep this directory secure

## More Information

- [Cloudflare Tunnel Documentation](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/)
- [cloudflared CLI Reference](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/downloads/)
