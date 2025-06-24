# Multi-stage Dockerfile para Oracle 21c
# Stage 1: Build stage (preparação)
FROM container-registry.oracle.com/database/express:21.3.0-xe

# Variáveis de ambiente
ENV ORACLE_PWD=OraclePassword123
ENV ORACLE_CHARACTERSET=AL32UTF8
ENV ORACLE_EDITION=standard
ENV ORACLE_PDB=XEPDB1
ENV ORACLE_SID=XE

# Criar diretório para scripts de inicialização
RUN mkdir -p /opt/oracle/scripts/setup
RUN mkdir -p /opt/oracle/scripts/startup

# Script de configuração inicial para performance
COPY --chown=oracle:dba <<EOF /opt/oracle/scripts/setup/02-performance-config.sql
-- Configurações de performance
ALTER SESSION SET CONTAINER = XEPDB1;

ALTER SYSTEM SET shared_pool_size=256M SCOPE=SPFILE;
ALTER SYSTEM SET db_cache_size=512M SCOPE=SPFILE;
ALTER SYSTEM SET pga_aggregate_target=256M SCOPE=SPFILE;

-- Configurações de sessão
ALTER SYSTEM SET sessions=300 SCOPE=SPFILE;
ALTER SYSTEM SET processes=200 SCOPE=SPFILE;

EXIT;
EOF

# Expor porta padrão do Oracle
EXPOSE 1521
EXPOSE 5500

# Volume para persistência de dados
VOLUME ["/opt/oracle/oradata"]

# Healthcheck
HEALTHCHECK --interval=30s --timeout=10s --retries=5 \
  CMD sqlplus -s sys/OraclePassword123@localhost:1521/XE as sysdba <<< "SELECT 1 FROM dual;" || exit 1
