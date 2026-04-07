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

// getGeoJsonRoutePoligono   	GET Route
//
//	@Summary		GeoJSON Poligonos
//	@Description	Obtener límites administrativos en formato GeoJSON
//	@Tags			GeoJSON
//	@Accept			json
//	@Produce		json
//	@Param			entidad	query		string	false	"Filter by entidad"
//	@Param			nivel	query		string	false	"Filter by nivel"
//	@Param			nombre	query		string	false	"Filter by nombre"
//	@Success		200		{object}	models.FeatureCollection
//	@Failure		500		{object}	map[string]interface{}
//	@Router			/mapas/geojsonPoligono [get]
func getGeoJsonRoutePoligono(c *gin.Context) {
	entidad := c.Query("entidad")
	nivel := c.Query("nivel")
	nombre := c.Query("nombre")

	log.Printf("Consultando mapa GeoJson de POLÍGONOS con filtros -> Entidad: '%s', Nivel: '%s'\n", entidad, nivel)

	featureCollection := GeoJson.SelectGeoJsonPoligono(entidad, nivel, nombre)

	c.JSON(http.StatusOK, featureCollection)
}
