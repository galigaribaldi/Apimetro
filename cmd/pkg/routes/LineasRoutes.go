package routes

import (
	"log"
	"net/http"
	"strconv"

	metro "Apimetro/cmd/pkg/controller/metro"
	"Apimetro/cmd/pkg/models"

	"github.com/gin-gonic/gin"
)

func addLineRoute(rg *gin.RouterGroup) {

	//Lineas
	rg.GET("/linea", getLineaRoute)
	rg.POST("/linea", postLineaRoute)
	rg.DELETE("/linea", deleteLineaRoute)
	rg.PATCH("/linea", updateLineaRoute)
}

// ==========================================
// GET /movilidad/metro/linea
// ==========================================
func getLineaRoute(c *gin.Context) {
	filtros := make(map[string]interface{})
	filtros["sistema"] = "METRO"

	// Capturar los Query Params
	if nombre := c.Query("nombre"); nombre != "" {
		filtros["nombre"] = nombre
	}

	if ramal := c.Query("nombre_ramal"); ramal != "" {
		filtros["nombre_ramal"] = ramal
	}

	if numComercial := c.Query("num_comercial"); numComercial != "" {
		filtros["num_comercial"] = numComercial
	}

	if clasificacion := c.Query("clasificacion"); clasificacion != "" {
		filtros["clasificacion"] = clasificacion
	}

	if tamKm := c.Query("tam_km"); tamKm != "" {
		filtros["tam_km"] = tamKm
	}

	if existeStr := c.Query("existe"); existeStr != "" {
		existe, err := strconv.ParseBool(existeStr)
		if err == nil {
			filtros["existe"] = existe
		}
	}
	log.Println("🔍 Filtros detectados en la petición:", filtros)
	lineas := metro.SearchLineas(filtros)
	c.JSON(http.StatusOK, lineas)
}

// ==========================================
// POST /movilidad/metro/linea
// ==========================================
func postLineaRoute(c *gin.Context) {
	var newLinea models.Linea

	if err := c.BindJSON(&newLinea); err != nil {
		c.JSON(http.StatusBadRequest,
			gin.H{
				"error":   "JSON inválido",
				"detalle": err.Error(),
			})
		return
	}

	if newLinea.Sistema == "" {
		newLinea.Sistema = "METRO"
	}

	if err := metro.CreateLinea(newLinea); err != nil {
		c.JSON(
			http.StatusInternalServerError,
			gin.H{
				"error":   "No se pudo crear la línea",
				"detalle": err.Error(),
			},
		)
		return
	}
	c.JSON(http.StatusCreated, newLinea)

}

// ==========================================
// DELETE /movilidad/metro/linea?id=1
// ==========================================
func deleteLineaRoute(c *gin.Context) {
	idStr := c.Query("id")
	id, err := strconv.Atoi(idStr)

	if err != nil || id == 0 {
		c.JSON(
			http.StatusBadRequest,
			gin.H{
				"error": "Se requiere un ID numérico válido (ej. ?id=1)",
			})
		return
	}

	if err := metro.DeleteLinea(id); err != nil {
		c.JSON(
			http.StatusInternalServerError,
			gin.H{
				"error": "No se pudo eliminar la línea",
			})
		return
	}
	c.JSON(http.StatusOK, gin.H{"mensaje": "Línea y dependencias eliminadas correctamente"})
}

// ==========================================
// PATCH /movilidad/metro/lineas?id=1
// ==========================================

func updateLineaRoute(c *gin.Context) {
	idStr := c.Query("id")
	id, err := strconv.Atoi(idStr)

	if err != nil || id == 0 {
		c.JSON(
			http.StatusBadRequest,
			gin.H{
				"error": "Se requiere un ID numérico válido (ej. ?id=1)",
			},
		)
		return
	}

	var dataActualizada map[string]interface{}
	if err := c.BindJSON(&dataActualizada); err != nil {
		c.JSON(
			http.StatusBadRequest,
			gin.H{
				"error": "JSON inválido",
			},
		)
	}

	delete(dataActualizada, "linea_id")

	if err := metro.UpdateLinea(id, dataActualizada); err != nil {
		c.JSON(
			http.StatusInternalServerError,
			gin.H{
				"error": "No se pudo actualizar la línea",
			})
		return
	}
	c.JSON(http.StatusOK, gin.H{"mensaje": "Línea actualizada correctamente"})
}
