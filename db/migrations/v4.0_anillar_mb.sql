-- =====================================================
-- Apimetro — Migración Anillo Periférico Interior
-- Escenario: MB (BRT)
-- Sistema: MB
-- Fecha: 2026-09-16
-- Clasificación: propuesta_periferico
-- 
-- Este script es idempotente (ON CONFLICT DO NOTHING).
-- Para revertir: ejecutar scripts/anillar_cleanup.sql
-- =====================================================

-- =====================================================
-- 1. LÍNEAS (4 líneas del Anillo Periférico Interior)
-- =====================================================
INSERT INTO lineas (id, nombre, sistema, anio_inauguracion, color_en, color_esp,
    tam_km, existe, clasificacion, num_comercial, jerarquia_transporte,
    derecho_de_via, capacidad_vehiculo)
VALUES (2071, 'Periférico Interior Sur', 'MB', 2026,
    'orange', 'NARANJA', 0, false, 'propuesta_periferico',
    'AP71', 'masivo_mediano',
    'confinado', 160)
ON CONFLICT (id) DO NOTHING;

INSERT INTO lineas (id, nombre, sistema, anio_inauguracion, color_en, color_esp,
    tam_km, existe, clasificacion, num_comercial, jerarquia_transporte,
    derecho_de_via, capacidad_vehiculo)
VALUES (2072, 'Periférico Interior Poniente', 'MB', 2026,
    'orange', 'NARANJA', 0, false, 'propuesta_periferico',
    'AP72', 'masivo_mediano',
    'confinado', 160)
ON CONFLICT (id) DO NOTHING;

INSERT INTO lineas (id, nombre, sistema, anio_inauguracion, color_en, color_esp,
    tam_km, existe, clasificacion, num_comercial, jerarquia_transporte,
    derecho_de_via, capacidad_vehiculo)
VALUES (2073, 'Periférico Interior Norte', 'MB', 2026,
    'orange', 'NARANJA', 0, false, 'propuesta_periferico',
    'AP73', 'masivo_mediano',
    'confinado', 160)
ON CONFLICT (id) DO NOTHING;

INSERT INTO lineas (id, nombre, sistema, anio_inauguracion, color_en, color_esp,
    tam_km, existe, clasificacion, num_comercial, jerarquia_transporte,
    derecho_de_via, capacidad_vehiculo)
