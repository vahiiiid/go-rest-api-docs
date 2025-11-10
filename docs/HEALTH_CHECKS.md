# Health Check System

The GRAB boilerplate implements a production-grade health check system following industry best practices, including Kubernetes liveness/readiness probes and the [IETF RFC Draft for HTTP Health Check Response Format](https://datatracker.ietf.org/doc/html/draft-inadarei-api-health-check-06).

## Overview

The health check system provides three endpoints designed for different monitoring purposes:

| Endpoint | Purpose | Use Case |
|----------|---------|----------|
| `/health` | Overall system health | General monitoring, status pages |
| `/health/live` | Liveness probe | Container orchestration (Kubernetes, Docker) |
| `/health/ready` | Readiness probe | Load balancer health checks, traffic routing |

## Endpoints

### GET /health

Returns overall system health status with uptime information.

**Response (200 OK)**
```json
{
  "status": "healthy",
  "timestamp": "2025-11-06T20:00:00Z",
  "uptime": "2 days, 3 hours, 15 minutes"
}
```

**Status Values**
- `healthy` - All systems operational
- `degraded` - System operational but with performance issues
- `unhealthy` - Critical systems failing

### GET /health/live

Liveness probe endpoint for container orchestration platforms. Always returns `healthy` unless the application process has crashed.

**Use Case**: Kubernetes uses this to determine if the container should be restarted.

**Response (200 OK)**
```json
{
  "status": "healthy",
  "timestamp": "2025-11-06T20:00:00Z",
  "uptime": "2 days, 3 hours, 15 minutes"
}
```

### GET /health/ready

Readiness probe endpoint with dependency health checks. Returns service status and individual dependency checks.

**Use Case**: Load balancers use this to determine if the instance should receive traffic.

**Response (200 OK) - All Checks Pass**
```json
{
  "status": "healthy",
  "timestamp": "2025-11-06T20:00:00Z",
  "uptime": "2 days, 3 hours, 15 minutes",
  "checks": [
    {
      "name": "database",
      "status": "pass",
      "response_time": "45ms",
      "message": "Database is healthy"
    }
  ]
}
```

**Response (200 OK) - Degraded but Operational**
```json
{
  "status": "degraded",
  "timestamp": "2025-11-06T20:00:00Z",
  "uptime": "2 days, 3 hours, 15 minutes",
  "checks": [
    {
      "name": "database",
      "status": "warn",
      "response_time": "350ms",
      "message": "Database response time is slow"
    }
  ]
}
```

**Response (503 Service Unavailable) - Unhealthy**
```json
{
  "status": "unhealthy",
  "timestamp": "2025-11-06T20:00:00Z",
  "uptime": "2 days, 3 hours, 15 minutes",
  "checks": [
    {
      "name": "database",
      "status": "fail",
      "response_time": "0s",
      "message": "Cannot connect to database"
    }
  ]
}
```

**Check Status Values**
- `pass` - Component healthy
- `warn` - Component operational but degraded
- `fail` - Component unavailable or failing

## Configuration

Health check behavior is configured in `configs/config.yaml`:

```yaml
app:
  name: "GRAB API"
  version: "1.0.0"                 # Version shown in health responses
  environment: "development"

health:
  timeout: 5                       # Health check timeout in seconds
  database_check_enabled: true     # Enable/disable database health checks
```

### Environment Variables

Override configuration using environment variables:

```bash
APP_VERSION=1.2.0
HEALTH_TIMEOUT=10
HEALTH_DATABASE_CHECK_ENABLED=false
```

## Database Health Checker

The database checker performs two operations:
1. **Ping** - Tests database connection
2. **Query** - Executes `SELECT 1` to verify query processing

### Response Time Thresholds

| Status | Response Time | Health Status |
|--------|---------------|---------------|
| Pass | < 100ms | `healthy` |
| Warn | 100-500ms | `degraded` |
| Fail | > 500ms or error | `unhealthy` |

### Implementation Example

```go
// Database checker automatically registered in SetupRouter
db, err := db.NewPostgresDB(...)
router := server.SetupRouter(userHandler, authService, cfg, db)
```

## Architecture & Directory Structure

The health check system follows clean architecture principles with clear separation of concerns:

```
internal/health/
├── checker.go              # Checker interface
├── model.go                # Health status types and response structures
├── service.go              # Health service with uptime tracking
├── service_test.go         # Service unit tests
├── handler.go              # Gin HTTP handlers with Swagger annotations
├── handler_test.go         # Handler unit tests
├── database_checker.go     # PostgreSQL health checker implementation
└── database_checker_test.go # Database checker tests
```

### Component Responsibilities

- **checker.go**: Defines the `Checker` interface for extensibility
- **model.go**: Health status constants (`StatusHealthy`, `StatusDegraded`, `StatusUnhealthy`) and response models
- **service.go**: Orchestrates health checks, tracks uptime, aggregates statuses
- **handler.go**: HTTP endpoints (`/health`, `/health/live`, `/health/ready`) with Swagger documentation
- **database_checker.go**: Database health verification with latency-based thresholds

### Integration Points

The health system is wired in `internal/server/router.go`:

```go
// Conditional checker creation based on config
var checkers []health.Checker
if cfg.Health.DatabaseCheckEnabled {
    dbChecker := health.NewDatabaseChecker(db)
    checkers = append(checkers, dbChecker)
}

// Service initialization with app version from config
healthService := health.NewService(checkers, cfg.App.Version, cfg.App.Environment)
healthHandler := health.NewHandler(healthService)

// Route registration
router.GET("/health", healthHandler.Health)
router.GET("/health/live", healthHandler.Live)
router.GET("/health/ready", healthHandler.Ready)
```

## Security Considerations

### Overview

Health check endpoints are designed to be publicly accessible for container orchestration platforms (Kubernetes, Docker Swarm) and load balancers. However, they expose system information that could be valuable to attackers. This section helps you understand the security implications and implement appropriate safeguards for your deployment environment.

### Information Disclosure Risks

#### What Information is Exposed?

| Information | Endpoint | Security Impact | Mitigation Priority |
|------------|----------|-----------------|-------------------|
| **System Uptime** | All | Low - Reveals restart/patch cycles | Low |
| **Application Version** | All | Low - May reveal outdated versions | Medium |
| **Environment Name** | All | Low - Confirms dev/staging/prod | Low |
| **Database Response Time** | `/health/ready` | Medium - Performance profiling | Medium |
| **Dependency Status** | `/health/ready` | Medium - Infrastructure mapping | High |
| **Error Messages** | `/health/ready` | Medium - Technical details | High |

#### Why This Matters

1. **Reconnaissance**: Attackers can build a profile of your infrastructure
2. **Timing Attacks**: Response times may reveal database load or query complexity
3. **Version Targeting**: Known vulnerabilities can be exploited if versions are exposed
4. **Uptime Analysis**: Helps attackers identify maintenance windows or patch cycles

### Risk Assessment by Deployment Type

#### ✅ **Low Risk Scenarios** (Public Exposure Acceptable)

- **Internal Development Environments** - No sensitive data, fast iteration needed
- **Staging with Test Data** - Used for testing, monitoring visibility is priority
- **Kubernetes Clusters** - Health checks must be accessible to kubelet
- **Behind Corporate VPN** - Network already restricted
- **Container Orchestration** - Docker healthchecks require public endpoints

#### ⚠️ **Medium Risk Scenarios** (Consider Restrictions)

- **Public-Facing APIs** - Exposed to internet but not handling sensitive data
- **Multi-Tenant Systems** - Tenant data separated at application level
- **APIs with Rate Limiting** - Already have DoS protection in place

#### 🚨 **High Risk Scenarios** (Implement Restrictions)

- **Financial Services APIs** - Regulated environments (PCI-DSS, SOC2)
- **Healthcare Applications** - HIPAA compliance required
- **Government Systems** - Strict security requirements
- **High-Value Targets** - Known to be targeted by attackers

### Production Deployment Best Practices

#### 1. Network-Level Security (Recommended Approach)

The most effective and maintainable security approach is to restrict access at the infrastructure level:

##### **Kubernetes Network Policies**

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-health-checks-from-ingress
spec:
  podSelector:
    matchLabels:
      app: go-rest-api
  policyTypes:
  - Ingress
  ingress:
  # Allow health checks from ingress controller only
  - from:
    - namespaceSelector:
        matchLabels:
          name: ingress-nginx
    ports:
    - protocol: TCP
      port: 8080
  # Allow health checks from kubelet (node network)
  - from:
    - ipBlock:
        cidr: 10.0.0.0/8  # Your cluster CIDR
    ports:
    - protocol: TCP
      port: 8080
```

##### **AWS Security Group Example**

```hcl
# Terraform configuration
resource "aws_security_group_rule" "health_check_alb" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id = aws_security_group.api.id
  description       = "Allow health checks from ALB only"
}

