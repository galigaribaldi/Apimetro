-- =====================================================
-- Apimetro — Migración Anillo Periférico Interior
-- Escenario: METRO
-- Sistema: METRO
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
VALUES (3071, 'Periférico Interior Sur', 'METRO', 2026,
    'darkblue', 'AZUL', 0, false, 'propuesta_periferico',
    'AP71', 'masivo_pesado',
    'exclusivo', 1000)
ON CONFLICT (id) DO NOTHING;

INSERT INTO lineas (id, nombre, sistema, anio_inauguracion, color_en, color_esp,
    tam_km, existe, clasificacion, num_comercial, jerarquia_transporte,
    derecho_de_via, capacidad_vehiculo)
VALUES (3072, 'Periférico Interior Poniente', 'METRO', 2026,
    'darkblue', 'AZUL', 0, false, 'propuesta_periferico',
    'AP72', 'masivo_pesado',
    'exclusivo', 1000)
ON CONFLICT (id) DO NOTHING;

INSERT INTO lineas (id, nombre, sistema, anio_inauguracion, color_en, color_esp,
    tam_km, existe, clasificacion, num_comercial, jerarquia_transporte,
    derecho_de_via, capacidad_vehiculo)
VALUES (3073, 'Periférico Interior Norte', 'METRO', 2026,
    'darkblue', 'AZUL', 0, false, 'propuesta_periferico',
    'AP73', 'masivo_pesado',
    'exclusivo', 1000)
ON CONFLICT (id) DO NOTHING;

INSERT INTO lineas (id, nombre, sistema, anio_inauguracion, color_en, color_esp,
    tam_km, existe, clasificacion, num_comercial, jerarquia_transporte,
    derecho_de_via, capacidad_vehiculo)
