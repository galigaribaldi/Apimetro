package metro

import (
	con "Apimetro/pkg/controller"
	"log"

	models "Apimetro/pkg/models"
)

func init() {
	con.ConnectDataBase()
	con.DB.AutoMigrate()
	con.DB.AutoMigrate(&models.Estacion{})
}

/*
------
POST
------
*/
//Crear estaciones
func CreateEstacion(estacion models.Estacion) {
	con.DB.Create(&estacion)
}

/*
------
GET
------
*/

//Seleccionar por nombre
func SelectEstacionbyName(name string) []models.Estacion {
	var estacion []models.Estacion
	if result := con.DB.Where("nombre LIKE ?", "%"+name+"%").Order("ID").Find(&estacion); result.Error != nil {
		return estacion
	}
	return estacion
}

//Seleccionar por Año (exacto)
func SelectEstacionbyAnio(anioEstacion string) []models.Estacion {
	var estacion []models.Estacion
	if result := con.DB.Where("anio = ?", anioEstacion).Order("ID").Find(&estacion); result.Error != nil {
		return estacion
	}
	return estacion
}

//Seleccionar por Año (Rango)
func SelectEstacionbyAnioRango(anioEstacionRango1 string, anioEstacionRango2 string) []models.Estacion {
	var estacion []models.Estacion
	//Antes del año
	if anioEstacionRango1 != "" && anioEstacionRango2 == "" {
		log.Println("Mayor al año: ", anioEstacionRango1)
		if result := con.DB.Where("anio <= ?", anioEstacionRango1).Find(&estacion); result.Error != nil {
			return estacion
		}
	}
	//Solo Despues
	if anioEstacionRango1 == "" && anioEstacionRango2 != "" {
		log.Println("Menor al año: ", anioEstacionRango2)
		if result := con.DB.Where("anio >= ?", anioEstacionRango2).Find(&estacion); result.Error != nil {
			return estacion
		}
	}
	//Entre Rangos
	if anioEstacionRango1 != "" && anioEstacionRango2 != "" {
		log.Println("Menor al año: ", anioEstacionRango2, " Mayor al año: ", anioEstacionRango1)
		if result := con.DB.Where("anio >= ? AND anio <= ?", anioEstacionRango1, anioEstacionRango2).Find(&estacion); result.Error != nil {
			return estacion
		}
	}
	return estacion
}

//Seleccionar por Localizacion (exacto)
func SelectEstacionbyCiudad(ciudadEstacion string) []models.Estacion {
	var estacion []models.Estacion
	if result := con.DB.Where("estado_ciudad LIKE ? ", "%"+ciudadEstacion+"%").Find(&estacion); result.Error != nil {
		return estacion
	}
	return estacion
}

//Seleccionar por Localizacion (exacto)
func SelectEstacionbyAlcaldia(alcaldiaEstacion string) []models.Estacion {
	var estacion []models.Estacion
	if result := con.DB.Where("alcaldia_municipio LIKE ? ", "%"+alcaldiaEstacion+"%").Find(&estacion); result.Error != nil {
		return estacion
	}
	return estacion
}

//Seleccionar por Linea de Metro
func SelectEstacionbyLineaID(lineaID int) []models.Estacion {
	var estacion []models.Estacion
	if result := con.DB.Where("linea_id = ?", lineaID).Order("ID").Find(&estacion); result.Error != nil {
		return estacion
	}
	return estacion
}

//Seleccionar por Color Español - Ingles
func SelectEstacionbyColor(color string, idioma string) []models.Estacion {
	var linea models.Linea
	var estacion []models.Estacion
	if idioma == "esp" {
		log.Println("Español esp")
		if result := con.DB.Where("color_esp = ? ", color).First(&linea); result.Error != nil {
			return estacion
		}
		if result := con.DB.Where("linea_id = ?", linea.ID).Find(&estacion); result.Error != nil {
			return estacion
		}
		return estacion
	}
	if idioma == "en" {
		log.Println("Ingles en")
		if result := con.DB.Where("color_en = ? ", color).First(&linea); result.Error != nil {
			return estacion
		}
		if result := con.DB.Where("linea_id = ?", linea.ID).Find(&estacion); result.Error != nil {
			return estacion
		}
		return estacion
	}
	return estacion
}

//Todas las estaciones
func SelectAllEstations() []models.Estacion {
	var estacion []models.Estacion
	con.DB.Find(&estacion)
	return estacion
}

/*
------
DELETE
------
*/
func DeleteEstacion(id int) {
	var estacion models.Estacion
	if result := con.DB.Delete(&estacion, id); result.Error != nil {
		return
	}
}

/*
------
UPDATE
------
*/
func UpdateEstacion(estacion models.Estacion) {
	con.DB.Model(&estacion).Updates(models.Estacion{
		Nombre:             estacion.Nombre,
		Cve_est:            estacion.Cve_est,
		Tipo:               estacion.Tipo,
		Alcaldia_municipio: estacion.Alcaldia_municipio,
		Anio:               estacion.Anio,
		Estado_ciudad:      estacion.Estado_ciudad,
		Longitud:           estacion.Longitud,
		Latitud:            estacion.Latitud,
		LineaID:            estacion.LineaID,
	})
}
