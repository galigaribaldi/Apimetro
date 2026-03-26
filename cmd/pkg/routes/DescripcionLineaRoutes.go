package routes

import (
	"log"
	"net/http"

	"strconv"

	transporte "Apimetro/cmd/pkg/controller/transporte"
	"Apimetro/cmd/pkg/models"

	"github.com/gin-gonic/gin"
)

func addDescriptionLineRoute(rg *gin.RouterGroup) {

	rg.GET("/descripcion-linea", getDescripcionLineaRoute)
	rg.POST("/descripcion-linea", postDescripcionLineaRoute)
	rg.DELETE("/descripcion-linea/:id", deleteDescripcionLineaRoute)
	rg.PUT("/descripcion-linea/:id", putDescripcionLineaRoute)
}

/*
--------
GET METHODS
--------
*/
func getDescripcionLineaRoute(c *gin.Context) {
	sistema := c.MustGet("sistemaValidado").(string)

	filtros := map[string]interface{}{
		"sistema": sistema,
	}

	if id := c.Query("id"); id != "" {
		filtros["id"] = id
	}
	if terminal := c.Query("terminal_original"); terminal != "" {
		filtros["terminal_original"] = terminal
	}
	if lineaBase := c.Query("linea_base"); lineaBase != "" {
		filtros["linea_base"] = lineaBase
	}
	if numComercial := c.Query("num_comercial"); numComercial != "" {
		filtros["num_comercial"] = numComercial
	}

	log.Println("Buscando Descripción de Línea con filtros:", filtros)

	resultados := transporte.SearchDescripcionesLinea(filtros)
	c.JSON(http.StatusOK, resultados)
}

/*
--------
POST METHODS
--------
*/
func postDescripcionLineaRoute(c *gin.Context) {
	var newDescripcion models.DescripcionLinea
	if err := c.BindJSON(&newDescripcion); err != nil {
		c.JSON(
			http.StatusBadRequest,
			gin.H{
				"error":   "JSON inválido",
				"detalle": err.Error(),
			})
		return
	}
	transporte.CreateDescripcionLinea(newDescripcion)
	c.JSON(
		http.StatusCreated,
		gin.H{
			"mensaje": "Descripción de línea creada con éxito",
		})
}

/*
--------
DELETE METHODS
--------
*/

func deleteDescripcionLineaRoute(c *gin.Context) {
	idParam := c.Param("id")
	id, err := strconv.Atoi(idParam)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID inválido"})
		return
	}

	transporte.DeleteDescripcionLinea(id)
	c.JSON(http.StatusOK, gin.H{"mensaje": "Descripción eliminada con éxito"})

}

/*
--------
PUT METHODS
--------
*/
func putDescripcionLineaRoute(c *gin.Context) {
	idParam := c.Param("id")
	id, err := strconv.Atoi(idParam)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID inválido"})
		return
	}

	var updateData models.DescripcionLinea
	if err := c.BindJSON(&updateData); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "JSON inválido"})
		return
	}

	updateData.ID = uint(id)
	transporte.UpdateDescripcionLinea(updateData)
	c.JSON(http.StatusOK, gin.H{"mensaje": "Descripción actualizada con éxito"})
}
