#!/bin/bash

# PostgreSQL 17 Setup Script for Podman
set -e

# Configuration
CONTAINER_NAME="postgres-study"
POSTGRES_VERSION="17"
POSTGRES_PORT="5432"
POSTGRES_DB="demo"
POSTGRES_USER="postgres"
POSTGRES_PASSWORD="password"
DATA_DIR="$(pwd)/postgres-data"

echo "Setting up PostgreSQL 17 with Podman..."

# Stop and remove existing container if it exists
if podman ps -a --format "table {{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
    echo "Stopping and removing existing container..."
    podman stop $CONTAINER_NAME || true
    podman rm $CONTAINER_NAME || true
fi

# Create data directory if it doesn't exist
mkdir -p "$DATA_DIR"

# Pull PostgreSQL 17 image
echo "Pulling PostgreSQL $POSTGRES_VERSION image..."
podman pull docker.io/postgres:$POSTGRES_VERSION

# Run PostgreSQL container
echo "Starting PostgreSQL container..."
podman run -d \
    --name $CONTAINER_NAME \
    -e POSTGRES_DB=$POSTGRES_DB \
    -e POSTGRES_USER=$POSTGRES_USER \
    -e POSTGRES_PASSWORD=$POSTGRES_PASSWORD \
    -p $POSTGRES_PORT:5432 \
    -v "$DATA_DIR:/var/lib/postgresql/data:Z" \
    docker.io/postgres:$POSTGRES_VERSION

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
sleep 10

# Check if container is running
if ! podman ps --format "table {{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
    echo "Error: Container failed to start"
    exit 1
fi

# Test connection
echo "Testing connection..."
if podman exec $CONTAINER_NAME pg_isready -U $POSTGRES_USER; then
    echo "PostgreSQL is ready!"
else
    echo "Error: PostgreSQL is not ready"
    exit 1
fi

# Create demo database and load data if dump exists
if [ -f "db/demo-big-20170815.sql" ]; then
    echo "Creating demo database and loading data..."
    podman exec $CONTAINER_NAME createdb -U $POSTGRES_USER -O $POSTGRES_USER $POSTGRES_DB || true
    podman exec -i $CONTAINER_NAME psql -U $POSTGRES_USER -d $POSTGRES_DB < db/demo-big-20170815.sql
    echo "Demo database loaded successfully!"
fi

echo ""
echo "PostgreSQL 17 is now running!"
echo "Connection details:"
echo "  Host: localhost"
echo "  Port: $POSTGRES_PORT"
echo "  Database: $POSTGRES_DB"
echo "  Username: $POSTGRES_USER"
echo "  Password: $POSTGRES_PASSWORD"
echo ""
echo "Connect with: psql -h localhost -p $POSTGRES_PORT -U $POSTGRES_USER -d $POSTGRES_DB"
echo "Stop container: podman stop $CONTAINER_NAME"
echo "Start container: podman start $CONTAINER_NAME"
