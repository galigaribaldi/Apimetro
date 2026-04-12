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
//	@Summary		Consultar Estaciones de Transporte
//	@Description	Retorna datos descriptivos (JSON) de estaciones del sistema indicado en la ruta.
//	@Description	Si el sistema es TODOS, devuelve estaciones de todos los sistemas disponibles.
//	@Description	Los CETRAM (Centros de Transferencia Modal) son nodos multimodales donde convergen varios sistemas.
//	@Description	La búsqueda por nombre usa coincidencia parcial (ILIKE) y normaliza caracteres especiales (ñ, tildes).
//	@Tags			Estacion
//	@Accept			json
//	@Produce		json
//	@Param			sistema				path	string	true	"Sistema de transporte. Valores: METRO, MB, CBB, RTP, TROLE, TL, MEXIBUS, MEXICABLE, INTERURBANO, CC, TODOS"
//	@Param			id					query	int		false	"ID interno de la estación en la base de datos"
//	@Param			nombre				query	string	false	"Nombre de la estación (ej: 'Tacubaya'). Búsqueda parcial e insensible a mayúsculas."
//	@Param			linea_id			query	int		false	"ID interno de la línea a la que pertenece la estación"
//	@Param			alcaldia_municipio	query	string	false	"Alcaldía (CDMX) o municipio del Área Metropolitana (ej: 'Miguel Hidalgo', 'Naucalpan de Juárez')"
//	@Param			num_comercial		query	string	false	"Número o clave comercial de la línea (ej: '1', 'MB1')"
//	@Param			color_esp			query	string	false	"Color identificador de la línea en español (ej: 'Rosa', 'Azul', 'Naranja')"
//	@Param			color_en			query	string	false	"Color identificador de la línea en inglés (ej: 'Pink', 'Blue', 'Orange')"
//	@Param			anio				query	int		false	"Año de inauguración de la estación (ej: 1969)"
//	@Param			es_cetram			query	bool	false	"true para filtrar únicamente estaciones que son CETRAM"
//	@Success		200					{array}		models.Estacion			"Lista de estaciones que coinciden con los filtros"
//	@Failure		400					{object}	map[string]interface{}	"Parámetros inválidos"
//	@Failure		404					{object}	map[string]interface{}	"No se encontraron estaciones"
//	@Failure		500					{object}	map[string]interface{}	"Error interno del servidor"
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
//	@Summary		Crear Estación de Transporte
//	@Description	Registra una nueva estación en el sistema especificado.
//	@Description	Requiere al menos `nombre`, `sistema` y `linea_id` para asociarla a una línea existente.
//	@Tags			Estacion
//	@Accept			json
//	@Produce		json
//	@Param			sistema		path	string			true	"Sistema de transporte"
//	@Param			estacion	body	models.Estacion	true	"Objeto Estacion con los datos a registrar"
//	@Success		201			{object}	map[string]interface{}	"Estación creada exitosamente"
//	@Failure		400			{object}	map[string]interface{}	"JSON inválido o campos requeridos faltantes"
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
//	@Summary		Eliminar Estación de Transporte
//	@Description	Elimina una estación por su ID interno. Esta operación es irreversible.
//	@Tags			Estacion
//	@Accept			json
//	@Produce		json
//	@Param			sistema	path	string	true	"Sistema de transporte"
//	@Param			id		query	int		true	"ID interno de la estación a eliminar (ej: ?id=10)"
//	@Success		200		{object}	map[string]interface{}	"Estación eliminada con éxito"
//	@Failure		400		{object}	map[string]interface{}	"ID inválido o faltante"
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
//	@Summary		Actualizar Estación de Transporte
//	@Description	Actualiza los datos de una estación por su ID interno.
//	@Description	Se reemplazan todos los campos enviados en el body (comportamiento de PATCH con objeto completo).
//	@Tags			Estacion
//	@Accept			json
//	@Produce		json
//	@Param			sistema		path	string			true	"Sistema de transporte"
//	@Param			id			query	int				true	"ID interno de la estación a actualizar (ej: ?id=10)"
//	@Param			estacion	body	models.Estacion	true	"Objeto Estacion con los datos actualizados"
//	@Success		200			{object}	map[string]interface{}	"Estación actualizada correctamente"
//	@Failure		400			{object}	map[string]interface{}	"ID inválido o JSON mal formado"
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
