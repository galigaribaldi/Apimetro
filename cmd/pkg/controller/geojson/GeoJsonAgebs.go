package geojson

import (
	con "Apimetro/cmd/pkg/controller"
	utilsGeoJson "Apimetro/cmd/pkg/controller/utils/GeoJson"
	modelsGeojson "Apimetro/cmd/pkg/models/ResponseGeoJson"
	"encoding/json"
	"log"
)

// SelectGeoJsonAgebs retorna una FeatureCollection con AGEBs urbanas del esquema plutarco.
// Filtros opcionales: entidad (código 2 dígitos), municipio_alcaldia (texto libre).
// Paginación: limit (default 500) y offset (default 0).
func SelectGeoJsonAgebs(filtros map[string]interface{}) modelsGeojson.FeatureCollection {
	var resultados []utilsGeoJson.ResultGeoJsonAgeb

	entidad := ""
	municipio := ""
	limit := 500
	offset := 0

	if v, ok := filtros["entidad"].(string); ok {
		entidad = v
	}
	if v, ok := filtros["municipio_alcaldia"].(string); ok {
		municipio = v
	}
	if v, ok := filtros["limit"].(int); ok && v > 0 {
		limit = v
	}
	if v, ok := filtros["offset"].(int); ok && v >= 0 {
		offset = v
	}

	log.Printf("GeoJSON AGEBs — entidad:'%s' municipio:'%s' limit:%d offset:%d",
		entidad, municipio, limit, offset)

	result := con.DB.Raw(`
		SELECT
			cve_ageb,
			entidad,
			municipio_alcaldia,
			poblacion_total,
			viviendas_habitadas,
			pea,
			area_km2,
			densidad_pob_km2,
			fuente,
			ST_AsGeoJSON(geom, 6) AS mapa
		FROM plutarco.agebs
		WHERE geom IS NOT NULL
		  AND ($1 = '' OR entidad = $1)
		  AND ($2 = '' OR municipio_alcaldia ILIKE '%' || $2 || '%')
		LIMIT $3 OFFSET $4
	`, entidad, municipio, limit, offset).Scan(&resultados)

	if result.Error != nil {
		log.Println("Error obteniendo GeoJSON de AGEBs:", result.Error)
		return modelsGeojson.FeatureCollection{}
	}

	log.Printf("GeoJSON AGEBs — %d registros encontrados", len(resultados))

	featureCollection := modelsGeojson.FeatureCollection{
		Type:     "FeatureCollection",
		Features: []modelsGeojson.Feature{},
	}

	for _, row := range resultados {
		var geometry modelsGeojson.Geometry
		if err := json.Unmarshal([]byte(row.Mapa), &geometry); err != nil {
			log.Printf("Error parseando geometría AGEB %s: %v", row.CveAgeb, err)
			continue
		}

		properties := map[string]interface{}{
			"cve_ageb":            row.CveAgeb,
			"entidad":             row.Entidad,
			"municipio_alcaldia":  row.MunicipioAlcaldia,
			"poblacion_total":     row.PoblacionTotal,
			"viviendas_habitadas": row.ViviendasHabitadas,
			"pea":                 row.Pea,
			"area_km2":            row.AreaKm2,
			"densidad_pob_km2":    row.DensidadPobKm2,
			"tipo_entidad":        "ageb",
			"fuente":              row.Fuente,
		}

		featureCollection.Features = append(featureCollection.Features, modelsGeojson.Feature{
			Type:       "Feature",
			Geometry:   geometry,
			Properties: properties,
		})
	}

	return featureCollection
}