VALUES (2074, 'Periférico Interior Oriente', 'MB', 2026,
    'orange', 'NARANJA', 0, false, 'propuesta_periferico',
    'AP74', 'masivo_mediano',
    'confinado', 160)
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- 2. ESTACIONES (con geometría POINT PostGIS)
-- =====================================================
INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31001, 'Periférico Oriente/Tláhuac', 'APMB7101', 'Terminal / Transbordo', 'Iztapalapa', '2026',
    'CDMX', -99.0745175260824, 19.3176186017939, 2071, 1,
    31001, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.0745175260824, 19.3176186017939), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31002, 'Estrella del Sur', 'APMB7102', 'Intermedia', 'Iztapalapa', '2026',
    'CDMX', -99.08, 19.31, 2071, 2,
    31002, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.08, 19.31), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31003, 'Culhuacán', 'APMB7103', 'Intermedia', 'Iztapalapa', '2026',
    'CDMX', -99.0845, 19.304, 2071, 3,
    31003, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.0845, 19.304), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31004, 'Atlalilco/Periférico', 'APMB7104', 'Transbordo', 'Iztapalapa', '2026',
    'CDMX', -99.087, 19.301, 2071, 4,
    31004, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.087, 19.301), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31005, 'Canal de Chalco/Periférico', 'APMB7105', 'Intermedia', 'Tláhuac', '2026',
    'CDMX', -99.09, 19.2995, 2071, 5,
    31005, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.09, 19.2995), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31006, 'Cuemanco', 'APMB7106', 'Intermedia', 'Xochimilco', '2026',
    'CDMX', -99.0942407817674, 19.2984866689764, 2071, 6,
    31006, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.0942407817674, 19.2984866689764), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31007, 'Canal Nacional', 'APMB7107', 'Intermedia', 'Xochimilco', '2026',
    'CDMX', -99.1022150696128, 19.2951373900851, 2071, 7,
    31007, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.1022150696128, 19.2951373900851), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31008, 'Muyuguarda/Cafetales', 'APMB7108', 'Transbordo', 'Xochimilco', '2026',
    'CDMX', -99.1151871930735, 19.2896182983505, 2071, 8,
    31008, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.1151871930735, 19.2896182983505), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31009, 'Vaqueritos', 'APMB7109', 'Transbordo', 'Xochimilco', '2026',
    'CDMX', -99.1263201882756, 19.2848434038385, 2071, 9,
    31009, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.1263201882756, 19.2848434038385), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31010, 'Coapa', 'APMB7110', 'Intermedia', 'Tlalpan', '2026',
    'CDMX', -99.1315359290786, 19.2837426599594, 2071, 10,
    31010, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.1315359290786, 19.2837426599594), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31011, 'Tepepan', 'APMB7111', 'Intermedia', 'Tlalpan', '2026',
    'CDMX', -99.1413095240045, 19.2826902381638, 2071, 11,
    31011, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.1413095240045, 19.2826902381638), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31012, 'ESCA', 'APMB7112', 'Intermedia', 'Tlalpan', '2026',
    'CDMX', -99.1471534331923, 19.2855171865218, 2071, 12,
    31012, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.1471534331923, 19.2855171865218), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31013, 'Zona de Hospitales', 'APMB7113', 'Intermedia', 'Tlalpan', '2026',
    'CDMX', -99.1520826881746, 19.2904007344833, 2071, 13,
    31013, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.1520826881746, 19.2904007344833), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31014, 'Huipulco', 'APMB7114', 'Intermedia', 'Tlalpan', '2026',
    'CDMX', -99.154638074917, 19.2947326036117, 2071, 14,
    31014, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.154638074917, 19.2947326036117), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31015, 'Imán/Circuito Azteca', 'APMB7115', 'Intermedia', 'Tlalpan', '2026',
    'CDMX', -99.1605958187857, 19.3010375800792, 2071, 15,
    31015, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.1605958187857, 19.3010375800792), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31016, 'Gran Sur', 'APMB7116', 'Intermedia', 'Tlalpan', '2026',
    'CDMX', -99.165564430135, 19.3021048026286, 2071, 16,
    31016, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.165564430135, 19.3021048026286), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31017, 'Santa Ursula', 'APMB7117', 'Intermedia', 'Coyoacán', '2026',
    'CDMX', -99.1728062297974, 19.3030265199362, 2071, 17,
    31017, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.1728062297974, 19.3030265199362), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31018, 'Cuicuilco', 'APMB7118', 'Intermedia', 'Tlalpan', '2026',
    'CDMX', -99.1814065330579, 19.3031746140771, 2071, 18,
    31018, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.1814065330579, 19.3031746140771), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31019, 'Periférico Sur', 'APMB7119', 'Transbordo', 'Coyoacán', '2026',
    'CDMX', -99.1858597527883, 19.3031599255714, 2071, 19,
    31019, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.1858597527883, 19.3031599255714), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31020, 'Jardines del Pedregal', 'APMB7120', 'Intermedia', 'Coyoacán', '2026',
    'CDMX', -99.1997557764832, 19.304247670836, 2071, 20,
    31020, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.1997557764832, 19.304247670836), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31021, 'Ajusco', 'APMB7121', 'Transbordo', 'Coyoacán', '2026',
    'CDMX', -99.204757323956, 19.3058181987807, 2071, 21,
    31021, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.204757323956, 19.3058181987807), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31022, 'Santa Teresa', 'APMB7122', 'Intermedia', 'Álvaro Obregón', '2026',
    'CDMX', -99.2158309051932, 19.3075696512559, 2071, 22,
    31022, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.2158309051932, 19.3075696512559), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31023, 'Ángeles', 'APMB7123', 'Intermedia', 'La Magdalena Contreras', '2026',
    'CDMX', -99.2199193504131, 19.3129905724798, 2071, 23,
    31023, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.2199193504131, 19.3129905724798), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31024, 'Suiza', 'APMB7124', 'Intermedia', 'La Magdalena Contreras', '2026',
    'CDMX', -99.2216738353594, 19.3186553545115, 2071, 24,
    31024, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.2216738353594, 19.3186553545115), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31025, 'Luis Cabrera', 'APMB7125', 'Terminal / Transbordo', 'La Magdalena Contreras', '2026',
    'CDMX', -99.220328643837, 19.320925949733, 2071, 25,
    31025, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.220328643837, 19.320925949733), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31026, 'Luis Cabrera', 'APMB7201', 'Terminal / Transbordo', 'La Magdalena Contreras', '2026',
    'CDMX', -99.220328643837, 19.320925949733, 2072, 1,
    31026, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.220328643837, 19.320925949733), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31027, 'San Antonio Elevado', 'APMB7202', 'Intermedia', 'La Magdalena Contreras', '2026',
    'CDMX', -99.2156603800189, 19.324062314384, 2072, 2,
    31027, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.2156603800189, 19.324062314384), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31028, 'Tarasquillo', 'APMB7203', 'Intermedia', 'Álvaro Obregón', '2026',
    'CDMX', -99.2120483506634, 19.3286106861771, 2072, 3,
    31028, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.2120483506634, 19.3286106861771), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31029, 'Glorieta Monumental', 'APMB7204', 'Intermedia', 'Álvaro Obregón', '2026',
    'CDMX', -99.2109659153388, 19.3306707865798, 2072, 4,
    31029, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.2109659153388, 19.3306707865798), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31030, 'Parque el Batán', 'APMB7205', 'Intermedia', 'Álvaro Obregón', '2026',
    'CDMX', -99.2089943081942, 19.3342970580488, 2072, 5,
    31030, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.2089943081942, 19.3342970580488), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31031, 'Toluca', 'APMB7206', 'Transbordo', 'Álvaro Obregón', '2026',
    'CDMX', -99.2032322288589, 19.3408894521725, 2072, 6,
    31031, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.2032322288589, 19.3408894521725), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31032, 'Desierto de los Leones', 'APMB7207', 'Intermedia', 'Álvaro Obregón', '2026',
    'CDMX', -99.2020378704102, 19.3479263629079, 2072, 7,
    31032, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.2020378704102, 19.3479263629079), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31033, 'Rómulo O''Farril', 'APMB7208', 'Intermedia', 'Álvaro Obregón', '2026',
    'CDMX', -99.1988823295185, 19.3557316805212, 2072, 8,
    31033, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.1988823295185, 19.3557316805212), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31034, 'Barranca del Muerto/Periférico', 'APMB7209', 'Transbordo', 'Álvaro Obregón', '2026',
    'CDMX', -99.1912054597844, 19.3617955262867, 2072, 9,
    31034, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.1912054597844, 19.3617955262867), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31035, 'Prepa 8', 'APMB7210', 'Intermedia', 'Álvaro Obregón', '2026',
    'CDMX', -99.1911488730648, 19.366922941138, 2072, 10,
    31035, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.1911488730648, 19.366922941138), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31036, 'Rosa Trepadora', 'APMB7211', 'Intermedia', 'Álvaro Obregón', '2026',
    'CDMX', -99.193938817374, 19.3721026926363, 2072, 11,
    31036, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.193938817374, 19.3721026926363), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31037, 'Celini', 'APMB7212', 'Intermedia', 'Álvaro Obregón', '2026',
    'CDMX', -99.1915218752405, 19.3762729468749, 2072, 12,
    31037, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.1915218752405, 19.3762729468749), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31038, 'Distribuidor Vial San Antonio', 'APMB7213', 'Intermedia', 'Álvaro Obregón', '2026',
    'CDMX', -99.1912526191116, 19.3847724156345, 2072, 13,
    31038, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.1912526191116, 19.3847724156345), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31039, 'San Pedro de los Pinos/Periférico', 'APMB7214', 'Transbordo', 'Benito Juárez', '2026',
    'CDMX', -99.188913461022, 19.3909745202463, 2072, 14,
    31039, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.188913461022, 19.3909745202463), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31040, '11 de Abril', 'APMB7215', 'Intermedia', 'Benito Juárez', '2026',
    'CDMX', -99.1887382399895, 19.3955383249044, 2072, 15,
    31040, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.1887382399895, 19.3955383249044), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31041, 'Miguel Alemán Valdés', 'APMB7216', 'Intermedia', 'Miguel Hidalgo', '2026',
    'CDMX', -99.1917529384344, 19.4001935073707, 2072, 16,
    31041, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.1917529384344, 19.4001935073707), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31042, 'Parque Lira', 'APMB7217', 'Intermedia', 'Miguel Hidalgo', '2026',
    'CDMX', -99.1918864435316, 19.4064246330255, 2072, 17,
    31042, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.1918864435316, 19.4064246330255), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31043, 'Constituyentes/Periférico', 'APMB7218', 'Intermedia', 'Miguel Hidalgo', '2026',
    'CDMX', -99.1941158560232, 19.4112098768217, 2072, 18,
    31043, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.1941158560232, 19.4112098768217), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31044, 'Los Pinos', 'APMB7219', 'Intermedia', 'Miguel Hidalgo', '2026',
    'CDMX', -99.1948212702859, 19.4179379699072, 2072, 19,
    31044, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.1948212702859, 19.4179379699072), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31045, 'Alencastre', 'APMB7220', 'Intermedia', 'Miguel Hidalgo', '2026',
    'CDMX', -99.1990471598163, 19.4227045760294, 2072, 20,
    31045, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.1990471598163, 19.4227045760294), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31046, 'Paseo de la Reforma', 'APMB7221', 'Intermedia', 'Miguel Hidalgo', '2026',
    'CDMX', -99.2033829224792, 19.427271778236, 2072, 21,
    31046, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.2033829224792, 19.427271778236), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31047, 'Presidente Masaryk', 'APMB7222', 'Intermedia', 'Miguel Hidalgo', '2026',
    'CDMX', -99.2080967842068, 19.4320351650801, 2072, 22,
    31047, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.2080967842068, 19.4320351650801), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31048, 'Homero', 'APMB7223', 'Intermedia', 'Miguel Hidalgo', '2026',
    'CDMX', -99.2129461326464, 19.4367463974964, 2072, 23,
    31048, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.2129461326464, 19.4367463974964), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31049, 'Ejército Nacional', 'APMB7224', 'Intermedia', 'Miguel Hidalgo', '2026',
    'CDMX', -99.214626690685, 19.4392638928012, 2072, 24,
    31049, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.214626690685, 19.4392638928012), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31050, 'Hipódromo las Américas', 'APMB7225', 'Intermedia', 'Miguel Hidalgo', '2026',
    'CDMX', -99.216389674011, 19.4423772420843, 2072, 25,
    31050, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.216389674011, 19.4423772420843), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31051, 'Cuatro Caminos/Periférico', 'APMB7226', 'Transbordo', 'Naucalpan de Juárez', '2026',
    'EDOMEX', -99.2205876390333, 19.4587801108788, 2072, 26,
    31051, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.2205876390333, 19.4587801108788), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31052, 'Las Torres', 'APMB7227', 'Intermedia', 'Naucalpan de Juárez', '2026',
    'EDOMEX', -99.2245013622917, 19.4660189895512, 2072, 27,
    31052, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.2245013622917, 19.4660189895512), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31053, 'Naucalpan', 'APMB7228', 'Intermedia', 'Naucalpan de Juárez', '2026',
    'EDOMEX', -99.2285223588608, 19.47375676818, 2072, 28,
    31053, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.2285223588608, 19.47375676818), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31054, 'Gustavo Baz Prada', 'APMB7229', 'Intermedia', 'Naucalpan de Juárez', '2026',
    'EDOMEX', -99.2319348869996, 19.4790829347871, 2072, 29,
    31054, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.2319348869996, 19.4790829347871), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31055, 'Lomas Verdes', 'APMB7230', 'Intermedia', 'Naucalpan de Juárez', '2026',
    'EDOMEX', -99.2350808843679, 19.4861748591816, 2072, 30,
    31055, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.2350808843679, 19.4861748591816), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31056, 'Parque Naucalli', 'APMB7231', 'Terminal / Transbordo', 'Naucalpan de Juárez', '2026',
    'EDOMEX', -99.2372188516262, 19.4942303629856, 2072, 31,
    31056, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.2372188516262, 19.4942303629856), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31057, 'Parque Naucalli', 'APMB7301', 'Terminal / Transbordo', 'Naucalpan de Juárez', '2026',
    'EDOMEX', -99.2372188516262, 19.4942303629856, 2073, 1,
    31057, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.2372188516262, 19.4942303629856), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31058, 'Torres de Satélite', 'APMB7302', 'Intermedia', 'Naucalpan de Juárez', '2026',
    'EDOMEX', -99.237, 19.502, 2073, 2,
    31058, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.237, 19.502), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31059, 'Ciudad Satélite', 'APMB7303', 'Intermedia', 'Naucalpan de Juárez', '2026',
    'EDOMEX', -99.2368132396803, 19.5092138203163, 2073, 3,
    31059, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.2368132396803, 19.5092138203163), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31060, 'Circunvalación', 'APMB7304', 'Intermedia', 'Naucalpan de Juárez', '2026',
    'EDOMEX', -99.2306362052263, 19.5193013624258, 2073, 4,
    31060, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.2306362052263, 19.5193013624258), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31061, 'Viveros de Atizapán', 'APMB7305', 'Intermedia', 'Tlalnepantla de Baz', '2026',
    'EDOMEX', -99.2185048168838, 19.5185963862678, 2073, 5,
    31061, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.2185048168838, 19.5185963862678), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31062, 'Presidente Juárez', 'APMB7306', 'Intermedia', 'Tlalnepantla de Baz', '2026',
    'EDOMEX', -99.2117073099832, 19.5168414273159, 2073, 6,
    31062, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.2117073099832, 19.5168414273159), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31063, 'Tlalnepantla', 'APMB7307', 'Intermedia', 'Tlalnepantla de Baz', '2026',
    'EDOMEX', -99.1964973796254, 19.5170094114134, 2073, 7,
    31063, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.1964973796254, 19.5170094114134), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31064, 'Av de las Granjas', 'APMB7308', 'Intermedia', 'Tlalnepantla de Baz', '2026',
    'EDOMEX', -99.1793753322663, 19.5116041682883, 2073, 8,
    31064, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.1793753322663, 19.5116041682883), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31065, 'El Heraldo', 'APMB7309', 'Intermedia', 'Tlalnepantla de Baz', '2026',
    'EDOMEX', -99.1729985503897, 19.5145114374118, 2073, 9,
    31065, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.1729985503897, 19.5145114374118), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31066, 'Vaso Regulador de Carretas', 'APMB7310', 'Intermedia', 'Tlalnepantla de Baz', '2026',
    'EDOMEX', -99.1655936278391, 19.5124915987051, 2073, 10,
    31066, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.1655936278391, 19.5124915987051), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31067, 'Progreso Nacional', 'APMB7311', 'Intermedia', 'Tlalnepantla de Baz', '2026',
    'EDOMEX', -99.1603951642349, 19.512747482633, 2073, 11,
    31067, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.1603951642349, 19.512747482633), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31068, 'Fábricas/Periférico', 'APMB7312', 'Intermedia', 'Tlalnepantla de Baz', '2026',
    'EDOMEX', -99.154068179484, 19.5146094622948, 2073, 12,
    31068, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.154068179484, 19.5146094622948), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31069, 'Río San Joaquín', 'APMB7313', 'Intermedia', 'Azcapotzalco', '2026',
    'CDMX', -99.1430542558633, 19.5180624295389, 2073, 13,
    31069, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.1430542558633, 19.5180624295389), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31070, 'Acueducto', 'APMB7314', 'Intermedia', 'Gustavo A. Madero', '2026',
    'CDMX', -99.1345326557674, 19.5179557253226, 2073, 14,
    31070, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.1345326557674, 19.5179557253226), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31071, 'La Presa', 'APMB7315', 'Intermedia', 'Gustavo A. Madero', '2026',
    'CDMX', -99.1242526088899, 19.5191546977744, 2073, 15,
    31071, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.1242526088899, 19.5191546977744), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31072, 'Hermilo Mena', 'APMB7316', 'Transbordo', 'Gustavo A. Madero', '2026',
    'CDMX', -99.114145246139, 19.5214580487031, 2073, 16,
    31072, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.114145246139, 19.5214580487031), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31073, 'Constituyentes de 1857', 'APMB7317', 'Intermedia', 'Gustavo A. Madero', '2026',
    'CDMX', -99.1012458364103, 19.5147915769313, 2073, 17,
    31073, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.1012458364103, 19.5147915769313), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31074, 'Río de los Remedios MB/Periférico', 'APMB7318', 'Transbordo', 'Ecatepec de Morelos', '2026',
    'EDOMEX', -99.0859313881947, 19.5071286247817, 2073, 18,
    31074, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.0859313881947, 19.5071286247817), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31075, 'Gran Canal de Desagüe', 'APMB7319', 'Intermedia', 'Ecatepec de Morelos', '2026',
    'EDOMEX', -99.0779649889604, 19.5038193655209, 2073, 19,
    31075, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.0779649889604, 19.5038193655209), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31076, 'Parque Orizaba', 'APMB7320', 'Intermedia', 'Ecatepec de Morelos', '2026',
    'EDOMEX', -99.0642759104053, 19.4982680721875, 2073, 20,
    31076, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.0642759104053, 19.4982680721875), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31077, 'Valle de Santiago', 'APMB7321', 'Intermedia', 'Ecatepec de Morelos', '2026',
    'EDOMEX', -99.053966727543, 19.4938637992146, 2073, 21,
    31077, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.053966727543, 19.4938637992146), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31078, 'Río de los Remedios Metro/Periférico', 'APMB7322', 'Transbordo', 'Ecatepec de Morelos', '2026',
    'EDOMEX', -99.0466020294544, 19.4911807713892, 2073, 22,
    31078, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.0466020294544, 19.4911807713892), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31079, 'Valle de San Lorenzo', 'APMB7323', 'Intermedia', 'Nezahualcóyotl', '2026',
    'EDOMEX', -99.0388115288086, 19.4873294113852, 2073, 23,
    31079, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.0388115288086, 19.4873294113852), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31080, 'Colonias de Aragón', 'APMB7324', 'Terminal / Transbordo', 'Nezahualcóyotl', '2026',
    'EDOMEX', -99.0316621504572, 19.4793309527282, 2073, 24,
    31080, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.0316621504572, 19.4793309527282), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31081, 'Colonias de Aragón', 'APMB7401', 'Terminal / Transbordo', 'Nezahualcóyotl', '2026',
    'EDOMEX', -99.0316621504572, 19.4793309527282, 2074, 1,
    31081, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.0316621504572, 19.4793309527282), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31082, 'FES Aragón', 'APMB7402', 'Transbordo', 'Nezahualcóyotl', '2026',
    'EDOMEX', -99.0356457017992, 19.4730405471889, 2074, 2,
    31082, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.0356457017992, 19.4730405471889), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31083, 'Pirules', 'APMB7403', 'Intermedia', 'Nezahualcóyotl', '2026',
    'EDOMEX', -99.0373166530742, 19.4666123777387, 2074, 3,
    31083, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.0373166530742, 19.4666123777387), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31084, 'Peñón Texcoco/Periférico', 'APMB7404', 'Intermedia', 'Nezahualcóyotl', '2026',
    'EDOMEX', -99.0383847433583, 19.4571699263318, 2074, 4,
    31084, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.0383847433583, 19.4571699263318), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31085, 'Alameda Oriente', 'APMB7405', 'Intermedia', 'Venustiano Carranza', '2026',
    'CDMX', -99.0522269700144, 19.4297107907808, 2074, 5,
    31085, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.0522269700144, 19.4297107907808), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31086, 'Ciudad Nezahualcóyotl', 'APMB7406', 'Intermedia', 'Nezahualcóyotl', '2026',
    'EDOMEX', -99.0554993142479, 19.4223645933323, 2074, 6,
    31086, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.0554993142479, 19.4223645933323), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31087, 'Av Pantitlán', 'APMB7407', 'Intermedia', 'Iztacalco', '2026',
    'CDMX', -99.0567857536576, 19.4119961559513, 2074, 7,
    31087, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.0567857536576, 19.4119961559513), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31088, 'Valesquillo', 'APMB7408', 'Intermedia', 'Iztapalapa', '2026',
    'CDMX', -99.0575875865377, 19.4046000958895, 2074, 8,
    31088, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.0575875865377, 19.4046000958895), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31089, 'Canal de San Juan/Periférico', 'APMB7409', 'Transbordo', 'Iztapalapa', '2026',
    'CDMX', -99.0579318907728, 19.3983599751904, 2074, 9,
    31089, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.0579318907728, 19.3983599751904), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31090, 'Constitución de Apatzingán', 'APMB7410', 'Intermedia', 'Iztapalapa', '2026',
    'CDMX', -99.0599752608567, 19.3896460289669, 2074, 10,
    31090, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.0599752608567, 19.3896460289669), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31091, 'Canal de Tezontle', 'APMB7411', 'Intermedia', 'Iztapalapa', '2026',
    'CDMX', -99.0606372559403, 19.3820692425108, 2074, 11,
    31091, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.0606372559403, 19.3820692425108), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31092, 'Leyes de Reforma', 'APMB7412', 'Intermedia', 'Iztapalapa', '2026',
    'CDMX', -99.0601250788034, 19.3767183843786, 2074, 12,
    31092, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.0601250788034, 19.3767183843786), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31093, 'Luis Méndez', 'APMB7413', 'Intermedia', 'Iztapalapa', '2026',
    'CDMX', -99.0574385618996, 19.3633810991953, 2074, 13,
    31093, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.0574385618996, 19.3633810991953), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31094, 'Revolución Social', 'APMB7414', 'Intermedia', 'Iztapalapa', '2026',
    'CDMX', -99.0596560450222, 19.3535104905475, 2074, 14,
    31094, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.0596560450222, 19.3535104905475), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31095, 'Constitución de 1917/Periférico', 'APMB7415', 'Transbordo', 'Iztapalapa', '2026',
    'CDMX', -99.0626549863211, 19.3450857602017, 2074, 15,
    31095, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.0626549863211, 19.3450857602017), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31096, '5 de Mayo', 'APMB7416', 'Intermedia', 'Iztapalapa', '2026',
    'CDMX', -99.0642540491586, 19.3391428958489, 2074, 16,
    31096, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.0642540491586, 19.3391428958489), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31097, 'Iztapalapa', 'APMB7417', 'Transbordo', 'Iztapalapa', '2026',
    'CDMX', -99.067599524439, 19.3283774337608, 2074, 17,
    31097, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.067599524439, 19.3283774337608), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (31098, 'Periférico Oriente/Tláhuac', 'APMB7418', 'Terminal / Transbordo', 'Iztapalapa', '2026',
    'CDMX', -99.0745175260824, 19.3176186017939, 2074, 18,
    31098, 'MB', false,
    ST_SetSRID(ST_MakePoint(-99.0745175260824, 19.3176186017939), 4326))
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- 3. RAMALES (geometría MultiLineString — ida y regreso)
--    Trazo: ST_MakeLine entre estaciones consecutivas
--    Cada línea tiene 2 ramales: sentido 1 (ida) y 0 (regreso)
--
--    DELETE previo garantiza idempotencia: ramals no tiene
--    constraint única en (linea_id, ramal_num), así que
--    ON CONFLICT DO NOTHING nunca dispara y re-ejecuciones
--    sin DELETE acumularían duplicados.
-- =====================================================
DELETE FROM historico_operacion WHERE linea_id BETWEEN 2071 AND 2074;
DELETE FROM ramals               WHERE linea_id BETWEEN 2071 AND 2074;

