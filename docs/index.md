<div align="center">

<img src="images/logo.png" alt="GRAB Logo" width="300">

<h2><strong>G</strong>o <strong>R</strong>EST <strong>A</strong>PI <strong>B</strong>oilerplate</h2>

<p><em>Grab it and Go &mdash; a clean, production-ready REST API starter kit in Go with JWT, PostgreSQL, Docker, and Swagger.</em></p>

<p>
<img src="https://img.shields.io/badge/version-1.1.0-blue.svg" alt="Version">
<img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License">
<img src="https://img.shields.io/badge/Go-1.24+-00ADD8?logo=go" alt="Go Version">
</p>

<p>
<a href="https://github.com/vahiiiid/go-rest-api-boilerplate">🚀 Main Repository</a> | 
<a href="https://github.com/vahiiiid/go-rest-api-boilerplate/releases/tag/v1.1.0">📋 Latest Release</a> | 
<a href="https://github.com/vahiiiid/go-rest-api-boilerplate/issues">🐛 Report Issues</a>
</p>

</div>

---

## 🎯 Why GRAB?

**Building a REST API in Go shouldn't take days of setup.** GRAB gives you a production-ready foundation so you can focus on building features, not infrastructure.

### The Problem We Solve

- 🔧 Setting up project structure and deciding on architecture ([see current structure](DEVELOPMENT_GUIDE.md#directory-structure))
- 🔐 Implementing authentication and security
- 🐳 Configuring Docker, hot-reload, and development environment
- 📚 Setting up API documentation and testing tools
- 🗄️ Configuring database, migrations, and ORM
- ✅ Writing tests and CI/CD pipelines

### The GRAB Solution

**One command. Two minutes. Production-ready.**

```bash
make quick-start
```

That's it. You get a fully configured, battle-tested REST API with:

- ✅ **Clean Architecture** - Layered structure that scales
- ✅ **JWT Authentication** - Secure, ready to use
- ✅ **Hot-Reload Development** - See changes in 2 seconds
- ✅ **Database Migrations** - Version-controlled schema
- ✅ **Interactive API Docs** - Swagger UI out of the box
- ✅ **Automated Tests** - Unit and integration tests
- ✅ **Docker-First** - Consistent environments
- ✅ **Production Optimized** - Multi-stage builds, security best practices

---

## ✨ Features

<div class="grid cards" markdown>

- :material-shield-check: **JWT Authentication**
  
    OAuth 2.0 BCP compliant with refresh token rotation, automatic reuse detection, and secure token management

- :material-account-group: **User Management**
  
    Complete CRUD operations with validation and error handling

- :material-shield-account: **Role-Based Access Control**
  
    Many-to-many role system with JWT integration, secure admin CLI, and middleware-based endpoint protection

- :material-database: **PostgreSQL + GORM**
  
    Robust database with powerful ORM and automated migrations

- :material-docker: **Docker Development**
  
    Hot-reload with Air (~2 sec feedback), volume mounting for live code sync

- :material-rocket-launch: **Production Ready**
  
    Optimized multi-stage Docker builds, minimal Alpine images, graceful shutdown

- :material-api: **Swagger/OpenAPI**
  
    Interactive API documentation with "Try it out" feature

- :material-database-sync: **Database Migrations**
  
    Version-controlled schema changes with golang-migrate

- :material-test-tube: **Automated Testing**
  
    Unit & integration tests with 75%+ coverage

- :material-github: **GitHub Actions CI**
  
    Automated linting, testing, and code quality checks

- :material-console: **Make Commands**
  
    Simplified workflow automation with auto-detection (Docker/host)

- :material-postage-stamp: **Postman Collection**
  
    Pre-configured API tests with example requests

- :material-layers: **Clean Architecture**
  
    Layered, maintainable structure (Handler → Service → Repository)
    
    📁 **Directory Structure**: See the - [Directory Structure](DEVELOPMENT_GUIDE.md#directory-structure) for a high-level overview of the current layout and main directories.

- :material-security: **Security Best Practices**
  
    Bcrypt hashing, input validation, SQL injection protection

- :material-web: **CORS Support**
  
    Configurable cross-origin requests for frontend integration

- :material-code-braces: **Code Quality**
  
    golangci-lint configured with best practices

- :material-chart-line: **Structured Logging**
  
    JSON logging with request tracking, performance metrics, and environment-aware configuration

- :material-cog: **Configuration Management**
  
    Environment-based configuration with YAML support and validation

</div>

---

## 🚀 Perfect For

<div class="grid cards" markdown>

- :material-rocket-launch: **Starting New Projects**
  
    Skip the setup headache and start building features immediately

- :material-school: **Learning Go Web Development**
  
    Production-quality examples and best practices to learn from

- :material-domain: **Building Scalable APIs**
  
    Architecture that grows with your application

- :material-account-group: **Team Projects**
  
    Consistent structure and standards that everyone can follow

- :material-speedometer: **Rapid Prototyping**
  
    Get your MVP running in minutes, not days

- :material-briefcase: **Enterprise Applications**
  
    Battle-tested patterns and security best practices

</div>

---

## 🎬 Quick Start

Get your API running in **under 2 minutes**:

```bash
# Clone the repository
git clone https://github.com/vahiiiid/go-rest-api-boilerplate.git
cd go-rest-api-boilerplate

# One command to rule them all
make quick-start
```

**🎉 Done!** Your API is now running at:

- **API Base URL:** http://localhost:8080/api/v1
- **Swagger UI:** http://localhost:8080/swagger/index.html
- **Health Check:** http://localhost:8080/health

**✨ New in v1.1.0:** Request logging is automatically enabled! Check the logs to see structured JSON output for each request.

**➡️ [Full Setup Guide](SETUP.md)** for more options (manual setup, production deployment)

---

## 📖 What's Next?

<div class="grid cards" markdown>

- :material-book-open-page-variant: **[Setup Guide](SETUP.md)**
  
    Quick start, Docker development, manual setup, and production deployment

- :material-code-braces: **[Development Guide](DEVELOPMENT_GUIDE.md)**
  
    Learn the architecture and how to build your own features

- :material-checkbox-marked-circle: **[TODO List Example](TODO_EXAMPLE.md)**
  
    Complete step-by-step tutorial showing how to add new endpoints

- :material-test-tube: **[Testing Guide](TESTING.md)**
  
    How to write and run tests for your API

- :material-docker: **[Docker Guide](DOCKER.md)**
  
    Container setup, hot-reload, and production deployment

- :material-chart-line: **[Logging & Monitoring](LOGGING.md)**
  
    Structured logging, configuration, and production monitoring setup

- :material-api: **[Swagger Guide](SWAGGER.md)**
  
    API documentation generation and usage

- :material-flash: **[Quick Reference](QUICK_REFERENCE.md)**
  
    Command cheat sheet and common tasks

- :material-sitemap: **[Project Summary](PROJECT_SUMMARY.md)**
  
    Architecture overview and design patterns

</div>

---

## 🏗️ Architecture

GRAB follows **clean architecture** principles with clear separation of concerns:

```
┌─────────────────────────────────────┐
│         Handler Layer               │  ← HTTP handlers, request/response
│   (internal/user/handler.go)        │     validation, error handling
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│         Service Layer               │  ← Business logic, orchestration
│   (internal/user/service.go)        │     transactions, domain rules
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│       Repository Layer              │  ← Data access, CRUD operations
│  (internal/user/repository.go)      │     database queries
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│         Database (PostgreSQL)       │  ← Data persistence
└─────────────────────────────────────┘
```

### Key Principles

- ✅ **Separation of Concerns** - Each layer has a single responsibility
- ✅ **Dependency Injection** - Loose coupling between layers
- ✅ **Testability** - Easy to mock and test each layer
- ✅ **Maintainability** - Clear structure, easy to navigate ([see structure](DEVELOPMENT_GUIDE.md#directory-structure))
- ✅ **Scalability** - Easy to extend with new features

---

## 🤝 Contributing

Contributions are welcome! Please read our [contributing guidelines](https://github.com/vahiiiid/go-rest-api-boilerplate/blob/main/CONTRIBUTING.md) before submitting pull requests.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/vahiiiid/go-rest-api-boilerplate/blob/main/LICENSE) file for details.

---

<div align="center">

<p><strong>Made with ❤️ for the Go community</strong></p>

<p><a href="https://github.com/vahiiiid/go-rest-api-boilerplate">⭐ Star this repo</a> if you find it useful!</p>

</div>