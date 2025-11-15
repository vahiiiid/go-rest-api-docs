# Error Handling

GRAB implements a comprehensive structured error handling system that provides consistent, machine-readable error responses across the entire API.

!!! info "API Response Format"
    All API responses use a standardized envelope format. See the [API Response Format](API_RESPONSE_FORMAT.md) guide for complete details.

## Overview

The error handling system consists of three main components:

1. **Error Types** (`internal/errors/errors.go`) - Structured error definitions
2. **Error Codes** (`internal/errors/codes.go`) - Machine-readable error constants
3. **Error Middleware** (`internal/errors/middleware.go`) - Centralized error processing
4. **Response Envelope** (`internal/errors/response.go`) - Standardized response wrapper

## Error Response Structure

All API errors follow a consistent JSON structure wrapped in a response envelope:

```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message",
    "details": "Optional additional context",
    "timestamp": "2024-11-13T20:00:00Z",
    "path": "/api/v1/endpoint",
    "request_id": "req_abc123"
  }
}
```

### Response Fields

- **`success`** (boolean, required): Always `false` for error responses
- **`error`** (object, required): Contains detailed error information

### Error Object Fields

- **`code`** (string, required): Machine-readable error code for client-side error handling
- **`message`** (string, required): Human-readable error description
- **`details`** (any, optional): Additional error context (e.g., validation field errors, debug information)
- **`timestamp`** (string, required): ISO 8601 timestamp when error occurred
- **`path`** (string, required): API endpoint path where error occurred
- **`request_id`** (string, required): Unique request identifier for troubleshooting

## Error Codes

GRAB defines the following standard error codes:

| Code | HTTP Status | Description |
|------|-------------|-------------|
| `INTERNAL_ERROR` | 500 | Internal server error occurred |
| `NOT_FOUND` | 404 | Requested resource was not found |
| `UNAUTHORIZED` | 401 | Authentication is required or failed |
| `FORBIDDEN` | 403 | User lacks permission to access resource |
| `VALIDATION_ERROR` | 400 | Request validation failed |
| `CONFLICT` | 409 | Resource conflict (e.g., duplicate email) |
| `TOO_MANY_REQUESTS` | 429 | Rate limit exceeded |

## Error Examples

### 404 Not Found

```json
{
  "success": false,
  "error": {
    "code": "NOT_FOUND",
    "message": "User not found",
    "timestamp": "2024-11-13T20:00:00Z",
    "path": "/api/v1/users/999",
    "request_id": "req_abc123"
  }
}
```

**Curl Example:**
```bash
curl -X GET http://localhost:8080/api/v1/users/999 \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### 400 Validation Error

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": {
      "Email": "Email must be a valid email address",
      "Password": "Password is too short (minimum 6)"
    },
    "timestamp": "2024-11-13T20:00:00Z",
    "path": "/api/v1/auth/register",
    "request_id": "req_def456"
  }
}
```

**Curl Example:**
```bash
curl -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "invalid-email",
    "password": "123"
  }'
```

### 401 Unauthorized

```json
{
  "success": false,
  "error": {
    "code": "UNAUTHORIZED",
    "message": "Invalid email or password",
    "timestamp": "2024-11-13T20:00:00Z",
    "path": "/api/v1/auth/login",
    "request_id": "req_ghi789"
  }
}
```

**Curl Example:**
```bash
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "wrongpassword"
  }'
```

### 403 Forbidden

```json
{
  "success": false,
  "error": {
    "code": "FORBIDDEN",
    "message": "Forbidden user ID",
    "timestamp": "2024-11-13T20:00:00Z",
    "path": "/api/v1/users/5",
    "request_id": "req_jkl012"
  }
}
```

**Curl Example:**
```bash
curl -X GET http://localhost:8080/api/v1/users/5 \
  -H "Authorization: Bearer YOUR_TOKEN"
# Attempting to access another user's data
```

### 409 Conflict

```json
{
  "success": false,
  "error": {
    "code": "CONFLICT",
    "message": "Email already exists",
    "timestamp": "2024-11-13T20:00:00Z",
    "path": "/api/v1/auth/register",
    "request_id": "req_mno345"
  }
}
```

