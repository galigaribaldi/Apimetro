-- =====================================================
-- MIGRACIÓN v3.0 — Afluencia por estación (Metro)
-- Issue: #45
-- Idempotente: IF NOT EXISTS en todas las sentencias
--
-- Fuente: datos.cdmx.gob.mx — Afluencia Diaria del Metro (Simple)
-- Granularidad: 1 fila = 1 estación × 1 mes × 1 año
-- Cobertura: enero 2010 — presente (~37K registros)
-- =====================================================

CREATE TABLE IF NOT EXISTS plutarco.afluencia_estacion (
    id            SERIAL PRIMARY KEY,
    estacion_id   INTEGER REFERENCES public.estacions(id),
    linea_id      INTEGER REFERENCES public.lineas(id),
    anio          SMALLINT NOT NULL,
    mes_num       SMALLINT NOT NULL,
    mes           VARCHAR(20),
    afluencia     BIGINT NOT NULL,
    fuente        TEXT DEFAULT 'STC-Metro-DatosAbiertos',
    created_at    TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(estacion_id, anio, mes_num)
);

CREATE INDEX IF NOT EXISTS idx_afluencia_estacion_id    ON plutarco.afluencia_estacion (estacion_id);
CREATE INDEX IF NOT EXISTS idx_afluencia_estacion_linea ON plutarco.afluencia_estacion (linea_id);
CREATE INDEX IF NOT EXISTS idx_afluencia_estacion_anio  ON plutarco.afluencia_estacion (anio, mes_num);

-- Permisos para el rol de lectura
GRANT SELECT ON plutarco.afluencia_estacion TO apimetro_read;
