-- =====================================================
-- v5.0_sub_segmentos.sql
-- ACHECK-01: segmentar Tren Suburbano (linea_id=102)
-- de 2 ramals (línea completa) a 12 (6 segmentos × 2 sentidos)
-- Fuente geometría: GTFS local (ETL/Data/)
-- Generado por scripts/generate_sub_migration.py
-- =====================================================

BEGIN;

-- ── Paso 1: Insertar 12 nuevos ramals + historico_operacion ──

-- Sentido 1 — IDA
WITH r AS (
    INSERT INTO ramals (linea_id, nombre_ramal, ramal_num, estado, shape_gtfs, tam_km, anio_creacion, geom)
    VALUES (102, 'Cuautitlán-Tultitlán', 1, 'Existe', 'B_SH0700L1000_1', 0.0, 2024, ST_Multi(ST_GeomFromText('LINESTRING(-99.1763 19.6671, -99.1768612842288 19.6604587220746, -99.1779727247128 19.646494838975, -99.18039 19.63551)', 4326)))
    RETURNING id
)
INSERT INTO historico_operacion (ramal_id, velocidad_promedio_kmh, fuente, fecha_registro)
SELECT id, 65.0, 'https://es.wikipedia.org/wiki/Ferrocarril_Suburbano_de_la_Zona_Metropolitana_del_Valle_de_M%C3%A9xico', NOW() FROM r;

WITH r AS (
    INSERT INTO ramals (linea_id, nombre_ramal, ramal_num, estado, shape_gtfs, tam_km, anio_creacion, geom)
    VALUES (102, 'Tultitlán-Lechería', 1, 'Existe', 'B_SH0700L1000_1', 0.0, 2024, ST_Multi(ST_GeomFromText('LINESTRING(-99.18039 19.63551, -99.1814238063908 19.629326104029, -99.1864008494341 19.6075014198745, -99.18675 19.59921)', 4326)))
    RETURNING id
)
INSERT INTO historico_operacion (ramal_id, velocidad_promedio_kmh, fuente, fecha_registro)
SELECT id, 65.0, 'https://es.wikipedia.org/wiki/Ferrocarril_Suburbano_de_la_Zona_Metropolitana_del_Valle_de_M%C3%A9xico', NOW() FROM r;

WITH r AS (
    INSERT INTO ramals (linea_id, nombre_ramal, ramal_num, estado, shape_gtfs, tam_km, anio_creacion, geom)
    VALUES (102, 'Lechería-San Rafael', 1, 'Existe', 'B_SH0700L1000_1', 0.0, 2024, ST_Multi(ST_GeomFromText('LINESTRING(-99.18675 19.59921, -99.18543979198022 19.594564346013502, -99.1860680126328 19.5923433027883, -99.1866967085453 19.5905492558055, -99.1956502356694 19.580419876568, -99.19744999397292 19.5785391170087, -99.1978979457314 19.5764463274495, -99.1975352553779 19.5745679256562, -99.19622194431427 19.568890258202103, -99.19496 19.56526)', 4326)))
    RETURNING id
)
INSERT INTO historico_operacion (ramal_id, velocidad_promedio_kmh, fuente, fecha_registro)
SELECT id, 65.0, 'https://es.wikipedia.org/wiki/Ferrocarril_Suburbano_de_la_Zona_Metropolitana_del_Valle_de_M%C3%A9xico', NOW() FROM r;

WITH r AS (
    INSERT INTO ramals (linea_id, nombre_ramal, ramal_num, estado, shape_gtfs, tam_km, anio_creacion, geom)
    VALUES (102, 'San Rafael-Tlalnepantla', 1, 'Existe', 'B_SH0700L1000_1', 0.0, 2024, ST_Multi(ST_GeomFromText('LINESTRING(-99.19496 19.56526, -99.1938681176099 19.5594133922809, -99.190125649517 19.5562575661647, -99.18899829377008 19.5551912473416, -99.18809518253028 19.5532706857126, -99.18413 19.53574)', 4326)))
    RETURNING id
)
INSERT INTO historico_operacion (ramal_id, velocidad_promedio_kmh, fuente, fecha_registro)
SELECT id, 65.0, 'https://es.wikipedia.org/wiki/Ferrocarril_Suburbano_de_la_Zona_Metropolitana_del_Valle_de_M%C3%A9xico', NOW() FROM r;

