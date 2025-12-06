# Role-Based Access Control (RBAC)

## Overview

The GRAB API implements a flexible Role-Based Access Control (RBAC) system using a many-to-many relationship between users and roles. This allows fine-grained permission management and easy role assignment.

## Architecture

### Database Schema

```text
┌─────────┐         ┌──────────────┐         ┌───────┐
│  users  │────────→│  user_roles  │←────────│ roles │
└─────────┘         └──────────────┘         └───────┘
     1                    N     N                  1
```

**Tables:**

- `roles` - Stores available roles (user, admin)
- `user_roles` - Junction table linking users to roles
- `users` - User accounts with many-to-many relationship to roles

### Built-in Roles

| Role    | Description                         | Auto-assigned |
|---------|-------------------------------------|---------------|
| `user`  | Standard user with basic access     | ✅ Yes        |
| `admin` | Administrator with elevated access  | ❌ No         |

## Default Behavior

### Auto-Assignment

When a user registers, they are automatically assigned the `user` role:

```bash
POST /api/v1/auth/register
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "secure123"
}

# Response includes roles
{
  "success": true,
  "data": {
    "user": {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com",
      "roles": ["user"]  # ← Auto-assigned
    },
    "access_token": "...",
    "refresh_token": "..."
  }
}
```

## Admin Management

### Creating Admins

#### Option 1: Interactive CLI (Recommended)

```bash
make create-admin
```

This will prompt you for:
- Email address
- Full name
- Password (hidden input)
- Password confirmation

Example:

```text
$ make create-admin
Enter admin email: admin@example.com
Enter admin name: Admin User
Enter admin password: ********
Confirm password: ********

Admin user created successfully:
ID: 1
Email: admin@example.com
Name: Admin User
Roles: admin, user
```

#### Option 2: Promote Existing User

```bash
make promote-admin ID=5
```

Output:

```text
Successfully promoted John Doe (john@example.com) to admin
```

### Docker Environment

Both commands work in Docker:

```bash
# Interactive mode in Docker
docker exec -it grab-app make create-admin

# Promote mode in Docker
docker exec -it grab-app make promote-admin ID=5
```

## Endpoint Access Control

### Public Endpoints

No authentication required:

```text
POST /api/v1/auth/register  # Anyone can register
POST /api/v1/auth/login     # Anyone can login
```

### User Endpoints

Require authentication (any logged-in user):

```text
GET  /api/v1/auth/me        # View own profile
POST /api/v1/auth/refresh   # Refresh access token
POST /api/v1/auth/logout    # Logout
PUT  /api/v1/users/:id      # Update own profile only
DEL  /api/v1/users/:id      # Delete own account only
```

### Admin Endpoints

Require admin role (`RequireAdmin` middleware):

```text
GET /api/v1/users           # List all users
GET /api/v1/users/:id       # View any user profile
PUT /api/v1/users/:id       # Update any user profile
DEL /api/v1/users/:id       # Delete any user
```

### Access Rules Comparison

| Action                    | User Role | Admin Role |
|---------------------------|-----------|------------|
| View own profile          | ✅ Yes    | ✅ Yes     |
| Update own profile        | ✅ Yes    | ✅ Yes     |
| Delete own account        | ✅ Yes    | ✅ Yes     |
| View other user profiles  | ❌ No     | ✅ Yes     |
| List all users            | ❌ No     | ✅ Yes     |
| Update other users        | ❌ No     | ✅ Yes     |
| Delete other users        | ❌ No     | ✅ Yes     |

## API Examples

### Get Current User Profile

```bash
curl -X GET http://localhost:8080/api/v1/auth/me \
  -H "Authorization: Bearer <access_token>"
```

Response:

```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "roles": ["user"],
    "created_at": "2025-11-22T10:00:00Z",
    "updated_at": "2025-11-22T10:00:00Z"
  }
}
```

### List All Users (Admin Only)

```bash
curl -X GET "http://localhost:8080/api/v1/users?page=1&per_page=20&role=user&search=john&sort=created_at&order=desc" \
  -H "Authorization: Bearer <admin_access_token>"
```

Query Parameters:

- `page` - Page number (default: 1)
- `per_page` - Items per page (default: 20, max: 100)
- `role` - Filter by role (user, admin)
- `search` - Search in name or email
- `sort` - Sort field (created_at, name, email)
- `order` - Sort order (asc, desc)

Response:

```json
{
  "success": true,
  "data": {
    "users": [
      {
        "id": 1,
        "name": "John Doe",
        "email": "john@example.com",
        "roles": ["user"],
        "created_at": "2025-11-22T10:00:00Z",
        "updated_at": "2025-11-22T10:00:00Z"
      },
      {
        "id": 2,
        "name": "Admin User",
        "email": "admin@example.com",
        "roles": ["user", "admin"],
        "created_at": "2025-11-22T09:00:00Z",
        "updated_at": "2025-11-22T09:00:00Z"
      }
    ],
    "total": 2,
    "page": 1,
    "per_page": 20,
    "total_pages": 1
  }
}
```

### Get Any User Profile (Admin)

```bash
# Admin can access any user
curl -X GET http://localhost:8080/api/v1/users/5 \
  -H "Authorization: Bearer <admin_access_token>"
```

