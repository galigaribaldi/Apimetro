package routes

import (
	GeoJson "Apimetro/cmd/pkg/controller/transporte"
	"log"
	"net/http"

	"github.com/gin-gonic/gin"
	"golang.org/x/text/unicode/norm"
)

func addGeoJsonRouteEstacion(rg *gin.RouterGroup) {
	rg.GET("/geojsonEstacion", getGeoJsonRouteEstacion)
}

func getGeoJsonRouteEstacion(c *gin.Context) {
	filtros := make(map[string]interface{})

	sistema := c.Query("sistema")
	if sistema == "" {
		sistema = "%"
	}
	filtros["sistema"] = sistema

	if nc := c.Query("num_comercial"); nc != "" {
		filtros["num_comercial"] = nc
	}
	if alc := c.Query("alcaldia_municipio"); alc != "" {
		filtros["alcaldia_municipio"] = alc
	}
	if nr := c.Query("nombre_ramal"); nr != "" {
		ramalNormalizado := norm.NFC.String(nr)
		filtros["nombre_ramal"] = ramalNormalizado
	}

	log.Println("Consultando mapa GeoJson de ESTACIONES con filtros:", filtros)

	featureCollection := GeoJson.SelectGeoJsonEstacionConFiltros(filtros)

	if len(featureCollection.Features) == 0 {
		c.JSON(http.StatusNotFound, gin.H{
			"mensaje": "No se encontraron estaciones para los filtros proporcionados",
			"data":    featureCollection,
		})
		return
	}

	c.JSON(http.StatusOK, featureCollection)
}
