# API Response Format

## Overview

GRAB implements a **standardized response envelope format** for all API endpoints, ensuring consistent and predictable responses across the entire API. This design follows industry best practices inspired by JSend and provides a unified structure for both successful and error responses.

## Design Philosophy

Our response format is designed with these principles in mind:

- **Consistency**: All responses follow the same envelope structure
- **Machine-Readable**: Clear success/failure indicators for programmatic handling
- **Predictable**: Clients always know what to expect
- **Extensible**: Support for metadata and pagination
- **Type-Safe**: Well-defined structures for different scenarios

## Response Envelope Structure

All API responses (except 204 No Content) are wrapped in a standardized envelope:

```json
{
  "success": boolean,
  "data": object | null,
  "error": object | null,
  "meta": object | null
}
```

### Fields

| Field | Type | Description |
|-------|------|-------------|
| `success` | boolean | Always present. `true` for successful requests, `false` for errors |
| `data` | object \| null | Present on success (2xx responses). Contains the response payload |
| `error` | object \| null | Present on failure (4xx/5xx responses). Contains error details |
| `meta` | object \| null | Optional. Contains metadata like pagination, timestamps, request tracking |

### Key Characteristics

✅ **Always includes `success` field** - Clients can immediately determine success/failure  
✅ **Mutual exclusivity** - Either `data` or `error` is present, never both  
✅ **Consistent structure** - Same envelope for all endpoints  
✅ **HTTP status aligned** - `success: true` for 2xx, `success: false` for 4xx/5xx  

## Success Responses (2xx)

Successful API calls return responses with `success: true` and populated `data` field.

### Basic Success Response

```json
{
  "success": true,
  "data": {
    "id": 1,
    "email": "user@example.com",
    "name": "John Doe"
  }
}
```

**HTTP Status**: 200 OK

### Success with Metadata

Responses can include optional metadata for tracking and pagination:

```json
{
  "success": true,
  "data": [
    {"id": 1, "name": "Item 1"},
    {"id": 2, "name": "Item 2"}
  ],
  "meta": {
    "request_id": "abc123",
    "timestamp": "2024-11-13T20:00:00Z",
    "page": 1,
    "per_page": 20,
    "total": 42,
    "total_pages": 3,
    "links": {
      "self": "/api/v1/items?page=1",
      "next": "/api/v1/items?page=2",
      "prev": null,
      "first": "/api/v1/items?page=1",
      "last": "/api/v1/items?page=3"
    }
  }
}
```

**HTTP Status**: 200 OK

### No Content (204)

DELETE operations and similar actions that don't return data use HTTP 204 with no response body:

**HTTP Status**: 204 No Content  
**Body**: (empty)

## Error Responses (4xx/5xx)

Error responses use `success: false` and provide detailed error information in the `error` object.

### Error Structure

```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message",
    "details": "Optional additional context",
    "timestamp": "2024-11-13T20:00:00Z",
    "path": "/api/v1/endpoint",
    "request_id": "abc123"
  }
}
```

### Error Fields

| Field | Type | Description |
|-------|------|-------------|
| `code` | string | Machine-readable error code (e.g., `VALIDATION_ERROR`, `NOT_FOUND`) |
| `message` | string | Human-readable error description |
| `details` | any | Optional. Additional context (validation errors, stack traces in dev) |
| `timestamp` | string | ISO 8601 timestamp when error occurred |
| `path` | string | API endpoint path where error occurred |
| `request_id` | string | Unique request identifier for troubleshooting |

### Error Examples

