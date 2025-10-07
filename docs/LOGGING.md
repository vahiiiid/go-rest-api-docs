# 📊 Logging & Monitoring

GRAB includes a comprehensive structured logging system that provides detailed insights into your API's behavior, performance, and errors. This guide covers everything you need to know about logging configuration, monitoring, and production deployment.

## 🎯 Overview

GRAB uses **structured JSON logging** with the following features:

- ✅ **Structured JSON Format** - Easy to parse and analyze
- ✅ **Request Tracking** - Unique request IDs for tracing
- ✅ **Performance Metrics** - Response times and sizes
- ✅ **Smart Log Levels** - Automatic level adjustment based on status codes
- ✅ **Environment-Aware** - Skip paths automatically configured per environment
- ✅ **Configurable** - Log levels via YAML config or environment variables

## 📋 Log Format

Every HTTP request generates a structured JSON log entry:

```json
{
  "time": "2025-10-07T20:58:09.182401421Z",
  "level": "INFO",
  "msg": "HTTP Request",
  "request_id": "245bf1f3-0c9b-4242-8770-bbf3735ce303",
  "method": "POST",
  "path": "/api/v1/auth/login",
  "status": 200,
  "duration": 87074653,
  "duration_ms": "87ms",
  "client_ip": "192.168.97.1",
  "user_agent": "PostmanRuntime/7.26.8",
  "response_size": 287
}
```

> 📄 **Example Log File**: See [examples/server.log](examples/server.log) for a complete example with multiple log entries showing different scenarios (success, warnings, errors).

### Log Fields Explained

| Field | Description | Example |
|-------|-------------|---------|
| `time` | Timestamp in RFC3339 format | `2025-10-07T20:58:09.182401421Z` |
| `level` | Log level (INFO/WARN/ERROR) | `INFO` |
| `msg` | Log message | `HTTP Request` |
| `request_id` | Unique request identifier | `245bf1f3-0c9b-4242-8770-bbf3735ce303` |
| `method` | HTTP method | `POST`, `GET`, `PUT`, `DELETE` |
| `path` | Request path with query params | `/api/v1/auth/login?debug=true` |
| `status` | HTTP status code | `200`, `404`, `500` |
| `duration` | Request duration in nanoseconds | `87074653` |
| `duration_ms` | Human-readable duration | `87ms` |
| `client_ip` | Client IP address | `192.168.97.1` |
| `user_agent` | Client user agent | `PostmanRuntime/7.26.8` |
| `response_size` | Response body size in bytes | `287` |

## 🎚️ Log Levels

GRAB automatically adjusts log levels based on HTTP status codes:

| Status Code | Log Level | Description |
|-------------|-----------|-------------|
| 200-399 | `INFO` | Successful requests |
| 400-499 | `WARN` | Client errors (bad requests, unauthorized, etc.) |
| 500-599 | `ERROR` | Server errors (internal errors, database issues, etc.) |

### Configurable Log Levels

You can also set a minimum log level to filter out less important messages:

| Level | Description | Use Case |
|-------|-------------|----------|
| `debug` | Most verbose, includes all messages | Development debugging |
| `info` | Standard logging (default) | Development and staging |
| `warn` | Warnings and errors only | Production (recommended) |
| `error` | Errors only | High-traffic production |

## ⚙️ Configuration

### YAML Configuration

Edit `configs/config.yaml`:

```yaml
logging:
  level: info  # debug, info, warn, error
```

### Environment Variables

Override YAML configuration with environment variables:

```bash
# Set log level
export LOG_LEVEL=debug

# Set environment (affects skip paths)
export ENV=production
```

### Docker Configuration

In `docker-compose.yml`:

```yaml
environment:
  LOG_LEVEL: debug  # debug, info, warn, error
  ENV: development
```

In `docker-compose.prod.yml`:

```yaml
environment:
  LOG_LEVEL: warn   # Production defaults to warn level
  ENV: production
```

## 🚫 Skip Paths (Environment-Based)

Skip paths are automatically determined based on environment to reduce log noise:

| Environment | Skip Paths | Reason |
|-------------|------------|---------|
| `production` | `/health`, `/metrics`, `/debug`, `/pprof` | Reduce noise from monitoring endpoints |
| `development` | `/health` | Keep health checks quiet |
| `test` | `/health` | Clean test output |
| `default` | `/health` | Safe default |

## 📍 Where to Find Logs

### 🐳 Docker Development

**View live logs:**
```bash
# View all container logs
docker-compose logs -f

# View only app logs
docker-compose logs -f app

# View logs with timestamps
docker-compose logs -f -t app
```

**Save logs to file:**
```bash
# Save logs to file
docker-compose logs app > server.log

# Append logs to file
docker-compose logs app >> server.log

# Save logs with timestamps
docker-compose logs -t app > server.log
```

**Redirect stdout to file:**
```bash
# Method 1: Redirect docker-compose output
docker-compose up > server.log 2>&1

# Method 2: Use docker logs with redirection
docker-compose up -d
docker-compose logs -f app > server.log &

# Method 3: Direct container log redirection
docker logs -f go_api_app > server.log
```

### 🏗️ Go Build & Run

**Direct execution:**
```bash
# Logs go to stdout (terminal)
go run cmd/server/main.go

# Redirect to file
go run cmd/server/main.go > server.log 2>&1

# Run in background with logging
nohup go run cmd/server/main.go > server.log 2>&1 &
```

**Built binary:**
```bash
# Build the binary
go build -o bin/server cmd/server/main.go

# Run with logging
./bin/server > server.log 2>&1

# Run in background
nohup ./bin/server > server.log 2>&1 &
```

