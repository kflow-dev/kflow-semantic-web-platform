# Cleanup Instructions for kflow-semantic-web-platform

## Complete Cleanup Script

To clean up all generated files by the Docker deployment and start anew, run the following commands:

```bash
# Stop all running containers
docker-compose down

# Remove all Docker volumes (including databases)
docker-compose down -v

# Remove all Docker images for this project
docker rmi $(docker images | grep kflow | awk '{print $3}')

# Clean up any dangling images
docker image prune -f

# Clean up any unused containers
docker container prune -f

# Clean up any unused networks
docker network prune -f

# Remove local data directories
rm -rf data/postgres

# Remove any generated test files
rm -rf tests/*.sh

# Remove any generated config files
rm -rf config/*.json
rm -rf config/*.yml
rm -rf config/*.yaml
rm -rf config/*.ttl

# Reset git to clean state (if needed)
git clean -fd
git reset --hard
```

## Partial Cleanup Options

### Clean only containers and networks:
```bash
docker-compose down
```

### Clean containers, networks, and volumes:
```bash
docker-compose down -v
```

### Clean only data directories:
```bash
rm -rf data/postgres
```

## After Cleanup

To start fresh:

1. Rebuild the containers:
   ```bash
   docker-compose up -d
   ```

2. Initialize the database:
   ```bash
   docker-compose exec postgres psql -U directus -d directus -c "CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";"
   ```

3. Access services:
   - Directus: http://localhost:8055
   - Keycloak: http://localhost:8080
   - Jena: http://localhost:3030
   - Qdrant: http://localhost:6333
   - RAG API: http://localhost:5000
   - QR API: http://localhost:7000