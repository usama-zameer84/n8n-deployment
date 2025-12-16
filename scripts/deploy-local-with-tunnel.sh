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
    echo -e "${RED}============================================${NC}"
    echo -e "${RED}   IMPORTANT: Configuration Required!${NC}"
    echo -e "${RED}============================================${NC}"
    echo -e "Please edit ${YELLOW}$DEPLOYMENT_DIR/config.env${NC}"
    echo -e "and fill in your:"
    echo -e "  1. ${YELLOW}TUNNEL_TOKEN${NC} (from Cloudflare)"
    echo -e "  2. ${YELLOW}N8N_DOMAIN${NC} (your domain)"
    echo ""
    echo -e "Run this script again after configuration."
    exit 1
fi

# Load environment variables
export $(cat "$DEPLOYMENT_DIR/config.env" | grep -v '^#' | xargs)

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
