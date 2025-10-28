# Authentication & JWT

## Overview

GRAB implements a secure, production-ready authentication system using **OAuth 2.0 Best Current Practice (BCP) compliant** JWT refresh token rotation with automatic reuse detection. This approach provides enhanced security while maintaining excellent user experience.

## Key Features

- **Token Pair Authentication**: Access tokens (short-lived) + Refresh tokens (long-lived)
- **Automatic Token Rotation**: Each refresh generates a new token pair
- **Reuse Detection**: Automatic revocation of token families when suspicious activity is detected
- **Token Family Tracking**: UUID-based lineage tracking for security auditing
- **SHA-256 Token Hashing**: Refresh tokens are hashed before storage
- **Configurable TTLs**: Separate lifetimes for access and refresh tokens
- **Secure Revocation**: Per-user and per-family token revocation

## Authentication Flow

### Registration & Login

```mermaid
sequenceDiagram
    participant Client
    participant API
    participant DB
    
    Client->>API: POST /api/v1/auth/register
    API->>DB: Create user
    API->>DB: Store refresh token (hashed)
    API->>Client: { access_token, refresh_token }
    
    Note over Client: Store tokens securely
```

**Register Endpoint:**

```http
POST /api/v1/auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "SecurePassword123!",
  "name": "John Doe"
}
```

**Response:**

```json
{
  "user": {
    "id": 1,
    "email": "user@example.com",
    "name": "John Doe"
  },
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "8f7a3c2b1e9d4a5f6c8b7e3a2f1d9c8b...",
  "token_type": "Bearer",
  "expires_in": 900
}
```

**Login Endpoint:**

```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "SecurePassword123!"
}
```

Response format is identical to registration.

### Token Refresh Flow

When the access token expires, use the refresh token to obtain a new token pair:

```mermaid
sequenceDiagram
    participant Client
    participant API
    participant DB
    
    Client->>API: POST /api/v1/auth/refresh<br/>{refresh_token}
    API->>DB: Find token by hash
    
    alt Token Valid & Not Used
        API->>DB: Mark old token as used
        API->>DB: Store new refresh token
        API->>Client: { new_access_token, new_refresh_token }
    else Token Already Used (Reuse Detection)
        API->>DB: Revoke entire token family
        API->>Client: 401 Unauthorized - Token reuse detected
    else Token Expired/Revoked/Invalid
        API->>Client: 401 Unauthorized
    end
```

**Refresh Endpoint:**

```http
POST /api/v1/auth/refresh
Content-Type: application/json

{
  "refresh_token": "8f7a3c2b1e9d4a5f6c8b7e3a2f1d9c8b..."
}
```

**Success Response:**

```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "9a8b7c6d5e4f3a2b1c9d8e7f6a5b4c3d...",
  "token_type": "Bearer",
  "expires_in": 900
}
```

### Making Authenticated Requests

Use the access token in the `Authorization` header:

```http
GET /api/v1/users/1
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Logout

Revoke all refresh tokens for the current user:

```http
POST /api/v1/auth/logout
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response:**

```json
{
  "message": "Successfully logged out"
}
```

## Security Architecture

### Token Rotation

Token rotation is a security best practice that limits the lifespan of refresh tokens while maintaining a seamless user experience. Each time a refresh token is used:

1. ✅ The old refresh token is marked as "used" (not deleted)
2. ✅ A new token pair is generated with the same token family
3. ✅ The new refresh token is stored in the database (hashed)
4. ✅ Old token becomes invalid for future use

**Why keep used tokens?** They enable reuse detection!

### Reuse Detection

Reuse detection protects against token theft by detecting when a refresh token is used more than once:

```mermaid
flowchart TD
    A[Client sends refresh_token] --> B{Token exists?}
    B -->|No| C[Return: Invalid token]
    B -->|Yes| D{Token revoked?}
    D -->|Yes| E[Return: Token revoked]
    D -->|No| F{Token expired?}
    F -->|Yes| G[Return: Token expired]
    F -->|No| H{Token already used?}
    H -->|Yes| I[🚨 REUSE DETECTED<br/>Revoke entire token family]
    H -->|No| J[Mark as used<br/>Generate new token pair]
    I --> K[Return: Token reuse detected]
    J --> L[Return: New tokens]
```

**Scenario: Token Theft**

