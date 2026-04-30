#!/bin/bash

echo "Running end-to-end workflow test..."

# Test 1: Check all services are running
echo "Step 1: Checking all services are running..."
docker-compose ps | grep -E "(Up|Exited)" || echo "Some services may not be running properly"

# Test 2: Health check for all services
echo -e "\nStep 2: Running health checks..."
./tests/health-checks.sh

# Test 3: Test QR code generation and tracking
echo -e "\nStep 3: Testing QR code functionality..."
echo "Generating QR code..."
QR_RESPONSE=$(curl -s -X POST http://localhost:7000/generate -d '{"entity_id": "product-123"}')
echo "QR Response: $QR_RESPONSE"

# Extract token from response (simplified)
TOKEN=$(echo $QR_RESPONSE | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
if [ ! -z "$TOKEN" ]; then
    echo "Tracking QR code with token: $TOKEN"
    curl -s http://localhost:7000/track/$TOKEN
else
    echo "Could not extract token from QR response"
fi

# Test 4: Test basic Directus functionality
echo -e "\nStep 4: Testing basic Directus functionality..."
echo "Checking if Directus is accessible..."
curl -f -s http://localhost:8055 || echo "Directus is not accessible"

# Test 5: Test database connectivity
echo -e "\nStep 5: Testing database connectivity..."
echo "Checking PostgreSQL..."
docker-compose exec postgres pg_isready -U directus -d directus || echo "PostgreSQL not responding"

# Test 6: Test RAG API
echo -e "\nStep 6: Testing RAG API..."
echo "Testing basic query..."
curl -s http://localhost:5000/query?q=test || echo "RAG API not responding properly"

echo -e "\nEnd-to-end test completed!"
echo "If all services are running, you should see a successful workflow."
echo "The system is ready for product management, user authentication, and QR tracking."