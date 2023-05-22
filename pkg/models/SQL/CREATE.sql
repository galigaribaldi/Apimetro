CREATE TABLE lineas(
    ID                  integer PRIMARY KEY,
    sistema             character varying,
    nombre              character varying,
    anio_inauguracion   integer,
    color_en            character varying,
    color_esp           character varying,
    tam_km              float
);
CREATE TABLE estacions(
    ID                  SERIAL PRIMARY KEY,
    nombre              character varying,
    cve_est             character varying,
    tipo                character varying,
    alcaldia_municipio  character varying,
    anio                character varying,
    estado_ciudad       character varying,
    longitud            float,
    latitud             float,
    linea_id               integer,
    CONSTRAINT linea_id_fk FOREIGN KEY (linea_id)
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