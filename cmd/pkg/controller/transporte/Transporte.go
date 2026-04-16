package transporte

import (
	con "Apimetro/cmd/pkg/controller"
	"log"
	"os"
)

// Inicializa el módulo de Transporte conectando a la base de datos.
// AutoMigrate solo corre en entorno local (DB_HOST vacío o localhost).
// En producción el esquema es gestionado por db/init/init.sql.
func init() {
	log.Println("Inicializando BD y módulo de Transporte")
	con.ConnectDataBase()

	if os.Getenv("DB_HOST") != "" && os.Getenv("DB_HOST") != "localhost" {
		log.Println("Saltando AutoMigrate en módulo Transporte (entorno Docker)")
	}
}
