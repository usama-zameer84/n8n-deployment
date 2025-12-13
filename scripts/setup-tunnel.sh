#!/bin/bash

# Cloudflare Tunnel Setup Script for Zero Trust
# This script helps you create a Cloudflare Tunnel and configure it for n8n
# Compatible with Cloudflare Zero Trust (formerly Argo Tunnel)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}Cloudflare Zero Trust Tunnel Setup for n8n${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""
echo -e "${CYAN}This script will:${NC}"
echo "  1. Authenticate with Cloudflare"
echo "  2. Create a new tunnel (or use existing)"
echo "  3. Configure DNS routing"
echo "  4. Generate tunnel token"
echo "  5. Configure for Docker deployment"
echo ""

# Check if cloudflared is installed
if ! command -v cloudflared &> /dev/null; then
    echo -e "${RED}Error: cloudflared is not installed${NC}"
    echo ""
    echo "Please install cloudflared first:"
    echo ""
    echo "macOS:"
    echo "  brew install cloudflared"
    echo ""
    echo "Linux:"
    echo "  wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb"
    echo "  sudo dpkg -i cloudflared-linux-amd64.deb"
    echo ""
    echo "Windows:"
    echo "  Download from: https://github.com/cloudflare/cloudflared/releases"
    echo ""
    exit 1
fi

echo -e "${GREEN}✓ cloudflared is installed${NC}"
echo ""

# Prompt for domain
echo -e "${YELLOW}Step 1: Domain Configuration${NC}"
read -p "Enter your full domain for n8n (e.g., n8n.example.com): " DOMAIN

if [ -z "$DOMAIN" ]; then
    echo -e "${RED}Error: Domain cannot be empty${NC}"
    exit 1
fi

# Extract subdomain and root domain
SUBDOMAIN=$(echo "$DOMAIN" | cut -d'.' -f1)
ROOT_DOMAIN=$(echo "$DOMAIN" | cut -d'.' -f2-)

echo -e "${GREEN}✓ Domain: $DOMAIN${NC}"
echo -e "  Subdomain: $SUBDOMAIN"
echo -e "  Root domain: $ROOT_DOMAIN"
echo ""

# Prompt for tunnel name
echo -e "${YELLOW}Step 2: Tunnel Name${NC}"
read -p "Enter a name for your tunnel (default: n8n-tunnel): " TUNNEL_NAME
TUNNEL_NAME=${TUNNEL_NAME:-n8n-tunnel}

echo -e "${GREEN}✓ Tunnel name: $TUNNEL_NAME${NC}"
echo ""

# Login to Cloudflare
echo -e "${YELLOW}Step 3: Cloudflare Authentication${NC}"
echo "Opening browser for Cloudflare authentication..."
echo ""

