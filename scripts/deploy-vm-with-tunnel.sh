#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}   n8n GCP VM with Cloudflare Tunnel${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TERRAFORM_DIR="$SCRIPT_DIR/../terraform"

# Parse arguments
SKIP_TUNNEL_SETUP=false
for arg in "$@"; do
    case $arg in
        --skip-tunnel-setup)
        SKIP_TUNNEL_SETUP=true
        shift
        ;;
    esac
done

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

# Check if cloudflared is installed (only if not skipping tunnel setup)
if [ "$SKIP_TUNNEL_SETUP" = false ]; then
    if ! command -v cloudflared &> /dev/null; then
        echo -e "${RED}Error: cloudflared CLI is not installed.${NC}"
        echo -e "Install instructions: $SCRIPT_DIR/../docs/INSTALL_CLOUDFLARED.md"
        exit 1
    fi
fi

# Check if authenticated with GCP
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" &> /dev/null; then
    echo -e "${YELLOW}Not authenticated with GCP. Running gcloud auth login...${NC}"
    gcloud auth login
fi

echo -e "${GREEN}✓ Prerequisites check passed${NC}"
echo ""

# Setup Cloudflare Tunnel (unless skipped)
if [ "$SKIP_TUNNEL_SETUP" = false ]; then
    echo -e "${BLUE}Setting up Cloudflare Tunnel...${NC}"
    
    if [ -f "$SCRIPT_DIR/setup-tunnel.sh" ]; then
        bash "$SCRIPT_DIR/setup-tunnel.sh"
    else
        echo -e "${RED}Error: setup-tunnel.sh not found in scripts directory${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ Tunnel setup complete${NC}"
    echo ""
else
    echo -e "${YELLOW}Skipping tunnel setup (--skip-tunnel-setup flag used)${NC}"
    echo ""
fi

# Check if terraform.tfvars exists
if [ ! -f "$TERRAFORM_DIR/terraform.tfvars" ]; then
    echo -e "${RED}Error: terraform.tfvars not found${NC}"
    echo -e "Please create it from terraform.tfvars.example and fill in required values"
    exit 1
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
terraform plan

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
terraform apply -auto-approve

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   Deployment Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Get outputs
DOMAIN=$(terraform output -raw domain 2>/dev/null || echo "Not available")
VM_IP=$(terraform output -raw vm_external_ip 2>/dev/null || echo "Check GCP Console")

echo -e "${GREEN}Access n8n at: https://${DOMAIN}${NC}"
echo -e "${GREEN}VM External IP: ${VM_IP}${NC}"
echo ""
echo -e "SSH into the VM:"
echo -e "${YELLOW}  gcloud compute ssh n8n-server --zone=us-central1-a --project=\$(terraform output -raw project_id)${NC}"
echo ""
