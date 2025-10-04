# Testing Guide

Comprehensive guide to testing in the Go REST API Boilerplate (GRAB) project.

---

## 📋 Testing Philosophy

GRAB follows a **pragmatic testing approach** that balances thoroughness with maintainability:

- ✅ **Integration tests** for critical API flows
- ✅ **Unit tests** for complex business logic
- ✅ **Fast execution** using in-memory databases
- ✅ **No external dependencies** for CI/CD
- ✅ **Table-driven tests** for multiple scenarios

---

## 🎯 Types of Tests

### 1. Integration Tests

**Location**: `tests/` directory

**Purpose**: Test the complete request/response cycle including handlers, services, and repositories.

**When to use**:
- Testing API endpoints end-to-end
- Verifying authentication flows
- Testing CRUD operations
- Validating error responses

**Example**:
```go
func TestRegisterUser(t *testing.T) {
    db := setupTestDB(t)
    router := server.SetupRouter(db)
    
    req := httptest.NewRequest("POST", "/api/v1/auth/register", body)
    w := httptest.NewRecorder()
    router.ServeHTTP(w, req)
    
    assert.Equal(t, http.StatusOK, w.Code)
}
```

### 2. Unit Tests

**Location**: Alongside the code (e.g., `internal/user/service_test.go`)

**Purpose**: Test individual functions and methods in isolation.

**When to use**:
- Testing business logic
- Testing utility functions
- Testing validation logic
- Testing error handling

**Example**:
```go
// internal/user/service_test.go
func TestValidateEmail(t *testing.T) {
    tests := []struct {
        name    string
        email   string
        wantErr bool
    }{
        {"valid", "user@example.com", false},
        {"invalid", "not-an-email", true},
    }
    
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            err := validateEmail(tt.email)
            if (err != nil) != tt.wantErr {
                t.Errorf("got error %v, wantErr %v", err, tt.wantErr)
            }
        })
    }
}
```

### 3. End-to-End Tests (Future)

**Location**: `e2e/` directory (not yet implemented)

**Purpose**: Test the entire system including database, external services, etc.

**Planned for**: v1.1.0+

---

## ✅ Currently Implemented Tests

### Integration Tests (`tests/handler_test.go`)

#### Authentication Tests

**TestRegisterUser**
- ✅ Successful user registration
- ✅ Duplicate email handling
- ✅ Invalid input validation
- ✅ Password hashing verification
- ✅ JWT token generation

**TestLoginUser**
- ✅ Successful login with correct credentials
- ✅ Failed login with wrong password
- ✅ Failed login with non-existent user
- ✅ JWT token validation

#### User Management Tests

**TestListUsers**
- ✅ List users with authentication
- ✅ Unauthorized access (no token)
- ✅ Invalid token handling

**TestGetUser**
- ✅ Get user by ID with authentication
- ✅ Get non-existent user (404)
- ✅ Unauthorized access

**TestUpdateUser**
- ✅ Update user name and email
- ✅ Unauthorized update attempt
- ✅ Invalid data handling

**TestDeleteUser**
- ✅ Delete user with authentication
- ✅ Delete non-existent user
- ✅ Unauthorized deletion

### Test Helpers

**setupTestDB(t)**
- Creates in-memory SQLite database
- Runs migrations automatically
- Returns configured GORM instance

**createTestUser(t, db)**
- Creates a test user with hashed password
- Returns user object
- Used for authentication tests

**getAuthToken(t, db)**
- Creates test user
- Generates valid JWT token
- Returns token string for authenticated requests

---

## 🚀 Running Tests

### Quick Commands

```bash
# Run all tests
make test

# Run all tests with verbose output
go test -v ./...

# Run tests with coverage
go test -cover ./...

# Run tests with coverage report
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out

# Run specific test
go test -v ./tests -run TestRegisterUser

# Run tests in specific directory
go test ./tests/...
go test ./internal/user/...

# Run tests with race detection
go test -race ./...
```

### CI/CD

