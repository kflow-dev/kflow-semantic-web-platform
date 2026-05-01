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

## Production Deployment on Ubuntu 22.04 VPS

### Prerequisites
- Ubuntu 22.04 LTS server
- Docker and Docker Compose installed
- A domain name pointing to your server
- SSL certificate (recommended but optional for testing)

### Deployment Steps

1. SSH into your Ubuntu server
2. Install Docker and Docker Compose:
   ```bash
   sudo apt update
   sudo apt install docker.io docker-compose
   ```

3. Clone the repository:
   ```bash
   git clone https://github.com/kflow-dev/kflow-semantic-web-platform.git
   cd kflow-semantic-web-platform
   ```

4. Configure environment variables:
   ```bash
   cp .env.example .env
   # Edit .env to set your domain and passwords
   ```

5. Start services:
   ```bash
   docker-compose up -d
   ```

6. Configure firewall:
   ```bash
   sudo ufw allow 22
   sudo ufw allow 80
   sudo ufw allow 443
   sudo ufw enable
   ```

7. Configure reverse proxy (Nginx) for HTTPS:
   ```bash
   sudo apt install nginx
   # Configure Nginx with SSL certificate
   ```

### File Structure for Production

```
/kflow-semantic-web-platform/
├── docker-compose.yml
├── .env
├── .env.example
├── data/
│   └── postgres/
├── services/
│   ├── llamaindex/
│   │   ├── Dockerfile
│   │   ├── app.py
│   │   └── requirements.txt
│   └── qr/
│       ├── Dockerfile
│       └── app.py
├── config/
│   ├── directus.json
│   ├── postgres.yml
│   ├── keycloak.json
│   ├── jena.ttl
│   └── qdrant.yaml
├── tests/
│   ├── health-checks.sh
│   ├── product-endpoint-tests.sh
│   ├── end-to-end-test.sh
│   └── deployment-test.sh
└── README.md
```

### Testing Production Deployment

1. Verify all containers are running:
   ```bash
   docker-compose ps
   ```

2. Test service endpoints:
   ```bash
   curl http://localhost:8055
   curl http://localhost:7000
   curl http://localhost:5000
   ```

3. Verify database connectivity:
   ```bash
   docker-compose exec postgres psql -U directus -d directus
   ```

4. Test user authentication:
   ```bash
   curl http://localhost:8080
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

## License

This project is licensed under the MIT License.
