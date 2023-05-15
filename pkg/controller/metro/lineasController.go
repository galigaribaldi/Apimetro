package metro

import (
	con "Apimetro/pkg/controller"

	models "Apimetro/pkg/models"
)

func init() {
	con.ConnectDataBase()
	con.DB.AutoMigrate()
	con.DB.AutoMigrate(&models.Linea{})
}

/*
------
POST
------
*/
func CreateLinea(linea models.Linea) {
	con.DB.Create(&linea)
}

/*
------
GET
------
*/

//Seleccionar todos
func SelectAllLines() []models.Linea {
	var lineas []models.Linea
	con.DB.Find(&lineas)
	return lineas
}

//Seleccionar por id
func SelectLinesById(id int) models.Linea {
	var linea models.Linea
	if result := con.DB.First(&linea, id); result.Error != nil {
		return linea
	}
	return linea
}

//Seleccionar por Color
func SelectLineByColor(color string) []models.Linea {
	var newLinea []models.Linea
	if result := con.DB.Where("color_esp LIKE ?", "%"+color+"%").Find(&newLinea); result.Error != nil {
		return newLinea
	}
	return newLinea
}

/*
------
DELETE
------
*/
func DeleteLinea(id int) {
	var linea models.Linea
	if result := con.DB.Delete(&linea, id); result.Error != nil {
		return
	}
}

/*
------
UPDATE
------
*/
func UpdateLinea(linea models.Linea) {
	con.DB.Model(&linea).Updates(models.Linea{
		Sistema:           linea.Sistema,
		Anio_inauguracion: linea.Anio_inauguracion,
		Color_en:          linea.Color_en,
		Color_esp:         linea.Color_esp,
	})
}
