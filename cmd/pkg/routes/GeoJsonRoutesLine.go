package routes

import (
	GeoJson "Apimetro/cmd/pkg/controller/utils/GeoJson"
	"log"
	"net/http"

	"github.com/gin-gonic/gin"
)

func addGeoJsonRouteLine(rg *gin.RouterGroup) {
	rg.GET("/geojsonLinea", getGeoJsonRouteLinea)
}

func getGeoJsonRouteLinea(c *gin.Context) {
	sistema := c.Query("sistema")

	if sistema == "" {
		sistema = "%"
	}

	log.Println("Consultado mapa GeoJson para el sistema: ", sistema)
	featureCollection := GeoJson.SelectGeoJsonLineaBysistema(sistema)

	if len(featureCollection.Features) == 0 {
		log.Println("No se encontraron traos para el sistema:", sistema)
		c.JSON(http.StatusNotFound, gin.H{
			"mensaje": "No se encontraron mapas paara el sistema proporcionado",
			"data":    featureCollection,
		})
		return
	}

	c.JSON(http.StatusOK, featureCollection)
}
