#!/bin/bash
set -e

# =======================================
# Variáveis
# =======================================
USER_HOME="/home/ubuntu"
ENV_NAME="jupyter_env"
PASSWORD="pops2025"
JUPYTER_PORT=8888

# =======================================
# Atualizar pacotes e instalar dependências
# =======================================
echo "[INFO] Atualizando pacotes e instalando dependências..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y python3-pip python3-venv

# =======================================
# Criar ambiente virtual
# =======================================
echo "[INFO] Criando ambiente virtual em ${USER_HOME}/${ENV_NAME}..."
cd $USER_HOME
python3 -m venv $ENV_NAME

# Garantir que o ubuntu seja dono do venv
sudo chown -R ubuntu:ubuntu $USER_HOME/$ENV_NAME

# =======================================
# Instalar JupyterLab e PuLP no venv
# =======================================
echo "[INFO] Instalando JupyterLab e PuLP no venv..."
sudo -u ubuntu bash -c "
source ${USER_HOME}/${ENV_NAME}/bin/activate
pip install --upgrade pip
pip install jupyterlab pulp ipykernel
"

# =======================================
# Registrar kernel do venv no JupyterLab
# =======================================
echo "[INFO] Registrando kernel do venv no JupyterLab..."
sudo -u ubuntu bash -c "
source ${USER_HOME}/${ENV_NAME}/bin/activate
python -m ipykernel install --user --name=${ENV_NAME} --display-name 'Python (${ENV_NAME})'
"

# =======================================
# Gerar arquivo de configuração do JupyterLab
# =======================================
echo "[INFO] Gerando configuração do JupyterLab..."
sudo -u ubuntu bash -c "
${USER_HOME}/${ENV_NAME}/bin/jupyter lab --generate-config
"

# Garante que o diretório existe
mkdir -p ${USER_HOME}/.jupyter

# =======================================
# Criar hash de senha
# =======================================
echo "[INFO] Gerando hash da senha..."
HASHED_PASS=$(python3 -c "from jupyter_server.auth import passwd; print(passwd('${PASSWORD}'))")

# =======================================
# Configurar jupyter_lab_config.py
# =======================================
JUPYTER_CONFIG="${USER_HOME}/.jupyter/jupyter_lab_config.py"
echo "[INFO] Configurando JupyterLab em ${JUPYTER_CONFIG}..."
cat > $JUPYTER_CONFIG <<EOL
c.ServerApp.ip = '0.0.0.0'
c.ServerApp.port = ${JUPYTER_PORT}
c.ServerApp.open_browser = False
c.ServerApp.identity_provider_class = 'jupyter_server.auth.identity.PasswordIdentityProvider'
c.PasswordIdentityProvider.hashed_password = '${HASHED_PASS}'
EOL

# =======================================
# Criar serviço systemd
# =======================================
echo "[INFO] Criando serviço systemd para JupyterLab..."
SERVICE_FILE="/etc/systemd/system/jupyterlab.service"

sudo bash -c "cat > $SERVICE_FILE" <<EOL
[Unit]
Description=JupyterLab

[Service]
Type=simple
ExecStart=${USER_HOME}/${ENV_NAME}/bin/jupyter-lab --config=${USER_HOME}/.jupyter/jupyter_lab_config.py
User=ubuntu
Group=ubuntu
WorkingDirectory=${USER_HOME}
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOL

# =======================================
# Ativar serviço
# =======================================
echo "[INFO] Ativando serviço JupyterLab..."
sudo systemctl daemon-reload
sudo systemctl enable jupyterlab
sudo systemctl restart jupyterlab

# =======================================
# Status
# =======================================
echo "[INFO] Status do serviço:"
sudo systemctl status jupyterlab --no-pager