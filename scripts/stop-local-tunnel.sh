#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}Stopping local n8n deployment with tunnel...${NC}"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DEPLOYMENT_DIR="$SCRIPT_DIR/../deployments/local-with-tunnel"

cd "$DEPLOYMENT_DIR"
docker-compose down

echo -e "${GREEN}✓ Stopped local deployment with tunnel${NC}"
