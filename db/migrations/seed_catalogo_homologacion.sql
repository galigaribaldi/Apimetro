-- =====================================================
-- Apimetro — Seed: plutarco.catalogo_homologacion
-- Issue: #39
-- Fecha: 2026-06
-- =====================================================
--
-- PROPÓSITO:
--   Mapea los nombres de línea que aparecen en los CSVs
--   fuente (ETL/Data/Pesos/) hacia linea_id de public.lineas.
--   Permite al ETL de afluencia resolver nombres heterogéneos.
--
-- IDEMPOTENCIA:
--   Todos los INSERTs usan ON CONFLICT DO NOTHING.
--   Seguro de re-ejecutar.
--
-- USO:
--   Ejecutar DESPUÉS de v2.0_afluencia.sql y DESPUÉS de
--   que public.lineas tenga datos (seed.sql cargado).
--
--   PGPASSWORD='<ADMIN_PASS>' psql \
--     -h localhost -p 5433 \
--     -U admin_apimetro -d db_apimetro \
--     -v ON_ERROR_STOP=1 \
--     -f db/migrations/seed_catalogo_homologacion.sql
--
-- NOTAS:
--   - linea_id se resuelve via subquery para portabilidad
--   - Si un nombre_csv no encuentra match, el INSERT se
--     ignora silenciosamente (subquery retorna NULL → FK falla)
--   - Después de ejecutar, verificar filas insertadas vs esperadas
-- =====================================================

BEGIN;

-- =====================================================
-- METRO (STC) — 12 líneas
-- Fuente principal: afluencia_diaria_historica.xlsx
-- Columna: linea_servicio | Organismo: STC
-- =====================================================
INSERT INTO plutarco.catalogo_homologacion (nombre_csv, sistema, linea_id)
SELECT v.nombre_csv, 'METRO', l.id
FROM (VALUES
    ('Línea 1',  '1'),
    ('Linea 1',  '1'),
    ('Línea 2',  '2'),
    ('Linea 2',  '2'),
    ('Línea 3',  '3'),
    ('Linea 3',  '3'),
    ('Línea 4',  '4'),
    ('Linea 4',  '4'),
    ('Línea 5',  '5'),
    ('Linea 5',  '5'),
    ('Línea 6',  '6'),
    ('Linea 6',  '6'),
    ('Línea 7',  '7'),
    ('Linea 7',  '7'),
    ('Línea 8',  '8'),
    ('Linea 8',  '8'),
    ('Línea 9',  '9'),
    ('Linea 9',  '9'),
    ('Línea A',  'A'),
    ('Linea A',  'A'),
    ('Línea B',  'B'),
    ('Linea B',  'B'),
    ('Línea 12', 'L12'),
    ('Linea 12', 'L12'),
    ('L12',      'L12'),
    ('L1',       '1'),
    ('L2',       '2'),
    ('L3',       '3'),
    ('L4',       '4'),
    ('L5',       '5'),
    ('L6',       '6'),
    ('L7',       '7'),
    ('L8',       '8'),
    ('L9',       '9'),
    ('LA',       'A'),
    ('LB',       'B')
) AS v(nombre_csv, num)
JOIN public.lineas l ON l.sistema = 'METRO' AND l.num_comercial = v.num
ON CONFLICT (nombre_csv, sistema) DO NOTHING;


-- =====================================================
-- METROBÚS (MB) — 7 líneas + SL01
-- Fuente principal: afluencia_diaria_historica.xlsx
-- Columna: linea_servicio | Organismo: Metrobús
-- =====================================================
INSERT INTO plutarco.catalogo_homologacion (nombre_csv, sistema, linea_id)
SELECT v.nombre_csv, 'MB', l.id
FROM (VALUES
    ('Línea 1',  '1'),
    ('Linea 1',  '1'),
    ('Línea 2',  '2'),
    ('Linea 2',  '2'),
    ('Línea 3',  '3'),
    ('Linea 3',  '3'),
    ('Línea 4',  '4'),
    ('Linea 4',  '4'),
    ('Línea 5',  '5'),
    ('Linea 5',  '5'),
    ('Línea 6',  '6'),
    ('Linea 6',  '6'),
    ('Línea 7',  '7'),
    ('Linea 7',  '7'),
    ('L1',       '1'),
    ('L2',       '2'),
    ('L3',       '3'),
    ('L4',       '4'),
    ('L5',       '5'),
    ('L6',       '6'),
    ('L7',       '7')
) AS v(nombre_csv, num)
JOIN public.lineas l ON l.sistema = 'MB' AND l.num_comercial = v.num
ON CONFLICT (nombre_csv, sistema) DO NOTHING;

-- MB extensiones (sin línea individual en public.lineas)
-- LT1/LT2 son extensiones temporales sin entrada propia en public.lineas.
-- Se registran con activo=FALSE para documentar su existencia sin que el ETL las procese.
INSERT INTO plutarco.catalogo_homologacion (nombre_csv, sistema, linea_id, activo)
VALUES
    ('LT1 (Atlalilco-Tláhuac)', 'MB', NULL, FALSE),
    ('LT2 (Coyuya-Tláhuac)',    'MB', NULL, FALSE)