WITH r AS (
    INSERT INTO ramals (linea_id, nombre_ramal, ramal_num, estado, shape_gtfs, tam_km, anio_creacion, geom)
    VALUES (102, 'Tlalnepantla-Fortuna', 1, 'Existe', 'B_SH0700L1000_1', 0.0, 2024, ST_Multi(ST_GeomFromText('LINESTRING(-99.18413 19.53574, -99.1827111045973 19.53205423021389, -99.17927989360528 19.5244997232918, -99.1784650317494 19.5206575051377, -99.1781854192674 19.5120750206638, -99.1766475061052 19.5057995793095, -99.17107 19.49175)', 4326)))
    RETURNING id
)
INSERT INTO historico_operacion (ramal_id, velocidad_promedio_kmh, fuente, fecha_registro)
SELECT id, 65.0, 'https://es.wikipedia.org/wiki/Ferrocarril_Suburbano_de_la_Zona_Metropolitana_del_Valle_de_M%C3%A9xico', NOW() FROM r;

WITH r AS (
    INSERT INTO ramals (linea_id, nombre_ramal, ramal_num, estado, shape_gtfs, tam_km, anio_creacion, geom)
    VALUES (102, 'Fortuna-Buenavista', 1, 'Existe', 'B_SH0700L1000_1', 0.0, 2024, ST_Multi(ST_GeomFromText('LINESTRING(-99.17107 19.49175, -99.1666696145034 19.480274187573, -99.16238127768558 19.4691332457011, -99.1617952916446 19.4684078603714, -99.1523742512166 19.4557766482416, -99.1512907606493 19.4524469056536, -99.15162 19.44992)', 4326)))
    RETURNING id
)
INSERT INTO historico_operacion (ramal_id, velocidad_promedio_kmh, fuente, fecha_registro)
SELECT id, 65.0, 'https://es.wikipedia.org/wiki/Ferrocarril_Suburbano_de_la_Zona_Metropolitana_del_Valle_de_M%C3%A9xico', NOW() FROM r;

-- Sentido 0 — REGRESO
WITH r AS (
    INSERT INTO ramals (linea_id, nombre_ramal, ramal_num, estado, shape_gtfs, tam_km, anio_creacion, geom)
    VALUES (102, 'Buenavista-Fortuna', 0, 'Existe', 'B_SH0700L1000_0', 0.0, 2024, ST_Multi(ST_GeomFromText('LINESTRING(-99.15162 19.44992, -99.1512907606493 19.4524469056536, -99.1523742512166 19.4557766482416, -99.1617952916446 19.4684078603714, -99.16238127768558 19.4691332457011, -99.1666696145034 19.480274187573, -99.17107 19.49175)', 4326)))
    RETURNING id
)
INSERT INTO historico_operacion (ramal_id, velocidad_promedio_kmh, fuente, fecha_registro)
SELECT id, 65.0, 'https://es.wikipedia.org/wiki/Ferrocarril_Suburbano_de_la_Zona_Metropolitana_del_Valle_de_M%C3%A9xico', NOW() FROM r;

WITH r AS (
    INSERT INTO ramals (linea_id, nombre_ramal, ramal_num, estado, shape_gtfs, tam_km, anio_creacion, geom)
    VALUES (102, 'Fortuna-Tlalnepantla', 0, 'Existe', 'B_SH0700L1000_0', 0.0, 2024, ST_Multi(ST_GeomFromText('LINESTRING(-99.17107 19.49175, -99.1766475061052 19.5057995793095, -99.1781854192674 19.5120750206638, -99.1784650317494 19.5206575051377, -99.17927989360528 19.5244997232918, -99.1827111045973 19.53205423021389, -99.18413 19.53574)', 4326)))
    RETURNING id
)
INSERT INTO historico_operacion (ramal_id, velocidad_promedio_kmh, fuente, fecha_registro)
SELECT id, 65.0, 'https://es.wikipedia.org/wiki/Ferrocarril_Suburbano_de_la_Zona_Metropolitana_del_Valle_de_M%C3%A9xico', NOW() FROM r;

