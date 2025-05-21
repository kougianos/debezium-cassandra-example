#!/bin/bash

# Display banner
echo "====================================================="
echo "  Debezium Cassandra Example - Clean Start Script"
echo "====================================================="
echo

# Export the Debezium version
export DEBEZIUM_VERSION=2.1

# Stop any running containers from this compose file
echo "Stopping any running containers..."
docker-compose -f docker-compose-cassandra.yaml down -v

# Remove any dangling volumes
echo "Removing dangling volumes..."
docker volume prune -f

# Rebuild and start the containers
echo "Starting containers with a clean environment..."
docker-compose -f docker-compose-cassandra.yaml up --build