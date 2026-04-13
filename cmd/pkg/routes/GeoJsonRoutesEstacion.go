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

// getGeoJsonRouteEstacion   	GET Route
//
//	@Summary		GeoJSON de Estaciones
//	@Description	Retorna estaciones de transporte público en formato GeoJSON (FeatureCollection).
//	@Description	Cada Feature contiene una geometría tipo `Point` (longitud/latitud) y un objeto `properties`
//	@Description	con atributos como nombre, sistema, alcaldía, número comercial, año y datos de CETRAM.
//	@Description	Si no se especifica `sistema`, se devuelven estaciones de todos los sistemas.
//	@Description	Los textos con caracteres especiales (ñ, tildes) se normalizan automáticamente.
//	@Tags			GeoJSON
//	@Accept			json
//	@Produce		json
//	@Param			sistema					query	string	false	"Sistema de transporte. Ej: METRO, MB, CBB, RTP, TROLE, TL, MEXIBUS, MEXICABLE, INTERURBANO, CC. Vacío = todos."
//	@Param			num_comercial			query	string	false	"Número o clave comercial de la línea (ej: '1', 'A', 'MB1')"
//	@Param			alcaldia_municipio		query	string	false	"Alcaldía (CDMX) o municipio del Área Metropolitana donde se ubica la estación (ej: 'Cuauhtémoc')"
//	@Param			nombre_ramal			query	string	false	"Nombre del ramal o variante de ruta al que pertenece la estación (ej: 'Ramal Politécnico')"
//	@Param			jerarquia_transporte	query	string	false	"Jerarquía del sistema. Ej: 'Línea principal', 'Ramal'"
//	@Param			derecho_de_via			query	string	false	"Tipo de infraestructura vial. Valores: Superficie, Elevado, Subterráneo"
//	@Param			es_cetram				query	string	false	"Filtra estaciones que son o colindan con un CETRAM (Centro de Transferencia Modal). Valores: true, false"
//	@Param			nombre_cetram			query	string	false	"Nombre del CETRAM (ej: 'Indios Verdes', 'Tacubaya'). Aplica solo si es_cetram=true"
//	@Param			cetram_real				query	string	false	"Nombre de un CETRAM para buscar estaciones en un radio de 250 metros a su alrededor"
//	@Success		200						{object}	models.FeatureCollection	"FeatureCollection con estaciones encontradas"
//	@Failure		404						{object}	map[string]interface{}		"No se encontraron estaciones con los filtros proporcionados"
//	@Failure		500						{object}	map[string]interface{}		"Error interno del servidor al ejecutar la consulta espacial"
//	@Router			/mapas/geojsonEstacion [get]
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
	if cetramReal := c.Query("cetram_real"); cetramReal != "" {
		cetramRealNormalizado := norm.NFC.String(cetramReal)
		filtros["cetram_real"] = cetramRealNormalizado
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
