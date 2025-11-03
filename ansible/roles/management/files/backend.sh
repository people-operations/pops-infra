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
# Instalar dependências (somente se necessário)
# ========================
echo "Verificando dependências básicas (Java + Git + Maven)..."

install_if_missing() {
  local cmd=$1
  local pkg=$2
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Instalando $pkg..."
    sudo apt-get update -y
    sudo apt-get install -y "$pkg"
  else
    echo "$pkg já está instalado."
  fi
}

install_if_missing java openjdk-17-jdk
install_if_missing git git
install_if_missing mvn maven
install_if_missing unzip unzip
install_if_missing lsof lsof  # usado para detectar portas em uso

# ========================
# Preparar diretórios
# ========================
echo "Preparando diretórios de deploy..."
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
  git clone --depth 1 "$repo" "$DEPLOY_DIR/$name"
done

# ========================
# Clonar repositório de configuração
# ========================
echo "Clonando repositório de configuração..."
git clone --depth 1 "$CONFIG_REPO" "$DEPLOY_DIR/config"

GLOBAL_CONFIG_PATH="$DEPLOY_DIR/config/$CONFIG_FILE"
if [ ! -f "$GLOBAL_CONFIG_PATH" ]; then
  echo "ERRO: $CONFIG_FILE não encontrado em $GLOBAL_CONFIG_PATH"
  exit 1
else
  echo "Configuração global localizada em: $GLOBAL_CONFIG_PATH"
fi

# ========================
# Build Maven (com -DskipTests)
# ========================
echo "🛠️ Iniciando build Maven..."
for name in "${NAMES[@]}"; do
  echo "→ Buildando $name..."
  cd "$DEPLOY_DIR/$name"
  PROJECT_DIR=$(find . -type f -name "pom.xml" -printf '%h\n' | head -n 1)
  if [ -n "$PROJECT_DIR" ]; then
    cd "$PROJECT_DIR"
    mvn -q clean package -DskipTests
  else
    echo "Nenhum pom.xml encontrado em $name, pulando..."
  fi
done

# ========================
# Exportar variável de ambiente Firebase
# ========================
echo ""
echo "Verificando chave Firebase..."
if [ -f "$FIREBASE_KEY_PATH" ]; then
  echo "Chave encontrada: $FIREBASE_KEY_PATH"
  export FIREBASE_KEY_PATH="$FIREBASE_KEY_PATH"
else
  echo "ERRO: Chave Firebase não encontrada em $FIREBASE_KEY_PATH"
  echo "Verifique o caminho antes de continuar."
  exit 1
fi

# ========================
# Rodar serviços em background (com config global)
# ========================
echo ""
echo "🚀 Iniciando serviços em background..."
for i in "${!NAMES[@]}"; do
  name="${NAMES[$i]}"
  port="${PORTS[$i]}"
  SERVICE_DIR="$DEPLOY_DIR/$name"

  PROJECT_DIR=$(find "$SERVICE_DIR" -type f -name "pom.xml" -printf '%h\n' | head -n 1)
  if [ -z "$PROJECT_DIR" ]; then
    echo "Nenhum pom.xml encontrado em $name, pulando..."
    continue
  fi

  JAR_FILE=$(find "$PROJECT_DIR/target" -maxdepth 1 -type f -name "*.jar" | head -n 1)
  if [ ! -f "$JAR_FILE" ]; then
    echo "Nenhum arquivo JAR encontrado para $name, pulando..."
    continue
  fi

  # Garante que não haja processo antigo na porta
  PID=$(sudo lsof -t -i:$port || true)
  if [ -n "$PID" ]; then
    echo "Porta $port em uso (PID $PID), matando processo anterior..."
    sudo kill -9 "$PID" || true
  fi

  echo "→ Executando $name na porta $port..."
  nohup bash -lc "cd '$SERVICE_DIR' && \
    java -jar '$JAR_FILE' \
      --server.port=$port \
      --spring.config.import=optional:file:$GLOBAL_CONFIG_PATH" \
    > "$DEPLOY_DIR/$name.log" 2>&1 &

  sleep 10  # pequena pausa entre os serviços pra evitar pico de CPU
done

# ========================
# Exibir status final
# ========================
echo ""
echo "Verificando serviços ativos..."
ps aux | grep java | grep pops || true

echo ""
echo "Backend PeopleOps implantado com sucesso!"
echo " - Employee API: http://localhost:8081/api-employee"
echo " - Project API:  http://localhost:8082/api-project"
echo " - Squad API:    http://localhost:8083/api-squad"
echo ""
echo "Logs disponíveis em:"
echo " - $DEPLOY_DIR/pops-srv-employee.log"
echo " - $DEPLOY_DIR/pops-srv-projetos.log"
echo " - $DEPLOY_DIR/pops-squad-api.log"