#### 400 Validation Error

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
    "request_id": "req_abc123"
  }
}
```

**HTTP Status**: 400 Bad Request

#### 401 Unauthorized

```json
{
  "success": false,
  "error": {
    "code": "UNAUTHORIZED",
    "message": "Invalid or expired refresh token",
    "timestamp": "2024-11-13T20:00:00Z",
    "path": "/api/v1/auth/refresh",
    "request_id": "req_def456"
  }
}
```

**HTTP Status**: 401 Unauthorized

#### 403 Forbidden

```json
{
  "success": false,
  "error": {
    "code": "FORBIDDEN",
    "message": "Forbidden user ID",
    "timestamp": "2024-11-13T20:00:00Z",
    "path": "/api/v1/users/42",
    "request_id": "req_ghi789"
  }
}
```

**HTTP Status**: 403 Forbidden

#### 404 Not Found

```json
{
  "success": false,
  "error": {
    "code": "NOT_FOUND",
    "message": "User not found",
    "timestamp": "2024-11-13T20:00:00Z",
    "path": "/api/v1/users/999",
    "request_id": "req_jkl012"
  }
}
```

**HTTP Status**: 404 Not Found

#### 409 Conflict

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

**HTTP Status**: 409 Conflict

#### 429 Rate Limit Exceeded

```json
{
  "success": false,
  "error": {
    "code": "TOO_MANY_REQUESTS",
    "message": "Rate limit exceeded. Try again in 60 seconds",
    "details": {
      "retry_after": 60,
      "limit": 100,
      "window": "1m"
    },
    "timestamp": "2024-11-13T20:00:00Z",
    "path": "/api/v1/users/1",
    "request_id": "req_pqr678"
  }
}
```

**HTTP Status**: 429 Too Many Requests

#### 500 Internal Server Error

```json
{
  "success": false,
  "error": {
    "code": "INTERNAL_ERROR",
    "message": "An internal error occurred",
    "timestamp": "2024-11-13T20:00:00Z",
    "path": "/api/v1/users",
    "request_id": "req_stu901"
  }
}
```

**HTTP Status**: 500 Internal Server Error

## Real-World Examples

### User Registration

**Request:**
```http
POST /api/v1/auth/register
Content-Type: application/json

{
  "email": "john.doe@example.com",
  "password": "SecurePassword123!",
  "name": "John Doe"
}
```

**Success Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": 1,
      "email": "john.doe@example.com",
      "name": "John Doe"
    },
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refresh_token": "8f7a3c2b1e9d4a5f6c8b7e3a2f1d9c8b...",
    "token_type": "Bearer",
    "expires_in": 900
  }
}
```

### User Login

**Request:**
```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "john.doe@example.com",
  "password": "SecurePassword123!"
}
```

**Success Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": 1,
      "email": "john.doe@example.com",
      "name": "John Doe"
    },
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refresh_token": "8f7a3c2b1e9d4a5f6c8b7e3a2f1d9c8b...",
    "token_type": "Bearer",
    "expires_in": 900
  }
}
```

**Error Response (401 Unauthorized):**
```json
{
  "success": false,
  "error": {
    "code": "UNAUTHORIZED",
    "message": "Invalid email or password",
    "timestamp": "2024-11-13T20:00:00Z",
    "path": "/api/v1/auth/login",
    "request_id": "req_vwx234"
  }
}
```

### Token Refresh

**Request:**
```http
POST /api/v1/auth/refresh
Content-Type: application/json

{
  "refresh_token": "8f7a3c2b1e9d4a5f6c8b7e3a2f1d9c8b..."
}
```

**Success Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refresh_token": "1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p...",
    "token_type": "Bearer",
    "expires_in": 900
  }
}
```

### Get User by ID

**Request:**
```http
GET /api/v1/users/1
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Success Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "email": "john.doe@example.com",
    "name": "John Doe"
  }
}
```

**Error Response (404 Not Found):**
```json
{
  "success": false,
  "error": {
    "code": "NOT_FOUND",
    "message": "User not found",
    "timestamp": "2024-11-13T20:00:00Z",
    "path": "/api/v1/users/999",
    "request_id": "req_yz0123"
  }
}
```

### Update User

**Request:**
```http
PUT /api/v1/users/1
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "name": "John Updated Doe",
  "email": "john.updated@example.com"
}
```

**Success Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "email": "john.updated@example.com",
    "name": "John Updated Doe"
  }
}
```

### Delete User

**Request:**
```http
DELETE /api/v1/users/1
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Success Response:**
```
HTTP/1.1 204 No Content
```
(No response body for DELETE operations)

### Logout

