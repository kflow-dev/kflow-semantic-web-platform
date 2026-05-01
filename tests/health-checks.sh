#!/bin/bash
set -euo pipefail

BASE_URL="${BASE_URL:-https://localhost}"
CURL_OPTS=(-fskL --connect-timeout 5 --max-time 30)

check() {
  name="$1"
  path="$2"
  echo "Checking $name at $BASE_URL$path"
  curl "${CURL_OPTS[@]}" "$BASE_URL$path" >/dev/null
}

echo "Running health checks through Nginx front end."
check "Nginx" "/health"
check "Directus" "/server/health"
check "Keycloak" "/auth/"
check "FastAPI" "/api/health"
check "RAG API" "/rag/health"
check "QR API" "/qr/health"
check "Jena Fuseki" "/jena/"
check "Qdrant" "/qdrant/"
check "Prometheus" "/prometheus/-/healthy"
check "Grafana" "/grafana/api/health"

echo "Health checks completed successfully."
