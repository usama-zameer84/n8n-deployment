#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}Destroying GCP VM deployment...${NC}"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TERRAFORM_DIR="$SCRIPT_DIR/../terraform"

cd "$TERRAFORM_DIR"

echo -e "${YELLOW}This will destroy all resources created by Terraform.${NC}"
echo -e "${YELLOW}This includes the VM, project, and all data!${NC}"
echo -e "${RED}This action cannot be undone!${NC}"
echo ""
echo -e "${YELLOW}Type 'yes' to confirm destruction: ${NC}"
read -r REPLY

if [[ ! $REPLY =~ ^[Yy]es$ ]]; then
    echo -e "${RED}Destruction cancelled.${NC}"
    exit 0
fi

terraform destroy

echo -e "${GREEN}✓ Resources destroyed${NC}"