1. **Attacker** steals a refresh token
2. **Attacker** uses it → Gets new token pair ✅
3. **Legitimate user** tries to use the same token → 🚨 **Reuse detected!**
4. **System** revokes the entire token family (attacker's tokens become invalid)

This provides strong protection even if a token is compromised.

### Token Family Tracking

Each token belongs to a "token family" identified by a UUID. All tokens generated from the same initial authentication share the same family ID:

```
Initial Login:  family_id = "abc-123"
  ↓
First Refresh:  family_id = "abc-123" (same family)
  ↓
Second Refresh: family_id = "abc-123" (same family)
  ↓
🚨 Reuse Detected → Revoke ALL tokens in family "abc-123"
```

### Token Storage

**Access Tokens:**
- Short-lived (default: 15 minutes)
- Stored only on client side
- Contains user claims (ID, email, name)
- NOT stored in database

**Refresh Tokens:**
- Long-lived (default: 7 days)
- SHA-256 hashed before storage
- Includes metadata: token_family, expires_at, used_at, revoked_at
- Database indexed for fast lookup

**Database Schema:**

```sql
CREATE TABLE refresh_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash VARCHAR(64) NOT NULL,
    token_family UUID NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    used_at TIMESTAMP,
    revoked_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_refresh_tokens_token_hash ON refresh_tokens(token_hash);
CREATE INDEX idx_refresh_tokens_token_family ON refresh_tokens(token_family);
CREATE INDEX idx_refresh_tokens_user_id ON refresh_tokens(user_id);
CREATE INDEX idx_refresh_tokens_expires_at ON refresh_tokens(expires_at);
```

## Configuration

### Environment Variables

Configure token lifetimes via environment variables or config files:

```bash
# JWT Configuration
JWT_SECRET=your-super-secret-key-min-32-chars
JWT_ACCESS_TOKEN_TTL=15m      # Access token lifetime
JWT_REFRESH_TOKEN_TTL=168h    # Refresh token lifetime (7 days)
```

### Config File

`configs/config.yaml`:

```yaml
jwt:
  secret: ${JWT_SECRET}
  access_token_ttl: "15m"
  refresh_token_ttl: "168h"
```

### Recommended TTL Values

| Environment | Access Token | Refresh Token | Rationale |
|-------------|-------------|---------------|-----------|
| **Development** | 15m | 7 days | Balance between security and DX |
| **Staging** | 15m | 7 days | Match production behavior |
| **Production** | 15m | 7-30 days | Based on security requirements |

**Guidelines:**

- ✅ **Access tokens**: 5-15 minutes (frequently rotated, high security)
- ✅ **Refresh tokens**: 7-30 days (balance between security and UX)
- ❌ **Don't**: Set access tokens > 1 hour (defeats rotation purpose)
- ❌ **Don't**: Set refresh tokens > 90 days (compliance risk)

## API Reference

### Authentication Endpoints

| Endpoint | Method | Auth Required | Description |
|----------|--------|---------------|-------------|
| `/api/v1/auth/register` | POST | No | Create new user account |
| `/api/v1/auth/login` | POST | No | Authenticate and get tokens |
| `/api/v1/auth/refresh` | POST | No | Refresh access token |
| `/api/v1/auth/logout` | POST | Yes | Revoke all user tokens |

### Register

**Request:**

```json
{
  "email": "string (required, email format)",
  "password": "string (required, min 8 chars)",
  "name": "string (required, min 1 char)"
}
```

**Response (200 OK):**

```json
{
  "user": {
    "id": "integer",
    "email": "string",
    "name": "string"
  },
  "access_token": "string (JWT)",
  "refresh_token": "string (random 32 bytes, hex)",
  "token_type": "Bearer",
  "expires_in": "integer (seconds)"
}
```

**Error Responses:**

- `400 Bad Request`: Validation errors
- `409 Conflict`: Email already exists
- `500 Internal Server Error`: Server error

### Login

**Request:**

```json
{
  "email": "string (required)",
  "password": "string (required)"
}
```

**Response:** Same as Register

**Error Responses:**

- `400 Bad Request`: Validation errors
- `401 Unauthorized`: Invalid credentials
- `500 Internal Server Error`: Server error

### Refresh Token

**Request:**

```json
{
  "refresh_token": "string (required)"
}
```

**Response (200 OK):**

```json
{
  "access_token": "string (JWT)",
  "refresh_token": "string (new token)",
  "token_type": "Bearer",
  "expires_in": "integer (seconds)"
}
```

**Error Responses:**

- `400 Bad Request`: Missing refresh_token
- `401 Unauthorized`: Invalid/expired/revoked token
- `401 Unauthorized` (reuse): Token reuse detected - all family tokens revoked
- `500 Internal Server Error`: Server error

### Logout

**Request:**

Requires `Authorization: Bearer <access_token>` header

**Response (200 OK):**

```json
{
  "message": "Successfully logged out"
}
```

**Error Responses:**

- `401 Unauthorized`: Missing/invalid access token
- `500 Internal Server Error`: Server error

## Client Implementation Guide

### Best Practices

1. **Store tokens securely**:
   - Web: HttpOnly cookies (most secure) or sessionStorage (never localStorage for refresh tokens)
   - Mobile: Secure storage (Keychain/Keystore)
   - Never expose refresh tokens in URLs or logs

2. **Implement automatic refresh**:
   - Detect 401 responses
   - Attempt token refresh
   - Retry original request with new token
   - If refresh fails, redirect to login

3. **Handle reuse detection**:
   - On "token reuse detected" error, immediately clear all tokens
   - Redirect user to login
   - Optional: Show security alert

### JavaScript/TypeScript Example

```typescript
class AuthClient {
  private accessToken: string | null = null;
  private refreshToken: string | null = null;
  private refreshPromise: Promise<void> | null = null;

  async login(email: string, password: string): Promise<void> {
    const response = await fetch('/api/v1/auth/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password })
    });

    if (!response.ok) throw new Error('Login failed');

    const data = await response.json();
    this.setTokens(data.access_token, data.refresh_token);
  }

  async refreshAccessToken(): Promise<void> {
    // Prevent concurrent refresh attempts
    if (this.refreshPromise) return this.refreshPromise;

    this.refreshPromise = (async () => {
      try {
        const response = await fetch('/api/v1/auth/refresh', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ refresh_token: this.refreshToken })
        });

        if (!response.ok) {
          // Token reuse or expired - clear everything
          this.clearTokens();
          throw new Error('Refresh failed');
        }

        const data = await response.json();
        this.setTokens(data.access_token, data.refresh_token);
      } finally {
        this.refreshPromise = null;
      }
    })();

    return this.refreshPromise;
  }

  async request(url: string, options: RequestInit = {}): Promise<Response> {
    // Add access token to request
    const headers = new Headers(options.headers);
    headers.set('Authorization', `Bearer ${this.accessToken}`);

    let response = await fetch(url, { ...options, headers });

    // If 401, try to refresh and retry
    if (response.status === 401 && this.refreshToken) {
      try {
        await this.refreshAccessToken();
        headers.set('Authorization', `Bearer ${this.accessToken}`);
        response = await fetch(url, { ...options, headers });
      } catch (error) {
        // Refresh failed - redirect to login
        window.location.href = '/login';
        throw error;
      }
    }

    return response;
  }

  async logout(): Promise<void> {
    if (this.accessToken) {
      await fetch('/api/v1/auth/logout', {
        method: 'POST',
        headers: { 'Authorization': `Bearer ${this.accessToken}` }
      });
    }
    this.clearTokens();
  }

  private setTokens(accessToken: string, refreshToken: string): void {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
    // Store in secure storage (e.g., sessionStorage)
    sessionStorage.setItem('access_token', accessToken);
    sessionStorage.setItem('refresh_token', refreshToken);
  }

  private clearTokens(): void {
    this.accessToken = null;
    this.refreshToken = null;
    sessionStorage.removeItem('access_token');
    sessionStorage.removeItem('refresh_token');
  }
}

// Usage
const auth = new AuthClient();

// Login
await auth.login('user@example.com', 'password');

// Make authenticated request (auto-refresh on 401)
const response = await auth.request('/api/v1/users/1');
const user = await response.json();

// Logout
await auth.logout();
```

### Mobile App Example (React Native)

```typescript
import * as SecureStore from 'expo-secure-store';

class MobileAuthClient {
  private async getTokens() {
    const accessToken = await SecureStore.getItemAsync('access_token');
    const refreshToken = await SecureStore.getItemAsync('refresh_token');
    return { accessToken, refreshToken };
  }

  private async setTokens(accessToken: string, refreshToken: string) {
    await SecureStore.setItemAsync('access_token', accessToken);
    await SecureStore.setItemAsync('refresh_token', refreshToken);
  }

  private async clearTokens() {
    await SecureStore.deleteItemAsync('access_token');
    await SecureStore.deleteItemAsync('refresh_token');
  }

  async login(email: string, password: string) {
    const response = await fetch('https://api.example.com/api/v1/auth/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password })
    });

    if (!response.ok) throw new Error('Login failed');

    const data = await response.json();
    await this.setTokens(data.access_token, data.refresh_token);
    return data;
  }

  async authenticatedRequest(url: string, options: RequestInit = {}) {
    const { accessToken, refreshToken } = await this.getTokens();
    
    const headers = new Headers(options.headers);
    headers.set('Authorization', `Bearer ${accessToken}`);

    let response = await fetch(url, { ...options, headers });

    if (response.status === 401 && refreshToken) {
      // Try to refresh
      const refreshResponse = await fetch('https://api.example.com/api/v1/auth/refresh', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ refresh_token: refreshToken })
      });

      if (refreshResponse.ok) {
        const data = await refreshResponse.json();
        await this.setTokens(data.access_token, data.refresh_token);
        
        // Retry original request
        headers.set('Authorization', `Bearer ${data.access_token}`);
        response = await fetch(url, { ...options, headers });
      } else {
        // Refresh failed - clear tokens and require login
        await this.clearTokens();
        throw new Error('Session expired');
      }
    }

    return response;
  }
}
```

## Security Considerations

### Production Checklist

- [ ] **JWT Secret**: Use strong secret (min 32 characters, random)
- [ ] **HTTPS Only**: Never use tokens over HTTP
- [ ] **Secure Storage**: Use HttpOnly cookies or secure storage APIs
- [ ] **Token Expiry**: Keep access tokens short-lived (≤ 15 minutes)
- [ ] **Rate Limiting**: Protect auth endpoints (implemented in GRAB)
- [ ] **Input Validation**: Validate all auth requests (implemented in GRAB)
- [ ] **Password Hashing**: Use bcrypt with cost ≥ 12 (implemented in GRAB)
- [ ] **CORS**: Configure proper CORS policies
- [ ] **Monitoring**: Log auth failures and token reuse events
- [ ] **Revocation**: Implement logout and token revocation

### Common Vulnerabilities & Mitigations

| Vulnerability | Mitigation in GRAB |
|---------------|-------------------|
| **Token Theft** | Reuse detection + automatic family revocation |
| **XSS Attacks** | Use HttpOnly cookies or secure storage |
| **CSRF Attacks** | JWT in Authorization header (not cookies) |
| **Replay Attacks** | Token rotation + short TTLs |
| **Brute Force** | Rate limiting on auth endpoints |
| **Session Fixation** | New token family per authentication |

## Troubleshooting

### Common Issues

**Issue: "Invalid token" error**

- ✅ Check token hasn't expired
- ✅ Verify token format (should be JWT for access, hex string for refresh)
- ✅ Ensure proper Authorization header format: `Bearer <token>`
- ✅ Confirm JWT_SECRET matches between environments

**Issue: "Token reuse detected"**

- This is a **security feature**, not a bug
- Occurs when same refresh token used twice
- Solution: User must log in again
- Prevention: Ensure client properly updates tokens after refresh

**Issue: Refresh token not working after logout**

- Expected behavior - logout revokes all user tokens
- User must log in again to get new tokens

**Issue: Access token expires too quickly**

- Default is 15 minutes (security best practice)
- Don't increase beyond 1 hour
- Implement automatic refresh in client instead

### Debug Mode

Enable debug logging in development:

```yaml
# configs/config.development.yaml
server:
  log_level: "debug"  # Shows detailed auth logs
```

## Standards & References

GRAB's authentication implementation follows industry best practices and standards:

- **[OAuth 2.0 Best Current Practice (BCP)](https://datatracker.ietf.org/doc/html/draft-ietf-oauth-security-topics)**: Token rotation and reuse detection
- **[RFC 7519 (JWT)](https://datatracker.ietf.org/doc/html/rfc7519)**: JSON Web Token standard
- **[RFC 6750 (Bearer Token)](https://datatracker.ietf.org/doc/html/rfc6750)**: OAuth 2.0 Bearer Token usage
- **[OWASP Authentication Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html)**: Security best practices

**Additional Resources:**

- [Auth0: Refresh Token Rotation](https://auth0.com/docs/secure/tokens/refresh-tokens/refresh-token-rotation)
- [OWASP: JSON Web Token Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/JSON_Web_Token_for_Java_Cheat_Sheet.html)

## Next Steps

- 📚 [Rate Limiting](RATE_LIMITING.md) - Protect auth endpoints
- 🔍 [Error Handling](ERROR_HANDLING.md) - Understand auth error responses
- 🐳 [Docker Guide](DOCKER.md) - Deploy with proper secrets
- 📊 [Swagger API Docs](SWAGGER.md) - Interactive API testing
