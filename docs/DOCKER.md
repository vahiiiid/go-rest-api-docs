# 🐳 Docker Setup Guide

This project supports both **development** and **production** Docker configurations.

## 📋 Overview

The project uses **multi-stage Dockerfile** with two targets:

1. **Development** - Hot-reload with code sync
2. **Production** - Optimized minimal image

## 🔧 Development Setup (Hot-Reload)

### Features
- ✅ **Hot-reload** - Changes reflect instantly
- ✅ **Volume mounting** - Edit code in IDE, see changes in container
- ✅ **Air** - Automatic rebuild on file changes
- ✅ **Internal networking** - Database not exposed to host

### Quick Start

```bash
# Start development environment
docker-compose up --build

# Or using make
make docker-up
```

### What Happens
1. Mounts your local code into `/app` in container
2. Uses Air for hot-reload
3. PostgreSQL accessible only via Docker network name `db`
4. Changes in your IDE automatically trigger rebuild

### Development Architecture

```
┌─────────────────────────────────────┐
│   Your IDE (Local Filesystem)      │
│   Edit: internal/user/handler.go   │
└──────────────┬──────────────────────┘
               │ Volume Mount
               ▼
┌─────────────────────────────────────┐
│   Docker Container (app)            │
│   Air detects change → Rebuild      │
│   → Restart server                  │
└──────────────┬──────────────────────┘
               │ Docker Network
               ▼
┌─────────────────────────────────────┐
│   PostgreSQL Container (db)         │
│   Only accessible via 'db' hostname │
└─────────────────────────────────────┘
```

### Configuration Files

- **Dockerfile** - `target: development` stage
- **docker-compose.yml** - Development config with volumes
- **.air.toml** - Hot-reload configuration

### Excluded from Hot-Reload
- `tmp/` directory (build artifacts)
- `*_test.go` files
- `vendor/` directory
- `api/docs/` directory

## 🚀 Production Setup

### Features
- ✅ **Minimal image** - ~10-15MB final image
- ✅ **No volumes** - Code baked into image
- ✅ **Optimized build** - Multi-stage with stripped binary
- ✅ **Secure** - No development tools
- ✅ **Internal networking** - Database not exposed

### Quick Start

```bash
# Start production environment
docker-compose -f docker-compose.prod.yml up --build

# Or using make
make docker-up-prod
```

### Production Architecture

```
┌─────────────────────────────────────┐
│   Docker Image (Production)         │
│   - Compiled binary only            │
│   - Alpine base (~5MB)              │
│   - No source code                  │
│   - No development tools            │
└──────────────┬──────────────────────┘
               │ Docker Network
               ▼
┌─────────────────────────────────────┐
│   PostgreSQL Container (db)         │
│   Only accessible via 'db' hostname │
└─────────────────────────────────────┘
```

### Configuration Files

- **Dockerfile** - `target: production` stage
- **docker-compose.prod.yml** - Production config without volumes

## 🔀 Key Differences

| Aspect | Development | Production |
|--------|-------------|------------|
| **Dockerfile Stage** | `development` | `production` |
| **Base Image** | golang:1.24-alpine | alpine:latest |
| **Code Location** | Volume mounted | Baked in image |
| **Hot-Reload** | ✅ Yes (Air) | ❌ No |
| **Image Size** | ~800MB | ~15MB |
| **Build Time** | Fast (cached) | Slower (full build) |
| **Security** | Dev tools included | Minimal surface |
| **DB Port** | Not exposed | Not exposed |

## 🌐 Networking

### Internal Communication

Both setups use Docker's internal network:

```yaml
networks:
  go_api_network:
    driver: bridge
```

**App connects to DB using**: `DB_HOST=db` (Docker service name)

**PostgreSQL port**: Only exposed within Docker network, NOT to host

### Why This Matters

✅ **Security**: Database not accessible from host machine  
✅ **Portability**: Works the same in dev/prod/CI  
✅ **Isolation**: Clean separation of concerns  
✅ **Best Practice**: Follows Docker networking patterns  

### Accessing PostgreSQL (if needed)

If you need to access PostgreSQL from host for debugging:

```bash
# Option 1: Exec into container
docker exec -it go_api_db psql -U postgres -d go_api

# Option 2: Temporarily expose port (edit docker-compose.yml)
# Add under db service:
# ports:
#   - "5432:5432"
```

## 📝 Common Commands

### Development

```bash
# Start with logs
docker-compose up

# Start in background
docker-compose up -d

# View logs
docker-compose logs -f app

# Restart app only (after config change)
docker-compose restart app

# Rebuild after dependency change
docker-compose up --build

# Stop everything
docker-compose down

# Stop and remove volumes
docker-compose down -v
```

### Production

