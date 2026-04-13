-- =====================================================
-- Apimetro — DDL Completo
-- Fuente de verdad: inspección directa de db_apimetro
-- Autor: galigaribaldi | Generado: 2026-04
-- =====================================================

-- =====================================================
-- EXTENSIONES
-- =====================================================
CREATE EXTENSION IF NOT EXISTS postgis;

CREATE EXTENSION IF NOT EXISTS postgis_topology;

-- =====================================================
-- ESQUEMAS
-- =====================================================
CREATE SCHEMA IF NOT EXISTS plutarco;

COMMENT ON SCHEMA plutarco IS 'Esquema reservado para datos de AGEBs y Calles (integración futura)';

-- =====================================================
-- TIPOS PERSONALIZADOS
-- =====================================================
DO $$ BEGIN
    CREATE TYPE estado_ramal AS ENUM (
        'Existe',
        'Propuesta oficial',
        'Propuesta académica',
        'Descartado'
    );

EXCEPTION WHEN duplicate_object THEN NULL;

END $$;

-- =====================================================
-- TABLAS PRINCIPALES
-- Orden: menor a mayor dependencia de FK
-- =====================================================

-- Tabla: lineas
-- Cada línea de transporte público (METRO, MB, CBB, etc.)
-- NOTA: la columna geom almacena WKT plano (TEXT), no una geometría PostGIS.
--       Las geometrías reales de los trazos viven en la tabla ramals.
CREATE TABLE IF NOT EXISTS lineas (
    id BIGSERIAL PRIMARY KEY,
    nombre TEXT,
    sistema TEXT,
    anio_inauguracion BIGINT,
    color_en TEXT,
    color_esp TEXT,
    tam_km NUMERIC,
    existe BOOLEAN,
    ramal_id BIGINT,
    linea_base_ramal BIGINT,
    geom TEXT,
    route_gtfs TEXT,
    num_comercial TEXT,
    clasificacion TEXT DEFAULT 'existente',
    jerarquia_transporte TEXT,
    derecho_de_via TEXT,
    capacidad_vehiculo BIGINT
);

-- Tabla: ramals
-- Variantes de ruta de una línea (IDA, REGRESO, ramales específicos).
-- Contiene la geometría real del trazo como MultiLineString PostGIS (SRID 4326).
CREATE TABLE IF NOT EXISTS ramals (
    id BIGSERIAL PRIMARY KEY,
    linea_id BIGINT,
    shape_gtfs TEXT,
    nombre_ramal TEXT,
    tam_km NUMERIC,
    anio_creacion BIGINT,
    ramal_num BIGINT,
    estado estado_ramal,
    geom geometry (MultiLineString, 4326),
    CONSTRAINT fk_lineas_ramales FOREIGN KEY (linea_id) REFERENCES lineas (id)
);

-- Tabla: estacions
-- Estaciones o paradas de cada sistema de transporte.
-- Contiene geometría PostGIS tipo Point (SRID 4326) usada en queries GeoJSON.
-- Las columnas longitud/latitud son campos numéricos separados (redundantes con geom).
CREATE TABLE IF NOT EXISTS estacions (
    id BIGSERIAL PRIMARY KEY,
    nombre TEXT,
    cve_est TEXT,
    tipo TEXT,
    alcaldia_municipio TEXT,
    anio TEXT,
    estado_ciudad TEXT,
    longitud NUMERIC,
    latitud NUMERIC,
    linea_id SMALLINT,
    num_estacion SMALLINT,
    estacion_id_oficial SMALLINT,
    sistema TEXT,
    existe BOOLEAN,
    stop_gtfs TEXT,
    geom geometry (Point, 4326),
    es_cetram BOOLEAN DEFAULT false,
    nombre_cetram TEXT,
    CONSTRAINT fk_estacions_linea FOREIGN KEY (linea_id) REFERENCES lineas (id)
);

-- Tabla: descripcion_lineas
-- Información histórica y descriptiva de las líneas:
-- terminales originales, tipo, ampliaciones y texto libre.
CREATE TABLE IF NOT EXISTS descripcion_lineas (
    id BIGSERIAL PRIMARY KEY,
    terminal_original TEXT,
    inicio_original TEXT,
    tipo TEXT,
    direccion TEXT,
    descripcion TEXT,
    anio_inicio_ampliacion BIGINT,
    anio_fin_ampliacion BIGINT,
    linea_base BIGINT,
    CONSTRAINT fk_lineas_descripcion_linea FOREIGN KEY (linea_base) REFERENCES lineas (id)
);

