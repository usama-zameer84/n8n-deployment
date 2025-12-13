# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Complete restructure with multiple deployment options
- Interactive deployment manager (`deploy.sh`)
- Local deployment support (with and without tunnel)
- GCP VM deployment with automated tunnel setup
- Comprehensive documentation suite
- Pre-push security validation script
- Environment-specific configuration management

### Changed
- Reorganized project structure for better maintainability
- Moved documentation to `docs/` directory
- Moved scripts to `scripts/` directory
- Separated deployment configurations by environment
- Updated README to GitHub standards

### Security
- Added `.gitignore` for sensitive files
- Added pre-push security checks
- Removed hardcoded secrets
- Environment-based configuration

## [1.0.0] - 2025-12-13

### Added
- Initial release
- Terraform-based GCP deployment
- Cloudflare Tunnel integration
- PostgreSQL database support
- Docker Compose configurations
- Basic documentation

[Unreleased]: https://github.com/yourusername/n8n-deployment-suite/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/yourusername/n8n-deployment-suite/releases/tag/v1.0.0
