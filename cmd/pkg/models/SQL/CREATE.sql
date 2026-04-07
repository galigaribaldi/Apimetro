CREATE TABLE lineas (
    ID integer PRIMARY KEY,
    sistema character varying,
    nombre character varying,
    anio_inauguracion integer,
    color_en character varying,
    color_esp character varying,
    tam_km float
);

CREATE TABLE estacions (
    ID SERIAL PRIMARY KEY,
    nombre character varying,
    cve_est character varying,
    tipo character varying,
    alcaldia_municipio character varying,
    anio character varying,
    estado_ciudad character varying,
    longitud float,
    latitud float,
    linea_id integer,
    num_estacion integer,
    estacion_id_oficial integer,
    sistema character varying,
    CONSTRAINT linea_id_fk FOREIGN KEY (linea_id) REFERENCES lineas (ID)
);

/*
create extension postgis;

create extension postgis_topology

*/
--- Actualizacion para poder guardar jerarquias y derechos de vías
ALTER TABLE lineas
ADD COLUMN jerarquia_transporte VARCHAR(50), -- 'masivo' o 'superficie'
ADD COLUMN derecho_de_via VARCHAR(50), -- 'exclusivo' o 'compartido'
ADD COLUMN capacidad_vehiculo INTEGER;
-- Ej. 1530 para Metro, 90 para RTP

CREATE TABLE historico_operacion (
    id SERIAL PRIMARY KEY,
    linea_id INTEGER REFERENCES lineas (id),
    ramal_id INTEGER REFERENCES ramals (id),
    velocidad_promedio_kmh NUMERIC(5, 2),
    frecuencia_minutos NUMERIC(5, 2),
    fuente VARCHAR(100), -- Para saber si vino del GTFS, Google API, o manual
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índices para optimizar las consultas de la API en Go
CREATE INDEX idx_historico_fecha ON historico_operacion (fecha_registro DESC);

CREATE INDEX idx_historico_ramal ON historico_operacion (ramal_id);

select count(*) from lineas;
---301
select
    count(*) as "'TOTAL_LINEAS'",
    (
        select count(*)
        from lineas
        where
            capacidad_vehiculo is null
    ) as "'TOTAL_CAP_V_NULL'",
    (
        select count(*)
        from lineas
        where
            derecho_de_via is null
    ) as "'TOTAL_DER_V_NULL'"
from lineas;

select count(*)
from historico_operacion
where
    frecuencia_minutos is null;

select * from lineas;