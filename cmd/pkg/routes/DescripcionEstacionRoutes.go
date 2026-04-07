package routes

import (
	"log"
	"net/http"
	"strconv"

	transporte "Apimetro/cmd/pkg/controller/transporte"
	"Apimetro/cmd/pkg/models"

	"github.com/gin-gonic/gin"
)

// addDescripcionEstacionRoute configura las rutas para la API, teniendo en cuenta
// la arquitectura dinámica dependiendo del sistema de transporte
//
//	@Summary		Descripción de Estación
//	@Description		Obtener, crear, actualizar y eliminar descripciones de estaciones
//	@Tags			Descripción de Estación
func addDescripcionEstacionRoute(rg *gin.RouterGroup) {
	rg.GET("/descripcion-estacion", getDescripcionEstacionRoute)
	rg.POST("/descripcion-estacion", postDescripcionEstacionRoute)
	rg.PUT("/descripcion-estacion/:id", putDescripcionEstacionRoute)
	rg.DELETE("/descripcion-estacion/:id", deleteDescripcionEstacionRoute)
}

// getDescripcionEstacionRoute   	GET Route
//
//	@Summary		Datos de Descripcion Estacion
//	@Description	Obtener descripciones de estaciones con filtros
//	@Tags			DescripcionEstacion
//	@Accept			json
//	@Produce		json
//	@Param			sistema		path		string	true	"Sistema de transporte"
//	@Param			id				query		int		false	"ID de la descripción"
//	@Param			nombre				query		string	false	"Search by nombre"
//	@Param			alcaldia_municipio	query		string	false	"Search by alcaldia_municipio"
//	@Param			num_comercial		query		string	false	"Search by num_comercial"
//	@Success		200					{array}	models.DescripcionEstacion
//	@Failure		400					{object}	httputil.HTTPError
//	@Failure		404					{object}	httputil.HTTPError
//	@Failure		500					{object}	httputil.HTTPError
//	@Router			/{sistema}/descripcion-estacion [get]
func getDescripcionEstacionRoute(c *gin.Context) {
	sistema := c.MustGet("sistemaValidado").(string)
	filtros := make(map[string]interface{})

	if sistema != "TODOS" {
		filtros["sistema"] = sistema
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

// postDescripcionEstacionRoute   	POST Route
//
//	@Summary		Crear Descripcion Estacion
//	@Description	Crear una nueva descripción de estación
//	@Tags			DescripcionEstacion
//	@Accept			json
//	@Produce		json
//	@Param			sistema	path		string	true	"Sistema de transporte"
//	@Param			descripcion	body		models.DescripcionEstacion	true	"Datos de la descripción de estación"
//	@Success		201				{object}	map[string]interface{}
//	@Failure		400				{object}	httputil.HTTPError
//	@Router			/{sistema}/descripcion-estacion [post]
func postDescripcionEstacionRoute(c *gin.Context) {
	var newDescripcion models.DescripcionEstacion
	if err := c.BindJSON(&newDescripcion); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "JSON inválido", "detalle": err.Error()})
		return
	}
	transporte.CreateDescripcionEstacion(newDescripcion)
	c.JSON(http.StatusCreated, gin.H{"mensaje": "Descripción de estación creada con éxito"})
}

// putDescripcionEstacionRoute   	PUT Route
//
//	@Summary		Actualizar Descripcion Estacion
//	@Description	Actualizar una descripción de estación por ID
//	@Tags			DescripcionEstacion
//	@Accept			json
//	@Produce		json
//	@Param			sistema	path		string	true	"Sistema de transporte"
//	@Param			id			path		int				true	"ID de la descripción de estación"
//	@Param			descripcion	body		models.DescripcionEstacion	true	"Datos actualizados"
//	@Success		200			{object}	map[string]interface{}
//	@Failure		400			{object}	httputil.HTTPError
//	@Router			/{sistema}/descripcion-estacion/{id} [put]
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

// deleteDescripcionEstacionRoute   	DELETE Route
//
//	@Summary		Eliminar Descripcion Estacion
//	@Description	Eliminar una descripción de estación por ID
//	@Tags			DescripcionEstacion
//	@Accept			json
//	@Produce		json
//	@Param			sistema	path		string	true	"Sistema de transporte"
//	@Param			id	path		int	true	"ID de la descripción de estación a eliminar"
//	@Success		200	{object} map[string]interface{}
//	@Failure		400	{object}	httputil.HTTPError
//	@Router			/{sistema}/descripcion-estacion/{id} [delete]
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
