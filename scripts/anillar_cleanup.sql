-- =====================================================
-- Cleanup: Eliminar datos del Anillo Periférico Interior
-- Ejecutar para revertir la carga de cualquier escenario
-- =====================================================

-- Escenario MB
DELETE FROM historico_operacion WHERE linea_id BETWEEN 2071 AND 2074;
DELETE FROM ramals WHERE linea_id BETWEEN 2071 AND 2074;
DELETE FROM estacions WHERE id BETWEEN 31001 AND 31200;
DELETE FROM lineas WHERE id BETWEEN 2071 AND 2074;

-- Escenario METRO
DELETE FROM historico_operacion WHERE linea_id BETWEEN 3071 AND 3074;
DELETE FROM ramals WHERE linea_id BETWEEN 3071 AND 3074;
DELETE FROM estacions WHERE id BETWEEN 32001 AND 32200;
DELETE FROM lineas WHERE id BETWEEN 3071 AND 3074;

-- Verificar limpieza
SELECT 'lineas' AS tabla, count(*) FROM lineas WHERE clasificacion = 'propuesta_periferico'
UNION ALL
SELECT 'estacions', count(*) FROM estacions WHERE id BETWEEN 31001 AND 32200
UNION ALL
SELECT 'ramals', count(*) FROM ramals WHERE linea_id BETWEEN 2071 AND 3074
UNION ALL
SELECT 'historico_operacion', count(*) FROM historico_operacion WHERE linea_id BETWEEN 2071 AND 3074;
