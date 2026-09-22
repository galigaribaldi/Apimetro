-- ============================================================
-- MIGRACIÓN: Segmentar ramals.geom de línea completa
--            a segmentos interestación
-- ============================================================
-- Archivo : db/init/UPDATE.sql
-- Autor   : Hernán Galileo Cabrera Garibaldi
-- Fecha   : 2026-04-17
-- Versión : 1.0
--
-- PROPÓSITO
-- ---------
-- Actualmente ramals.geom almacena la geometría del recorrido
-- completo de cada ramal (ej. Metro L1 = 176 vértices, 16.6 km
-- en una sola geometría). El endpoint geojsonLinea devuelve esta
-- geometría como un MultiLineString con 1 sublínea por sentido.
--
-- Esto provoca que VFTModel construya el grafo con micro-aristas
-- entre vértices geométricos en lugar de aristas interestación,
-- haciendo que los tiempos de viaje sean de segundos en lugar de
-- minutos por tramo real.
--
-- Este script reemplaza cada ramals.geom con un MultiLineString
-- de N-1 sublíneas, donde N = número de estaciones de la línea.
-- Cada sublínea corresponde exactamente a un tramo interestación.
--
-- PRECONDICIONES
-- --------------
-- 1. Las estaciones deben tener geom IS NOT NULL.
-- 2. Las estaciones deben estar vinculadas a su línea via linea_id.
-- 3. PostGIS debe estar instalado (ST_LineLocatePoint,
--    ST_LineSubstring, ST_LineMerge, ST_Collect, ST_Multi).
--
-- SISTEMAS CUBIERTOS
-- ------------------
-- Todos los que tienen estaciones con geom poblado:
--   METRO, MB, TL, TROLE, RTP, CC, SUB, INTERURBANO, CBB
-- Sistemas sin num_estacion (MEXICABLE, MEXIBÚS) se ordenan
-- automáticamente por posición geográfica en el trazo.
--
-- IMPACTO EN LA API
-- -----------------
-- El endpoint GET /movilidad/mapas/geojsonLinea devolverá
-- features con N-1 sublíneas por ramal en lugar de 1.
-- Sin cambios en código Go ni en el esquema (init.sql).
--
-- TIEMPO ESTIMADO: ~2-5 min sobre 693 ramals x 22k estaciones.
-- ============================================================

-- ============================================================
-- CONEXIÓN A DOCKER DESDE pgAdmin
-- ============================================================
--
-- ENTORNO DEV (recomendado para probar primero):
--   Host/Address : localhost
--   Port         : 5433
--   Database     : db_apimetro
--   Username     : admin_apimetro
--   Password     : Dev_Adm1nP4ss!2024
--
-- ENTORNO QA:
--   Host/Address : localhost
--   Port         : 5434
--   Database     : db_apimetro
--   Username     : admin_apimetro
--   Password     : QA_Adm1nP4ss!2024
--
-- PASOS EN pgAdmin:
--   1. Object > Register > Server...
--   2. Pestaña "General" → Name: Apimetro DEV (o QA)
--   3. Pestaña "Connection" → completar los datos de arriba
--   4. Save. El servidor aparece en el árbol izquierdo.
--   5. Abrir Query Tool sobre db_apimetro (clic derecho
--      sobre la base → Query Tool)
--   6. Pegar y ejecutar el UPDATE de abajo (F5 o ▶)
--
-- NOTA: El contenedor Docker debe estar corriendo antes de
-- conectarte. Verifica con: docker ps | grep apimetro_db
-- ============================================================

BEGIN;

WITH

-- ── 1. Descomponer cada ramal en sub-trazos individuales (LineStrings) ───
--    ST_LineMerge intenta fusionar el MultiLineString en un único trazo.
--    Si los sub-trazos están desconectados (ej. CBB con 6 segmentos
--    separados), ST_LineMerge devuelve MultiLineString y ST_LineLocatePoint
--    falla con "1st arg isn't a line".
--    Solución: ST_Dump descompone el resultado en LineStrings individuales
--    sin importar si el merge fue parcial o total.
ramal_lines AS (
    SELECT
        r.id AS ramal_id,
        r.linea_id,
        (
            ST_Dump (ST_LineMerge (r.geom))
        ).geom AS line_geom,
        (
            ST_Dump (ST_LineMerge (r.geom))
        ).path[1] AS part_idx
    FROM ramals r
    WHERE
        r.geom IS NOT NULL
        AND ST_GeometryType (r.geom) IS NOT NULL
),

