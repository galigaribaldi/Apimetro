-- =====================================================
-- Consultas de demostración — Extensión Plutarco
-- Apimetro | Issue #45 | 2026-06
--
-- Ejecutar en PgAdmin o psql contra db_apimetro.
-- Requiere: extensión plutarco activada (make plutarco-setup).
-- =====================================================


-- =====================================================
-- 1. VERIFICACIÓN BÁSICA
-- =====================================================

-- Conteo total de registros por tabla
SELECT 'agebs' AS tabla, COUNT(*) AS registros FROM plutarco.agebs
UNION ALL SELECT 'afluencia_linea', COUNT(*) FROM plutarco.afluencia_linea
UNION ALL SELECT 'afluencia_estacion', COUNT(*) FROM plutarco.afluencia_estacion
UNION ALL SELECT 'catalogo_homologacion', COUNT(*) FROM plutarco.catalogo_homologacion
ORDER BY tabla;


-- =====================================================
-- 2. AFLUENCIA POR ESTACIÓN — Consultas analíticas
-- =====================================================

-- 2.1 Resumen por línea: estaciones y afluencia acumulada
SELECT
    l.num_comercial      AS linea,
    l.nombre             AS nombre_linea,
    COUNT(DISTINCT a.estacion_id) AS estaciones,
    SUM(a.afluencia)     AS afluencia_total,
    MIN(a.anio)          AS desde,
    MAX(a.anio)          AS hasta
FROM plutarco.afluencia_estacion a
JOIN public.lineas l ON l.id = a.linea_id
GROUP BY l.num_comercial, l.nombre
ORDER BY l.num_comercial;


-- 2.2 Top 10 estaciones más concurridas (acumulado histórico)
SELECT
    e.nombre             AS estacion,
    l.num_comercial      AS linea,
    SUM(a.afluencia)     AS afluencia_total,
    ROUND(SUM(a.afluencia)::numeric / 1000000, 1) AS millones_viajes
FROM plutarco.afluencia_estacion a
JOIN public.estacions e ON e.id = a.estacion_id
JOIN public.lineas l ON l.id = a.linea_id
GROUP BY e.nombre, l.num_comercial
ORDER BY afluencia_total DESC
LIMIT 10;


-- 2.3 Serie temporal: Pantitlán en 2023-2024 (todas sus líneas)
SELECT
    l.num_comercial AS linea,
    a.anio,
    a.mes_num,
    a.mes,
    a.afluencia,
    ROUND(a.afluencia::numeric / 1000000, 2) AS millones
FROM plutarco.afluencia_estacion a
JOIN public.estacions e ON e.id = a.estacion_id
JOIN public.lineas l ON l.id = a.linea_id
WHERE e.nombre ILIKE '%Pantitlán%'
  AND a.anio BETWEEN 2023 AND 2024
ORDER BY l.num_comercial, a.anio, a.mes_num;


-- 2.4 Estaciones de transbordo (aparecen en múltiples líneas)
SELECT
    e.nombre AS estacion,
    COUNT(DISTINCT a.linea_id) AS num_lineas,
    STRING_AGG(DISTINCT l.num_comercial, ', ' ORDER BY l.num_comercial) AS lineas
FROM plutarco.afluencia_estacion a
JOIN public.estacions e ON e.id = a.estacion_id
JOIN public.lineas l ON l.id = a.linea_id
GROUP BY e.nombre
HAVING COUNT(DISTINCT a.linea_id) > 1
ORDER BY num_lineas DESC, e.nombre;


-- 2.5 Comparativa interanual: marzo 2019 vs marzo 2020 (impacto COVID)
SELECT
    e.nombre AS estacion,
    l.num_comercial AS linea,
    MAX(CASE WHEN a.anio = 2019 THEN a.afluencia END) AS mar_2019,
    MAX(CASE WHEN a.anio = 2020 THEN a.afluencia END) AS mar_2020,
    ROUND(
        (MAX(CASE WHEN a.anio = 2020 THEN a.afluencia END)::numeric /
         NULLIF(MAX(CASE WHEN a.anio = 2019 THEN a.afluencia END), 0) - 1) * 100
    , 1) AS variacion_pct