**Curl Example:**
```bash
curl -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Jane Doe",
    "email": "existing@example.com",
    "password": "password123"
  }'
```

### 429 Rate Limit Exceeded

```json
{
  "success": false,
  "error": {
    "code": "TOO_MANY_REQUESTS",
    "message": "Rate limit exceeded",
    "details": {
      "retry_after": 60,
      "limit": 10,
      "window": "1m"
    },
    "timestamp": "2024-11-13T20:00:00Z",
    "path": "/api/v1/auth/login",
    "request_id": "req_pqr678"
  }
}
```

**Curl Example:**
```bash
# Make 11 rapid requests (rate limit is 10 per minute)
for i in {1..11}; do
  curl -X POST http://localhost:8080/api/v1/auth/login \
    -H "Content-Type: application/json" \
    -d '{"email":"user@example.com","password":"password123"}'
done
```

**Response Headers:**
```
X-RateLimit-Limit: 10
X-RateLimit-Remaining: 0
X-RateLimit-Reset: 1698765432
```

### 500 Internal Server Error

```json
{
  "success": false,
  "error": {
    "code": "INTERNAL_ERROR",
    "message": "Internal server error",
    "details": "database connection failed",
    "timestamp": "2024-11-13T20:00:00Z",
    "path": "/api/v1/users",
    "request_id": "req_stu901"
  }
}
```

## Using Errors in Handlers

### Basic Error Usage

```go
package user

import (
    "github.com/gin-gonic/gin"
    apiErrors "github.com/vahiiiid/go-rest-api-boilerplate/internal/errors"
)

func (h *Handler) GetUser(c *gin.Context) {
    user, err := h.service.GetUserByID(ctx, id)
    if err != nil {
        if errors.Is(err, ErrUserNotFound) {
            _ = c.Error(apiErrors.NotFound("User not found"))
            return
        }
        _ = c.Error(apiErrors.InternalServerError(err))
        return
    }
    
    c.JSON(http.StatusOK, ToUserResponse(user))
}
```

### Validation Errors

```go
func (h *Handler) Register(c *gin.Context) {
    var req RegisterRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        // Automatically converts validator errors to structured format
        _ = c.Error(apiErrors.FromGinValidation(err))
        return
    }
    
    // Process registration...
}
```

**Validation Error Response:**
```json
{
  "code": "VALIDATION_ERROR",
  "message": "Validation failed",
  "details": {
    "Name": "Name is required",
    "Email": "Email must be a valid email address",
    "Password": "Password is too short (minimum 6)"
  }
}
```

### Custom Error Details

```go
func (h *Handler) UpdateUser(c *gin.Context) {
    if !canAccess {
        _ = c.Error(apiErrors.Forbidden("Forbidden user ID"))
        return
    }
    
    user, err := h.service.UpdateUser(ctx, id, req)
    if err != nil {
        if errors.Is(err, ErrEmailExists) {
            _ = c.Error(apiErrors.Conflict("Email already exists"))
            return
        }
        _ = c.Error(apiErrors.InternalServerError(err))
        return
    }
    
    c.JSON(http.StatusOK, ToUserResponse(user))
}
```

## Error Constructor Reference

| Function | HTTP Status | Use Case |
|----------|-------------|----------|
| `NotFound(message)` | 404 | Resource not found |
| `BadRequest(message)` | 400 | Invalid request format |
| `Unauthorized(message)` | 401 | Authentication failure |
| `Forbidden(message)` | 403 | Authorization failure |
| `Conflict(message)` | 409 | Resource conflict |
| `InternalServerError(err)` | 500 | Unexpected server errors |
| `ValidationError(details)` | 400 | Custom validation with details |
| `FromGinValidation(err)` | 400 | Gin/validator error conversion |
| `TooManyRequests(seconds)` | 429 | Rate limit (with retry-after) |

## Client-Side Error Handling

### JavaScript/TypeScript Example

