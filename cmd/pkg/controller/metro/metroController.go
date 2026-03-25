package metro

import (
	con "Apimetro/cmd/pkg/controller"
	models "Apimetro/cmd/pkg/models"
	"log"
)

func init() {
	log.Println("Inicializando BD y módulo Metro")
	con.ConnectDataBase()

	err := con.DB.AutoMigrate(
		&models.Linea{},
		&models.Estacion{},
		//&models.Ramal{},
		//&models.DescripcionLinea{},
	)
	if err != nil {
		log.Println("Error en la migración del módulo Metro", err)
	}

}
