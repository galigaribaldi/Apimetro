package routes

import (
	"log"
	"net/http"
	"strconv"

	transporte "Apimetro/cmd/pkg/controller/transporte"
	"Apimetro/cmd/pkg/models"

	"github.com/gin-gonic/gin"
)

func addDescripcionEstacionRoute(rg *gin.RouterGroup) {
	rg.GET("/descripcion-estacion", getDescripcionEstacionRoute)
	rg.POST("/descripcion-estacion", postDescripcionEstacionRoute)
	rg.PUT("/descripcion-estacion/:id", putDescripcionEstacionRoute)
	rg.DELETE("/descripcion-estacion/:id", deleteDescripcionEstacionRoute)
}

/*
--------
GET
--------
*/
func getDescripcionEstacionRoute(c *gin.Context) {
	sistema := c.MustGet("sistemaValidado").(string)

	filtros := map[string]interface{}{
		"sistema": sistema,
	}

	if id := c.Query("id"); id != "" {
		filtros["id"] = id
	}
	if nombre := c.Query("nombre"); nombre != "" {
		filtros["nombre"] = nombre
	}
	if alcaldia := c.Query("alcaldia_municipio"); alcaldia != "" {
		filtros["alcaldia_municipio"] = alcaldia
	}
	if numComercial := c.Query("num_comercial"); numComercial != "" {
		filtros["num_comercial"] = numComercial
	}

	log.Println("Buscando Descripción de Estación con filtros:", filtros)

	resultados := transporte.SearchDescripcionesEstacion(filtros)
	c.JSON(http.StatusOK, resultados)
}

/*
--------
POST
--------
*/
func postDescripcionEstacionRoute(c *gin.Context) {
	var newDescripcion models.DescripcionEstacion
	if err := c.BindJSON(&newDescripcion); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "JSON inválido", "detalle": err.Error()})
		return
	}
	transporte.CreateDescripcionEstacion(newDescripcion)
	c.JSON(http.StatusCreated, gin.H{"mensaje": "Descripción de estación creada con éxito"})
}

/*
--------
PUT
--------
*/
func putDescripcionEstacionRoute(c *gin.Context) {
	idParam := c.Param("id")
	id, err := strconv.Atoi(idParam)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID inválido"})
		return
	}

	var updateData models.DescripcionEstacion
	if err := c.BindJSON(&updateData); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "JSON inválido"})
		return
	}

	updateData.ID = uint(id)
	transporte.UpdateDescripcionEstacion(updateData)
	c.JSON(http.StatusOK, gin.H{"mensaje": "Descripción de estación actualizada con éxito"})
}

/*
--------
DELETE
--------
*/
func deleteDescripcionEstacionRoute(c *gin.Context) {
	idParam := c.Param("id")
	id, err := strconv.Atoi(idParam)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID inválido"})
		return
	}

	transporte.DeleteDescripcionEstacion(id)
	c.JSON(http.StatusOK, gin.H{"mensaje": "Descripción de estación eliminada con éxito"})
}
