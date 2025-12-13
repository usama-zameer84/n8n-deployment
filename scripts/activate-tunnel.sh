#!/bin/bash

# Cloudflare Zero Trust Tunnel Activation Script
# This script helps activate an existing inactive tunnel

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}Cloudflare Tunnel Activation${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Check if cloudflared is installed
if ! command -v cloudflared &> /dev/null; then
    echo -e "${RED}Error: cloudflared is not installed${NC}"
    echo ""
    echo "Install cloudflared first:"
    echo "  macOS: brew install cloudflared"
    echo "  Linux: See docs/INSTALL_CLOUDFLARED.md"
    exit 1
fi

echo -e "${GREEN}✓ cloudflared CLI found${NC}"
echo ""

# List existing tunnels
echo -e "${CYAN}=== Your Existing Tunnels ===${NC}"
cloudflared tunnel list 2>/dev/null

echo ""
echo -e "${YELLOW}Note: Tunnels show as INACTIVE until the cloudflared connector is running${NC}"
echo ""

# Prompt for tunnel name
read -p "Enter the tunnel name to activate (default: n8n-tunnel): " TUNNEL_NAME
TUNNEL_NAME=${TUNNEL_NAME:-n8n-tunnel}

# Get tunnel details
TUNNEL_INFO=$(cloudflared tunnel list 2>/dev/null | grep "$TUNNEL_NAME" | head -n1)

if [ -z "$TUNNEL_INFO" ]; then
    echo -e "${RED}Error: Tunnel '$TUNNEL_NAME' not found${NC}"
    echo ""
    echo "Available options:"
    echo "  1. Create new tunnel: ./scripts/setup-tunnel.sh"
    echo "  2. Check tunnel name spelling"
    exit 1
fi

TUNNEL_ID=$(echo "$TUNNEL_INFO" | awk '{print $1}')
echo -e "${GREEN}✓ Found tunnel: $TUNNEL_NAME${NC}"
echo -e "  Tunnel ID: ${CYAN}$TUNNEL_ID${NC}"
echo ""

# Check if credentials exist
CRED_FILE="$HOME/.cloudflared/${TUNNEL_ID}.json"
if [ ! -f "$CRED_FILE" ]; then
    echo -e "${RED}Error: Credentials file not found${NC}"
    echo "  Expected: $CRED_FILE"
    echo ""
    echo "This tunnel may have been created on another machine."
    echo "You'll need to:"
    echo "  1. Delete this tunnel: cloudflared tunnel delete $TUNNEL_NAME"
    echo "  2. Create a new one: ./scripts/setup-tunnel.sh"
    exit 1
fi

echo -e "${GREEN}✓ Credentials file found${NC}"
echo ""

# Prompt for domain
read -p "Enter your domain for n8n (e.g., n8n.example.com): " DOMAIN

if [ -z "$DOMAIN" ]; then
    echo -e "${RED}Error: Domain cannot be empty${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Domain: $DOMAIN${NC}"
echo ""

# Check/Configure DNS routing
echo -e "${CYAN}=== Configuring DNS Routing ===${NC}"
EXISTING_ROUTE=$(cloudflared tunnel route dns list 2>/dev/null | grep "$DOMAIN" || true)

if [ -n "$EXISTING_ROUTE" ]; then
    echo -e "${GREEN}✓ DNS route already exists for $DOMAIN${NC}"
else
    echo "Creating DNS route..."
    cloudflared tunnel route dns "$TUNNEL_ID" "$DOMAIN"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ DNS route created${NC}"
    else
        echo -e "${YELLOW}Warning: Could not create DNS route automatically${NC}"
        echo "Add it manually in Cloudflare Zero Trust dashboard"
    fi
fi
echo ""

# Create/Update config file
echo -e "${CYAN}=== Creating Configuration ===${NC}"
CONFIG_FILE="$HOME/.cloudflared/config.yml"

cat > "$CONFIG_FILE" <<EOF
tunnel: $TUNNEL_ID
credentials-file: $CRED_FILE

ingress:
  - hostname: $DOMAIN
    service: http://n8n:5678
  - service: http_status:404
EOF

echo -e "${GREEN}✓ Configuration file created: $CONFIG_FILE${NC}"
echo ""

# Generate tunnel token
echo -e "${CYAN}=== Generating Tunnel Token ===${NC}"
TUNNEL_TOKEN=$(cloudflared tunnel token "$TUNNEL_NAME" 2>/dev/null)

if [ -z "$TUNNEL_TOKEN" ]; then
    echo -e "${RED}Error: Failed to generate tunnel token${NC}"
    echo "Try running: cloudflared tunnel login"
    exit 1
fi

echo -e "${GREEN}✓ Tunnel token generated${NC}"
echo ""

# Update configuration files based on deployment type
echo -e "${CYAN}=== Updating Configuration Files ===${NC}"

# Update local-with-tunnel config
LOCAL_TUNNEL_CONFIG="deployments/local-with-tunnel/config.env"
if [ -f "$LOCAL_TUNNEL_CONFIG" ]; then
    if grep -q "^TUNNEL_TOKEN=" "$LOCAL_TUNNEL_CONFIG"; then
        sed -i.bak "s|^TUNNEL_TOKEN=.*|TUNNEL_TOKEN=$TUNNEL_TOKEN|" "$LOCAL_TUNNEL_CONFIG"
    else
        echo "TUNNEL_TOKEN=$TUNNEL_TOKEN" >> "$LOCAL_TUNNEL_CONFIG"
    fi
    
    if grep -q "^N8N_DOMAIN=" "$LOCAL_TUNNEL_CONFIG"; then
        sed -i.bak "s|^N8N_DOMAIN=.*|N8N_DOMAIN=$DOMAIN|" "$LOCAL_TUNNEL_CONFIG"
    else
        echo "N8N_DOMAIN=$DOMAIN" >> "$LOCAL_TUNNEL_CONFIG"
    fi
    
    rm -f "${LOCAL_TUNNEL_CONFIG}.bak"
    echo -e "${GREEN}✓ Updated: $LOCAL_TUNNEL_CONFIG${NC}"
fi

# Update terraform.tfvars
TFVARS_FILE="../terraform/terraform.tfvars"
if [ -f "$TFVARS_FILE" ]; then
    if grep -q "^tunnel_token" "$TFVARS_FILE"; then
        sed -i.bak "s|^tunnel_token.*|tunnel_token       = \"$TUNNEL_TOKEN\"|" "$TFVARS_FILE"
    else
        echo "tunnel_token       = \"$TUNNEL_TOKEN\"" >> "$TFVARS_FILE"
    fi
    
    if grep -q "^domain" "$TFVARS_FILE"; then
        sed -i.bak "s|^domain.*|domain             = \"$DOMAIN\"|" "$TFVARS_FILE"
    else
        echo "domain             = \"$DOMAIN\"" >> "$TFVARS_FILE"
    fi
    
    rm -f "${TFVARS_FILE}.bak"
    echo -e "${GREEN}✓ Updated: $TFVARS_FILE${NC}"
fi

echo ""

# Summary and next steps
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}✓ Tunnel Ready for Activation!${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""
echo -e "${GREEN}Tunnel Details:${NC}"
echo "  Name:   $TUNNEL_NAME"
echo "  ID:     $TUNNEL_ID"
echo "  Domain: $DOMAIN"
echo ""
echo -e "${YELLOW}Important: The tunnel will appear as INACTIVE until you deploy${NC}"
echo ""
echo -e "${GREEN}Next Steps - Choose Your Deployment:${NC}"
echo ""
echo -e "${CYAN}Option 1: Local Deployment (Test on your machine)${NC}"
echo "  ./scripts/deploy-local-with-tunnel.sh"
echo ""
echo -e "${CYAN}Option 2: GCP VM Deployment (Production)${NC}"
echo "  ./scripts/deploy-vm-with-tunnel.sh"
echo ""
echo -e "${CYAN}Option 3: Test Tunnel Now (Foreground)${NC}"
echo "  cloudflared tunnel run $TUNNEL_NAME"
echo "  (Press Ctrl+C to stop)"
echo ""
echo -e "${BLUE}Once deployed, your tunnel will show as ACTIVE at:${NC}"
echo "  https://one.dash.cloudflare.com/ → Networks → Tunnels"
echo ""
echo -e "${GREEN}Configuration files updated with tunnel token.${NC}"
echo ""
