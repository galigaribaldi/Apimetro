package routes

import (
	GeoJson "Apimetro/cmd/pkg/controller/transporte"
	"log"
	"net/http"

	"github.com/gin-gonic/gin"
	"golang.org/x/text/unicode/norm"
)

func addGeoJsonRouteLine(rg *gin.RouterGroup) {
	rg.GET("/geojsonLinea", getGeoJsonRouteLinea)
}

func getGeoJsonRouteLinea(c *gin.Context) {
	filtros := make(map[string]interface{})

	// 2. Capturamos el sistema (con soporte para comodín % si viene vacío)
	sistema := c.Query("sistema")
	if sistema == "" {
		sistema = "%"
	}
	filtros["sistema"] = sistema

	// 3. Capturamos el resto de los filtros
	if nc := c.Query("num_comercial"); nc != "" {
		filtros["num_comercial"] = nc
	}
	// Soporte de nuevas letras
	if nombreRaw := c.Query("nombre_ramal"); nombreRaw != "" {
		log.Println("Ramal crudo de la URL:", c.Request.URL.RawQuery)
		filtros["nombre_ramal"] = norm.NFC.String(nombreRaw)
	}

	// Convertimos el string "true"/"false" a un booleano real en Go
	if existe := c.Query("existe"); existe != "" {
		switch existe {
		case "true":
			filtros["existe"] = true
		case "false":
			filtros["existe"] = false
		}
	}

	log.Println("Consultando mapa GeoJson de LÍNEAS con filtros:", filtros)

	featureCollection := GeoJson.SelectGeoJsonLineaConFiltros(filtros)

	if len(featureCollection.Features) == 0 {
		c.JSON(http.StatusNotFound, gin.H{
			"mensaje": "No se encontraron trazos para los filtros proporcionados",
			"data":    featureCollection,
		})
		return
	}

	c.JSON(http.StatusOK, featureCollection)
}
