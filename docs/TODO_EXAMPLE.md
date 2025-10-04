# 📝 TODO List Implementation

This guide walks you through implementing a complete TODO list feature from scratch, demonstrating all layers of the clean architecture used in GRAB.

## 🎯 What You'll Build

A fully functional TODO list API with:
- ✅ Create, Read, Update, Delete operations
- ✅ User ownership and authentication
- ✅ Database migrations
- ✅ Swagger documentation
- ✅ Complete CRUD endpoints

## 📋 Prerequisites

- GRAB project set up and running
- Basic understanding of Go
- Familiarity with REST APIs

## 🚀 Implementation Steps

### Step 1: Create Directory Structure

```bash
mkdir -p internal/todo
touch internal/todo/model.go
touch internal/todo/dto.go
touch internal/todo/repository.go
touch internal/todo/service.go
touch internal/todo/handler.go
```

### Step 2: Define Model (`internal/todo/model.go`)

```go
package todo

import (
    "time"
    "gorm.io/gorm"
)

// Todo represents a task in the system
type Todo struct {
    ID          uint           `gorm:"primaryKey" json:"id"`
    Title       string         `gorm:"not null" json:"title"`
    Description string         `gorm:"type:text" json:"description"`
    Completed   bool           `gorm:"default:false" json:"completed"`
    UserID      uint           `gorm:"not null;index" json:"user_id"`
    CreatedAt   time.Time      `json:"created_at"`
    UpdatedAt   time.Time      `json:"updated_at"`
    DeletedAt   gorm.DeletedAt `gorm:"index" json:"-"`
}

// TableName specifies the table name for GORM
func (Todo) TableName() string {
    return "todos"
}
```

**Key Points:**
- `gorm:"primaryKey"` - Defines the primary key
- `gorm:"not null"` - Makes field required
- `gorm:"index"` - Creates database index for faster queries
- `DeletedAt` - Enables soft deletes
- `json:"-"` - Excludes field from JSON responses

### Step 3: Create Migration Files

**`migrations/000002_create_todos_table.up.sql`:**
```sql
CREATE TABLE IF NOT EXISTS todos (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    completed BOOLEAN DEFAULT FALSE,
    user_id INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    
    CONSTRAINT fk_todos_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE
);

CREATE INDEX idx_todos_user_id ON todos(user_id);
CREATE INDEX idx_todos_deleted_at ON todos(deleted_at);
```

**`migrations/000002_create_todos_table.down.sql`:**
```sql
DROP INDEX IF EXISTS idx_todos_deleted_at;
DROP INDEX IF EXISTS idx_todos_user_id;
DROP TABLE IF EXISTS todos;
```

**Create migration:**
```bash
make migrate-create NAME=create_todos_table
```

### Step 4: Define DTOs (`internal/todo/dto.go`)

```go
package todo

import "time"

// CreateTodoRequest represents the request to create a new todo
type CreateTodoRequest struct {
    Title       string `json:"title" binding:"required,min=1,max=255"`
    Description string `json:"description" binding:"max=1000"`
}

// UpdateTodoRequest represents the request to update a todo
type UpdateTodoRequest struct {
    Title       *string `json:"title" binding:"omitempty,min=1,max=255"`
    Description *string `json:"description" binding:"omitempty,max=1000"`
    Completed   *bool   `json:"completed"`
}

// TodoResponse represents a todo in API responses
type TodoResponse struct {
    ID          uint      `json:"id"`
    Title       string    `json:"title"`
    Description string    `json:"description"`
    Completed   bool      `json:"completed"`
    UserID      uint      `json:"user_id"`
    CreatedAt   time.Time `json:"created_at"`
    UpdatedAt   time.Time `json:"updated_at"`
}

// TodoListResponse represents a list of todos
type TodoListResponse struct {
    Todos []TodoResponse `json:"todos"`
    Total int            `json:"total"`
}

// ErrorResponse represents an error response
type ErrorResponse struct {
    Error string `json:"error"`
}

// Helper function to convert model to response
func toTodoResponse(todo *Todo) TodoResponse {
    return TodoResponse{
        ID:          todo.ID,
        Title:       todo.Title,
        Description: todo.Description,
        Completed:   todo.Completed,
        UserID:      todo.UserID,
        CreatedAt:   todo.CreatedAt,
        UpdatedAt:   todo.UpdatedAt,
    }
}
```

