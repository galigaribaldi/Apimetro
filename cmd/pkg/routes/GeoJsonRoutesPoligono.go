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
//	@Summary		GeoJSON de Polígonos Administrativos
//	@Description	Retorna límites administrativos en formato GeoJSON (FeatureCollection).
//	@Description	Cubre alcaldías de la CDMX, municipios del Área Metropolitana y entidades federativas.
//	@Description	Las geometrías son de tipo `Polygon` o `MultiPolygon`, útiles para delimitar zonas en mapas.
//	@Description	Si no se aplican filtros, devuelve todos los polígonos disponibles en la base de datos.
//	@Tags			GeoJSON
//	@Accept			json
//	@Produce		json
//	@Param			entidad	query	string	false	"Entidad federativa. Ej: 'CDMX', 'Estado de México', 'Hidalgo', 'Morelos'"
//	@Param			nivel	query	string	false	"Nivel administrativo. Valores: alcaldia (circunscripciones de CDMX), municipio (Área Metropolitana), entidad (nivel estatal)"
//	@Param			nombre	query	string	false	"Nombre exacto del polígono (ej: 'Cuauhtémoc', 'Naucalpan de Juárez', 'Ecatepec de Morelos')"
//	@Success		200		{object}	models.FeatureCollection	"FeatureCollection con polígonos administrativos"
//	@Failure		500		{object}	map[string]interface{}		"Error interno del servidor al ejecutar la consulta espacial"
//	@Router			/mapas/geojsonPoligono [get]
func getGeoJsonRoutePoligono(c *gin.Context) {
	entidad := c.Query("entidad")
	nivel := c.Query("nivel")
	nombre := c.Query("nombre")

	log.Printf("Consultando mapa GeoJson de POLÍGONOS con filtros -> Entidad: '%s', Nivel: '%s'\n", entidad, nivel)

	featureCollection := GeoJson.SelectGeoJsonPoligono(entidad, nivel, nombre)

	c.JSON(http.StatusOK, featureCollection)
}
