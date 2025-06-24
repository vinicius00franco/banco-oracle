#!/bin/bash

# Script de inicialização do Oracle 21c com Docker
# Autor: Lab Banco de Dados
# Data: $(date)

set -e

echo "🚀 Iniciando configuração do Oracle 21c com Docker..."

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para log
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

# Verificar se Docker está instalado
if ! command -v docker &> /dev/null; then
    error "Docker não está instalado. Por favor, instale o Docker primeiro."
    exit 1
fi

# Verificar se Docker Compose está instalado
if ! command -v docker-compose &> /dev/null; then
    error "Docker Compose não está instalado. Por favor, instale o Docker Compose primeiro."
    exit 1
fi

# Criar diretórios necessários
log "Criando diretórios de persistência..."
mkdir -p data/oracle
mkdir -p data/backup
mkdir -p logs
mkdir -p scripts-sql

# Verificar se há scripts SQL para copiar
if [ -d "28-03-25" ]; then
    log "Copiando scripts SQL encontrados..."
    cp -r 28-03-25/*.sql scripts-sql/ 2>/dev/null || warn "Nenhum arquivo SQL encontrado em 28-03-25/"
fi

if [ -f "script-criacao-tabelas-acidentes-lab.sql" ]; then
    cp script-criacao-tabelas-acidentes-lab.sql scripts-sql/
    log "Script principal de criação de tabelas copiado."
fi

# Configurar permissões
log "Configurando permissões..."
sudo chown -R 54321:54321 data/oracle
sudo chown -R 54321:54321 data/backup
chmod -R 755 data/
chmod -R 755 scripts-sql/

# Fazer login no Oracle Container Registry (necessário para Oracle XE)
log "Verificando acesso ao Oracle Container Registry..."
echo ""
echo "⚠️  IMPORTANTE: Você precisa fazer login no Oracle Container Registry para baixar a imagem do Oracle XE."
echo "   1. Acesse: https://container-registry.oracle.com"
echo "   2. Crie uma conta Oracle (se não tiver)"
echo "   3. Aceite os termos da licença para Database > express"
echo "   4. Execute: docker login container-registry.oracle.com"
echo ""

read -p "Pressione Enter quando estiver logado no Oracle Container Registry..."

# Verificar se o usuário está logado
if ! docker info | grep -q "Username"; then
    warn "Fazendo login no Oracle Container Registry..."
    docker login container-registry.oracle.com
fi

# Build e start dos containers
log "Construindo e iniciando containers Oracle..."
docker-compose down --remove-orphans 2>/dev/null || true
docker-compose build --no-cache
docker-compose up -d

# Aguardar o Oracle ficar disponível
log "Aguardando Oracle ficar disponível (isso pode levar alguns minutos)..."
echo "Isso pode demorar de 2-5 minutos na primeira execução..."

# Função para verificar se Oracle está pronto
check_oracle() {
    docker exec oracle21c-lab-acidentes sqlplus -s sys/OraclePassword123@localhost:1521/XE as sysdba <<< "SELECT 1 FROM dual;" &>/dev/null
}

# Loop de verificação
counter=0
max_attempts=60
while ! check_oracle; do
    sleep 10
    counter=$((counter + 1))
    if [ $counter -gt $max_attempts ]; then
        error "Timeout: Oracle não ficou disponível após 10 minutos"
        docker-compose logs oracle-db
        exit 1
    fi
    echo -n "."
done

echo ""
log "✅ Oracle 21c está disponível!"

# Executar scripts de inicialização personalizados
if [ "$(ls -A scripts-sql/)" ]; then
    log "Executando scripts SQL personalizados..."
    for sql_file in scripts-sql/*.sql; do
        if [ -f "$sql_file" ]; then
            log "Executando: $(basename "$sql_file")"
            docker exec oracle21c-lab-acidentes sqlplus lab_acidentes/LabPassword123@localhost:1521/XEPDB1 @/opt/oracle/scripts/custom/$(basename "$sql_file") || warn "Erro ao executar $sql_file"
        fi
    done
fi

# Informações de conexão
echo ""
echo "🎉 Configuração concluída com sucesso!"
echo ""
echo -e "${BLUE}📋 INFORMAÇÕES DE CONEXÃO:${NC}"
echo "────────────────────────────────────────"
echo "🏠 Host: localhost"
echo "🔌 Porta: 1521"
echo "🔑 SID: XE"
echo "📦 PDB: XEPDB1"
echo ""
echo -e "${BLUE}👤 USUÁRIOS:${NC}"
echo "────────────────────────────────────────"
echo "🔐 SYS (DBA): sys / OraclePassword123"
echo "👨‍💻 App User: lab_acidentes / LabPassword123"
echo ""
echo -e "${BLUE}🌐 INTERFACES WEB:${NC}"
echo "────────────────────────────────────────"
echo "📊 Oracle EM: http://localhost:5500/em"
echo "🛠️  Adminer: http://localhost:8080"
echo ""
echo -e "${BLUE}🔧 COMANDOS ÚTEIS:${NC}"
echo "────────────────────────────────────────"
echo "📊 Status: docker-compose ps"
echo "📜 Logs: docker-compose logs -f oracle-db"
echo "🔄 Restart: docker-compose restart oracle-db"
echo "⏹️  Stop: docker-compose down"
echo "🗑️  Clean: docker-compose down -v"
echo ""
echo -e "${BLUE}💾 STRING DE CONEXÃO:${NC}"
echo "────────────────────────────────────────"
echo "jdbc:oracle:thin:@localhost:1521:XE"
echo "jdbc:oracle:thin:@localhost:1521/XEPDB1"
echo ""

log "Setup completo! Seu banco Oracle 21c está pronto para uso."
