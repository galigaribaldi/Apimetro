CREATE TABLE estacion(
    estacion_id         SERIAL PRIMARY KEY,
    nombre              character varying,
    cve_est             character varying,
    tipo                character varying,
    alcaldia_municipio  character varying,
    anio                character varying,
    estado_ciudad       character varying,
    longitud            float,
    latitud             float,
    linea               integer,
    ubicacion           point,
    CONSTRAINT linea_fk FOREIGN KEY (linea)
    REFERENCES linea (linea_id)
);

CREATE TABLE lineas(
    ID                  integer PRIMARY KEY,
    sistema             character varying,
    anio_inauguracion   integer,
    color_en            character varying,
    color_esp           character varying,
    ubicacion           line
);