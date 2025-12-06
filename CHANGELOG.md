# Documentation Changelog

All notable changes to the Go REST API Boilerplate documentation will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

**Note**: This changelog tracks documentation changes. For API/code changes, see the [main repository changelog](https://github.com/vahiiiid/go-rest-api-boilerplate/blob/main/CHANGELOG.md).

## [2.0.0] - 2025-12-06

### Added
- ✨ **RBAC Documentation** (`docs/RBAC.md`) - Comprehensive Role-Based Access Control guide
  - Many-to-many architecture explanation
  - Admin CLI usage and security
  - Middleware and context helpers
  - JWT integration details
  - API examples and troubleshooting
  
- ✨ **Authentication Updates** - Refresh token system documentation
  - OAuth 2.0 BCP compliance details
  - Token rotation flow diagrams
  - Reuse detection scenarios
  - Token family tracking explanation
  - Security architecture
  
- ✨ **Health Checks Guide** (`docs/HEALTH_CHECKS.md`) - Production-grade health check documentation
  - Three-endpoint system (/health, /health/live, /health/ready)
  - Kubernetes integration examples
  - Docker Compose configuration
  - Load balancer setup
  - Monitoring integration
  - RFC-compliant response format
  
- ✨ **API Response Format Guide** - Standardized envelope format documentation
- ✨ **Error Handling Guide** - Structured error codes and consistent responses
- ✨ **Graceful Shutdown Guide** - Zero-downtime deployment strategies
- ✨ **Context Helpers Reference** - RBAC helper functions (HasRole, IsAdmin, GetRoles)

### Changed
- Updated all documentation to reflect v2.0.0 features
- Updated code examples with new API response format
- Enhanced security best practices sections
- Improved quick reference with new endpoints
- Updated architecture diagrams

### Fixed
- Corrected version references throughout documentation
- Updated Postman collection screenshots
- Updated Swagger UI screenshots
- Fixed outdated API endpoint examples

---

## [1.2.0] - 2025-01-15

### Added
- ✨ **Rate Limiting Documentation** - Comprehensive guide for the new rate limiting middleware
  - Complete configuration guide with YAML and environment variables
  - Token bucket algorithm explanation with examples
  - HTTP headers documentation and response formats
  - Implementation details and middleware integration
  - Testing strategies and troubleshooting guide
  - Best practices for production, development, and testing
  - Advanced configuration options and security considerations
  - Performance impact analysis and migration guide
  - Location: `docs/RATE_LIMITING.md`
  - Added to Infrastructure section in navigation

---

## [1.0.0] - 2025-01-05

### 🎉 Initial Documentation Release

Complete documentation for GRAB v1.0.0 using MkDocs with Material theme.

### Added

#### Documentation Site
- **MkDocs Setup** - Material theme with dark mode support
- **GitHub Pages** - Automated deployment via GitHub Actions
- **Search Functionality** - Full-text search across all docs
- **Responsive Design** - Mobile-friendly navigation
- **Custom Styling** - Branded colors and logo

#### Core Documentation
- **Home Page** (index.md)
  - Project overview with features
  - Quick start guide
  - Architecture diagram
  - API endpoints table
  - Swagger UI screenshot
  - Postman collection screenshot
  
- **Setup Guide** (SETUP.md)
  - Prerequisites and installation
  - Local development setup
  - Docker setup
  - Environment configuration
  - Troubleshooting

- **Development Guide** (DEVELOPMENT_GUIDE.md)
  - Architecture overview
  - Layer-by-layer explanation
  - Code organization
  - Best practices
  - Common patterns
  - Testing strategies

- **Complete Example** (TODO_EXAMPLE.md)
  - Step-by-step TODO list implementation
  - All layers with complete code
  - Migration files
  - Testing commands
  - 12-step tutorial

- **Docker Guide** (DOCKER.md)
  - Development with hot-reload
  - Production deployment
  - Docker Compose configuration
  - Volume management
  - Network configuration

- **Swagger Guide** (SWAGGER.md)
  - Swagger generation
  - API documentation
  - Annotations guide
  - Troubleshooting

- **Quick Reference** (QUICK_REFERENCE.md)
  - Command cheat sheet
  - Make commands
  - Docker commands
  - curl examples
  - Postman collection guide

- **Project Summary** (PROJECT_SUMMARY.md)
  - High-level architecture
  - Technology stack
  - Design decisions
  - Feature overview

#### Visual Assets
- **Logo** - SVG and PNG formats
- **Swagger UI Screenshot** - Interactive API docs preview
- **Postman Collection Screenshot** - Testing tools preview
- **Custom CSS** - Larger logo in navigation

#### Setup & Tooling
- **setup-local.sh** - Automated local setup script
- **Virtual Environment** - Python venv for MkDocs
- **Requirements.txt** - Python dependencies
- **GitHub Actions** - Auto-deployment workflow

#### Navigation Structure
```
📖 Home
🚀 Getting Started
   - Setup Guide
   - Quick Reference
💻 Development
   - Development Guide
   - Project Summary
📝 Complete Example
🏗️ Infrastructure
   - Docker Guide
   - Swagger API Docs
   - Documentation Setup
```

### Features

#### Content Features
- ✅ Comprehensive guides for all aspects
- ✅ Code examples with syntax highlighting
- ✅ Step-by-step tutorials
- ✅ Visual screenshots
- ✅ curl command examples
- ✅ Troubleshooting sections
- ✅ Best practices
- ✅ Architecture diagrams

#### Technical Features
- ✅ Material Design theme
- ✅ Dark/Light mode toggle
- ✅ Instant page loading
- ✅ Search with suggestions
- ✅ Code copy buttons
- ✅ Table of contents
- ✅ Edit on GitHub links
- ✅ Responsive tables
- ✅ Emoji support
- ✅ Mermaid diagrams support

#### User Experience
- ✅ Clear navigation
- ✅ Breadcrumbs
- ✅ Back to top button
- ✅ Keyboard shortcuts
- ✅ Print-friendly
- ✅ SEO optimized

### Technical Stack
- **Generator**: MkDocs 1.5+
- **Theme**: Material for MkDocs 9.5+
- **Deployment**: GitHub Pages
- **CI/CD**: GitHub Actions
- **Markdown Extensions**: 
  - Admonitions
  - Code highlighting
  - Tables
  - Emoji
  - Mermaid diagrams

### File Structure
```
go-rest-api-docs/
├── mkdocs.yml              # MkDocs configuration
├── requirements.txt        # Python dependencies
├── setup-local.sh         # Local setup script
├── docs/
│   ├── index.md           # Home page
│   ├── SETUP.md
│   ├── DEVELOPMENT_GUIDE.md
│   ├── TODO_EXAMPLE.md
│   ├── DOCKER.md
│   ├── SWAGGER.md
│   ├── QUICK_REFERENCE.md
│   ├── PROJECT_SUMMARY.md
│   ├── DOCS_SETUP.md
│   ├── images/            # Screenshots and assets
│   └── stylesheets/       # Custom CSS
└── .github/
    └── workflows/
        └── docs.yml       # Deployment workflow
```

### Documentation Standards
- Clear, concise language
- Code examples for all concepts
- Consistent formatting
- Proper heading hierarchy
- Cross-references between pages
- External links to official docs

### Notes
- Documentation is versioned to match main repo
- All pages are tested and verified
- Screenshots are up-to-date with v1.0.0
- Search index is automatically generated
- Site deploys automatically on push to main

---

## Version History

- **1.2.0** (2025-01-15) - Rate limiting documentation
- **1.0.0** (2025-01-05) - Initial documentation release

---

## Links

- [Documentation Site](https://vahiiiid.github.io/go-rest-api-docs/)
- [Main Repository](https://github.com/vahiiiid/go-rest-api-boilerplate)
- [Docs Repository](https://github.com/vahiiiid/go-rest-api-docs)
- [Report Documentation Issues](https://github.com/vahiiiid/go-rest-api-docs/issues)

---

**Legend:**
- 📝 Documentation update
- ✨ New content
- 🐛 Fix typos/errors
- 🎨 Improve formatting
- 🔧 Configuration change
- 📸 Update screenshots
- 🔗 Fix/update links