**Request:**
```http
POST /api/v1/auth/logout
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "refresh_token": "8f7a3c2b1e9d4a5f6c8b7e3a2f1d9c8b..."
}
```

**Success Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "message": "Successfully logged out"
  }
}
```

## Client Implementation Guide

### JavaScript/TypeScript

```typescript
// Type definitions
interface SuccessResponse<T> {
  success: true;
  data: T;
  meta?: ResponseMeta;
}

interface ErrorResponse {
  success: false;
  error: ErrorInfo;
}

interface ErrorInfo {
  code: string;
  message: string;
  details?: any;
  timestamp: string;
  path: string;
  request_id: string;
}

interface ResponseMeta {
  request_id?: string;
  timestamp?: string;
  page?: number;
  per_page?: number;
  total?: number;
  total_pages?: number;
  links?: PaginationLinks;
}

type ApiResponse<T> = SuccessResponse<T> | ErrorResponse;

// API client with response handling
async function apiCall<T>(endpoint: string, options?: RequestInit): Promise<T> {
  const response = await fetch(`http://localhost:8080${endpoint}`, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      ...options?.headers,
    },
  });

  const json: ApiResponse<T> = await response.json();

  if (!json.success) {
    throw new ApiError(json.error);
  }

  return json.data;
}

// Usage example
try {
  const user = await apiCall<User>('/api/v1/users/1', {
    headers: { Authorization: `Bearer ${token}` }
  });
  console.log('User:', user);
} catch (error) {
  if (error instanceof ApiError) {
    console.error('API Error:', error.code, error.message);
    if (error.code === 'UNAUTHORIZED') {
      // Handle authentication error
    }
  }
}
```

### Python

```python
from typing import TypeVar, Generic, Optional, Any
from dataclasses import dataclass
import requests

T = TypeVar('T')

@dataclass
class ErrorInfo:
    code: str
    message: str
    details: Optional[Any] = None
    timestamp: str = ""
    path: str = ""
    request_id: str = ""

@dataclass
class ApiResponse(Generic[T]):
    success: bool
    data: Optional[T] = None
    error: Optional[ErrorInfo] = None
    meta: Optional[dict] = None

class ApiError(Exception):
    def __init__(self, error_info: ErrorInfo):
        self.error_info = error_info
        super().__init__(error_info.message)

def api_call(endpoint: str, method: str = 'GET', **kwargs) -> Any:
    response = requests.request(
        method,
        f'http://localhost:8080{endpoint}',
        **kwargs
    )
    
    json_response = response.json()
    
    if not json_response.get('success'):
        error = ErrorInfo(**json_response['error'])
        raise ApiError(error)
    
    return json_response['data']

# Usage example
try:
    user = api_call('/api/v1/users/1', headers={'Authorization': f'Bearer {token}'})
    print(f'User: {user}')
except ApiError as e:
    print(f'API Error: {e.error_info.code} - {e.error_info.message}')
    if e.error_info.code == 'UNAUTHORIZED':
        # Handle authentication error
        pass
```

### Go

```go
package main

import (
	"encoding/json"
	"fmt"
	"net/http"
)

// Response envelope
type Response struct {
	Success bool            `json:"success"`
	Data    json.RawMessage `json:"data,omitempty"`
	Error   *ErrorInfo      `json:"error,omitempty"`
	Meta    *ResponseMeta   `json:"meta,omitempty"`
}

type ErrorInfo struct {
	Code      string      `json:"code"`
	Message   string      `json:"message"`
	Details   interface{} `json:"details,omitempty"`
	Timestamp string      `json:"timestamp"`
	Path      string      `json:"path"`
	RequestID string      `json:"request_id"`
}

type ResponseMeta struct {
	RequestID  string `json:"request_id,omitempty"`
	Timestamp  string `json:"timestamp,omitempty"`
	Page       int    `json:"page,omitempty"`
	PerPage    int    `json:"per_page,omitempty"`
	Total      int64  `json:"total,omitempty"`
	TotalPages int    `json:"total_pages,omitempty"`
}

