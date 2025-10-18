# Configuration Guide

Complete guide to configuring the Go REST API Boilerplate (GRAB) with the Viper-based configuration system.

---

## 📋 Overview

The application uses a **layered configuration system** powered by [Viper](https://github.com/spf13/viper) that supports multiple configuration sources with clear precedence rules.

### Configuration Precedence (Highest to Lowest)

```
1. Environment Variables (.env file) 
   ↓ (overrides)
2. Environment-specific Config Files (config.{environment}.yaml)
   ↓ (overrides)  
3. Base Config File (config.yaml)
   ↓ (overrides)
4. Default Values (built into application)
```

This means environment variables **always win**, followed by environment-specific config files, then the base config file, and finally built-in defaults.

---

## 🗂️ Configuration Files

### Base Configuration (`configs/config.yaml`)

The main configuration file with all available options and documentation:

```yaml
# ===========================================
# Go REST API Boilerplate - Base Configuration
# ===========================================

app:
  name: "GRAB API"                  # Application name
  environment: "development"        # Environment: development|staging|production
  debug: true                       # Enable debug mode

database:
  host: "db"                        # Database host
  port: 5432                        # Database port  
  user: "postgres"                  # Database user
  password: ""                      # Database password (set via env var)
  name: "grab"                      # Database name
  sslmode: "disable"                # SSL mode: disable|require|verify-ca|verify-full

jwt:
  secret: ""                        # JWT secret (required, set via env var)
  ttlhours: 24                      # JWT token TTL in hours

server:
  port: "8080"                      # Server port
  readtimeout: 10                   # Read timeout in seconds
  writetimeout: 10                  # Write timeout in seconds

logging:
  level: "info"                     # Log level: debug|info|warn|error

ratelimit:
  enabled: false                    # Enable rate limiting
  requests: 100                     # Max requests per window
  window: "1m"                      # Time window (e.g., "1m", "1h", "30s")
```

### Environment-Specific Configuration

The application automatically loads environment-specific config files based on the `APP_ENVIRONMENT` variable:

#### Development (`configs/config.development.yaml`)

```yaml
app:
  name: "GRAB API (development)"
  environment: "development"
  debug: true

database:
  host: "db"
  password: "postgres"              # Default for development
  sslmode: "disable"                # SSL disabled for convenience

jwt:
  secret: "change-me"               # Default for development
```

#### Production (`configs/config.production.yaml`)

```yaml
app:
  name: "GRAB API"
  environment: "production"
  debug: false                      # Disable debug in production

database:
  password: ""                      # Must be set via DATABASE_PASSWORD
  sslmode: "require"                # SSL required in production

jwt:
  secret: ""                        # Must be set via JWT_SECRET (min 32 chars)
```

#### Staging (`configs/config.staging.yaml`)

```yaml
app:
  name: "GRAB API (staging)"
  environment: "staging"
  debug: false

database:
  sslmode: "require"                # SSL required in staging

jwt:
  secret: ""                        # Must be set via JWT_SECRET
```

---

## 🌍 Environment Variables

### Complete Reference

All configuration values can be overridden with environment variables using the format: `SECTION_KEY=value`.

#### Application Configuration

| Variable | Default | Description | Accepted Values |
|----------|---------|-------------|-----------------|
| `APP_NAME` | `"GRAB API"` | Application name | Any string |
| `APP_ENVIRONMENT` | `"development"` | Runtime environment | `development`, `staging`, `production` |
| `APP_DEBUG` | `true` | Enable debug mode | `true`, `false` |

#### Database Configuration

| Variable | Default | Description | Accepted Values |
|----------|---------|-------------|-----------------|
| `DATABASE_HOST` | `"db"` | Database host | Hostname or IP |
| `DATABASE_PORT` | `5432` | Database port | 1-65535 |
| `DATABASE_USER` | `"postgres"` | Database user | Any string |
| `DATABASE_PASSWORD` | `""` | Database password | Any string (required in production) |
| `DATABASE_NAME` | `"grab"` | Database name | Valid PostgreSQL database name |
| `DATABASE_SSLMODE` | `"disable"` | SSL mode | `disable`, `require`, `verify-ca`, `verify-full` |

#### JWT Configuration

| Variable | Default | Description | Accepted Values |
|----------|---------|-------------|-----------------|
| `JWT_SECRET` | `""` | JWT signing secret | Any string (min 32 chars in production) |
| `JWT_TTLHOURS` | `24` | Token TTL in hours | Positive integer |

#### Server Configuration

| Variable | Default | Description | Accepted Values |
|----------|---------|-------------|-----------------|
| `SERVER_PORT` | `"8080"` | Server port | `"1"` to `"65535"` |
| `SERVER_READTIMEOUT` | `10` | Read timeout (seconds) | Positive integer |
| `SERVER_WRITETIMEOUT` | `10` | Write timeout (seconds) | Positive integer |

#### Logging Configuration

| Variable | Default | Description | Accepted Values |
|----------|---------|-------------|-----------------|
| `LOGGING_LEVEL` | `"info"` | Log level | `debug`, `info`, `warn`, `error` |

#### Rate Limiting Configuration

| Variable | Default | Description | Accepted Values |
|----------|---------|-------------|-----------------|
| `RATELIMIT_ENABLED` | `false` | Enable rate limiting | `true`, `false` |
| `RATELIMIT_REQUESTS` | `100` | Max requests per window | Positive integer |
| `RATELIMIT_WINDOW` | `"1m"` | Time window | Go duration format (`1s`, `1m`, `1h`) |

---

## 🔧 Configuration Examples

### Example 1: Development Setup

Create `.env` file:

```env
# Development environment
APP_ENVIRONMENT=development
APP_DEBUG=true

# Database (Docker setup)
DATABASE_HOST=db
DATABASE_PASSWORD=postgres

# JWT (development only - use stronger secret in production)
JWT_SECRET=dev-secret-change-in-production

# Logging
LOGGING_LEVEL=debug
```

### Example 2: Production Setup

Create `.env` file:

```env
# Production environment
APP_ENVIRONMENT=production
APP_DEBUG=false

# Database (production values)
DATABASE_HOST=prod-db.example.com
DATABASE_PASSWORD=super-secure-password
DATABASE_SSLMODE=require

# JWT (strong production secret)
JWT_SECRET=this-is-a-very-strong-production-jwt-secret-that-is-at-least-32-characters-long
JWT_TTLHOURS=1

# Server
SERVER_PORT=8080
SERVER_READTIMEOUT=30
SERVER_WRITETIMEOUT=30

# Logging
LOGGING_LEVEL=warn

# Rate Limiting
RATELIMIT_ENABLED=true
RATELIMIT_REQUESTS=60
RATELIMIT_WINDOW=1m
```

### Example 3: Docker Compose Override

```yaml
# docker-compose.override.yml
version: '3.8'

services:
  app:
    environment:
      - APP_ENVIRONMENT=staging
      - DATABASE_HOST=staging-db
      - JWT_SECRET=staging-jwt-secret-32-chars-min
      - LOGGING_LEVEL=info
      - RATELIMIT_ENABLED=true
```

---

## ⚡ Quick Setup Commands

### Copy and Configure

```bash
# Copy example file
cp .env.example .env

# Edit with your values
nano .env
```

### Verify Configuration

```bash
# Check if app starts correctly
make up

# Check health endpoint
curl http://localhost:8080/health

# View configuration (debug info)
docker logs go-rest-api-boilerplate_app_1 | grep -i config
```

---

## 🔒 Security Best Practices

### Production Configuration

1. **Always use environment variables for secrets**:
   ```bash
   # ✅ Good - via environment
   JWT_SECRET=strong-production-secret
   DATABASE_PASSWORD=secure-db-password
   
   # ❌ Bad - hardcoded in config file
   jwt.secret: "hardcoded-secret"
   ```

2. **Use strong JWT secrets (32+ characters)**:
   ```bash
   # ✅ Good - 32+ characters
   JWT_SECRET=this-is-a-very-strong-jwt-secret-for-production-use-only
   
   # ❌ Bad - too short
   JWT_SECRET=secret123
   ```

3. **Enable SSL for database connections**:
   ```bash
   # ✅ Good - SSL required
   DATABASE_SSLMODE=require
   
   # ❌ Bad - SSL disabled
   DATABASE_SSLMODE=disable
   ```

4. **Use appropriate log levels**:
   ```bash
   # ✅ Good - production logging
   LOGGING_LEVEL=warn
   
   # ❌ Bad - too verbose in production
   LOGGING_LEVEL=debug
   ```

### Environment Isolation

- **Development**: Use `config.development.yaml` + `.env`
- **Staging**: Use `config.staging.yaml` + environment variables
- **Production**: Use `config.production.yaml` + secure environment variables

---

## 🐛 Troubleshooting

### Common Configuration Issues

#### 1. Configuration Not Loading

**Problem**: Changes to config files not being applied.

**Solution**:
```bash
# Check which config file is being loaded
APP_ENVIRONMENT=development go run cmd/server/main.go

# Verify file exists
ls -la configs/config.development.yaml

# Check environment variable
echo $APP_ENVIRONMENT
```

#### 2. Environment Variables Not Working

**Problem**: Environment variables not overriding config files.

**Solution**:
```bash
# Check variable format (must use underscores)
DATABASE_HOST=localhost  # ✅ Correct
database.host=localhost  # ❌ Wrong

# Check if .env file is loaded
cat .env | grep DATABASE_HOST

# Restart application after changes
make restart
```

#### 3. Validation Errors

**Problem**: Application fails to start with validation errors.

**Solutions**:

**JWT Secret Missing**:
```bash
# Error: JWT secret is required
JWT_SECRET=your-secret-here

# Production: minimum 32 characters required
JWT_SECRET=this-is-a-32-character-secret-key
```

**Database Password Missing in Production**:
```bash
# Error: database.password is required in production
DATABASE_PASSWORD=secure-password
```

**Invalid SSL Mode in Production**:
```bash
# Error: SSL mode cannot be 'disable' in production
DATABASE_SSLMODE=require
```

#### 4. Port Already in Use

**Problem**: Server port is already occupied.

**Solution**:
```bash
# Check what's using the port
lsof -i :8080

# Use different port
SERVER_PORT=8081

# Or kill the process
lsof -ti:8080 | xargs kill -9
```

---

## 📚 Advanced Configuration

### Custom Configuration Loading

For advanced use cases, you can load configuration programmatically:

```go
package main

import (
    "github.com/vahiiiid/go-rest-api-boilerplate/internal/config"
)

func main() {
    // Load from specific file
    cfg, err := config.LoadConfig("/path/to/custom-config.yaml")
    if err != nil {
        log.Fatal(err)
    }
    
    // Load with environment detection
    cfg, err = config.LoadConfig("")  // Uses APP_ENVIRONMENT
    if err != nil {
        log.Fatal(err)
    }
}
```

### Testing Configuration

```go
// Use test helper for consistent test config
func TestMyFunction(t *testing.T) {
    cfg := config.NewTestConfig()
    // cfg is now pre-configured for testing
}
```

---

## 🔗 Related Documentation

- [Setup Guide](SETUP.md) - Initial configuration setup
- [Development Guide](DEVELOPMENT_GUIDE.md) - Using config in code
- [Docker Guide](DOCKER.md) - Docker-specific configuration
- [Quick Reference](QUICK_REFERENCE.md) - Configuration commands