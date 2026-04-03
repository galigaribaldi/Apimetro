-- 1. Asignar sentido 0 a todos los ramales de regreso
UPDATE ramals SET ramal_num = 0 WHERE shape_gtfs LIKE '%_0';

-- 2. Asignar sentido 1 a todos los ramales de ida
UPDATE ramals SET ramal_num = 1 WHERE shape_gtfs LIKE '%_1';

-- 1. Superficie Baja (Ej. Vagonetas, Pumabús, Microbuses alimentadores pequeños)
UPDATE lineas
SET
    jerarquia_transporte = 'superficie_baja'
WHERE
    sistema IN (
        'PUMABUS',
        'MICROBUS',
        'VAGONETA'
    );

-- 2. Superficie Convencional (Ej. Autobuses estándar, RTP, Trolebús tradicional, Corredores)
UPDATE lineas
SET
    jerarquia_transporte = 'superficie_convencional'
WHERE
    sistema IN ('RTP', 'CC', 'TROLE');

-- 3. Masivo Mediano (Ej. BRTs como Metrobús/Mexibús, Tren Ligero, Cablebús)
UPDATE lineas
SET
    jerarquia_transporte = 'masivo_mediano'
WHERE
    sistema IN (
        'METROBUS',
        'MEXIBUS',
        'TREN LIGERO',
        'CABLEBUS',
        'MEXICABLE'
    );

-- 4. Masivo Pesado (Ej. Metro, Tren Suburbano, Tren Insurgente)
UPDATE lineas
SET
    jerarquia_transporte = 'masivo_pesado'
WHERE
    sistema IN (
        'METRO',
        'SUBURBANO',
        'TREN INSURGENTE'
    );

-- ==============================================================================
-- FASE 2: ACTUALIZACIÓN DE FRECUENCIAS OPERATIVAS REALISTAS (HORA PICO)
-- Conexión: historico_operacion -> ramals -> lineas
-- ==============================================================================

-- 1. Sistemas Masivos y Concesionados (Ajuste Híbrido con Fricción)
UPDATE historico_operacion
SET
    frecuencia_minutos = 4.0,
    fuente = 'Modelo VFT Híbrido (Teoría+GTFS)'
WHERE
    ramal_id IN (
        SELECT r.id
        FROM ramals r
            JOIN lineas l ON r.linea_id = l.id
        WHERE
            TRIM(UPPER(l.sistema)) = 'METRO'
    );

UPDATE historico_operacion
SET
    frecuencia_minutos = 6.0,
    fuente = 'Modelo VFT Híbrido (Teoría+GTFS)'
WHERE
    ramal_id IN (
        SELECT r.id
        FROM ramals r
            JOIN lineas l ON r.linea_id = l.id
        WHERE
            TRIM(UPPER(l.sistema)) = 'MB'
    );

UPDATE historico_operacion
SET
    frecuencia_minutos = 10.0,
    fuente = 'Modelo VFT Híbrido (Teoría+GTFS)'
WHERE
    ramal_id IN (
        SELECT r.id
        FROM ramals r
            JOIN lineas l ON r.linea_id = l.id
        WHERE
            TRIM(UPPER(l.sistema)) = 'CC'
    );

UPDATE historico_operacion
SET
    frecuencia_minutos = 5.0,
    fuente = 'Modelo VFT Híbrido (Teoría+GTFS)'
WHERE
    ramal_id IN (
        SELECT r.id
        FROM ramals r
            JOIN lineas l ON r.linea_id = l.id
        WHERE
            TRIM(UPPER(l.sistema)) = 'TL'
    );

-- 2. Sistemas de Superficie y Flujo Continuo (GTFS Realista / Diseño)
UPDATE historico_operacion
SET
    frecuencia_minutos = 10.0,
    fuente = 'Modelo VFT (Promedio GTFS)'
WHERE
    ramal_id IN (
        SELECT r.id
        FROM ramals r
            JOIN lineas l ON r.linea_id = l.id
        WHERE
            TRIM(UPPER(l.sistema)) = 'TROLE'
    );

UPDATE historico_operacion
SET
    frecuencia_minutos = 20.0,
    fuente = 'Modelo VFT (Promedio GTFS)'
WHERE
    ramal_id IN (
        SELECT r.id
        FROM ramals r
            JOIN lineas l ON r.linea_id = l.id
        WHERE
            TRIM(UPPER(l.sistema)) = 'RTP'
    );

UPDATE historico_operacion
SET
    frecuencia_minutos = 0.5,
    fuente = 'Modelo VFT (Diseño Fijo)'
WHERE
    ramal_id IN (
        SELECT r.id
        FROM ramals r
            JOIN lineas l ON r.linea_id = l.id
        WHERE
            TRIM(UPPER(l.sistema)) = 'CBB'
    );

-- 3. Sistemas Foráneos y Universitarios (Horarios Oficiales Publicados)
UPDATE historico_operacion
SET
    frecuencia_minutos = 8.0,
    fuente = 'Modelo VFT (Horario Oficial)'
WHERE
    ramal_id IN (
        SELECT r.id
        FROM ramals r
            JOIN lineas l ON r.linea_id = l.id
        WHERE
            TRIM(UPPER(l.sistema)) = 'SUB'
    );

UPDATE historico_operacion
SET
    frecuencia_minutos = 15.0,
    fuente = 'Modelo VFT (Horario Oficial)'
WHERE
    ramal_id IN (
        SELECT r.id
        FROM ramals r
            JOIN lineas l ON r.linea_id = l.id
        WHERE
            TRIM(UPPER(l.sistema)) = 'INTERURBANO'
    );

UPDATE historico_operacion
SET
    frecuencia_minutos = 5.0,
    fuente = 'Modelo VFT (Horario Oficial)'
WHERE
    ramal_id IN (
        SELECT r.id
        FROM ramals r
            JOIN lineas l ON r.linea_id = l.id
        WHERE
            TRIM(UPPER(l.sistema)) = 'PUMABUS'
    );

-- ==============================================================================
-- CORRECCIÓN ESPACIAL: Vecino más cercano para estaciones en "fronteras o huecos"
-- ==============================================================================

UPDATE estacions e
SET
    alcaldia_municipio = (
        SELECT nombre
        FROM limites_territoriales l
        ORDER BY e.geom <-> l.geom
        LIMIT 1
    ),
    estado_ciudad = (
        SELECT entidad
        FROM limites_territoriales l
        ORDER BY e.geom <-> l.geom
        LIMIT 1
    )
WHERE
    e.alcaldia_municipio = '0.0';
------
-----

UPDATE estacions e
SET
    alcaldia_municipio = l.nombre,
    estado_ciudad = l.entidad
FROM limites_territoriales l
WHERE
    ST_Intersects (e.geom, l.geom);

-----
-----
-----