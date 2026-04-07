package routes

import (
	GeoJson "Apimetro/cmd/pkg/controller/geojson"
	"log"
	"net/http"

	"github.com/gin-gonic/gin"
	"golang.org/x/text/unicode/norm"
)

// addGeoJsonRouteLine configura la ruta para obtener líneas de transporte en formato GeoJSON con métricas operativas
func addGeoJsonRouteLine(rg *gin.RouterGroup) {
	rg.GET("/geojsonLinea", getGeoJsonRouteLinea)
}

// getGeoJsonRouteLinea   	GET Route
//
//	@Summary		GeoJSON Lineas
//	@Description	Obtener líneas de transporte en formato GeoJSON con métricas operativas
//	@Tags			GeoJSON
//	@Accept			json
//	@Produce		json
//	@Param			sistema				query		string	false	"Filter by sistema"
//	@Param			num_comercial		query		string	false	"Filter by num_comercial"
//	@Param			nombre_ramal		query		string	false	"Filter by nombre_ramal"
//	@Param			jerarquia_transporte	query		string	false	"Filter by jerarquia_transporte"
//	@Param			derecho_de_via		query		string	false	"Filter by derecho_de_via"
//	@Param			es_cetram			query		string	false	"Filter by es_cetram"
//	@Param			sentido				query		string	false	"Filter by sentido"
//	@Param			cetram_real			query		string	false	"Filter by cetram_real (250m radius)"
//	@Param			existe				query		string	false	"Filter by existe (true/false)"
//	@Success		200					{object}	models.FeatureCollection
//	@Failure		404					{object}	map[string]interface{}
//	@Failure		500					{object}	map[string]interface{}
//	@Router			/mapas/geojsonLinea [get]
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
	if cetramReal := c.Query("cetram_real"); cetramReal != "" {
		cetramRealNormalizado := norm.NFC.String(cetramReal)
		filtros["cetram_real"] = cetramRealNormalizado
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
