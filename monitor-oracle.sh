#!/bin/bash

# Script para monitoramento do Oracle
# Verifica status, performance e espaço

check_oracle_status() {
    echo "📊 Status do Oracle:"
    echo "==================="
    
    # Status do container
    echo "🐳 Container Status:"
    docker-compose ps oracle-db
    echo ""
    
    # Verificar se Oracle está respondendo
    echo "🔌 Conectividade:"
    if docker exec oracle21c-lab-acidentes sqlplus -s sys/OraclePassword123@localhost:1521/XE as sysdba <<< "SELECT 'Oracle OK' as status FROM dual;" 2>/dev/null | grep -q "Oracle OK"; then
        echo "✅ Oracle está respondendo"
    else
        echo "❌ Oracle não está respondendo"
    fi
    echo ""
    
    # Uso de recursos
    echo "💾 Uso de Recursos:"
    docker stats oracle21c-lab-acidentes --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}\t{{.NetIO}}\t{{.BlockIO}}"
    echo ""
    
    # Espaço em disco
    echo "💿 Uso de Disco:"
    du -sh data/oracle 2>/dev/null || echo "Dados não disponíveis"
    echo ""
    
    # Sessões ativas
    echo "👥 Sessões Ativas:"
    docker exec oracle21c-lab-acidentes sqlplus -s sys/OraclePassword123@localhost:1521/XE as sysdba <<< "
    SELECT 
        username,
        status,
        COUNT(*) as session_count
    FROM v\$session 
    WHERE username IS NOT NULL
    GROUP BY username, status
    ORDER BY username;
    " 2>/dev/null || echo "Não foi possível obter informações de sessão"
}

check_oracle_logs() {
    echo "📜 Últimos logs (últimas 50 linhas):"
    echo "===================================="
    docker-compose logs --tail=50 oracle-db
}

case "$1" in
    "status")
        check_oracle_status
        ;;
    "logs")
        check_oracle_logs
        ;;
    *)
        echo "Uso: $0 {status|logs}"
        echo ""
        echo "Comandos disponíveis:"
        echo "  status  - Mostra status e métricas do Oracle"
        echo "  logs    - Mostra logs recentes"
        exit 1
        ;;
esac
