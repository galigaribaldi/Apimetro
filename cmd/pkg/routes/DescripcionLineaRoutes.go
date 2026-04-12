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
//	@Summary		Consultar Descripciones de Línea
//	@Description	Retorna registros descriptivos e históricos de líneas de transporte.
//	@Description	Incluye información sobre terminales originales, tipo de línea, dirección, ampliaciones y descripción textual.
//	@Description	Útil para construir fichas informativas o mostrar la historia de una línea.
//	@Description	Si el sistema es TODOS, devuelve descripciones de todos los sistemas.
//	@Tags			DescripcionLinea
//	@Accept			json
//	@Produce		json
//	@Param			sistema				path	string	true	"Sistema de transporte. Valores: METRO, MB, CBB, RTP, TROLE, TL, MEXIBUS, MEXICABLE, INTERURBANO, CC, TODOS"
//	@Param			id					query	int		false	"ID interno del registro de descripción"
//	@Param			terminal_original	query	string	false	"Nombre de la terminal original de la línea (ej: 'Observatorio', 'Pantitlán')"
//	@Param			linea_base			query	string	false	"ID de la línea base a la que corresponde esta descripción (ej: '1')"
//	@Param			num_comercial		query	string	false	"Número o clave comercial de la línea (ej: '1', 'A', 'B')"
//	@Success		200					{array}		models.DescripcionLinea		"Lista de descripciones de línea"
//	@Failure		400					{object}	map[string]interface{}		"Parámetros inválidos"
//	@Failure		404					{object}	map[string]interface{}		"No se encontraron registros"
//	@Failure		500					{object}	map[string]interface{}		"Error interno del servidor"
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
//	@Summary		Crear Descripción de Línea
//	@Description	Registra una nueva descripción histórica o informativa para una línea de transporte.
//	@Description	Debe asociarse a una línea existente mediante el campo `linea_base`.
//	@Tags			DescripcionLinea
//	@Accept			json
//	@Produce		json
//	@Param			sistema		path	string					true	"Sistema de transporte"
//	@Param			descripcion	body	models.DescripcionLinea	true	"Objeto DescripcionLinea con los datos a registrar"
//	@Success		201			{object}	map[string]interface{}	"Descripción de línea creada con éxito"
//	@Failure		400			{object}	map[string]interface{}	"JSON inválido o campos requeridos faltantes"
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
//	@Summary		Eliminar Descripción de Línea
//	@Description	Elimina un registro de descripción de línea por su ID. Esta operación es irreversible.
//	@Tags			DescripcionLinea
//	@Accept			json
//	@Produce		json
//	@Param			sistema	path	string	true	"Sistema de transporte"
//	@Param			id		path	int		true	"ID del registro de descripción a eliminar"
//	@Success		200		{object}	map[string]interface{}	"Descripción eliminada con éxito"
//	@Failure		400		{object}	map[string]interface{}	"ID inválido"
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
//	@Summary		Actualizar Descripción de Línea
//	@Description	Reemplaza completamente el registro de descripción de línea con el ID indicado.
//	@Description	A diferencia de PATCH, PUT requiere enviar el objeto completo.
//	@Tags			DescripcionLinea
//	@Accept			json
//	@Produce		json
//	@Param			sistema		path	string					true	"Sistema de transporte"
//	@Param			id			path	int						true	"ID del registro a actualizar"
//	@Param			descripcion	body	models.DescripcionLinea	true	"Objeto DescripcionLinea con los datos actualizados"
//	@Success		200			{object}	map[string]interface{}	"Descripción actualizada con éxito"
//	@Failure		400			{object}	map[string]interface{}	"ID inválido o JSON mal formado"
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
