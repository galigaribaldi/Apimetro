-- =====================================================
-- 05_anillar.sql
-- Sincroniza secuencias SERIAL después del seed.
--
-- pg_dump genera setval() con el valor de la secuencia
-- al momento del dump, no con MAX(id) real. El seed
-- inserta con IDs explícitos sin avanzar las secuencias,
-- dejándolas desfasadas. Cualquier INSERT posterior que
-- dependa de autoincrement choca con un PK existente y
-- ON CONFLICT DO NOTHING lo descarta en silencio.
--
-- Este archivo corre después de 04_seed.sql y antes de
-- 05_apply_anillar.sh, garantizando secuencias correctas
-- para todas las migraciones posteriores.
-- =====================================================

SELECT setval('public.ramals_id_seq',
    COALESCE((SELECT MAX(id) FROM public.ramals), 0) + 1, false);

SELECT setval('public.estacions_id_seq',
    COALESCE((SELECT MAX(id) FROM public.estacions), 0) + 1, false);

SELECT setval('public.lineas_id_seq',
    COALESCE((SELECT MAX(id) FROM public.lineas), 0) + 1, false);

SELECT setval('public.historico_operacion_id_seq',
    COALESCE((SELECT MAX(id) FROM public.historico_operacion), 0) + 1, false);

SELECT setval('public.descripcion_lineas_id_seq',
    COALESCE((SELECT MAX(id) FROM public.descripcion_lineas), 0) + 1, false);

SELECT setval('public.descripcion_estacions_id_seq',
    COALESCE((SELECT MAX(id) FROM public.descripcion_estacions), 0) + 1, false);
