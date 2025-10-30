# Graceful Shutdown Guide

Complete guide to graceful shutdown implementation in the Go REST API Boilerplate (GRAB).

---

## 📋 Overview

Graceful shutdown ensures that your application terminates cleanly without dropping active requests or leaving resources in an inconsistent state. This is **critical for production deployments** and zero-downtime updates.

### What is Graceful Shutdown?

When the server receives a termination signal (SIGINT, SIGTERM), it:

1. ✅ **Stops accepting new connections**
2. ✅ **Completes all active requests** (within timeout)
3. ✅ **Closes database connections** properly
4. ✅ **Logs shutdown process** for debugging
5. ✅ **Exits with appropriate status code**

---

## 🔧 How It Works

### Signal Handling

The application listens for OS signals:

```go
quit := make(chan os.Signal, 1)
signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
sig := <-quit
```

**Supported Signals:**
- `SIGINT` - Ctrl+C in terminal
- `SIGTERM` - Docker stop, Kubernetes pod termination, systemd

### HTTP Server Configuration

The application uses Go's `http.Server` with explicit timeouts:

```go
srv := &http.Server{
    Addr:           ":8080",
    Handler:        router,
    ReadTimeout:    10 * time.Second,
    WriteTimeout:   10 * time.Second,
    IdleTimeout:    120 * time.Second,
    MaxHeaderBytes: 1 << 20, // 1MB
}
```

### Shutdown Process

1. Signal received → log notification
2. Close database connections
3. Call `srv.Shutdown(contextutil)` with timeout
4. Wait for active requests to complete or timeout
5. Exit gracefully

---

## ⚙️ Configuration

### Timeout Settings

Configure timeouts via environment variables or config files:

```env
# Server Timeouts
SERVER_READTIMEOUT=10        # Max time to read request (seconds)
SERVER_WRITETIMEOUT=10       # Max time to write response (seconds)
SERVER_IDLETIMEOUT=120       # Keep-alive idle timeout (seconds)
SERVER_SHUTDOWNTIMEOUT=30    # Graceful shutdown timeout (seconds)
SERVER_MAXHEADERBYTES=1048576 # Max header size (bytes)
```

### Default Values

| Setting | Default | Description |
|---------|---------|-------------|
| `ReadTimeout` | 10s | Time limit for reading entire request |
| `WriteTimeout` | 10s | Time limit for writing response |
| `IdleTimeout` | 120s | Keep-alive timeout for idle connections |
| `ShutdownTimeout` | 30s | Max time to wait for active requests during shutdown |
| `MaxHeaderBytes` | 1MB | Maximum size of request headers |

### Environment-Specific Settings

**Development** - Longer timeouts for debugging:
```yaml
server:
  readtimeout: 30
  writetimeout: 30
  shutdowntimeout: 60
```

**Production** - Stricter timeouts:
```yaml
server:
  readtimeout: 10
  writetimeout: 10
  shutdowntimeout: 30
```

---

## 🧪 Testing Graceful Shutdown

### Manual Testing

#### 1. Test with Docker

```bash
# Terminal 1: Start server
make up

# Terminal 2: Send a request
curl http://localhost:8080/health

# Terminal 1: Stop server (sends SIGTERM)
docker compose stop app
```

**Expected Behavior:**
```
Server starting on :8080
Received shutdown signal: terminated
Shutting down server gracefully...
Closing database connections...
Server exited gracefully
```

#### 2. Test with Ctrl+C

```bash
# Start server
make up

# Press Ctrl+C in the terminal
```

**Expected Behavior:**
```
Received shutdown signal: interrupt
Shutting down server gracefully...
Server exited gracefully
```

#### 3. Test with Active Requests

```bash
# Terminal 1: Start server
make up

# Terminal 2: Send a long-running request
curl http://localhost:8080/api/v1/users/1 &

# Terminal 3: Immediately stop server
docker compose stop app

# Observe: Request completes before shutdown
```

### Automated Testing

The project includes comprehensive integration tests:

```bash
# Run shutdown tests (requires database)
go test ./cmd/server -v -run TestGracefulShutdown

# Run all integration tests
SKIP_INTEGRATION_TESTS="" go test ./... -v
```

---

## 🚀 Production Deployment

### Docker Deployment

