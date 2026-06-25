#!/bin/bash
# =====================================================
# roles.sh — Creación del rol de solo lectura para la API
# Se ejecuta DESPUÉS de 01_init.sql y 02_init_plutarco.sql (orden numérico)
# Variables requeridas en el contenedor:
#   POSTGRES_USER, POSTGRES_DB, API_DB_PASSWORD
# =====================================================
set -e

echo ">>> Configurando rol apimetro_read..."

psql -v ON_ERROR_STOP=1 \
     --username "$POSTGRES_USER" \
     --dbname   "$POSTGRES_DB" <<-EOSQL

    -- Crear rol con acceso de solo lectura.
    -- Si ya existe (reinicio del contenedor), actualiza la contraseña.
    DO \$\$
    BEGIN
        CREATE ROLE apimetro_read WITH LOGIN PASSWORD '${API_DB_PASSWORD}';
        RAISE NOTICE 'Rol apimetro_read creado.';
    EXCEPTION WHEN duplicate_object THEN
        ALTER ROLE apimetro_read WITH PASSWORD '${API_DB_PASSWORD}';
        RAISE NOTICE 'Rol apimetro_read ya existía — contraseña actualizada.';
    END;
    \$\$;

    -- Permisos sobre esquema public
    GRANT CONNECT ON DATABASE ${POSTGRES_DB} TO apimetro_read;
    GRANT USAGE ON SCHEMA public TO apimetro_read;
    GRANT SELECT ON ALL TABLES IN SCHEMA public TO apimetro_read;
    ALTER DEFAULT PRIVILEGES IN SCHEMA public
        GRANT SELECT ON TABLES TO apimetro_read;

    -- Permisos sobre esquema plutarco (AGEBs y Calles — datos futuros)
    GRANT USAGE ON SCHEMA plutarco TO apimetro_read;
    GRANT SELECT ON ALL TABLES IN SCHEMA plutarco TO apimetro_read;
    ALTER DEFAULT PRIVILEGES IN SCHEMA plutarco
        GRANT SELECT ON TABLES TO apimetro_read;

EOSQL

echo ">>> Rol apimetro_read configurado correctamente."
