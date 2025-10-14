# 🛠️ Development Guide

A comprehensive guide to understanding the codebase and building new features.

## 📑 Table of Contents

- [Architecture Overview](#-architecture-overview)
- [Configuration System](#-configuration-system)
- [Directory Structure](#-directory-structure)
- [Understanding the Layers](#-understanding-the-layers)
- [How User Management Works](#-how-user-management-works)
- [Adding New Features](#-adding-new-features)
- [Best Practices](#-best-practices)
- [Common Patterns](#-common-patterns)

---

## 🏗️ Architecture Overview

This project follows **Clean Architecture** principles with clear separation of concerns:

```
┌─────────────────────────────────────────────────────────┐
│                    HTTP Layer                           │
│  (Handlers - Receive requests, return responses)        │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│                   Business Layer                        │
│  (Services - Business logic, orchestration)             │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│                   Data Layer                            │
│  (Repositories - Database operations)                   │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│                    Database                             │
│  (PostgreSQL - Data storage)                            │
└─────────────────────────────────────────────────────────┘
```

### Key Principles

1. **Separation of Concerns** - Each layer has one responsibility
2. **Dependency Injection** - Dependencies flow inward
3. **Interface-Based** - Layers communicate through interfaces
4. **Testable** - Each layer can be tested independently
5. **Maintainable** - Easy to understand and modify

---

## ⚙️ Configuration System

The application uses a **Viper-based configuration system** with layered precedence for flexibility and security.

### Configuration Architecture

```text
Environment Variables (.env)          <-- Highest Priority
        ↓ (overrides)
Environment Config (config.{env}.yaml)
        ↓ (overrides)  
Base Config (config.yaml)
        ↓ (overrides)
Default Values (hardcoded)            <-- Lowest Priority
```

### Using Configuration in Code

**Step 1: Load configuration in main.go**

```go
package main

import (
    "github.com/vahiiiid/go-rest-api-boilerplate/internal/config"
)

func main() {
    // Load configuration using Viper
    cfg, err := config.LoadConfig("") // Auto-detects environment
    if err != nil {
        log.Fatalf("Failed to load config: %v", err)
    }

    // Pass typed config to services
    authService := auth.NewService(&cfg.JWT)
    db, err := db.NewPostgresDBFromDatabaseConfig(cfg.Database)
    // ...
}
```

**Step 2: Inject configuration into services**

```go
// Before (manual env reads)
func NewService() Service {
    secret := os.Getenv("JWT_SECRET") // ❌ Direct env access
    // ...
}

// After (typed config injection)
func NewService(cfg *config.JWTConfig) Service {
    secret := cfg.Secret // ✅ Type-safe access
    ttl := time.Duration(cfg.TTLHours) * time.Hour
    // ...
}
```

### Configuration Validation

The config system includes automatic validation:

```go
// Production validations automatically applied
func (c *Config) Validate() error {
    if c.JWT.Secret == "" {
        return fmt.Errorf("JWT secret is required")
    }
    
    if c.App.Environment == "production" {
        if len(c.JWT.Secret) < 32 {
            return fmt.Errorf("JWT secret must be 32+ chars in production")
        }
        if c.Database.SSLMode == "disable" {
            return fmt.Errorf("SSL required in production")
        }
    }
    return nil
}
```

### Testing Configuration

Use the test helper for consistent test configs:

```go
func TestUserService(t *testing.T) {
    // Get pre-configured test config
    cfg := config.NewTestConfig()
    
    // Override specific values if needed
    cfg.JWT.TTLHours = 1
    
    service := NewService(&cfg.JWT)
    // ... test with consistent config
}
```

**📖 Complete configuration reference:** [Configuration Guide](CONFIGURATION.md)

---

## 📁 Directory Structure

```
internal/
├── auth/                   # Authentication & Authorization
│   ├── dto.go             # JWT Claims
│   ├── service.go         # Token generation/validation
│   └── middleware.go      # Auth middleware for routes
│
├── config/                 # Configuration Management (Viper-based)
│   ├── config.go          # Config structs, Viper loading, and validation
│   ├── config_test.go     # Comprehensive configuration tests
│   ├── testing.go         # Test configuration helper
│   └── validator.go       # Configuration validation rules
│
├── db/                     # Database Connection
│   └── db.go              # PostgreSQL connection setup
│
├── middleware/             # HTTP Middleware
│   ├── logger.go          # Request logging middleware
│   ├── logger_test.go     # Logger middleware tests
│   └── README.md          # Middleware documentation
│
├── server/                 # Server & Routing
│   └── router.go          # Route definitions
│
└── user/                   # User Domain (Example Feature)
    ├── model.go           # Database model (GORM)
    ├── dto.go             # Request/Response objects
    ├── repository.go      # Database operations
    ├── service.go         # Business logic
    └── handler.go         # HTTP handlers
```

### File Responsibilities

| File | Purpose | Contains |
|------|---------|----------|
| `model.go` | Database schema | GORM models with tags |
| `dto.go` | Data transfer | Request/Response structs |
| `repository.go` | Data access | CRUD operations |
| `service.go` | Business logic | Validation, orchestration |
| `handler.go` | HTTP layer | Route handlers, Swagger docs |

---

## 🔍 Understanding the Layers

### 1. Model Layer (`model.go`)

**Purpose:** Define database schema using GORM

**Example:**
```go
package user

import (
    "gorm.io/gorm"
    "time"
)

type User struct {
    ID           uint           `gorm:"primaryKey" json:"id"`
    Name         string         `gorm:"not null" json:"name"`
    Email        string         `gorm:"uniqueIndex;not null" json:"email"`
    PasswordHash string         `gorm:"not null" json:"-"`
    CreatedAt    time.Time      `json:"created_at"`
    UpdatedAt    time.Time      `json:"updated_at"`
    DeletedAt    gorm.DeletedAt `gorm:"index" json:"-"`
}
```

**Key Points:**
- Use GORM tags for database constraints
- Use JSON tags for API responses
- Use `json:"-"` to hide sensitive fields
- `gorm.DeletedAt` enables soft deletes

### 2. DTO Layer (`dto.go`)

**Purpose:** Define request/response structures

**Example:**
```go
package user

type RegisterRequest struct {
    Name     string `json:"name" binding:"required,min=2"`
    Email    string `json:"email" binding:"required,email"`
    Password string `json:"password" binding:"required,min=6"`
}

type UserResponse struct {
    ID        uint      `json:"id"`
    Name      string    `json:"name"`
    Email     string    `json:"email"`
    CreatedAt time.Time `json:"created_at"`
}

type ErrorResponse struct {
    Error string `json:"error"`
}
```

**Key Points:**
- Use `binding` tags for validation
- Never expose `PasswordHash` in responses
- Create separate structs for requests/responses
- Use clear, descriptive names

### 3. Repository Layer (`repository.go`)

**Purpose:** Handle all database operations

**Example:**
```go
package user

import (
    "gorm.io/gorm"
)

type UserRepository interface {
    Create(user *User) error
    FindByID(id uint) (*User, error)
    FindByEmail(email string) (*User, error)
    List() ([]User, error)
    Update(user *User) error
    Delete(id uint) error
}

type GormUserRepository struct {
    db *gorm.DB
}

func NewRepository(db *gorm.DB) UserRepository {
    return &GormUserRepository{db: db}
}

func (r *GormUserRepository) Create(user *User) error {
    return r.db.Create(user).Error
}

func (r *GormUserRepository) FindByID(id uint) (*User, error) {
    var user User
    if err := r.db.First(&user, id).Error; err != nil {
        return nil, err
    }
    return &user, nil
}

// ... more methods
```

**Key Points:**
- Define interface first
- Use GORM methods for queries
- Always check for errors
- Return appropriate GORM errors

### 4. Service Layer (`service.go`)

**Purpose:** Implement business logic and orchestration

**Example:**
```go
package user

import (
    "errors"
    "golang.org/x/crypto/bcrypt"
)

type UserService struct {
    repo UserRepository
}

func NewService(repo UserRepository) *UserService {
    return &UserService{repo: repo}
}

func (s *UserService) RegisterUser(req RegisterRequest) (*User, error) {
    // Check if user exists
    existing, _ := s.repo.FindByEmail(req.Email)
    if existing != nil {
        return nil, errors.New("email already exists")
    }

    // Hash password
    hash, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
    if err != nil {
        return nil, err
    }

    // Create user
    user := &User{
        Name:         req.Name,
        Email:        req.Email,
        PasswordHash: string(hash),
    }

    if err := s.repo.Create(user); err != nil {
        return nil, err
    }

    return user, nil
}

// ... more methods
```

**Key Points:**
- Validate business rules
- Orchestrate repository calls
- Handle errors appropriately
- Keep logic testable

### 5. Handler Layer (`handler.go`)

**Purpose:** Handle HTTP requests and responses

**Example:**
```go
package user

import (
    "net/http"
    "github.com/gin-gonic/gin"
)

type UserHandler struct {
    service     *UserService
    authService *auth.AuthService
}

func NewHandler(service *UserService, authService *auth.AuthService) *UserHandler {
    return &UserHandler{
        service:     service,
        authService: authService,
    }
}

// @Summary Register a new user
// @Description Create a new user account
// @Tags auth
// @Accept json
// @Produce json
// @Param user body RegisterRequest true "User registration data"
// @Success 200 {object} TokenResponse
// @Failure 400 {object} ErrorResponse
// @Router /api/v1/auth/register [post]
func (h *UserHandler) Register(c *gin.Context) {
    var req RegisterRequest
    
    // Bind and validate request
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(http.StatusBadRequest, ErrorResponse{Error: err.Error()})
        return
    }

    // Call service
    user, err := h.service.RegisterUser(req)
    if err != nil {
        c.JSON(http.StatusBadRequest, ErrorResponse{Error: err.Error()})
        return
    }

    // Generate token
    token, err := h.authService.GenerateToken(user.ID)
    if err != nil {
        c.JSON(http.StatusInternalServerError, ErrorResponse{Error: "Failed to generate token"})
        return
    }

    // Return response
    c.JSON(http.StatusOK, TokenResponse{
        Token: token,
        User:  toUserResponse(user),
    })
}
```

**Key Points:**
- Bind request data with validation
- Call service layer
- Return appropriate HTTP status codes
- Add Swagger annotations
- Keep handlers thin

---

## 👤 How User Management Works

Let's trace a registration request through all layers:

### Request Flow

```
1. HTTP Request
   POST /api/v1/auth/register
   Body: {"name": "Alice", "email": "alice@example.com", "password": "secret123"}
   
   ↓

2. Handler (handler.go)
   - Binds JSON to RegisterRequest
   - Validates using binding tags
   - Calls service.RegisterUser()
   
   ↓

3. Service (service.go)
   - Checks if email already exists (calls repo.FindByEmail)
   - Hashes password with bcrypt
   - Creates User model
   - Calls repo.Create()
   
   ↓

4. Repository (repository.go)
   - Executes GORM Create
   - Inserts into database
   - Returns user with ID
   
   ↓

5. Back to Service
   - Returns user to handler
   
   ↓

6. Back to Handler
   - Generates JWT token
   - Converts user to UserResponse
   - Returns JSON response
   
   ↓

7. HTTP Response
   {"token": "eyJ...", "user": {"id": 1, "name": "Alice", ...}}
```

### Authentication Flow

Protected endpoints use middleware:

```
1. Request with Header
   Authorization: Bearer eyJhbGc...
   
   ↓

2. Auth Middleware (auth/middleware.go)
   - Extracts token from header
   - Validates JWT signature
   - Parses claims (user ID)
   - Sets user ID in context
   
   ↓

3. Handler
   - Gets user ID from context
   - Proceeds with business logic
```

---

## 🚀 Adding New Features

Follow these steps to add a new feature:

### Step-by-Step Checklist

- [ ] 1. Create domain directory in `internal/`
- [ ] 2. Define model (`model.go`)
- [ ] 3. Create migration files
- [ ] 4. Define DTOs (`dto.go`)
- [ ] 5. Create repository interface and implementation (`repository.go`)
- [ ] 6. Implement business logic (`service.go`)
- [ ] 7. Create HTTP handlers with Swagger docs (`handler.go`)
- [ ] 8. Register routes in `router.go`
- [ ] 9. Update `main.go` for migrations
- [ ] 10. Write tests
- [ ] 11. Update API documentation

---

## 🎯 Best Practices

### 1. Error Handling

**DO:**
```go
if err != nil {
    if errors.Is(err, gorm.ErrRecordNotFound) {
        return nil, errors.New("resource not found")
    }
    return nil, fmt.Errorf("database error: %w", err)
}
```

**DON'T:**
```go
if err != nil {
    panic(err)  // Never panic in production code
}
```

### 2. Validation

**Always validate at multiple layers:**
- **DTO level** - Use binding tags
- **Service level** - Business rules
- **Database level** - Constraints

### 3. Security

**Always:**
- ✅ Hash passwords with bcrypt
- ✅ Validate JWT tokens
- ✅ Check ownership before operations
- ✅ Use parameterized queries (GORM does this)
- ✅ Never expose sensitive data in responses

### 4. Testing

**Test each layer:**
```go
// Repository test (use test database)
func TestCreateTodo(t *testing.T) {
    db := setupTestDB()
    repo := NewRepository(db)
    
    todo := &Todo{Title: "Test", UserID: 1}
    err := repo.Create(todo)
    
    assert.NoError(t, err)
    assert.NotZero(t, todo.ID)
}

// Service test (mock repository)
func TestCreateTodo_Service(t *testing.T) {
    mockRepo := &MockTodoRepository{}
    service := NewService(mockRepo)
    
    mockRepo.On("Create", mock.Anything).Return(nil)
    
    todo, err := service.CreateTodo(1, CreateTodoRequest{Title: "Test"})
    
    assert.NoError(t, err)
    assert.NotNil(t, todo)
}

// Handler test (use httptest)
func TestCreateTodoHandler(t *testing.T) {
    gin.SetMode(gin.TestMode)
    router := gin.New()
    handler := NewHandler(mockService)
    
    router.POST("/todos", handler.CreateTodo)
    
    req := httptest.NewRequest("POST", "/todos", body)
    rec := httptest.NewRecorder()
    
    router.ServeHTTP(rec, req)
    
    assert.Equal(t, http.StatusCreated, rec.Code)
}
```

### 5. Logging

**Add structured logging:**
```go
import "log"

func (s *TodoService) CreateTodo(userID uint, req CreateTodoRequest) (*Todo, error) {
    log.Printf("Creating todo for user %d: %s", userID, req.Title)
    
    // ... business logic ...
    
    log.Printf("Todo created successfully: %d", todo.ID)
    return todo, nil
}
```

---

## 🔄 Common Patterns

### Pagination

```go
type PaginationParams struct {
    Page  int `form:"page" binding:"min=1"`
    Limit int `form:"limit" binding:"min=1,max=100"`
}

func (r *GormTodoRepository) FindByUserIDPaginated(userID uint, params PaginationParams) ([]Todo, int64, error) {
    var todos []Todo
    var total int64
    
    offset := (params.Page - 1) * params.Limit
    
    // Count total
    r.db.Model(&Todo{}).Where("user_id = ?", userID).Count(&total)
    
    // Get paginated results
    err := r.db.Where("user_id = ?", userID).
        Offset(offset).
        Limit(params.Limit).
        Order("created_at DESC").
        Find(&todos).Error
    
    return todos, total, err
}
```

### Filtering

```go
type TodoFilter struct {
    Completed *bool  `form:"completed"`
    Search    string `form:"search"`
}

func (r *GormTodoRepository) FindWithFilter(userID uint, filter TodoFilter) ([]Todo, error) {
    query := r.db.Where("user_id = ?", userID)
    
    if filter.Completed != nil {
        query = query.Where("completed = ?", *filter.Completed)
    }
    
    if filter.Search != "" {
        query = query.Where("title ILIKE ?", "%"+filter.Search+"%")
    }
    
    var todos []Todo
    err := query.Find(&todos).Error
    return todos, err
}
```

### Batch Operations

```go
func (s *TodoService) MarkAllCompleted(userID uint) error {
    return s.repo.db.
        Model(&Todo{}).
        Where("user_id = ? AND completed = ?", userID, false).
        Update("completed", true).
        Error
}
```

### Transactions

```go
func (s *TodoService) BulkCreate(userID uint, todos []CreateTodoRequest) error {
    return s.repo.db.Transaction(func(tx *gorm.DB) error {
        for _, req := range todos {
            todo := &Todo{
                Title:  req.Title,
                UserID: userID,
            }
            if err := tx.Create(todo).Error; err != nil {
                return err // Rollback
            }
        }
        return nil // Commit
    })
}
```

---

## 📚 Additional Resources

### GORM Documentation
- [GORM Guide](https://gorm.io/docs/)
- [Associations](https://gorm.io/docs/belongs_to.html)
- [Hooks](https://gorm.io/docs/hooks.html)

### Gin Documentation
- [Gin Framework](https://gin-gonic.com/docs/)
- [Binding and Validation](https://gin-gonic.com/docs/examples/binding-and-validation/)

### Swagger
- [Swaggo](https://github.com/swaggo/swag)
- [Swagger Spec](https://swagger.io/specification/)

### Testing
- [Testify](https://github.com/stretchr/testify)
- [Go Testing](https://golang.org/pkg/testing/)

---

## 🆘 Getting Help

If you're stuck:

1. Check the example implementations in `internal/user/`
2. Review this guide
3. Check GORM/Gin documentation
4. Look at the tests in `tests/`
5. Open an issue on GitHub

---

## ✅ Checklist for New Features

Before considering your feature complete:

- [ ] Model defined with proper GORM tags
- [ ] Migration files created (up and down)
- [ ] DTOs defined with validation tags
- [ ] Repository interface and implementation
- [ ] Service with business logic
- [ ] Handlers with Swagger annotations
- [ ] Routes registered in router
- [ ] Migration added to main.go
- [ ] Tests written for all layers
- [ ] Swagger docs regenerated
- [ ] API tested with curl/Postman
- [ ] Error cases handled
- [ ] Logging added
- [ ] Documentation updated

---

**Happy Coding! 🚀**

Remember: Start simple, test often, and refactor as needed. The architecture supports growth and change!