INSERT INTO ramals (linea_id, nombre_ramal, estado, ramal_num, geom)
VALUES (2071, 'Periférico Interior Sur - IDA', 'Propuesta académica', 1,
    ST_Multi(ST_MakeLine(ARRAY[ST_SetSRID(ST_MakePoint(-99.0745175260824, 19.3176186017939), 4326), ST_SetSRID(ST_MakePoint(-99.08, 19.31), 4326), ST_SetSRID(ST_MakePoint(-99.0845, 19.304), 4326), ST_SetSRID(ST_MakePoint(-99.087, 19.301), 4326), ST_SetSRID(ST_MakePoint(-99.09, 19.2995), 4326), ST_SetSRID(ST_MakePoint(-99.0942407817674, 19.2984866689764), 4326), ST_SetSRID(ST_MakePoint(-99.1022150696128, 19.2951373900851), 4326), ST_SetSRID(ST_MakePoint(-99.1151871930735, 19.2896182983505), 4326), ST_SetSRID(ST_MakePoint(-99.1263201882756, 19.2848434038385), 4326), ST_SetSRID(ST_MakePoint(-99.1315359290786, 19.2837426599594), 4326), ST_SetSRID(ST_MakePoint(-99.1413095240045, 19.2826902381638), 4326), ST_SetSRID(ST_MakePoint(-99.1471534331923, 19.2855171865218), 4326), ST_SetSRID(ST_MakePoint(-99.1520826881746, 19.2904007344833), 4326), ST_SetSRID(ST_MakePoint(-99.154638074917, 19.2947326036117), 4326), ST_SetSRID(ST_MakePoint(-99.1605958187857, 19.3010375800792), 4326), ST_SetSRID(ST_MakePoint(-99.165564430135, 19.3021048026286), 4326), ST_SetSRID(ST_MakePoint(-99.1728062297974, 19.3030265199362), 4326), ST_SetSRID(ST_MakePoint(-99.1814065330579, 19.3031746140771), 4326), ST_SetSRID(ST_MakePoint(-99.1858597527883, 19.3031599255714), 4326), ST_SetSRID(ST_MakePoint(-99.1997557764832, 19.304247670836), 4326), ST_SetSRID(ST_MakePoint(-99.204757323956, 19.3058181987807), 4326), ST_SetSRID(ST_MakePoint(-99.2158309051932, 19.3075696512559), 4326), ST_SetSRID(ST_MakePoint(-99.2199193504131, 19.3129905724798), 4326), ST_SetSRID(ST_MakePoint(-99.2216738353594, 19.3186553545115), 4326), ST_SetSRID(ST_MakePoint(-99.220328643837, 19.320925949733), 4326)])))