Docker automatically sends SIGTERM when stopping containers:

```bash
# Graceful stop (sends SIGTERM, waits 10s by default)
docker stop <container>

# Force stop (sends SIGKILL immediately)
docker kill <container>
```

**docker-compose.yml:**
```yaml
services:
  app:
    stop_grace_period: 35s  # Allow time for 30s shutdown + buffer
```

### Kubernetes Deployment

Kubernetes sends SIGTERM during pod termination:

```yaml
apiVersion: v1
kind: Pod
spec:
  terminationGracePeriodSeconds: 35  # Must be > SERVER_SHUTDOWNTIMEOUT
  containers:
  - name: api
    # ... other config
```

**Pod Lifecycle:**
1. Pod marked for termination
2. Removed from service endpoints (no new traffic)
3. SIGTERM sent to container
4. Grace period countdown starts
5. If not stopped, SIGKILL after grace period

### systemd Service

For systemd deployments:

```ini
[Unit]
Description=GRAB API Server
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/api-server
KillMode=mixed
TimeoutStopSec=35s  # Must be > SERVER_SHUTDOWNTIMEOUT
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

---

## 🎯 Best Practices

### 1. Set Appropriate Timeouts

```bash
# Production recommendation
SERVER_SHUTDOWNTIMEOUT=30  # 30 seconds for graceful shutdown
```

**Considerations:**
- Too short → may terminate active requests
- Too long → slow deployments, delayed restarts
- Typical range: 20-60 seconds

### 2. Health Check During Shutdown

Health checks should reflect shutdown state:

```go
if shuttingDown.Load() {
    c.JSON(http.StatusServiceUnavailable, gin.H{
        "status": "shutting_down",
    })
    return
}
```

### 3. Database Connection Cleanup

Always close database connections:

```go
sqlDB, err := database.DB()
if err == nil {
    logger.Info("Closing database connections...")
    sqlDB.Close()
}
```

### 4. Monitoring and Logging

Log shutdown events for debugging:

```go
logger.Info("Received shutdown signal", "signal", sig)
logger.Info("Shutting down server gracefully...")
logger.Info("Server exited gracefully")
```

### 5. Load Balancer Configuration

Ensure load balancers stop sending traffic before shutdown:

```yaml
# Kubernetes readiness probe
livenessProbe:
  httpGet:
    path: /health
    port: 8080
readinessProbe:  # Stops routing traffic when pod terminates
  httpGet:
    path: /health
    port: 8080
```

---

## 🔍 Troubleshooting

### Shutdown Takes Too Long

**Problem:** Shutdown exceeds timeout.

**Solutions:**
1. Check for long-running requests
2. Increase `SERVER_SHUTDOWNTIMEOUT`
3. Implement request timeouts
4. Review slow database queries

### Requests Being Dropped

**Problem:** Active requests fail during shutdown.

**Solutions:**
1. Increase shutdown timeout
2. Ensure load balancer stops sending traffic
3. Check container orchestrator grace period
4. Verify health check implementation

### Database Connection Errors

**Problem:** "connection refused" errors after restart.

**Solutions:**
1. Ensure proper connection cleanup
2. Check database connection pooling settings
3. Verify database availability
4. Review connection timeout settings

### Signal Not Received

**Problem:** Server doesn't gracefully shutdown.

**Solutions:**
1. Don't use shell wrapper (`/bin/sh -c`)
2. Use `CMD ["./bin/server"]` in Dockerfile
3. Verify signal forwarding in orchestrator
4. Check process running as PID 1

---

## 📚 Related Documentation

- [Configuration Guide](CONFIGURATION.md) - Timeout configuration details
- [Docker Guide](DOCKER.md) - Container deployment
- [Testing Guide](TESTING.md) - Testing shutdown behavior
- [Development Guide](DEVELOPMENT_GUIDE.md) - Local development setup

---

## 🎓 Further Reading

- [Go net/http Server.Shutdown](https://pkg.go.dev/net/http#Server.Shutdown)
- [Kubernetes Pod Lifecycle](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/)
- [Docker Stop vs Kill](https://docs.docker.com/engine/reference/commandline/stop/)
- [systemd Service Configuration](https://www.freedesktop.org/software/systemd/man/systemd.service.html)
