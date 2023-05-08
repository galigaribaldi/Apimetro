package metro

import (
	con "Apimetro/pkg/controller"

	models "Apimetro/pkg/models"
)

func init() {
	con.ConnectDataBase()
	con.DB.AutoMigrate()
	con.DB.AutoMigrate(&models.Linea{})
	//con.DB.AutoMigrate(&models.Estacion{})
}

func SelectAllEstations() []models.Estacion {
	var estacion []models.Estacion
	return estacion
}

func SelectAllLines() []models.Linea {
	var lineas []models.Linea
	con.DB.Find(&lineas)
	return lineas
}
func SelectLinesById(id int) models.Linea {
	var linea models.Linea
	if result := con.DB.First(&linea, id); result.Error != nil {
		return linea
	}
	return linea
}
func SelectLineByColor(color string) []models.Linea {
	var newLinea []models.Linea
	if result := con.DB.Where("color_esp LIKE ?", "%"+color+"%").Find(&newLinea); result.Error != nil {
		return newLinea
	}
	return newLinea
}
func CreateLinea(linea models.Linea) {
	con.DB.Create(&linea)
}
