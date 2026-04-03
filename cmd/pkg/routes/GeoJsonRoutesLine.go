package routes

import (
	GeoJson "Apimetro/cmd/pkg/controller/geojson"
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

	if nc := c.Query("num_comercial"); nc != "" {
		filtros["num_comercial"] = nc
	}
	if nombreRaw := c.Query("nombre_ramal"); nombreRaw != "" {
		log.Println("Ramal crudo de la URL:", c.Request.URL.RawQuery)
		filtros["nombre_ramal"] = norm.NFC.String(nombreRaw)
	}
	if jt := c.Query("jerarquia_transporte"); jt != "" {
		filtros["jerarquia_transporte"] = jt
	}
	// Filtrar trazos que pasen por un CETRAM
	if esCetram := c.Query("es_cetram"); esCetram != "" {
		filtros["es_cetram"] = esCetram
	}
	// Filtrar por sentido en GeoJson
	if sentido := c.Query("sentido"); sentido != "" {
		filtros["sentido"] = sentido
	}
	if dv := c.Query("derecho_de_via"); dv != "" {
		filtros["derecho_de_via"] = dv
	}
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
