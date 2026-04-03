package routes

import (
	"log"
	"net/http"
	"strconv"

	transporte "Apimetro/cmd/pkg/controller/transporte"
	"Apimetro/cmd/pkg/models"

	"github.com/gin-gonic/gin"
	"golang.org/x/text/unicode/norm"
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

	sistema := c.MustGet("sistemaValidado").(string)
	filtros := make(map[string]interface{})

	if sistema != "TODOS" {
		filtros["sistema"] = sistema
	}
	// Capturar los Query Params
	// Soporte para caracteres nuevos
	if nombreRaw := c.Query("nombre"); nombreRaw != "" {
		// Esto fuerza a que "n" + "~" se convierta en "ñ" real
		filtros["nombre"] = norm.NFC.String(nombreRaw)
	}
	if nombre := c.Query("nombre"); nombre != "" {
		filtros["nombre"] = nombre
	}

	if ramal := c.Query("nombre_ramal"); ramal != "" {
		ramalNormalizado := norm.NFC.String(ramal)
		filtros["nombre_ramal"] = ramalNormalizado
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
	// Filtrar por si la línea tiene estaciones tipo CETRAM
	if esCetram := c.Query("es_cetram"); esCetram != "" {
		filtros["es_cetram"] = esCetram
	}
	// Filtrar por sentido
	if sentido := c.Query("sentido"); sentido != "" {
		filtros["sentido"] = sentido
	}

	if existeStr := c.Query("existe"); existeStr != "" {
		existe, err := strconv.ParseBool(existeStr)
		if err == nil {
			filtros["existe"] = existe
		}
	}
	log.Println("🔍 Filtros detectados en la petición:", filtros)
	lineas := transporte.SearchLineas(filtros)
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

	if err := transporte.CreateLinea(newLinea); err != nil {
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

	if err := transporte.DeleteLinea(id); err != nil {
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

	if err := transporte.UpdateLinea(id, dataActualizada); err != nil {
		c.JSON(
			http.StatusInternalServerError,
			gin.H{
				"error": "No se pudo actualizar la línea",
			})
		return
	}
	c.JSON(http.StatusOK, gin.H{"mensaje": "Línea actualizada correctamente"})
}
