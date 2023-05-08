package metro

import (
	con "github.com/galigaribaldi/Apimetro/pkg/controller"
	models "github.com/galigaribaldi/Apimetro/pkg/models"
)

func init() {
	con.ConnectDataBase()
	con.DB.AutoMigrate()
	con.DB.AutoMigrate(&models.Linea{})
	con.DB.AutoMigrate(&models.Estacion{})
}

func SelectAllEstations() []models.Estacion {
	var estacion []models.Estacion
	return estacion
}
