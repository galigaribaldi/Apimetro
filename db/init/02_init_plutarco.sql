-- =====================================================
-- Apimetro — DDL Extensión Plutarco
-- Esquema de datos geoespaciales y censales del INEGI
-- para el motor VFT (Valor de Flujo de Transporte).
-- Autor: galigaribaldi | Actualizado: 2026-06
-- =====================================================
-- IMPORTANTE: Ejecutar DESPUÉS de init.sql.
-- Este archivo solo contiene DDL (sin datos).
-- Los datos se cargan con los scripts ETL:
--   ETL/DataCharge/LoadAgebs.py       → plutarco.agebs
--   ETL/DataCharge/LoadPlutarcoGeo.py → plutarco.calles,
--                                       plutarco.uso_suelo,
--                                       plutarco.curvas_nivel
-- =====================================================

-- =====================================================
-- ESQUEMA
-- =====================================================
CREATE SCHEMA IF NOT EXISTS plutarco;
COMMENT ON SCHEMA plutarco IS 'Datos geoespaciales y censales INEGI para análisis VFT';


-- =====================================================
-- TABLA: plutarco.agebs
-- AGEBs urbanas + Censo 2020
-- Scope: 6 estados macrometrópoli (09,15,17,21,22,29)
-- Fuente: INEGI Marco Geoestadístico (*a.shp) + CPV 2020
-- ETL: DataCharge/LoadAgebs.py
-- =====================================================
CREATE TABLE IF NOT EXISTS plutarco.agebs (
    id                  SERIAL PRIMARY KEY,
    cve_ageb            VARCHAR(20) UNIQUE NOT NULL,
    poblacion_total     INTEGER DEFAULT 0,
    viviendas_habitadas INTEGER DEFAULT 0,
    geom                GEOMETRY(MultiPolygon, 4326),
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    entidad             VARCHAR(2),
    municipio_alcaldia  TEXT,
    area_km2            NUMERIC(10,4),
    densidad_pob_km2    NUMERIC(12,4),
    pea                 INTEGER,
    fuente              TEXT DEFAULT 'INEGI Censo 2020'
);

CREATE INDEX IF NOT EXISTS idx_agebs_geom     ON plutarco.agebs USING GIST (geom);
CREATE INDEX IF NOT EXISTS idx_agebs_entidad  ON plutarco.agebs (entidad);
CREATE INDEX IF NOT EXISTS idx_agebs_cve_ageb ON plutarco.agebs (cve_ageb);


