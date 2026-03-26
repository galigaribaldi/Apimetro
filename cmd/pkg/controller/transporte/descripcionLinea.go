package transporte

import (
	con "Apimetro/cmd/pkg/controller"

	models "Apimetro/cmd/pkg/models"
	"log"
)

/*
-------
POST En Descripcion Línea
-------
*/

func CreateDescripcionLinea(descripcionLinea models.DescripcionLinea) {
	if err := con.DB.Create(&descripcionLinea).Error; err != nil {
		log.Println("Error en la creacion de Descripcion de Linea", err)
	}
}

/*
-------
GET en Descripcion Linea
-------
*/
func SearchDescripcionesLinea(filtros map[string]interface{}) []models.DescripcionLinea {
	var descripciones []models.DescripcionLinea
	query := con.DB.Model(&models.DescripcionLinea{})

	// Filtrar por ID (Exacto)
	if id, ok := filtros["id"]; ok && id != "" && id != 0 {
		query = query.Where("id = ?", id)
	}

	// Filtrar por Terminal Original
	if terminal, ok := filtros["terminal_original"]; ok && terminal != "" {
		query = query.Where("terminal_original ILIKE ?", "%"+terminal.(string)+"%")
	}

	// Filtrar por Línea Base
	if lineaBase, ok := filtros["linea_base"]; ok && lineaBase != "" {
		query = query.Where("linea_base = ?", lineaBase)
	}

	// Unir tablas por sistema o num_comercial con JOINS
	needsJoinLinea := false
	if _, ok := filtros["sistema"]; ok && filtros["sistema"] != "" {
		needsJoinLinea = true
	}
	if _, ok := filtros["num_comercial"]; ok && filtros["num_comercial"] != "" {
		needsJoinLinea = true
	}

	if needsJoinLinea {
		query = query.Joins("JOIN lineas ON lineas.id = descripcion_lineas.linea_base")
	}

	// Aplicamos los filtros de la tabla foránea 'lineas'
	if sistema, ok := filtros["sistema"]; ok && sistema != "" {
		query = query.Where("lineas.sistema = ?", sistema)
	}
	if numComercial, ok := filtros["num_comercial"]; ok && numComercial != "" {
		query = query.Where("lineas.num_comercial = ?", numComercial)
	}

	if err := query.Find(&descripciones).Error; err != nil {
		log.Println("Error en la búsqueda dinámica de descripciones de Líneas:", err)
	}

	return descripciones
}

/*
-------
UPDATE
-------
*/
func UpdateDescripcionLinea(descripcion models.DescripcionLinea) {
	if err := con.DB.Model(&descripcion).Where("id = ?", descripcion.ID).Updates(descripcion).Error; err != nil {
		log.Println("Error actualizando la descripción de la línea:", err)
	}
}

/*
-------
DELETE
-------
*/
func DeleteDescripcionLinea(id int) {
	if err := con.DB.Delete(&models.DescripcionLinea{}, id).Error; err != nil {
		log.Println("Error eliminando la descripción de la línea con ID", id, ":", err)
	}
}