```typescript
interface APIError {
  code: string;
  message: string;
  details?: any;
}

interface ErrorResponse {
  success: false;
  error: APIError;
}

async function loginUser(email: string, password: string) {
  try {
    const response = await fetch('/api/v1/auth/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password })
    });
    
    if (!response.ok) {
      const errorResponse: ErrorResponse = await response.json();
      const error = errorResponse.error;
      
      switch (error.code) {
        case 'UNAUTHORIZED':
          alert('Invalid credentials');
          break;
        case 'VALIDATION_ERROR':
          displayValidationErrors(error.details);
          break;
        case 'TOO_MANY_REQUESTS':
          alert(`Rate limit exceeded. ${error.details}`);
          break;
        default:
          alert('An error occurred: ' + error.message);
      }
      
      return null;
    }
    
    return await response.json();
  } catch (err) {
    console.error('Network error:', err);
    return null;
  }
}

function displayValidationErrors(details: Record<string, string>) {
  Object.entries(details).forEach(([field, message]) => {
    const inputElement = document.getElementById(field.toLowerCase());
    if (inputElement) {
      inputElement.classList.add('error');
      const errorSpan = document.createElement('span');
      errorSpan.className = 'error-message';
      errorSpan.textContent = message;
      inputElement.parentElement?.appendChild(errorSpan);
    }
  });
}
```

### Python Example

```python
import requests
from typing import Optional, Dict, Any

class APIError(Exception):
    def __init__(self, code: str, message: str, details: Optional[Any] = None):
        self.code = code
        self.message = message
        self.details = details
        super().__init__(self.message)

def login_user(email: str, password: str) -> Optional[Dict]:
    try:
        response = requests.post(
            'http://localhost:8080/api/v1/auth/login',
            json={'email': email, 'password': password}
        )
        
        if not response.ok:
            error_response = response.json()
            error_data = error_response['error']
            raise APIError(
                code=error_data['code'],
                message=error_data['message'],
                details=error_data.get('details')
            )
        
        return response.json()
        
    except APIError as e:
        if e.code == 'UNAUTHORIZED':
            print('Invalid credentials')
        elif e.code == 'VALIDATION_ERROR':
            print(f'Validation errors: {e.details}')
        elif e.code == 'TOO_MANY_REQUESTS':
            print(f'Rate limit exceeded: {e.details}')
        else:
            print(f'Error: {e.message}')
        return None
    except requests.RequestException as e:
        print(f'Network error: {e}')
        return None
```

### Go Client Example

```go
package main

import (
    "bytes"
    "encoding/json"
    "fmt"
    "net/http"
)

type APIError struct {
    Code    string      `json:"code"`
    Message string      `json:"message"`
    Details interface{} `json:"details,omitempty"`
}

func (e *APIError) Error() string {
    return e.Message
}

type ErrorResponse struct {
    Success bool     `json:"success"`
    Error   APIError `json:"error"`
}

func LoginUser(email, password string) (*AuthResponse, error) {
    payload := map[string]string{
        "email":    email,
        "password": password,
    }
    
    jsonData, _ := json.Marshal(payload)
    resp, err := http.Post(
        "http://localhost:8080/api/v1/auth/login",
        "application/json",
        bytes.NewBuffer(jsonData),
    )
    if err != nil {
        return nil, fmt.Errorf("network error: %w", err)
    }
    defer resp.Body.Close()
    
    if resp.StatusCode != http.StatusOK {
        var errResp ErrorResponse
        if err := json.NewDecoder(resp.Body).Decode(&errResp); err != nil {
            return nil, fmt.Errorf("failed to parse error: %w", err)
        }
        
        apiErr := errResp.Error
        switch apiErr.Code {
        case "UNAUTHORIZED":
            return nil, fmt.Errorf("invalid credentials")
        case "VALIDATION_ERROR":
            return nil, fmt.Errorf("validation error: %v", apiErr.Details)
        case "TOO_MANY_REQUESTS":
            return nil, fmt.Errorf("rate limit exceeded: %s", apiErr.Details)
        default:
            return nil, &apiErr
        }
    }
    
    var authResp AuthResponse
    if err := json.NewDecoder(resp.Body).Decode(&authResp); err != nil {
        return nil, fmt.Errorf("failed to parse response: %w", err)
    }
    
    return &authResp, nil
}
```

