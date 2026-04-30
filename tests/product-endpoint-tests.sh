#!/bin/bash

echo "Testing product management endpoints..."

# Test Directus API for products
echo "1. Testing Directus products API..."
curl -X GET http://localhost:8055/items/products \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwicm9sZSI6ImFkbWluIiwiaWF0IjoxNjE3Mzg0MDAwfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c" \
  -H "Content-Type: application/json" || echo "Directus products API not responding"

# Test QR API endpoints
echo -e "\n2. Testing QR API - generating QR code..."
curl -X POST http://localhost:7000/generate \
  -H "Content-Type: application/json" \
  -d '{"entity_id": "test-product-123"}' || echo "QR API generate endpoint not responding"

echo -e "\n3. Testing QR API - tracking QR code..."
curl -X GET http://localhost:7000/track/test-token-123 || echo "QR API track endpoint not responding"

# Test RAG API endpoint
echo -e "\n4. Testing RAG API..."
curl -X GET http://localhost:5000/query?q=hello || echo "RAG API not responding"

echo -e "\nProduct endpoint tests completed!"