VALUES (3074, 'Periférico Interior Oriente', 'METRO', 2026,
    'darkblue', 'AZUL', 0, false, 'propuesta_periferico',
    'AP74', 'masivo_pesado',
    'exclusivo', 1000)
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- 2. ESTACIONES (con geometría POINT PostGIS)
-- =====================================================
INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30001, 'Periférico Oriente/Tláhuac', 'APME7101', 'Terminal / Transbordo', 'Iztapalapa', '2026',
    'CDMX', -99.0745175260824, 19.3176186017939, 3071, 1,
    30001, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.0745175260824, 19.3176186017939), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30002, 'Estrella del Sur', 'APME7102', 'Intermedia', 'Iztapalapa', '2026',
    'CDMX', -99.08, 19.31, 3071, 2,
    30002, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.08, 19.31), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30003, 'Culhuacán', 'APME7103', 'Intermedia', 'Iztapalapa', '2026',
    'CDMX', -99.0845, 19.304, 3071, 3,
    30003, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.0845, 19.304), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30004, 'Atlalilco/Periférico', 'APME7104', 'Transbordo', 'Iztapalapa', '2026',
    'CDMX', -99.087, 19.301, 3071, 4,
    30004, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.087, 19.301), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30005, 'Canal de Chalco/Periférico', 'APME7105', 'Intermedia', 'Tláhuac', '2026',
    'CDMX', -99.09, 19.2995, 3071, 5,
    30005, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.09, 19.2995), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30006, 'Cuemanco', 'APME7106', 'Intermedia', 'Xochimilco', '2026',
    'CDMX', -99.0942407817674, 19.2984866689764, 3071, 6,
    30006, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.0942407817674, 19.2984866689764), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30007, 'Canal Nacional', 'APME7107', 'Intermedia', 'Xochimilco', '2026',
    'CDMX', -99.1022150696128, 19.2951373900851, 3071, 7,
    30007, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.1022150696128, 19.2951373900851), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30008, 'Muyuguarda/Cafetales', 'APME7108', 'Transbordo', 'Xochimilco', '2026',
    'CDMX', -99.1151871930735, 19.2896182983505, 3071, 8,
    30008, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.1151871930735, 19.2896182983505), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30009, 'Vaqueritos', 'APME7109', 'Transbordo', 'Xochimilco', '2026',
    'CDMX', -99.1263201882756, 19.2848434038385, 3071, 9,
    30009, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.1263201882756, 19.2848434038385), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30010, 'Coapa', 'APME7110', 'Intermedia', 'Tlalpan', '2026',
    'CDMX', -99.1315359290786, 19.2837426599594, 3071, 10,
    30010, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.1315359290786, 19.2837426599594), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30011, 'Tepepan', 'APME7111', 'Intermedia', 'Tlalpan', '2026',
    'CDMX', -99.1413095240045, 19.2826902381638, 3071, 11,
    30011, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.1413095240045, 19.2826902381638), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30012, 'ESCA', 'APME7112', 'Intermedia', 'Tlalpan', '2026',
    'CDMX', -99.1471534331923, 19.2855171865218, 3071, 12,
    30012, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.1471534331923, 19.2855171865218), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30013, 'Zona de Hospitales', 'APME7113', 'Intermedia', 'Tlalpan', '2026',
    'CDMX', -99.1520826881746, 19.2904007344833, 3071, 13,
    30013, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.1520826881746, 19.2904007344833), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30014, 'Huipulco', 'APME7114', 'Intermedia', 'Tlalpan', '2026',
    'CDMX', -99.154638074917, 19.2947326036117, 3071, 14,
    30014, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.154638074917, 19.2947326036117), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30015, 'Imán/Circuito Azteca', 'APME7115', 'Intermedia', 'Tlalpan', '2026',
    'CDMX', -99.1605958187857, 19.3010375800792, 3071, 15,
    30015, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.1605958187857, 19.3010375800792), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30016, 'Gran Sur', 'APME7116', 'Intermedia', 'Tlalpan', '2026',
    'CDMX', -99.165564430135, 19.3021048026286, 3071, 16,
    30016, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.165564430135, 19.3021048026286), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30017, 'Santa Ursula', 'APME7117', 'Intermedia', 'Coyoacán', '2026',
    'CDMX', -99.1728062297974, 19.3030265199362, 3071, 17,
    30017, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.1728062297974, 19.3030265199362), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30018, 'Cuicuilco', 'APME7118', 'Intermedia', 'Tlalpan', '2026',
    'CDMX', -99.1814065330579, 19.3031746140771, 3071, 18,
    30018, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.1814065330579, 19.3031746140771), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30019, 'Periférico Sur', 'APME7119', 'Transbordo', 'Coyoacán', '2026',
    'CDMX', -99.1858597527883, 19.3031599255714, 3071, 19,
    30019, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.1858597527883, 19.3031599255714), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30020, 'Jardines del Pedregal', 'APME7120', 'Intermedia', 'Coyoacán', '2026',
    'CDMX', -99.1997557764832, 19.304247670836, 3071, 20,
    30020, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.1997557764832, 19.304247670836), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30021, 'Ajusco', 'APME7121', 'Transbordo', 'Coyoacán', '2026',
    'CDMX', -99.204757323956, 19.3058181987807, 3071, 21,
    30021, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.204757323956, 19.3058181987807), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30022, 'Santa Teresa', 'APME7122', 'Intermedia', 'Álvaro Obregón', '2026',
    'CDMX', -99.2158309051932, 19.3075696512559, 3071, 22,
    30022, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.2158309051932, 19.3075696512559), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30023, 'Ángeles', 'APME7123', 'Intermedia', 'La Magdalena Contreras', '2026',
    'CDMX', -99.2199193504131, 19.3129905724798, 3071, 23,
    30023, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.2199193504131, 19.3129905724798), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30024, 'Suiza', 'APME7124', 'Intermedia', 'La Magdalena Contreras', '2026',
    'CDMX', -99.2216738353594, 19.3186553545115, 3071, 24,
    30024, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.2216738353594, 19.3186553545115), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30025, 'Luis Cabrera', 'APME7125', 'Terminal / Transbordo', 'La Magdalena Contreras', '2026',
    'CDMX', -99.220328643837, 19.320925949733, 3071, 25,
    30025, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.220328643837, 19.320925949733), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30026, 'Luis Cabrera', 'APME7201', 'Terminal / Transbordo', 'La Magdalena Contreras', '2026',
    'CDMX', -99.220328643837, 19.320925949733, 3072, 1,
    30026, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.220328643837, 19.320925949733), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30027, 'San Antonio Elevado', 'APME7202', 'Intermedia', 'La Magdalena Contreras', '2026',
    'CDMX', -99.2156603800189, 19.324062314384, 3072, 2,
    30027, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.2156603800189, 19.324062314384), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30028, 'Tarasquillo', 'APME7203', 'Intermedia', 'Álvaro Obregón', '2026',
    'CDMX', -99.2120483506634, 19.3286106861771, 3072, 3,
    30028, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.2120483506634, 19.3286106861771), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30029, 'Glorieta Monumental', 'APME7204', 'Intermedia', 'Álvaro Obregón', '2026',
    'CDMX', -99.2109659153388, 19.3306707865798, 3072, 4,
    30029, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.2109659153388, 19.3306707865798), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30030, 'Parque el Batán', 'APME7205', 'Intermedia', 'Álvaro Obregón', '2026',
    'CDMX', -99.2089943081942, 19.3342970580488, 3072, 5,
    30030, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.2089943081942, 19.3342970580488), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30031, 'Toluca', 'APME7206', 'Transbordo', 'Álvaro Obregón', '2026',
    'CDMX', -99.2032322288589, 19.3408894521725, 3072, 6,
    30031, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.2032322288589, 19.3408894521725), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30032, 'Desierto de los Leones', 'APME7207', 'Intermedia', 'Álvaro Obregón', '2026',
    'CDMX', -99.2020378704102, 19.3479263629079, 3072, 7,
    30032, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.2020378704102, 19.3479263629079), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30033, 'Rómulo O''Farril', 'APME7208', 'Intermedia', 'Álvaro Obregón', '2026',
    'CDMX', -99.1988823295185, 19.3557316805212, 3072, 8,
    30033, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.1988823295185, 19.3557316805212), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30034, 'Barranca del Muerto/Periférico', 'APME7209', 'Transbordo', 'Álvaro Obregón', '2026',
    'CDMX', -99.1912054597844, 19.3617955262867, 3072, 9,
    30034, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.1912054597844, 19.3617955262867), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30035, 'Prepa 8', 'APME7210', 'Intermedia', 'Álvaro Obregón', '2026',
    'CDMX', -99.1911488730648, 19.366922941138, 3072, 10,
    30035, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.1911488730648, 19.366922941138), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30036, 'Rosa Trepadora', 'APME7211', 'Intermedia', 'Álvaro Obregón', '2026',
    'CDMX', -99.193938817374, 19.3721026926363, 3072, 11,
    30036, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.193938817374, 19.3721026926363), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30037, 'Celini', 'APME7212', 'Intermedia', 'Álvaro Obregón', '2026',
    'CDMX', -99.1915218752405, 19.3762729468749, 3072, 12,
    30037, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.1915218752405, 19.3762729468749), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30038, 'Distribuidor Vial San Antonio', 'APME7213', 'Intermedia', 'Álvaro Obregón', '2026',
    'CDMX', -99.1912526191116, 19.3847724156345, 3072, 13,
    30038, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.1912526191116, 19.3847724156345), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30039, 'San Pedro de los Pinos/Periférico', 'APME7214', 'Transbordo', 'Benito Juárez', '2026',
    'CDMX', -99.188913461022, 19.3909745202463, 3072, 14,
    30039, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.188913461022, 19.3909745202463), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30040, '11 de Abril', 'APME7215', 'Intermedia', 'Benito Juárez', '2026',
    'CDMX', -99.1887382399895, 19.3955383249044, 3072, 15,
    30040, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.1887382399895, 19.3955383249044), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30041, 'Miguel Alemán Valdés', 'APME7216', 'Intermedia', 'Miguel Hidalgo', '2026',
    'CDMX', -99.1917529384344, 19.4001935073707, 3072, 16,
    30041, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.1917529384344, 19.4001935073707), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30042, 'Parque Lira', 'APME7217', 'Intermedia', 'Miguel Hidalgo', '2026',
    'CDMX', -99.1918864435316, 19.4064246330255, 3072, 17,
    30042, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.1918864435316, 19.4064246330255), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30043, 'Constituyentes/Periférico', 'APME7218', 'Intermedia', 'Miguel Hidalgo', '2026',
    'CDMX', -99.1941158560232, 19.4112098768217, 3072, 18,
    30043, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.1941158560232, 19.4112098768217), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30044, 'Los Pinos', 'APME7219', 'Intermedia', 'Miguel Hidalgo', '2026',
    'CDMX', -99.1948212702859, 19.4179379699072, 3072, 19,
    30044, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.1948212702859, 19.4179379699072), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30045, 'Alencastre', 'APME7220', 'Intermedia', 'Miguel Hidalgo', '2026',
    'CDMX', -99.1990471598163, 19.4227045760294, 3072, 20,
    30045, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.1990471598163, 19.4227045760294), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30046, 'Paseo de la Reforma', 'APME7221', 'Intermedia', 'Miguel Hidalgo', '2026',
    'CDMX', -99.2033829224792, 19.427271778236, 3072, 21,
    30046, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.2033829224792, 19.427271778236), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30047, 'Presidente Masaryk', 'APME7222', 'Intermedia', 'Miguel Hidalgo', '2026',
    'CDMX', -99.2080967842068, 19.4320351650801, 3072, 22,
    30047, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.2080967842068, 19.4320351650801), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30048, 'Homero', 'APME7223', 'Intermedia', 'Miguel Hidalgo', '2026',
    'CDMX', -99.2129461326464, 19.4367463974964, 3072, 23,
    30048, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.2129461326464, 19.4367463974964), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30049, 'Ejército Nacional', 'APME7224', 'Intermedia', 'Miguel Hidalgo', '2026',
    'CDMX', -99.214626690685, 19.4392638928012, 3072, 24,
    30049, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.214626690685, 19.4392638928012), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30050, 'Hipódromo las Américas', 'APME7225', 'Intermedia', 'Miguel Hidalgo', '2026',
    'CDMX', -99.216389674011, 19.4423772420843, 3072, 25,
    30050, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.216389674011, 19.4423772420843), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30051, 'Cuatro Caminos/Periférico', 'APME7226', 'Transbordo', 'Naucalpan de Juárez', '2026',
    'EDOMEX', -99.2205876390333, 19.4587801108788, 3072, 26,
    30051, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.2205876390333, 19.4587801108788), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30052, 'Las Torres', 'APME7227', 'Intermedia', 'Naucalpan de Juárez', '2026',
    'EDOMEX', -99.2245013622917, 19.4660189895512, 3072, 27,
    30052, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.2245013622917, 19.4660189895512), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30053, 'Naucalpan', 'APME7228', 'Intermedia', 'Naucalpan de Juárez', '2026',
    'EDOMEX', -99.2285223588608, 19.47375676818, 3072, 28,
    30053, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.2285223588608, 19.47375676818), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30054, 'Gustavo Baz Prada', 'APME7229', 'Intermedia', 'Naucalpan de Juárez', '2026',
    'EDOMEX', -99.2319348869996, 19.4790829347871, 3072, 29,
    30054, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.2319348869996, 19.4790829347871), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30055, 'Lomas Verdes', 'APME7230', 'Intermedia', 'Naucalpan de Juárez', '2026',
    'EDOMEX', -99.2350808843679, 19.4861748591816, 3072, 30,
    30055, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.2350808843679, 19.4861748591816), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30056, 'Parque Naucalli', 'APME7231', 'Terminal / Transbordo', 'Naucalpan de Juárez', '2026',
    'EDOMEX', -99.2372188516262, 19.4942303629856, 3072, 31,
    30056, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.2372188516262, 19.4942303629856), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30057, 'Parque Naucalli', 'APME7301', 'Terminal / Transbordo', 'Naucalpan de Juárez', '2026',
    'EDOMEX', -99.2372188516262, 19.4942303629856, 3073, 1,
    30057, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.2372188516262, 19.4942303629856), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30058, 'Torres de Satélite', 'APME7302', 'Intermedia', 'Naucalpan de Juárez', '2026',
    'EDOMEX', -99.237, 19.502, 3073, 2,
    30058, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.237, 19.502), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30059, 'Ciudad Satélite', 'APME7303', 'Intermedia', 'Naucalpan de Juárez', '2026',
    'EDOMEX', -99.2368132396803, 19.5092138203163, 3073, 3,
    30059, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.2368132396803, 19.5092138203163), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30060, 'Circunvalación', 'APME7304', 'Intermedia', 'Naucalpan de Juárez', '2026',
    'EDOMEX', -99.2306362052263, 19.5193013624258, 3073, 4,
    30060, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.2306362052263, 19.5193013624258), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30061, 'Viveros de Atizapán', 'APME7305', 'Intermedia', 'Tlalnepantla de Baz', '2026',
    'EDOMEX', -99.2185048168838, 19.5185963862678, 3073, 5,
    30061, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.2185048168838, 19.5185963862678), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30062, 'Presidente Juárez', 'APME7306', 'Intermedia', 'Tlalnepantla de Baz', '2026',
    'EDOMEX', -99.2117073099832, 19.5168414273159, 3073, 6,
    30062, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.2117073099832, 19.5168414273159), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30063, 'Tlalnepantla', 'APME7307', 'Intermedia', 'Tlalnepantla de Baz', '2026',
    'EDOMEX', -99.1964973796254, 19.5170094114134, 3073, 7,
    30063, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.1964973796254, 19.5170094114134), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30064, 'Av de las Granjas', 'APME7308', 'Intermedia', 'Tlalnepantla de Baz', '2026',
    'EDOMEX', -99.1793753322663, 19.5116041682883, 3073, 8,
    30064, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.1793753322663, 19.5116041682883), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30065, 'El Heraldo', 'APME7309', 'Intermedia', 'Tlalnepantla de Baz', '2026',
    'EDOMEX', -99.1729985503897, 19.5145114374118, 3073, 9,
    30065, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.1729985503897, 19.5145114374118), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30066, 'Vaso Regulador de Carretas', 'APME7310', 'Intermedia', 'Tlalnepantla de Baz', '2026',
    'EDOMEX', -99.1655936278391, 19.5124915987051, 3073, 10,
    30066, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.1655936278391, 19.5124915987051), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30067, 'Progreso Nacional', 'APME7311', 'Intermedia', 'Tlalnepantla de Baz', '2026',
    'EDOMEX', -99.1603951642349, 19.512747482633, 3073, 11,
    30067, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.1603951642349, 19.512747482633), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30068, 'Fábricas/Periférico', 'APME7312', 'Intermedia', 'Tlalnepantla de Baz', '2026',
    'EDOMEX', -99.154068179484, 19.5146094622948, 3073, 12,
    30068, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.154068179484, 19.5146094622948), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30069, 'Río San Joaquín', 'APME7313', 'Intermedia', 'Azcapotzalco', '2026',
    'CDMX', -99.1430542558633, 19.5180624295389, 3073, 13,
    30069, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.1430542558633, 19.5180624295389), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30070, 'Acueducto', 'APME7314', 'Intermedia', 'Gustavo A. Madero', '2026',
    'CDMX', -99.1345326557674, 19.5179557253226, 3073, 14,
    30070, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.1345326557674, 19.5179557253226), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30071, 'La Presa', 'APME7315', 'Intermedia', 'Gustavo A. Madero', '2026',
    'CDMX', -99.1242526088899, 19.5191546977744, 3073, 15,
    30071, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.1242526088899, 19.5191546977744), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30072, 'Hermilo Mena', 'APME7316', 'Transbordo', 'Gustavo A. Madero', '2026',
    'CDMX', -99.114145246139, 19.5214580487031, 3073, 16,
    30072, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.114145246139, 19.5214580487031), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30073, 'Constituyentes de 1857', 'APME7317', 'Intermedia', 'Gustavo A. Madero', '2026',
    'CDMX', -99.1012458364103, 19.5147915769313, 3073, 17,
    30073, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.1012458364103, 19.5147915769313), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30074, 'Río de los Remedios MB/Periférico', 'APME7318', 'Transbordo', 'Ecatepec de Morelos', '2026',
    'EDOMEX', -99.0859313881947, 19.5071286247817, 3073, 18,
    30074, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.0859313881947, 19.5071286247817), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30075, 'Gran Canal de Desagüe', 'APME7319', 'Intermedia', 'Ecatepec de Morelos', '2026',
    'EDOMEX', -99.0779649889604, 19.5038193655209, 3073, 19,
    30075, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.0779649889604, 19.5038193655209), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30076, 'Parque Orizaba', 'APME7320', 'Intermedia', 'Ecatepec de Morelos', '2026',
    'EDOMEX', -99.0642759104053, 19.4982680721875, 3073, 20,
    30076, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.0642759104053, 19.4982680721875), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30077, 'Valle de Santiago', 'APME7321', 'Intermedia', 'Ecatepec de Morelos', '2026',
    'EDOMEX', -99.053966727543, 19.4938637992146, 3073, 21,
    30077, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.053966727543, 19.4938637992146), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30078, 'Río de los Remedios Metro/Periférico', 'APME7322', 'Transbordo', 'Ecatepec de Morelos', '2026',
    'EDOMEX', -99.0466020294544, 19.4911807713892, 3073, 22,
    30078, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.0466020294544, 19.4911807713892), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30079, 'Valle de San Lorenzo', 'APME7323', 'Intermedia', 'Nezahualcóyotl', '2026',
    'EDOMEX', -99.0388115288086, 19.4873294113852, 3073, 23,
    30079, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.0388115288086, 19.4873294113852), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30080, 'Colonias de Aragón', 'APME7324', 'Terminal / Transbordo', 'Nezahualcóyotl', '2026',
    'EDOMEX', -99.0316621504572, 19.4793309527282, 3073, 24,
    30080, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.0316621504572, 19.4793309527282), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30081, 'Colonias de Aragón', 'APME7401', 'Terminal / Transbordo', 'Nezahualcóyotl', '2026',
    'EDOMEX', -99.0316621504572, 19.4793309527282, 3074, 1,
    30081, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.0316621504572, 19.4793309527282), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30082, 'FES Aragón', 'APME7402', 'Transbordo', 'Nezahualcóyotl', '2026',
    'EDOMEX', -99.0356457017992, 19.4730405471889, 3074, 2,
    30082, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.0356457017992, 19.4730405471889), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30083, 'Pirules', 'APME7403', 'Intermedia', 'Nezahualcóyotl', '2026',
    'EDOMEX', -99.0373166530742, 19.4666123777387, 3074, 3,
    30083, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.0373166530742, 19.4666123777387), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30084, 'Peñón Texcoco/Periférico', 'APME7404', 'Intermedia', 'Nezahualcóyotl', '2026',
    'EDOMEX', -99.0383847433583, 19.4571699263318, 3074, 4,
    30084, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.0383847433583, 19.4571699263318), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30085, 'Alameda Oriente', 'APME7405', 'Intermedia', 'Venustiano Carranza', '2026',
    'CDMX', -99.0522269700144, 19.4297107907808, 3074, 5,
    30085, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.0522269700144, 19.4297107907808), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30086, 'Ciudad Nezahualcóyotl', 'APME7406', 'Intermedia', 'Nezahualcóyotl', '2026',
    'EDOMEX', -99.0554993142479, 19.4223645933323, 3074, 6,
    30086, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.0554993142479, 19.4223645933323), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30087, 'Av Pantitlán', 'APME7407', 'Intermedia', 'Iztacalco', '2026',
    'CDMX', -99.0567857536576, 19.4119961559513, 3074, 7,
    30087, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.0567857536576, 19.4119961559513), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30088, 'Valesquillo', 'APME7408', 'Intermedia', 'Iztapalapa', '2026',
    'CDMX', -99.0575875865377, 19.4046000958895, 3074, 8,
    30088, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.0575875865377, 19.4046000958895), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30089, 'Canal de San Juan/Periférico', 'APME7409', 'Transbordo', 'Iztapalapa', '2026',
    'CDMX', -99.0579318907728, 19.3983599751904, 3074, 9,
    30089, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.0579318907728, 19.3983599751904), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30090, 'Constitución de Apatzingán', 'APME7410', 'Intermedia', 'Iztapalapa', '2026',
    'CDMX', -99.0599752608567, 19.3896460289669, 3074, 10,
    30090, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.0599752608567, 19.3896460289669), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30091, 'Canal de Tezontle', 'APME7411', 'Intermedia', 'Iztapalapa', '2026',
    'CDMX', -99.0606372559403, 19.3820692425108, 3074, 11,
    30091, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.0606372559403, 19.3820692425108), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30092, 'Leyes de Reforma', 'APME7412', 'Intermedia', 'Iztapalapa', '2026',
    'CDMX', -99.0601250788034, 19.3767183843786, 3074, 12,
    30092, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.0601250788034, 19.3767183843786), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30093, 'Luis Méndez', 'APME7413', 'Intermedia', 'Iztapalapa', '2026',
    'CDMX', -99.0574385618996, 19.3633810991953, 3074, 13,
    30093, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.0574385618996, 19.3633810991953), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30094, 'Revolución Social', 'APME7414', 'Intermedia', 'Iztapalapa', '2026',
    'CDMX', -99.0596560450222, 19.3535104905475, 3074, 14,
    30094, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.0596560450222, 19.3535104905475), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30095, 'Constitución de 1917/Periférico', 'APME7415', 'Transbordo', 'Iztapalapa', '2026',
    'CDMX', -99.0626549863211, 19.3450857602017, 3074, 15,
    30095, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.0626549863211, 19.3450857602017), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30096, '5 de Mayo', 'APME7416', 'Intermedia', 'Iztapalapa', '2026',
    'CDMX', -99.0642540491586, 19.3391428958489, 3074, 16,
    30096, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.0642540491586, 19.3391428958489), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30097, 'Iztapalapa', 'APME7417', 'Transbordo', 'Iztapalapa', '2026',
    'CDMX', -99.067599524439, 19.3283774337608, 3074, 17,
    30097, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.067599524439, 19.3283774337608), 4326))
