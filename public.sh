#!/bin/bash

#####################################################################################
# Script inalterado dado que ainda não foi criado uma aplicação web para o projeto  #
#####################################################################################

BACKEND_IP=$1  # O IP do backend será passado como argumento

if [ -z "$BACKEND_IP" ]; then
    echo "ERRO: Nenhum IP de backend fornecido!"
    exit 1
fi

echo "Usando o IP do backend: $BACKEND_IP"

echo "Atualizando pacotes..."
sudo apt update && sudo apt install -y nginx git openjdk-17-jdk

REPO_URL="https://github.com/Miguel-Araujo325/edu-invtt-tf"
TMP_DIR="/tmp/edu-invtt-tf"

echo "Removendo qualquer versão antiga do repositório..."
sudo rm -rf "$TMP_DIR"

echo "Clonando o repositório no diretório temporário..."
sudo git clone "$REPO_URL" "$TMP_DIR"

# ======================== Configurando Backend ========================
BACKEND_DIR="/opt/edu-invtt"
sudo mkdir -p "$BACKEND_DIR"

echo "Movendo arquivos .jar para $BACKEND_DIR..."
sudo cp "$TMP_DIR/back-end/api.jar" "$BACKEND_DIR/api.jar"
sudo cp "$TMP_DIR/back-end/dashboard.jar" "$BACKEND_DIR/dashboard.jar"

echo "Iniciando backend..."
sudo nohup env IPV4_PRIVATE="$BACKEND_IP" S3_BUCKET="03231034-dev-edu-invtt" java -jar "$BACKEND_DIR/api.jar" > /var/log/api.log 2>&1 &
sudo nohup env IPV4_PRIVATE="$BACKEND_IP" java -jar "$BACKEND_DIR/dashboard.jar" > /var/log/dashboard.log 2>&1 &
echo "Backend iniciado com sucesso."

# ======================== Configurando Frontend ========================
echo "Configurando o frontend..."
sudo rm -rf /var/www/html/*
sudo cp -r "$TMP_DIR/front-end" /var/www/html/

# ======================== Configurando Nginx ========================
sudo bash -c 'cat <<EOT > /etc/nginx/sites-available/myserver
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    server_name _;

    root /var/www/html/front-end/solucao-e4e/html;
    index login2.html;

    location /css/ {
        alias /var/www/html/front-end/solucao-e4e/css/;
    }
    location /js/ {
        alias /var/www/html/front-end/solucao-e4e/js/;
    }
    location /imgs/ {
        alias /var/www/html/front-end/solucao-e4e/imgs/;
    }

    # Proxy para API principal
    location /api/ {
        proxy_pass http://localhost:8080/api/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }

    location /api-dashboard/ {
            proxy_pass http://localhost:7000/api-dashboard/;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        }
}
EOT'

# Ativando a configuração do Nginx
sudo ln -sf /etc/nginx/sites-available/myserver /etc/nginx/sites-enabled/myserver
sudo rm -f /etc/nginx/sites-enabled/default
sudo systemctl reload nginx
sudo systemctl restart nginx
echo "Nginx configurado com sucesso."

# ======================== Removendo Diretório Temporário ========================
echo "Removendo arquivos temporários..."
sudo rm -rf "$TMP_DIR"

echo "Instalação concluída!"