**Key Points:**
- `binding:"required"` - Field is mandatory
- `binding:"omitempty"` - Field is optional
- Use pointers for optional fields in updates
- Separate request and response DTOs

### Step 5: Create Repository (`internal/todo/repository.go`)

```go
package todo

import (
    "gorm.io/gorm"
)

// TodoRepository defines the interface for todo data operations
type TodoRepository interface {
    Create(todo *Todo) error
    FindByID(id uint) (*Todo, error)
    FindByUserID(userID uint) ([]Todo, error)
    Update(todo *Todo) error
    Delete(id uint) error
}

// GormTodoRepository implements TodoRepository using GORM
type GormTodoRepository struct {
    db *gorm.DB
}

// NewRepository creates a new todo repository
func NewRepository(db *gorm.DB) TodoRepository {
    return &GormTodoRepository{db: db}
}

// Create inserts a new todo into the database
func (r *GormTodoRepository) Create(todo *Todo) error {
    return r.db.Create(todo).Error
}

// FindByID retrieves a todo by its ID
func (r *GormTodoRepository) FindByID(id uint) (*Todo, error) {
    var todo Todo
    if err := r.db.First(&todo, id).Error; err != nil {
        return nil, err
    }
    return &todo, nil
}

// FindByUserID retrieves all todos for a specific user
func (r *GormTodoRepository) FindByUserID(userID uint) ([]Todo, error) {
    var todos []Todo
    if err := r.db.Where("user_id = ?", userID).Order("created_at DESC").Find(&todos).Error; err != nil {
        return nil, err
    }
    return todos, nil
}

// Update updates an existing todo
func (r *GormTodoRepository) Update(todo *Todo) error {
    return r.db.Save(todo).Error
}

// Delete soft deletes a todo by ID
func (r *GormTodoRepository) Delete(id uint) error {
    return r.db.Delete(&Todo{}, id).Error
}
```

**Key Points:**
- Interface defines contract
- GORM handles SQL generation
- Use parameterized queries (automatic with GORM)
- Soft delete with `DeletedAt`

### Step 6: Implement Service (`internal/todo/service.go`)

```go
package todo

import (
    "errors"
    "gorm.io/gorm"
)

// TodoService handles business logic for todos
type TodoService struct {
    repo TodoRepository
}

// NewService creates a new todo service
func NewService(repo TodoRepository) *TodoService {
    return &TodoService{repo: repo}
}

// CreateTodo creates a new todo for a user
func (s *TodoService) CreateTodo(userID uint, req CreateTodoRequest) (*Todo, error) {
    todo := &Todo{
        Title:       req.Title,
        Description: req.Description,
        Completed:   false,
        UserID:      userID,
    }

    if err := s.repo.Create(todo); err != nil {
        return nil, err
    }

    return todo, nil
}

// GetUserTodos retrieves all todos for a user
func (s *TodoService) GetUserTodos(userID uint) ([]Todo, error) {
    return s.repo.FindByUserID(userID)
}

// GetTodo retrieves a specific todo and verifies ownership
func (s *TodoService) GetTodo(todoID, userID uint) (*Todo, error) {
    todo, err := s.repo.FindByID(todoID)
    if err != nil {
        if errors.Is(err, gorm.ErrRecordNotFound) {
            return nil, errors.New("todo not found")
        }
        return nil, err
    }

    // Verify ownership
    if todo.UserID != userID {
        return nil, errors.New("unauthorized")
    }

    return todo, nil
}

// UpdateTodo updates an existing todo
func (s *TodoService) UpdateTodo(todoID, userID uint, req UpdateTodoRequest) (*Todo, error) {
    // Get and verify ownership
    todo, err := s.GetTodo(todoID, userID)
    if err != nil {
        return nil, err
    }

    // Update fields if provided
    if req.Title != nil {
        todo.Title = *req.Title
    }
    if req.Description != nil {
        todo.Description = *req.Description
    }
    if req.Completed != nil {
        todo.Completed = *req.Completed
    }

    if err := s.repo.Update(todo); err != nil {
        return nil, err
    }

    return todo, nil
}

// DeleteTodo deletes a todo
func (s *TodoService) DeleteTodo(todoID, userID uint) error {
    // Verify ownership
    _, err := s.GetTodo(todoID, userID)
    if err != nil {
        return err
    }

    return s.repo.Delete(todoID)
}
```

