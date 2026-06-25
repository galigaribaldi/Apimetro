#!/bin/bash
# =====================================================
# load-seed.sh — Carga inicial de datos en producción
#
# Ejecutar DESDE TU MÁQUINA LOCAL, no desde el server.
# Requiere: psql, pg_dump instalados localmente y
#           acceso SSH configurado al servidor.
#
# El seed.sql NO está en el repositorio (gitignoreado).
# Este script lo genera desde tu DB local y lo sube
# al servidor vía SCP para que docker-entrypoint-initdb.d
# lo cargue automáticamente en el primer arranque.
#
# Uso:
#   bash scripts/load-seed.sh <IP_DEL_SERVIDOR>
#
# Ejemplo:
#   bash scripts/load-seed.sh 129.213.45.100
#
# Variables de entorno opcionales (con fallback para dev local):
#   DB_HOST, DB_NAME, DB_USER, DB_PASSWORD, DB_PORT
# =====================================================

set -euo pipefail

SERVER_IP="${1:?Error: falta la IP del servidor. Uso: $0 <IP_DEL_SERVIDOR>}"
DB_LOCAL_HOST="${DB_HOST:-localhost}"
DB_LOCAL_PORT="${DB_PORT:-5432}"
DB_LOCAL_USER="${DB_USER:-prueba}"
DB_LOCAL_PASS="${DB_PASSWORD:-postgres}"
DB_LOCAL_NAME="${DB_NAME:-db_apimetro}"
SEED_FILE="db/init/04_seed.sql"

echo "======================================================"
echo " Apimetro — Carga de seed.sql en producción"
echo " Servidor destino: $SERVER_IP"
echo "======================================================"
echo ""

# Paso 1: Generar seed.sql desde la DB local
echo "[1/3] Generando $SEED_FILE desde la DB local ($DB_LOCAL_NAME)..."
PGPASSWORD="$DB_LOCAL_PASS" pg_dump \
  --data-only --inserts --disable-triggers \
  -t lineas \
  -t ramals \
  -t estacions \
  -t descripcion_lineas \
  -t descripcion_estacions \
  -t historico_operacion \
  -t limites_territoriales \
  -h "$DB_LOCAL_HOST" \
  -p "$DB_LOCAL_PORT" \
  -U "$DB_LOCAL_USER" \
  "$DB_LOCAL_NAME" \
  > "$SEED_FILE"

SEED_SIZE=$(du -sh "$SEED_FILE" | cut -f1)
echo "    seed.sql generado: $SEED_SIZE"

# Paso 2: Subir al servidor
echo ""
echo "[2/3] Subiendo $SEED_FILE al servidor ($SERVER_IP)..."
scp "$SEED_FILE" "ubuntu@${SERVER_IP}:/home/ubuntu/Apimetro/db/init/seed.sql"
echo "    Archivo subido correctamente."

# Paso 3: Instrucciones finales
echo ""
echo "[3/3] seed.sql listo en el servidor."
echo ""
echo "======================================================"
echo " SIGUIENTE PASO según el estado del servidor:"
echo "======================================================"
echo ""
echo " A) Si el contenedor de DB AÚN NO ha sido levantado:"
echo "    El seed.sql ya está en db/init/ — docker compose"
echo "    lo cargará automáticamente en el primer arranque."
echo ""
echo "    docker compose -f docker-compose.prod.yml up -d db"
echo ""
echo " B) Si el contenedor ya está corriendo (sin datos):"
echo "    Inyectar manualmente — ejecutar en el servidor:"
echo ""
echo "    PGPASSWORD='<ADMIN_PASS>' psql \\"
echo "      -h localhost -p 5432 \\"
echo "      -U admin_apimetro \\"
echo "      -d db_apimetro \\"
echo "      -v ON_ERROR_STOP=1 \\"
echo "      -f /home/ubuntu/Apimetro/db/init/seed.sql"
echo ""
echo " Conteos esperados tras la carga (abril 2026):"
echo "   estacions             22,878"
echo "   ramals                   693"
echo "   historico_operacion      690"
echo "   limites_territoriales    553"
echo "   lineas                   317"
echo "======================================================"
