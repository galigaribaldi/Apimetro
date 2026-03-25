package routes

import (
	GeoJson "Apimetro/cmd/pkg/controller/utils/GeoJson"
	"log"
	"net/http"

	"github.com/gin-gonic/gin"
)

func addGeoJsonRouteEstacion(rg *gin.RouterGroup) {
	rg.GET("/geojsonEstacion", getGeoJsonRouteEstacion)
}

func getGeoJsonRouteEstacion(c *gin.Context) {
	sistema := c.Query("sistema")

	if sistema == "" {
		sistema = "%"
	}

	log.Println("Consultado mapa GeoJson de ESTACIONES para el sistema: ", sistema)

	featureCollection := GeoJson.SelectGeoJsonEstacionBysistema(sistema)

	if len(featureCollection.Features) == 0 {
		c.JSON(http.StatusNotFound, gin.H{
			"mensaje": "No se encontraron estaciones para el sistema proporcionado",
			"data":    featureCollection,
		})
		return
	}
	c.JSON(http.StatusOK, featureCollection)
}