**Key Points:**
- Business logic lives here
- Always verify ownership
- Handle errors appropriately
- Keep functions focused and small

### Step 7: Create Handlers (`internal/todo/handler.go`)

```go
package todo

import (
    "errors"
    "net/http"
    "strconv"

    "github.com/gin-gonic/gin"
)

// TodoHandler handles HTTP requests for todos
type TodoHandler struct {
    service *TodoService
}

// NewHandler creates a new todo handler
func NewHandler(service *TodoService) *TodoHandler {
    return &TodoHandler{service: service}
}

// getUserID is a helper to extract user ID from context
func (h *TodoHandler) getUserID(c *gin.Context) (uint, error) {
    userID, exists := c.Get("user_id")
    if !exists {
        return 0, errors.New("user not authenticated")
    }
    return userID.(uint), nil
}

// CreateTodo godoc
// @Summary Create a new todo
// @Description Create a new todo item for the authenticated user
// @Tags todos
// @Accept json
// @Produce json
// @Param todo body CreateTodoRequest true "Todo data"
// @Success 201 {object} TodoResponse
// @Failure 400 {object} ErrorResponse
// @Failure 401 {object} ErrorResponse
// @Security BearerAuth
// @Router /api/v1/todos [post]
func (h *TodoHandler) CreateTodo(c *gin.Context) {
    userID, err := h.getUserID(c)
    if err != nil {
        c.JSON(http.StatusUnauthorized, ErrorResponse{Error: err.Error()})
        return
    }

    var req CreateTodoRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(http.StatusBadRequest, ErrorResponse{Error: err.Error()})
        return
    }

    todo, err := h.service.CreateTodo(userID, req)
    if err != nil {
        c.JSON(http.StatusInternalServerError, ErrorResponse{Error: err.Error()})
        return
    }

    c.JSON(http.StatusCreated, toTodoResponse(todo))
}

// GetTodos godoc
// @Summary Get all todos
// @Description Get all todos for the authenticated user
// @Tags todos
// @Produce json
// @Success 200 {object} TodoListResponse
// @Failure 401 {object} ErrorResponse
// @Security BearerAuth
// @Router /api/v1/todos [get]
func (h *TodoHandler) GetTodos(c *gin.Context) {
    userID, err := h.getUserID(c)
    if err != nil {
        c.JSON(http.StatusUnauthorized, ErrorResponse{Error: err.Error()})
        return
    }

    todos, err := h.service.GetUserTodos(userID)
    if err != nil {
        c.JSON(http.StatusInternalServerError, ErrorResponse{Error: err.Error()})
        return
    }

    responses := make([]TodoResponse, len(todos))
    for i, todo := range todos {
        responses[i] = toTodoResponse(&todo)
    }

    c.JSON(http.StatusOK, TodoListResponse{
        Todos: responses,
        Total: len(responses),
    })
}

// GetTodo godoc
// @Summary Get a todo by ID
// @Description Get a specific todo by ID for the authenticated user
// @Tags todos
// @Produce json
// @Param id path int true "Todo ID"
// @Success 200 {object} TodoResponse
// @Failure 400 {object} ErrorResponse
// @Failure 401 {object} ErrorResponse
// @Failure 404 {object} ErrorResponse
// @Security BearerAuth
// @Router /api/v1/todos/{id} [get]
func (h *TodoHandler) GetTodo(c *gin.Context) {
    userID, err := h.getUserID(c)
    if err != nil {
        c.JSON(http.StatusUnauthorized, ErrorResponse{Error: err.Error()})
        return
    }

    todoID, err := strconv.ParseUint(c.Param("id"), 10, 32)
    if err != nil {
        c.JSON(http.StatusBadRequest, ErrorResponse{Error: "invalid todo ID"})
        return
    }

    todo, err := h.service.GetTodo(uint(todoID), userID)
    if err != nil {
        if err.Error() == "todo not found" {
            c.JSON(http.StatusNotFound, ErrorResponse{Error: err.Error()})
        } else if err.Error() == "unauthorized" {
            c.JSON(http.StatusForbidden, ErrorResponse{Error: err.Error()})
        } else {
            c.JSON(http.StatusInternalServerError, ErrorResponse{Error: err.Error()})
        }
        return
    }

    c.JSON(http.StatusOK, toTodoResponse(todo))
}

// UpdateTodo godoc
// @Summary Update a todo
// @Description Update an existing todo for the authenticated user
// @Tags todos
// @Accept json
// @Produce json
// @Param id path int true "Todo ID"
// @Param todo body UpdateTodoRequest true "Todo update data"
// @Success 200 {object} TodoResponse
// @Failure 400 {object} ErrorResponse
// @Failure 401 {object} ErrorResponse
// @Failure 404 {object} ErrorResponse
// @Security BearerAuth
// @Router /api/v1/todos/{id} [put]
func (h *TodoHandler) UpdateTodo(c *gin.Context) {
    userID, err := h.getUserID(c)
    if err != nil {
        c.JSON(http.StatusUnauthorized, ErrorResponse{Error: err.Error()})
        return
    }

    todoID, err := strconv.ParseUint(c.Param("id"), 10, 32)
    if err != nil {
        c.JSON(http.StatusBadRequest, ErrorResponse{Error: "invalid todo ID"})
        return
    }

    var req UpdateTodoRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(http.StatusBadRequest, ErrorResponse{Error: err.Error()})
        return
    }

    todo, err := h.service.UpdateTodo(uint(todoID), userID, req)
    if err != nil {
        if err.Error() == "todo not found" {
            c.JSON(http.StatusNotFound, ErrorResponse{Error: err.Error()})
        } else if err.Error() == "unauthorized" {
            c.JSON(http.StatusForbidden, ErrorResponse{Error: err.Error()})
        } else {
            c.JSON(http.StatusInternalServerError, ErrorResponse{Error: err.Error()})
        }
        return
    }

    c.JSON(http.StatusOK, toTodoResponse(todo))
}

// DeleteTodo godoc
// @Summary Delete a todo
// @Description Delete a todo for the authenticated user
// @Tags todos
// @Produce json
// @Param id path int true "Todo ID"
// @Success 204
// @Failure 400 {object} ErrorResponse
// @Failure 401 {object} ErrorResponse
// @Failure 404 {object} ErrorResponse
// @Security BearerAuth
// @Router /api/v1/todos/{id} [delete]
func (h *TodoHandler) DeleteTodo(c *gin.Context) {
    userID, err := h.getUserID(c)
    if err != nil {
        c.JSON(http.StatusUnauthorized, ErrorResponse{Error: err.Error()})
        return
    }

    todoID, err := strconv.ParseUint(c.Param("id"), 10, 32)
    if err != nil {
        c.JSON(http.StatusBadRequest, ErrorResponse{Error: "invalid todo ID"})
        return
    }

    if err := h.service.DeleteTodo(uint(todoID), userID); err != nil {
        if err.Error() == "todo not found" {
            c.JSON(http.StatusNotFound, ErrorResponse{Error: err.Error()})
        } else if err.Error() == "unauthorized" {
            c.JSON(http.StatusForbidden, ErrorResponse{Error: err.Error()})
        } else {
            c.JSON(http.StatusInternalServerError, ErrorResponse{Error: err.Error()})
        }
        return
    }

    c.Status(http.StatusNoContent)
}
```