### 📁 Log File Locations

| Method | Default Location | Custom Location |
|--------|------------------|-----------------|
| Docker stdout | Container logs | `docker-compose logs > custom.log` |
| Go run redirect | `./server.log` | `go run cmd/server/main.go > custom.log` |
| Binary redirect | `./server.log` | `./bin/server > custom.log` |
| Background process | `./nohup.out` | `nohup ./bin/server > custom.log` |

## 🏭 Production Logging

### Log Aggregation Setup

For production, you'll want to set up log aggregation. Here are popular options:

#### 1. **ELK Stack (Elasticsearch, Logstash, Kibana)**

```yaml
# docker-compose.prod.yml
services:
  app:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
    # ... rest of config
```

#### 2. **Fluentd + Elasticsearch**

```yaml
# docker-compose.prod.yml
services:
  app:
    logging:
      driver: "fluentd"
      options:
        fluentd-address: "localhost:24224"
        tag: "api.logs"
```

#### 3. **Prometheus + Grafana**

```yaml
# docker-compose.prod.yml
services:
  app:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

### Production Configuration

**Recommended production settings:**

```yaml
# configs/config.yaml
logging:
  level: warn  # Only warnings and errors
```

```bash
# Environment variables
export LOG_LEVEL=warn
export ENV=production
```

### Log Rotation

**Docker log rotation:**
```yaml
# docker-compose.prod.yml
services:
  app:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"    # Max 10MB per file
        max-file: "5"      # Keep 5 files (50MB total)
```

**System log rotation:**
```bash
# Install logrotate
sudo apt-get install logrotate

# Create logrotate config
sudo tee /etc/logrotate.d/go-api << EOF
/path/to/server.log {
    daily
    missingok
    rotate 7
    compress
    delaycompress
    notifempty
    create 644 root root
    postrotate
        # Restart your service if needed
        systemctl reload go-api
    endscript
}
EOF
```

## 🔍 Log Analysis Examples

### Basic Analysis with `jq`

```bash
# Count requests by status code
cat server.log | jq -r '.status' | sort | uniq -c

# Find slow requests (>100ms)
cat server.log | jq 'select(.duration_ms | tonumber > 100)'

# Find errors
cat server.log | jq 'select(.level == "ERROR")'

# Count requests by endpoint
cat server.log | jq -r '.path' | sort | uniq -c

# Find requests from specific IP
cat server.log | jq 'select(.client_ip == "192.168.1.100")'
```

### Advanced Analysis

```bash
# Average response time by endpoint
cat server.log | jq -r 'select(.status < 400) | "\(.path) \(.duration_ms)"' | \
  awk '{sum[$1]+=$2; count[$1]++} END {for (i in sum) print i, sum[i]/count[i]}'

# Top 10 slowest requests
cat server.log | jq -r 'select(.status < 400) | "\(.duration_ms) \(.path) \(.method)"' | \
  sort -nr | head -10

# Error rate by endpoint
cat server.log | jq -r '.path' | sort | uniq -c | \
  awk '{print $2, $1}' | sort -k2 -nr
```

## 🛠️ Troubleshooting

### Common Issues

**1. No logs appearing:**
```bash
# Check if service is running
docker-compose ps

# Check container logs
docker-compose logs app

# Verify log level
echo $LOG_LEVEL
```

**2. Too many logs:**
```bash
# Increase log level
export LOG_LEVEL=warn

# Check skip paths
echo $ENV
```

**3. Log file not created:**
```bash
# Check permissions
ls -la server.log

# Check disk space
df -h

# Verify redirection
go run cmd/server/main.go > server.log 2>&1 &
```

### Debug Mode

**Enable debug logging:**
```bash
# Development
export LOG_LEVEL=debug
export ENV=development
go run cmd/server/main.go

# Docker
LOG_LEVEL=debug docker-compose up
```

## 📊 Monitoring Integration

### Health Check Endpoint

The `/health` endpoint is automatically excluded from logging but provides basic health information:

```bash
curl http://localhost:8080/health
```

Response:
```json
{
  "status": "ok",
  "message": "Server is running"
}
```

### Metrics Collection

For production monitoring, consider adding:

- **Prometheus metrics** for request rates, response times, error rates
- **Health check endpoints** for load balancer health
- **Custom metrics** for business logic monitoring

## 🎯 Best Practices

### Development
- Use `debug` level for detailed debugging
- Monitor logs in real-time with `docker-compose logs -f`
- Use structured queries with `jq` for analysis

### Production
- Use `warn` level to reduce noise
- Set up log aggregation (ELK, Fluentd, etc.)
- Implement log rotation to prevent disk space issues
- Monitor error rates and response times
- Set up alerts for high error rates or slow responses

### Security
- Never log sensitive data (passwords, tokens, PII)
- Use request IDs for tracing without exposing user data
- Consider log sanitization for compliance requirements

---

## 🚀 Quick Commands Reference

```bash
# View live logs (Docker)
docker-compose logs -f app

# Save logs to file (Docker)
docker-compose logs app > server.log

# View logs (Go run)
go run cmd/server/main.go

# Save logs to file (Go run)
go run cmd/server/main.go > server.log 2>&1

# Analyze logs with jq
cat server.log | jq 'select(.level == "ERROR")'

# Count requests by status
cat server.log | jq -r '.status' | sort | uniq -c

# Find slow requests
cat server.log | jq 'select(.duration_ms | tonumber > 100)'
```

---

<div align="center">

**📚 [Back to Documentation](index.md) | [Development Guide](DEVELOPMENT_GUIDE.md) | [Docker Guide](DOCKER.md)**

</div>
