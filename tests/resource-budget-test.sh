#!/bin/bash
set -euo pipefail

ENV_FILE="${ENV_FILE:-.env.dev}"
MAX_RAM_MB="${MAX_RAM_MB:-5120}"

to_mb() {
  value="$1"
  case "$value" in
    *g|*G) echo "$(( ${value%?} * 1024 ))" ;;
    *m|*M) echo "${value%?}" ;;
    *) echo "$value" ;;
  esac
}

get_limit() {
  key="$1"
  fallback="$2"
  value="$(grep "^$key=" "$ENV_FILE" | cut -d= -f2- || true)"
  echo "${value:-$fallback}"
}

default_limits=(
  "POSTGRES_MEMORY_LIMIT:700m"
  "REDIS_MEMORY_LIMIT:128m"
  "DIRECTUS_MEMORY_LIMIT:700m"
  "JENA_MEMORY_LIMIT:700m"
  "QDRANT_MEMORY_LIMIT:700m"
  "FASTAPI_MEMORY_LIMIT:256m"
  "RAG_MEMORY_LIMIT:512m"
  "QR_MEMORY_LIMIT:128m"
  "NGINX_MEMORY_LIMIT:128m"
  "PROMETHEUS_MEMORY_LIMIT:256m"
  "GRAFANA_MEMORY_LIMIT:384m"
)

total=0
for item in "${default_limits[@]}"; do
  key="${item%%:*}"
  fallback="${item##*:}"
  limit="$(get_limit "$key" "$fallback")"
  mb="$(to_mb "$limit")"
  printf "%-28s %5s MB\n" "$key" "$mb"
  total="$((total + mb))"
done

echo "Default stack memory budget: ${total} MB / ${MAX_RAM_MB} MB"
if [ "$total" -gt "$MAX_RAM_MB" ]; then
  echo "Error: default stack exceeds memory budget"
  exit 1
fi

echo "Resource budget check passed."
