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
<<<<<<< HEAD:cmd/pkg/controller/Controller.go
	log.Println("Variable: ",os.Getenv("DATABASE_URL"))
	dbURL := "postgresql://postgres:postgress@localhost:5432/data";
=======
	log.Println(os.Getenv("DATABASE_URL"))
	//dbURL := "postgresql://postgres:postgress@localhost:5433/Data"
	dbURL := os.Getenv("DATABASE_URL")
>>>>>>> main:pkg/controller/Controller.go
	//postgresql://postgres:postgress@localhost:5433/Data

	database, err := gorm.Open(postgres.Open(dbURL), &gorm.Config{})

	if err != nil {
		log.Fatalln(err)
	}
	database.AutoMigrate(&models.Linea{})
	log.Println("Conexion exitosa")
	DB = database
}