ON CONFLICT DO NOTHING;

INSERT INTO ramals (linea_id, nombre_ramal, estado, ramal_num, geom)
VALUES (2071, 'Periférico Interior Sur - REGRESO', 'Propuesta académica', 0,
    ST_Multi(ST_MakeLine(ARRAY[ST_SetSRID(ST_MakePoint(-99.220328643837, 19.320925949733), 4326), ST_SetSRID(ST_MakePoint(-99.2216738353594, 19.3186553545115), 4326), ST_SetSRID(ST_MakePoint(-99.2199193504131, 19.3129905724798), 4326), ST_SetSRID(ST_MakePoint(-99.2158309051932, 19.3075696512559), 4326), ST_SetSRID(ST_MakePoint(-99.204757323956, 19.3058181987807), 4326), ST_SetSRID(ST_MakePoint(-99.1997557764832, 19.304247670836), 4326), ST_SetSRID(ST_MakePoint(-99.1858597527883, 19.3031599255714), 4326), ST_SetSRID(ST_MakePoint(-99.1814065330579, 19.3031746140771), 4326), ST_SetSRID(ST_MakePoint(-99.1728062297974, 19.3030265199362), 4326), ST_SetSRID(ST_MakePoint(-99.165564430135, 19.3021048026286), 4326), ST_SetSRID(ST_MakePoint(-99.1605958187857, 19.3010375800792), 4326), ST_SetSRID(ST_MakePoint(-99.154638074917, 19.2947326036117), 4326), ST_SetSRID(ST_MakePoint(-99.1520826881746, 19.2904007344833), 4326), ST_SetSRID(ST_MakePoint(-99.1471534331923, 19.2855171865218), 4326), ST_SetSRID(ST_MakePoint(-99.1413095240045, 19.2826902381638), 4326), ST_SetSRID(ST_MakePoint(-99.1315359290786, 19.2837426599594), 4326), ST_SetSRID(ST_MakePoint(-99.1263201882756, 19.2848434038385), 4326), ST_SetSRID(ST_MakePoint(-99.1151871930735, 19.2896182983505), 4326), ST_SetSRID(ST_MakePoint(-99.1022150696128, 19.2951373900851), 4326), ST_SetSRID(ST_MakePoint(-99.0942407817674, 19.2984866689764), 4326), ST_SetSRID(ST_MakePoint(-99.09, 19.2995), 4326), ST_SetSRID(ST_MakePoint(-99.087, 19.301), 4326), ST_SetSRID(ST_MakePoint(-99.0845, 19.304), 4326), ST_SetSRID(ST_MakePoint(-99.08, 19.31), 4326), ST_SetSRID(ST_MakePoint(-99.0745175260824, 19.3176186017939), 4326)])))
