# Installing cloudflared

## macOS

```bash
brew install cloudflared
```

## Linux (Debian/Ubuntu)

```bash
# Download the package
wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb

# Install
sudo dpkg -i cloudflared-linux-amd64.deb

# Verify
cloudflared --version
```

## Linux (RHEL/CentOS)

```bash
# Add Cloudflare GPG key
sudo mkdir -p --mode=0755 /usr/share/keyrings
curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | sudo tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null

# Add repository
echo "deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/cloudflared.list

# Install
sudo yum install cloudflared
```

## Windows

1. Download from: https://github.com/cloudflare/cloudflared/releases
2. Choose `cloudflared-windows-amd64.exe`
3. Rename to `cloudflared.exe`
4. Add to PATH or run from download location

## Verify Installation

```bash
cloudflared --version
```

You should see output like: `cloudflared version 2024.x.x`

## Next Steps

Once installed, run:

```bash
./setup-tunnel.sh
```

This will guide you through creating and configuring your Cloudflare Tunnel.