ON CONFLICT (id) DO NOTHING;

INSERT INTO estacions (id, nombre, cve_est, tipo, alcaldia_municipio, anio,
    estado_ciudad, longitud, latitud, linea_id, num_estacion,
    estacion_id_oficial, sistema, existe, geom)
VALUES (30098, 'Periférico Oriente/Tláhuac', 'APME7418', 'Terminal / Transbordo', 'Iztapalapa', '2026',
    'CDMX', -99.0745175260824, 19.3176186017939, 3074, 18,
    30098, 'METRO', false,
    ST_SetSRID(ST_MakePoint(-99.0745175260824, 19.3176186017939), 4326))
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- 3. RAMALES (geometría MultiLineString — ida y regreso)
--    Trazo: ST_MakeLine entre estaciones consecutivas
--    Cada línea tiene 2 ramales: sentido 1 (ida) y 0 (regreso)
-- =====================================================
INSERT INTO ramals (linea_id, nombre_ramal, estado, ramal_num, geom)
VALUES (3071, 'Periférico Interior Sur - IDA', 'Propuesta académica', 1,
    ST_Multi(ST_MakeLine(ARRAY[ST_SetSRID(ST_MakePoint(-99.0745175260824, 19.3176186017939), 4326), ST_SetSRID(ST_MakePoint(-99.08, 19.31), 4326), ST_SetSRID(ST_MakePoint(-99.0845, 19.304), 4326), ST_SetSRID(ST_MakePoint(-99.087, 19.301), 4326), ST_SetSRID(ST_MakePoint(-99.09, 19.2995), 4326), ST_SetSRID(ST_MakePoint(-99.0942407817674, 19.2984866689764), 4326), ST_SetSRID(ST_MakePoint(-99.1022150696128, 19.2951373900851), 4326), ST_SetSRID(ST_MakePoint(-99.1151871930735, 19.2896182983505), 4326), ST_SetSRID(ST_MakePoint(-99.1263201882756, 19.2848434038385), 4326), ST_SetSRID(ST_MakePoint(-99.1315359290786, 19.2837426599594), 4326), ST_SetSRID(ST_MakePoint(-99.1413095240045, 19.2826902381638), 4326), ST_SetSRID(ST_MakePoint(-99.1471534331923, 19.2855171865218), 4326), ST_SetSRID(ST_MakePoint(-99.1520826881746, 19.2904007344833), 4326), ST_SetSRID(ST_MakePoint(-99.154638074917, 19.2947326036117), 4326), ST_SetSRID(ST_MakePoint(-99.1605958187857, 19.3010375800792), 4326), ST_SetSRID(ST_MakePoint(-99.165564430135, 19.3021048026286), 4326), ST_SetSRID(ST_MakePoint(-99.1728062297974, 19.3030265199362), 4326), ST_SetSRID(ST_MakePoint(-99.1814065330579, 19.3031746140771), 4326), ST_SetSRID(ST_MakePoint(-99.1858597527883, 19.3031599255714), 4326), ST_SetSRID(ST_MakePoint(-99.1997557764832, 19.304247670836), 4326), ST_SetSRID(ST_MakePoint(-99.204757323956, 19.3058181987807), 4326), ST_SetSRID(ST_MakePoint(-99.2158309051932, 19.3075696512559), 4326), ST_SetSRID(ST_MakePoint(-99.2199193504131, 19.3129905724798), 4326), ST_SetSRID(ST_MakePoint(-99.2216738353594, 19.3186553545115), 4326), ST_SetSRID(ST_MakePoint(-99.220328643837, 19.320925949733), 4326)])))
