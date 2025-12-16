#!/bin/bash

# Script to configure VS Code SSH access to the n8n VM
set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   Setup VS Code SSH Access${NC}"
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
ZONE=$(gcloud compute instances list $PROJECT_FLAG --filter="name=n8n-server" --format="value(zone)" 2>/dev/null | head -n1)

if [ -z "$ZONE" ]; then
    echo -e "${RED}Error: Could not find 'n8n-server' instance.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Found instance in zone: $ZONE${NC}"
echo ""

# Configure SSH
echo -e "${BLUE}Configuring SSH access...${NC}"
gcloud compute config-ssh $PROJECT_FLAG --ssh-key-file="$HOME/.ssh/google_compute_engine" --quiet

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✓ SSH configuration updated successfully!${NC}"
    echo ""
    echo -e "${BLUE}To connect in VS Code:${NC}"
    echo "1. Open the Command Palette (Cmd+Shift+P)"
    echo "2. Type 'Remote-SSH: Connect to Host...'"
    echo "3. Select: ${GREEN}n8n-server.${ZONE}.${PROJECT_ID}${NC}"
    echo ""
    echo -e "${YELLOW}Note: The first time you connect, it may take a moment to install the VS Code Server on the VM.${NC}"
else
    echo -e "${RED}Error: Failed to configure SSH.${NC}"
fi
