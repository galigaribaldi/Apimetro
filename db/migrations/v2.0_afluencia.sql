-- =====================================================
-- Apimetro — Migración v2.0: Tablas de Afluencia
-- Issue: #39
-- Fecha: 2026-06
-- =====================================================
--
-- PROPÓSITO:
--   Agrega las tablas plutarco.afluencia_linea y
--   plutarco.catalogo_homologacion a entornos existentes
--   que ya tienen el esquema plutarco creado (data-v1.0+).
--
-- PARA FRESH INSTALLS:
--   No es necesario ejecutar este archivo — las tablas
--   se crean automáticamente via init_plutarco.sql en
--   docker-entrypoint-initdb.d.
--
-- IDEMPOTENCIA:
--   Todas las sentencias usan IF NOT EXISTS.
--   Seguro de re-ejecutar sin efectos secundarios.
--
-- USO (desde máquina local, conectando al contenedor DEV):
--
--   PGPASSWORD='<ADMIN_PASS>' psql \
--     -h localhost -p 5433 \
--     -U admin_apimetro -d db_apimetro \
--     -v ON_ERROR_STOP=1 \
--     -f db/migrations/v2.0_afluencia.sql
--
-- Para QA (puerto 5434) o MAIN (puerto 5435), cambiar
-- el puerto y la contraseña correspondiente.
-- =====================================================

BEGIN;

-- =====================================================
-- TABLA: plutarco.afluencia_linea
-- Afluencia mensual por línea de transporte público
-- =====================================================
CREATE TABLE IF NOT EXISTS plutarco.afluencia_linea (
    id            SERIAL PRIMARY KEY,
    linea_id      INTEGER REFERENCES public.lineas(id),
    sistema       VARCHAR(20) NOT NULL,
    num_comercial VARCHAR(20),
    anio          SMALLINT NOT NULL,
    mes_num       SMALLINT NOT NULL,
    mes           VARCHAR(20),
    afluencia     BIGINT NOT NULL,
    fuente        TEXT,
    created_at    TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(linea_id, anio, mes_num)
);

CREATE INDEX IF NOT EXISTS idx_afluencia_linea_id ON plutarco.afluencia_linea (linea_id);
CREATE INDEX IF NOT EXISTS idx_afluencia_anio     ON plutarco.afluencia_linea (anio, mes_num);


-- =====================================================
-- TABLA: plutarco.catalogo_homologacion
-- Mapeo de nombres de línea en CSVs fuente → linea_id
-- =====================================================
CREATE TABLE IF NOT EXISTS plutarco.catalogo_homologacion (
    id          SERIAL PRIMARY KEY,
    nombre_csv  TEXT,
    sistema     VARCHAR(20) NOT NULL,
    linea_id    INTEGER REFERENCES public.lineas(id),
    activo      BOOLEAN DEFAULT TRUE,
    UNIQUE(nombre_csv, sistema)
);

CREATE INDEX IF NOT EXISTS idx_homologacion_sistema ON plutarco.catalogo_homologacion (sistema);


-- =====================================================
-- PERMISOS — Asegurar que apimetro_read puede leer
-- =====================================================
GRANT SELECT ON plutarco.afluencia_linea       TO apimetro_read;
GRANT SELECT ON plutarco.catalogo_homologacion TO apimetro_read;

COMMIT;

-- =====================================================
-- Verificación post-migración:
--
--   SELECT table_name FROM information_schema.tables
--   WHERE table_schema = 'plutarco'
--   ORDER BY table_name;
--
-- Resultado esperado (6 tablas):
--   afluencia_linea
--   agebs
--   calles
--   catalogo_homologacion
--   curvas_nivel
--   uso_suelo
-- =====================================================
