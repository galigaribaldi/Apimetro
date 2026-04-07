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
//	@Summary		GeoJSON Estaciones
//	@Description	Obtener estaciones en formato GeoJSON con filtros avanzados
//	@Tags			GeoJSON
//	@Accept			json
//	@Produce		json
//	@Param			sistema				query		string	false	"Filter by sistema"
//	@Param			num_comercial		query		string	false	"Filter by num_comercial"
//	@Param			alcaldia_municipio	query		string	false	"Filter by alcaldia_municipio"
//	@Param			nombre_ramal		query		string	false	"Filter by nombre_ramal"
//	@Param			jerarquia_transporte	query		string	false	"Filter by jerarquia_transporte"
//	@Param			derecho_de_via		query		string	false	"Filter by derecho_de_via"
//	@Param			es_cetram			query		string	false	"Filter by es_cetram"
//	@Param			nombre_cetram		query		string	false	"Filter by nombre_cetram"
//	@Param			cetram_real			query		string	false	"Filter by cetram_real (250m radius)"
//	@Success		200					{object}	models.FeatureCollection
//	@Failure		404					{object}	map[string]interface{}
//	@Failure		500					{object}	map[string]interface{}
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
