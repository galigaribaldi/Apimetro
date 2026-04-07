package routes

import (
	"log"
	"net/http"

	"strconv"

	transporte "Apimetro/cmd/pkg/controller/transporte"
	"Apimetro/cmd/pkg/models"

	"github.com/gin-gonic/gin"
)

/*************  ✨ Windsurf Command ⭐  *************/
// addDescriptionLineRoute configura las rutas para la API de descripciones de línea, teniendo en cuenta
// la arquitectura dinámica dependiendo del sistema de transporte
//
//	@Summary		Descripción de Línea
//	@Description		Obtener, crear, actualizar y eliminar descripciones de línea
//	@Tags			Descripción de Línea
/*******  68ce6771-2981-42ef-acc5-81ecb5553556  *******/
func addDescriptionLineRoute(rg *gin.RouterGroup) {

	rg.GET("/descripcion-linea", getDescripcionLineaRoute)
	rg.POST("/descripcion-linea", postDescripcionLineaRoute)
	rg.DELETE("/descripcion-linea/:id", deleteDescripcionLineaRoute)
	rg.PUT("/descripcion-linea/:id", putDescripcionLineaRoute)
}

// getDescripcionLineaRoute   	GET Route
//
//	@Summary		Datos de Descripcion Linea
//	@Description	Obtener descripciones de líneas con filtros
//	@Tags			DescripcionLinea
//	@Accept			json
//	@Produce		json
//	@Param			sistema		path		string	true	"Sistema de transporte"
//	@Param			id				query		int		false	"ID de la descripción"
//	@Param			terminal_original	query		string	false	"Search by terminal_original"
//	@Param			linea_base			query		string	false	"Search by linea_base"
//	@Param			num_comercial		query		string	false	"Search by num_comercial"
//	@Success		200					{array}	models.DescripcionLinea
//	@Failure		400					{object}	httputil.HTTPError
//	@Failure		404					{object}	httputil.HTTPError
//	@Failure		500					{object}	httputil.HTTPError
//	@Router			/{sistema}/descripcion-linea [get]
func getDescripcionLineaRoute(c *gin.Context) {
	sistema := c.MustGet("sistemaValidado").(string)
	filtros := make(map[string]interface{})

	if sistema != "TODOS" {
		filtros["sistema"] = sistema
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

// postDescripcionLineaRoute   	POST Route
//
//	@Summary		Crear Descripcion Linea
//	@Description	Crear una nueva descripción de línea
//	@Tags			DescripcionLinea
//	@Accept			json
//	@Produce		json
//	@Param			sistema	path		string	true	"Sistema de transporte"
//	@Param			descripcion	body		models.DescripcionLinea	true	"Datos de la descripción de línea"
//	@Success		201			{object}	map[string]interface{}
//	@Failure		400			{object}	httputil.HTTPError
//	@Router			/{sistema}/descripcion-linea [post]
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

// deleteDescripcionLineaRoute   	DELETE Route
//
//	@Summary		Eliminar Descripcion Linea
//	@Description	Eliminar una descripción de línea por ID
//	@Tags			DescripcionLinea
//	@Accept			json
//	@Produce		json
//	@Param			sistema	path		string	true	"Sistema de transporte"
//	@Param			id	path		int	true	"ID de la descripción de línea a eliminar"
//	@Success		200	{object} map[string]interface{}
//	@Failure		400	{object}	httputil.HTTPError
//	@Router			/{sistema}/descripcion-linea/{id} [delete]
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

// putDescripcionLineaRoute   	PUT Route
//
//	@Summary		Actualizar Descripcion Linea
//	@Description	Actualizar una descripción de línea por ID
//	@Tags			DescripcionLinea
//	@Accept			json
//	@Produce		json
//	@Param			sistema	path		string	true	"Sistema de transporte"
//	@Param			id			path		int				true	"ID de la descripción de línea"
//	@Param			descripcion	body		models.DescripcionLinea	true	"Datos actualizados"
//	@Success		200			{object}	map[string]interface{}
//	@Failure		400			{object}	httputil.HTTPError
//	@Router			/{sistema}/descripcion-linea/{id} [put]
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
