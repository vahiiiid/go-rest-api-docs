# Database Migrations

This directory is a placeholder for database migrations if you choose to use a migration tool in production.

## Current Approach

The project currently uses **GORM AutoMigrate** which automatically handles schema migrations on application startup. This is suitable for development and small projects.

## For Production

For production environments, we recommend using a proper migration tool:

### Option 1: golang-migrate

```bash
# Install
go install -tags 'postgres' github.com/golang-migrate/migrate/v4/cmd/migrate@latest

# Create migration
migrate create -ext sql -dir migrations -seq create_users_table

# Run migrations
migrate -path migrations -database "postgres://user:password@localhost:5432/dbname?sslmode=disable" up
```

### Option 2: goose

```bash
# Install
go install github.com/pressly/goose/v3/cmd/goose@latest

# Create migration
goose -dir migrations create create_users_table sql

# Run migrations
goose -dir migrations postgres "user=postgres password=postgres dbname=go_api sslmode=disable" up
```

### Option 3: Atlas

```bash
# Install
curl -sSf https://atlasgo.sh | sh

# Generate migration from schema
atlas migrate diff --env local
```

## Migration Best Practices

1. **Always use migrations in production** - Never rely on AutoMigrate
2. **Version control** - Keep migrations in version control
3. **Test migrations** - Test both up and down migrations
4. **Backup first** - Always backup before running migrations in production
5. **Atomic changes** - Each migration should be atomic and reversible
6. **No data loss** - Avoid migrations that lose data

## Example Migration

### create_users_table.up.sql
```sql
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_deleted_at ON users(deleted_at);
```

### create_users_table.down.sql
```sql
DROP INDEX IF EXISTS idx_users_deleted_at;
DROP INDEX IF EXISTS idx_users_email;
DROP TABLE IF EXISTS users;
```

