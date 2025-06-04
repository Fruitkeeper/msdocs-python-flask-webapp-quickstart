#!/bin/bash

# Flask application startup script
# This script can be used to run the application locally or in containers

set -e

# Default values
DEFAULT_WORKERS=4
DEFAULT_PORT=5000
DEFAULT_HOST="0.0.0.0"
DEFAULT_LOG_LEVEL="info"

# Function to display usage
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -w, --workers NUMBER     Number of worker processes (default: $DEFAULT_WORKERS)"
    echo "  -p, --port NUMBER        Port to bind to (default: $DEFAULT_PORT)"
    echo "  -h, --host HOST          Host to bind to (default: $DEFAULT_HOST)"
    echo "  -l, --log-level LEVEL    Log level (default: $DEFAULT_LOG_LEVEL)"
    echo "  --dev                    Run in development mode (Flask dev server)"
    echo "  --help                   Show this help message"
    echo ""
    echo "Environment variables:"
    echo "  GUNICORN_WORKERS         Number of workers"
    echo "  GUNICORN_BIND            Host:port to bind to"
    echo "  GUNICORN_LOG_LEVEL       Log level"
    echo "  FLASK_ENV                Flask environment (development/production)"
    exit 1
}

# Parse command line arguments
WORKERS=${GUNICORN_WORKERS:-$DEFAULT_WORKERS}
HOST=$DEFAULT_HOST
PORT=$DEFAULT_PORT
LOG_LEVEL=${GUNICORN_LOG_LEVEL:-$DEFAULT_LOG_LEVEL}
DEV_MODE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -w|--workers)
            WORKERS="$2"
            shift 2
            ;;
        -p|--port)
            PORT="$2"
            shift 2
            ;;
        -h|--host)
            HOST="$2"
            shift 2
            ;;
        -l|--log-level)
            LOG_LEVEL="$2"
            shift 2
            ;;
        --dev)
            DEV_MODE=true
            shift
            ;;
        --help)
            usage
            ;;
        *)
            echo "Unknown option $1"
            usage
            ;;
    esac
done

# Set environment variables
export GUNICORN_WORKERS="$WORKERS"
export GUNICORN_BIND="$HOST:$PORT"
export GUNICORN_LOG_LEVEL="$LOG_LEVEL"

echo "Starting Flask application..."
echo "Workers: $WORKERS"
echo "Bind: $HOST:$PORT"
echo "Log Level: $LOG_LEVEL"
echo "Development Mode: $DEV_MODE"
echo ""

if [ "$DEV_MODE" = true ]; then
    echo "Running in development mode with Flask dev server..."
    export FLASK_ENV=development
    export FLASK_DEBUG=1
    flask run --host="$HOST" --port="$PORT"
else
    echo "Running in production mode with Gunicorn..."
    gunicorn --config gunicorn.conf.py app:app
fi 