package geojson

import (
	con "Apimetro/cmd/pkg/controller"
	utilsGeoJson "Apimetro/cmd/pkg/controller/utils/GeoJson"
	modelsGeojson "Apimetro/cmd/pkg/models/ResponseGeoJson"
	"encoding/json"
	"log"
)

func init() {
	con.ConnectDataBase()
}

func SelectGeoJsonLineaBysistema(sistema string) modelsGeojson.FeatureCollection {
	var resultados []utilsGeoJson.ResultGeoJsonLinea
	query := `
		SELECT 
			l.nombre AS nombre_linea, 
			l.sistema, 
			l.color_esp, 
			l.tam_km, 
			r.nombre_ramal, 
			ST_AsGeoJSON(r.geom) AS mapa
		FROM lineas l
		INNER JOIN ramals r ON l.id = r.linea_id
		WHERE l.sistema ILIKE ? AND r.geom IS NOT NULL
	`
	if result := con.DB.Raw(query, sistema).Scan(&resultados); result.Error != nil {
		log.Println("Error obteniendo GeoJson de líneas", result.Error)
		return modelsGeojson.FeatureCollection{}
	}
	featureCollection := modelsGeojson.FeatureCollection{
		Type:     "FeatureCollection",
		Features: []modelsGeojson.Feature{},
	}

	// Transform row to 'Feature dynamicall
	for _, row := range resultados {
		var geometry modelsGeojson.Geometry
		if err := json.Unmarshal([]byte(row.Mapa), &geometry); err != nil {
			log.Println("Error Parseando geometría del ramal", row.NombreRamal, err)
			continue
		}
		propertys := map[string]interface{}{
			"nombre_linea": row.NombreLinea,
			"sistema":      row.Sistema,
			"color":        row.ColorEsp,
			"tam_km":       row.TamKm,
			"nombre_ramal": row.NombreRamal,
		}
		feature := modelsGeojson.Feature{
			Type:       "Feature",
			Geometry:   geometry,
			Properties: propertys,
		}
		featureCollection.Features = append(featureCollection.Features, feature)
	}
	return featureCollection
}