-- =====================================================
-- TABLA: plutarco.calles
-- Red vial urbana segmentada (ejes de vialidad)
-- Scope: CDMX (09) — otros estados pendiente (deuda)
-- Fuente: INEGI Marco Geoestadístico (lineas_ejes_de_vialidad.shp)
-- ETL: DataCharge/LoadPlutarcoGeo.py → CallesETL
-- =====================================================
CREATE TABLE IF NOT EXISTS plutarco.calles (
    id         SERIAL PRIMARY KEY,
    cvegeo     TEXT,
    cve_ent    VARCHAR(2),
    cve_mun    VARCHAR(3),
    cve_loc    VARCHAR(4),
    cvevial    VARCHAR(10),
    cveseg     VARCHAR(10),
    nomvial    TEXT,
    tipovial   TEXT,
    sentido    TEXT,
    tiposen    SMALLINT,
    ambito     TEXT,
    geom       GEOMETRY(MultiLineString, 4326),
    fuente     TEXT DEFAULT 'INEGI Marco Geoestadístico',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_calles_geom     ON plutarco.calles USING GIST (geom);
CREATE INDEX IF NOT EXISTS idx_calles_tipovial ON plutarco.calles (tipovial);
CREATE INDEX IF NOT EXISTS idx_calles_cve_ent  ON plutarco.calles (cve_ent);


-- =====================================================
-- TABLA: plutarco.uso_suelo
-- Uso de suelo y vegetación
-- Scope: Parcial (cobertura según shapefile fuente)
-- Fuente: INEGI Uso de Suelo y Vegetación 1993
--         (MedioFisicoNatural.gpkg → inegi_ambi_usosue_1993)
-- DEUDA: Actualizar a Serie VI (2017) cuando esté disponible
-- ETL: DataCharge/LoadPlutarcoGeo.py → UsoSueloETL
-- =====================================================
CREATE TABLE IF NOT EXISTS plutarco.uso_suelo (
    id         SERIAL PRIMARY KEY,
    cve_carta  TEXT,
    entidad    TEXT,
    tipo       TEXT,
    fisonomia  TEXT,
    veg_sec    TEXT,
    erosion    TEXT,
    cult_pri   TEXT,
    tipod7     TEXT,
    representa TEXT,
    geom       GEOMETRY(MultiPolygon, 4326),
    fuente     TEXT DEFAULT 'INEGI Uso de Suelo y Vegetación 1993',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_uso_suelo_geom       ON plutarco.uso_suelo USING GIST (geom);
CREATE INDEX IF NOT EXISTS idx_uso_suelo_tipo        ON plutarco.uso_suelo (tipo);
CREATE INDEX IF NOT EXISTS idx_uso_suelo_representa  ON plutarco.uso_suelo (representa);


-- =====================================================
-- TABLA: plutarco.curvas_nivel
-- Curvas de nivel (isohipsas)
-- Scope: Parcial — cobertura limitada a datos disponibles
-- Fuente: INEGI Cartas Topográficas
--         (MedioFisicoNatural.gpkg → CurvasNivel)
-- DEUDA: Completar con CEM 3.0 o Cartas 1:50,000
-- ETL: DataCharge/LoadPlutarcoGeo.py → CurvasNivelETL
-- =====================================================
CREATE TABLE IF NOT EXISTS plutarco.curvas_nivel (
    id         SERIAL PRIMARY KEY,
    elevacion  NUMERIC(8,2),
    tipo       TEXT,
    geom       GEOMETRY(MultiLineString, 4326),
    fuente     TEXT DEFAULT 'INEGI Cartas Topográficas',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_curvas_nivel_geom      ON plutarco.curvas_nivel USING GIST (geom);
CREATE INDEX IF NOT EXISTS idx_curvas_nivel_elevacion ON plutarco.curvas_nivel (elevacion);


-- =====================================================
-- TABLA: plutarco.afluencia_linea
-- Afluencia mensual por línea de transporte público
-- Granularidad: 1 fila = 1 línea × 1 mes × 1 año
-- Fuente: SEMOVI / organismos operadores (CSVs en ETL/Data/Pesos/)
-- ETL: DataCharge/LoadAfluencia.py
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
-- Permite al ETL de afluencia resolver nombres heterogéneos
-- (ej. "STC-Línea 1" → linea_id=1, sistema=METRO)
-- Mantenimiento: manual (seed o INSERT directo)
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
-- TABLA: plutarco.afluencia_estacion
-- Afluencia mensual por estación de Metro
-- Granularidad: 1 fila = 1 estación × 1 mes × 1 año
-- Fuente: datos.cdmx.gob.mx — Afluencia Diaria del Metro (Simple)
-- ETL: DataCharge/LoadAfluenciaEstacion.py
-- Issue: #45
-- =====================================================
CREATE TABLE IF NOT EXISTS plutarco.afluencia_estacion (
    id            SERIAL PRIMARY KEY,
    estacion_id   INTEGER REFERENCES public.estacions(id),
    linea_id      INTEGER REFERENCES public.lineas(id),
    anio          SMALLINT NOT NULL,
    mes_num       SMALLINT NOT NULL,
    mes           VARCHAR(20),
    afluencia     BIGINT NOT NULL,
    fuente        TEXT DEFAULT 'STC-Metro-DatosAbiertos',
    created_at    TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(estacion_id, anio, mes_num)
);

CREATE INDEX IF NOT EXISTS idx_afluencia_estacion_id    ON plutarco.afluencia_estacion (estacion_id);
CREATE INDEX IF NOT EXISTS idx_afluencia_estacion_linea ON plutarco.afluencia_estacion (linea_id);
CREATE INDEX IF NOT EXISTS idx_afluencia_estacion_anio  ON plutarco.afluencia_estacion (anio, mes_num);


-- =====================================================
-- PERMISOS — Se configuran en 03_roles.sh (el rol aún no existe aquí)
-- =====================================================


-- =====================================================
-- TABLAS PENDIENTES (deuda de datos — v3)
-- =====================================================
-- plutarco.servicios_area    ← *sia.shp  (falta CDMX) (Issue #44)
-- =====================================================