**Key Points:**
- Swagger annotations for documentation
- Proper HTTP status codes
- Error handling for different scenarios
- Extract user ID from JWT context

### Step 8: Register Routes (`internal/server/router.go`)

Add to your router setup:

```go
// Add to imports
import (
    "github.com/vahiiiid/go-rest-api-boilerplate/internal/todo"
)

// In SetupRouter function, after initializing user handler:
func SetupRouter(userHandler *user.UserHandler, authService *auth.AuthService, todoHandler *todo.TodoHandler) *gin.Engine {
    // ... existing code ...

    // Protected routes (requires authentication)
    protected := v1.Group("")
    protected.Use(auth.AuthMiddleware(authService))
    {
        // User routes
        protected.GET("/users", userHandler.ListUsers)
        protected.GET("/users/:id", userHandler.GetUser)
        protected.PUT("/users/:id", userHandler.UpdateUser)
        protected.DELETE("/users/:id", userHandler.DeleteUser)

        // Todo routes (NEW)
        protected.POST("/todos", todoHandler.CreateTodo)
        protected.GET("/todos", todoHandler.GetTodos)
        protected.GET("/todos/:id", todoHandler.GetTodo)
        protected.PUT("/todos/:id", todoHandler.UpdateTodo)
        protected.DELETE("/todos/:id", todoHandler.DeleteTodo)
    }

    return router
}
```