Tests run automatically on:
- ✅ Push to `main` branch
- ✅ Push to `develop` branch
- ✅ Pull requests

**GitHub Actions Workflow**: `.github/workflows/ci.yml`

```yaml
- name: Run tests
  run: go test -v ./...

- name: Run linter
  run: golangci-lint run

- name: Check go vet
  run: go vet ./...
```

---

## 📝 Writing New Tests

### Step 1: Determine Test Type

**Integration Test** (tests/)
- Testing API endpoints
- Testing complete flows
- Multiple layers involved

**Unit Test** (internal/)
- Testing single function
- Testing business logic
- Isolated component

### Step 2: Create Test File

```bash
# Integration test
touch tests/my_feature_test.go

# Unit test (alongside code)
touch internal/mypackage/service_test.go
```

### Step 3: Write Test

#### Integration Test Template

```go
package tests

import (
    "bytes"
    "encoding/json"
    "net/http"
    "net/http/httptest"
    "testing"

    "github.com/vahiiiid/go-rest-api-boilerplate/internal/server"
)

func TestMyFeature(t *testing.T) {
    // Setup
    db := setupTestDB(t)
    router := server.SetupRouter(db)
    
    // Prepare request
    payload := map[string]string{
        "field": "value",
    }
    body, _ := json.Marshal(payload)
    
    // Make request
    req := httptest.NewRequest("POST", "/api/v1/endpoint", bytes.NewBuffer(body))
    req.Header.Set("Content-Type", "application/json")
    w := httptest.NewRecorder()
    
    router.ServeHTTP(w, req)
    
    // Assert response
    if w.Code != http.StatusOK {
        t.Errorf("Expected 200, got %d", w.Code)
    }
    
    // Parse response
    var response map[string]interface{}
    if err := json.Unmarshal(w.Body.Bytes(), &response); err != nil {
        t.Fatalf("Failed to parse response: %v", err)
    }
    
    // Validate response data
    if response["field"] != "expected" {
        t.Errorf("Expected 'expected', got '%v'", response["field"])
    }
}
```

#### Unit Test Template

```go
package mypackage

import "testing"

func TestMyFunction(t *testing.T) {
    tests := []struct {
        name     string
        input    string
        expected string
        wantErr  bool
    }{
        {
            name:     "valid input",
            input:    "test",
            expected: "TEST",
            wantErr:  false,
        },
        {
            name:     "empty input",
            input:    "",
            expected: "",
            wantErr:  true,
        },
    }
    
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            result, err := MyFunction(tt.input)
            
            if (err != nil) != tt.wantErr {
                t.Errorf("MyFunction() error = %v, wantErr %v", err, tt.wantErr)
                return
            }
            
            if result != tt.expected {
                t.Errorf("MyFunction() = %v, want %v", result, tt.expected)
            }
        })
    }
}
```

### Step 4: Test with Authentication

For protected endpoints, use the `getAuthToken` helper:

```go
func TestProtectedEndpoint(t *testing.T) {
    db := setupTestDB(t)
    router := server.SetupRouter(db)
    
    // Get auth token
    token := getAuthToken(t, db)
    
    // Make authenticated request
    req := httptest.NewRequest("GET", "/api/v1/users", nil)
    req.Header.Set("Authorization", "Bearer "+token)
    w := httptest.NewRecorder()
    
    router.ServeHTTP(w, req)
    
    if w.Code != http.StatusOK {
        t.Errorf("Expected 200, got %d", w.Code)
    }
}
```

---

## 🎨 Testing Best Practices

### 1. Test Independence

Each test should be completely independent:

```go
func TestFeatureA(t *testing.T) {
    db := setupTestDB(t) // Fresh database for each test
    // ... test logic
}

func TestFeatureB(t *testing.T) {
    db := setupTestDB(t) // Another fresh database
    // ... test logic
}
```

### 2. Use Subtests

Group related tests with `t.Run()`:

