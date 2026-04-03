package routes

import (
	GeoJson "Apimetro/cmd/pkg/controller/geojson"
	"log"
	"net/http"

	"github.com/gin-gonic/gin"
)

// addGeoJsonRoutePoligono registra el endpoint en el grupo de rutas de mapas
func addGeoJsonRoutePoligono(rg *gin.RouterGroup) {
	rg.GET("/geojsonPoligono", getGeoJsonRoutePoligono)
}

// getGeoJsonRoutePoligono maneja la petición HTTP, extrae los filtros y devuelve el GeoJSON
func getGeoJsonRoutePoligono(c *gin.Context) {
	entidad := c.Query("entidad")
	nivel := c.Query("nivel")
	nombre := c.Query("nombre")

	log.Printf("Consultando mapa GeoJson de POLÍGONOS con filtros -> Entidad: '%s', Nivel: '%s'\n", entidad, nivel)

	featureCollection := GeoJson.SelectGeoJsonPoligono(entidad, nivel, nombre)

	c.JSON(http.StatusOK, featureCollection)
}