ON CONFLICT DO NOTHING;

INSERT INTO ramals (linea_id, nombre_ramal, estado, ramal_num, geom)
VALUES (2072, 'Periférico Interior Poniente - IDA', 'Propuesta académica', 1,
    ST_Multi(ST_MakeLine(ARRAY[ST_SetSRID(ST_MakePoint(-99.220328643837, 19.320925949733), 4326), ST_SetSRID(ST_MakePoint(-99.2156603800189, 19.324062314384), 4326), ST_SetSRID(ST_MakePoint(-99.2120483506634, 19.3286106861771), 4326), ST_SetSRID(ST_MakePoint(-99.2109659153388, 19.3306707865798), 4326), ST_SetSRID(ST_MakePoint(-99.2089943081942, 19.3342970580488), 4326), ST_SetSRID(ST_MakePoint(-99.2032322288589, 19.3408894521725), 4326), ST_SetSRID(ST_MakePoint(-99.2020378704102, 19.3479263629079), 4326), ST_SetSRID(ST_MakePoint(-99.1988823295185, 19.3557316805212), 4326), ST_SetSRID(ST_MakePoint(-99.1912054597844, 19.3617955262867), 4326), ST_SetSRID(ST_MakePoint(-99.1911488730648, 19.366922941138), 4326), ST_SetSRID(ST_MakePoint(-99.193938817374, 19.3721026926363), 4326), ST_SetSRID(ST_MakePoint(-99.1915218752405, 19.3762729468749), 4326), ST_SetSRID(ST_MakePoint(-99.1912526191116, 19.3847724156345), 4326), ST_SetSRID(ST_MakePoint(-99.188913461022, 19.3909745202463), 4326), ST_SetSRID(ST_MakePoint(-99.1887382399895, 19.3955383249044), 4326), ST_SetSRID(ST_MakePoint(-99.1917529384344, 19.4001935073707), 4326), ST_SetSRID(ST_MakePoint(-99.1918864435316, 19.4064246330255), 4326), ST_SetSRID(ST_MakePoint(-99.1941158560232, 19.4112098768217), 4326), ST_SetSRID(ST_MakePoint(-99.1948212702859, 19.4179379699072), 4326), ST_SetSRID(ST_MakePoint(-99.1990471598163, 19.4227045760294), 4326), ST_SetSRID(ST_MakePoint(-99.2033829224792, 19.427271778236), 4326), ST_SetSRID(ST_MakePoint(-99.2080967842068, 19.4320351650801), 4326), ST_SetSRID(ST_MakePoint(-99.2129461326464, 19.4367463974964), 4326), ST_SetSRID(ST_MakePoint(-99.214626690685, 19.4392638928012), 4326), ST_SetSRID(ST_MakePoint(-99.216389674011, 19.4423772420843), 4326), ST_SetSRID(ST_MakePoint(-99.2205876390333, 19.4587801108788), 4326), ST_SetSRID(ST_MakePoint(-99.2245013622917, 19.4660189895512), 4326), ST_SetSRID(ST_MakePoint(-99.2285223588608, 19.47375676818), 4326), ST_SetSRID(ST_MakePoint(-99.2319348869996, 19.4790829347871), 4326), ST_SetSRID(ST_MakePoint(-99.2350808843679, 19.4861748591816), 4326), ST_SetSRID(ST_MakePoint(-99.2372188516262, 19.4942303629856), 4326)])))