ON CONFLICT (nombre_csv, sistema) DO NOTHING;


-- =====================================================
-- CABLEBÚS (CBB) — 3 líneas
-- Fuente: afluencia_desglosada_cb_03_2026.csv
-- Columna: linea
-- Variantes encontradas: "Línea 1", "Linea 1" (con/sin tilde)
-- =====================================================
INSERT INTO plutarco.catalogo_homologacion (nombre_csv, sistema, linea_id)
SELECT v.nombre_csv, 'CBB', l.id
FROM (VALUES
    ('Línea 1', '1'),
    ('Linea 1', '1'),
    ('Línea 2', '2'),
    ('Linea 2', '2'),
    ('Línea 3', '3'),
    ('Linea 3', '3'),
    ('L1 Campos Revolución-Tlalpexco', '1')
) AS v(nombre_csv, num)
JOIN public.lineas l ON l.sistema = 'CBB' AND l.num_comercial = v.num
ON CONFLICT (nombre_csv, sistema) DO NOTHING;


-- =====================================================
-- TREN LIGERO (TL) — 1 línea (sistema completo)
-- Fuente: afluencia_desglosada_tl_03_2026.csv
-- Sin columna de línea — dato a nivel sistema
-- =====================================================
INSERT INTO plutarco.catalogo_homologacion (nombre_csv, sistema, linea_id)
SELECT v.nombre_csv, 'TL', l.id
FROM (VALUES
    ('Tren Ligero'),
    ('TL'),
    ('Línea 1'),
    ('Linea 1'),
    ('Xochimilco-Tasqueña')
) AS v(nombre_csv)
JOIN public.lineas l ON l.sistema = 'TL' AND l.num_comercial = '1'
ON CONFLICT (nombre_csv, sistema) DO NOTHING;


-- =====================================================
-- TROLEBÚS (TROLE) — 13 líneas
-- Fuente: afluencia_desglosada_trolebus_03_2026.csv
-- Columna: linea
-- Variantes encontradas: "Línea N", "linea_ N" (guion bajo + espacio)
-- Incluye variantes Nochebús y Trolebús Elevado
-- =====================================================
INSERT INTO plutarco.catalogo_homologacion (nombre_csv, sistema, linea_id)
SELECT v.nombre_csv, 'TROLE', l.id
FROM (VALUES
    ('Línea 1',    '1'),
    ('Linea 1',    '1'),
    ('linea_ 1',   '1'),
    ('Línea 2',    '2'),
    ('Linea 2',    '2'),
    ('linea_ 2',   '2'),
    ('Línea 3',    '3'),
    ('Linea 3',    '3'),
    ('linea_ 3',   '3'),
    ('Línea 4',    '4'),
    ('Linea 4',    '4'),
    ('linea_ 4',   '4'),
    ('Línea 5',    '5'),
    ('Linea 5',    '5'),
    ('linea_ 5',   '5'),
    ('Línea 6',    '6'),
    ('Linea 6',    '6'),
    ('linea_ 6',   '6'),
    ('Línea 7',    '7'),
    ('Linea 7',    '7'),
    ('linea_ 7',   '7'),
    ('Línea 8',    '8'),
    ('Linea 8',    '8'),
    ('linea_ 8',   '8'),
    ('Línea 9',    '9'),
    ('Linea 9',    '9'),
    ('linea_ 9',   '9'),
    ('Línea 10',   '10'),
    ('Linea 10',   '10'),
    ('linea_ 10',  '10'),
    ('Línea 10 (Trolebús elevado)', '10'),
    ('Línea 11',   '11'),
    ('Linea 11',   '11'),
    ('Línea 12',   '12'),
    ('Linea 12',   '12'),
    ('Línea 13',   '13'),
    ('Linea 13',   '13')
) AS v(nombre_csv, num)
JOIN public.lineas l ON l.sistema = 'TROLE' AND l.num_comercial = v.num
ON CONFLICT (nombre_csv, sistema) DO NOTHING;

-- Variantes Excel histórico (afluencia_diaria_historica.xlsx)
INSERT INTO plutarco.catalogo_homologacion (nombre_csv, sistema, linea_id)
SELECT v.nombre_csv, 'TROLE', l.id
FROM (VALUES
    ('L1 Eje Central',              '1'),
    ('L2 Eje 2 sur',               '2'),
    ('L3 Eje 7 Sur',               '3'),
    ('L4 Pto Aéreo-Rosario',       '4'),
    ('L5 Sn Felipe-Hidalgo',       '5'),
    ('L6 Rosario-Chapultepec',     '6'),
    ('L7 Lomas Estrella-CU',       '7'),
    ('L8 Circuito IPN',            '8'),
    ('L9 Iztacalco-Villa de Cortés', '9'),
    ('Servicio apoyo Metro Línea 12', '10')
) AS v(nombre_csv, num)
JOIN public.lineas l ON l.sistema = 'TROLE' AND l.num_comercial = v.num
ON CONFLICT (nombre_csv, sistema) DO NOTHING;

