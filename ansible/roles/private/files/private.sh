#!/bin/bash

set -e  # Faz o script parar na primeira falha

check_mysql() {
    if ! which mysql > /dev/null 2>&1; then
        echo "MySQL não está instalado. Instalando MySQL Server 8.0..."
        install_mysql
    else
        echo "MySQL já está instalado."
        configure_mysql
    fi
}

install_mysql() {
    echo "Instalando MySQL Server 8.0..."
    sudo apt update
    sudo apt install -y mysql-server
    sudo systemctl start mysql
    sudo systemctl enable mysql
    echo "MySQL Server instalado e iniciado."
    configure_mysql
}

configure_mysql() {
    echo "Configurando MySQL para aceitar conexões externas..."

    MYSQL_CONFIG="/etc/mysql/mysql.conf.d/mysqld.cnf"
    if [ ! -f "$MYSQL_CONFIG" ]; then
        MYSQL_CONFIG="/etc/mysql/my.cnf"
    fi

    sudo sed -i "s/^bind-address\s*=.*/bind-address = 0.0.0.0/" "$MYSQL_CONFIG"

    echo "Reiniciando o MySQL para aplicar as mudanças..."
    sudo systemctl restart mysql

    echo "Aguardando MySQL iniciar..."
    sleep 5

    create_db_user
}

create_db_user() {
    DB_USER="pops"
    DB_PASS="p0ps#?025!"

    echo "Criando o usuário '$DB_USER' no MySQL..."
    sudo mysql -e "CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED WITH mysql_native_password BY '$DB_PASS';"
    sudo mysql -e "GRANT ALL PRIVILEGES ON *.* TO '$DB_USER'@'%' WITH GRANT OPTION;"
    sudo mysql -e "FLUSH PRIVILEGES;"

    echo "Usuário '$DB_USER' criado com sucesso."
    setup_database
}

setup_database() {
  DB_SCRIPT="/tmp/script.sql"

  echo "Executando script SQL de configuração do banco de dados..."

  if [ -f "$DB_SCRIPT" ]; then
    echo "Executando $DB_SCRIPT..."
    sudo mysql < "$DB_SCRIPT"
    echo "Banco de dados configurado com sucesso."
  else
    echo "Arquivo $DB_SCRIPT não encontrado. Pulando configuração."
  fi
}

# Executar verificações e configurações
check_mysql