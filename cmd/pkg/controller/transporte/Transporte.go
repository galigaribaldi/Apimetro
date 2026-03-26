package transporte

import (
	con "Apimetro/cmd/pkg/controller"
	models "Apimetro/cmd/pkg/models"
	"log"
)

func init() {
	log.Println("Inicializando BD y módulo de Transporte")
	con.ConnectDataBase()

	err := con.DB.AutoMigrate(
		&models.Linea{},
		&models.Estacion{},
		&models.DescripcionLinea{},
		//&models.Ramal{},
	)
	if err != nil {
		log.Println("Error en la migración del módulo Metro", err)
	}

}