ON CONFLICT DO NOTHING;

INSERT INTO ramals (linea_id, nombre_ramal, estado, ramal_num, geom)
VALUES (3071, 'Periférico Interior Sur - REGRESO', 'Propuesta académica', 0,
    ST_Multi(ST_MakeLine(ARRAY[ST_SetSRID(ST_MakePoint(-99.220328643837, 19.320925949733), 4326), ST_SetSRID(ST_MakePoint(-99.2216738353594, 19.3186553545115), 4326), ST_SetSRID(ST_MakePoint(-99.2199193504131, 19.3129905724798), 4326), ST_SetSRID(ST_MakePoint(-99.2158309051932, 19.3075696512559), 4326), ST_SetSRID(ST_MakePoint(-99.204757323956, 19.3058181987807), 4326), ST_SetSRID(ST_MakePoint(-99.1997557764832, 19.304247670836), 4326), ST_SetSRID(ST_MakePoint(-99.1858597527883, 19.3031599255714), 4326), ST_SetSRID(ST_MakePoint(-99.1814065330579, 19.3031746140771), 4326), ST_SetSRID(ST_MakePoint(-99.1728062297974, 19.3030265199362), 4326), ST_SetSRID(ST_MakePoint(-99.165564430135, 19.3021048026286), 4326), ST_SetSRID(ST_MakePoint(-99.1605958187857, 19.3010375800792), 4326), ST_SetSRID(ST_MakePoint(-99.154638074917, 19.2947326036117), 4326), ST_SetSRID(ST_MakePoint(-99.1520826881746, 19.2904007344833), 4326), ST_SetSRID(ST_MakePoint(-99.1471534331923, 19.2855171865218), 4326), ST_SetSRID(ST_MakePoint(-99.1413095240045, 19.2826902381638), 4326), ST_SetSRID(ST_MakePoint(-99.1315359290786, 19.2837426599594), 4326), ST_SetSRID(ST_MakePoint(-99.1263201882756, 19.2848434038385), 4326), ST_SetSRID(ST_MakePoint(-99.1151871930735, 19.2896182983505), 4326), ST_SetSRID(ST_MakePoint(-99.1022150696128, 19.2951373900851), 4326), ST_SetSRID(ST_MakePoint(-99.0942407817674, 19.2984866689764), 4326), ST_SetSRID(ST_MakePoint(-99.09, 19.2995), 4326), ST_SetSRID(ST_MakePoint(-99.087, 19.301), 4326), ST_SetSRID(ST_MakePoint(-99.0845, 19.304), 4326), ST_SetSRID(ST_MakePoint(-99.08, 19.31), 4326), ST_SetSRID(ST_MakePoint(-99.0745175260824, 19.3176186017939), 4326)])))
