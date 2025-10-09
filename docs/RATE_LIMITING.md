# Rate Limiting

## Overview

The Go REST API Boilerplate includes a robust rate limiting middleware that protects your API from abuse and ensures fair usage across all clients. The rate limiter uses a token bucket algorithm with configurable limits and windows.

## Features

- **Token Bucket Algorithm**: Allows burst traffic while maintaining average rate limits
- **Per-IP Limiting**: Rate limits are applied per client IP address
- **Configurable Limits**: Set custom request limits and time windows
- **HTTP Headers**: Provides standard rate limit headers for client awareness
- **In-Memory Storage**: Uses LRU cache with TTL for efficient memory usage
- **Environment Configuration**: Supports both YAML config and environment variables

## Configuration

### YAML Configuration

Add the following section to your `configs/config.yaml`:

```yaml
ratelimit:
  rate_limit_enabled: true
  rate_limit_requests: 50
  rate_limit_window: 1m
```

### Environment Variables

You can override the configuration using environment variables:

```bash
# Enable/disable rate limiting
RATE_LIMIT_ENABLED=true

# Number of requests allowed per window
RATE_LIMIT_REQUESTS=100

# Time window for rate limiting (Go duration format)
RATE_LIMIT_WINDOW=5m
```

### Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `rate_limit_enabled` | boolean | `false` | Enable or disable rate limiting |
| `rate_limit_requests` | integer | `50` | Maximum requests allowed per window |
| `rate_limit_window` | duration | `1m` | Time window for rate limiting |

### Duration Format

The `rate_limit_window` accepts Go duration format:
- `1s` - 1 second
- `1m` - 1 minute
- `1h` - 1 hour
- `30s` - 30 seconds
- `5m` - 5 minutes

## How It Works

### Token Bucket Algorithm

The rate limiter uses a token bucket algorithm that:

1. **Refills tokens** at a steady rate based on your configuration
2. **Allows bursts** up to the maximum request limit
3. **Blocks requests** when no tokens are available
4. **Resets tokens** after the specified time window

### Example Scenarios

**Configuration**: 10 requests per minute

- **Minute 1**: Client makes 10 requests → Allowed (burst)
- **Minute 1**: Client makes 11th request → Blocked (429 error)
- **Minute 2**: Tokens refill → Client can make 10 more requests

### IP Detection

The rate limiter identifies clients by IP address using the following priority:

1. `ClientIP()` - Direct client IP
2. `X-Forwarded-For` header - For requests behind proxies
3. `X-Real-IP` header - Alternative proxy header
4. `"unknown"` - Fallback for test environments

## HTTP Headers

### Success Response Headers

When requests are allowed, the following headers are included:

```
X-RateLimit-Limit: 50
X-RateLimit-Remaining: 45
X-RateLimit-Reset: 1640995200
```

### Rate Limit Exceeded Response

When rate limits are exceeded, the server returns:

**Status Code**: `429 Too Many Requests`

**Headers**:
```
Retry-After: 30
X-RateLimit-Limit: 50
X-RateLimit-Remaining: 0
X-RateLimit-Reset: 1640995200
```

**Response Body**:
```json
{
  "error": "Rate limit exceeded",
  "message": "Too many requests. Please try again in 30 seconds.",
  "retry_after": 30
}
```

## Implementation Details

### Middleware Integration

The rate limiter is integrated as global middleware in the router:

```go
// Global rate-limit middleware (per client IP)
rlCfg := cfg.Ratelimit
if rlCfg.Enabled {
    router.Use(
        middleware.NewRateLimitMiddleware(
            rlCfg.Window,
            rlCfg.Requests,
            func(c *gin.Context) string {
                ip := c.ClientIP()
                if ip == "" {
                    // Fallback for test environments
                    ip = c.GetHeader("X-Forwarded-For")
                    if ip == "" {
                        ip = c.GetHeader("X-Real-IP")
                    }
                    if ip == "" {
                        ip = "unknown"
                    }
                }
                return ip
            },
            nil, // default in-memory LRU
        ),
    )
}
```

### Storage Backend

The rate limiter uses an in-memory LRU cache with TTL:

- **Cache Size**: 5,000 entries (configurable)
- **TTL**: 6 hours (configurable)
- **Storage**: `github.com/hashicorp/golang-lru/v2/expirable`

### Custom Storage

You can implement a custom storage backend by implementing the `Storage` interface:

```go
type Storage interface {
    Add(string, *rate.Limiter) bool
    Get(string) (*rate.Limiter, bool)
}
```

## Usage Examples

### Basic Configuration

```yaml
# configs/config.yaml
ratelimit:
  rate_limit_enabled: true
  rate_limit_requests: 100
  rate_limit_window: 1m
```

### Strict Rate Limiting

```yaml
# Very strict: 10 requests per minute
ratelimit:
  rate_limit_enabled: true
  rate_limit_requests: 10
  rate_limit_window: 1m
```

### Generous Rate Limiting

```yaml
# Generous: 1000 requests per hour
ratelimit:
  rate_limit_enabled: true
  rate_limit_requests: 1000
  rate_limit_window: 1h
```

### Environment-Based Configuration