FROM plutarco.afluencia_estacion a
JOIN public.estacions e ON e.id = a.estacion_id
JOIN public.lineas l ON l.id = a.linea_id
WHERE a.mes_num = 3 AND a.anio IN (2019, 2020)
GROUP BY e.nombre, l.num_comercial
ORDER BY variacion_pct ASC
LIMIT 15;


-- 2.6 Afluencia promedio mensual por línea (últimos 3 años)
SELECT
    l.num_comercial AS linea,
    a.mes_num,
    ROUND(AVG(a.afluencia)) AS promedio_mensual
FROM plutarco.afluencia_estacion a
JOIN public.lineas l ON l.id = a.linea_id
WHERE a.anio >= 2022
GROUP BY l.num_comercial, a.mes_num
ORDER BY l.num_comercial, a.mes_num;


-- =====================================================
-- 3. AFLUENCIA POR LÍNEA — Consultas analíticas
-- =====================================================

-- 3.1 Ranking de sistemas por afluencia total
SELECT
    a.sistema,
    COUNT(DISTINCT a.linea_id) AS lineas,
    SUM(a.afluencia) AS afluencia_total,
    ROUND(SUM(a.afluencia)::numeric / 1000000, 0) AS millones_viajes
FROM plutarco.afluencia_linea a
GROUP BY a.sistema
ORDER BY afluencia_total DESC;


-- 3.2 Evolución mensual del Metro (todas las líneas, último año disponible)
SELECT
    l.num_comercial AS linea,
    a.mes_num,
    a.mes,
    a.afluencia
FROM plutarco.afluencia_linea a
JOIN public.lineas l ON l.id = a.linea_id
WHERE a.sistema = 'METRO'
  AND a.anio = (SELECT MAX(anio) FROM plutarco.afluencia_linea WHERE sistema = 'METRO')
ORDER BY l.num_comercial, a.mes_num;


-- =====================================================
-- 4. AGEBs — Consultas espaciales
-- =====================================================

-- 4.1 Resumen por entidad
SELECT
    cve_ent AS entidad,
    nom_ent AS nombre,
    COUNT(*) AS agebs,
    ROUND(SUM(pobtot)::numeric / 1000, 0) AS poblacion_miles,
    ROUND(AVG(densidad_pob), 0) AS densidad_promedio
FROM plutarco.agebs
GROUP BY cve_ent, nom_ent
ORDER BY cve_ent;


-- 4.2 Top 10 AGEBs más densamente pobladas
SELECT
    cve_ageb,
    nom_mun AS municipio,
    pobtot AS poblacion,
    ROUND(densidad_pob, 0) AS hab_por_km2,
    ROUND(area_km2::numeric, 3) AS area_km2
FROM plutarco.agebs
WHERE densidad_pob IS NOT NULL
ORDER BY densidad_pob DESC
LIMIT 10;


-- 4.3 AGEBs cercanas a una estación del Metro (ejemplo: Bellas Artes, 800m)
SELECT
    ag.cve_ageb,
    ag.nom_mun AS alcaldia,
    ag.pobtot AS poblacion,
    ROUND(ST_Distance(ag.geom::geography, e.geom::geography)) AS distancia_m
FROM plutarco.agebs ag, public.estacions e
WHERE e.nombre = 'Bellas Artes'
  AND e.sistema = 'METRO'
  AND ST_DWithin(ag.geom::geography, e.geom::geography, 800)
ORDER BY distancia_m;


-- =====================================================
-- 5. CONSULTAS CRUZADAS (Afluencia + Geografía)
-- =====================================================

-- 5.1 Demanda por estación + población cercana (proxy de Node Score VFT)
SELECT
    e.nombre AS estacion,
    l.num_comercial AS linea,
    SUM(a.afluencia) AS afluencia_2024,
    (SELECT SUM(ag.pobtot)
     FROM plutarco.agebs ag
     WHERE ST_DWithin(ag.geom::geography, e.geom::geography, 800)
    ) AS poblacion_800m
FROM plutarco.afluencia_estacion a
JOIN public.estacions e ON e.id = a.estacion_id
JOIN public.lineas l ON l.id = a.linea_id
WHERE a.anio = 2024
GROUP BY e.nombre, l.num_comercial, e.geom
ORDER BY afluencia_2024 DESC
LIMIT 20;