ON CONFLICT DO NOTHING;

INSERT INTO ramals (linea_id, nombre_ramal, estado, ramal_num, geom)
VALUES (3072, 'Periférico Interior Poniente - IDA', 'Propuesta académica', 1,
    ST_Multi(ST_MakeLine(ARRAY[ST_SetSRID(ST_MakePoint(-99.220328643837, 19.320925949733), 4326), ST_SetSRID(ST_MakePoint(-99.2156603800189, 19.324062314384), 4326), ST_SetSRID(ST_MakePoint(-99.2120483506634, 19.3286106861771), 4326), ST_SetSRID(ST_MakePoint(-99.2109659153388, 19.3306707865798), 4326), ST_SetSRID(ST_MakePoint(-99.2089943081942, 19.3342970580488), 4326), ST_SetSRID(ST_MakePoint(-99.2032322288589, 19.3408894521725), 4326), ST_SetSRID(ST_MakePoint(-99.2020378704102, 19.3479263629079), 4326), ST_SetSRID(ST_MakePoint(-99.1988823295185, 19.3557316805212), 4326), ST_SetSRID(ST_MakePoint(-99.1912054597844, 19.3617955262867), 4326), ST_SetSRID(ST_MakePoint(-99.1911488730648, 19.366922941138), 4326), ST_SetSRID(ST_MakePoint(-99.193938817374, 19.3721026926363), 4326), ST_SetSRID(ST_MakePoint(-99.1915218752405, 19.3762729468749), 4326), ST_SetSRID(ST_MakePoint(-99.1912526191116, 19.3847724156345), 4326), ST_SetSRID(ST_MakePoint(-99.188913461022, 19.3909745202463), 4326), ST_SetSRID(ST_MakePoint(-99.1887382399895, 19.3955383249044), 4326), ST_SetSRID(ST_MakePoint(-99.1917529384344, 19.4001935073707), 4326), ST_SetSRID(ST_MakePoint(-99.1918864435316, 19.4064246330255), 4326), ST_SetSRID(ST_MakePoint(-99.1941158560232, 19.4112098768217), 4326), ST_SetSRID(ST_MakePoint(-99.1948212702859, 19.4179379699072), 4326), ST_SetSRID(ST_MakePoint(-99.1990471598163, 19.4227045760294), 4326), ST_SetSRID(ST_MakePoint(-99.2033829224792, 19.427271778236), 4326), ST_SetSRID(ST_MakePoint(-99.2080967842068, 19.4320351650801), 4326), ST_SetSRID(ST_MakePoint(-99.2129461326464, 19.4367463974964), 4326), ST_SetSRID(ST_MakePoint(-99.214626690685, 19.4392638928012), 4326), ST_SetSRID(ST_MakePoint(-99.216389674011, 19.4423772420843), 4326), ST_SetSRID(ST_MakePoint(-99.2205876390333, 19.4587801108788), 4326), ST_SetSRID(ST_MakePoint(-99.2245013622917, 19.4660189895512), 4326), ST_SetSRID(ST_MakePoint(-99.2285223588608, 19.47375676818), 4326), ST_SetSRID(ST_MakePoint(-99.2319348869996, 19.4790829347871), 4326), ST_SetSRID(ST_MakePoint(-99.2350808843679, 19.4861748591816), 4326), ST_SetSRID(ST_MakePoint(-99.2372188516262, 19.4942303629856), 4326)])))