resource "aws_security_group_rule" "health_check_monitoring" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/16"]  # Internal VPC CIDR
  security_group_id = aws_security_group.api.id
  description       = "Allow health checks from internal monitoring"
}
```

##### **Docker Compose with Private Network**

```yaml
version: '3.8'
services:
  api:
    image: go-rest-api:latest
    networks:
      - internal
    # Health check accessible only within Docker network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health/live"]
      interval: 30s
      timeout: 5s
      retries: 3

  nginx:
    image: nginx:alpine
    networks:
      - internal
      - public
    # Nginx can access API health checks
    # Public only sees Nginx

networks:
  internal:
    internal: true  # Not accessible from host
  public:
    driver: bridge
```

#### 2. Reverse Proxy Authentication

Use a reverse proxy (Nginx, Traefik, Envoy) to add authentication:

##### **Nginx with Basic Auth**

```nginx
# /etc/nginx/sites-available/api

# Public health endpoints (for load balancer)
location /health/live {
    proxy_pass http://api:8080;
    # No auth required - just liveness
}

location /health/ready {
    proxy_pass http://api:8080;
    # No auth required - load balancer needs this
}

# Protected detailed health endpoint
location /health {
    auth_basic "Health Monitoring";
    auth_basic_user_file /etc/nginx/.htpasswd;
    proxy_pass http://api:8080;
}