```bash
# Start production
docker-compose -f docker-compose.prod.yml up --build

# Start in background
docker-compose -f docker-compose.prod.yml up -d

# View logs
docker-compose -f docker-compose.prod.yml logs -f

# Stop production
docker-compose -f docker-compose.prod.yml down
```

### Makefile Shortcuts

```bash
make docker-up          # Development
make docker-up-prod     # Production
make docker-down        # Stop development
make docker-down-prod   # Stop production
```

## 🛠️ Development Workflow

### 1. Start Environment

```bash
docker-compose up
```

### 2. Edit Code

Open your IDE and edit any Go file:
- `internal/user/handler.go`
- `internal/auth/service.go`
- etc.

### 3. See Changes

Air automatically detects changes and rebuilds:

```
[Air] 2024/01/01 - 12:00:00 main.go has changed
[Air] Building...
[Air] Build finished
[Air] Restarting...
Server starting on :8080
```

### 4. Test API

```bash
curl http://localhost:8080/health
```

Changes are immediately reflected!

## 🔒 Environment Variables

The application uses a **Viper-based configuration system** with updated environment variable names.

### Development

Set in `docker-compose.yml` or use `.env` file:

```bash
# App Configuration
APP_ENVIRONMENT=development
APP_DEBUG=true

# Database Configuration (updated variable names)
DATABASE_HOST=db  # Docker service name
DATABASE_PORT=5432
DATABASE_USER=postgres
DATABASE_PASSWORD=postgres
DATABASE_NAME=grab
DATABASE_SSLMODE=disable

# JWT Configuration
JWT_SECRET=dev-secret-for-development-only
JWT_TTLHOURS=24

# Server Configuration
SERVER_PORT=8080
```

### Production

Set in `docker-compose.prod.yml` or use `.env` file:

```bash
# App Configuration
APP_ENVIRONMENT=production
APP_DEBUG=false

# Database Configuration
DATABASE_HOST=db  # Docker service name
DATABASE_PASSWORD=STRONG_DB_PASSWORD
DATABASE_SSLMODE=require

# JWT Configuration (must be 32+ characters)
JWT_SECRET=this-is-a-very-strong-production-jwt-secret-32-chars-minimum
JWT_TTLHOURS=1

# Rate Limiting (optional)
RATELIMIT_ENABLED=true
RATELIMIT_REQUESTS=60
RATELIMIT_WINDOW=1m
```

⚠️ **Important Changes:**
- Variable names changed: `DB_*` → `DATABASE_*`
- JWT secret must be 32+ characters in production
- SSL mode enforced in production
- See [Configuration Guide](CONFIGURATION.md) for complete reference

⚠️ **Never commit production secrets!**

## 🐛 Troubleshooting

### Hot-Reload Not Working

```bash
# Check Air is running
docker-compose logs app | grep Air

# Verify volume mount
docker-compose exec app ls -la /app

# Restart the service
docker-compose restart app
```

### Database Connection Error

```bash
# Check DB is running
docker-compose ps

# Check DB logs
docker-compose logs db

# Verify DATABASE_HOST=db in environment  
docker-compose exec app env | grep DATABASE_HOST
```

### Permission Issues

```bash
# macOS/Linux: Fix tmp/ directory permissions
sudo chown -R $USER:$USER tmp/

# Or remove and recreate
rm -rf tmp/
```

### Build Issues

```bash
# Clean rebuild
docker-compose down
docker-compose build --no-cache
docker-compose up
```

## 📊 Performance Tips

### Development

- Use `.dockerignore` to exclude unnecessary files
- Keep `tmp/` in .gitignore
- Don't mount large directories unnecessarily

### Production

- Use multi-stage build (already configured)
- Strip debug symbols: `-ldflags="-w -s"`
- Use minimal base image (alpine)
- Don't include development dependencies

## 🎯 Best Practices

### ✅ Do

- Use Docker networks for service communication
- Keep database internal (don't expose ports)
- Use environment variables for config
- Separate dev and prod configs
- Use `.dockerignore` file
- Keep images small

### ❌ Don't

- Hardcode database connection strings
- Expose database ports to host in production
- Mount volumes in production
- Include source code in production images
- Commit secrets to git

## 📚 Additional Resources

- [Air (Hot-reload)](https://github.com/air-verse/air)
- [Docker Multi-stage Builds](https://docs.docker.com/build/building/multi-stage/)
- [Docker Compose](https://docs.docker.com/compose/)
- [Docker Networking](https://docs.docker.com/network/)

## 📌 Note on Air Version

This project uses **Air v1.52.3** (pinned version) instead of `@latest` because:
- Air v1.63.0 has a bug requiring non-existent Go 1.25
- v1.52.3 is stable and fully compatible with Go 1.24
- All hot-reload features work perfectly

When Air fixes the issue, you can update to `@latest` in the Dockerfile.

---

**Happy Dockering!** 🐳

