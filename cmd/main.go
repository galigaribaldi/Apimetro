package main

import (
	routes "Apimetro/cmd/pkg/routes"
	"log"
	_ "Apimetro/cmd/docs"
)

//	@title			Apimetro
//	@version		1.0
//	@description	API sobre el Sistema de Transporte Colectivo (STC) de la Ciudad de México

//	@contact.name	galigaribaldi (Galileo Cabrera Garibaldi)
//	@contact.email	galigaribaldi0@gmail.com

//	@license.name	Apache 2.0
//	@license.url	http://www.apache.org/licenses/LICENSE-2.0.html

//	@host		localhost:8080
//	@BasePath	/stc

//	@securityDefinitions.basic	BasicAuth

//	@externalDocs.description	Github
//	@externalDocs.url			https://github.com/galigaribaldi/Apimetro
func main() {
	routes.Run()
	log.Println("Alive!")
}