# Generate password file:
# htpasswd -c /etc/nginx/.htpasswd monitoring_user
```

##### **Traefik with Middleware**

```yaml
# traefik-config.yml
http:
  routers:
    api-health:
      rule: "PathPrefix(`/health`)"
      middlewares:
        - health-auth
      service: api

  middlewares:
    health-auth:
      basicAuth:
        users:
          - "monitoring:$apr1$H6uskkkW$IgXLP6ewTrSuBkTrqE8wj/"
          # Generated with: htpasswd -nb monitoring password

  services:
    api:
      loadBalancer:
        servers:
          - url: "http://api:8080"
```

#### 3. Configuration-Based Security

Minimize information disclosure through configuration:

##### **Disable Database Checks for Public Endpoints**

```yaml
# configs/config.production.yaml
health:
  timeout: 5
  database_check_enabled: false  # Disable for public /health/ready
```

This provides readiness without exposing database performance data.

##### **Use Generic Version Numbers**

```yaml
# configs/config.production.yaml
app:
  version: "2.x"  # Don't expose exact version (2.3.1)
  environment: "production"
```

##### **Separate Internal Monitoring Endpoints** (Future Enhancement)

Consider creating authenticated `/metrics` or `/health/detailed` endpoints for internal monitoring while keeping basic health checks public.

#### 4. Monitoring and Alerting

Track health endpoint access to detect reconnaissance:

```yaml
# Example: Alert on excessive health check requests
- alert: HealthCheckSpike
  expr: rate(http_requests_total{path=~"/health.*"}[5m]) > 100
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Unusual health check request rate"
    description: "Health endpoint receiving {{ $value }} req/s"
