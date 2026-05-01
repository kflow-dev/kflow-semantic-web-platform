#!/bin/bash
set -euo pipefail

BASE_URL="${BASE_URL:-https://localhost}"
CURL_OPTS=(-fskL --connect-timeout 5 --max-time 30)

echo "Testing product pipeline endpoints through Nginx."

echo "1. Checking Directus API health."
curl "${CURL_OPTS[@]}" "$BASE_URL/server/health" >/dev/null

echo "2. Ingesting a sample product document into the RAG API."
curl "${CURL_OPTS[@]}" -X POST "$BASE_URL/rag/ingest" \
  -H "Content-Type: application/json" \
  -d '{"name":"product-123","content":"Product 123 is a semantic web demo product with QR tracking and RAG metadata."}' >/dev/null

echo "3. Indexing raw file content for the RAG API."
curl "${CURL_OPTS[@]}" -X POST "$BASE_URL/rag/index/raw" >/dev/null

echo "4. Querying the RAG API for the sample product."
curl "${CURL_OPTS[@]}" "$BASE_URL/rag/query?q=product%20123" >/dev/null

echo "5. Checking chat interaction against retrieved context."
curl "${CURL_OPTS[@]}" -X POST "$BASE_URL/rag/chat" \
  -H "Content-Type: application/json" \
  -d '{"message":"What is product 123?","top_k":3}' >/dev/null

echo "6. Generating and tracking a QR code for the sample product."
QR_RESPONSE="$(curl "${CURL_OPTS[@]}" -X POST "$BASE_URL/qr/generate" \
  -H "Content-Type: application/json" \
  -d '{"entity_id":"product-123"}')"
TOKEN="$(printf '%s' "$QR_RESPONSE" | sed -n 's/.*"token":"\([^"]*\)".*/\1/p')"
test -n "$TOKEN"
curl "${CURL_OPTS[@]}" "$BASE_URL/qr/track/$TOKEN" >/dev/null

echo "Product pipeline endpoint tests completed successfully."
