# Gunicorn Configuration Guide

This document explains the Gunicorn configuration for the Flask application and how to customize it.

## Files Overview

- `gunicorn.conf.py` - Main Gunicorn configuration file
- `run.sh` - Startup script with development/production modes
- `Dockerfile` - Docker configuration using Gunicorn

## Configuration Options

### Core Settings

| Setting | Default | Environment Variable | Description |
|---------|---------|---------------------|-------------|
| `bind` | `0.0.0.0:5000` | `GUNICORN_BIND` | Socket to bind |
| `workers` | `CPU_COUNT * 2 + 1` | `GUNICORN_WORKERS` | Number of worker processes |
| `worker_class` | `sync` | `GUNICORN_WORKER_CLASS` | Type of workers to run |
| `timeout` | `120` | `GUNICORN_TIMEOUT` | Worker timeout in seconds |

### Performance Settings

| Setting | Default | Environment Variable | Description |
|---------|---------|---------------------|-------------|
| `worker_connections` | `1000` | `GUNICORN_WORKER_CONNECTIONS` | Maximum number of simultaneous clients |
| `max_requests` | `1000` | `GUNICORN_MAX_REQUESTS` | Restart workers after this many requests |
| `max_requests_jitter` | `50` | `GUNICORN_MAX_REQUESTS_JITTER` | Random jitter for max_requests |
| `preload_app` | `True` | `GUNICORN_PRELOAD_APP` | Load application code before worker processes |
| `worker_tmp_dir` | `/dev/shm` | `GUNICORN_WORKER_TMP_DIR` | Directory for worker temporary files |

### Logging Settings

| Setting | Default | Environment Variable | Description |
|---------|---------|---------------------|-------------|
| `accesslog` | `-` (stdout) | `GUNICORN_ACCESS_LOG` | Access log file |
| `errorlog` | `-` (stderr) | `GUNICORN_ERROR_LOG` | Error log file |
| `loglevel` | `info` | `GUNICORN_LOG_LEVEL` | Log level |

### Security Settings

| Setting | Default | Environment Variable | Description |
|---------|---------|---------------------|-------------|
| `limit_request_line` | `4094` | `GUNICORN_LIMIT_REQUEST_LINE` | Maximum size of HTTP request line |
| `limit_request_fields` | `100` | `GUNICORN_LIMIT_REQUEST_FIELDS` | Maximum number of headers |
| `limit_request_field_size` | `8190` | `GUNICORN_LIMIT_REQUEST_FIELD_SIZE` | Maximum size of header fields |

## Usage Examples

### Running with Docker

```bash
# Build the image
docker build -t flask-app .

# Run with default configuration
docker run -p 5000:5000 flask-app

# Run with custom worker count
docker run -p 5000:5000 -e GUNICORN_WORKERS=8 flask-app

# Run with custom bind address
docker run -p 8080:8080 -e GUNICORN_BIND=0.0.0.0:8080 flask-app

# Run with debug logging
docker run -p 5000:5000 -e GUNICORN_LOG_LEVEL=debug flask-app
```

### Running Locally

```bash
# Using the startup script
./run.sh

# Development mode with Flask dev server
./run.sh --dev

# Custom workers and port
./run.sh --workers 8 --port 8080

# Direct gunicorn command
gunicorn --config gunicorn.conf.py app:app

# With environment variables
GUNICORN_WORKERS=8 GUNICORN_LOG_LEVEL=debug gunicorn --config gunicorn.conf.py app:app
```

## Worker Configuration

### Worker Count Recommendations

- **Development**: 1-2 workers
- **Production**: `(2 × CPU cores) + 1`
- **High traffic**: Start with `(2 × CPU cores) + 1` and scale based on monitoring

### Worker Class Options

- `sync` (default): Standard synchronous workers
- `gevent`: Asynchronous workers using gevent
- `eventlet`: Asynchronous workers using eventlet
- `tornado`: Tornado workers

Example with async workers:
```bash
docker run -p 5000:5000 -e GUNICORN_WORKER_CLASS=gevent -e GUNICORN_WORKER_CONNECTIONS=1000 flask-app
```

## Monitoring and Health Checks

### Built-in Health Check

The Docker configuration includes a health check that pings the root endpoint every 30 seconds.

### Log Format

The default access log format includes:
- Client IP
- Request timestamp
- HTTP method and path
- Response status
- Response size
- User agent
- Request duration

### Process Monitoring

Gunicorn provides several hooks for monitoring:
- `when_ready`: Server is ready
- `pre_fork`/`post_fork`: Worker process lifecycle
- `worker_abort`: Worker received abort signal

## SSL/HTTPS Configuration

To enable HTTPS, set these environment variables:

```bash
GUNICORN_KEYFILE=/path/to/private.key
GUNICORN_CERTFILE=/path/to/certificate.crt
```

Then uncomment the SSL configuration in `gunicorn.conf.py`.

## Performance Tuning

### Memory Optimization

1. Enable `preload_app=True` (default) to share memory between workers
2. Set appropriate `max_requests` to prevent memory leaks
3. Use `/dev/shm` for worker temporary directory (default)

### Connection Tuning

1. Adjust `worker_connections` based on expected concurrent requests
2. Set appropriate `timeout` values for your application
3. Use `keepalive` for HTTP/1.1 persistent connections

### Example High-Performance Configuration

```bash
docker run -p 5000:5000 \
  -e GUNICORN_WORKERS=16 \
  -e GUNICORN_WORKER_CLASS=gevent \
  -e GUNICORN_WORKER_CONNECTIONS=1000 \
  -e GUNICORN_MAX_REQUESTS=1000 \
  -e GUNICORN_PRELOAD_APP=true \
  flask-app
```

## Troubleshooting

### Common Issues

1. **Workers timing out**: Increase `GUNICORN_TIMEOUT`
2. **High memory usage**: Reduce `GUNICORN_WORKERS` or enable worker recycling
3. **Connection refused**: Check `GUNICORN_BIND` setting
4. **Slow startup**: Disable `preload_app` if application has startup issues

### Debug Mode

Enable debug logging:
```bash
docker run -p 5000:5000 -e GUNICORN_LOG_LEVEL=debug flask-app
```

### Resource Monitoring

Monitor worker processes:
```bash
# Inside container
ps aux | grep gunicorn

# Memory usage
free -h

# Check worker temp directory
df -h /dev/shm
```

## Production Recommendations

1. **Use a reverse proxy** (nginx, Apache) in front of Gunicorn
2. **Set up proper logging** with log rotation
3. **Monitor worker processes** with process management tools
4. **Configure resource limits** in Docker/Kubernetes
5. **Set up health checks** and monitoring
6. **Use HTTPS** in production
7. **Configure firewall** rules appropriately

For more details, refer to the [official Gunicorn documentation](https://docs.gunicorn.org/en/stable/). 