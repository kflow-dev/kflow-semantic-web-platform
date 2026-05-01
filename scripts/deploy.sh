#!/bin/bash
set -euo pipefail

TARGET="${1:-local}"
if [ -z "${ENV_FILE:-}" ]; then
  if [ "$TARGET" = "production" ]; then
    ENV_FILE=".env"
  else
    ENV_FILE=".env.dev"
  fi
fi

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

load_env() {
  if [ ! -f "$ENV_FILE" ]; then
    echo "Error: $ENV_FILE does not exist. Copy .env.template and set production values."
    exit 1
  fi
}

ensure_local_certs() {
  mkdir -p .local/certs
  if [ ! -f .local/certs/localhost.crt ] || [ ! -f .local/certs/localhost.key ]; then
    openssl req -x509 -nodes -newkey rsa:2048 -days 365 \
      -keyout .local/certs/localhost.key \
      -out .local/certs/localhost.crt \
      -subj "/CN=localhost" \
      -addext "subjectAltName=DNS:localhost,IP:127.0.0.1"
  fi
}

validate_prod_tls() {
  cert_file="$(grep '^TLS_CERT_FILE=' "$ENV_FILE" | cut -d= -f2-)"
  key_file="$(grep '^TLS_KEY_FILE=' "$ENV_FILE" | cut -d= -f2-)"
  if [ ! -f "$cert_file" ] || [ ! -f "$key_file" ]; then
    echo "Error: production TLS files do not exist: $cert_file $key_file"
    exit 1
  fi
}

require_command docker
load_env
mkdir -p data/raw

case "$TARGET" in
  local)
    require_command openssl
    ensure_local_certs
    ;;
  production)
    validate_prod_tls
    ;;
  *)
    echo "Usage: ENV_FILE=.env.dev ./scripts/deploy.sh local"
    echo "       ENV_FILE=.env ./scripts/deploy.sh production"
    exit 1
    ;;
esac

echo "Deploying $TARGET with $ENV_FILE."
compose config >/dev/null
compose pull --ignore-pull-failures
compose up -d --build --remove-orphans
compose ps
