# Gunicorn configuration file
# https://docs.gunicorn.org/en/stable/settings.html

import multiprocessing
import os

# Server socket
bind = os.getenv("GUNICORN_BIND", "0.0.0.0:5000")
backlog = int(os.getenv("GUNICORN_BACKLOG", "2048"))

# Worker processes
workers = int(os.getenv("GUNICORN_WORKERS", multiprocessing.cpu_count() * 2 + 1))
worker_class = os.getenv("GUNICORN_WORKER_CLASS", "sync")
worker_connections = int(os.getenv("GUNICORN_WORKER_CONNECTIONS", "1000"))
timeout = int(os.getenv("GUNICORN_TIMEOUT", "120"))
keepalive = int(os.getenv("GUNICORN_KEEPALIVE", "2"))

# Restart workers after this many requests, to prevent memory leaks
max_requests = int(os.getenv("GUNICORN_MAX_REQUESTS", "1000"))
max_requests_jitter = int(os.getenv("GUNICORN_MAX_REQUESTS_JITTER", "50"))

# Logging
accesslog = os.getenv("GUNICORN_ACCESS_LOG", "-")  # Log to stdout
errorlog = os.getenv("GUNICORN_ERROR_LOG", "-")    # Log to stderr
loglevel = os.getenv("GUNICORN_LOG_LEVEL", "info")
access_log_format = os.getenv("GUNICORN_ACCESS_LOG_FORMAT", 
    '%(h)s %(l)s %(u)s %(t)s "%(r)s" %(s)s %(b)s "%(f)s" "%(a)s" %(D)s')

# Process naming
proc_name = os.getenv("GUNICORN_PROC_NAME", "flask_app")

# Worker temporary directory (use tmpfs for better performance)
worker_tmp_dir = os.getenv("GUNICORN_WORKER_TMP_DIR", "/dev/shm")

# Preload application for better performance and memory usage
preload_app = os.getenv("GUNICORN_PRELOAD_APP", "True").lower() in ("true", "1", "yes")

# Security settings
limit_request_line = int(os.getenv("GUNICORN_LIMIT_REQUEST_LINE", "4094"))
limit_request_fields = int(os.getenv("GUNICORN_LIMIT_REQUEST_FIELDS", "100"))
limit_request_field_size = int(os.getenv("GUNICORN_LIMIT_REQUEST_FIELD_SIZE", "8190"))

# SSL configuration (uncomment and configure if HTTPS is needed)
# keyfile = os.getenv("GUNICORN_KEYFILE")
# certfile = os.getenv("GUNICORN_CERTFILE")
# ssl_version = ssl.PROTOCOL_TLS
# cert_reqs = ssl.CERT_NONE
# ca_certs = None
# suppress_ragged_eofs = True

# Server mechanics
daemon = False
pidfile = os.getenv("GUNICORN_PIDFILE")
user = os.getenv("GUNICORN_USER")
group = os.getenv("GUNICORN_GROUP")
tmp_upload_dir = os.getenv("GUNICORN_TMP_UPLOAD_DIR")

# Graceful timeout for worker shutdown
graceful_timeout = int(os.getenv("GUNICORN_GRACEFUL_TIMEOUT", "30"))

# Hook functions for logging and monitoring
def when_ready(server):
    server.log.info("Server is ready. Spawning workers")

def worker_int(worker):
    worker.log.info("Worker received INT or QUIT signal")

def pre_fork(server, worker):
    server.log.info("Worker spawned (pid: %s)", worker.pid)

def post_fork(server, worker):
    server.log.info("Worker spawned (pid: %s)", worker.pid)

def post_worker_init(worker):
    worker.log.info("Worker initialized (pid: %s)", worker.pid)

def worker_abort(worker):
    worker.log.info("Worker received SIGABRT signal")

def on_exit(server):
    server.log.info("Server is shutting down")

def on_reload(server):
    server.log.info("Server is reloading configuration") 