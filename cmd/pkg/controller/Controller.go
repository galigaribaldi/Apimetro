package controller

import (
	models "Apimetro/cmd/pkg/models"
	"log"
	"os"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

var DB *gorm.DB

// ConnectDataBase se encarga de conectarse a la base de datos PostgreSQL y realizar la migración de las tablas.
func ConnectDataBase() {
	log.Println(os.Getenv("DATABASE_URL"))
	//dbURL := "postgresql://postgres:postgress@localhost:5433/Data"
	dbURL := os.Getenv("DATABASE_URL")
	//postgresql://postgres:postgress@localhost:5433/Data

	database, err := gorm.Open(postgres.Open(dbURL), &gorm.Config{})
	if err != nil {
		log.Fatalln(err)
	}

	database.AutoMigrate(
		&models.Linea{},
		&models.Ramal{},
		&models.Estacion{},
		&models.DescripcionLinea{},
		&models.DescripcionEstacion{},
	)
	if err != nil {
		log.Fatal("Error durante la migración:", err)
	}
	log.Println("Conexion y Migracion exitosa")
	DB = database
}