## Best Practices

### 1. Always Use Structured Errors

❌ **Don't:**
```go
c.JSON(http.StatusNotFound, gin.H{"error": "user not found"})
```

✅ **Do:**
```go
_ = c.Error(apiErrors.NotFound("User not found"))
```

### 2. Handle Specific Errors First

✅ **Do:**
```go
if err != nil {
    // Check specific errors first
    if errors.Is(err, ErrUserNotFound) {
        _ = c.Error(apiErrors.NotFound("User not found"))
        return
    }
    if errors.Is(err, ErrEmailExists) {
        _ = c.Error(apiErrors.Conflict("Email already exists"))
        return
    }
    // Generic error last
    _ = c.Error(apiErrors.InternalServerError(err))
    return
}
```

### 3. Provide Meaningful Error Messages

❌ **Don't:**
```go
_ = c.Error(apiErrors.BadRequest("Error"))
```

✅ **Do:**
```go
_ = c.Error(apiErrors.BadRequest("Invalid user ID format"))
```

### 4. Use Validation Helper for Gin Errors

✅ **Do:**
```go
if err := c.ShouldBindJSON(&req); err != nil {
    // Automatically handles validator.ValidationErrors
    _ = c.Error(apiErrors.FromGinValidation(err))
    return
}
```

### 5. Don't Expose Sensitive Information

❌ **Don't:**
```go
_ = c.Error(apiErrors.InternalServerError(
    errors.New("database password incorrect")
))
```

✅ **Do:**
```go
// Log the detailed error server-side
log.Error("Database connection failed", "error", err.Error())

// Return generic error to client
_ = c.Error(apiErrors.InternalServerError(
    errors.New("database connection failed")
))
```

## Error Logging

All errors are automatically logged by the logger middleware with appropriate log levels:

- **4xx errors**: Logged at `WARN` level
- **5xx errors**: Logged at `ERROR` level

Example log output:
```json
{
  "time": "2025-10-27T20:45:30Z",
  "level": "WARN",
  "msg": "HTTP Request",
  "request_id": "abc123...",
  "method": "POST",
  "path": "/api/v1/auth/login",
  "status": 401,
  "duration": "45ms"
}
{
  "time": "2025-10-27T20:45:30Z",
  "level": "ERROR",
  "msg": "Request error",
  "request_id": "abc123...",
  "error": "Invalid email or password"
}
```

## Testing Error Responses

### Unit Test Example

```go
func TestHandler_GetUser_NotFound(t *testing.T) {
    mockService := &MockService{}
    mockService.On("GetUserByID", mock.Anything, uint(1)).
        Return(nil, user.ErrUserNotFound)
    
    handler := NewHandler(mockService, mockAuthService)
    
    w := httptest.NewRecorder()
    c, _ := gin.CreateTestContext(w)
    c.Params = gin.Params{{Key: "id", Value: "1"}}
    
    handler.GetUser(c)
    errors.ErrorHandler()(c)
    
    assert.Equal(t, http.StatusNotFound, w.Code)
    
    var response map[string]interface{}
    json.Unmarshal(w.Body.Bytes(), &response)
    assert.Equal(t, "NOT_FOUND", response["code"])
    assert.Equal(t, "User not found", response["message"])
}
```

## Related Documentation

- [Authentication](AUTHENTICATION.md) - JWT authentication and token errors
- [Rate Limiting](RATE_LIMITING.md) - Rate limit configuration and errors
- [Logging](LOGGING.md) - Structured logging and error tracking
- [Testing](TESTING.md) - Writing tests for error scenarios

## Further Reading

- [RFC 7807: Problem Details for HTTP APIs](https://www.rfc-editor.org/rfc/rfc7807)
- [API Error Handling Best Practices](https://nordicapis.com/best-practices-api-error-handling/)
- [Go Error Handling](https://go.dev/blog/error-handling-and-go)
