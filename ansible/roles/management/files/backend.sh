#!/bin/bash
set -e

# ========================
# Variáveis
# ========================
DEPLOY_DIR="/opt/pops-backend"
CONFIG_REPO="https://github.com/people-operations/config.git"
CONFIG_FILE="values.yml"
REPOS=(
  "https://github.com/people-operations/pops-srv-funcionarios.git"
  "https://github.com/people-operations/pops-srv-projetos.git"
  "https://github.com/people-operations/pops-squad-api.git"
)
NAMES=("pops-srv-employee" "pops-srv-projetos" "pops-squad-api")
PORTS=(8081 8082 8083)

# Caminho padrão da chave Firebase
FIREBASE_KEY_PATH="/opt/pops/keys/pops-srv-employee-firebase-adminsdk-fbsvc-e86c8fbf1b.json"

# ========================
# Instalar dependências
# ========================
echo "Instalando dependências básicas (Java + Git + Maven)..."
sudo apt update -y
sudo apt install -y openjdk-17-jdk git maven unzip

# ========================
# Preparar diretórios
# ========================
sudo rm -rf "$DEPLOY_DIR"
mkdir -p "$DEPLOY_DIR"
cd "$DEPLOY_DIR" || exit 1

# ========================
# Clonar repositórios
# ========================
echo "Clonando repositórios de serviços..."
for i in "${!REPOS[@]}"; do
  repo="${REPOS[$i]}"
  name="${NAMES[$i]}"
  echo "→ Clonando $repo..."
  git clone "$repo" "$DEPLOY_DIR/$name"
done

# ========================
# Clonar repositório de configuração
# ========================
echo "Clonando repositório de configuração..."
git clone "$CONFIG_REPO" "$DEPLOY_DIR/config"

# ========================
# Copiar values.yml para /config de cada serviço
# ========================
for name in "${NAMES[@]}"; do
  if [ -f "$DEPLOY_DIR/config/$CONFIG_FILE" ]; then
    echo "Inserindo $CONFIG_FILE em $name/config/"
    mkdir -p "$DEPLOY_DIR/$name/config"
    cp "$DEPLOY_DIR/config/$CONFIG_FILE" "$DEPLOY_DIR/$name/config/$CONFIG_FILE"
  else
    echo "Arquivo $CONFIG_FILE não encontrado em $DEPLOY_DIR/config/"
  fi
done

# ========================
# Build Maven (com -DskipTests)
# ========================
echo "Iniciando build Maven..."
for name in "${NAMES[@]}"; do
  echo "→ Buildando $name..."
  cd "$DEPLOY_DIR/$name"
  PROJECT_DIR=$(find . -type f -name "pom.xml" -printf '%h\n' | head -n 1)
  if [ -n "$PROJECT_DIR" ]; then
    cd "$PROJECT_DIR"
    mvn clean package -DskipTests
  else
    echo "⚠️ Nenhum pom.xml encontrado em $name, pulando..."
  fi
done

# ========================
# Exportar variável de ambiente Firebase
# ========================
echo ""
echo "🔐 Verificando chave Firebase..."
if [ -f "$FIREBASE_KEY_PATH" ]; then
  echo "✅ Chave encontrada: $FIREBASE_KEY_PATH"
  export FIREBASE_KEY_PATH="$FIREBASE_KEY_PATH"
else
  echo "❌ ERRO: Chave Firebase não encontrada em $FIREBASE_KEY_PATH"
  echo "Verifique o caminho antes de continuar."
  exit 1
fi

# ========================
# Rodar serviços em background
# ========================
echo ""
echo "Iniciando serviços em background..."
for i in "${!NAMES[@]}"; do
  name="${NAMES[$i]}"
  port="${PORTS[$i]}"
  PROJECT_DIR=$(find "$DEPLOY_DIR/$name" -type f -name "pom.xml" -printf '%h\n' | head -n 1)

  if [ -n "$PROJECT_DIR" ]; then
    JAR_FILE=$(find "$PROJECT_DIR/target" -type f -name "*.jar" | head -n 1)
    if [ -f "$JAR_FILE" ]; then
      echo "→ Executando $name na porta $port..."
      nohup java -jar "$JAR_FILE" --server.port=$port > "$DEPLOY_DIR/$name.log" 2>&1 &
    else
      echo "⚠️ Nenhum arquivo JAR encontrado para $name"
    fi
  fi
done

# ========================
# Exibir status final
# ========================
echo ""
echo "Verificando serviços ativos..."
ps aux | grep java | grep pops || true

echo ""
echo "✅ Backend PeopleOps implantado com sucesso!"
echo " - Employee API: http://localhost:8081/api-employee"
echo " - Project API:  http://localhost:8082/api-project"
echo " - Squad API:    http://localhost:8083/api-squad"
echo ""
echo "Logs disponíveis em:"
echo " - $DEPLOY_DIR/pops-srv-employee.log"
echo " - $DEPLOY_DIR/pops-srv-projetos.log"
echo " - $DEPLOY_DIR/pops-squad-api.log"