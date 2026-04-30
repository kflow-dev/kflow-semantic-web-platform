#!/bin/bash

echo "Testing Docker deployment..."

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null; then
    echo "Error: docker-compose is not installed"
    exit 1
fi

# Check if docker daemon is running
if ! docker info &> /dev/null; then
    echo "Error: Docker daemon is not running"
    exit 1
fi

# Test docker-compose configuration
echo "Validating docker-compose configuration..."
docker-compose config

# Test if containers can be built
echo -e "\nTesting container build..."
docker-compose build --no-cache

echo -e "\nDocker deployment test completed successfully!"
echo "The configuration is valid and containers can be built."