ON CONFLICT DO NOTHING;

INSERT INTO ramals (linea_id, nombre_ramal, estado, ramal_num, geom)
VALUES (3072, 'Periférico Interior Poniente - REGRESO', 'Propuesta académica', 0,
    ST_Multi(ST_MakeLine(ARRAY[ST_SetSRID(ST_MakePoint(-99.2372188516262, 19.4942303629856), 4326), ST_SetSRID(ST_MakePoint(-99.2350808843679, 19.4861748591816), 4326), ST_SetSRID(ST_MakePoint(-99.2319348869996, 19.4790829347871), 4326), ST_SetSRID(ST_MakePoint(-99.2285223588608, 19.47375676818), 4326), ST_SetSRID(ST_MakePoint(-99.2245013622917, 19.4660189895512), 4326), ST_SetSRID(ST_MakePoint(-99.2205876390333, 19.4587801108788), 4326), ST_SetSRID(ST_MakePoint(-99.216389674011, 19.4423772420843), 4326), ST_SetSRID(ST_MakePoint(-99.214626690685, 19.4392638928012), 4326), ST_SetSRID(ST_MakePoint(-99.2129461326464, 19.4367463974964), 4326), ST_SetSRID(ST_MakePoint(-99.2080967842068, 19.4320351650801), 4326), ST_SetSRID(ST_MakePoint(-99.2033829224792, 19.427271778236), 4326), ST_SetSRID(ST_MakePoint(-99.1990471598163, 19.4227045760294), 4326), ST_SetSRID(ST_MakePoint(-99.1948212702859, 19.4179379699072), 4326), ST_SetSRID(ST_MakePoint(-99.1941158560232, 19.4112098768217), 4326), ST_SetSRID(ST_MakePoint(-99.1918864435316, 19.4064246330255), 4326), ST_SetSRID(ST_MakePoint(-99.1917529384344, 19.4001935073707), 4326), ST_SetSRID(ST_MakePoint(-99.1887382399895, 19.3955383249044), 4326), ST_SetSRID(ST_MakePoint(-99.188913461022, 19.3909745202463), 4326), ST_SetSRID(ST_MakePoint(-99.1912526191116, 19.3847724156345), 4326), ST_SetSRID(ST_MakePoint(-99.1915218752405, 19.3762729468749), 4326), ST_SetSRID(ST_MakePoint(-99.193938817374, 19.3721026926363), 4326), ST_SetSRID(ST_MakePoint(-99.1911488730648, 19.366922941138), 4326), ST_SetSRID(ST_MakePoint(-99.1912054597844, 19.3617955262867), 4326), ST_SetSRID(ST_MakePoint(-99.1988823295185, 19.3557316805212), 4326), ST_SetSRID(ST_MakePoint(-99.2020378704102, 19.3479263629079), 4326), ST_SetSRID(ST_MakePoint(-99.2032322288589, 19.3408894521725), 4326), ST_SetSRID(ST_MakePoint(-99.2089943081942, 19.3342970580488), 4326), ST_SetSRID(ST_MakePoint(-99.2109659153388, 19.3306707865798), 4326), ST_SetSRID(ST_MakePoint(-99.2120483506634, 19.3286106861771), 4326), ST_SetSRID(ST_MakePoint(-99.2156603800189, 19.324062314384), 4326), ST_SetSRID(ST_MakePoint(-99.220328643837, 19.320925949733), 4326)])))
ON CONFLICT DO NOTHING;