### Step 9: Update Main (`cmd/server/main.go`)

```go
// Add to imports
import (
    "github.com/vahiiiid/go-rest-api-boilerplate/internal/todo"
)

func main() {
    // ... existing code ...

    // Run migrations
    log.Println("Running database migrations...")
    if err := database.AutoMigrate(&user.User{}, &todo.Todo{}); err != nil {
        log.Fatalf("Failed to run migrations: %v", err)
    }
    log.Println("Migrations completed successfully")

    // Initialize services
    authService := auth.NewService()
    userRepo := user.NewRepository(database)
    userService := user.NewService(userRepo)
    userHandler := user.NewHandler(userService, authService)

    // Todo services (NEW)
    todoRepo := todo.NewRepository(database)
    todoService := todo.NewService(todoRepo)
    todoHandler := todo.NewHandler(todoService)

    // Setup router with todo handler
    router := server.SetupRouter(userHandler, authService, todoHandler)

    // ... rest of code ...
}
```

### Step 10: Run Migrations

```bash
# If using AutoMigrate (default)
# Just restart the app, it will auto-create the table

# If using golang-migrate
make migrate-docker-up
```

### Step 11: Test the API

**Create a Todo:**
```bash
# First, register and get token
TOKEN=$(curl -s -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Alice","email":"alice@example.com","password":"secret123"}' \
  | jq -r '.token')

# Create a todo
curl -X POST http://localhost:8080/api/v1/todos \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Buy groceries",
    "description": "Milk, eggs, bread"
  }'
```

**Get All Todos:**
```bash
curl -X GET http://localhost:8080/api/v1/todos \
  -H "Authorization: Bearer $TOKEN"
```

**Update a Todo:**
```bash
curl -X PUT http://localhost:8080/api/v1/todos/1 \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "completed": true
  }'
```

**Delete a Todo:**
```bash
curl -X DELETE http://localhost:8080/api/v1/todos/1 \
  -H "Authorization: Bearer $TOKEN"
```

### Step 12: Regenerate Swagger Docs

```bash
make swag
```

Visit `http://localhost:8080/swagger/index.html` to see the new TODO endpoints!

---

## 🎉 Congratulations!

You've successfully implemented a complete TODO list feature following GRAB's clean architecture! This same pattern can be applied to any new feature you want to add.

## 📚 What You Learned

- ✅ Creating models with GORM
- ✅ Writing database migrations
- ✅ Defining DTOs with validation
- ✅ Implementing repositories
- ✅ Writing business logic in services
- ✅ Creating HTTP handlers
- ✅ Registering routes
- ✅ Adding Swagger documentation
- ✅ Testing with curl

## 🔄 Next Steps

- Add pagination to the list endpoint
- Add filtering (completed/incomplete)
- Add search functionality
- Write unit tests
- Add due dates to todos
- Implement todo categories

## 💡 Tips

- Always verify ownership in services
- Use proper HTTP status codes
- Add Swagger annotations
- Test each layer independently
- Keep functions small and focused
- Handle errors appropriately

---

**Happy Coding! 🚀**

For more details on the architecture and patterns, see the [Development Guide](DEVELOPMENT_GUIDE.md).