-- ── 2. Para cada (ramal, sub-trazo, estación): calcular fracción y
--       distancia de la estación al sub-trazo ────────────────────────────
--    Esto genera todas las combinaciones posibles; en el paso siguiente
--    cada estación se asigna únicamente al sub-trazo más cercano.
fracciones AS (
    SELECT
        rl.ramal_id,
        rl.part_idx,
        rl.line_geom,
        e.id AS estacion_id,
        ST_LineLocatePoint (rl.line_geom, e.geom) AS t,
        ST_Distance (
            ST_ClosestPoint (rl.line_geom, e.geom)::geography,
            e.geom::geography
        ) AS dist_m
    FROM ramal_lines rl
        JOIN estacions e ON e.linea_id = rl.linea_id
    WHERE
        e.geom IS NOT NULL
        AND ST_GeometryType (rl.line_geom) = 'ST_LineString'
),

-- ── 3. Asignar cada estación al sub-trazo más cercano ───────────────────
--    DISTINCT ON (ramal_id, estacion_id) + ORDER BY dist_m garantiza que
--    una estación solo aparezca una vez por ramal, en el sub-trazo donde
--    tiene la proyección más corta.
fracciones_asignadas AS (
    SELECT DISTINCT
        ON (ramal_id, estacion_id) ramal_id,
        part_idx,
        line_geom,
        t,
        dist_m
    FROM fracciones
    ORDER BY ramal_id, estacion_id, dist_m
),

-- ── 4. Definir los límites de cada segmento interestación ───────────────
--    Dentro de cada (ramal, sub-trazo), LEAD() obtiene la fracción de la
--    siguiente estación ordenada por posición física en el trazo.
segmentos AS (
    SELECT
        ramal_id,
        part_idx,
        line_geom,
        t AS t_ini,
        LEAD(t) OVER (
            PARTITION BY
                ramal_id,
                part_idx
            ORDER BY t
        ) AS t_fin
    FROM fracciones_asignadas
),

-- ── 5. Cortar cada sub-trazo entre estaciones consecutivas ───────────────
--    Se descartan segmentos < 0.001 de fracción (proyecciones duplicadas
--    o estaciones terminales que caen en el mismo punto del trazo).
geometrias_segmento AS (
    SELECT
        ramal_id,
        ST_LineSubstring (line_geom, t_ini, t_fin) AS seg_geom
    FROM segmentos
    WHERE
        t_fin IS NOT NULL
        AND (t_fin - t_ini) > 0.001
),

-- ── 6. Reagrupar todos los segmentos del ramal en un MultiLineString ─────
nueva_geom AS (
    SELECT
        ramal_id,
        ST_Multi (ST_Collect (seg_geom)) AS geom_segmentada
    FROM geometrias_segmento
    WHERE
        seg_geom IS NOT NULL
    GROUP BY
        ramal_id
)

-- ── 7. Actualizar ramals ─────────────────────────────────────────────────
UPDATE ramals r
SET
    geom = ng.geom_segmentada
FROM nueva_geom ng
WHERE
    r.id = ng.ramal_id
    AND ng.geom_segmentada IS NOT NULL;

COMMIT;

-- ============================================================
-- VERIFICACIÓN POST-MIGRACIÓN
-- ============================================================
-- Ejecutar después del UPDATE para confirmar resultados:
--
-- 1. Conteo de sublíneas por sistema (debe ser > 1 para todos):
--
--    SELECT l.sistema, l.num_comercial,
--           r.nombre_ramal, r.ramal_num,
--           ST_NumGeometries(r.geom) AS n_segmentos
--    FROM ramals r
--    JOIN lineas l ON l.id = r.linea_id
--    WHERE l.sistema IN ('METRO','MB','TL','CBB')
--    ORDER BY l.sistema, l.num_comercial, r.ramal_num
--    LIMIT 20;
--
-- 2. Metro L1 debe tener 19 segmentos por sentido:
--
--    SELECT r.nombre_ramal, r.ramal_num,
--           ST_NumGeometries(r.geom) AS n_segmentos,
--           ST_NPoints(r.geom) AS n_vertices_total
--    FROM ramals r
--    JOIN lineas l ON l.id = r.linea_id
--    WHERE l.sistema = 'METRO' AND l.num_comercial = '1';
--
-- 3. Verificar el endpoint de la API:
--    curl "http://localhost:8080/movilidad/mapas/geojsonLinea?sistema=METRO&num_comercial=1"
--    → Cada feature debe tener "type": "MultiLineString" con 19 coordinates[]
-- ============================================================

-- ============================================================
-- REGENERAR seed.sql DESPUÉS DE VERIFICAR
-- ============================================================
-- Desde terminal (no en pgAdmin), ejecutar:
--
--PGPASSWORD='Dev_Adm1nP4ss!2024' pg_dump \
--data-only --inserts --disable-triggers \
---t lineas -t ramals -t estacions \
---t descripcion_lineas -t descripcion_estacions \
---t historico_operacion -t limites_territoriales \
---h localhost -p 5433 -U admin_apimetro db_apimetro \
--> db/init/seed.sql
--
-- El nuevo seed.sql contendrá las geometrías segmentadas y
-- se usará en todos los contenedores Docker futuros.
-- ============================================================