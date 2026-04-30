#!/bin/bash

echo "Running health checks for kflow-semantic-web-platform..."

# Check if all containers are running
echo "1. Checking running containers..."
docker-compose ps

# Check Directus service
echo -e "\n2. Testing Directus service..."
curl -f http://localhost:8055 || echo "Directus service is not responding"

# Check Keycloak service
echo -e "\n3. Testing Keycloak service..."
curl -f http://localhost:8080 || echo "Keycloak service is not responding"

# Check Jena service
echo -e "\n4. Testing Jena service..."
curl -f http://localhost:3030 || echo "Jena service is not responding"

# Check Qdrant service
echo -e "\n5. Testing Qdrant service..."
curl -f http://localhost:6333 || echo "Qdrant service is not responding"

# Check QR API service
echo -e "\n6. Testing QR API service..."
curl -f http://localhost:7000 || echo "QR API service is not responding"

# Check RAG API service
echo -e "\n7. Testing RAG API service..."
curl -f http://localhost:5000 || echo "RAG API service is not responding"

echo -e "\nHealth checks completed!"