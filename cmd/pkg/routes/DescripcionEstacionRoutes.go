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
//	@Summary		Consultar Descripciones de Estación
//	@Description	Retorna registros descriptivos e históricos de estaciones de transporte.
//	@Description	Complementa los datos de la tabla principal de Estaciones con información histórica o alternativa.
//	@Description	Incluye clave oficial (cve_est), tipo, alcaldía y año de apertura.
//	@Description	Si el sistema es TODOS, devuelve descripciones de todos los sistemas.
//	@Tags			DescripcionEstacion
//	@Accept			json
//	@Produce		json
//	@Param			sistema				path	string	true	"Sistema de transporte. Valores: METRO, MB, CBB, RTP, TROLE, TL, MEXIBUS, MEXICABLE, INTERURBANO, CC, TODOS"
//	@Param			id					query	int		false	"ID interno del registro de descripción"
//	@Param			nombre				query	string	false	"Nombre de la estación (ej: 'Tacubaya'). Búsqueda parcial."
//	@Param			alcaldia_municipio	query	string	false	"Alcaldía o municipio donde se ubica (ej: 'Miguel Hidalgo', 'Ecatepec de Morelos')"
//	@Param			num_comercial		query	string	false	"Número o clave comercial de la línea a la que pertenece (ej: '1')"
//	@Success		200					{array}		models.DescripcionEstacion	"Lista de descripciones de estación"
//	@Failure		400					{object}	map[string]interface{}		"Parámetros inválidos"
//	@Failure		404					{object}	map[string]interface{}		"No se encontraron registros"
//	@Failure		500					{object}	map[string]interface{}		"Error interno del servidor"
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
//	@Summary		Crear Descripción de Estación
//	@Description	Registra una nueva descripción histórica o informativa para una estación.
//	@Description	Debe asociarse a una estación existente mediante el campo `estacion_id`.
//	@Tags			DescripcionEstacion
//	@Accept			json
//	@Produce		json
//	@Param			sistema		path	string						true	"Sistema de transporte"
//	@Param			descripcion	body	models.DescripcionEstacion	true	"Objeto DescripcionEstacion con los datos a registrar"
//	@Success		201			{object}	map[string]interface{}	"Descripción de estación creada con éxito"
//	@Failure		400			{object}	map[string]interface{}	"JSON inválido o campos requeridos faltantes"
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
//	@Summary		Actualizar Descripción de Estación
//	@Description	Reemplaza completamente el registro de descripción de estación con el ID indicado.
//	@Tags			DescripcionEstacion
//	@Accept			json
//	@Produce		json
//	@Param			sistema		path	string						true	"Sistema de transporte"
//	@Param			id			path	int							true	"ID del registro a actualizar"
//	@Param			descripcion	body	models.DescripcionEstacion	true	"Objeto DescripcionEstacion con los datos actualizados"
//	@Success		200			{object}	map[string]interface{}	"Descripción de estación actualizada con éxito"
//	@Failure		400			{object}	map[string]interface{}	"ID inválido o JSON mal formado"
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
//	@Summary		Eliminar Descripción de Estación
//	@Description	Elimina un registro de descripción de estación por su ID. Esta operación es irreversible.
//	@Tags			DescripcionEstacion
//	@Accept			json
//	@Produce		json
//	@Param			sistema	path	string	true	"Sistema de transporte"
//	@Param			id		path	int		true	"ID del registro de descripción a eliminar"
//	@Success		200		{object}	map[string]interface{}	"Descripción de estación eliminada con éxito"
//	@Failure		400		{object}	map[string]interface{}	"ID inválido"
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