INSERT INTO ramals (linea_id, nombre_ramal, estado, ramal_num, geom)
VALUES (3073, 'Periférico Interior Norte - IDA', 'Propuesta académica', 1,
    ST_Multi(ST_MakeLine(ARRAY[ST_SetSRID(ST_MakePoint(-99.2372188516262, 19.4942303629856), 4326), ST_SetSRID(ST_MakePoint(-99.237, 19.502), 4326), ST_SetSRID(ST_MakePoint(-99.2368132396803, 19.5092138203163), 4326), ST_SetSRID(ST_MakePoint(-99.2306362052263, 19.5193013624258), 4326), ST_SetSRID(ST_MakePoint(-99.2185048168838, 19.5185963862678), 4326), ST_SetSRID(ST_MakePoint(-99.2117073099832, 19.5168414273159), 4326), ST_SetSRID(ST_MakePoint(-99.1964973796254, 19.5170094114134), 4326), ST_SetSRID(ST_MakePoint(-99.1793753322663, 19.5116041682883), 4326), ST_SetSRID(ST_MakePoint(-99.1729985503897, 19.5145114374118), 4326), ST_SetSRID(ST_MakePoint(-99.1655936278391, 19.5124915987051), 4326), ST_SetSRID(ST_MakePoint(-99.1603951642349, 19.512747482633), 4326), ST_SetSRID(ST_MakePoint(-99.154068179484, 19.5146094622948), 4326), ST_SetSRID(ST_MakePoint(-99.1430542558633, 19.5180624295389), 4326), ST_SetSRID(ST_MakePoint(-99.1345326557674, 19.5179557253226), 4326), ST_SetSRID(ST_MakePoint(-99.1242526088899, 19.5191546977744), 4326), ST_SetSRID(ST_MakePoint(-99.114145246139, 19.5214580487031), 4326), ST_SetSRID(ST_MakePoint(-99.1012458364103, 19.5147915769313), 4326), ST_SetSRID(ST_MakePoint(-99.0859313881947, 19.5071286247817), 4326), ST_SetSRID(ST_MakePoint(-99.0779649889604, 19.5038193655209), 4326), ST_SetSRID(ST_MakePoint(-99.0642759104053, 19.4982680721875), 4326), ST_SetSRID(ST_MakePoint(-99.053966727543, 19.4938637992146), 4326), ST_SetSRID(ST_MakePoint(-99.0466020294544, 19.4911807713892), 4326), ST_SetSRID(ST_MakePoint(-99.0388115288086, 19.4873294113852), 4326), ST_SetSRID(ST_MakePoint(-99.0316621504572, 19.4793309527282), 4326)])))
ON CONFLICT DO NOTHING;

INSERT INTO ramals (linea_id, nombre_ramal, estado, ramal_num, geom)
VALUES (3073, 'Periférico Interior Norte - REGRESO', 'Propuesta académica', 0,
    ST_Multi(ST_MakeLine(ARRAY[ST_SetSRID(ST_MakePoint(-99.0316621504572, 19.4793309527282), 4326), ST_SetSRID(ST_MakePoint(-99.0388115288086, 19.4873294113852), 4326), ST_SetSRID(ST_MakePoint(-99.0466020294544, 19.4911807713892), 4326), ST_SetSRID(ST_MakePoint(-99.053966727543, 19.4938637992146), 4326), ST_SetSRID(ST_MakePoint(-99.0642759104053, 19.4982680721875), 4326), ST_SetSRID(ST_MakePoint(-99.0779649889604, 19.5038193655209), 4326), ST_SetSRID(ST_MakePoint(-99.0859313881947, 19.5071286247817), 4326), ST_SetSRID(ST_MakePoint(-99.1012458364103, 19.5147915769313), 4326), ST_SetSRID(ST_MakePoint(-99.114145246139, 19.5214580487031), 4326), ST_SetSRID(ST_MakePoint(-99.1242526088899, 19.5191546977744), 4326), ST_SetSRID(ST_MakePoint(-99.1345326557674, 19.5179557253226), 4326), ST_SetSRID(ST_MakePoint(-99.1430542558633, 19.5180624295389), 4326), ST_SetSRID(ST_MakePoint(-99.154068179484, 19.5146094622948), 4326), ST_SetSRID(ST_MakePoint(-99.1603951642349, 19.512747482633), 4326), ST_SetSRID(ST_MakePoint(-99.1655936278391, 19.5124915987051), 4326), ST_SetSRID(ST_MakePoint(-99.1729985503897, 19.5145114374118), 4326), ST_SetSRID(ST_MakePoint(-99.1793753322663, 19.5116041682883), 4326), ST_SetSRID(ST_MakePoint(-99.1964973796254, 19.5170094114134), 4326), ST_SetSRID(ST_MakePoint(-99.2117073099832, 19.5168414273159), 4326), ST_SetSRID(ST_MakePoint(-99.2185048168838, 19.5185963862678), 4326), ST_SetSRID(ST_MakePoint(-99.2306362052263, 19.5193013624258), 4326), ST_SetSRID(ST_MakePoint(-99.2368132396803, 19.5092138203163), 4326), ST_SetSRID(ST_MakePoint(-99.237, 19.502), 4326), ST_SetSRID(ST_MakePoint(-99.2372188516262, 19.4942303629856), 4326)])))
ON CONFLICT DO NOTHING;

INSERT INTO ramals (linea_id, nombre_ramal, estado, ramal_num, geom)
VALUES (3074, 'Periférico Interior Oriente - IDA', 'Propuesta académica', 1,
    ST_Multi(ST_MakeLine(ARRAY[ST_SetSRID(ST_MakePoint(-99.0316621504572, 19.4793309527282), 4326), ST_SetSRID(ST_MakePoint(-99.0356457017992, 19.4730405471889), 4326), ST_SetSRID(ST_MakePoint(-99.0373166530742, 19.4666123777387), 4326), ST_SetSRID(ST_MakePoint(-99.0383847433583, 19.4571699263318), 4326), ST_SetSRID(ST_MakePoint(-99.0522269700144, 19.4297107907808), 4326), ST_SetSRID(ST_MakePoint(-99.0554993142479, 19.4223645933323), 4326), ST_SetSRID(ST_MakePoint(-99.0567857536576, 19.4119961559513), 4326), ST_SetSRID(ST_MakePoint(-99.0575875865377, 19.4046000958895), 4326), ST_SetSRID(ST_MakePoint(-99.0579318907728, 19.3983599751904), 4326), ST_SetSRID(ST_MakePoint(-99.0599752608567, 19.3896460289669), 4326), ST_SetSRID(ST_MakePoint(-99.0606372559403, 19.3820692425108), 4326), ST_SetSRID(ST_MakePoint(-99.0601250788034, 19.3767183843786), 4326), ST_SetSRID(ST_MakePoint(-99.0574385618996, 19.3633810991953), 4326), ST_SetSRID(ST_MakePoint(-99.0596560450222, 19.3535104905475), 4326), ST_SetSRID(ST_MakePoint(-99.0626549863211, 19.3450857602017), 4326), ST_SetSRID(ST_MakePoint(-99.0642540491586, 19.3391428958489), 4326), ST_SetSRID(ST_MakePoint(-99.067599524439, 19.3283774337608), 4326), ST_SetSRID(ST_MakePoint(-99.0745175260824, 19.3176186017939), 4326)])))