```go
func TestUserValidation(t *testing.T) {
    t.Run("valid email", func(t *testing.T) {
        // test valid email
    })
    
    t.Run("invalid email", func(t *testing.T) {
        // test invalid email
    })
    
    t.Run("empty email", func(t *testing.T) {
        // test empty email
    })
}
```

### 3. Test Error Cases

Don't just test happy paths:

```go
func TestCreateUser(t *testing.T) {
    t.Run("success", func(t *testing.T) {
        // test successful creation
    })
    
    t.Run("duplicate email", func(t *testing.T) {
        // test duplicate email error
    })
    
    t.Run("invalid input", func(t *testing.T) {
        // test validation errors
    })
    
    t.Run("database error", func(t *testing.T) {
        // test database failure handling
    })
}
```

### 4. Use Table-Driven Tests

For testing multiple scenarios:

```go
func TestPasswordValidation(t *testing.T) {
    tests := []struct {
        name     string
        password string
        wantErr  bool
        errMsg   string
    }{
        {"valid password", "SecurePass123!", false, ""},
        {"too short", "abc", true, "password too short"},
        {"no numbers", "SecurePass!", true, "must contain number"},
        {"no special chars", "SecurePass123", true, "must contain special character"},
    }
    
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            err := validatePassword(tt.password)
            
            if (err != nil) != tt.wantErr {
                t.Errorf("validatePassword() error = %v, wantErr %v", err, tt.wantErr)
            }
            
            if err != nil && err.Error() != tt.errMsg {
                t.Errorf("error message = %v, want %v", err.Error(), tt.errMsg)
            }
        })
    }
}
```

### 5. Clean Test Data

Use descriptive test data:

```go
// Good
testUser := &user.User{
    Name:  "Test User",
    Email: "test@example.com",
}

// Bad
testUser := &user.User{
    Name:  "aaa",
    Email: "a@a.com",
}
```

### 6. Use Assertions

Consider using a testing library for cleaner assertions:

```go
// Without library
if result != expected {
    t.Errorf("got %v, want %v", result, expected)
}

// With testify/assert
assert.Equal(t, expected, result)
assert.NoError(t, err)
assert.NotNil(t, user)
```

---

## 🗄️ Test Database

### SQLite In-Memory

GRAB uses **SQLite in-memory** database for tests:

**Advantages**:
- ✅ **Fast**: No disk I/O
- ✅ **Isolated**: Each test gets fresh database
- ✅ **No setup**: No external database required
- ✅ **CI-friendly**: Works in GitHub Actions

**Setup**:
```go
func setupTestDB(t *testing.T) *gorm.DB {
    db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
    if err != nil {
        t.Fatalf("Failed to connect to test database: %v", err)
    }
    
    // Run migrations
    if err := db.AutoMigrate(&user.User{}); err != nil {
        t.Fatalf("Failed to migrate test database: %v", err)
    }
    
    return db
}
```

### PostgreSQL for E2E Tests (Future)

For end-to-end tests, use Docker PostgreSQL:

```bash
# Start test database
docker run -d --name test-postgres \
  -e POSTGRES_PASSWORD=test \
  -e POSTGRES_DB=test_db \
  -p 5433:5432 \
  postgres:15-alpine

# Run E2E tests
TEST_DB_PORT=5433 go test ./e2e/...

# Cleanup
docker rm -f test-postgres
```

---

## 📊 Test Coverage

### Current Coverage

Run coverage report:

```bash
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out
```

**Target Coverage**: 80%+

### Coverage by Package

```bash
# Check coverage per package
go test -cover ./internal/user
go test -cover ./internal/auth
go test -cover ./tests
```

### Improving Coverage

**High Priority**:
- ✅ All API handlers
- ✅ Authentication logic
- ✅ User CRUD operations

**Medium Priority**:
- ⚠️ Middleware functions
- ⚠️ Validation logic
- ⚠️ Error handling

**Low Priority**:
- ℹ️ Configuration loading
- ℹ️ Database connection
- ℹ️ Main function

