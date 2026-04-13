--------------------------------------------------
------------------------------------------------------
--------------------------------------------------
-------------------------------------------------------------
--- UPDATE de derecho de vía y capacidad de Vehiculo
-------------------------------------------------------------
--------------------------------------------------
------------------------------------------------------
--------------------------------------------------
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

--------------------------------------------------
------------------------------------------------------
--------------------------------------------------
-------------------------------------------------------------
--- UPDATE de Velocidades por sistema
-------------------------------------------------------------
--------------------------------------------------
------------------------------------------------------
--------------------------------------------------

UPDATE historico_operacion ho
SET
    velocidad_promedio_kmh = CASE
        WHEN l.sistema = 'METRO' THEN 36.0
        WHEN l.sistema = 'MB' THEN 16.3
        WHEN l.sistema = 'MEXIBÚS' THEN 16.3
        WHEN l.sistema = 'SUB' THEN 65.0
        WHEN l.sistema = 'INTERURBANO' THEN 160.0
        WHEN l.sistema = 'TL' THEN 22.0
        WHEN l.sistema = 'CBB' THEN 20.0
        WHEN l.sistema = 'MEXICABLE' THEN 20.0
        WHEN l.sistema = 'RTP' THEN 11.0
        WHEN l.sistema = 'CC' THEN 11.0
        WHEN l.sistema = 'PUMABUS' THEN 14.0
        WHEN l.sistema = 'TROLE' THEN (
            CASE
                WHEN l.nombre ILIKE '%Elevado%' THEN 25.0
                ELSE 18.0
            END
        )
        ELSE ho.velocidad_promedio_kmh
    END,
    fuente = LEFT(
        CASE
            WHEN l.sistema IN ('METRO', 'MB', 'MEXIBÚS') THEN 'https://semovi.cdmx.gob.mx/storage/app/media/diagnostico-tecnico-de-movilidad-pim.pdf'
            WHEN l.sistema = 'SUB' THEN 'https://es.wikipedia.org/wiki/Ferrocarril_Suburbano_de_la_Zona_Metropolitana_del_Valle_de_M%C3%A9xico'
            WHEN l.sistema = 'INTERURBANO' THEN 'http://www.conama11.vsf.es/conama10/download/files/conama2022/CT%202022/10009788.pdf'
            WHEN l.sistema = 'TL' THEN 'https://es.wikipedia.org/wiki/Tren_ligero_de_la_Ciudad_de_M%C3%A9xico'
            WHEN l.sistema IN ('CBB', 'MEXICABLE') THEN 'https://obras.expansion.mx/infraestructura/2024/09/25/linea-3-del-cablebus-mapa-estaciones-ruta-precio-horarios'
            WHEN l.sistema = 'TROLE' THEN CASE
                WHEN l.nombre ILIKE '%Elevado%' THEN 'https://www.unotv.com/nacional/sheinbaum-anuncia-que-el-trolebus-elevado-se-inaugurara-el-12-de-mayo/'
                ELSE 'https://www.ste.cdmx.gob.mx/storage/app/media/Dinamica%20de%20Operacion%20de%20Eje%20Central/dinamica_operacion_eje_central.pdf'
            END
            WHEN l.sistema IN ('RTP', 'CC') THEN 'https://revistas-colaboracion.juridicas.unam.mx/index.php/rev-administracion-publica/article/viewFile/42369/39117'
            ELSE ho.fuente
        END,
        100
    ),
    fecha_registro = NOW()
FROM ramals r
    JOIN lineas l ON r.linea_id = l.id
WHERE
    ho.ramal_id = r.id;

ALTER TABLE historico_operacion ALTER COLUMN fuente TYPE TEXT;

Commit;