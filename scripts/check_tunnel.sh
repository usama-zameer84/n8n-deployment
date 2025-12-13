#!/bin/bash

# Cloudflare Zero Trust Tunnel Status Checker
# This script checks the status of your Cloudflare Tunnel

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}Cloudflare Zero Trust Tunnel Status${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Check if cloudflared is installed
if command -v cloudflared &> /dev/null; then
    echo -e "${GREEN}✓ cloudflared CLI installed${NC}"
    
    # List all tunnels
    echo -e "\n${CYAN}=== Your Cloudflare Tunnels ===${NC}"
    cloudflared tunnel list 2>/dev/null || echo -e "${YELLOW}Could not list tunnels (may need authentication)${NC}"
    
    # List tunnel routes
    echo -e "\n${CYAN}=== Tunnel Routes (DNS) ===${NC}"
    cloudflared tunnel route dns list 2>/dev/null || echo -e "${YELLOW}Could not list routes${NC}"
else
    echo -e "${YELLOW}⚠ cloudflared CLI not installed${NC}"
fi

# Check Docker containers
echo -e "\n${CYAN}=== Docker Containers ===${NC}"
if command -v docker &> /dev/null; then
    DOCKER_CMD="docker"
    if ! docker ps &> /dev/null; then
        DOCKER_CMD="sudo docker"
    fi
    
    $DOCKER_CMD ps -a --filter "name=cloudflare-tunnel" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo -e "${YELLOW}No cloudflare-tunnel container found${NC}"
    
    # Check if tunnel container exists
    if $DOCKER_CMD ps -a --filter "name=cloudflare-tunnel" --format "{{.Names}}" | grep -q "cloudflare-tunnel"; then
        echo -e "\n${CYAN}=== Cloudflare Tunnel Container Logs (last 30 lines) ===${NC}"
        $DOCKER_CMD logs cloudflare-tunnel --tail 30 2>/dev/null
        
        # Check connectivity from tunnel to n8n
        echo -e "\n${CYAN}=== Checking n8n Accessibility from Tunnel ===${NC}"
        if $DOCKER_CMD exec cloudflare-tunnel wget -qO- http://n8n:5678 &> /dev/null; then
            echo -e "${GREEN}✓ n8n is accessible from tunnel container${NC}"
        else
            echo -e "${RED}✗ Cannot reach n8n from tunnel container${NC}"
            echo -e "${YELLOW}  Make sure n8n container is running and on the same network${NC}"
        fi
        
        # Check if tunnel is connected
        echo -e "\n${CYAN}=== Tunnel Connection Status ===${NC}"
        if $DOCKER_CMD logs cloudflare-tunnel --tail 10 2>/dev/null | grep -q "registered"; then
            echo -e "${GREEN}✓ Tunnel appears to be registered and connected${NC}"
        elif $DOCKER_CMD logs cloudflare-tunnel --tail 10 2>/dev/null | grep -q "Connection.*registered"; then
            echo -e "${GREEN}✓ Tunnel connection is active${NC}"
        else
            echo -e "${YELLOW}⚠ Tunnel status unclear - check logs above${NC}"
        fi
    else
        echo -e "${YELLOW}No cloudflare-tunnel container found${NC}"
        echo -e "${YELLOW}Deploy with: ./scripts/deploy-local-with-tunnel.sh or ./scripts/deploy-vm-with-tunnel.sh${NC}"
    fi
else
    echo -e "${RED}✗ Docker not installed or not running${NC}"
fi

# Check for environment files
echo -e "\n${CYAN}=== Configuration Files ===${NC}"
for env_file in ".env" "deployments/local-with-tunnel/config.env" "/home/ubuntu/n8n/.env"; do
    if [ -f "$env_file" ]; then
        echo -e "${GREEN}✓ Found: $env_file${NC}"
        if grep -q "TUNNEL_TOKEN" "$env_file" 2>/dev/null; then
            TOKEN_PREVIEW=$(grep "TUNNEL_TOKEN" "$env_file" 2>/dev/null | cut -c1-40)
            echo -e "  ${CYAN}${TOKEN_PREVIEW}...${NC}"
        fi
    fi
done

# Summary and recommendations
echo -e "\n${BLUE}================================================${NC}"
echo -e "${BLUE}Summary & Recommendations${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""
echo -e "${CYAN}To view tunnel status in Cloudflare Zero Trust:${NC}"
echo "  https://one.dash.cloudflare.com/"
echo "  Navigate to: Networks > Tunnels"
echo ""
echo -e "${CYAN}To activate your tunnel:${NC}"
echo "  1. Ensure tunnel is created: ./scripts/setup-tunnel.sh"
echo "  2. Deploy with Docker: ./scripts/deploy-local-with-tunnel.sh"
echo "  3. The tunnel will show as ACTIVE in Cloudflare dashboard"
echo ""
echo -e "${CYAN}Common issues:${NC}"
echo "  - Tunnel shows as INACTIVE: Start the Docker container with cloudflared"
echo "  - Cannot reach n8n: Check Docker network and container names"
echo "  - Authentication errors: Run 'cloudflared tunnel login' again"
echo ""
