# Security Guide

Comprehensive security guidelines and best practices for the Go REST API Boilerplate (GRAB).

---

## 🔐 JWT Secret Management

JWT secrets are critical for token security. This section covers proper generation, storage, and validation.

### Security Requirements

#### All Environments
- **Minimum Length:** 32 characters
- **Cryptographically Random:** Generated using secure methods (not predictable)
- **Never Committed:** Must never be checked into version control
- **Unique per Environment:** Different secrets for development, staging, and production

#### Production Requirements
- **Minimum Length:** 64 characters (stricter requirement)
- **SSL Required:** Database must use SSL (`sslmode: require`)
- **Rotation Policy:** Rotate secrets periodically (recommended: every 90 days)

---

## 🔑 Generating JWT Secrets

### Automated Generation (Recommended)

#### Quick Start with Auto-Generation

```bash
make quick-start
```

The quick-start command automatically generates a secure 32+ character JWT secret if missing or empty.

#### Generate or Check JWT Secret

```bash
make generate-jwt-secret
```

**Behavior:**

- **If JWT_SECRET exists in .env:** Displays confirmation message (doesn't regenerate)
- **If JWT_SECRET is missing:** Generates and automatically saves to .env
- **Secret length:** 64 characters (base64 encoded from 48 random bytes)

**Example Output (when JWT_SECRET missing):**

```text
🔐 Generating JWT secret...
✅ JWT_SECRET generated and saved to .env

⚠️  NEVER commit .env to git!
```

**Example Output (when JWT_SECRET exists):**

```text
✅ JWT_SECRET already exists in .env
💡 Current value is set (not displayed for security)

To regenerate, remove the current JWT_SECRET line from .env first
```

### Manual Generation Methods

#### Using OpenSSL (Recommended)

Generate a secure 32+ character secret:

```bash
openssl rand -base64 48
```

#### Using /dev/urandom

```bash
head -c 48 /dev/urandom | base64 | tr -d '\n'
```

#### Using Python

```bash
python3 -c "import secrets; print(secrets.token_urlsafe(48))"
```

#### Using Node.js

```bash
node -e "console.log(require('crypto').randomBytes(48).toString('base64'))"
```

---

## 📝 Environment Configuration

### .env File Setup

**1. Copy Template:**
```bash
cp .env.example .env
```

**2. Generate Secret:**
```bash
make generate-jwt-secret
```

**3. Add to .env:**
```bash
JWT_SECRET=xKyLmNpQrStUvWzAbBcCdDeEfFgGhHiIjJkKlLmMnNoOpPqQrRsStTuUvVwWxXyYzZ
```

### Environment Validation

Check your environment configuration:
```bash
make check-env
```

**Example Output:**
```
✅ .env file exists
✅ JWT_SECRET is set
✅ JWT_SECRET length: 64 characters (recommended for production)
✅ DATABASE_PASSWORD is set
```

---

## ⚠️ Common Security Mistakes

### ❌ DON'T: Use Weak Secrets

```bash
# BAD - Too short (< 32 characters)
JWT_SECRET=mysecret

# BAD - Too short for production (< 64 characters)
JWT_SECRET=my-secret-key-that-is-only-32-char

# BAD - Not cryptographically random
JWT_SECRET=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
```

### ✅ DO: Use Strong Secrets

```bash
# GOOD - Cryptographically random, 64+ chars
JWT_SECRET=xKyLmNpQrStUvWzAbBcCdDeEfFgGhHiIjJkKlLmMnNoOpPqQrRsStTuUvVwWxXyYzZ

# GOOD - Generated with openssl
JWT_SECRET=$(openssl rand -base64 96)

# GOOD - Generated with make command
make generate-jwt-secret
```

### ❌ DON'T: Commit Secrets to Git

```yaml
# config.yaml - BAD
jwt:
  secret: "my-hardcoded-secret"  # ❌ Never do this
```

```bash
# .env - BAD
JWT_SECRET=hardcoded-value
git add .env  # ❌ Never commit .env files
```

### ✅ DO: Use Environment Variables

```yaml
# config.yaml - GOOD
jwt:
  # No secret field - must be set via JWT_SECRET env var ✅
  access_token_ttl: "15m"
  refresh_token_ttl: "168h"
```

```bash
# .env - GOOD (not committed to git)
JWT_SECRET=$(openssl rand -base64 96)

# .gitignore - GOOD
.env  # ✅ Always ignored
```

---

## 🔄 Secret Rotation

### When to Rotate Secrets

- **Scheduled:** Every 90 days (production)
- **Security Incident:** Immediately if compromise suspected
- **Team Changes:** When team members with access leave
- **Compliance:** As required by security policies

### Rotation Process

**1. Generate New Secret:**
```bash
make generate-jwt-secret
```

**2. Update Environment:**
```bash
# Update .env file with new secret
JWT_SECRET=<new-secret-value>
```

**3. Restart Application:**
```bash
make restart
```

**4. Verify:**
```bash
curl http://localhost:8080/health
```

**Note:** Existing JWT tokens will become invalid after rotation. Users will need to re-authenticate.

---

## 🏗️ Production Deployment

### Environment Setup Checklist

- [ ] Generate production JWT secret (64+ characters)
- [ ] Set JWT_SECRET environment variable
- [ ] Enable SSL for database (`DATABASE_SSLMODE=require`)
- [ ] Set DATABASE_PASSWORD via environment variable
- [ ] Verify APP_ENVIRONMENT=production
- [ ] Disable debug mode (APP_DEBUG=false)
- [ ] Run `make check-env` to validate configuration

### Docker Deployment

**docker-compose.prod.yml:**
```yaml
services:
  app:
    environment:
      - APP_ENVIRONMENT=production
      - JWT_SECRET=${JWT_SECRET}  # From host environment
      - DATABASE_PASSWORD=${DATABASE_PASSWORD}
      - DATABASE_SSLMODE=require
```

**Start Production:**
```bash
# Set secrets in shell
export JWT_SECRET=$(openssl rand -base64 96)
export DATABASE_PASSWORD=$(openssl rand -base64 32)

# Start services
docker-compose -f docker-compose.prod.yml up -d
```

### Kubernetes Deployment

**Create Secret:**
```bash
kubectl create secret generic app-secrets \
  --from-literal=jwt-secret=$(openssl rand -base64 96) \
  --from-literal=database-password=$(openssl rand -base64 32)
```

**Deployment YAML:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grab-api
spec:
  template:
    spec:
      containers:
      - name: api
        env:
        - name: JWT_SECRET
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: jwt-secret
        - name: DATABASE_PASSWORD
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: database-password
```

---

## 🔍 Security Validation

### Startup Validation

The application validates security configuration on startup:

**Validation Checks:**
1. JWT_SECRET is present
2. JWT_SECRET length ≥ 32 characters (64+ for production)
3. DATABASE_PASSWORD is set in production
4. SSL is enabled in production

**Example Validation Error:**
```
ERROR Failed to load configuration error="JWT_SECRET must be at least 32 characters (current: 16)
Generate secure secret: make generate-jwt-secret"
```

### Runtime Security

**Token Validation:**
- All protected endpoints validate JWT tokens
- Expired tokens are automatically rejected
- Invalid signatures are rejected
- Token refresh requires valid refresh token

**Rate Limiting:**
- Optional rate limiting per endpoint
- Configurable via `RATELIMIT_ENABLED`, `RATELIMIT_REQUESTS`, `RATELIMIT_WINDOW`

---

## 📚 Additional Security Resources

### OWASP Guidelines
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [JWT Security Best Practices](https://cheatsheetseries.owasp.org/cheatsheets/JSON_Web_Token_for_Java_Cheat_Sheet.html)

### 12-Factor App Methodology
- [Config](https://12factor.net/config) - Store config in environment

### Related Documentation
- [Configuration Guide](CONFIGURATION.md) - Complete configuration reference
- [Setup Guide](SETUP.md) - Initial setup and quick start
- [Development Guide](DEVELOPMENT_GUIDE.md) - Development best practices

---

## 🆘 Support

If you have security concerns or questions:

1. **Security Issues:** Report via [GitHub Security Advisories](https://github.com/vahiiiid/go-rest-api-boilerplate/security/advisories)
2. **General Questions:** Open an [issue](https://github.com/vahiiiid/go-rest-api-boilerplate/issues)
3. **Documentation:** Check [full documentation](https://vahiiiid.github.io/go-rest-api-docs/)