```bash
# Production environment
RATE_LIMIT_ENABLED=true
RATE_LIMIT_REQUESTS=200
RATE_LIMIT_WINDOW=5m

# Development environment
RATE_LIMIT_ENABLED=false
```

## Testing

### Unit Tests

The rate limiter includes comprehensive unit tests:

```bash
# Run rate limiter tests
go test ./internal/middleware/ -v -run TestRateLimit

# Run all tests
make test
```

### Manual Testing

Test rate limiting with curl:

```bash
# Test normal requests
for i in {1..10}; do
  curl -X POST http://localhost:8080/api/v1/auth/login \
    -H "Content-Type: application/json" \
    -d '{"email":"test@example.com","password":"password"}'
done

# Test rate limit exceeded
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password"}'
```

Expected response for rate limit exceeded:
```json
{
  "error": "Rate limit exceeded",
  "message": "Too many requests. Please try again in 30 seconds.",
  "retry_after": 30
}
```

## Best Practices

### Production Configuration

For production environments, consider these settings:

```yaml
ratelimit:
  rate_limit_enabled: true
  rate_limit_requests: 100
  rate_limit_window: 1m
```

### Development Configuration

For development, you might want more lenient limits:

```yaml
ratelimit:
  rate_limit_enabled: true
  rate_limit_requests: 1000
  rate_limit_window: 1m
```

### Testing Configuration

For testing, disable rate limiting:

```yaml
ratelimit:
  rate_limit_enabled: false
```

### Monitoring

Monitor rate limit metrics:

- Track 429 responses in your logs
- Monitor `X-RateLimit-Remaining` headers
- Set up alerts for high rate limit usage

## Troubleshooting

### Common Issues

#### Rate Limiting Not Working

**Problem**: Requests are not being rate limited.

**Solutions**:
1. Check if `rate_limit_enabled` is set to `true`
2. Verify configuration is loaded correctly
3. Check middleware is registered in router

#### Too Strict Rate Limiting

**Problem**: Legitimate users are being blocked.

**Solutions**:
1. Increase `rate_limit_requests` value
2. Increase `rate_limit_window` duration
3. Consider implementing user-based rate limiting

#### Memory Usage

**Problem**: High memory usage with many unique IPs.

**Solutions**:
1. Reduce `DefaultCacheSize` (currently 5,000)
2. Reduce `DefaultTTL` (currently 6 hours)
3. Implement Redis-based storage for distributed systems

### Debug Mode

Enable debug logging to troubleshoot:

```yaml
logging:
  level: debug
```

### Health Check

The `/health` endpoint is not rate limited, so you can always check server status.

## Advanced Configuration

### Custom Key Function

You can customize how clients are identified by providing a custom key function:

```go
// Rate limit per user ID instead of IP
router.Use(middleware.NewRateLimitMiddleware(
    rlCfg.Window,
    rlCfg.Requests,
    func(c *gin.Context) string {
        // Extract user ID from JWT token
        userID := getUserIDFromToken(c)
        return userID
    },
    nil,
))
```

### Multiple Rate Limits

You can apply different rate limits to different route groups:

```go
// Strict rate limiting for auth endpoints
authGroup := v1.Group("/auth")
authGroup.Use(middleware.NewRateLimitMiddleware(
    1*time.Minute, // 1 minute window
    5,             // 5 requests
    ipKeyFunc,
    nil,
))

// More lenient rate limiting for other endpoints
apiGroup := v1.Group("/api")
apiGroup.Use(middleware.NewRateLimitMiddleware(
    1*time.Minute, // 1 minute window
    100,           // 100 requests
    ipKeyFunc,
    nil,
))
```

## Security Considerations

### DDoS Protection

The rate limiter provides basic DDoS protection by:
- Limiting requests per IP address
- Using efficient in-memory storage
- Providing immediate feedback to clients

### Bypass Prevention

To prevent bypass attempts:
- Use consistent IP detection logic
- Consider implementing additional security layers
- Monitor for suspicious patterns

### Distributed Systems

For distributed deployments:
- Consider Redis-based storage
- Implement consistent hashing
- Use load balancer IP forwarding

## Performance Impact

### Memory Usage

- **Per IP**: ~1KB of memory
- **Default Cache**: ~5MB for 5,000 IPs
- **TTL**: Automatic cleanup after 6 hours

### CPU Impact

- **Minimal**: O(1) operations for token bucket
- **Efficient**: LRU cache with TTL
- **Scalable**: Handles thousands of concurrent requests

## Migration Guide

### From No Rate Limiting

1. Add rate limiter configuration to `config.yaml`
2. Set conservative limits initially
3. Monitor and adjust based on usage patterns
4. Enable in production after testing

### Updating Existing Configuration

1. Update `config.yaml` with new values
2. Restart the application
3. Monitor rate limit headers
4. Adjust if needed

## Related Documentation

- [Configuration Guide](SETUP.md)
- [Middleware Documentation](DEVELOPMENT_GUIDE.md)
- [Security Best Practices](DEVELOPMENT_GUIDE.md)
- [API Documentation](SWAGGER.md)

## Support

For questions or issues with the rate limiter:

1. Check this documentation
2. Review the [troubleshooting section](#troubleshooting)
3. Open an issue on GitHub
4. Check existing discussions

---

*Last updated: January 2025*
