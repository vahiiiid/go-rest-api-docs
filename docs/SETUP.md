# Setup Guide

Complete setup instructions for the Go REST API Boilerplate.

## Prerequisites

### Required
- **Go 1.23+** ([Download](https://golang.org/dl/))
- **Docker & Docker Compose** ([Download](https://www.docker.com/products/docker-desktop))

### Optional (for local development without Docker)
- **PostgreSQL 13+** ([Download](https://www.postgresql.org/download/))
- **Make** (usually pre-installed on Unix systems)

## Quick Start (Recommended)

The fastest way to get started is using our automated setup script:

```bash
# 1. Clone the repository
git clone https://github.com/vahiiiid/go-rest-api-boilerplate.git
cd go-rest-api-boilerplate

# 2. Run the quick start script
./scripts/quick-start.sh
# or
make quick-start
```

This script will automatically:
- ✅ Install development tools (swag, golangci-lint, migrate, air)
- ✅ Verify all prerequisites and dependencies
- ✅ Create `.env` file from template
- ✅ Generate Swagger documentation
- ✅ Start all services with docker-compose
- ✅ Display access points

✅ That's it! The API is now running at http://localhost:8080

### Manual Quick Start

If you prefer manual steps:

```bash
# 1. Install development tools
make install-tools
# or
./scripts/install-tools.sh

# 2. Copy environment file
cp .env.example .env

# 3. Generate Swagger docs
make swag
# or
./scripts/init-swagger.sh

# 4. Start everything with Docker
docker-compose up --build
```

## Detailed Setup

### 1. Environment Configuration

Copy `.env.example` to `.env`:
```bash
cp .env.example .env
```

**Important**: Change the `JWT_SECRET` in production:
```bash
# Generate a secure random secret
openssl rand -hex 32
```

### 2. Option A: Docker Setup (Recommended)

Start the application with PostgreSQL:
```bash
docker-compose up --build
```

Stop the services:
```bash
docker-compose down
```

Remove volumes (clean database):
```bash
docker-compose down -v
```

### 3. Option B: Local Development Setup

#### Install Development Tools
```bash
make install-tools
# or
./scripts/install-tools.sh
```

This installs:
- `swag` - Swagger documentation generator
- `golangci-lint` - Go linter
- `migrate` - Database migration tool
- `air` - Hot-reload for development

#### Install Dependencies
```bash
go mod download
```

#### Setup PostgreSQL
Create a database:
```bash
psql -U postgres
CREATE DATABASE go_api;
\q
```

Or use Docker for just the database:
```bash
docker run --name go_api_db \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=go_api \
  -p 5432:5432 \
  -d postgres:15-alpine
```

#### Configure Environment
Update your `.env` with local settings:
```bash
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=postgres
DB_NAME=go_api
JWT_SECRET=your-super-secret-key-here
PORT=8080
```

#### Run the Application
```bash
make run
# or
go run ./cmd/server
```

### 4. Generate Swagger Documentation

Generate docs (swag must be installed via `make install-tools`):
```bash
make swag
# or
./scripts/init-swagger.sh
```

After running the app, access Swagger UI at:
http://localhost:8080/swagger/index.html

### 5. Development Tools

All development tools can be installed at once:
```bash
make install-tools
# or
./scripts/install-tools.sh
```

This installs: `swag`, `golangci-lint`, `migrate`, and `air`.

#### Run Linter
```bash
make lint
```

#### Run Tests
```bash
make test
```

With coverage:
```bash
make test-coverage
```

## Verification

### Automated Verification (Recommended)

Run our comprehensive verification script:
```bash
make verify
# or
./scripts/verify-setup.sh
```

This checks:
- ✅ Go installation
- ✅ Docker installation
- ✅ Development tools (swag, golangci-lint, migrate, air)
- ✅ All required files exist
- ✅ Code compiles
- ✅ Tests pass
- ✅ go vet passes

### Manual Verification

1. **Health Check**
```bash
curl http://localhost:8080/health
```
Expected: `{"status":"ok","message":"Server is running"}`

2. **Register a User**
```bash
curl -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "password": "password123"
  }'
```

3. **Access Swagger UI**
Open: http://localhost:8080/swagger/index.html

## Troubleshooting

### Database Connection Errors

**Error**: `failed to connect to database`

**Solution**:
- Verify PostgreSQL is running
- Check credentials in `.env`
- Ensure database exists
- For Docker: wait for DB to be ready (healthcheck)

### Port Already in Use

**Error**: `bind: address already in use`

**Solution**:
```bash
# Find and kill the process
lsof -ti:8080 | xargs kill -9
# or change PORT in .env
```

### Import Errors

**Error**: `cannot find package`

**Solution**:
```bash
go mod download
go mod tidy
```

### Swagger Not Generated

**Error**: `404 on /swagger/*`

**Solution**:
```bash
# Install swag
go install github.com/swaggo/swag/cmd/swag@latest

# Generate docs
make swag

# Rebuild and restart
make build
./bin/server
```

### Docker Build Fails

**Solution**:
```bash
# Clean Docker cache
docker-compose down -v
docker system prune -a

# Rebuild
docker-compose up --build
```

## IDE Setup

### VSCode

Recommended extensions:
- `golang.go` - Official Go extension
- `42Crunch.vscode-openapi` - OpenAPI/Swagger support
- `humao.rest-client` - Test API endpoints

Settings:
```json
{
  "go.useLanguageServer": true,
  "go.lintTool": "golangci-lint",
  "go.lintOnSave": "workspace"
}
```

### GoLand / IntelliJ IDEA

1. Enable Go Modules: `Preferences → Go → Go Modules`
2. Enable format on save: `Preferences → Tools → Actions on Save`
3. Configure run configuration with environment variables

## Next Steps

1. ✅ Read the [README.md](README.md) for API documentation
2. ✅ Check [CONTRIBUTING.md](CONTRIBUTING.md) if you want to contribute
3. ✅ Explore the [Swagger UI](http://localhost:8080/swagger/index.html)
4. ✅ Review the code structure in `internal/`
5. ✅ Run tests: `make test`

## Production Deployment

For production deployment:

1. **Change JWT_SECRET** to a strong random value
2. **Use proper migrations** instead of AutoMigrate (see `migrations/README.md`)
3. **Set ENV=production** in your environment
4. **Use managed PostgreSQL** (AWS RDS, Cloud SQL, etc.)
5. **Enable HTTPS** with a reverse proxy (nginx, Caddy)
6. **Set up monitoring** (Prometheus, Datadog, etc.)
7. **Configure logging** properly (structured logs)
8. **Use secrets management** (Vault, AWS Secrets Manager)

See deployment examples in `docs/deployment/` (coming soon).

## Resources

- [Go Documentation](https://golang.org/doc/)
- [Gin Framework](https://gin-gonic.com/docs/)
- [GORM Guide](https://gorm.io/docs/)
- [Swagger/OpenAPI Spec](https://swagger.io/specification/)

## Support

- 📖 [Documentation](README.md)
- 🐛 [Issue Tracker](https://github.com/vahiiiid/go-rest-api-boilerplate/issues)
- 💬 [Discussions](https://github.com/vahiiiid/go-rest-api-boilerplate/discussions)

---

**Need Help?** Open an issue on GitHub!

