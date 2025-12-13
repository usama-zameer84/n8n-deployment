#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Display banner
clear
echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                                            ║${NC}"
echo -e "${BLUE}║        n8n Deployment Manager              ║${NC}"
echo -e "${BLUE}║                                            ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

# Main menu
show_menu() {
    echo -e "${GREEN}Choose your deployment option:${NC}"
    echo ""
    echo -e "  ${YELLOW}Local Deployments:${NC}"
    echo -e "    1) Deploy locally (no tunnel) - Access at http://localhost:5678"
    echo -e "    2) Deploy locally with Cloudflare Tunnel - Secure HTTPS access"
    echo -e "    3) Stop local deployment"
    echo -e "    4) Stop local deployment with tunnel"
    echo ""
    echo -e "  ${YELLOW}GCP VM Deployments:${NC}"
    echo -e "    5) Deploy to GCP VM (no tunnel)"
    echo -e "    6) Deploy to GCP VM with Cloudflare Tunnel (recommended)"
    echo -e "    7) Destroy GCP VM deployment"
    echo ""
    echo -e "  ${YELLOW}Utilities:${NC}"
    echo -e "    8) View logs (local)"
    echo -e "    9) View logs (local with tunnel)"
    echo -e "    10) Setup new Cloudflare Tunnel"
    echo -e "    11) Activate existing Cloudflare Tunnel"
    echo -e "    12) Check Cloudflare Tunnel status"
    echo ""
    echo -e "    0) Exit"
    echo ""
    echo -e -n "${BLUE}Enter your choice [0-12]: ${NC}"
}

# View logs function
view_logs() {
    local deployment_type=$1
    local deployment_dir=""
    
    case $deployment_type in
        "local")
            deployment_dir="$SCRIPT_DIR/../deployments/local"
            ;;
        "local-tunnel")
            deployment_dir="$SCRIPT_DIR/../deployments/local-with-tunnel"
            ;;
    esac
    
    if [ -n "$deployment_dir" ]; then
        echo -e "${BLUE}Viewing logs... (Press Ctrl+C to exit)${NC}"
        docker-compose -f "$deployment_dir/docker-compose.yml" logs -f
    fi
}

# Main loop
while true; do
    show_menu
    read -r choice
    echo ""
    
    case $choice in
        1)
            echo -e "${BLUE}Starting local deployment...${NC}"
            bash "$SCRIPT_DIR/deploy-local.sh"
            ;;
        2)
            echo -e "${BLUE}Starting local deployment with Cloudflare Tunnel...${NC}"
            bash "$SCRIPT_DIR/deploy-local-with-tunnel.sh"
            ;;
        3)
            echo -e "${BLUE}Stopping local deployment...${NC}"
            bash "$SCRIPT_DIR/stop-local.sh"
            ;;
        4)
            echo -e "${BLUE}Stopping local deployment with tunnel...${NC}"
            bash "$SCRIPT_DIR/stop-local-tunnel.sh"
            ;;
        5)
            echo -e "${BLUE}Deploying to GCP VM...${NC}"
            bash "$SCRIPT_DIR/deploy-vm.sh"
            ;;
        6)
            echo -e "${BLUE}Deploying to GCP VM with Cloudflare Tunnel...${NC}"
            bash "$SCRIPT_DIR/deploy-vm-with-tunnel.sh"
            ;;
        7)
            echo -e "${BLUE}Destroying GCP VM deployment...${NC}"
            bash "$SCRIPT_DIR/destroy-vm.sh"
            ;;
        8)
            view_logs "local"
            ;;
        9)
            view_logs "local-tunnel"
            ;;
        10)
            echo -e "${BLUE}Setting up new Cloudflare Tunnel...${NC}"
            bash "$SCRIPT_DIR/scripts/setup-tunnel.sh"
            ;;
        11)
            echo -e "${BLUE}Activating existing Cloudflare Tunnel...${NC}"
            bash "$SCRIPT_DIR/scripts/activate-tunnel.sh"
            ;;
        12)
            echo -e "${BLUE}Checking Cloudflare Tunnel status...${NC}"
            bash "$SCRIPT_DIR/scripts/check_tunnel.sh"
            ;;
        0)
            echo -e "${GREEN}Goodbye!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option. Please try again.${NC}"
            ;;
    esac
    
    echo ""
    echo -e "${YELLOW}Press Enter to continue...${NC}"
    read -r
    clear
    echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║        n8n Deployment Manager              ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
    echo ""
done
