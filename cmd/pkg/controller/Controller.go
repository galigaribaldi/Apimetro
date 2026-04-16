package controller

import (
	models "Apimetro/cmd/pkg/models"
	"fmt"
	"log"
	"net/url"
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
// Usa url.URL para codificar correctamente caracteres especiales en la contraseña.
func buildDSN() string {
	if dbURL := os.Getenv("DATABASE_URL"); dbURL != "" {
		return dbURL
	}
	host := getEnv("DB_HOST", "localhost")
	port := getEnv("DB_PORT", "5432")
	user := getEnv("DB_USER", "prueba")
	pass := getEnv("DB_PASSWORD", "postgres")
	name := getEnv("DB_NAME", "db_apimetro")
	u := &url.URL{
		Scheme: "postgresql",
		User:   url.UserPassword(user, pass),
		Host:   fmt.Sprintf("%s:%s", host, port),
		Path:   name,
	}
	return u.String()
}

// getEnv retorna el valor de la variable de entorno o el fallback si está vacía.
func getEnv(key, fallback string) string {
	if val := os.Getenv(key); val != "" {
		return val
	}
	return fallback
}
