package routes

import (
	GeoJson "Apimetro/cmd/pkg/controller/geojson"
	"log"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

func addAfluenciaEstacionRoute(rg *gin.RouterGroup) {
	rg.GET("/afluencia-estacion", getAfluenciaEstacion)
}

// getAfluenciaEstacion   GET Route
//
//	@Summary		Afluencia mensual por estación del Metro CDMX
//	@Description	Retorna registros de afluencia mensual por estación desde `plutarco.afluencia_estacion`.
//	@Description	Granularidad: 1 fila = 1 estación × 1 mes × 1 año.
//	@Description	Solo sistema Metro (STC) — los demás sistemas no publican datos por estación.
//	@Description	Datos fuente: STC Metro / datos.cdmx.gob.mx (CC BY 4.0).
//	@Description	Total actual: 38,219 registros (195 estaciones, 12 líneas, 2010-2026).
//	@Tags			Analítico
//	@Accept			json
//	@Produce		json
//	@Param			linea_id		query	int		false	"ID de la línea Metro (ref: public.lineas.id)"
//	@Param			num_comercial	query	string	false	"Número comercial de la línea. Ej: 1, A, L12"
//	@Param			estacion_id		query	int		false	"ID de la estación (ref: public.estacions.id)"
//	@Param			nombre_estacion	query	string	false	"Nombre de la estación (búsqueda parcial, ILIKE). Ej: Pantitlán"
//	@Param			anio			query	int		false	"Filtrar por año. Ej: 2024"
//	@Param			mes_num			query	int		false	"Filtrar por mes (1-12). Ej: 3 = Marzo"
//	@Success		200			{object}	models.AfluenciaEstacionResponse	"Registros de afluencia encontrados"
//	@Failure		404			{object}	map[string]interface{}				"No se encontraron registros"
//	@Failure		500			{object}	map[string]interface{}				"Error interno"
//	@Failure		503			{object}	map[string]interface{}				"Extensión Plutarco no activada — ejecutar make plutarco-setup"
//	@Router			/analitico/afluencia-estacion [get]
func getAfluenciaEstacion(c *gin.Context) {
	filtros := make(map[string]interface{})

	if v := c.Query("linea_id"); v != "" {
		if n, err := strconv.Atoi(v); err == nil {
			filtros["linea_id"] = n
		}
	}
	if v := c.Query("num_comercial"); v != "" {
		filtros["num_comercial"] = v
	}
	if v := c.Query("estacion_id"); v != "" {
		if n, err := strconv.Atoi(v); err == nil {
			filtros["estacion_id"] = n
		}
	}
	if v := c.Query("nombre_estacion"); v != "" {
		filtros["nombre_estacion"] = v
	}
	if v := c.Query("anio"); v != "" {
		if n, err := strconv.Atoi(v); err == nil {
			filtros["anio"] = n
		}
	}
	if v := c.Query("mes_num"); v != "" {
		if n, err := strconv.Atoi(v); err == nil {
			filtros["mes_num"] = n
		}
	}

	log.Println("Consultando afluencia por estación con filtros:", filtros)

	response := GeoJson.SelectAfluenciaEstacion(filtros)

	if response.Total == 0 {
		if !GeoJson.PluarcoTableHasData("afluencia_estacion") {
			c.JSON(http.StatusServiceUnavailable, gin.H{
				"extension":            "plutarco",
				"activacion_requerida": true,
				"mensaje":             "Este endpoint requiere activar la extensión Plutarco (afluencia por estación).",
				"guia":                "Ejecuta 'make plutarco-setup' o consulta docs/PLUTARCO_EXTENSION.md",
				"repositorio":         "https://github.com/galigaribaldi/Apimetro/blob/main/docs/PLUTARCO_EXTENSION.md",
			})
			return
		}
		c.JSON(http.StatusNotFound, gin.H{
			"mensaje": "No se encontraron registros de afluencia por estación para los filtros proporcionados",
			"data":    response,
		})
		return
	}

	c.JSON(http.StatusOK, response)
}
