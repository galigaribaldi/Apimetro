package transporte

import (
	con "Apimetro/cmd/pkg/controller"

	models "Apimetro/cmd/pkg/models"
	"log"
)

// CreateEstacion inserts a new station into the database
func CreateEstacion(estacion models.Estacion) {
	con.DB.Create(&estacion)
}

// SearchEstaciones performs dynamic search on stations with JOIN to lines table
// Supports filters: sistema, id, nombre, linea_id, alcaldia_municipio, num_comercial, color_esp, color_en, es_cetram
func SearchEstaciones(filtros map[string]interface{}) []models.Estacion {
	var estaciones []models.Estacion
	query := con.DB.Model(&models.Estacion{})

	// Buscar por ID
	if id, ok := filtros["id"]; ok &&
		id != "" {
		query = query.Where("estacions.id = ?", id)
	}

	// Buscar por Linea id (guardada en la BD)
	if lineaID, ok := filtros["linea_id"]; ok &&
		lineaID != "" {
		query = query.Where("estacions.linea_id = ?", lineaID)
	}

	// Buscar por nombre de estaciones
	if nombre, ok := filtros["nombre"]; ok &&
		nombre != "" {
		query = query.Where("estacions.nombre ILIKE ?", "%"+nombre.(string)+"%")
	}

	// Buscar por alcaldía o municipio
	if alcaldia, ok := filtros["alcaldia_municipio"]; ok && alcaldia != "" {
		query = query.Where("estacions.alcaldia_municipio ILIKE ?", "%"+alcaldia.(string)+"%")
	}

	// Estaciones que necesitan JOIN (experimental)
	needsJoinLinea := false
	if _, ok := filtros["sistema"]; ok && filtros["sistema"] != "" {
		needsJoinLinea = true
	}
	if _, ok := filtros["num_comercial"]; ok && filtros["num_comercial"] != "" {
		needsJoinLinea = true
	}
	if _, ok := filtros["color_esp"]; ok && filtros["color_esp"] != "" {
		needsJoinLinea = true
	}
	if _, ok := filtros["color_en"]; ok && filtros["color_en"] != "" {
		needsJoinLinea = true
	}

	// Construccion final de la consulta con JOIN
	if needsJoinLinea {
		query = query.Joins("JOIN lineas ON lineas.id = estacions.linea_id")
	}

	// Filtros foráneos (Tabla Lineas)
	if sistema, ok := filtros["sistema"]; ok && sistema != "" {
		query = query.Where("lineas.sistema = ?", sistema)
	}
	if numComercial, ok := filtros["num_comercial"]; ok && numComercial != "" {
		query = query.Where("lineas.num_comercial = ?", numComercial)
	}
	if colorEsp, ok := filtros["color_esp"]; ok && colorEsp != "" {
		query = query.Where("lineas.color_esp ILIKE ?", "%"+colorEsp.(string)+"%")
	}
	if colorEn, ok := filtros["color_en"]; ok && colorEn != "" {
		query = query.Where("lineas.color_en ILIKE ?", "%"+colorEn.(string)+"%")
	}
	if esCetram, ok := filtros["es_cetram"]; ok && esCetram != "" {
		query = query.Where("estacions.es_cetram = ?", esCetram)
	}
	// Query Final
	if err := query.Find(&estaciones).Error; err != nil {
		log.Println("Error en la búsqueda dinámica de estaciones: ", err)
	}

	return estaciones
}

func DeleteEstacion(id int) {
	var estacion models.Estacion
	if result := con.DB.Delete(&estacion, id); result.Error != nil {
		log.Println("Error eliminando estación:", result.Error)
		return
	}
}

func UpdateEstacion(estacion models.Estacion) {
	if err := con.DB.Model(&estacion).Updates(estacion).Error; err != nil {
		log.Println("Error actualizando estación:", err)
	}
}
