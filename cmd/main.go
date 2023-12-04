package main

import (
	routes "Apimetro/pkg/routes"
	"log"
)

func main() {
	routes.Run()
	log.Println("Alive!")
}