### Access Denied Example

```bash
# Regular user trying to list all users
curl -X GET http://localhost:8080/api/v1/users \
  -H "Authorization: Bearer <user_access_token>"
```

Response (403 Forbidden):

```json
{
  "success": false,
  "error": {
    "code": "FORBIDDEN",
    "message": "insufficient permissions",
    "timestamp": "2025-11-22T15:30:00Z",
    "path": "/api/v1/users",
    "request_id": "abc123"
  }
}
```

## JWT Token Structure

Access tokens include roles in the payload:

```json
{
  "user_id": 1,
  "email": "john@example.com",
  "name": "John Doe",
  "roles": ["user"],
  "exp": 1700000000,
  "iat": 1699996400
}
```

## Implementation Details

### Middleware Usage

```go
// routes/router.go

// Admin-only endpoint
router.GET("/users", 
    middleware.RequireAdmin(),  // Checks for admin role
    userHandler.ListUsers,
)

// Custom role requirement
router.GET("/reports", 
    middleware.RequireRole("analyst"),  // Custom role
    reportHandler.List,
)
```

### Context Helpers

Check roles in handler code:

```go
func (h *Handler) SomeHandler(c *gin.Context) {
    // Check if user is admin
    if contextutil.IsAdmin(c) {
        // Admin-specific logic
    }
    
    // Check for specific role
    if contextutil.HasRole(c, "moderator") {
        // Moderator-specific logic
    }
    
    // Get all roles
    roles := contextutil.GetRoles(c)
}
```

### User Model Methods

```go
// Check if user has specific role
user.HasRole("admin")  // returns bool

// Check if user is admin
user.IsAdmin()  // returns bool

// Get role names
user.GetRoleNames()  // returns []string
```

## Migration

### Applying RBAC Migrations

```bash
# Apply migrations
make migrate-up

# Check migration status
make migrate-status
```

### Rolling Back

```bash
# Rollback last 2 migrations
make migrate-down STEPS=2
```

### Migration Files

```text
migrations/
├── 20251122153000_create_roles_table.up.sql
├── 20251122153000_create_roles_table.down.sql
├── 20251122153001_create_user_roles_table.up.sql
└── 20251122153001_create_user_roles_table.down.sql
```

## Database Seeding

The roles table is automatically seeded with default roles during migration:

```sql
INSERT INTO roles (id, name, description) VALUES
(1, 'user', 'Standard user with basic permissions'),
(2, 'admin', 'Administrator with full system access');
```

## Security Considerations

### Best Practices

1. **Never hardcode admin credentials** - Always use the CLI tool
2. **Rotate admin passwords regularly** - Update via update user endpoint
3. **Limit admin accounts** - Only promote trusted users
4. **Audit admin actions** - Monitor admin endpoint access in logs
5. **Use refresh tokens** - Short-lived access tokens with role claims

### Role Verification

Roles are verified on every request:

1. JWT is decoded and validated
2. Roles are extracted from token claims
3. Middleware checks required role
4. Request is allowed or denied (403)

### Database Integrity

- Foreign keys ensure referential integrity
- Composite primary key prevents duplicate role assignments
- CASCADE delete removes role assignments when user/role is deleted

## Troubleshooting

### User has no roles

**Problem:** User registered before RBAC system was implemented.

**Solution:**

```bash
# Assign user role
make promote-admin ID=<user_id>

# Or use direct SQL (production environments)
INSERT INTO user_roles (user_id, role_id, assigned_at) 
VALUES (<user_id>, 1, NOW())
ON CONFLICT DO NOTHING;
```

### Cannot create admin

**Problem:** Database not migrated or role seeding failed.

**Solution:**

```bash
# Check migrations
make migrate-status

# Re-run migrations if needed
make migrate-up

# Verify roles exist
docker exec -it grab-db psql -U grab -d grab -c "SELECT * FROM roles;"
```

### 403 Forbidden despite being admin

**Problem:** Token was generated before user was promoted to admin.

**Solution:**

```bash
# User needs to login again to get new token with admin role
POST /api/v1/auth/login
{
  "email": "admin@example.com",
  "password": "password"
}
```

## Advanced Usage

### Adding Custom Roles

#### Step 1: Insert role into database

```sql
INSERT INTO roles (name, description) 
VALUES ('moderator', 'Moderates user content');
```

#### Step 2: Assign to user

```sql
INSERT INTO user_roles (user_id, role_id, assigned_at)
SELECT 5, id, NOW() FROM roles WHERE name = 'moderator';
```

#### Step 3: Use in middleware

```go
router.DELETE("/posts/:id",
    middleware.RequireRole("moderator"),
    postHandler.Delete,
)
```

### Multiple Role Assignment

Users can have multiple roles:

```json
{
  "id": 1,
  "name": "Super User",
  "email": "super@example.com",
  "roles": ["user", "admin", "moderator"]
}
```

## Related Documentation

- [Authentication](AUTHENTICATION.md) - JWT and token management
- [API Response Format](API_RESPONSE_FORMAT.md) - Standard response structure
- [Error Handling](ERROR_HANDLING.md) - Error codes and handling
- [Security Guide](SECURITY_GUIDE.md) - Security best practices
