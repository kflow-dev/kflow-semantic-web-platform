# kflow-semantic-web-platform

Semantic web platform for knowledge flows.
Version: v01: 2026-04-29

Full stack platform for hosting interactive data products and services for knowledge flows - it is a lightweight internal platform (mini-SaaS), Docker-first, and modular, which can be tested and deployed locally (on macos/Ubuntu Linux) or remotely (Ubuntu).

  - full webshop backend (WooCommerce-style)
  - API-first CMS
  - AI-ready data pipeline
  - semantic-ready structure (LOD-compatible)
  - QR logistics tracking
  - ultra-light VPS footprint

## Core capabilities
  1. OAuth2 / SSO (Keycloak)
  2. API Gateway (Kong lightweight mode)
  3. CMS + commerce backend (Directus)
  4. AI/RAG service (LlamaIndex optional)
  5. Event streaming (Redis Streams)
  6. Real-time dashboard (simple WebSocket UI)
  7. Multi-tenant SaaS model
  8. QR tracking system
  9. Cart + checkout + orders

## Technical stack:
        1. Directus → catalog + RBAC + media + workflows
        2. PostgreSQL → main DB
        3. Redis → cache/queue
        4. Apache Jena Fuseki → semantic layer
        5. Qdrant → embeddings (lightweight, Rust, fast)
        6. LlamaIndex → RAG API (Python)
        7. Keycloak → SSO
        8. Nginx → reverse proxy

## Technical architecture:
'''
                 🌐 Nginx (TLS)
                        |
                 API Gateway (Kong)
                        |
     ------------------------------------------------
     |            |             |                  |
 Directus     Auth (Keycloak)  AI/RAG        Event API
     |                             |
 PostgreSQL                    Qdrant (optional)
     |
 Redis Streams (events)
     |
 Real-time Dashboard (WebSocket)
'''

## Service URL List:
- Directus      http://localhost:8055
- Keycloak      http://localhost:8080
- Listmonk      http://localhost:9001
- Jena          http://localhost:3030
- Qdrant        http://localhost:6333
- RAG API       http://localhost:5000
- QR API        http://localhost:7000

## Getting Started

### Prerequisites
- Docker and Docker Compose installed
- At least 4GB RAM available for the development environment

### Local Development Setup

1. Clone the repository
2. Copy the example environment file:
   ```bash
   cp .env.template .env
   ```

3. Start all services:
   ```bash
   docker-compose up -d
   ```

4. Wait for all containers to start (this may take a few minutes)
5. Access the services:
   - Directus: http://localhost:8055
   - Keycloak: http://localhost:8080
   - Jena: http://localhost:3030
   - Qdrant: http://localhost:6333
   - RAG API: http://localhost:5000
   - QR API: http://localhost:7000

### Initial Setup in Directus

1. Navigate to http://localhost:8055
2. Log in with:
   - Email: admin@example.com
   - Password: admin123

3. Create a new collection for products:
   - Go to Settings → Collections
   - Click "Create Collection"
   - Name: products
   - Add fields:
     - name (string)
     - description (text)
     - price (number)
     - stock_quantity (number)
     - image (file)
     - qr_code (string)

4. Create a new collection for users:
   - Go to Settings → Collections
   - Click "Create Collection"
   - Name: users
   - Add fields:
     - email (string)
     - first_name (string)
     - last_name (string)
     - subscription_status (string)

5. Create a new collection for orders:
   - Go to Settings → Collections
   - Click "Create Collection"
   - Name: orders
   - Add fields:
     - user_id (relation to users)
     - product_id (relation to products)
     - quantity (number)
     - status (string)
     - delivery_status (string)

### Sample Content

To populate the CMS with sample data, follow these steps:

1. Create sample products:
   - Product 1: "Wireless Headphones"
     - Description: "High-quality wireless headphones with noise cancellation"
     - Price: 199.99
     - Stock: 50
   - Product 2: "Smartphone"
     - Description: "Latest model smartphone with advanced features"
     - Price: 699.99
     - Stock: 25
   - Product 3: "Laptop"
     - Description: "Powerful laptop for professional use"
     - Price: 1299.99
     - Stock: 15

2. Create sample users:
   - User 1: John Doe (john.doe@example.com)
   - User 2: Jane Smith (jane.smith@example.com)

3. Create sample orders:
   - Order for John Doe: 2 Wireless Headphones
   - Order for Jane Smith: 1 Laptop

### Testing the Web UI and API Endpoints

#### Testing Directus CMS
1. Access Directus at http://localhost:8055
2. Login with admin@example.com / admin123
3. Navigate to the Products collection to view and edit products
4. Test CRUD operations for products, users, and orders

#### Testing QR Code Generation and Tracking
1. Generate a QR code:
   ```bash
   curl -X POST http://localhost:7000/generate -d '{"entity_id": "product-123"}'
   ```

2. Track the generated QR code:
   ```bash
   curl http://localhost:7000/track/{token}
   ```

3. View the QR code image in the browser:
   - Navigate to http://localhost:7000/track/{token}

#### Testing Product Management
1. Create products via Directus UI
2. Verify products appear in the webshop
3. Test product search functionality
4. Test product details view

#### Testing User Management and Orders
1. Create user accounts via Directus UI
2. Test user login functionality
3. Test cart functionality
4. Test checkout process
5. Verify order creation in Directus

## Configuration Files

The platform includes configuration files for each component in the `config/` directory:

- `config/directus.json` - Directus configuration
- `config/postgres.yml` - PostgreSQL service configuration  
- `config/keycloak.json` - Keycloak SSO configuration
- `config/jena.ttl` - Jena Fuseki semantic configuration
- `config/qdrant.yaml` - Qdrant vector database configuration

## Testing

