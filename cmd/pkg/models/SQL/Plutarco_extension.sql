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