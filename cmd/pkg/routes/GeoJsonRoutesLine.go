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
//	@Summary		GeoJSON de Líneas de Transporte
//	@Description	Retorna trazos de líneas de transporte en formato GeoJSON (FeatureCollection).
//	@Description	Cada Feature contiene la geometría del trazo (`LineString` o `MultiLineString`) y un objeto
//	@Description	`properties` con métricas operativas: velocidad promedio (km/h), frecuencia (min),
//	@Description	capacidad del vehículo, distancia en metros, derecho de vía y jerarquía de transporte.
//	@Description	Los trazos se obtienen de la tabla Ramales, enriquecidos con datos de HistoricoOperacion.
//	@Description	Si no se especifica `sistema`, se devuelven trazos de todos los sistemas.
//	@Tags			GeoJSON
//	@Accept			json
//	@Produce		json
//	@Param			sistema					query	string	false	"Sistema de transporte. Ej: METRO, MB, CBB, RTP, TROLE, TL, MEXIBUS, MEXICABLE, INTERURBANO, CC. Vacío = todos."
//	@Param			num_comercial			query	string	false	"Número o clave comercial de la línea (ej: '1', 'A', 'MB1')"
//	@Param			nombre_ramal			query	string	false	"Nombre del ramal o variante de ruta (ej: 'IDA', 'REGRESO', 'Ramal Politécnico')"
//	@Param			jerarquia_transporte	query	string	false	"Jerarquía del sistema. Ej: 'Línea principal', 'Ramal'"
//	@Param			derecho_de_via			query	string	false	"Tipo de infraestructura. Valores: Superficie, Elevado, Subterráneo"
//	@Param			es_cetram				query	string	false	"Filtra trazos que pasan por un CETRAM. Valores: true, false"
//	@Param			sentido					query	string	false	"Dirección del trazo. Valores: 1 (ida / hacia terminal), 0 (regreso / hacia origen)"
//	@Param			existe					query	string	false	"Filtra por líneas actualmente operativas. Valores: true (en operación), false (discontinuadas)"
//	@Success		200						{object}	models.FeatureCollection	"FeatureCollection con trazos de líneas y métricas operativas"
//	@Failure		404						{object}	map[string]interface{}		"No se encontraron trazos con los filtros proporcionados"
//	@Failure		500						{object}	map[string]interface{}		"Error interno del servidor al ejecutar la consulta espacial"
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
