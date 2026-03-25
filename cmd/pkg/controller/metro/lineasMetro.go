package metro

import (
	con "Apimetro/cmd/pkg/controller"
	models "Apimetro/cmd/pkg/models"
	"log"
)

/*
------
GET
------
*/
func SelectAllLines() []models.Linea {
	var lineas []models.Linea
	con.DB.Preload("Descripcion_linea").Preload("Ramales").Find(&lineas)
	return lineas
}

// Seleccionar por id
func SelectLinesById(id int) models.Linea {
	var linea models.Linea
	if result := con.DB.Preload("Descripcion_linea").Preload("Ramales").First(&linea, id); result.Error != nil {
		return linea
	}
	return linea
}

// Busqueda dinámica por filtros para construir el Query
func SearchLineas(filtros map[string]interface{}) []models.Linea {
	var lineas []models.Linea
	query := con.DB.Preload("Descripcion_linea").Preload("Ramales").Model(&models.Linea{})

	//Filtrar por Nombre del Ramal
	if ramal, ok := filtros["nombre_ramal"]; ok && ramal != "" {
		query = query.Joins("JOIN ramals ON ramals.linea_id = lineas.id").
			Where("ramals.nombre_ramal ILIKE ?", "%"+ramal.(string)+"%")
	}

	//Filtrar por nombre de la línea
	if nombre, ok := filtros["nombre"]; ok && nombre != "" {
		query = query.Where("lineas.nombre ILIKE ?", "%"+nombre.(string)+"%")
	}

	// Filtro por sistema (Clave para separar Metrobus, Cablebus, etc)
	if sistema, ok := filtros["sistema"]; ok && sistema != "" {
		query = query.Where("lineas.sistema = ?", sistema)
	}

	//Filtrar por numero Comercial de las lineas
	if numComercial, ok := filtros["num_comercial"]; ok && numComercial != "" {
		query = query.Where("lineas.num_comercial = ?", numComercial)
	}

	//Filtrar por clasificacion
	if clasificacion, ok := filtros["claisificacion"]; ok && clasificacion != "" {
		query = query.Where("lineas.clasificacion = ?", clasificacion)
	}

	// Filtrar por existencia
	if existe, ok := filtros["existe"]; ok {
		query = query.Where("lineas.existe = ?", existe)
	}

	// Filtrar por tamaño de Kilometros
	if tamKm, ok := filtros["tam_km"]; ok && tamKm != "" {
		query = query.Where("lineas.tam_km >= ?", tamKm)
	}

	/// Query Final
	if err := query.Find(&lineas).Error; err != nil {
		log.Println("Error en la busqueda dinámica de líneas: ", err)
	}

	return lineas
}

/*
------
POST
------
*/
func CreateLinea(linea models.Linea) error {
	result := con.DB.Create(&linea)
	log.Println("POST")
	return result.Error
}

/*
------
DELETE
------
*/
func DeleteLinea(id int) error {

	con.DB.Where("linea_id = ?", id).Delete(&models.Ramal{})
	con.DB.Where("linea_base = ?", id).Delete(&models.DescripcionLinea{})

	var linea models.Linea

	result := con.DB.Delete(&linea, id)
	return result.Error
}

/*
------
UPDATE
------
*/
func UpdateLinea(id int, dataActualizada map[string]interface{}) error {
	result := con.DB.Model(&models.Linea{}).
		Where("id = ?", id).
		Updates(dataActualizada)
	return result.Error
}
