#!/bin/bash

# Script para backup do Oracle
# Executa backup completo do banco de dados

set -e

BACKUP_DIR="./data/backup"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="oracle_backup_${TIMESTAMP}.dmp"

echo "🔄 Iniciando backup do Oracle..."

# Criar diretório de backup se não existir
mkdir -p $BACKUP_DIR

# Executar backup usando expdp
docker exec oracle21c-lab-acidentes bash -c "
expdp lab_acidentes/LabPassword123@XEPDB1 \
  directory=DATA_PUMP_DIR \
  dumpfile=${BACKUP_FILE} \
  logfile=backup_${TIMESTAMP}.log \
  schemas=lab_acidentes \
  compression=ALL
"

# Copiar backup para host
docker cp oracle21c-lab-acidentes:/opt/oracle/admin/XE/dpdump/${BACKUP_FILE} ${BACKUP_DIR}/

echo "✅ Backup concluído: ${BACKUP_DIR}/${BACKUP_FILE}"

# Limpar backups antigos (manter últimos 7 dias)
find $BACKUP_DIR -name "oracle_backup_*.dmp" -mtime +7 -delete 2>/dev/null || true

echo "🧹 Limpeza de backups antigos concluída"
