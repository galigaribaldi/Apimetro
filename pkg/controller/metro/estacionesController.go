package metro

import (
	con "Apimetro/pkg/controller"

	models "Apimetro/pkg/models"
)

func init() {
	con.ConnectDataBase()
	con.DB.AutoMigrate()
	con.DB.AutoMigrate(&models.Estacion{})
}

func SelectAllEstations() []models.Estacion {
	var estacion []models.Estacion
	con.DB.Find(&estacion)
	return estacion
}
func CreateEstacion(estacion models.Estacion) {
	con.DB.Create(&estacion)
}
