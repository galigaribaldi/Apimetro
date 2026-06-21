package geojson

import (
	con "Apimetro/cmd/pkg/controller"
	"Apimetro/cmd/pkg/models"
	"log"
)

// SelectAfluenciaLinea retorna registros de afluencia mensual por línea.
// Filtros opcionales: sistema, anio, mes_num, linea_id.
func SelectAfluenciaLinea(filtros map[string]interface{}) models.AfluenciaLineaResponse {
	var resultados []models.AfluenciaLinea

	sistema := ""
	anio := 0
	mesNum := 0
	lineaID := 0

	if v, ok := filtros["sistema"].(string); ok {
		sistema = v
	}
	if v, ok := filtros["anio"].(int); ok {
		anio = v
	}
	if v, ok := filtros["mes_num"].(int); ok {
		mesNum = v
	}
	if v, ok := filtros["linea_id"].(int); ok {
		lineaID = v
	}

	log.Printf("Afluencia línea — sistema:'%s' anio:%d mes_num:%d linea_id:%d",
		sistema, anio, mesNum, lineaID)

	result := con.DB.Raw(`
		SELECT
			a.linea_id,
			a.sistema,
			l.num_comercial,
			l.nombre AS nombre_linea,
			a.anio,
			a.mes_num,
			a.mes,
			a.afluencia,
			a.fuente
		FROM plutarco.afluencia_linea a
		JOIN public.lineas l ON l.id = a.linea_id
		WHERE ($1 = '' OR a.sistema = $1)
		  AND ($2 = 0  OR a.anio = $2)
		  AND ($3 = 0  OR a.mes_num = $3)
		  AND ($4 = 0  OR a.linea_id = $4)
		ORDER BY a.sistema, l.num_comercial, a.anio, a.mes_num
	`, sistema, anio, mesNum, lineaID).Scan(&resultados)

	if result.Error != nil {
		log.Println("Error obteniendo afluencia por línea:", result.Error)
		return models.AfluenciaLineaResponse{Total: 0, Data: []models.AfluenciaLinea{}}
	}

	log.Printf("Afluencia línea — %d registros encontrados", len(resultados))

	return models.AfluenciaLineaResponse{
		Total: len(resultados),
		Data:  resultados,
	}
}
