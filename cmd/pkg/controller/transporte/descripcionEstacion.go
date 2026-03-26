package transporte

import (
	con "Apimetro/cmd/pkg/controller"

	models "Apimetro/cmd/pkg/models"
	"log"
)

/*
-------
POST En Descripcion Estacion
-------
*/

func CreateDescripcionEstacion(descripcionEstacion models.DescripcionEstacion) {
	if err := con.DB.Create(&descripcionEstacion).Error; err != nil {
		log.Println("Error en la creación de Descripción de Estación", err)
	}
}

/*
-------
GET
-----
*/
func SearchDescripcionesEstacion(filtros map[string]interface{}) []models.DescripcionEstacion {
	var descripciones []models.DescripcionEstacion
	query := con.DB.Model(&models.DescripcionEstacion{})

	// Filtrar por ID
	if id, ok := filtros["id"]; ok && id != "" && id != 0 {
		query = query.Where("id = ?", id)
	}

	// Filtrar por Nombre de la estación
	if nombre, ok := filtros["nombre"]; ok && nombre != "" {
		query = query.Where("nombre ILIKE ?", "%"+nombre.(string)+"%")
	}

	// Filtrar por Alcaldía o Municipio
	if alcaldia, ok := filtros["alcaldia_municipio"]; ok && alcaldia != "" {
		query = query.Where("alcaldia_municipio ILIKE ?", "%"+alcaldia.(string)+"%")
	}

	// Filtrar por num_comercial o sistema con JOINS
	needsJoinLinea := false
	if _, ok := filtros["sistema"]; ok && filtros["sistema"] != "" {
		needsJoinLinea = true
	}
	if _, ok := filtros["num_comercial"]; ok && filtros["num_comercial"] != "" {
		needsJoinLinea = true
	}

	if needsJoinLinea {
		query = query.
			Joins("JOIN estacions ON estacions.id = descripcion_estacions.estacion_id").
			Joins("JOIN lineas ON lineas.id = estacions.linea_id")
	}

	// Aplicamos los filtros de la tabla foránea 'lineas'
	if sistema, ok := filtros["sistema"]; ok && sistema != "" {
		query = query.Where("lineas.sistema = ?", sistema)
	}
	if numComercial, ok := filtros["num_comercial"]; ok && numComercial != "" {
		query = query.Where("lineas.num_comercial = ?", numComercial)
	}

	if err := query.Find(&descripciones).Error; err != nil {
		log.Println("Error en la búsqueda dinámica de descripciones de Estaciones:", err)
	}

	return descripciones
}

/*
-------
UPDATE
-------
*/
func UpdateDescripcionEstacion(descripcion models.DescripcionEstacion) {
	if err := con.DB.Model(&descripcion).Where("id = ?", descripcion.ID).Updates(descripcion).Error; err != nil {
		log.Println("Error actualizando la descripción de la estación:", err)
	}
}

/*
-------
DELETE
-------
*/
func DeleteDescripcionEstacion(id int) {
	if err := con.DB.Delete(&models.DescripcionEstacion{}, id).Error; err != nil {
		log.Println("Error eliminando la descripción de la estación con ID", id, ":", err)
	}
}
