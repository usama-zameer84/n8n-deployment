#!/bin/bash

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Pre-Push Security Check                ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

ERRORS=0
WARNINGS=0

# Check if in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠ Not a git repository yet.${NC}"
    echo -e "${BLUE}This check will be fully functional after running 'git init'${NC}"
    echo ""
fi

# Check for sensitive files
echo -e "${BLUE}Checking for sensitive files...${NC}"

SENSITIVE_FILES=(
    "deployments/local/config.env"
    "deployments/local-with-tunnel/config.env"
    "terraform/terraform.tfvars"
    ".env"
)

for file in "${SENSITIVE_FILES[@]}"; do
    if [ -f "$file" ]; then
        if git rev-parse --git-dir > /dev/null 2>&1; then
            if git check-ignore "$file" > /dev/null 2>&1; then
                echo -e "${GREEN}✓ $file is ignored${NC}"
            else
                echo -e "${RED}✗ WARNING: $file is NOT in .gitignore!${NC}"
                ERRORS=$((ERRORS + 1))
            fi
        else
            # Not in git repo, just check if pattern is in .gitignore
            filename=$(basename "$file")
            if grep -q "$filename" .gitignore || grep -q "*.env" .gitignore; then
                echo -e "${GREEN}✓ $file pattern is in .gitignore${NC}"
            else
                echo -e "${RED}✗ WARNING: $file pattern is NOT in .gitignore!${NC}"
                ERRORS=$((ERRORS + 1))
            fi
        fi
    fi
done

# Check if sensitive files are staged
echo ""
if git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${BLUE}Checking staged files...${NC}"
    STAGED_FILES=$(git diff --cached --name-only 2>/dev/null)
else
    echo -e "${BLUE}Skipping staged files check (not in git repo)${NC}"
    STAGED_FILES=""
fi

if echo "$STAGED_FILES" | grep -q "config.env"; then
    echo -e "${RED}✗ ERROR: config.env file is staged!${NC}"
    ERRORS=$((ERRORS + 1))
fi

if echo "$STAGED_FILES" | grep -q "terraform.tfvars"; then
    echo -e "${RED}✗ ERROR: terraform.tfvars is staged!${NC}"
    ERRORS=$((ERRORS + 1))
fi

if echo "$STAGED_FILES" | grep -q "\.tfstate"; then
    echo -e "${RED}✗ ERROR: Terraform state file is staged!${NC}"
    ERRORS=$((ERRORS + 1))
fi

if echo "$STAGED_FILES" | grep -q "\.env$"; then
    echo -e "${RED}✗ ERROR: .env file is staged!${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Search for potential secrets in staged files
echo ""
echo -e "${BLUE}Scanning for potential secrets in staged files...${NC}"

for file in $STAGED_FILES; do
    if [ -f "$file" ]; then
        # Check for common secret patterns
        if grep -qi "password.*=.*[^example]" "$file" 2>/dev/null; then
            if ! grep -q "example" "$file"; then
                echo -e "${YELLOW}⚠ Warning: Possible password found in $file${NC}"
                WARNINGS=$((WARNINGS + 1))
            fi
        fi
        
        if grep -qi "token.*=.*[a-zA-Z0-9]\{20,\}" "$file" 2>/dev/null; then
            echo -e "${YELLOW}⚠ Warning: Possible token found in $file${NC}"
            WARNINGS=$((WARNINGS + 1))
        fi
        
        if grep -qi "secret.*=.*[a-zA-Z0-9]\{20,\}" "$file" 2>/dev/null; then
            echo -e "${YELLOW}⚠ Warning: Possible secret found in $file${NC}"
            WARNINGS=$((WARNINGS + 1))
        fi
    fi
done

# Check if .gitignore exists
echo ""
echo -e "${BLUE}Checking .gitignore...${NC}"
if [ -f ".gitignore" ]; then
    echo -e "${GREEN}✓ .gitignore exists${NC}"
    
    # Check if important patterns are in .gitignore
    REQUIRED_PATTERNS=("*.env" "config.env" "terraform.tfvars" "*.tfstate")
    for pattern in "${REQUIRED_PATTERNS[@]}"; do
        if grep -q "$pattern" .gitignore; then
            echo -e "${GREEN}✓ $pattern is in .gitignore${NC}"
        else
            echo -e "${RED}✗ $pattern is NOT in .gitignore${NC}"
            ERRORS=$((ERRORS + 1))
        fi
    done
else
    echo -e "${RED}✗ .gitignore not found!${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Check if example files exist
echo ""
echo -e "${BLUE}Checking example configuration files...${NC}"

EXAMPLE_FILES=(
    "deployments/local/config.env.example"
    "deployments/local-with-tunnel/config.env.example"
    "terraform/terraform.tfvars.example"
)

for file in "${EXAMPLE_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓ $file exists${NC}"
    else
        echo -e "${YELLOW}⚠ Warning: $file not found${NC}"
        WARNINGS=$((WARNINGS + 1))
    fi
done

# Final summary
echo ""
echo -e "${BLUE}════════════════════════════════════════════${NC}"
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed! Safe to push.${NC}"
    echo ""
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠ ${WARNINGS} warning(s) found.${NC}"
    echo -e "${YELLOW}Review warnings before pushing.${NC}"
    echo ""
    exit 0
else
    echo -e "${RED}✗ ${ERRORS} error(s) found!${NC}"
    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}⚠ ${WARNINGS} warning(s) found.${NC}"
    fi
    echo ""
    echo -e "${RED}Please fix errors before pushing!${NC}"
    echo ""
    exit 1
fi
