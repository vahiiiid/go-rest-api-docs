# 📋 Project Summary - Go REST API Boilerplate

## Overview

This is a **production-ready, REST API boilerplate** written in Go. It demonstrates best practices, clean architecture, and provides everything needed to build scalable REST APIs.

## ✨ What Makes This Special

### 1. **Clean Architecture**
- Layered structure: Handlers → Services → Repositories
- Clear separation of concerns
- Easy to test and maintain
- Follows Go idioms and best practices

### 2. **Production Ready**
- ✅ JWT Authentication with secure password hashing
- ✅ PostgreSQL with GORM
- ✅ Comprehensive error handling
- ✅ Input validation
- ✅ Structured logging
- ✅ Health check endpoint
- ✅ CORS support

### 3. **Developer Friendly**
- ✅ Complete Swagger/OpenAPI documentation
- ✅ Docker & Docker Compose setup
- ✅ Makefile for common tasks
- ✅ Unit and integration tests
- ✅ Postman collection included
- ✅ GitHub Actions CI/CD
- ✅ Detailed README with examples

### 4. **Easy to Extend**
- Clear domain structure
- Repository pattern for data access
- Service layer for business logic
- DTOs for request/response
- Middleware pattern for cross-cutting concerns


## 🚀 Key Features

### Authentication & Security
- **JWT tokens** with HS256 signing
- **Bcrypt password hashing** (cost 10)
- **OAuth 2.0 BCP compliant** refresh token rotation
- **Automatic reuse detection** for token theft protection
- **Token family tracking** with UUIDs
- **Configurable TTLs** (Access: 15m, Refresh: 7 days)
- **Authorization middleware** for protected routes
- **Input validation** on all endpoints
- **No sensitive data** in responses

### API Endpoints
- `POST /api/v1/auth/register` - User registration (returns token pair)
- `POST /api/v1/auth/login` - User login (returns token pair)
- `POST /api/v1/auth/refresh` - Refresh access token (public)
- `POST /api/v1/auth/logout` - Revoke all tokens (protected)
- `GET /api/v1/users/:id` - Get user (protected)
- `PUT /api/v1/users/:id` - Update user (protected)
- `DELETE /api/v1/users/:id` - Delete user (protected)
- `GET /health` - Health check

### Database
- **PostgreSQL** as primary database
- **GORM** for ORM (with hooks, migrations, associations)
- **SQLite** for testing (in-memory)
- **Connection pooling** configured
- **Soft deletes** enabled
- **Automatic timestamps**

### Documentation
- **Swagger UI** at `/swagger/index.html`
- **OpenAPI 3.0** spec
- **Interactive API testing**
- **Complete curl examples**
- **Postman collection**

### Testing
- **Unit tests** for handlers
- **Integration tests** with httptest
- **In-memory SQLite** for CI (no dependencies)
- **Table-driven tests**
- **90%+ coverage** achievable

### CI/CD
- **GitHub Actions** workflow
- **Multi-version testing** (Go 1.23, 1.24)
- **Linting** with golangci-lint
- **Automated tests** on push/PR
- **Coverage reporting**

### Docker
- **Multi-stage build** for small images
- **Docker Compose** for local dev
- **Health checks** configured
- **Volume persistence**
- **Environment variables** support

## 📊 Technical Stack

| Component | Technology | Purpose |
|-----------|-----------|---------|
| Language | Go 1.24 | Performance, simplicity, type safety |
| Web Framework | Gin | Fast HTTP router, middleware support |
| ORM | GORM | Database abstraction, migrations |
| Database | PostgreSQL 15 | Reliable, feature-rich RDBMS |
| Auth | JWT (HS256) | Stateless authentication |
| Password | bcrypt | Secure password hashing |
| Validation | Gin binding | Request validation |
| API Docs | Swaggo | Swagger/OpenAPI generation |
| Testing | httptest | HTTP testing utilities |
| CI/CD | GitHub Actions | Automated testing and linting |
| Containerization | Docker | Consistent environments |

## 🎯 Use Cases

This boilerplate is perfect for:

1. **New REST API projects** - Start with a solid foundation
2. **Microservices** - Each service can use this pattern
3. **Learning Go web development** - See best practices in action
4. **Prototyping** - Quickly build and test APIs
5. **Interview projects** - Demonstrate your skills
6. **Team templates** - Standardize your team's approach

## 🔧 Customization Points

Easy to customize:

- **Add new domains**: Copy the `user` package structure
- **Add middleware**: JWT auth pattern is reusable
- **Change database**: GORM supports MySQL, SQLite, etc.
- **Add rate limiting**: Middleware pattern makes it easy
- **Add logging**: Service layer is perfect for structured logs
- **Add metrics**: Instrument handlers and services

## 📈 What You Get

### For Developers
- ✅ Skip boilerplate setup
- ✅ Focus on business logic
- ✅ Learn Go best practices
- ✅ Ready-to-use patterns

### For Teams
- ✅ Consistent structure
- ✅ Easy onboarding
- ✅ Scalable foundation
- ✅ Production patterns

### For Learning
- ✅ Real-world examples
- ✅ Complete test coverage
- ✅ Best practice patterns
- ✅ Well-documented code

## 🚦 Getting Started (30 seconds)

```bash
# Clone the repo
git clone https://github.com/vahiiiid/go-rest-api-boilerplate.git
cd go-rest-api-boilerplate

# Run the quick start script
./scripts/quick-start.sh

# Or manually with Docker
docker-compose up --build
```

That's it! API running at http://localhost:8080 ✨

## 📚 Documentation

- **README.md** - Main documentation with API examples
- **SETUP.md** - Detailed setup instructions
- **CONTRIBUTING.md** - Contribution guidelines
- **PROJECT_SUMMARY.md** - This file (overview)
- **migrations/README.md** - Database migration guide
- **Swagger UI** - Interactive API documentation

## 🎓 Learning Resources

This project demonstrates:
- RESTful API design
- Clean architecture in Go
- Repository pattern
- Service layer pattern
- Middleware pattern
- Dependency injection
- Unit testing strategies
- Integration testing
- Docker containerization
- CI/CD workflows
- API documentation
- Security best practices

## 🌟 Why This Stands Out

1. **Complete** - Not a minimal example, but production-ready
2. **Documented** - Every feature is explained
3. **Tested** - Comprehensive test coverage
4. **Modern** - Latest Go features and practices
5. **Maintainable** - Clean code, clear structure
6. **Scalable** - Patterns that grow with your project
7. **Secure** - Security best practices built-in
8. **Developer-Friendly** - Great DX with docs, examples, tools

## 🔄 Development Workflow

```bash
# Development
make run          # Run locally
make test         # Run tests
make lint         # Check code quality
make swag         # Generate API docs

# Docker
make docker-up    # Start containers
make docker-down  # Stop containers

# Building
make build        # Build binary
make docker-build # Build Docker image
```

## 🎉 Success Metrics

After using this boilerplate, you should be able to:

- ✅ Build a new REST API endpoint in < 30 minutes
- ✅ Add authentication to any endpoint in < 5 minutes
- ✅ Write tests for your endpoints easily
- ✅ Deploy to production with confidence
- ✅ Scale your API as your project grows

## 🤝 Contributing

We welcome contributions! See [CONTRIBUTING.md](https://github.com/vahiiiid/go-rest-api-boilerplate/blob/main/CONTRIBUTING.md) for:
- Code style guidelines
- How to add features
- Testing requirements
- Pull request process

## 📄 License

MIT License - free to use, modify, and distribute.

## 🙏 Credits

Built with ❤️ using:
- [Gin Web Framework](https://github.com/gin-gonic/gin)
- [GORM](https://gorm.io/)
- [golang-jwt](https://github.com/golang-jwt/jwt)
- [swaggo](https://github.com/swaggo/swag)

---

**Ready to build something awesome?** ⭐ Star this repo and start coding!

```bash
git clone https://github.com/vahiiiid/go-rest-api-boilerplate.git
cd go-rest-api-boilerplate
docker-compose up --build
# Happy coding! 🚀
```