-- Tabla: descripcion_estacions
-- Información histórica y complementaria de estaciones:
-- clave oficial, tipo administrativo, alcaldía y año de apertura.
CREATE TABLE IF NOT EXISTS descripcion_estacions (
    id BIGSERIAL PRIMARY KEY,
    nombre TEXT,
    cve_est TEXT,
    tipo TEXT,
    alcaldia_municipio TEXT,
    anio TEXT,
    estado_ciudad TEXT,
    longitud NUMERIC,
    estacion_id BIGINT,
    CONSTRAINT fk_descripcion_estacions_estacion FOREIGN KEY (estacion_id) REFERENCES estacions (id)
);

-- Tabla: historico_operacion
-- Métricas operativas por ramal: velocidad promedio, frecuencia, fuente y fecha.
-- ramal_id tiene constraint UNIQUE — un registro por ramal.
CREATE TABLE IF NOT EXISTS historico_operacion (
    id SERIAL PRIMARY KEY,
    linea_id INTEGER,
    ramal_id INTEGER UNIQUE,
    velocidad_promedio_kmh NUMERIC,
    frecuencia_minutos NUMERIC,
    fuente TEXT,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT historico_operacion_linea_id_fkey FOREIGN KEY (linea_id) REFERENCES lineas (id),
    CONSTRAINT historico_operacion_ramal_id_fkey FOREIGN KEY (ramal_id) REFERENCES ramals (id)
);

-- Tabla: limites_territoriales
-- Polígonos administrativos: alcaldías CDMX y municipios del Área Metropolitana.
-- Usada exclusivamente en el endpoint GeoJSON de polígonos (raw SQL PostGIS).
CREATE TABLE IF NOT EXISTS limites_territoriales (
    gid SERIAL PRIMARY KEY,
    cvegeo VARCHAR(5),
    cve_ent VARCHAR(2),
    cve_mun VARCHAR(3),
    nombre VARCHAR(80),
    geom geometry (MultiPolygon, 4326),
    entidad VARCHAR(100),
    nivel VARCHAR(50)
);

-- =====================================================
-- ÍNDICES DE RENDIMIENTO Y ESPACIALES
-- =====================================================

-- Búsqueda de ramales por línea (JOIN frecuente en GeoJSON)
CREATE INDEX IF NOT EXISTS idx_ramals_linea_id ON ramals USING btree (linea_id);

-- Histórico: búsqueda por ramal y orden cronológico
CREATE INDEX IF NOT EXISTS idx_historico_ramal ON historico_operacion USING btree (ramal_id);

CREATE INDEX IF NOT EXISTS idx_historico_fecha ON historico_operacion USING btree (fecha_registro DESC);

-- Índices espaciales GiST — requeridos por ST_AsGeoJSON, ST_DWithin, ST_Intersects
CREATE INDEX IF NOT EXISTS idx_estacions_geom ON estacions USING gist (geom);

CREATE INDEX IF NOT EXISTS idx_ramals_geom ON ramals USING gist (geom);

CREATE INDEX IF NOT EXISTS idx_limites_territoriales_geom ON limites_territoriales USING gist (geom);

-- 1. Crear el esquema
CREATE SCHEMA IF NOT EXISTS plutarco;

-- 2. Tabla de AGEBS (Áreas Geoestadísticas Básicas)
-- Generalmente polígonos que contienen datos sociodemográficos
CREATE TABLE IF NOT EXISTS plutarco.agebs (
    id SERIAL PRIMARY KEY,
    cve_ageb VARCHAR(20) UNIQUE NOT NULL, -- Código identificador del INEGI
    poblacion_total INTEGER DEFAULT 0,
    viviendas_habitadas INTEGER DEFAULT 0,
    geom GEOMETRY (MultiPolygon, 4326), -- Geometría tipo MultiPolígono
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Tabla de Calles (Red Vial)
-- Segmentos de líneas para análisis de conectividad
CREATE TABLE IF NOT EXISTS plutarco.calles (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(255),
    tipo_vialidad VARCHAR(50), -- Eje vial, Avenida, Calle, Callejón
    sentido VARCHAR(20), -- Un sentido, ambos sentidos
    geom GEOMETRY (MultiLineString, 4326), -- Geometría tipo MultiLínea
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Índices Espaciales (Crucial para el rendimiento en GORM)
CREATE INDEX idx_agebs_geom ON plutarco.agebs USING GIST (geom);

CREATE INDEX idx_calles_geom ON plutarco.calles USING GIST (geom);