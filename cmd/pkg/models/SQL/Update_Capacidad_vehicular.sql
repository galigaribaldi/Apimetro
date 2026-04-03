-- 1. STC Metro (Trenes de 9 carros)
UPDATE lineas
SET
    derecho_de_via = 'exclusivo',
    capacidad_vehiculo = 1500
WHERE
    sistema = 'METRO';

-- 2. Metrobús (Autobuses articulados)
UPDATE lineas
SET
    derecho_de_via = 'exclusivo',
    capacidad_vehiculo = 160
WHERE
    sistema = 'MB';

-- 3. Red de Transporte de Pasajeros - RTP (Autobuses padrón)
UPDATE lineas
SET
    derecho_de_via = 'compartido',
    capacidad_vehiculo = 90
WHERE
    sistema = 'RTP';

-- 4. Trolebús STE (Autobuses eléctricos)
UPDATE lineas
SET
    derecho_de_via = 'compartido',
    capacidad_vehiculo = 90
WHERE
    sistema = 'TROLE';

-- 5. Cablebús (Cabinas aéreas)
UPDATE lineas
SET
    derecho_de_via = 'exclusivo',
    capacidad_vehiculo = 10
WHERE
    sistema = 'CBB';

-- 6. Tren Ligero - STE (Trenes ligeros articulados dobles)
UPDATE lineas
SET
    derecho_de_via = 'exclusivo',
    capacidad_vehiculo = 374
WHERE
    sistema = 'TL';

-- 7. Tren Suburbano (Trenes pesados de 4 a 8 carros)
UPDATE lineas
SET
    derecho_de_via = 'exclusivo',
    capacidad_vehiculo = 2200 -- Capacidad oficial configuración 8 carros
WHERE
    sistema = 'SUB';

-- 8. Tren Interurbano "El Insurgente" (Trenes de 5 carros)
UPDATE lineas
SET
    derecho_de_via = 'exclusivo',
    capacidad_vehiculo = 719 -- Ficha técnica oficial trenes CAF
WHERE
    sistema = 'INTERURBANO';

-- 9. Corredores Concesionados (Autobuses morados)
UPDATE lineas
SET
    derecho_de_via = 'compartido',
    capacidad_vehiculo = 90
WHERE
    sistema = 'CC';

-- 10. PUMABUS (Autobuses universitarios padrón)
UPDATE lineas
SET
    derecho_de_via = 'compartido',
    capacidad_vehiculo = 90
WHERE
    sistema = 'PUMABUS';