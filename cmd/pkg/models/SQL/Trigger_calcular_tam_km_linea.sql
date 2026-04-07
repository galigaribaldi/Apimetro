CREATE OR REPLACE FUNCTION calcular_tam_km_linea()
RETURNS TRIGGER AS $$
BEGIN
    -- Si estamos insertando o actualizando un ramal
    IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
        UPDATE lineas
        SET tam_km = (
            SELECT COALESCE(ST_Length(ST_Union(geom)::geography) / 1000.0, 0)
            FROM ramals
            WHERE linea_id = NEW.linea_id
        )
        WHERE id = NEW.linea_id;
    END IF;

    -- Si estamos borrando un ramal (usamos OLD porque NEW ya no existe)
    IF (TG_OP = 'DELETE') THEN
        UPDATE lineas
        SET tam_km = (
            SELECT COALESCE(ST_Length(ST_Union(geom)::geography) / 1000.0, 0)
            FROM ramals
            WHERE linea_id = OLD.linea_id
        )
        WHERE id = OLD.linea_id;
    END IF;

    RETURN NULL; -- Es un trigger AFTER, no necesitamos retornar nada
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_actualizar_tam_km ON ramals;

CREATE TRIGGER trigger_actualizar_tam_km
AFTER INSERT OR UPDATE OR DELETE ON ramals
FOR EACH ROW
EXECUTE FUNCTION calcular_tam_km_linea();

UPDATE lineas l
SET tam_km = (
    SELECT COALESCE(ST_Length(ST_Union(r.geom)::geography) / 1000.0, 0)
    FROM ramals r
    WHERE r.linea_id = l.id
);
