#!/bin/bash
set -e

# ========================
# Variáveis
# ========================
FRONTEND_BRANCH="dev"
FRONTEND_REPO="https://github.com/people-operations/pops-web.git"
DEPLOY_DIR="/opt/pops-frontend"

# ========================
# Exibir info
# ========================
echo "🚀 Iniciando deploy do frontend PeopleOps (modo local EC2)"
echo "Serviços esperados:"
echo " - Employee API → http://localhost:8081/api-employee"
echo " - Project API  → http://localhost:8082/api-project"
echo " - Squad API    → http://localhost:8083/api-squad"
echo ""

# ========================
# Instalar dependências (Docker + Compose)
# ========================
echo "📦 Instalando Docker e Docker Compose..."

sudo apt-get remove -y docker docker-engine docker.io containerd runc || true
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl gnupg lsb-release git

# Adiciona chave e repositório Docker
sudo mkdir -p /etc/apt/keyrings
if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
fi

echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 🔧 Ativar e iniciar o daemon Docker
echo "🔧 Ativando e iniciando o serviço Docker..."
sudo systemctl enable docker
sudo systemctl start docker

sleep 3
if ! sudo docker info >/dev/null 2>&1; then
  echo "Docker ainda não está ativo, tentando reiniciar..."
  sudo systemctl restart docker
  sleep 3
fi
echo "✅ Docker está ativo e rodando."

# ========================
# Preparar diretórios
# ========================
echo "🧹 Limpando diretório antigo e preparando estrutura..."
sudo rm -rf "$DEPLOY_DIR"
mkdir -p "$DEPLOY_DIR"
cd "$DEPLOY_DIR" || exit 1

# ========================
# Clonar repositório
# ========================
echo "📥 Clonando repositório frontend..."
git clone -b "$FRONTEND_BRANCH" "$FRONTEND_REPO" "$DEPLOY_DIR"

# ========================
# Criar configuração do Nginx
# ========================
cat > "$DEPLOY_DIR/nginx.conf" <<'EOF'
server {
    listen 80;
    server_name _;

    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    # ========================
    # BACKENDS - MESMA EC2
    # ========================

    # Employee Service
    location /api-employee/ {
        proxy_pass http://localhost:8081/api-employee/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Project Service
    location /api-project/ {
        proxy_pass http://localhost:8082/api-project/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Squad Service
    location /api-squad/ {
        proxy_pass http://localhost:8083/api-squad/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Arquivos estáticos
    location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
        expires 30d;
        access_log off;
    }
}
EOF

# ========================
# Criar Dockerfile
# ========================
cat > "$DEPLOY_DIR/Dockerfile" <<'EOF'
FROM nginx:alpine
WORKDIR /usr/share/nginx/html
COPY public/ .
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
EOF

# ========================
# Criar docker-compose.yml
# ========================
cat > "$DEPLOY_DIR/docker-compose.yml" <<'EOF'
version: '3.8'

services:
  frontend:
    build: .
    container_name: pops-frontend
    ports:
      - "80:80"
    restart: always
    network_mode: "host"  # usa rede local da EC2 para enxergar backends
EOF

# ========================
# Subir container
# ========================
echo "🧱 Construindo e subindo container do frontend..."
sudo docker compose down || true
sudo docker compose up -d --build

# ========================
# Exibir status final
# ========================
PUBLIC_IP=$(curl -s ifconfig.me)
echo ""
echo "✅ Deploy do frontend concluído com sucesso!"
echo "🌐 Acesse: http://$PUBLIC_IP"
echo "📦 Container: pops-frontend"
echo "📁 Diretório: $DEPLOY_DIR"
echo ""
sudo docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"