The platform includes automated tests in the `tests/` directory:

- `tests/health-checks.sh` - Checks if all services are running properly
- `tests/product-endpoint-tests.sh` - Tests product management API endpoints
- `tests/end-to-end-test.sh` - Runs complete end-to-end workflow test
- `tests/deployment-test.sh` - Validates Docker deployment configuration

Run tests with:
```bash
# Run all health checks
./tests/health-checks.sh

# Run end-to-end test
./tests/end-to-end-test.sh

# Run deployment validation
./tests/deployment-test.sh
```

## End-to-End Scenario Testing

### Typical User Flow:
1. User visits the webshop
2. User browses products
3. User adds products to cart
4. User proceeds to checkout
5. User fills in user details
6. User completes payment
7. System generates QR code for tracking
8. User can track product status via QR code

### Testing Steps:
1. **Product Management**: Create and view products in Directus
2. **User Registration**: Register new users
3. **Cart Functionality**: Add/remove products from cart
4. **Checkout Process**: Complete a purchase
5. **QR Generation**: Generate QR codes for products
6. **Tracking**: Track product status using QR codes
7. **Order Management**: View and manage orders in Directus

### Sample API Endpoints:
- `GET /api/products` - Get all products
- `POST /api/cart/add` - Add product to cart
- `POST /api/checkout` - Process checkout
- `POST /api/qr/generate` - Generate QR code
- `GET /api/qr/track/{token}` - Track product status

## Troubleshooting

### Common Issues:
1. **Port conflicts**: Ensure ports 8055, 8080, 3030, 6333, 5000, 7000 are free
2. **Database initialization**: Wait for PostgreSQL to initialize before accessing Directus
3. **Docker permissions**: Run with sudo if needed or add user to docker group

### Useful Commands:
```bash
# View logs
docker-compose logs -f

# Stop all services
docker-compose down

# Restart services
docker-compose restart

# View running containers
docker-compose ps
```

## Contributing

This project is a work in progress. Contributions are welcome through pull requests.

## Production Deployment on Ubuntu 22.04

The production profile is designed for an unmanaged VPS with about 5 GB RAM. The default Compose stack keeps Keycloak and Ollama optional, exposes only Nginx, and validates its memory budget with `./tests/resource-budget-test.sh`.

### Server prerequisites

```bash
sudo apt update
sudo apt install -y ca-certificates curl git openssl
curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker "$USER"
```

Log out and back in, then clone the repository:

```bash
sudo mkdir -p /opt/kflow-semantic-web-platform
sudo chown "$USER:$USER" /opt/kflow-semantic-web-platform
git clone <repo-url> /opt/kflow-semantic-web-platform
cd /opt/kflow-semantic-web-platform
cp .env.template .env
```

Edit `.env` and set `DOMAIN`, `PUBLIC_URL`, all passwords, and TLS file paths. For a standalone deployment where Docker Nginx owns ports 80 and 443:

```bash
ENV_FILE=.env ./scripts/deploy.sh production
BASE_URL=https://your-domain.example ENV_FILE=.env ./tests/end-to-end-test.sh
```

### Integrating with an existing host Nginx

If the VPS already has Nginx listening on HTTP `80` and HTTPS `443`, do not publish Docker Nginx on those ports. In `.env`, bind the container front end to loopback-only alternate ports:

```env
NGINX_HTTP_PORT=127.0.0.1:8088
NGINX_HTTPS_PORT=127.0.0.1:8443
PUBLIC_URL=https://your-domain.example
```

Then configure the host Nginx as the public TLS terminator and verified reverse proxy. Use the same certificate paths in `.env` so Docker Nginx presents a certificate trusted by the host proxy.

```nginx
server {
    listen 80;
    server_name your-domain.example;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    server_name your-domain.example;

    ssl_certificate /etc/letsencrypt/live/your-domain.example/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/your-domain.example/privkey.pem;

    location / {
        proxy_pass https://127.0.0.1:8443;
        proxy_ssl_server_name on;
        proxy_ssl_name your-domain.example;
        proxy_ssl_trusted_certificate /etc/letsencrypt/live/your-domain.example/fullchain.pem;
        proxy_ssl_verify on;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
    }
}
```

Reload host Nginx and deploy:

```bash
sudo nginx -t && sudo systemctl reload nginx
ENV_FILE=.env ./scripts/deploy.sh production
```

Public routes are `/` for Directus, `/rag/` for RAG APIs, `/qr/`, `/jena/`, `/qdrant/`, `/prometheus/`, and `/grafana/`. Start optional services only when there is enough RAM:

```bash
docker compose --env-file .env --profile auth up -d keycloak
docker compose --env-file .env --profile llm up -d ollama
```

## Graph RAG Pipeline Workflow

Use the Web UI to create product/content collections in Directus, upload CMS files or media, and place batch files in `data/raw/`. Index content from the CLI:

```bash
curl -k -X POST https://your-domain.example/rag/index/raw
curl -k -X POST https://your-domain.example/rag/ingest \
  -H "Content-Type: application/json" \
  -d '{"name":"sku-123","content":"Product facts, links, and semantic metadata."}'
curl -k "https://your-domain.example/rag/query?q=sku-123"
curl -k -X POST https://your-domain.example/rag/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"Summarize sku-123","top_k":5}'
```

For Python workflow examples using LangChain, LlamaIndex, LangGraph, Qdrant, and Ollama-style chat, open [notebooks/graph_rag_pipeline.ipynb](notebooks/graph_rag_pipeline.ipynb). Recommended notebook packages:

```bash
pip install -U jupyter requests qdrant-client langchain langchain-ollama langchain-qdrant langgraph llama-index llama-index-llms-ollama llama-index-embeddings-ollama
```

## License

This project is licensed under the MIT License.
