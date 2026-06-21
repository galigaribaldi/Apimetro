package routes

import (
	GeoJson "Apimetro/cmd/pkg/controller/geojson"
	"log"
	"net/http"
	"strconv"
	"strings"

	"github.com/gin-gonic/gin"
)

func addAfluenciaRoute(rg *gin.RouterGroup) {
	rg.GET("/afluencia-linea", getAfluenciaLinea)
}

// getAfluenciaLinea   GET Route
//
//	@Summary		Afluencia mensual por línea de transporte
//	@Description	Retorna registros de afluencia mensual por línea desde `plutarco.afluencia_linea`.
//	@Description	Granularidad: 1 fila = 1 línea × 1 mes × 1 año.
//	@Description	Sistemas disponibles: METRO, MB (Metrobús), CBB (Cablebús), TL (Tren Ligero), TROLE (Trolebús).
//	@Description	Datos fuente: SEMOVI / organismos operadores.
//	@Description	Total actual: 1,197 registros (5 sistemas).
//	@Tags			Analítico
//	@Accept			json
//	@Produce		json
//	@Param			sistema		query	string	false	"Filtrar por sistema: METRO, MB, CBB, TL, TROLE"
//	@Param			linea_id	query	int		false	"ID exacto de la línea (ref: public.lineas.id)"
//	@Param			anio		query	int		false	"Filtrar por año. Ej: 2024"
//	@Param			mes_num		query	int		false	"Filtrar por mes (1-12). Ej: 3 = Marzo"
//	@Success		200			{object}	models.AfluenciaLineaResponse	"Registros de afluencia encontrados"
//	@Failure		404			{object}	map[string]interface{}			"No se encontraron registros"
//	@Failure		500			{object}	map[string]interface{}			"Error interno"
//	@Router			/analitico/afluencia-linea [get]
func getAfluenciaLinea(c *gin.Context) {
	filtros := make(map[string]interface{})

	if v := c.Query("sistema"); v != "" {
		filtros["sistema"] = strings.ToUpper(v)
	}
	if v := c.Query("linea_id"); v != "" {
		if n, err := strconv.Atoi(v); err == nil {
			filtros["linea_id"] = n
		}
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

	log.Println("Consultando afluencia por línea con filtros:", filtros)

	response := GeoJson.SelectAfluenciaLinea(filtros)

	if response.Total == 0 {
		c.JSON(http.StatusNotFound, gin.H{
			"mensaje": "No se encontraron registros de afluencia para los filtros proporcionados",
			"data":    response,
		})
		return
	}

	c.JSON(http.StatusOK, response)
}
