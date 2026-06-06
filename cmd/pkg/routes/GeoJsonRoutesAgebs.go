package routes

import (
	GeoJson "Apimetro/cmd/pkg/controller/geojson"
	"log"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

func addGeoJsonRouteAgebs(rg *gin.RouterGroup) {
	rg.GET("/agebs", getGeoJsonAgebs)
}

// getGeoJsonAgebs   GET Route
//
//	@Summary		GeoJSON de AGEBs urbanas
//	@Description	Retorna AGEBs (Áreas Geo-Estadísticas Básicas) urbanas en formato GeoJSON (FeatureCollection).
//	@Description	Cada Feature contiene una geometría tipo `MultiPolygon` y atributos censales del INEGI Censo 2020:
//	@Description	población total, viviendas habitadas, PEA, área en km² y densidad poblacional.
//	@Description	Scope geográfico: 6 estados de la macrometrópoli (CDMX, EdoMex, Morelos, Puebla, Querétaro, Tlaxcala).
//	@Description	**Paginación obligatoria** — default: limit=500, offset=0. Máximo recomendado: 1000 por request.
//	@Tags			Analítico
//	@Accept			json
//	@Produce		json
//	@Param			entidad				query	string	false	"Clave de entidad federativa (2 dígitos). Ej: 09=CDMX, 15=EdoMex, 17=Morelos, 21=Puebla, 22=Querétaro, 29=Tlaxcala"
//	@Param			municipio_alcaldia	query	string	false	"Nombre del municipio o alcaldía (búsqueda parcial). Ej: 'Cuauhtémoc', 'Naucalpan'"
//	@Param			limit				query	int		false	"Número máximo de AGEBs a retornar (default: 500)"
//	@Param			offset				query	int		false	"Número de AGEBs a saltar para paginación (default: 0)"
//	@Success		200					{object}	models.FeatureCollection	"FeatureCollection con AGEBs encontradas"
//	@Failure		404					{object}	map[string]interface{}		"No se encontraron AGEBs con los filtros proporcionados"
//	@Failure		500					{object}	map[string]interface{}		"Error interno del servidor al ejecutar la consulta espacial"
//	@Router			/analitico/agebs [get]
func getGeoJsonAgebs(c *gin.Context) {
	filtros := make(map[string]interface{})

	if v := c.Query("entidad"); v != "" {
		filtros["entidad"] = v
	}
	if v := c.Query("municipio_alcaldia"); v != "" {
		filtros["municipio_alcaldia"] = v
	}
	if v := c.Query("limit"); v != "" {
		if n, err := strconv.Atoi(v); err == nil {
			filtros["limit"] = n
		}
	}
	if v := c.Query("offset"); v != "" {
		if n, err := strconv.Atoi(v); err == nil {
			filtros["offset"] = n
		}
	}

	log.Println("Consultando GeoJSON de AGEBs con filtros:", filtros)

	featureCollection := GeoJson.SelectGeoJsonAgebs(filtros)

	if len(featureCollection.Features) == 0 {
		c.JSON(http.StatusNotFound, gin.H{
			"mensaje": "No se encontraron AGEBs para los filtros proporcionados",
			"data":    featureCollection,
		})
		return
	}

	c.JSON(http.StatusOK, featureCollection)
}
