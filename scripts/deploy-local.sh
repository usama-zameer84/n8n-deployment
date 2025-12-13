#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   n8n Local Deployment (No Tunnel)${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DEPLOYMENT_DIR="$SCRIPT_DIR/../deployments/local"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}Error: Docker is not running. Please start Docker Desktop.${NC}"
    exit 1
fi

# Create config.env if it doesn't exist
if [ ! -f "$DEPLOYMENT_DIR/config.env" ]; then
    echo -e "${YELLOW}Creating config.env from example...${NC}"
    cp "$DEPLOYMENT_DIR/config.env.example" "$DEPLOYMENT_DIR/config.env"
    echo -e "${GREEN}✓ Created config.env${NC}"
    echo -e "${YELLOW}You can edit $DEPLOYMENT_DIR/config.env to customize settings${NC}"
    echo ""
fi

# Navigate to deployment directory
cd "$DEPLOYMENT_DIR"

# Load environment variables
if [ -f config.env ]; then
    export $(cat config.env | grep -v '^#' | xargs)
fi

echo -e "${BLUE}Starting n8n...${NC}"
docker-compose up -d

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   n8n is starting up!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${GREEN}Access n8n at: http://localhost:5678${NC}"
echo ""
echo -e "To view logs: ${YELLOW}docker-compose -f $DEPLOYMENT_DIR/docker-compose.yml logs -f${NC}"
echo -e "To stop: ${YELLOW}$SCRIPT_DIR/stop-local.sh${NC}"
echo ""
