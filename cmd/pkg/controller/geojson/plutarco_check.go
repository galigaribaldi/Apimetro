package geojson

import (
	con "Apimetro/cmd/pkg/controller"
)

// PluarcoTableHasData verifica si una tabla del esquema plutarco tiene al menos un registro.
// Usado para distinguir "extensión no activada" (tabla vacía) de "filtros sin resultados".
func PluarcoTableHasData(tableName string) bool {
	var exists bool
	con.DB.Raw("SELECT EXISTS(SELECT 1 FROM plutarco." + tableName + " LIMIT 1)").Scan(&exists)
	return exists
}