// API client
func apiCall(endpoint string, result interface{}, token string) error {
	req, _ := http.NewRequest("GET", "http://localhost:8080"+endpoint, nil)
	req.Header.Set("Authorization", "Bearer "+token)
	
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	
	var apiResp Response
	if err := json.NewDecoder(resp.Body).Decode(&apiResp); err != nil {
		return err
	}
	
	if !apiResp.Success {
		return fmt.Errorf("%s: %s", apiResp.Error.Code, apiResp.Error.Message)
	}
	
	return json.Unmarshal(apiResp.Data, result)
}

// Usage
type User struct {
	ID    int    `json:"id"`
	Email string `json:"email"`
	Name  string `json:"name"`
}

func main() {
	var user User
	if err := apiCall("/api/v1/users/1", &user, "your-token"); err != nil {
		fmt.Println("Error:", err)
		return
	}
	fmt.Printf("User: %+v\n", user)
}
```

## Standards & Compliance

### Inspired by JSend

Our response format is inspired by the [JSend specification](https://github.com/omniti-labs/jsend) with enhancements for:

- **Request tracking** - `request_id` for debugging and auditing
- **Timestamps** - ISO 8601 timestamps for error occurrence
- **Path context** - Error location within the API
- **Rich metadata** - Pagination, HATEOAS links, and custom metadata

### HTTP Status Code Alignment

| HTTP Status | `success` Value | Contains |
|-------------|-----------------|----------|
| 200 OK | `true` | `data` field with response payload |
| 201 Created | `true` | `data` field with created resource |
| 204 No Content | N/A | Empty body (no envelope) |
| 400 Bad Request | `false` | `error` field with validation details |
| 401 Unauthorized | `false` | `error` field with auth failure |
| 403 Forbidden | `false` | `error` field with permission denial |
| 404 Not Found | `false` | `error` field with not found message |
| 409 Conflict | `false` | `error` field with conflict details |
| 429 Too Many Requests | `false` | `error` field with rate limit info |
| 500 Internal Server Error | `false` | `error` field with generic message |

## Migration Guide

### From Direct Responses

**Before (v1.x):**
```json
{
  "id": 1,
  "email": "user@example.com",
  "name": "John Doe"
}
```

**After (v2.0+):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "email": "user@example.com",
    "name": "John Doe"
  }
}
```

### Client Update Required

**Before:**
```javascript
const response = await fetch('/api/v1/users/1');
const user = await response.json();
console.log(user.email); // Direct access
```

**After:**
```javascript
const response = await fetch('/api/v1/users/1');
const envelope = await response.json();
if (envelope.success) {
  const user = envelope.data;
  console.log(user.email); // Access via data field
}
```

## Best Practices

### For API Consumers

1. **Always check `success` field first** before accessing data
2. **Use type-safe response interfaces** in typed languages
3. **Log `request_id` from errors** for support requests
4. **Handle error codes programmatically** rather than parsing messages
5. **Implement retry logic** for 429 Rate Limit responses using `retry_after`

### For API Developers

1. **Never mix data and error** in the same response
2. **Always provide error codes** for machine-readable error handling
3. **Include request_id** in error responses for traceability
4. **Use appropriate HTTP status codes** aligned with success/error state
5. **Document breaking changes** in API versioning

## Troubleshooting

### Request ID Not in Response

Ensure the error middleware is properly configured and the request context includes the request ID.

### Missing `success` Field

Check that all handlers use the `errors.Success()` wrapper for successful responses and that the error middleware is registered.

### Inconsistent Error Format

Verify that all error handlers use the centralized error middleware and `errors.APIError` types rather than direct JSON responses.

## Related Documentation

- [Error Handling](ERROR_HANDLING.md) - Detailed error codes and handling
- [Authentication](AUTHENTICATION.md) - Auth response examples
- [API Reference](SWAGGER.md) - Complete API endpoint documentation
- [Testing](TESTING.md) - How to test response formats

## Version History

- **v2.0.0** (2024-11-13): Introduced standardized response envelope format
- **v1.x**: Legacy direct response format (deprecated)