ON CONFLICT DO NOTHING;

INSERT INTO ramals (linea_id, nombre_ramal, estado, ramal_num, geom)
VALUES (2072, 'Periférico Interior Poniente - REGRESO', 'Propuesta académica', 0,
    ST_Multi(ST_MakeLine(ARRAY[ST_SetSRID(ST_MakePoint(-99.2372188516262, 19.4942303629856), 4326), ST_SetSRID(ST_MakePoint(-99.2350808843679, 19.4861748591816), 4326), ST_SetSRID(ST_MakePoint(-99.2319348869996, 19.4790829347871), 4326), ST_SetSRID(ST_MakePoint(-99.2285223588608, 19.47375676818), 4326), ST_SetSRID(ST_MakePoint(-99.2245013622917, 19.4660189895512), 4326), ST_SetSRID(ST_MakePoint(-99.2205876390333, 19.4587801108788), 4326), ST_SetSRID(ST_MakePoint(-99.216389674011, 19.4423772420843), 4326), ST_SetSRID(ST_MakePoint(-99.214626690685, 19.4392638928012), 4326), ST_SetSRID(ST_MakePoint(-99.2129461326464, 19.4367463974964), 4326), ST_SetSRID(ST_MakePoint(-99.2080967842068, 19.4320351650801), 4326), ST_SetSRID(ST_MakePoint(-99.2033829224792, 19.427271778236), 4326), ST_SetSRID(ST_MakePoint(-99.1990471598163, 19.4227045760294), 4326), ST_SetSRID(ST_MakePoint(-99.1948212702859, 19.4179379699072), 4326), ST_SetSRID(ST_MakePoint(-99.1941158560232, 19.4112098768217), 4326), ST_SetSRID(ST_MakePoint(-99.1918864435316, 19.4064246330255), 4326), ST_SetSRID(ST_MakePoint(-99.1917529384344, 19.4001935073707), 4326), ST_SetSRID(ST_MakePoint(-99.1887382399895, 19.3955383249044), 4326), ST_SetSRID(ST_MakePoint(-99.188913461022, 19.3909745202463), 4326), ST_SetSRID(ST_MakePoint(-99.1912526191116, 19.3847724156345), 4326), ST_SetSRID(ST_MakePoint(-99.1915218752405, 19.3762729468749), 4326), ST_SetSRID(ST_MakePoint(-99.193938817374, 19.3721026926363), 4326), ST_SetSRID(ST_MakePoint(-99.1911488730648, 19.366922941138), 4326), ST_SetSRID(ST_MakePoint(-99.1912054597844, 19.3617955262867), 4326), ST_SetSRID(ST_MakePoint(-99.1988823295185, 19.3557316805212), 4326), ST_SetSRID(ST_MakePoint(-99.2020378704102, 19.3479263629079), 4326), ST_SetSRID(ST_MakePoint(-99.2032322288589, 19.3408894521725), 4326), ST_SetSRID(ST_MakePoint(-99.2089943081942, 19.3342970580488), 4326), ST_SetSRID(ST_MakePoint(-99.2109659153388, 19.3306707865798), 4326), ST_SetSRID(ST_MakePoint(-99.2120483506634, 19.3286106861771), 4326), ST_SetSRID(ST_MakePoint(-99.2156603800189, 19.324062314384), 4326), ST_SetSRID(ST_MakePoint(-99.220328643837, 19.320925949733), 4326)])))
ON CONFLICT DO NOTHING;