WITH r AS (
    INSERT INTO ramals (linea_id, nombre_ramal, ramal_num, estado, shape_gtfs, tam_km, anio_creacion, geom)
    VALUES (102, 'Tlalnepantla-San Rafael', 0, 'Existe', 'B_SH0700L1000_0', 0.0, 2024, ST_Multi(ST_GeomFromText('LINESTRING(-99.18413 19.53574, -99.18809518253028 19.5532706857126, -99.18899829377008 19.5551912473416, -99.190125649517 19.5562575661647, -99.1938681176099 19.5594133922809, -99.19496 19.56526)', 4326)))
    RETURNING id
)
INSERT INTO historico_operacion (ramal_id, velocidad_promedio_kmh, fuente, fecha_registro)
SELECT id, 65.0, 'https://es.wikipedia.org/wiki/Ferrocarril_Suburbano_de_la_Zona_Metropolitana_del_Valle_de_M%C3%A9xico', NOW() FROM r;

WITH r AS (
    INSERT INTO ramals (linea_id, nombre_ramal, ramal_num, estado, shape_gtfs, tam_km, anio_creacion, geom)
    VALUES (102, 'San Rafael-Lechería', 0, 'Existe', 'B_SH0700L1000_0', 0.0, 2024, ST_Multi(ST_GeomFromText('LINESTRING(-99.19496 19.56526, -99.19622194431427 19.568890258202103, -99.1975352553779 19.5745679256562, -99.1978979457314 19.5764463274495, -99.19744999397292 19.5785391170087, -99.1956502356694 19.580419876568, -99.1866967085453 19.5905492558055, -99.1860680126328 19.5923433027883, -99.18543979198022 19.594564346013502, -99.18675 19.59921)', 4326)))
    RETURNING id
)
INSERT INTO historico_operacion (ramal_id, velocidad_promedio_kmh, fuente, fecha_registro)
SELECT id, 65.0, 'https://es.wikipedia.org/wiki/Ferrocarril_Suburbano_de_la_Zona_Metropolitana_del_Valle_de_M%C3%A9xico', NOW() FROM r;

WITH r AS (
    INSERT INTO ramals (linea_id, nombre_ramal, ramal_num, estado, shape_gtfs, tam_km, anio_creacion, geom)
    VALUES (102, 'Lechería-Tultitlán', 0, 'Existe', 'B_SH0700L1000_0', 0.0, 2024, ST_Multi(ST_GeomFromText('LINESTRING(-99.18675 19.59921, -99.1864008494341 19.6075014198745, -99.1814238063908 19.629326104029, -99.18039 19.63551)', 4326)))
    RETURNING id
)
INSERT INTO historico_operacion (ramal_id, velocidad_promedio_kmh, fuente, fecha_registro)
SELECT id, 65.0, 'https://es.wikipedia.org/wiki/Ferrocarril_Suburbano_de_la_Zona_Metropolitana_del_Valle_de_M%C3%A9xico', NOW() FROM r;

WITH r AS (
    INSERT INTO ramals (linea_id, nombre_ramal, ramal_num, estado, shape_gtfs, tam_km, anio_creacion, geom)
    VALUES (102, 'Tultitlán-Cuautitlán', 0, 'Existe', 'B_SH0700L1000_0', 0.0, 2024, ST_Multi(ST_GeomFromText('LINESTRING(-99.18039 19.63551, -99.1779727247128 19.646494838975, -99.1768612842288 19.6604587220746, -99.1763 19.6671)', 4326)))
    RETURNING id
)
INSERT INTO historico_operacion (ramal_id, velocidad_promedio_kmh, fuente, fecha_registro)
SELECT id, 65.0, 'https://es.wikipedia.org/wiki/Ferrocarril_Suburbano_de_la_Zona_Metropolitana_del_Valle_de_M%C3%A9xico', NOW() FROM r;

-- ── Paso 2: Eliminar historico_operacion de ramals originales ──
DELETE FROM historico_operacion WHERE id IN (1324, 1323);

-- ── Paso 3: Eliminar los 2 ramals originales (línea completa) ──
DELETE FROM ramals WHERE id IN (224, 225);

-- ── Verificación post-migración (debe mostrar 12 ramals y 12 ho) ──
SELECT COUNT(*) AS ramals_sub FROM ramals r
  JOIN lineas l ON r.linea_id = l.id WHERE l.sistema = 'SUB';

SELECT COUNT(*) AS ho_sub FROM historico_operacion ho
  JOIN ramals r ON ho.ramal_id = r.id
  JOIN lineas l ON r.linea_id = l.id WHERE l.sistema = 'SUB';

COMMIT;
