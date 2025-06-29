package controller

import (
	models "Apimetro/cmd/pkg/models"
	"log"
	"os"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

var DB *gorm.DB

func ConnectDataBase() {
	log.Println(os.Getenv("DATABASE_URL"))
	dbURL := "postgresql://prueba:postgres@localhost:5432/db_apimetro"
	//dbURL := os.Getenv("DATABSAE_URL")
	//postgresql://postgres:postgres@localhost:5433/Data

	database, err := gorm.Open(postgres.Open(dbURL), &gorm.Config{})

	if err != nil {
		log.Fatalln(err)
	}
	database.AutoMigrate(&models.Linea{})
	log.Println("Conexion exitosa")
	DB = database
}
