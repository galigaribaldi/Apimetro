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

func addEstacionRoute(rg *gin.RouterGroup) {

	//Estaciones
	rg.GET("/estacion", getEstacionRoute)
	rg.POST("/estacion", postEstacionRoute)
	rg.DELETE("/estacion", deleteEstacionRoute)
	rg.PATCH("/estacion", updateEstacionRoute)

}

// getEstacionRoute   	GET Route
//
//	@Summary		Datos de Estacion
//	@Description	Obtener datos a través de filtros como nombre, línea, municipio, colores y CETRAM
//	@Tags			Estacion
//	@Accept			json
//	@Produce		json
//	@Param			sistema		path		string	true	"Sistema de transporte"
//	@Param			id		query		int		false	"ID interno de estación"
//	@Param			nombre		query		string	false	"Nombre de la estación"
//	@Param			linea_id	query		int		false	"ID de la línea"
//	@Param			alcaldia_municipio	query	string	false	"Alcaldía o municipio"
//	@Param			color_esp	query		string	false	"Color de línea en español"
//	@Param			color_en	query		string	false	"Color de línea en inglés"
//	@Param			anio		query		int		false	"Año de inauguración"
//	@Param			es_cetram	query		bool		false	"Filtra estaciones CETRAM"
//	@Success		200			{array}	models.Estacion
//	@Failure		400			{object}	httputil.HTTPError
//	@Failure		404			{object}	httputil.HTTPError
//	@Failure		500			{object}	httputil.HTTPError
//	@Router			/{sistema}/estacion [get]
func getEstacionRoute(c *gin.Context) {
	sistema := c.MustGet("sistemaValidado").(string)
	filtros := make(map[string]interface{})

	if sistema != "TODOS" {
		filtros["sistema"] = sistema
	}
	if id := c.Query("id"); id != "" {
		filtros["id"] = id
	}
	if nombreRaw := c.Query("nombre"); nombreRaw != "" {
		// Esto fuerza a que "n" + "~" se convierta en "ñ" real
		filtros["nombre"] = norm.NFC.String(nombreRaw)
	}
	if lineaID := c.Query("linea_id"); lineaID != "" {
		filtros["linea_id"] = lineaID
	}
	if alcaldia := c.Query("alcaldia_municipio"); alcaldia != "" {
		filtros["alcaldia_municipio"] = alcaldia
	}
	if numComercial := c.Query("num_comercial"); numComercial != "" {
		filtros["num_comercial"] = numComercial
	}
	if colorEsp := c.Query("color_esp"); colorEsp != "" {
		filtros["color_esp"] = colorEsp
	}
	if colorEn := c.Query("color_en"); colorEn != "" {
		filtros["color_en"] = colorEn
	}
	if anio := c.Query("anio"); anio != "" {
		filtros["anio"] = anio
	}
	if esCetram := c.Query("es_cetram"); esCetram != "" {
		filtros["es_cetram"] = esCetram
	}

	log.Println("Buscando Estaciones con filtros:", filtros)
	resultados := transporte.SearchEstaciones(filtros)
	c.JSON(http.StatusOK, resultados)
}

// ==========================================
// POST /movilidad/:sistema/estacion
// ==========================================
// postEstacionRoute   	POST Route
//
//	@Summary		Crear Estacion
//	@Description	Crear una nueva estación en el sistema de transporte
//	@Tags			Estacion
//	@Accept			json
//	@Produce		json
//	@Param			sistema	path		string	true	"Sistema de transporte"
//	@Param			estacion	body		models.Estacion	true	"Datos de la estación a crear"
//	@Success		201			{object}	map[string]interface{}
//	@Failure		400			{object}	httputil.HTTPError
//	@Router			/{sistema}/estacion [post]
func postEstacionRoute(c *gin.Context) {
	var newEstacion models.Estacion
	if err := c.BindJSON(&newEstacion); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "JSON inválido", "detalle": err.Error()})
		return
	}
	transporte.CreateEstacion(newEstacion)
	c.JSON(http.StatusCreated, gin.H{"mensaje": "Estación creada", "data": newEstacion})
}

// ==========================================
// DELETE /movilidad/:sistema/estacion?id=1
// ==========================================
// deleteEstacionRoute   	DELETE Route
//
//	@Summary		Eliminar Estacion
//	@Description	Eliminar una estación por su ID
//	@Tags			Estacion
//	@Accept			json
//	@Produce		json
//	@Param			sistema	path		string	true	"Sistema de transporte"
//	@Param			id	query		int	true	"ID de la estación a eliminar"
//	@Success		200			{object}	map[string]interface{}
//	@Failure		400			{object}	httputil.HTTPError
//	@Router			/{sistema}/estacion [delete]
func deleteEstacionRoute(c *gin.Context) {
	idStr := c.Query("id")
	id, err := strconv.Atoi(idStr)
	if err != nil || id == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Se requiere un ID numérico válido en el query (?id=X)"})
		return
	}

	transporte.DeleteEstacion(id)
	c.JSON(http.StatusOK, gin.H{"mensaje": "Estación eliminada con éxito"})
}

// ==========================================
// PATCH /movilidad/:sistema/estacion?id=1
// ==========================================
// updateEstacionRoute   	PATCH Route
//
//	@Summary		Actualizar Estacion
//	@Description	Actualizar los datos de una estación por su ID
//	@Tags			Estacion
//	@Accept			json
//	@Produce		json
//	@Param			sistema	path		string	true	"Sistema de transporte"
//	@Param			id		query		int				true	"ID de la estación a actualizar"
//	@Param			estacion	body		models.Estacion	true	"Datos actualizados de la estación"
//	@Success		200			{object}	map[string]interface{}
//	@Failure		400			{object}	httputil.HTTPError
//	@Router			/{sistema}/estacion [patch]
func updateEstacionRoute(c *gin.Context) {
	idStr := c.Query("id")
	id, err := strconv.Atoi(idStr)
	if err != nil || id == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Se requiere un ID numérico válido en el query (?id=X)"})
		return
	}

	var updateData models.Estacion
	if err := c.BindJSON(&updateData); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "JSON inválido"})
		return
	}

	updateData.ID = uint(id)
	transporte.UpdateEstacion(updateData)

	c.JSON(http.StatusOK, gin.H{"mensaje": "Estación actualizada correctamente"})
}
