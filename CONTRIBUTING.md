# Contributing to n8n Deployment Suite

First off, thank you for considering contributing to n8n Deployment Suite! It's people like you that make this tool better for everyone.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Pull Request Process](#pull-request-process)
- [Style Guidelines](#style-guidelines)
- [Project Structure](#project-structure)

## Code of Conduct

### Our Pledge

We pledge to make participation in our project a harassment-free experience for everyone, regardless of age, body size, disability, ethnicity, gender identity and expression, level of experience, nationality, personal appearance, race, religion, or sexual identity and orientation.

### Our Standards

**Examples of behavior that contributes to a positive environment:**
- Using welcoming and inclusive language
- Being respectful of differing viewpoints and experiences
- Gracefully accepting constructive criticism
- Focusing on what is best for the community
- Showing empathy towards other community members

**Examples of unacceptable behavior:**
- The use of sexualized language or imagery
- Trolling, insulting/derogatory comments, and personal or political attacks
- Public or private harassment
- Publishing others' private information without explicit permission
- Other conduct which could reasonably be considered inappropriate

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues to avoid duplicates. When you create a bug report, include as many details as possible:

- **Use a clear and descriptive title**
- **Describe the exact steps to reproduce the problem**
- **Provide specific examples**
- **Describe the behavior you observed and what you expected**
- **Include logs, screenshots, or error messages**
- **Mention your environment** (OS, Docker version, etc.)

**Bug Report Template:**
```markdown
## Description
[Clear description of the bug]

## Steps to Reproduce
1. 
2. 
3. 

## Expected Behavior
[What you expected to happen]

## Actual Behavior
[What actually happened]

## Environment
- OS: [e.g., macOS 13.0, Ubuntu 22.04]
- Docker Version: [e.g., 24.0.0]
- Deployment Type: [local, local-with-tunnel, vm, vm-with-tunnel]

## Logs
```
[Paste relevant logs here]
```
```

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion:

- **Use a clear and descriptive title**
- **Provide a detailed description of the suggested enhancement**
- **Explain why this enhancement would be useful**
- **List any alternative solutions you've considered**

### Pull Requests

We actively welcome your pull requests! Follow these steps:

1. Fork the repo and create your branch from `main`
2. If you've added code, add tests if applicable
3. Ensure your code follows the existing style
4. Update documentation if needed
5. Run the pre-push security check: `./scripts/pre-push-check.sh`
6. Create a pull request!

## Development Setup

### Prerequisites

- Docker Desktop installed and running
- Git installed
- Text editor or IDE
- (Optional) gcloud CLI and Terraform for testing cloud deployments

### Local Development

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/n8n-deployment-suite.git
cd n8n-deployment-suite

# Make scripts executable
chmod +x deploy.sh scripts/*.sh

# Test local deployment
./scripts/deploy-local.sh

# Make your changes
# ...

# Test your changes
./scripts/deploy-local.sh

# Run security check
./scripts/pre-push-check.sh
```

### Testing Changes

Before submitting:

1. **Test locally first:**
   ```bash
   ./scripts/deploy-local.sh
   # Verify functionality
   ./scripts/stop-local.sh
   ```

2. **Test with tunnel (if applicable):**
   ```bash
   ./scripts/deploy-local-with-tunnel.sh
   # Verify tunnel connectivity
   ./scripts/stop-local-tunnel.sh
   ```

3. **Run security checks:**
   ```bash
   ./scripts/pre-push-check.sh
   ```

## Pull Request Process

1. **Update documentation** - If you change functionality, update relevant docs
2. **Follow the style guide** - Keep code consistent with existing patterns
3. **Test thoroughly** - Ensure all deployment options still work
4. **Update CHANGELOG** - Add your changes to `docs/CHANGELOG.md` (if it exists)
5. **Security check** - Run `./scripts/pre-push-check.sh`
6. **Descriptive commits** - Write clear, descriptive commit messages

### Commit Message Guidelines

Format:
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples:**
```
feat(scripts): add backup functionality

Added new backup script that creates snapshots of n8n data volumes
and uploads them to cloud storage.

Closes #123
```

```
fix(terraform): correct variable validation

Fixed issue where domain validation was too restrictive.

Fixes #456
```

## Style Guidelines

### Shell Scripts

- Use `#!/bin/bash` shebang
- Include `set -e` for error handling
- Add descriptive comments
- Use meaningful variable names in UPPERCASE
- Include color-coded output for user feedback
- Add usage instructions at the top of complex scripts

**Example:**
```bash
#!/bin/bash
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Configuration
DEPLOYMENT_DIR="/path/to/deployment"

echo -e "${GREEN}Starting deployment...${NC}"
```

### Docker Compose Files

- Use version '3.8'
- Include descriptive comments
- Group related environment variables
- Use named volumes
- Include health checks where applicable

### Terraform

- Follow HashiCorp's style guide
- Use meaningful resource names
- Add comments for complex logic
- Use variables for configurable values
- Include outputs for important values

### Documentation

- Use clear, concise language
- Include code examples
- Add screenshots where helpful
- Keep line length reasonable (80-120 chars)
- Use proper Markdown formatting

## Project Structure

Understanding the project layout:

```
n8n-deployment-suite/
├── deploy.sh                    # Main entry point
├── scripts/                     # All automation scripts
│   ├── deploy-*.sh             # Deployment scripts
│   ├── stop-*.sh               # Cleanup scripts
│   ├── setup-tunnel.sh         # Tunnel configuration
│   └── pre-push-check.sh       # Security validation
├── deployments/                 # Environment configs
│   ├── local/                  # Local deployment
│   └── local-with-tunnel/      # Local with tunnel
├── terraform/                   # Infrastructure as Code
│   ├── main.tf                 # Main Terraform config
│   ├── variables.tf            # Variable definitions
│   └── *.tf                    # Other Terraform files
├── docs/                        # Documentation
│   ├── DEPLOYMENT_GUIDE.md     # Detailed instructions
│   ├── QUICK_REFERENCE.md      # Command reference
│   └── *.md                    # Other documentation
└── local-files/                 # Shared files directory
```

### What Goes Where

- **New deployment types** → Add to `deployments/` and create script in `scripts/`
- **Documentation** → Add to `docs/`
- **Infrastructure changes** → Update `terraform/`
- **CI/CD** → Add to `.github/workflows/` (if adding)
- **Examples** → Add `*.example` files alongside actual config files

## Customization Guide

### Adding Environment Variables to n8n

Edit the relevant `docker-compose.yml` file:

```yaml
n8n:
  environment:
    # Existing variables
    - N8N_HOST=${N8N_DOMAIN}
    # Add your new variable
    - YOUR_NEW_VAR=value
```

### Adding New Services

Add to `docker-compose.yml`:

```yaml
services:
  # Existing services
  
  new-service:
    image: service:latest
    container_name: new-service
    restart: unless-stopped
    networks:
      - n8n-network
```

### Adding New Deployment Option

1. Create new deployment config in `deployments/`
2. Create deployment script in `scripts/deploy-your-option.sh`
3. Add to interactive menu in `deploy.sh`
4. Update documentation

## Questions?

- Open an issue with the `question` label
- Join discussions in the GitHub Discussions tab
- Check existing documentation in `docs/`

## Recognition

Contributors will be recognized in:
- GitHub contributors page
- Release notes (for significant contributions)
- Project documentation (for major features)

---

Thank you for contributing! 🎉

Your efforts help make n8n deployment easier for everyone.