ON CONFLICT DO NOTHING;

INSERT INTO ramals (linea_id, nombre_ramal, estado, ramal_num, geom)
VALUES (3074, 'Periférico Interior Oriente - REGRESO', 'Propuesta académica', 0,
    ST_Multi(ST_MakeLine(ARRAY[ST_SetSRID(ST_MakePoint(-99.0745175260824, 19.3176186017939), 4326), ST_SetSRID(ST_MakePoint(-99.067599524439, 19.3283774337608), 4326), ST_SetSRID(ST_MakePoint(-99.0642540491586, 19.3391428958489), 4326), ST_SetSRID(ST_MakePoint(-99.0626549863211, 19.3450857602017), 4326), ST_SetSRID(ST_MakePoint(-99.0596560450222, 19.3535104905475), 4326), ST_SetSRID(ST_MakePoint(-99.0574385618996, 19.3633810991953), 4326), ST_SetSRID(ST_MakePoint(-99.0601250788034, 19.3767183843786), 4326), ST_SetSRID(ST_MakePoint(-99.0606372559403, 19.3820692425108), 4326), ST_SetSRID(ST_MakePoint(-99.0599752608567, 19.3896460289669), 4326), ST_SetSRID(ST_MakePoint(-99.0579318907728, 19.3983599751904), 4326), ST_SetSRID(ST_MakePoint(-99.0575875865377, 19.4046000958895), 4326), ST_SetSRID(ST_MakePoint(-99.0567857536576, 19.4119961559513), 4326), ST_SetSRID(ST_MakePoint(-99.0554993142479, 19.4223645933323), 4326), ST_SetSRID(ST_MakePoint(-99.0522269700144, 19.4297107907808), 4326), ST_SetSRID(ST_MakePoint(-99.0383847433583, 19.4571699263318), 4326), ST_SetSRID(ST_MakePoint(-99.0373166530742, 19.4666123777387), 4326), ST_SetSRID(ST_MakePoint(-99.0356457017992, 19.4730405471889), 4326), ST_SetSRID(ST_MakePoint(-99.0316621504572, 19.4793309527282), 4326)])))
ON CONFLICT DO NOTHING;

-- =====================================================
-- 4. HISTÓRICO DE OPERACIÓN (velocidad y frecuencia)
-- =====================================================
INSERT INTO historico_operacion (linea_id, ramal_id, velocidad_promedio_kmh, frecuencia_minutos, fuente)
SELECT 3071, r.id, 36.0, 3.0, 'Propuesta académica Anillo Periférico Interior 2026'
FROM ramals r
WHERE r.linea_id = 3071 AND r.ramal_num = 1
  AND NOT EXISTS (SELECT 1 FROM historico_operacion h WHERE h.ramal_id = r.id);

INSERT INTO historico_operacion (linea_id, ramal_id, velocidad_promedio_kmh, frecuencia_minutos, fuente)
SELECT 3071, r.id, 36.0, 3.0, 'Propuesta académica Anillo Periférico Interior 2026'
FROM ramals r
WHERE r.linea_id = 3071 AND r.ramal_num = 0
  AND NOT EXISTS (SELECT 1 FROM historico_operacion h WHERE h.ramal_id = r.id);

INSERT INTO historico_operacion (linea_id, ramal_id, velocidad_promedio_kmh, frecuencia_minutos, fuente)
SELECT 3072, r.id, 36.0, 3.0, 'Propuesta académica Anillo Periférico Interior 2026'
FROM ramals r
WHERE r.linea_id = 3072 AND r.ramal_num = 1
  AND NOT EXISTS (SELECT 1 FROM historico_operacion h WHERE h.ramal_id = r.id);

INSERT INTO historico_operacion (linea_id, ramal_id, velocidad_promedio_kmh, frecuencia_minutos, fuente)
SELECT 3072, r.id, 36.0, 3.0, 'Propuesta académica Anillo Periférico Interior 2026'
FROM ramals r
WHERE r.linea_id = 3072 AND r.ramal_num = 0
  AND NOT EXISTS (SELECT 1 FROM historico_operacion h WHERE h.ramal_id = r.id);

INSERT INTO historico_operacion (linea_id, ramal_id, velocidad_promedio_kmh, frecuencia_minutos, fuente)
SELECT 3073, r.id, 36.0, 3.0, 'Propuesta académica Anillo Periférico Interior 2026'
FROM ramals r
WHERE r.linea_id = 3073 AND r.ramal_num = 1
  AND NOT EXISTS (SELECT 1 FROM historico_operacion h WHERE h.ramal_id = r.id);

INSERT INTO historico_operacion (linea_id, ramal_id, velocidad_promedio_kmh, frecuencia_minutos, fuente)
SELECT 3073, r.id, 36.0, 3.0, 'Propuesta académica Anillo Periférico Interior 2026'
FROM ramals r
WHERE r.linea_id = 3073 AND r.ramal_num = 0
  AND NOT EXISTS (SELECT 1 FROM historico_operacion h WHERE h.ramal_id = r.id);

INSERT INTO historico_operacion (linea_id, ramal_id, velocidad_promedio_kmh, frecuencia_minutos, fuente)
SELECT 3074, r.id, 36.0, 3.0, 'Propuesta académica Anillo Periférico Interior 2026'
FROM ramals r
WHERE r.linea_id = 3074 AND r.ramal_num = 1
  AND NOT EXISTS (SELECT 1 FROM historico_operacion h WHERE h.ramal_id = r.id);

INSERT INTO historico_operacion (linea_id, ramal_id, velocidad_promedio_kmh, frecuencia_minutos, fuente)
SELECT 3074, r.id, 36.0, 3.0, 'Propuesta académica Anillo Periférico Interior 2026'
FROM ramals r
WHERE r.linea_id = 3074 AND r.ramal_num = 0
  AND NOT EXISTS (SELECT 1 FROM historico_operacion h WHERE h.ramal_id = r.id);

-- =====================================================
-- Verificación post-carga
-- =====================================================
-- SELECT 'lineas' AS tabla, count(*) FROM lineas WHERE clasificacion = 'propuesta_periferico' AND sistema = 'METRO'
-- UNION ALL
-- SELECT 'estacions', count(*) FROM estacions WHERE sistema = 'METRO' AND id BETWEEN 30001 AND 30200
-- UNION ALL
-- SELECT 'ramals', count(*) FROM ramals WHERE linea_id BETWEEN 3071 AND 3074
-- UNION ALL
-- SELECT 'historico_operacion', count(*) FROM historico_operacion WHERE linea_id BETWEEN 3071 AND 3074;