```

### Configuration Recommendations by Environment

| Environment | Database Checks | Version Display | Network Restriction | Auth Required |
|------------|----------------|-----------------|-------------------|---------------|
| **Development** | ✅ Enabled | Exact version | None | No |
| **Staging** | ✅ Enabled | Exact version | VPN/Internal only | Optional |
| **Production** | ⚠️ Depends on needs | Generic (e.g., "2.x") | Firewall/SG rules | Recommended for `/health` |
| **High Security** | ❌ Disabled for public | Build hash only | Strict whitelist | Required |

### Implementation Checklist

Use this checklist when deploying to production:

- [ ] **Network Security**
  - [ ] Configure firewall rules to restrict health endpoint access
  - [ ] Set up security groups (AWS/GCP) or network policies (Kubernetes)
  - [ ] Verify load balancer can still access `/health/ready`
  - [ ] Confirm Kubernetes kubelet can access `/health/live`

- [ ] **Configuration**
  - [ ] Review `database_check_enabled` setting for production
  - [ ] Set generic version number if needed
  - [ ] Configure appropriate health check timeouts
  - [ ] Disable verbose error messages in production

- [ ] **Monitoring**
  - [ ] Set up alerts for health endpoint failures
  - [ ] Monitor for unusual access patterns
  - [ ] Log health check failures for investigation
  - [ ] Track response times for performance issues

- [ ] **Documentation**
  - [ ] Document security decisions for your deployment
  - [ ] Update runbooks with health endpoint access procedures
  - [ ] Train operations team on health check security

- [ ] **Testing**
  - [ ] Verify health checks work from authorized sources
  - [ ] Confirm unauthorized access is blocked
  - [ ] Test Kubernetes liveness/readiness probe functionality
  - [ ] Validate load balancer health check integration

### Common Security Questions

#### "Should I add authentication to health endpoints?"

**Generally No** for `/health/live` and `/health/ready` because:
- Container orchestration platforms (Kubernetes) can't easily provide credentials
- Load balancers expect unauthenticated health checks
- Network-level security is more maintainable

**Consider Yes** for:
- Detailed monitoring endpoints (e.g., `/health/metrics`)
- Compliance requirements (PCI-DSS, HIPAA)
- High-value targets with sophisticated threat models

#### "Is it safe to expose database response times?"

**Depends on context:**
- **Low Risk**: Internal APIs, development environments
- **Medium Risk**: Public APIs with rate limiting and monitoring
- **High Risk**: Financial systems, healthcare, government

**Mitigation**: Disable database checks in public-facing endpoints:
```yaml
health:
  database_check_enabled: false
```

#### "What about DDoS attacks on health endpoints?"

**Already Mitigated** - Health endpoints are subject to the global rate limiter:
```yaml
ratelimit:
  enabled: true
  window: 60        # seconds
  requests: 100     # max requests per window
```

Health checks are also excluded from logging to prevent log flooding.

#### "Should I use HTTPS for health checks?"

**Best Practice: Yes** - Always use HTTPS in production:
- Prevents man-in-the-middle attacks
- Protects information in transit
- Required for compliance (PCI-DSS, HIPAA)

Configure Kubernetes probes with HTTPS:
```yaml
livenessProbe:
  httpGet:
    path: /health/live
    port: 8080
    scheme: HTTPS  # Use HTTPS
```

### Trade-offs: Security vs Observability

Finding the right balance:

| Approach | Security | Observability | Maintenance |
|----------|----------|---------------|-------------|
| **Fully Public** | Low | High | Easy |
| **Network-Restricted** | Medium | High | Medium |
| **Auth Required** | High | Medium | Complex |
| **No Health Checks** | Highest | None | N/A |

**Recommended for Most Cases**: Network-restricted with public liveness/readiness probes.

### Additional Resources

- [OWASP API Security Top 10](https://owasp.org/www-project-api-security/)
- [Kubernetes Security Best Practices](https://kubernetes.io/docs/concepts/security/security-checklist/)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)
- [CIS Docker Benchmark](https://www.cisecurity.org/benchmark/docker)

## Kubernetes Integration

### Deployment Configuration

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: go-rest-api
spec:
  template:
    spec:
      containers:
      - name: api
        image: your-registry/go-rest-api:latest
        ports:
        - containerPort: 8080
        livenessProbe:
          httpGet:
            path: /health/live
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 30
          timeoutSeconds: 5
          failureThreshold: 3
        readinessProbe:
          httpGet:
            path: /health/ready
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 10
          timeoutSeconds: 5
          successThreshold: 1
          failureThreshold: 3
```

### Probe Configuration Guidelines

**Liveness Probe**
- `initialDelaySeconds: 10` - Wait for application startup
- `periodSeconds: 30` - Check every 30 seconds
- `failureThreshold: 3` - Restart after 3 consecutive failures (90 seconds)

