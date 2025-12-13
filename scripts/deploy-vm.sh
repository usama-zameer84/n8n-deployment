#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}   n8n GCP VM Deployment (No Tunnel)${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TERRAFORM_DIR="$SCRIPT_DIR/../terraform"

# Check prerequisites
echo -e "${BLUE}Checking prerequisites...${NC}"

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo -e "${RED}Error: gcloud CLI is not installed.${NC}"
    echo -e "Install from: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Check if terraform is installed
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}Error: Terraform is not installed.${NC}"
    echo -e "Install from: https://www.terraform.io/downloads"
    exit 1
fi

# Check if authenticated with GCP
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" &> /dev/null; then
    echo -e "${YELLOW}Not authenticated with GCP. Running gcloud auth login...${NC}"
    gcloud auth login
fi

echo -e "${GREEN}✓ Prerequisites check passed${NC}"
echo ""

# Check if terraform.tfvars exists
if [ ! -f "$TERRAFORM_DIR/terraform.tfvars" ]; then
    echo -e "${YELLOW}Creating terraform.tfvars from example...${NC}"
    if [ -f "$TERRAFORM_DIR/terraform.tfvars.example" ]; then
        cp "$TERRAFORM_DIR/terraform.tfvars.example" "$TERRAFORM_DIR/terraform.tfvars"
        echo -e "${RED}============================================${NC}"
        echo -e "${RED}   IMPORTANT: Configuration Required!${NC}"
        echo -e "${RED}============================================${NC}"
        echo -e "Please edit ${YELLOW}$TERRAFORM_DIR/terraform.tfvars${NC}"
        echo -e "and fill in your:"
        echo -e "  1. ${YELLOW}billing_account_id${NC} (from GCP)"
        echo -e "  2. Remove or comment out tunnel-related variables"
        echo ""
        echo -e "Run this script again after configuration."
        exit 1
    else
        echo -e "${RED}Error: terraform.tfvars.example not found${NC}"
        exit 1
    fi
fi

# Navigate to terraform directory
cd "$TERRAFORM_DIR"

# Initialize Terraform if needed
if [ ! -d ".terraform" ]; then
    echo -e "${BLUE}Initializing Terraform...${NC}"
    terraform init
    echo -e "${GREEN}✓ Terraform initialized${NC}"
    echo ""
fi

# Show plan
echo -e "${BLUE}Generating Terraform plan...${NC}"
echo -e "${YELLOW}Note: This deployment does NOT include Cloudflare Tunnel${NC}"
echo ""
terraform plan -var="tunnel_token=dummy_token_not_used" -var="domain=dummy_domain_not_used"

echo ""
echo -e "${YELLOW}Review the plan above. Do you want to proceed? (yes/no)${NC}"
read -r REPLY
if [[ ! $REPLY =~ ^[Yy]es$ ]]; then
    echo -e "${RED}Deployment cancelled.${NC}"
    exit 0
fi

# Apply Terraform
echo ""
echo -e "${BLUE}Deploying to GCP...${NC}"
terraform apply -auto-approve -var="tunnel_token=dummy_token_not_used" -var="domain=dummy_domain_not_used"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   Deployment Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Get the VM's external IP
VM_IP=$(terraform output -raw vm_external_ip 2>/dev/null || echo "Check GCP Console")

echo -e "${GREEN}VM External IP: ${VM_IP}${NC}"
echo ""
echo -e "SSH into the VM:"
echo -e "${YELLOW}  gcloud compute ssh n8n-server --zone=us-central1-a --project=\$(terraform output -raw project_id)${NC}"
echo ""
echo -e "${YELLOW}Note: You'll need to configure firewall rules or use SSH tunneling to access n8n${NC}"
echo -e "Or access via: ${YELLOW}http://${VM_IP}:5678${NC} (if firewall allows)"
echo ""
