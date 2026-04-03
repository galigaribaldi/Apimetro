package routes

import (
	GeoJson "Apimetro/cmd/pkg/controller/geojson"
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
	if jt := c.Query("jerarquia_transporte"); jt != "" {
		filtros["jerarquia_transporte"] = jt
	}
	if dv := c.Query("derecho_de_via"); dv != "" {
		filtros["derecho_de_via"] = dv
	}

	if esCetram := c.Query("es_cetram"); esCetram != "" {
		filtros["es_cetram"] = esCetram
	}
	if nomCetram := c.Query("nombre_cetram"); nomCetram != "" {
		nomCetramNormalizado := norm.NFC.String(nomCetram)
		filtros["nombre_cetram"] = nomCetramNormalizado
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
