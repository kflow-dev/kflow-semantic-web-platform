#!/bin/bash
set -e

# 🛠 Ubuntu 22.04 VPS One-Shot Deploy Script
# Run: sudo bash deploy.sh

PROJECT_DIR="/opt/ai-stack"
VPS_USER="deploy"
HTTPS=false
DOMAIN=""

echo "🚀 Starting AI Stack deployment..."

# 1. Install Docker
if ! command -v docker &> /dev/null; then
  echo "📦 Installing Docker..."
  curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
  sudo sh /tmp/get-docker.sh
  sudo usermod -aG docker $USER
fi

# 2. Install Docker Compose v2
if ! docker compose version &> /dev/null; then
  echo "📦 Installing Docker Compose..."
  sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
fi

# 3. Create project dir
sudo mkdir -p $PROJECT_DIR
sudo chown -R $USER:$USER $PROJECT_DIR
cd $PROJECT_DIR

# 4. Copy .env (if exists) or use defaults
if [ -f .env ]; then
  echo "✅ Using existing .env"
else
  echo "🔧 Generating .env (override secrets manually!)"
  cat > .env << EOF
DIRECTUS_KEY=$(openssl rand -base64 24)
DIRECTUS_SECRET=$(openssl rand -base64 24)
POSTGRES_PASSWORD=$(openssl rand -base64 16)
DIRECTUS_PORT=8055
WIKIJS_PORT=3000
FASTAPI_PORT=8000
NEXTJS_PORT=3001
NGINX_HTTP_PORT=80
COMPOSE_PROJECT_NAME=ai-stack
EOF
fi

# 5. Deploy
echo "🚀 Deploying ai-stack..."
docker compose down --remove-orphans
docker compose up -d --build

# 6. Optional: Install & configure nginx (system-level, not in Docker)
if [ "$HTTPS" = true ]; then
  echo "🛡️ Configuring HTTPS (requires certbot + domain)"
  # curl -fsSL https://get.acme.sh | sh
  # acme.sh --issue -d $DOMAIN --nginx
  # ... setup certbot ...
fi

echo "✅ AI Stack deployed!"
echo "🌐 Access at:"
echo "  - Directus: http://$VPS_HOST/"
echo "  - Wiki.js: http://$VPS_HOST/wiki/"
echo "  - API: http://$VPS_HOST/api/"
echo "  - Next.js: http://$VPS_HOST/next/"