-- Nochebús — mapea a la misma línea base
INSERT INTO plutarco.catalogo_homologacion (nombre_csv, sistema, linea_id)
SELECT v.nombre_csv, 'TROLE', l.id
FROM (VALUES
    ('Línea 1 Nochebús',  '1'),
    ('linea_ 1_nochebus', '1')
) AS v(nombre_csv, num)
JOIN public.lineas l ON l.sistema = 'TROLE' AND l.num_comercial = v.num
ON CONFLICT (nombre_csv, sistema) DO NOTHING;


-- =====================================================
-- RTP — Servicios (no líneas individuales)
-- Fuente: afluenciartp_desglosado_03_2026.csv
-- Columna: servicio
--
-- NOTA: RTP usa categorías de servicio (Ordinario, Expreso,
-- Ecobús, etc.) en lugar de líneas numeradas. El CSV agrupa
-- afluencia por tipo de servicio, no por ruta.
-- No corresponden a líneas individuales en public.lineas.
-- Se registran con activo=FALSE para documentar su existencia.
-- El ETL excluye RTP del procesamiento (VFT necesita afluencia
-- por línea, no por tipo de servicio).
--
-- Si en el futuro se requiere granularidad por ruta RTP,
-- se necesitará un CSV con desglose por ruta y agregar
-- las rutas RTP a public.lineas.
-- =====================================================
INSERT INTO plutarco.catalogo_homologacion (nombre_csv, sistema, linea_id, activo)
VALUES
    ('Ordinario',            'RTP', NULL, FALSE),
    ('ORDINARIO',            'RTP', NULL, FALSE),
    ('Expreso',              'RTP', NULL, FALSE),
    ('EXPRESO',              'RTP', NULL, FALSE),
    ('Ecobús',               'RTP', NULL, FALSE),
    ('ECOBUS',               'RTP', NULL, FALSE),
    ('Atenea',               'RTP', NULL, FALSE),
    ('ATENEA',               'RTP', NULL, FALSE),
    ('Nochebús',             'RTP', NULL, FALSE),
    ('NOCHEBUS',             'RTP', NULL, FALSE),
    ('S/Metro',              'RTP', NULL, FALSE),
    ('S/METRO',              'RTP', NULL, FALSE),
    ('Expdirecto',           'RTP', NULL, FALSE),
    ('EXPDIRECTO',           'RTP', NULL, FALSE),
    ('Ecoatenea',            'RTP', NULL, FALSE),
    ('Circuito Hospitales',  'RTP', NULL, FALSE),
    ('CIRCUITO HOSPITALES',  'RTP', NULL, FALSE),
    ('Apoyo Metro L1',       'RTP', NULL, FALSE),
    ('Apoyo concesionado',   'RTP', NULL, FALSE),
    ('Apoyo Concesionado',   'RTP', NULL, FALSE),
    ('APOYO A CONCESIONADO', 'RTP', NULL, FALSE),
    ('Servicios Temporales', 'RTP', NULL, FALSE),
    ('SERVICIOS TEMPORALES', 'RTP', NULL, FALSE),
    ('Nocturno',             'RTP', NULL, FALSE),
    ('Eco Atenea',           'RTP', NULL, FALSE),
    ('Expreso Directo',      'RTP', NULL, FALSE),
    ('SEFI Metro',           'RTP', NULL, FALSE),
    ('SEFI Metro Línea 12',  'RTP', NULL, FALSE),
    ('Temporal Peñón-Panteón San Isidro-Metro Camarones', 'RTP', NULL, FALSE),
    ('Temporal Zaragoza-Tacuba',       'RTP', NULL, FALSE),
    ('Temporal Tlalpan-Xochimilco',    'RTP', NULL, FALSE),
    ('Temporal Viveros-Tetelpan',      'RTP', NULL, FALSE),
    ('Circuito Hospitales $8.00',      'RTP', NULL, FALSE)
ON CONFLICT (nombre_csv, sistema) DO NOTHING;

COMMIT;

-- =====================================================
-- Verificación post-seed:
--
--   SELECT sistema, COUNT(*) AS variantes
--   FROM plutarco.catalogo_homologacion
--   GROUP BY sistema
--   ORDER BY sistema;
--
-- Resultado esperado (aproximado):
--   CBB    ~7   (activas)
--   MB     ~21  (activas) + 2 (inactivas: LT1/LT2)
--   METRO  ~36  (activas, incluye variantes L12→num_comercial 'L12')
--   RTP    ~33  (todas inactivas — servicios, no líneas)
--   TL     ~5   (activas)
--   TROLE  ~47  (activas)
--
-- Nota: TROLE Línea 11 no existe en public.lineas — datos descartados.
-- RTP excluido de ETL: VFT requiere afluencia por línea, no por servicio.
-- =====================================================
