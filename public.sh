#!/bin/bash

BACKEND_IP=$1
MYSQL_DATABASE="company_pops"
MYSQL_USER="pops"
MYSQL_PASSWORD="p0ps#?025!"

if [ -z "$BACKEND_IP" ]; then
    echo "ERRO: Nenhum IP de backend fornecido!"
    exit 1
fi

echo "Usando o IP do backend: $BACKEND_IP"

echo "Atualizando pacotes e instalando dependências..."
sudo apt update
sudo apt install -y nginx git openjdk-17-jdk maven

# ======================== Diretórios temporários ========================
TMP_DIR="/tmp/pops-deploy"
BACKEND_TMP="$TMP_DIR/backend"
FRONTEND_TMP="$TMP_DIR/frontend"

echo "Removendo diretórios temporários antigos..."
sudo rm -rf "$TMP_DIR"
mkdir -p "$BACKEND_TMP" "$FRONTEND_TMP"

# ======================== Clonando Backend ========================
BACKEND_REPO="https://github.com/people-operations/pops-api.git"
BACKEND_BRANCH="main"
echo "Clonando backend..."
git clone -b "$BACKEND_BRANCH" "$BACKEND_REPO" "$BACKEND_TMP"

# ======================== Clonando Frontend ========================
FRONTEND_REPO="https://github.com/people-operations/pops-web.git"
FRONTEND_BRANCH="dev"
echo "Clonando frontend..."
git clone -b "$FRONTEND_BRANCH" "$FRONTEND_REPO" "$FRONTEND_TMP"

# ======================== Configurando Backend ========================
BACKEND_DIR="/opt/pops-api"
sudo mkdir -p "$BACKEND_DIR"

BACKEND_PATH="$BACKEND_TMP/pops-srv-manager-api"
cd "$BACKEND_PATH" || { echo "ERRO: Diretório do backend não existe!"; exit 1; }

if [ ! -f "pom.xml" ]; then
    echo "ERRO: pom.xml não encontrado em $BACKEND_PATH"
    exit 1
fi

echo "Compilando backend com Maven..."
mvn clean install -DskipTests

# Pega o jar gerado
JAR_FILE=$(find target -name "*.jar" | grep -v "original" | head -n 1)
if [ -z "$JAR_FILE" ]; then
    echo "ERRO: Não foi possível encontrar o .jar após a compilação!"
    exit 1
fi

echo "Movendo $JAR_FILE para $BACKEND_DIR/api.jar..."
sudo cp "$JAR_FILE" "$BACKEND_DIR/api.jar"

echo "Iniciando backend..."
sudo nohup env \
    IPV4_PRIVATE="$BACKEND_IP" \
    MYSQL_DATABASE="$MYSQL_DATABASE" \
    MYSQL_USER="$MYSQL_USER" \
    MYSQL_PASSWORD="$MYSQL_PASSWORD" \
    java -jar "$BACKEND_DIR/api.jar" > /var/log/api.log 2>&1 &
echo "Backend iniciado com sucesso."

# ======================== Configurando Frontend ========================
echo "Configurando frontend..."
sudo rm -rf /var/www/html/*
sudo cp -r "$FRONTEND_TMP" /var/www/html/pops-web

# ======================== Configurando Nginx ========================
NGINX_CONF="/etc/nginx/sites-available/myserver"
sudo bash -c "cat > $NGINX_CONF" <<EOT
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    server_name _;

    root /var/www/html/pops-web/public;
    index index.html;

    location /assets/ {
        alias /var/www/html/pops-web/public/assets/;
    }

    location /app/ {
            alias /var/www/html/pops-web/public/app/;
        }

    location /api/ {
        proxy_pass http://localhost:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOT

sudo ln -sf "$NGINX_CONF" /etc/nginx/sites-enabled/myserver
sudo rm -f /etc/nginx/sites-enabled/default
sudo systemctl reload nginx
sudo systemctl restart nginx
echo "Nginx configurado com sucesso."

# ======================== Limpeza ========================
echo "Removendo diretórios temporários..."
sudo rm -rf "$TMP_DIR"

echo "Instalação e deploy concluídos!"