**Readiness Probe**
- `initialDelaySeconds: 5` - Start checking early
- `periodSeconds: 10` - Frequent checks for traffic routing
- `failureThreshold: 3` - Remove from load balancer after 3 failures (30 seconds)

## Docker Compose Integration

Both `docker-compose.yml` and `docker-compose.prod.yml` use `/health/live` for container health checks:

```yaml
services:
  app:
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health/live"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

**Parameters**
- `interval: 30s` - Check every 30 seconds
- `timeout: 10s` - Health check must respond within 10 seconds
- `retries: 3` - Mark unhealthy after 3 consecutive failures
- `start_period: 40s` - Grace period for application startup

## Load Balancer Configuration

### NGINX

```nginx
upstream api_backend {
    server api1.example.com:8080 max_fails=3 fail_timeout=30s;
    server api2.example.com:8080 max_fails=3 fail_timeout=30s;
}

server {
    location /health/ready {
        proxy_pass http://api_backend;
        proxy_connect_timeout 5s;
        proxy_read_timeout 5s;
    }
    
    location / {
        proxy_pass http://api_backend;
        # Regular API configuration
    }
}
```

### HAProxy

```haproxy
backend api_servers
    option httpchk GET /health/ready
    http-check expect status 200
    
    server api1 10.0.1.10:8080 check inter 10s fall 3 rise 2
    server api2 10.0.1.11:8080 check inter 10s fall 3 rise 2
```

## Monitoring Integration

### Prometheus

Example Prometheus configuration for health check monitoring:

```yaml
scrape_configs:
  - job_name: 'go-rest-api-health'
    metrics_path: '/health/ready'
    scrape_interval: 30s
    static_configs:
      - targets: ['api.example.com:8080']
```

### Datadog

Configure Datadog HTTP check in `conf.yaml`:

```yaml
init_config:

instances:
  - name: api_health
    url: http://api.example.com:8080/health/ready
    timeout: 5
    threshold: 3
    window: 5
```

### Custom Monitoring Script

```bash
#!/bin/bash
ENDPOINT="http://localhost:8080/health/ready"
RESPONSE=$(curl -s -w "%{http_code}" -o /tmp/health.json "$ENDPOINT")

if [ "$RESPONSE" -eq 200 ]; then
    STATUS=$(jq -r '.status' /tmp/health.json)
    if [ "$STATUS" = "healthy" ]; then
        echo "OK: Service is healthy"
        exit 0
    elif [ "$STATUS" = "degraded" ]; then
        echo "WARNING: Service is degraded"
        exit 1
    fi
fi

echo "CRITICAL: Service is unhealthy (HTTP $RESPONSE)"
exit 2
```

## Extending Health Checks

The system is designed for easy extension with additional health checkers.

### Creating a Custom Checker

```go
package health

import (
    "context"
    "time"
)

// RedisChecker checks Redis connectivity
type RedisChecker struct {
    client *redis.Client
}

func NewRedisChecker(client *redis.Client) *RedisChecker {
    return &RedisChecker{client: client}
}

func (c *RedisChecker) Name() string {
    return "redis"
}

func (c *RedisChecker) Check(ctx context.Context) CheckResult {
    start := time.Now()
    
    err := c.client.Ping(ctx).Err()
    responseTime := time.Since(start)
    
    if err != nil {
        return CheckResult{
            Name:         c.Name(),
            Status:       CheckFail,
            ResponseTime: responseTime.String(),
            Message:      "Redis connection failed: " + err.Error(),
        }
    }
    
    status := CheckPass
    message := "Redis is healthy"
    
    if responseTime > 500*time.Millisecond {
        status = CheckFail
        message = "Redis response time too high"
    } else if responseTime > 100*time.Millisecond {
        status = CheckWarn
        message = "Redis response time is slow"
    }
    
    return CheckResult{
        Name:         c.Name(),
        Status:       status,
        ResponseTime: responseTime.String(),
        Message:      message,
    }
}
```

### Registering Custom Checkers

Modify `internal/server/router.go`:

```go
// Setup health checks
checkers := []health.Checker{}

if cfg.Health.DatabaseCheckEnabled {
    checkers = append(checkers, health.NewDatabaseChecker(db))
}

