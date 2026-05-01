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

if ! docker info >/dev/null 2>&1; then
  echo "Error: Docker daemon is not running"
  exit 1
fi

echo "Validating Docker Compose configuration with $ENV_FILE."
compose config >/dev/null

echo "Checking default stack memory budget."
./tests/resource-budget-test.sh

echo "Building application images."
compose build

echo "Deployment configuration is valid."
