package geojson

import (
	con "Apimetro/cmd/pkg/controller"
	"Apimetro/cmd/pkg/models"
	"log"
)

// SelectAfluenciaEstacion retorna registros de afluencia mensual por estación del Metro.
// Filtros opcionales: linea_id, estacion_id, anio, mes_num.
func SelectAfluenciaEstacion(filtros map[string]interface{}) models.AfluenciaEstacionResponse {
	var resultados []models.AfluenciaEstacion

	lineaID := 0
	estacionID := 0
	anio := 0
	mesNum := 0
	numComercial := ""
	nombreEstacion := ""

	if v, ok := filtros["linea_id"].(int); ok {
		lineaID = v
	}
	if v, ok := filtros["estacion_id"].(int); ok {
		estacionID = v
	}
	if v, ok := filtros["anio"].(int); ok {
		anio = v
	}
	if v, ok := filtros["mes_num"].(int); ok {
		mesNum = v
	}
	if v, ok := filtros["num_comercial"].(string); ok {
		numComercial = v
	}
	if v, ok := filtros["nombre_estacion"].(string); ok {
		nombreEstacion = v
	}

	log.Printf("Afluencia estación — linea_id:%d estacion_id:%d anio:%d mes_num:%d num_comercial:'%s' nombre_estacion:'%s'",
		lineaID, estacionID, anio, mesNum, numComercial, nombreEstacion)

	result := con.DB.Raw(`
		SELECT
			a.estacion_id,
			e.nombre    AS nombre_estacion,
			a.linea_id,
			l.num_comercial,
			l.nombre    AS nombre_linea,
			a.anio,
			a.mes_num,
			a.mes,
			a.afluencia,
			a.fuente
		FROM plutarco.afluencia_estacion a
		JOIN public.estacions e ON e.id = a.estacion_id
		JOIN public.lineas    l ON l.id = a.linea_id
		WHERE ($1 = 0  OR a.linea_id    = $1)
		  AND ($2 = 0  OR a.estacion_id = $2)
		  AND ($3 = 0  OR a.anio        = $3)
		  AND ($4 = 0  OR a.mes_num     = $4)
		  AND ($5 = '' OR l.num_comercial = $5)
		  AND ($6 = '' OR e.nombre ILIKE '%' || $6 || '%')
		ORDER BY l.num_comercial, e.nombre, a.anio, a.mes_num
	`, lineaID, estacionID, anio, mesNum, numComercial, nombreEstacion).Scan(&resultados)

	if result.Error != nil {
		log.Println("Error obteniendo afluencia por estación:", result.Error)
		return models.AfluenciaEstacionResponse{Total: 0, Data: []models.AfluenciaEstacion{}}
	}

	log.Printf("Afluencia estación — %d registros encontrados", len(resultados))

	return models.AfluenciaEstacionResponse{
		Total: len(resultados),
		Data:  resultados,
	}
}