---

## 🔧 Testing Tools

### Installed Tools

**Go Testing**: Built-in testing framework
```bash
go test ./...
```

**httptest**: HTTP testing utilities
```go
import "net/http/httptest"
```

**GORM SQLite**: In-memory database
```go
import "gorm.io/driver/sqlite"
```

### Recommended Tools (Optional)

**testify/assert**: Better assertions
```bash
go get github.com/stretchr/testify/assert
```

**gomock**: Mocking framework
```bash
go install github.com/golang/mock/mockgen@latest
```

**go-sqlmock**: Database mocking
```bash
go get github.com/DATA-DOG/go-sqlmock
```

---

## 🐛 Debugging Tests

### Verbose Output

```bash
# See detailed test output
go test -v ./...

# See what tests are running
go test -v ./tests -run TestRegisterUser
```

### Print Debugging

```go
func TestMyFeature(t *testing.T) {
    // Print request body
    t.Logf("Request body: %s", body)
    
    // Print response
    t.Logf("Response: %s", w.Body.String())
    
    // Print status code
    t.Logf("Status code: %d", w.Code)
}
```

### Failed Test Output

```bash
# Show only failed tests
go test ./... | grep FAIL

# Run only failed tests
go test -failfast ./...
```

---

## 📅 Testing Roadmap

### v1.0.0 (Current)
- ✅ Integration tests for all endpoints
- ✅ Authentication flow tests
- ✅ CRUD operation tests
- ✅ Error handling tests

### v1.1.0 (Planned)
- ⏳ Unit tests for services
- ⏳ Middleware tests
- ⏳ Validation tests
- ⏳ 80%+ code coverage

### v1.2.0 (Future)
- 📋 E2E tests with PostgreSQL
- 📋 Performance tests
- 📋 Load tests
- 📋 Security tests

### v2.0.0 (Future)
- 📋 Contract tests
- 📋 Mutation tests
- 📋 Property-based tests
- 📋 Chaos engineering tests

---

## 📚 Resources

### Official Documentation
- [Go Testing Package](https://pkg.go.dev/testing)
- [Go Testing Best Practices](https://go.dev/doc/tutorial/add-a-test)
- [Table Driven Tests](https://github.com/golang/go/wiki/TableDrivenTests)

### Testing Libraries
- [testify](https://github.com/stretchr/testify) - Assertions and mocking
- [gomock](https://github.com/golang/mock) - Mocking framework
- [httpexpect](https://github.com/gavv/httpexpect) - HTTP testing

### Articles
- [Testing in Go](https://go.dev/blog/testing)
- [Advanced Testing in Go](https://about.sourcegraph.com/blog/go/advanced-testing-in-go)
- [Go Testing Techniques](https://medium.com/@matryer/5-simple-tips-and-tricks-for-writing-unit-tests-in-golang-619653f90742)

---

## 🤝 Contributing Tests

When contributing, please:

1. ✅ Write tests for new features
2. ✅ Update existing tests if behavior changes
3. ✅ Ensure all tests pass before submitting PR
4. ✅ Aim for 80%+ coverage on new code
5. ✅ Follow existing test patterns
6. ✅ Add comments for complex test logic

**Test Checklist**:
- [ ] Tests pass locally (`make test`)
- [ ] Tests pass in CI
- [ ] New features have tests
- [ ] Edge cases are covered
- [ ] Error cases are tested
- [ ] Documentation is updated

---

## 💡 Need Help?

- 📖 Check [tests/README.md](https://github.com/vahiiiid/go-rest-api-boilerplate/blob/main/tests/README.md) for quick reference
- 👀 Look at existing tests in `tests/handler_test.go` for examples
- 🐛 [Open an issue](https://github.com/vahiiiid/go-rest-api-boilerplate/issues) if you find bugs
- 💬 [Start a discussion](https://github.com/vahiiiid/go-rest-api-boilerplate/discussions) for questions

---

**Happy Testing! 🧪**
