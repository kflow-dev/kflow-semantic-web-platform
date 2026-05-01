#!/bin/bash
set -euo pipefail

ENV_FILE="${ENV_FILE:-.env.dev}"
BASE_URL="${BASE_URL:-https://localhost}"

compose() {
  if docker compose version >/dev/null 2>&1; then
    docker compose --env-file "$ENV_FILE" "$@"
  else
    docker-compose --env-file "$ENV_FILE" "$@"
  fi
}

echo "Running end-to-end scenario through $BASE_URL."

echo "1. Verifying containers are running."
compose ps

echo "2. Checking public Nginx-routed endpoints."
BASE_URL="$BASE_URL" ./tests/health-checks.sh

echo "3. Running product RAG and QR workflow."
BASE_URL="$BASE_URL" ./tests/product-endpoint-tests.sh

echo "4. Verifying PostgreSQL from inside the backend network."
compose exec -T postgres sh -c 'pg_isready -U "$POSTGRES_USER" -d "$POSTGRES_DB"'

echo "End-to-end scenario completed successfully."
