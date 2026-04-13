package controller

import (
	models "Apimetro/cmd/pkg/models"
	"fmt"
	"log"
	"os"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

var DB *gorm.DB

// ConnectDataBase establece la conexión con PostgreSQL y ejecuta las migraciones automáticas.
//
// Resolución del DSN (en orden de prioridad):
//  1. Variable de entorno DATABASE_URL (DSN completo, útil para plataformas cloud)
//  2. Variables individuales: DB_HOST, DB_PORT, DB_USER, DB_PASSWORD, DB_NAME
//  3. Fallback local para desarrollo sin Docker: prueba:postgres@localhost:5432/db_apimetro
func ConnectDataBase() {
	dbURL := buildDSN()
	log.Printf("Conectando a DB → host:%s db:%s user:%s",
		getEnv("DB_HOST", "localhost"),
		getEnv("DB_NAME", "db_apimetro"),
		getEnv("DB_USER", "prueba"),
	)

	database, err := gorm.Open(postgres.Open(dbURL), &gorm.Config{})
	if err != nil {
		log.Fatalln("Error al conectar a la base de datos:", err)
	}
	if os.Getenv("DB_HOST") == "" || os.Getenv("DB_HOST") == "localhost" {
		err = database.AutoMigrate(
			&models.Linea{},
			&models.Ramal{},
			&models.Estacion{},
			&models.DescripcionLinea{},
			&models.DescripcionEstacion{},
		)
		if err != nil {
			log.Fatalf("Error durante la migración: %v", err)
		}
	} else {
		log.Println("Saltando AutoMigrate (entorno Docker — esquema controlado por init.sql)")
	}
	log.Println("Conexión y migración exitosa")
	DB = database
}

// buildDSN construye el Data Source Name para GORM.
func buildDSN() string {
	if url := os.Getenv("DATABASE_URL"); url != "" {
		return url
	}
	host := getEnv("DB_HOST", "localhost")
	port := getEnv("DB_PORT", "5432")
	user := getEnv("DB_USER", "prueba")
	pass := getEnv("DB_PASSWORD", "postgres")
	name := getEnv("DB_NAME", "db_apimetro")
	return fmt.Sprintf("postgresql://%s:%s@%s:%s/%s", user, pass, host, port, name)
}

// getEnv retorna el valor de la variable de entorno o el fallback si está vacía.
func getEnv(key, fallback string) string {
	if val := os.Getenv(key); val != "" {
		return val
	}
	return fallback
}
