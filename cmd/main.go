package main

import (
	_ "Apimetro/cmd/docs"
	routes "Apimetro/cmd/pkg/routes"
	"log"
)

//	@title			Apimetro — API de Movilidad CDMX
//	@version		1.0
//	@description	API de datos geoespaciales sobre el sistema de transporte público de la Ciudad de México y Área Metropolitana.
//	@description	Ofrece dos tipos de respuesta: descriptiva (JSON) con datos operativos de líneas y estaciones,
//	@description	y geográfica (GeoJSON) con geometrías listas para renderizar en mapas interactivos.
//	@description	Cubre los sistemas: METRO, Metrobús (MB), Cablebús (CBB), RTP, Trolebús (TROLE),
//	@description	Tren Ligero (TL), Mexicable, Mexibús, Interurbano, Cable Car (CC) y CETRAM.
//	@description	Base path: /movilidad — Documentación: /swagger/

//	@contact.name	galigaribaldi (Galileo Cabrera Garibaldi)
//	@contact.email	galigaribaldi0@gmail.com

//	@license.name	Business Source License 1.1
//	@license.url	https://github.com/galigaribaldi/Apimetro/blob/main/LICENSE

// Host omitido: Swagger UI usa la URL del navegador (funciona en local y prod)
//	@BasePath	/movilidad

//	@securityDefinitions.basic	BasicAuth

// @externalDocs.description	Github
// @externalDocs.url			https://github.com/galigaribaldi/Apimetro
func main() {
	routes.Run()
	log.Println("Alive!")
}
