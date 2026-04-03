package geojson

import (
	con "Apimetro/cmd/pkg/controller"
	utilsGeoJson "Apimetro/cmd/pkg/controller/utils/GeoJson"
	modelsGeojson "Apimetro/cmd/pkg/models/ResponseGeoJson"
	"encoding/json"
	"log"
	"strings"
)

func SelectGeoJsonPoligono(entidad string, nivel string, nombre string) modelsGeojson.FeatureCollection {
	var resultados []utilsGeoJson.ResultGeoJsonPoligono

	query := con.DB.Table("limites_territoriales").
		Select(`nombre, entidad, nivel, cvegeo, ST_AsGeoJSON(geom) AS mapa`)

	// Filtros por parámetros
	if entidad != "" {
		query = query.Where("entidad ILIKE ?", "%"+entidad+"%")
	}
	if nivel != "" {
		query = query.Where("nivel = ?", nivel)
	}

	// Separar los nombres por comas
	// Si hay más de un nombre, agregamos los OR al subgrupo
	if nombre != "" {
		nombres := strings.Split(nombre, ",")

		primerNombre := strings.TrimSpace(nombres[0])
		subQuery := con.DB.Where("nombre ILIKE ?", "%"+primerNombre+"%")

		for i := 1; i < len(nombres); i++ {
			nombreLimpio := strings.TrimSpace(nombres[i])
			subQuery = subQuery.Or("nombre ILIKE ?", "%"+nombreLimpio+"%")
		}

		query = query.Where(subQuery)
	}

	if result := query.Scan(&resultados); result.Error != nil {
		log.Println("Error en Poligonos:", result.Error)
		return modelsGeojson.FeatureCollection{}
	}

	fc := modelsGeojson.FeatureCollection{
		Type:     "FeatureCollection",
		Features: []modelsGeojson.Feature{},
	}

	for _, row := range resultados {
		var geom modelsGeojson.Geometry
		json.Unmarshal([]byte(row.Mapa), &geom)

		feature := modelsGeojson.Feature{
			Type:     "Feature",
			Geometry: geom,
			Properties: map[string]interface{}{
				"nombre":       row.Nombre,
				"entidad":      row.Entidad,
				"nivel":        row.Nivel,
				"cvegeo":       row.Cvegeo,
				"tipo_entidad": "poligono_administrativo",
			},
		}
		fc.Features = append(fc.Features, feature)
	}
	return fc
}
