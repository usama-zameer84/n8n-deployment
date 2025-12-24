#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   n8n Local with Cloudflare Tunnel${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DEPLOYMENT_DIR="$SCRIPT_DIR/../deployments/local-with-tunnel"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}Error: Docker is not running. Please start Docker Desktop.${NC}"
    exit 1
fi

# Check if config.env exists
if [ ! -f "$DEPLOYMENT_DIR/config.env" ]; then
    echo -e "${YELLOW}Creating config.env from example...${NC}"
    cp "$DEPLOYMENT_DIR/config.env.example" "$DEPLOYMENT_DIR/config.env"
fi

# Load environment variables
export $(cat "$DEPLOYMENT_DIR/config.env" | grep -v '^#' | xargs)

# Show current configuration
if [ -n "$TUNNEL_TOKEN" ] && [ "$TUNNEL_TOKEN" != "your_tunnel_token_here" ] && \
   [ -n "$N8N_DOMAIN" ] && [ "$N8N_DOMAIN" != "your-domain.com" ]; then
    echo -e "${GREEN}Current Configuration:${NC}"
    echo -e "  Domain: ${CYAN}$N8N_DOMAIN${NC}"
    echo -e "  Token:  ${CYAN}${TUNNEL_TOKEN:0:10}...${NC}"
    echo ""
    read -p "Do you want to reconfigure? (y/N): " RECONFIGURE
    if [[ "$RECONFIGURE" =~ ^[Yy] ]]; then
        TUNNEL_TOKEN=""
        N8N_DOMAIN=""
    fi
fi

# Check if configuration is needed
if [ -z "$TUNNEL_TOKEN" ] || [ "$TUNNEL_TOKEN" = "your_tunnel_token_here" ] || \
   [ -z "$N8N_DOMAIN" ] || [ "$N8N_DOMAIN" = "your-domain.com" ]; then
   
    echo -e "${RED}============================================${NC}"
    echo -e "${RED}   Configuration Required!${NC}"
    echo -e "${RED}============================================${NC}"
    
    # Option 1: Automatic Setup
    if command -v cloudflared &> /dev/null; then
        echo -e "Cloudflare Tunnel CLI found."
        read -p "Do you want to run the automatic tunnel setup wizard? (Y/n): " AUTO_SETUP
        if [[ "$AUTO_SETUP" =~ ^[Yy] ]] || [[ -z "$AUTO_SETUP" ]]; then
            "$SCRIPT_DIR/setup-tunnel.sh"
            # Reload env after setup
            export $(cat "$DEPLOYMENT_DIR/config.env" | grep -v '^#' | xargs)
        fi
    fi
    
    # Option 2: Manual Input (if still not configured)
    if [ -z "$TUNNEL_TOKEN" ] || [ "$TUNNEL_TOKEN" = "your_tunnel_token_here" ]; then
        echo ""
        echo -e "${YELLOW}Manual Configuration:${NC}"
        echo "Please enter your Cloudflare Tunnel Token."
        echo "(Get this from https://one.dash.cloudflare.com/ > Networks > Tunnels)"
        read -p "Tunnel Token: " INPUT_TOKEN
        if [ -n "$INPUT_TOKEN" ]; then
            # Escape special characters in token if needed, though usually base64 safe
            sed -i.bak "s|^TUNNEL_TOKEN=.*|TUNNEL_TOKEN=$INPUT_TOKEN|" "$DEPLOYMENT_DIR/config.env"
            TUNNEL_TOKEN="$INPUT_TOKEN"
            rm -f "$DEPLOYMENT_DIR/config.env.bak"
        fi
    fi

    if [ -z "$N8N_DOMAIN" ] || [ "$N8N_DOMAIN" = "your-domain.com" ]; then
        echo ""
        read -p "Enter your n8n domain (e.g., n8n.example.com): " INPUT_DOMAIN
        if [ -n "$INPUT_DOMAIN" ]; then
            sed -i.bak "s|^N8N_DOMAIN=.*|N8N_DOMAIN=$INPUT_DOMAIN|" "$DEPLOYMENT_DIR/config.env"
            N8N_DOMAIN="$INPUT_DOMAIN"
            rm -f "$DEPLOYMENT_DIR/config.env.bak"
        fi
    fi
fi

# Validate required variables
if [ -z "$TUNNEL_TOKEN" ] || [ "$TUNNEL_TOKEN" = "your_tunnel_token_here" ]; then
    echo -e "${RED}Error: TUNNEL_TOKEN not set in config.env${NC}"
    echo -e "Please edit ${YELLOW}$DEPLOYMENT_DIR/config.env${NC} and add your Cloudflare tunnel token"
    exit 1
fi

if [ -z "$N8N_DOMAIN" ] || [ "$N8N_DOMAIN" = "your-domain.com" ]; then
    echo -e "${RED}Error: N8N_DOMAIN not set in config.env${NC}"
    echo -e "Please edit ${YELLOW}$DEPLOYMENT_DIR/config.env${NC} and add your domain"
    exit 1
fi

# Navigate to deployment directory
cd "$DEPLOYMENT_DIR"

# Check for config.yml directory issue (Docker mount artifact)
if [ -d "config.yml" ]; then
    echo -e "${YELLOW}Found config.yml as a directory. Removing it...${NC}"
    rm -rf "config.yml"
fi

# Check if config.yml exists (required for tunnel)
if [ ! -f "config.yml" ]; then
    echo -e "${YELLOW}Warning: config.yml not found. It should have been created by setup-tunnel.sh${NC}"
    echo -e "${YELLOW}Creating a default one...${NC}"
    cat > config.yml <<EOF
ingress:
  - hostname: $N8N_DOMAIN
    service: http://n8n:5678
  - service: http_status:404
EOF
fi

echo -e "${BLUE}Starting n8n with Cloudflare Tunnel...${NC}"
docker-compose up -d

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   n8n is starting up!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${GREEN}Access n8n at: https://${N8N_DOMAIN}${NC}"
echo -e "${GREEN}Local access: http://localhost:5678${NC}"
echo ""
echo -e "To view logs: ${YELLOW}docker-compose -f $DEPLOYMENT_DIR/docker-compose.yml logs -f${NC}"
echo -e "To stop: ${YELLOW}$SCRIPT_DIR/stop-local-tunnel.sh${NC}"
echo ""
