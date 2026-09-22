-- ============================================================
-- DOCUMENTACIÓN: Líneas con datos incompletos o no oficiales
-- ============================================================
-- Archivo : db/init/UPDATE_TROLE_13.sql
-- Autor   : Hernán Galileo Cabrera Garibaldi
-- Fecha   : 2026-04-19
--
-- PROPÓSITO
-- ---------
-- Registra en descripcion_lineas las líneas que carecen de datos
-- oficiales de paradas o cuya fuente no es el GTFS oficial.
--
-- Cubre tres casos:
--
--   1. TROLE Línea 13
--      Sin datos de paradas en la fuente GTFS (stop_times.txt
--      vacío para TR13). El trazo geométrico existe (shape TR13_1,
--      263 vértices, ruta tipo loop). ramals.geom conserva la
--      geometría completa sin segmentación interestación.
--      tipo = 'DATOS_INCOMPLETOS'
--
--   2. MEXIBÚS (todas las líneas, 12 registros)
--      Los datos de paradas y trazos provienen de OSMAN MAPS,
--      no del GTFS oficial de la SEMOVI. num_estacion no está
--      poblado (las estaciones se ordenan por fracción geográfica).
--      tipo = 'FUENTE_NO_OFICIAL'
--
--   3. MEXICABLE (todas las líneas, 4 registros)
--      Misma situación que MEXIBÚS: datos recolectados por
--      OSMAN MAPS, sin fuente GTFS oficial disponible.
--      tipo = 'FUENTE_NO_OFICIAL'
--
-- PRECONDICIÓN
-- ------------
-- descripcion_lineas debe estar vacía o no tener registros para
-- estas líneas (evitar duplicados). Verificar antes de ejecutar:
--
--   SELECT dl.tipo, l.sistema, l.num_comercial
--   FROM descripcion_lineas dl
--   JOIN lineas l ON l.id = dl.linea_base
--   WHERE l.sistema IN ('TROLE','MEXIBÚS','MEXICABLE');
-- ============================================================

BEGIN;

-- ── 1. TROLE Línea 13 ────────────────────────────────────────
INSERT INTO descripcion_lineas (tipo, descripcion, linea_base)
SELECT
    'DATOS_INCOMPLETOS',
    'Línea sin datos oficiales de paradas en la fuente GTFS. ' ||
    'stop_times.txt no contiene registros para TR13. ' ||
    'El trazo geométrico existe (shape TR13_1, 263 vértices, ruta loop). ' ||
    'ramals.geom conserva la geometría completa sin segmentación interestación.',
    l.id
FROM lineas l
WHERE l.sistema = 'TROLE'
  AND l.num_comercial = '13';

-- ── 2. MEXIBÚS — todas las líneas ───────────────────────────
INSERT INTO descripcion_lineas (tipo, descripcion, linea_base)
SELECT
    'FUENTE_NO_OFICIAL',
    'Datos de paradas y trazos recolectados por OSMAN MAPS. ' ||
    'No provienen del GTFS oficial de la SEMOVI. ' ||
    'num_estacion no está poblado; las estaciones se ordenan por fracción geográfica en el trazo.',
    l.id
FROM lineas l
WHERE l.sistema = 'MEXIBÚS';

-- ── 3. MEXICABLE — todas las líneas ─────────────────────────
INSERT INTO descripcion_lineas (tipo, descripcion, linea_base)
SELECT
    'FUENTE_NO_OFICIAL',
    'Datos de paradas y trazos recolectados por OSMAN MAPS. ' ||
    'No provienen del GTFS oficial de la SEMOVI.',
    l.id
FROM lineas l
WHERE l.sistema = 'MEXICABLE';

COMMIT;

-- ============================================================
-- VERIFICACIÓN POST-EJECUCIÓN
-- ============================================================
--
-- SELECT dl.tipo, l.sistema, l.num_comercial, dl.descripcion
-- FROM descripcion_lineas dl
-- JOIN lineas l ON l.id = dl.linea_base
-- ORDER BY l.sistema, l.num_comercial;
--
-- Resultado esperado: 17 registros
--   MEXIBÚS    → 12 filas  (tipo = FUENTE_NO_OFICIAL)
--   MEXICABLE  →  4 filas  (tipo = FUENTE_NO_OFICIAL)
--   TROLE 13   →  1 fila   (tipo = DATOS_INCOMPLETOS)
-- ============================================================
