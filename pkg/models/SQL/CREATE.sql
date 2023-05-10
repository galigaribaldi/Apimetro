CREATE TABLE lineas(
    linea_id                  integer PRIMARY KEY,
    sistema             character varying,
    anio_inauguracion   integer,
    color_en            character varying,
    color_esp           character varying
);
CREATE TABLE estacions(
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
    CONSTRAINT linea_fk FOREIGN KEY (linea)
    REFERENCES lineas (ID)
);

/*
create extension postgis;

create extension postgis_topology

create table edificacion (
	gid serial primary key,
	tipo varchar(25),
	estado varchar(25),
	geom geometry
);

create table cubierta_vegetal (
	gid serial primary key,
	tipo varchar(25),
	area double precision,
	geom geometry
);

create table viasl (
	gid serial primary key,
	tipo varchar(25),
	longitud double precision,
	geom geometry
);
*/