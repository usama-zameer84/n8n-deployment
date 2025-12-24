#!/bin/bash

# Script to check logs on the GCP VM
set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}      n8n VM Log Viewer${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo -e "${RED}Error: gcloud CLI is not installed.${NC}"
    exit 1
fi

# Try to get Project ID from Terraform
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TERRAFORM_DIR="$SCRIPT_DIR/../terraform"
PROJECT_ID=""

if [ -d "$TERRAFORM_DIR" ] && [ -f "$TERRAFORM_DIR/terraform.tfstate" ]; then
    echo -e "${BLUE}Reading configuration from Terraform...${NC}"
    pushd "$TERRAFORM_DIR" > /dev/null
    if command -v terraform &> /dev/null; then
        PROJECT_ID=$(terraform output -raw project_id 2>/dev/null)
    fi
    popd > /dev/null
fi

if [ -n "$PROJECT_ID" ]; then
    echo -e "${GREEN}✓ Detected Project ID: $PROJECT_ID${NC}"
    PROJECT_FLAG="--project=$PROJECT_ID"
else
    echo -e "${YELLOW}Warning: Could not detect Project ID from Terraform.${NC}"
    echo -e "${YELLOW}Using default gcloud project configuration.${NC}"
    PROJECT_FLAG=""
fi

# Find the instance zone
echo -e "${YELLOW}Locating n8n-server instance...${NC}"
# Get zone, handle potential multiple lines or errors
ZONE=$(gcloud compute instances list $PROJECT_FLAG --filter="name=n8n-server" --format="value(zone)" 2>/dev/null | head -n1)

if [ -z "$ZONE" ]; then
    echo -e "${RED}Error: Could not find 'n8n-server' instance.${NC}"
    if [ -n "$PROJECT_ID" ]; then
        echo "Checked in project: $PROJECT_ID"
    else
        CURRENT_PROJECT=$(gcloud config get-value project 2>/dev/null)
        echo "Checked in default project: $CURRENT_PROJECT"
    fi
    echo "Please ensure the VM is deployed and running."
    exit 1
fi

echo -e "${GREEN}✓ Found instance in zone: $ZONE${NC}"
echo ""

# Menu
echo "Which logs do you want to check?"
echo "1) n8n Application (Live logs)"
echo "2) Cloudflare Tunnel (Live logs)"
echo "3) VM Startup/Deployment Log (Debugging deployment issues)"
echo "4) Docker Container Status"
echo ""
read -p "Select an option (1-4): " OPTION

case $OPTION in
    1)
        echo -e "${BLUE}Fetching n8n logs... (Ctrl+C to exit)${NC}"
        CMD="sudo docker logs -f n8n"
        ;;
    2)
        echo -e "${BLUE}Fetching tunnel logs... (Ctrl+C to exit)${NC}"
        CMD="sudo docker logs -f cloudflare-tunnel"
        ;;
    3)
        echo -e "${BLUE}Fetching startup script logs... (Ctrl+C to exit)${NC}"
        CMD="tail -f /var/log/startup-script.log"
        ;;
    4)
        echo -e "${BLUE}Checking container status...${NC}"
        CMD="sudo docker ps -a"
        ;;
    *)
        echo -e "${RED}Invalid option${NC}"
        exit 1
        ;;
esac

echo ""
# Run the command via SSH
gcloud compute ssh n8n-server --zone="$ZONE" $PROJECT_FLAG --command="$CMD"
