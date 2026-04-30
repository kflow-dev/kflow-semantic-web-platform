#!/bin/bash

echo "Setting up local development environment..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Copy environment file if it doesn't exist
if [ ! -f ".env" ]; then
    echo "Creating .env file from example..."
    cp .env.example .env
fi

# Start all services
echo "Starting all services..."
docker-compose up -d

echo "Waiting for services to start..."
sleep 10

echo "Services started successfully!"
echo "Access the following services:"
echo "- Directus: http://localhost:8055"
echo "- Keycloak: http://localhost:8080"
echo "- Jena: http://localhost:3030"
echo "- Qdrant: http://localhost:6333"
echo "- RAG API: http://localhost:5000"
echo "- QR API: http://localhost:7000"

echo ""
echo "Initial login credentials:"
echo "- Directus: admin@example.com / admin123"
echo "- Keycloak: admin / admin"