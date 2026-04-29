# kflow-semantic-web-platform
Semantic web platform for knowledge flows.
Version: v01: 2026-04-29

Full stack platform for hosting interactive data products and services for knowledge flows - it is a lightweight internal platform (mini-SaaS), Docker-first, and modular, which can be tested and deployed locally (on macos/Ubuntu Linux) or remotely (Ubuntu).
  - full webshop backend (WooCommerce-style)
  - API-first CMS
  - AI-ready data pipeline
  - semantic-ready structure (LOD-compatible)
  - QR logistics tracking
  -  ultra-light VPS footprint

Core capabilities
  1. OAuth2 / SSO (Keycloak)
  2. API Gateway (Kong lightweight mode)
  3. CMS + commerce backend (Directus)
  4. AI/RAG service (LlamaIndex optional)
  5. Event streaming (Redis Streams)
  6. Real-time dashboard (simple WebSocket UI)
  7. Multi-tenant SaaS model
  8. QR tracking system
  9. Cart + checkout + orders

Technical stack:
        1. Directus → catalog + RBAC + media + workflows
        2. PostgreSQL → main DB
        3. Redis → cache/queue
        4. Apache Jena Fuseki → semantic layer
        5. Qdrant → embeddings (lightweight, Rust, fast)
        6. LlamaIndex → RAG API (Python)
        7. Keycloak → SSO
        8. Nginx → reverse proxy

Technical architecture:

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

Service	URL List:
- Directus	http://localhost:8055
- Keycloak	http://localhost:8080
- Listmonk	http://localhost:9001
- Jena  	http://localhost:3030
- Qdrant	http://localhost:6333
- RAG API	http://localhost:5000
- QR API	http://localhost:7000

