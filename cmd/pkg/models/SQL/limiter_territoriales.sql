-- Tabla única para límites territoriales
CREATE TABLE limites_territoriales (
    id SERIAL PRIMARY KEY,
    cvegeo VARCHAR(10) UNIQUE, -- Ej: '09' (CDMX), '09015' (Cuauhtémoc)
    nombre VARCHAR(255), -- Ej: 'Iztapalapa', 'Ecatepec'
    entidad VARCHAR(100), -- 'Ciudad de México', 'México', 'Hidalgo'
    nivel VARCHAR(50), -- 'ESTADO' o 'MUNICIPIO'
    geom GEOMETRY (MultiPolygon, 4326)
);

-- Índice espacial para que las consultas vuelen
CREATE INDEX idx_limites_territoriales_geom ON limites_territoriales USING GIST (geom);

-- 1. Renombramos la columna del INEGI para que Go la reconozca
ALTER TABLE limites_territoriales RENAME COLUMN nomgeo TO nombre;

-- 2. Agregamos las columnas de filtro que programamos en el Controlador
ALTER TABLE limites_territoriales ADD COLUMN entidad VARCHAR(100);

ALTER TABLE limites_territoriales ADD COLUMN nivel VARCHAR(50);

-- 3. Etiquetamos todo como CDMX
UPDATE limites_territoriales
SET
    entidad = 'Ciudad de México',
    nivel = 'MUNICIPIO';