INSERT INTO ramals (linea_id, nombre_ramal, estado, ramal_num, geom)
VALUES (2073, 'Periférico Interior Norte - IDA', 'Propuesta académica', 1,
    ST_Multi(ST_MakeLine(ARRAY[ST_SetSRID(ST_MakePoint(-99.2372188516262, 19.4942303629856), 4326), ST_SetSRID(ST_MakePoint(-99.237, 19.502), 4326), ST_SetSRID(ST_MakePoint(-99.2368132396803, 19.5092138203163), 4326), ST_SetSRID(ST_MakePoint(-99.2306362052263, 19.5193013624258), 4326), ST_SetSRID(ST_MakePoint(-99.2185048168838, 19.5185963862678), 4326), ST_SetSRID(ST_MakePoint(-99.2117073099832, 19.5168414273159), 4326), ST_SetSRID(ST_MakePoint(-99.1964973796254, 19.5170094114134), 4326), ST_SetSRID(ST_MakePoint(-99.1793753322663, 19.5116041682883), 4326), ST_SetSRID(ST_MakePoint(-99.1729985503897, 19.5145114374118), 4326), ST_SetSRID(ST_MakePoint(-99.1655936278391, 19.5124915987051), 4326), ST_SetSRID(ST_MakePoint(-99.1603951642349, 19.512747482633), 4326), ST_SetSRID(ST_MakePoint(-99.154068179484, 19.5146094622948), 4326), ST_SetSRID(ST_MakePoint(-99.1430542558633, 19.5180624295389), 4326), ST_SetSRID(ST_MakePoint(-99.1345326557674, 19.5179557253226), 4326), ST_SetSRID(ST_MakePoint(-99.1242526088899, 19.5191546977744), 4326), ST_SetSRID(ST_MakePoint(-99.114145246139, 19.5214580487031), 4326), ST_SetSRID(ST_MakePoint(-99.1012458364103, 19.5147915769313), 4326), ST_SetSRID(ST_MakePoint(-99.0859313881947, 19.5071286247817), 4326), ST_SetSRID(ST_MakePoint(-99.0779649889604, 19.5038193655209), 4326), ST_SetSRID(ST_MakePoint(-99.0642759104053, 19.4982680721875), 4326), ST_SetSRID(ST_MakePoint(-99.053966727543, 19.4938637992146), 4326), ST_SetSRID(ST_MakePoint(-99.0466020294544, 19.4911807713892), 4326), ST_SetSRID(ST_MakePoint(-99.0388115288086, 19.4873294113852), 4326), ST_SetSRID(ST_MakePoint(-99.0316621504572, 19.4793309527282), 4326)])))
ON CONFLICT DO NOTHING;

INSERT INTO ramals (linea_id, nombre_ramal, estado, ramal_num, geom)
VALUES (2073, 'Periférico Interior Norte - REGRESO', 'Propuesta académica', 0,
    ST_Multi(ST_MakeLine(ARRAY[ST_SetSRID(ST_MakePoint(-99.0316621504572, 19.4793309527282), 4326), ST_SetSRID(ST_MakePoint(-99.0388115288086, 19.4873294113852), 4326), ST_SetSRID(ST_MakePoint(-99.0466020294544, 19.4911807713892), 4326), ST_SetSRID(ST_MakePoint(-99.053966727543, 19.4938637992146), 4326), ST_SetSRID(ST_MakePoint(-99.0642759104053, 19.4982680721875), 4326), ST_SetSRID(ST_MakePoint(-99.0779649889604, 19.5038193655209), 4326), ST_SetSRID(ST_MakePoint(-99.0859313881947, 19.5071286247817), 4326), ST_SetSRID(ST_MakePoint(-99.1012458364103, 19.5147915769313), 4326), ST_SetSRID(ST_MakePoint(-99.114145246139, 19.5214580487031), 4326), ST_SetSRID(ST_MakePoint(-99.1242526088899, 19.5191546977744), 4326), ST_SetSRID(ST_MakePoint(-99.1345326557674, 19.5179557253226), 4326), ST_SetSRID(ST_MakePoint(-99.1430542558633, 19.5180624295389), 4326), ST_SetSRID(ST_MakePoint(-99.154068179484, 19.5146094622948), 4326), ST_SetSRID(ST_MakePoint(-99.1603951642349, 19.512747482633), 4326), ST_SetSRID(ST_MakePoint(-99.1655936278391, 19.5124915987051), 4326), ST_SetSRID(ST_MakePoint(-99.1729985503897, 19.5145114374118), 4326), ST_SetSRID(ST_MakePoint(-99.1793753322663, 19.5116041682883), 4326), ST_SetSRID(ST_MakePoint(-99.1964973796254, 19.5170094114134), 4326), ST_SetSRID(ST_MakePoint(-99.2117073099832, 19.5168414273159), 4326), ST_SetSRID(ST_MakePoint(-99.2185048168838, 19.5185963862678), 4326), ST_SetSRID(ST_MakePoint(-99.2306362052263, 19.5193013624258), 4326), ST_SetSRID(ST_MakePoint(-99.2368132396803, 19.5092138203163), 4326), ST_SetSRID(ST_MakePoint(-99.237, 19.502), 4326), ST_SetSRID(ST_MakePoint(-99.2372188516262, 19.4942303629856), 4326)])))
ON CONFLICT DO NOTHING;

INSERT INTO ramals (linea_id, nombre_ramal, estado, ramal_num, geom)
VALUES (2074, 'Periférico Interior Oriente - IDA', 'Propuesta académica', 1,
    ST_Multi(ST_MakeLine(ARRAY[ST_SetSRID(ST_MakePoint(-99.0316621504572, 19.4793309527282), 4326), ST_SetSRID(ST_MakePoint(-99.0356457017992, 19.4730405471889), 4326), ST_SetSRID(ST_MakePoint(-99.0373166530742, 19.4666123777387), 4326), ST_SetSRID(ST_MakePoint(-99.0383847433583, 19.4571699263318), 4326), ST_SetSRID(ST_MakePoint(-99.0522269700144, 19.4297107907808), 4326), ST_SetSRID(ST_MakePoint(-99.0554993142479, 19.4223645933323), 4326), ST_SetSRID(ST_MakePoint(-99.0567857536576, 19.4119961559513), 4326), ST_SetSRID(ST_MakePoint(-99.0575875865377, 19.4046000958895), 4326), ST_SetSRID(ST_MakePoint(-99.0579318907728, 19.3983599751904), 4326), ST_SetSRID(ST_MakePoint(-99.0599752608567, 19.3896460289669), 4326), ST_SetSRID(ST_MakePoint(-99.0606372559403, 19.3820692425108), 4326), ST_SetSRID(ST_MakePoint(-99.0601250788034, 19.3767183843786), 4326), ST_SetSRID(ST_MakePoint(-99.0574385618996, 19.3633810991953), 4326), ST_SetSRID(ST_MakePoint(-99.0596560450222, 19.3535104905475), 4326), ST_SetSRID(ST_MakePoint(-99.0626549863211, 19.3450857602017), 4326), ST_SetSRID(ST_MakePoint(-99.0642540491586, 19.3391428958489), 4326), ST_SetSRID(ST_MakePoint(-99.067599524439, 19.3283774337608), 4326), ST_SetSRID(ST_MakePoint(-99.0745175260824, 19.3176186017939), 4326)])))
