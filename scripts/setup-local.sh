#!/bin/bash
set -euo pipefail

ENV_FILE="${ENV_FILE:-.env.dev}"

compose() {
  if docker compose version >/dev/null 2>&1; then
    docker compose --env-file "$ENV_FILE" "$@"
  else
    docker-compose --env-file "$ENV_FILE" "$@"
  fi
}

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Error: $1 is required"
    exit 1
  fi
}

ensure_dev_env() {
  if [ ! -f "$ENV_FILE" ]; then
    cp .env.template "$ENV_FILE"
    echo "Created $ENV_FILE from .env.template; review secrets before deploying."
  fi
}

ensure_local_certs() {
  mkdir -p .local/certs
  if [ ! -f .local/certs/localhost.crt ] || [ ! -f .local/certs/localhost.key ]; then
    echo "Generating self-signed localhost TLS certificate."
    openssl req -x509 -nodes -newkey rsa:2048 -days 365 \
      -keyout .local/certs/localhost.key \
      -out .local/certs/localhost.crt \
      -subj "/CN=localhost" \
      -addext "subjectAltName=DNS:localhost,IP:127.0.0.1"
  fi
}

require_command docker
require_command openssl
ensure_dev_env
ensure_local_certs
mkdir -p data/raw

echo "Validating Compose configuration with $ENV_FILE."
compose config >/dev/null

echo "Building and starting the local platform."
compose up -d --build --remove-orphans

echo "Local endpoints are available through Nginx only:"
echo "- HTTP redirect: http://localhost"
echo "- HTTPS: https://localhost"
echo "- Directus: https://localhost/"
echo "- Keycloak: https://localhost/auth/"
echo "- API: https://localhost/api/"
echo "- RAG API: https://localhost/rag/"
echo "- QR API: https://localhost/qr/"
echo "- Jena: https://localhost/jena/"
echo "- Qdrant: https://localhost/qdrant/"
echo "- Prometheus: https://localhost/prometheus/"
echo "- Grafana: https://localhost/grafana/"
echo ""
echo "Optional profiles:"
echo "- Keycloak: docker compose --env-file $ENV_FILE --profile auth up -d keycloak"
echo "- Ollama: set OLLAMA_URL=http://ollama:11434 and run with --profile llm"
