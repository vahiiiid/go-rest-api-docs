# Database Migrations Guide

This directory contains SQL migration files for managing database schema changes.

## Current Status

**Current Approach**: The application uses **GORM AutoMigrate** which automatically creates/updates tables on startup. This is fine for development but **not recommended for production**.

**Migration Files Available**:
- ✅ `000001_create_users_table.up.sql` - Creates users table with indexes
- ✅ `000001_create_users_table.down.sql` - Rollback (drops users table)

## Using Migrations in Production

For production, we **strongly recommend** using a migration tool instead of AutoMigrate. Here are three popular options:

---

## Option 1: golang-migrate (Recommended)

### Install
```bash
# macOS
brew install golang-migrate

# Or using Go
go install -tags 'postgres' github.com/golang-migrate/migrate/v4/cmd/migrate@latest
```

### Run Migrations
```bash
# Apply all migrations
migrate -path migrations -database "postgres://postgres:postgres@localhost:5432/go_api?sslmode=disable" up

# Rollback last migration
migrate -path migrations -database "postgres://postgres:postgres@localhost:5432/go_api?sslmode=disable" down 1

# Check current version
migrate -path migrations -database "postgres://postgres:postgres@localhost:5432/go_api?sslmode=disable" version

# Force to specific version (use with caution)
migrate -path migrations -database "postgres://postgres:postgres@localhost:5432/go_api?sslmode=disable" force 1
```

### Create New Migration
```bash
migrate create -ext sql -dir migrations -seq add_user_avatar_column
```

This creates:
- `000002_add_user_avatar_column.up.sql`
- `000002_add_user_avatar_column.down.sql`

---

## Option 2: goose

### Install
```bash
go install github.com/pressly/goose/v3/cmd/goose@latest
```

### Run Migrations
```bash
# Apply migrations
goose -dir migrations postgres "user=postgres password=postgres dbname=go_api sslmode=disable" up

# Rollback
goose -dir migrations postgres "user=postgres password=postgres dbname=go_api sslmode=disable" down

# Status
goose -dir migrations postgres "user=postgres password=postgres dbname=go_api sslmode=disable" status
```

### Create New Migration
```bash
goose -dir migrations create add_user_avatar sql
```

---

## Option 3: Atlas

### Install
```bash
curl -sSf https://atlasgo.sh | sh
```

### Usage
```bash
# Apply migrations
atlas migrate apply --env local

# Generate migration from models
atlas migrate diff --env local
```

---

## Migration Naming Convention

We use sequential numbering with descriptive names:

```
000001_create_users_table.up.sql
000001_create_users_table.down.sql
000002_add_user_avatar_column.up.sql
000002_add_user_avatar_column.down.sql
000003_create_posts_table.up.sql
000003_create_posts_table.down.sql
```

---

## Migration Best Practices

### 1. Always Write Reversible Migrations
Every `.up.sql` should have a corresponding `.down.sql` that reverses the changes.

### 2. Test Migrations
```bash
# Test up
migrate -path migrations -database "..." up

# Test down
migrate -path migrations -database "..." down 1

# Test up again
migrate -path migrations -database "..." up
```

### 3. Never Modify Existing Migrations
Once a migration is committed and applied in any environment, **never modify it**. Create a new migration instead.

### 4. Keep Migrations Small
One logical change per migration. Don't combine unrelated changes.

### 5. Backup Before Production Migrations
```bash
# PostgreSQL backup
pg_dump -U postgres go_api > backup_$(date +%Y%m%d_%H%M%S).sql

# Restore if needed
psql -U postgres go_api < backup_20240101_120000.sql
```

---

## Switching from AutoMigrate to Migrations

To switch from GORM AutoMigrate to proper migrations:

### Step 1: Comment out AutoMigrate
In `cmd/server/main.go`:
```go
// Comment this out:
// if err := database.AutoMigrate(&user.User{}); err != nil {
//     log.Fatalf("Failed to run migrations: %v", err)
// }
```

### Step 2: Run migrations manually
```bash
migrate -path migrations -database "postgres://..." up
```

### Step 3: Update deployment scripts
Add migration step to your CI/CD or deployment process.

---

## Docker Integration

### Using golang-migrate in Docker

```dockerfile
# Add to Dockerfile
FROM golang:1.24-alpine AS builder
RUN apk add --no-cache git
RUN go install -tags 'postgres' github.com/golang-migrate/migrate/v4/cmd/migrate@latest
```

### docker-compose with migrations

```yaml
services:
  migrate:
    image: migrate/migrate
    volumes:
      - ./migrations:/migrations
    command: ["-path", "/migrations", "-database", "postgres://postgres:postgres@db:5432/go_api?sslmode=disable", "up"]
    depends_on:
      - db
```

---

## Common Issues & Solutions

### Issue: "Dirty database version"
```bash
# This means a migration failed partway through
# Check which version is dirty
migrate -path migrations -database "..." version

# Force to the correct version (after manually fixing the database)
migrate -path migrations -database "..." force VERSION_NUMBER
```

### Issue: "Migration already applied"
This is normal. The tool tracks which migrations have been applied in a `schema_migrations` table.

### Issue: "Connection refused"
Make sure your database is running and credentials are correct.

---

## Current Schema

Based on `internal/user/model.go`, the users table schema is:

```sql
TABLE users
├── id            SERIAL PRIMARY KEY
├── name          VARCHAR(255) NOT NULL
├── email         VARCHAR(255) UNIQUE NOT NULL
├── password_hash VARCHAR(255) NOT NULL
├── created_at    TIMESTAMP WITH TIME ZONE
├── updated_at    TIMESTAMP WITH TIME ZONE
└── deleted_at    TIMESTAMP WITH TIME ZONE

INDEXES
├── idx_users_email
└── idx_users_deleted_at
```

---

## Example: Adding a New Column

### 000002_add_user_phone.up.sql
```sql
ALTER TABLE users 
ADD COLUMN phone VARCHAR(20);

CREATE INDEX idx_users_phone ON users(phone);
```

### 000002_add_user_phone.down.sql
```sql
DROP INDEX IF EXISTS idx_users_phone;

ALTER TABLE users 
DROP COLUMN IF EXISTS phone;
```

---

## CI/CD Integration

### GitHub Actions Example
```yaml
jobs:
  migrate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Run migrations
        env:
          DATABASE_URL: ${{ secrets.DATABASE_URL }}
        run: |
          curl -L https://github.com/golang-migrate/migrate/releases/download/v4.15.2/migrate.linux-amd64.tar.gz | tar xvz
          ./migrate -path migrations -database "$DATABASE_URL" up
```

---

## Resources

- [golang-migrate Documentation](https://github.com/golang-migrate/migrate)
- [goose Documentation](https://github.com/pressly/goose)
- [Atlas Documentation](https://atlasgo.io/)
- [PostgreSQL ALTER TABLE](https://www.postgresql.org/docs/current/sql-altertable.html)

---

## Need Help?

- Check [migrations/README.md](README.md) for overview
- See existing migrations for examples
- Review PostgreSQL documentation
- Open an issue on GitHub

---

**Remember**: Migrations are your database's version control. Treat them with the same care as your code! 🗃️