ON CONFLICT DO NOTHING;

INSERT INTO ramals (linea_id, nombre_ramal, estado, ramal_num, geom)
VALUES (2074, 'Periférico Interior Oriente - REGRESO', 'Propuesta académica', 0,
    ST_Multi(ST_MakeLine(ARRAY[ST_SetSRID(ST_MakePoint(-99.0745175260824, 19.3176186017939), 4326), ST_SetSRID(ST_MakePoint(-99.067599524439, 19.3283774337608), 4326), ST_SetSRID(ST_MakePoint(-99.0642540491586, 19.3391428958489), 4326), ST_SetSRID(ST_MakePoint(-99.0626549863211, 19.3450857602017), 4326), ST_SetSRID(ST_MakePoint(-99.0596560450222, 19.3535104905475), 4326), ST_SetSRID(ST_MakePoint(-99.0574385618996, 19.3633810991953), 4326), ST_SetSRID(ST_MakePoint(-99.0601250788034, 19.3767183843786), 4326), ST_SetSRID(ST_MakePoint(-99.0606372559403, 19.3820692425108), 4326), ST_SetSRID(ST_MakePoint(-99.0599752608567, 19.3896460289669), 4326), ST_SetSRID(ST_MakePoint(-99.0579318907728, 19.3983599751904), 4326), ST_SetSRID(ST_MakePoint(-99.0575875865377, 19.4046000958895), 4326), ST_SetSRID(ST_MakePoint(-99.0567857536576, 19.4119961559513), 4326), ST_SetSRID(ST_MakePoint(-99.0554993142479, 19.4223645933323), 4326), ST_SetSRID(ST_MakePoint(-99.0522269700144, 19.4297107907808), 4326), ST_SetSRID(ST_MakePoint(-99.0383847433583, 19.4571699263318), 4326), ST_SetSRID(ST_MakePoint(-99.0373166530742, 19.4666123777387), 4326), ST_SetSRID(ST_MakePoint(-99.0356457017992, 19.4730405471889), 4326), ST_SetSRID(ST_MakePoint(-99.0316621504572, 19.4793309527282), 4326)])))
ON CONFLICT DO NOTHING;

-- =====================================================
-- 4. HISTÓRICO DE OPERACIÓN (velocidad y frecuencia)
-- =====================================================
INSERT INTO historico_operacion (linea_id, ramal_id, velocidad_promedio_kmh, frecuencia_minutos, fuente)
SELECT 2071, r.id, 16.3, 5.0, 'Propuesta académica Anillo Periférico Interior 2026'
FROM ramals r
WHERE r.linea_id = 2071 AND r.ramal_num = 1
  AND NOT EXISTS (SELECT 1 FROM historico_operacion h WHERE h.ramal_id = r.id);

INSERT INTO historico_operacion (linea_id, ramal_id, velocidad_promedio_kmh, frecuencia_minutos, fuente)
SELECT 2071, r.id, 16.3, 5.0, 'Propuesta académica Anillo Periférico Interior 2026'
FROM ramals r
WHERE r.linea_id = 2071 AND r.ramal_num = 0
  AND NOT EXISTS (SELECT 1 FROM historico_operacion h WHERE h.ramal_id = r.id);

INSERT INTO historico_operacion (linea_id, ramal_id, velocidad_promedio_kmh, frecuencia_minutos, fuente)
SELECT 2072, r.id, 16.3, 5.0, 'Propuesta académica Anillo Periférico Interior 2026'
FROM ramals r
WHERE r.linea_id = 2072 AND r.ramal_num = 1
  AND NOT EXISTS (SELECT 1 FROM historico_operacion h WHERE h.ramal_id = r.id);

INSERT INTO historico_operacion (linea_id, ramal_id, velocidad_promedio_kmh, frecuencia_minutos, fuente)
SELECT 2072, r.id, 16.3, 5.0, 'Propuesta académica Anillo Periférico Interior 2026'
FROM ramals r
WHERE r.linea_id = 2072 AND r.ramal_num = 0
  AND NOT EXISTS (SELECT 1 FROM historico_operacion h WHERE h.ramal_id = r.id);

INSERT INTO historico_operacion (linea_id, ramal_id, velocidad_promedio_kmh, frecuencia_minutos, fuente)
SELECT 2073, r.id, 16.3, 5.0, 'Propuesta académica Anillo Periférico Interior 2026'
FROM ramals r
WHERE r.linea_id = 2073 AND r.ramal_num = 1
  AND NOT EXISTS (SELECT 1 FROM historico_operacion h WHERE h.ramal_id = r.id);

INSERT INTO historico_operacion (linea_id, ramal_id, velocidad_promedio_kmh, frecuencia_minutos, fuente)
SELECT 2073, r.id, 16.3, 5.0, 'Propuesta académica Anillo Periférico Interior 2026'
FROM ramals r
WHERE r.linea_id = 2073 AND r.ramal_num = 0
  AND NOT EXISTS (SELECT 1 FROM historico_operacion h WHERE h.ramal_id = r.id);

INSERT INTO historico_operacion (linea_id, ramal_id, velocidad_promedio_kmh, frecuencia_minutos, fuente)
SELECT 2074, r.id, 16.3, 5.0, 'Propuesta académica Anillo Periférico Interior 2026'
FROM ramals r
WHERE r.linea_id = 2074 AND r.ramal_num = 1
  AND NOT EXISTS (SELECT 1 FROM historico_operacion h WHERE h.ramal_id = r.id);

INSERT INTO historico_operacion (linea_id, ramal_id, velocidad_promedio_kmh, frecuencia_minutos, fuente)
SELECT 2074, r.id, 16.3, 5.0, 'Propuesta académica Anillo Periférico Interior 2026'
FROM ramals r
WHERE r.linea_id = 2074 AND r.ramal_num = 0
  AND NOT EXISTS (SELECT 1 FROM historico_operacion h WHERE h.ramal_id = r.id);

-- =====================================================
-- Verificación post-carga
-- =====================================================
-- SELECT 'lineas' AS tabla, count(*) FROM lineas WHERE clasificacion = 'propuesta_periferico' AND sistema = 'MB'
-- UNION ALL
-- SELECT 'estacions', count(*) FROM estacions WHERE sistema = 'MB' AND id BETWEEN 31001 AND 20200
-- UNION ALL
-- SELECT 'ramals', count(*) FROM ramals WHERE linea_id BETWEEN 2071 AND 2074
-- UNION ALL
-- SELECT 'historico_operacion', count(*) FROM historico_operacion WHERE linea_id BETWEEN 2071 AND 2074;