// Add Redis checker
if cfg.Health.RedisCheckEnabled {
    redisChecker := health.NewRedisChecker(redisClient)
    checkers = append(checkers, redisChecker)
}

healthService := health.NewService(checkers...)
healthHandler := health.NewHandler(healthService, cfg.Health.Timeout)
```

## Best Practices

### Health Check Design

✅ **DO**
- Keep health checks fast (< 1 second)
- Use separate liveness and readiness checks
- Include critical dependencies in readiness checks
- Return appropriate HTTP status codes (200 for healthy, 503 for unhealthy)
- Log health check failures for debugging

❌ **DON'T**
- Include non-critical dependencies in health checks
- Perform expensive operations (database migrations, complex queries)
- Return 200 OK when dependencies are failing
- Use the same endpoint for liveness and readiness
- Cache health check results for too long

### Timeout Configuration

```yaml
# Development
health:
  timeout: "10s"  # More lenient for debugging

# Production
health:
  timeout: "5s"   # Strict for faster detection
```

### Monitoring Strategy

1. **Liveness Probe**: Detects application crashes → Triggers restart
2. **Readiness Probe**: Detects dependency issues → Stops traffic routing
3. **External Monitoring**: Validates end-to-end functionality → Alerts on-call

## Troubleshooting

### Container Restart Loop

**Symptom**: Container repeatedly restarts
**Cause**: Liveness probe failing
**Solution**:
1. Check application logs: `docker logs <container>`
2. Verify `/health/live` endpoint: `curl http://localhost:8080/health/live`
3. Increase `initialDelaySeconds` if application needs more startup time
4. Check for deadlocks or infinite loops in application code

### Service Not Receiving Traffic

**Symptom**: Load balancer marks instance as down
**Cause**: Readiness probe failing
**Solution**:
1. Check readiness endpoint: `curl http://localhost:8080/health/ready`
2. Review check status in response JSON
3. Verify database connectivity
4. Check response time thresholds
5. Review application logs for dependency errors

### Slow Health Checks

**Symptom**: Health checks timing out
**Cause**: Database queries or checks taking too long
**Solution**:
1. Optimize database queries
2. Add database connection pooling
3. Increase health check timeout
4. Consider disabling non-critical checks in high-load scenarios

## Testing Health Checks

### Unit Tests

Tests are located in `internal/health/*_test.go`:

```bash
# Run health package tests
go test ./internal/health/... -v

# Run with coverage
go test ./internal/health/... -cover
```

### Integration Tests

```bash
# Start containers
docker compose up -d

# Test liveness
curl -i http://localhost:8080/health/live

# Test readiness
curl -i http://localhost:8080/health/ready

# Test with unhealthy database
docker compose stop db
curl -i http://localhost:8080/health/ready  # Should return 503
```

### Load Testing

```bash
# Install hey (HTTP load generator)
go install github.com/rakyll/hey@latest

# Test health endpoint under load
hey -n 10000 -c 100 http://localhost:8080/health/ready
```

## Security Considerations

### Public Exposure

Health endpoints are **intentionally public** and do not require authentication. They should NOT expose:

- Internal IP addresses or hostnames
- Database credentials or connection strings
- Detailed error messages that could aid attackers
- Version numbers or software details

### Rate Limiting

Health checks are exempt from rate limiting to prevent false positives from monitoring systems making frequent requests.

Configuration in `internal/server/router.go`:

```go
// Health endpoints (no auth, no rate limit)
router.GET("/health", healthHandler.Health)
router.GET("/health/live", healthHandler.Live)
router.GET("/health/ready", healthHandler.Ready)
```

### Network Policies

In Kubernetes, restrict health endpoint access if needed:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-health-checks
spec:
  podSelector:
    matchLabels:
      app: go-rest-api
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: kube-system  # Allow from kube-system (monitoring)
    ports:
    - protocol: TCP
      port: 8080
```

## References

- [RFC Draft: Health Check Response Format for HTTP APIs](https://datatracker.ietf.org/doc/html/draft-inadarei-api-health-check-06)
- [Kubernetes Liveness and Readiness Probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)
- [Docker Compose Healthcheck](https://docs.docker.com/compose/compose-file/compose-file-v3/#healthcheck)
- [12-Factor App: Port Binding](https://12factor.net/port-binding)
