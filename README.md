# 📚 Go REST API Boilerplate - Documentation

Official documentation repository for the [Go REST API Boilerplate (GRAB)](https://github.com/vahiiiid/go-rest-api-boilerplate) project.

[![Documentation](https://img.shields.io/badge/docs-latest-brightgreen.svg)](https://vahiiiid.github.io/go-rest-api-docs/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## 🌐 View Documentation

**🔗 Live Site:** https://vahiiiid.github.io/go-rest-api-docs/

Complete, searchable documentation with dark mode, mobile-friendly navigation, and instant search.

**Current Version**: v2.0.0 - Matches [GRAB v2.0.0](https://github.com/vahiiiid/go-rest-api-boilerplate/releases/tag/v2.0.0)

## 📖 Contents

This documentation covers:

- **🚀 Getting Started** - Setup guides and quick reference
- **💻 Development** - Building features with complete TODO example
- **🏗️ Architecture** - Project structure and design patterns
- **🐳 Docker** - Container deployment and hot-reload setup
- **📚 API Reference** - Swagger documentation guide
- **🗄️ Database** - Migration management

## 🛠️ Local Development

### Prerequisites

- Python 3.x
- pip

### Quick Start

#### Automated Setup (Easiest)

```bash
# Run the setup script
./setup-local.sh

# This will:
# - Create a virtual environment
# - Install all dependencies
# - Provide next steps

# IMPORTANT: Activate the virtual environment first!
source venv/bin/activate

# Then start the server
mkdocs serve

# Your prompt will show (venv) when activated
```

#### Option 1: Using Virtual Environment (Recommended for macOS)

```bash
# Create virtual environment
python3 -m venv venv

# Activate virtual environment
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Serve locally with hot-reload
mkdocs serve

# Visit http://127.0.0.1:8000

# When done, deactivate
deactivate
```

#### Option 2: Using pipx (Alternative for macOS)

```bash
# Install pipx (if not already installed)
brew install pipx

# Install mkdocs with pipx
pipx install mkdocs
pipx inject mkdocs mkdocs-material
pipx inject mkdocs mkdocs-minify-plugin

# Serve locally
mkdocs serve
```

#### Option 3: System-wide (Linux/Windows)

```bash
# Install dependencies
pip install -r requirements.txt

# Serve locally with hot-reload
mkdocs serve

# Visit http://127.0.0.1:8000
```

### Building

```bash
# Build static site
mkdocs build

# Build with strict mode (recommended before committing)
mkdocs build --strict
```

> **Note for macOS users:** macOS uses externally-managed Python environments. We recommend using a virtual environment (Option 1) or pipx (Option 2) to avoid conflicts with system Python packages.

## 📁 Repository Structure

```
go-rest-api-docs/
├── mkdocs.yml              # MkDocs configuration
├── requirements.txt        # Python dependencies
├── setup-local.sh          # Automated setup script
├── docs/                   # Documentation content
│   ├── README.md          # Documentation home
│   ├── SETUP.md           # Setup guide
│   ├── DEVELOPMENT_GUIDE.md  # Development guide with TODO example
│   ├── DOCKER.md          # Docker guide
│   ├── SWAGGER.md         # API documentation guide
│   ├── QUICK_REFERENCE.md # Quick reference
│   ├── PROJECT_SUMMARY.md # Architecture overview
│   ├── DOCS_SETUP.md      # Documentation setup guide
│   └── images/            # Screenshots and diagrams
├── assets/                 # Logo and assets
│   └── logo.png
├── .github/
│   └── workflows/
│       └── docs.yml       # Deployment workflow
└── README.md              # This file
```

## 🤝 Contributing

Contributions to the documentation are welcome! Please:

1. **Fork** this repository
2. **Create a branch** for your changes
3. **Make your edits** to the `.md` files in `docs/`
4. **Test locally** with `mkdocs serve`
5. **Submit a pull request**

### Documentation Guidelines

- **Use clear, concise language** - Write for developers of all levels
- **Include code examples** - Show, don't just tell
- **Test all commands** - Ensure examples work
- **Add screenshots** - Visual aids help understanding
- **Update navigation** - Add new pages to `mkdocs.yml`
- **Check links** - Verify all internal and external links work

### Style Guide

- Use H2 (`##`) for major sections
- Use H3 (`###`) for subsections
- Use code blocks with language tags for syntax highlighting
- Use admonitions for tips, warnings, and notes:

```markdown
!!! tip "Pro Tip"
    This is a helpful tip!

!!! warning
    This is important to know!
```

## 🚀 Deployment

Documentation is automatically deployed to GitHub Pages when changes are pushed to the `main` branch.

### Deployment Workflow

1. Push changes to `main` branch
2. GitHub Actions triggers automatically
3. MkDocs builds the static site
4. Site deploys to `gh-pages` branch
5. GitHub Pages serves the updated site

Deployment typically takes 2-3 minutes.

### Manual Deployment

If needed, you can deploy manually:

```bash
mkdocs gh-deploy --force
```

## 🔗 Links

- **Main Repository:** https://github.com/vahiiiid/go-rest-api-boilerplate
- **Documentation Site:** https://vahiiiid.github.io/go-rest-api-docs/
- **Report Issues:** https://github.com/vahiiiid/go-rest-api-docs/issues
- **Code Issues:** https://github.com/vahiiiid/go-rest-api-boilerplate/issues

## 📋 Changelog

See [CHANGELOG.md](CHANGELOG.md) for documentation changes.

For API/code changes, see the [main repository changelog](https://github.com/vahiiiid/go-rest-api-boilerplate/blob/main/CHANGELOG.md).

## 📄 License

MIT License - same as the main project.

Copyright (c) 2025 vahiiiid

---

**Built with [MkDocs](https://www.mkdocs.org/) and [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/)**