cloudflared tunnel login

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to authenticate with Cloudflare${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Successfully authenticated${NC}"
echo ""

# Check if tunnel already exists
echo -e "${YELLOW}Step 4: Creating/Verifying Tunnel${NC}"
echo "Checking if tunnel '$TUNNEL_NAME' already exists..."
echo ""

EXISTING_TUNNEL=$(cloudflared tunnel list 2>/dev/null | grep "$TUNNEL_NAME" | head -n1 || true)

if [ -n "$EXISTING_TUNNEL" ]; then
    echo -e "${CYAN}Found existing tunnel: $TUNNEL_NAME${NC}"
    TUNNEL_ID=$(echo "$EXISTING_TUNNEL" | awk '{print $1}')
    echo -e "${GREEN}✓ Using existing tunnel ID: $TUNNEL_ID${NC}"
    echo ""
    
    read -p "Do you want to recreate this tunnel? (y/N): " RECREATE
    if [[ $RECREATE =~ ^[Yy]$ ]]; then
        echo "Deleting existing tunnel..."
        cloudflared tunnel delete "$TUNNEL_NAME" -f || true
        echo "Creating new tunnel..."
        cloudflared tunnel create "$TUNNEL_NAME"
        TUNNEL_ID=$(cloudflared tunnel list | grep "$TUNNEL_NAME" | awk '{print $1}')
        echo -e "${GREEN}✓ Tunnel recreated successfully${NC}"
    fi
else
    echo "Creating new tunnel: $TUNNEL_NAME..."
    cloudflared tunnel create "$TUNNEL_NAME"
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error: Failed to create tunnel${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ Tunnel created successfully${NC}"
    TUNNEL_ID=$(cloudflared tunnel list | grep "$TUNNEL_NAME" | awk '{print $1}')
fi

echo ""

if [ -z "$TUNNEL_ID" ]; then
    echo -e "${RED}Error: Could not find tunnel ID${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Tunnel ID: $TUNNEL_ID${NC}"
echo ""

# Configure DNS routing
echo -e "${YELLOW}Step 5: Configuring DNS Routing${NC}"
echo "Setting up DNS record for $DOMAIN..."
echo ""

# First, check if route already exists
EXISTING_ROUTE=$(cloudflared tunnel route dns list 2>/dev/null | grep "$DOMAIN" || true)

if [ -n "$EXISTING_ROUTE" ]; then
    echo -e "${CYAN}DNS route already exists for $DOMAIN${NC}"
    echo -e "${GREEN}✓ DNS route verified${NC}"
else
    cloudflared tunnel route dns "$TUNNEL_ID" "$DOMAIN"
    
    if [ $? -ne 0 ]; then
        echo -e "${YELLOW}Warning: Failed to configure DNS automatically${NC}"
        echo -e "${YELLOW}You may need to add the DNS record manually in Cloudflare Zero Trust dashboard${NC}"
        echo ""
        echo "Manual steps:"
        echo "  1. Go to https://one.dash.cloudflare.com/"
        echo "  2. Navigate to Networks > Tunnels"
        echo "  3. Click on your tunnel: $TUNNEL_NAME"
        echo "  4. Go to Public Hostname tab"
        echo "  5. Add hostname: $DOMAIN -> http://n8n:5678"
        echo ""
    else
        echo -e "${GREEN}✓ DNS configured successfully${NC}"
    fi
fi
echo ""

# Create config file
echo -e "${YELLOW}Step 6: Creating Tunnel Configuration${NC}"
echo "Creating configuration file..."
echo ""

# Get the credentials file location
CRED_FILE="$HOME/.cloudflared/${TUNNEL_ID}.json"

if [ ! -f "$CRED_FILE" ]; then
    echo -e "${RED}Error: Credentials file not found at $CRED_FILE${NC}"
    exit 1
fi

# Create config.yml
CONFIG_FILE="$HOME/.cloudflared/config.yml"
cat > "$CONFIG_FILE" <<EOF
tunnel: $TUNNEL_ID
credentials-file: $CRED_FILE

ingress:
  - hostname: $DOMAIN
    service: http://n8n:5678
  - service: http_status:404
EOF

echo -e "${GREEN}✓ Configuration file created at $CONFIG_FILE${NC}"
echo ""

# Generate tunnel token
echo -e "${YELLOW}Step 7: Generating Tunnel Token${NC}"
echo "Generating token for Docker deployment..."
echo ""

TUNNEL_TOKEN=$(cloudflared tunnel token "$TUNNEL_NAME")

if [ -z "$TUNNEL_TOKEN" ]; then
    echo -e "${RED}Error: Failed to generate tunnel token${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Tunnel token generated${NC}"
echo ""

# Update terraform.tfvars
echo -e "${YELLOW}Step 8: Updating terraform.tfvars${NC}"
TFVARS_FILE="terraform.tfvars"

if [ -f "$TFVARS_FILE" ]; then
    # Check if tunnel_token already exists
    if grep -q "^tunnel_token" "$TFVARS_FILE"; then
        # Update existing token
        sed -i.bak "s|^tunnel_token.*|tunnel_token       = \"$TUNNEL_TOKEN\"|" "$TFVARS_FILE"
        echo -e "${GREEN}✓ Updated tunnel_token in $TFVARS_FILE${NC}"
    else
        # Append token
        echo "tunnel_token       = \"$TUNNEL_TOKEN\"" >> "$TFVARS_FILE"
        echo -e "${GREEN}✓ Added tunnel_token to $TFVARS_FILE${NC}"
    fi
    
    # Check if domain already exists
    if grep -q "^domain" "$TFVARS_FILE"; then
        # Update existing domain
        sed -i.bak "s|^domain.*|domain             = \"$DOMAIN\"|" "$TFVARS_FILE"
        echo -e "${GREEN}✓ Updated domain in $TFVARS_FILE${NC}"
    else
        # Append domain
        echo "domain             = \"$DOMAIN\"" >> "$TFVARS_FILE"
        echo -e "${GREEN}✓ Added domain to $TFVARS_FILE${NC}"
    fi
    
    rm -f "${TFVARS_FILE}.bak"
else
    echo -e "${YELLOW}Warning: $TFVARS_FILE not found. Creating from example...${NC}"
    if [ -f "terraform.tfvars.example" ]; then
        cp terraform.tfvars.example "$TFVARS_FILE"
        sed -i.bak "s|YOUR-CLOUDFLARE-TUNNEL-TOKEN|$TUNNEL_TOKEN|" "$TFVARS_FILE"
        sed -i.bak "s|n8n.example.com|$DOMAIN|" "$TFVARS_FILE"
        rm -f "${TFVARS_FILE}.bak"
        echo -e "${GREEN}✓ Created $TFVARS_FILE from example${NC}"
        echo -e "${YELLOW}Please edit $TFVARS_FILE and fill in remaining values${NC}"
    else
        echo -e "${RED}Error: terraform.tfvars.example not found${NC}"
    fi
fi
echo ""

# Summary
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}✓ Setup Complete!${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""
echo -e "${GREEN}Tunnel Details:${NC}"
echo "  Name:   $TUNNEL_NAME"
echo "  ID:     $TUNNEL_ID"
echo "  Domain: $DOMAIN"
echo "  Status: Ready for deployment"
echo ""
echo -e "${CYAN}Cloudflare Zero Trust Dashboard:${NC}"
echo "  View your tunnel at: ${CYAN}https://one.dash.cloudflare.com/${NC}"
echo "  Navigate to: Networks > Tunnels"
echo ""
echo -e "${GREEN}Configuration Files:${NC}"
echo "  Config:      $CONFIG_FILE"
echo "  Credentials: $CRED_FILE"
echo "  Terraform:   terraform.tfvars (updated)"
echo ""
echo -e "${YELLOW}Important Notes:${NC}"
echo "  ✓ Tunnel token saved to terraform.tfvars"
echo "  ✓ This file is excluded from git (.gitignore)"
echo "  ✓ Tunnel will be ACTIVE once deployed with Docker"
echo ""
echo -e "${GREEN}Next Steps:${NC}"
echo ""
echo "  ${CYAN}For Local Deployment:${NC}"
echo "    ./scripts/deploy-local-with-tunnel.sh"
echo ""
echo "  ${CYAN}For GCP VM Deployment:${NC}"
echo "    1. Complete terraform.tfvars with:"
echo "       - billing_account_id (required)"
echo "       - postgres_password (recommended)"
echo ""
echo "    2. Deploy:"
echo "       ./scripts/deploy-vm-with-tunnel.sh"
echo ""
echo -e "${BLUE}To test your tunnel locally right now:${NC}"
echo "  cloudflared tunnel run $TUNNEL_NAME"
echo ""
echo -e "${CYAN}The tunnel will appear as ACTIVE in Cloudflare dashboard once${NC}"
echo -e "${CYAN}the Docker container with cloudflared is running.${NC}"
echo ""
