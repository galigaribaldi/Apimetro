#!/bin/bash
# Aplica la migración del anillo periférico si ANILLAR_MIGRATION está definida.
# Solo corre durante docker-entrypoint-initdb.d (primer arranque con volumen vacío).
#
# Las secuencias ya deben estar sincronizadas por 04b_sync_sequences.sql (que
# corre antes que este script en el orden alfabético del initdb). El bloque
# setval aquí es un segundo nivel de defensa para re-ejecuciones manuales sobre
# contenedores ya corriendo (docker exec ... -f /migrations/...).
if [ -n "$ANILLAR_MIGRATION" ]; then
    echo "Sincronizando secuencias (fallback para re-ejecución manual)..."
    psql --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -c "
        SELECT setval('ramals_id_seq',   COALESCE((SELECT MAX(id) FROM ramals),   0) + 1, false);
        SELECT setval('estacions_id_seq', COALESCE((SELECT MAX(id) FROM estacions), 0) + 1, false);
        SELECT setval('lineas_id_seq',    COALESCE((SELECT MAX(id) FROM lineas),    0) + 1, false);
    "
    echo "Aplicando migración del anillo: $ANILLAR_MIGRATION"
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -f "$ANILLAR_MIGRATION"
fi
