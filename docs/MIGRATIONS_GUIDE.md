# Database Migrations Guide

Complete guide to managing database schema changes in GRAB using **golang-migrate** with industry-standard timestamp versioning.

## Overview

GRAB uses **[golang-migrate/migrate](https://github.com/golang-migrate/migrate)** for production-grade database migrations with:

- ✅ **Timestamp versioning** (YYYYMMDDHHMMSS format) - prevents merge conflicts
- ✅ **Up/Down migration pairs** - full rollback capability  
- ✅ **Transaction support** - atomic schema changes
- ✅ **Safety features** - confirmation prompts, dirty state detection
- ✅ **Production-ready** - used by thousands of Go applications

## Quick Start

### Create a New Migration

\`\`\`bash
make migrate-create NAME=add_posts_table
\`\`\`

This creates two files with automatic timestamp:

\`\`\`
migrations/20251026143520_add_posts_table.up.sql
migrations/20251026143520_add_posts_table.down.sql
\`\`\`

### Apply Migrations

\`\`\`bash
make migrate-up          # Apply all pending migrations
make migrate-status      # Check current version
\`\`\`

### Rollback Migrations

\`\`\`bash
make migrate-down              # Rollback last migration (safe default)
make migrate-down STEPS=3      # Rollback 3 migrations
\`\`\`

## Migration Commands Reference

### Core Commands

| Command | Description | Example |
|---------|-------------|---------|
| \`make migrate-create NAME=<name>\` | Create new migration with timestamp | \`make migrate-create NAME=add_user_avatar\` |
| \`make migrate-up\` | Apply all pending migrations | \`make migrate-up\` |
| \`make migrate-down\` | Rollback last migration | \`make migrate-down\` |
| \`make migrate-down STEPS=N\` | Rollback N migrations | \`make migrate-down STEPS=3\` |
| \`make migrate-status\` | Show current migration version | \`make migrate-status\` |
| \`make migrate-goto VERSION=<n>\` | Jump to specific version | \`make migrate-goto VERSION=20251026143520\` |
| \`make migrate-force VERSION=<n>\` | Force set version (recovery) | \`make migrate-force VERSION=20251026143520\` |
| \`make migrate-drop\` | Drop all tables (danger!) | \`make migrate-drop\` |

### Advanced Commands

\`\`\`bash
# Apply specific number of migrations
docker compose exec app go run cmd/migrate/main.go up 2

# Custom timeout for long-running migrations
docker compose exec app go run cmd/migrate/main.go up --timeout=30m --lock-timeout=1m

# Skip confirmation prompts (use with caution)
docker compose exec app go run cmd/migrate/main.go drop --force
\`\`\`


## Real-World Examples

### Example 1: Creating a Posts Table

**Create migration:**

\`\`\`bash
make migrate-create NAME=create_posts_table
\`\`\`

**Edit \`*_create_posts_table.up.sql\`:**

\`\`\`sql
-- Migration: create_posts_table
-- Created: 2025-10-26T14:35:20Z
-- Description: Create posts table with foreign key to users

BEGIN;

CREATE TABLE posts (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    user_id INTEGER NOT NULL,
    status VARCHAR(20) DEFAULT 'draft',
    published_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    
    CONSTRAINT fk_posts_user FOREIGN KEY (user_id) 
        REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX idx_posts_user_id ON posts(user_id);
CREATE INDEX idx_posts_status ON posts(status);
CREATE INDEX idx_posts_published_at ON posts(published_at);
CREATE INDEX idx_posts_deleted_at ON posts(deleted_at);

COMMIT;
\`\`\`

**Edit \`*_create_posts_table.down.sql\`:**

\`\`\`sql
-- Migration: create_posts_table (rollback)
-- Created: 2025-10-26T14:35:20Z

BEGIN;

DROP INDEX IF EXISTS idx_posts_deleted_at;
DROP INDEX IF EXISTS idx_posts_published_at;
DROP INDEX IF EXISTS idx_posts_status;
DROP INDEX IF EXISTS idx_posts_user_id;
DROP TABLE IF EXISTS posts CASCADE;

COMMIT;
\`\`\`

**Apply and test:**

\`\`\`bash
make migrate-up          # Apply migration
make migrate-status      # Verify: version = 20251026143520
make migrate-down        # Test rollback
make migrate-status      # Verify: posts table gone
make migrate-up          # Re-apply
\`\`\`

### Example 2: Adding a Column

**Create migration:**

\`\`\`bash
make migrate-create NAME=add_user_avatar
\`\`\`

**Edit \`*_add_user_avatar.up.sql\`:**

\`\`\`sql
-- Migration: add_user_avatar
-- Created: 2025-10-26T15:22:10Z
-- Description: Add avatar column to users table

BEGIN;

ALTER TABLE users 
    ADD COLUMN IF NOT EXISTS avatar VARCHAR(255);

CREATE INDEX IF NOT EXISTS idx_users_avatar ON users(avatar) 
    WHERE avatar IS NOT NULL;

COMMENT ON COLUMN users.avatar IS 'URL to user profile avatar image';

COMMIT;
\`\`\`

**Edit \`*_add_user_avatar.down.sql\`:**

\`\`\`sql
-- Migration: add_user_avatar (rollback)
-- Created: 2025-10-26T15:22:10Z

BEGIN;

DROP INDEX IF EXISTS idx_users_avatar;
ALTER TABLE users DROP COLUMN IF EXISTS avatar;

COMMIT;
\`\`\`

## Migration Workflow Best Practices

### 1. Development Workflow

\`\`\`bash
# Start development
make up

# Create migration
make migrate-create NAME=add_feature_x

# Edit migration files
# Add SQL to *_add_feature_x.up.sql
# Add rollback SQL to *_add_feature_x.down.sql

# Apply migration
make migrate-up

# Verify it works
make migrate-status

# Test rollback
make migrate-down

# Re-apply for final verification
make migrate-up

# Run tests
make test
\`\`\`

### 2. Testing Migrations

**Test both directions:**

\`\`\`bash
# Test up
make migrate-up
make test

# Test down
make migrate-down
make test

# Test up again
make migrate-up
make test
\`\`\`

### 3. Production Deployment

**Pre-deployment checklist:**

- [ ] Migration tested locally (up and down)
- [ ] Migration reviewed by team
- [ ] Backward compatible with current application version
- [ ] Database backup strategy confirmed
- [ ] Rollback plan documented

**Deployment process:**

\`\`\`bash
# 1. Backup database
docker compose exec db pg_dump -U postgres grab > backup_$(date +%Y%m%d_%H%M%S).sql

# 2. Check current version
make migrate-status

# 3. Apply migrations
make migrate-up

# 4. Verify migration success
make migrate-status

# 5. If something goes wrong, rollback
make migrate-down STEPS=1
\`\`\`

## Migration Versioning System

### Timestamp Format

GRAB uses **YYYYMMDDHHMMSS** format for migration versions:

\`\`\`
20251026143520_create_posts_table.up.sql
│││││││││││││││
│││││││││││││└└─ Seconds (00-59)
││││││││││└└─── Minutes (00-59)
││││││││└└───── Hours (00-23)
│││││└└─────── Day (01-31)
│││└└────────── Month (01-12)
└└───────────── Year (2025)
\`\`\`

### Why Timestamp Versioning?

**Prevents merge conflicts:**

\`\`\`bash
# Sequential (problems):
Developer A: 000001_add_posts.sql
Developer B: 000001_add_comments.sql  # Conflict!

# Timestamps (no conflicts):
Developer A: 20251026140000_add_posts.sql
Developer B: 20251026140500_add_comments.sql  # Works!
\`\`\`

**Industry standard:**

- ✅ Ruby on Rails uses timestamps
- ✅ Django uses timestamps
- ✅ Laravel uses timestamps
- ✅ Alembic (Python) uses timestamps

## Rollback Behavior

### Default Behavior (Safe)

\`\`\`bash
make migrate-down
# ✅ Rolls back ONLY the last migration
# ✅ Confirmation prompt required
# ✅ Safe for production
\`\`\`

**Why roll back one migration at a time?**

- **Safety:** Prevents accidental data loss
- **Industry standard:** Matches Rails, Django, Alembic
- **Controllable:** You verify each step

### Rolling Back Multiple Migrations

\`\`\`bash
# Rollback specific number
make migrate-down STEPS=3

# This will:
# 1. Show warning: "This will rollback 3 migrations"
# 2. Prompt for confirmation
# 3. Roll back 3 migrations in order (newest first)
\`\`\`

### Rollback Comparison

| Framework | Default Rollback | Multiple Rollback |
|-----------|------------------|-------------------|
| **GRAB (golang-migrate)** | 1 migration | \`STEPS=N\` parameter |
| **Rails** | 1 migration | \`STEP=N\` parameter |
| **Django** | Must specify version | Migrate to version number |
| **Laravel** | Last batch | \`--step=N\` option |
| **Alembic** | \`-1\` (one down) | \`-N\` or \`base\` |

## Recovery & Troubleshooting

### Dirty State Recovery

**What is dirty state?**

A migration failed partway through, leaving the database in an inconsistent state.

**Check for dirty state:**

\`\`\`bash
make migrate-status
# Output: Status: ⚠️  DIRTY (migration failed or interrupted)
\`\`\`

**Recovery steps:**

\`\`\`bash
# 1. Check which version is dirty
make migrate-status

# 2. Manually fix the database
docker compose exec db psql -U postgres -d grab
# Fix issues manually in SQL

# 3. Force set the version
make migrate-force VERSION=20251026140000

# 4. Verify clean state
make migrate-status
# Status: ✅ Clean
\`\`\`

### Common Issues

#### Issue 1: "migration file does not exist"

**Solution:**

\`\`\`bash
# Force reset to previous version
make migrate-force VERSION=20251026135959
\`\`\`

#### Issue 2: "version is dirty"

**Solution:**

\`\`\`bash
# 1. Check what failed
docker compose exec db psql -U postgres -d grab

# 2. Manually fix database issues

# 3. Force clean state
make migrate-force VERSION=20251026140000
\`\`\`

## Advanced Topics

### Custom Migration Configuration

**Override timeouts:**

\`\`\`bash
# Long-running migration
docker compose exec app go run cmd/migrate/main.go up \
    --timeout=1h \
    --lock-timeout=10m
\`\`\`

**Configuration file:** \`configs/config.yaml\`

\`\`\`yaml
migrations:
  directory: "./migrations"
  timeout: 300          # 5 minutes default
  lock_timeout: 30      # 30 seconds default
\`\`\`

### CI/CD Integration

**GitHub Actions workflow:**

\`\`\`yaml
name: Migrations Test
on: [push, pull_request]

jobs:
  test-migrations:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Go
        uses: actions/setup-go@v4
        with:
          go-version: '1.24'

      - name: Run migrations up
        run: make migrate-up

      - name: Run tests
        run: make test

      - name: Test migrations down
        run: echo "yes" | make migrate-down

      - name: Run migrations up again
        run: make migrate-up
\`\`\`

## Migration Testing Script

GRAB includes a comprehensive migration test script:

\`\`\`bash
./scripts/test-migrations.sh
\`\`\`

**What it tests:**

- ✅ Creating migrations with timestamp versioning
- ✅ Applying all migrations (migrate-up)
- ✅ Migration status checking
- ✅ Rolling back single migration
- ✅ Rolling back multiple migrations (STEPS parameter)
- ✅ Goto specific version
- ✅ Database schema tracking (schema_migrations table)
- ✅ Industry best practices compliance

## Migration Checklist

### Before Creating Migration

- [ ] Pulled latest changes from main branch
- [ ] Reviewed existing migrations
- [ ] Planned migration strategy (backward compatible?)

### Writing Migration

- [ ] Used \`make migrate-create NAME=descriptive_name\`
- [ ] Both \`.up.sql\` and \`.down.sql\` files provided
- [ ] SQL wrapped in \`BEGIN;\` / \`COMMIT;\` transaction
- [ ] Used \`IF EXISTS\` / \`IF NOT EXISTS\` for idempotency
- [ ] Added descriptive comments
- [ ] Down migration truly reverses up migration

### Testing Migration

- [ ] Applied migration locally: \`make migrate-up\`
- [ ] Verified migration status: \`make migrate-status\`
- [ ] Tested rollback: \`make migrate-down\`
- [ ] Re-applied migration: \`make migrate-up\`
- [ ] Ran all tests: \`make test\`
- [ ] Ran linter: \`make lint\`

### Before Deployment

- [ ] Migration reviewed by team
- [ ] Backup strategy confirmed
- [ ] Rollback plan documented

## Summary

### Key Takeaways

1. **Always use versioned SQL migrations** - Not GORM AutoMigrate in production
2. **Timestamp versioning prevents conflicts** - Teams can work in parallel
3. **Test both up and down migrations** - Rollbacks should always work
4. **One logical change per migration** - Keep migrations focused
5. **Never modify existing migrations** - Create new migration to fix issues
6. **Use transactions** - Wrap SQL in BEGIN/COMMIT for atomicity
7. **Rollback 1 by default is intentional** - Safety first, STEPS for multiple
8. **Use confirmation prompts** - Prevents accidental data loss
9. **Monitor dirty state** - Detect and recover from failed migrations
10. **Backup before production migrations** - Always have a recovery plan

### Additional Resources

- **[golang-migrate Documentation](https://github.com/golang-migrate/migrate)** - Official docs
- **[Migration Testing Script](https://github.com/vahiiiid/go-rest-api-boilerplate/blob/main/scripts/test-migrations.sh)** - Automated testing
- **[GRAB Documentation](https://vahiiiid.github.io/go-rest-api-docs/)** - Full project docs

### Questions or Issues?

- 📖 Check the [Migration Testing Script](https://github.com/vahiiiid/go-rest-api-boilerplate/blob/main/scripts/test-migrations.sh)
- 🐛 [Open an issue](https://github.com/vahiiiid/go-rest-api-boilerplate/issues)
- 💬 [Start a discussion](https://github.com/vahiiiid/go-rest-api-boilerplate/discussions)
- ⭐ [Star the repository](https://github.com/vahiiiid/go-rest-api-boilerplate)

---

**Happy migrating! 🚀**
