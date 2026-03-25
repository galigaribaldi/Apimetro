package geojson

import (
	con "Apimetro/cmd/pkg/controller"
	modelsGeojson "Apimetro/cmd/pkg/models/ResponseGeoJson"
	"encoding/json"
	"log"
)

func SelectGeoJsonLineaBysistema(sistema string) modelsGeojson.FeatureCollection {
	var resultados []ResultGeoJsonLinea
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

func SelectGeoJsonEstacionBysistema(sistema string) modelsGeojson.FeatureCollection {
	// 1. Usamos la estructura exacta que creaste en ResultGeoJsonEstacion.go
	var resultados []ResultGeoJsonEstacion

	// 2. Consulta a la tabla de estaciones.
	// NOTA: Asegúrate de que tu tabla se llame 'estaciones' y tu columna espacial 'geom'
	query := `
		SELECT 
			e.nombre, 
			l.sistema, 
			e.tipo, 
			e.alcaldia_municipio, 
			ST_AsGeoJSON(e.geom) AS mapa
		FROM estacions e
		INNER JOIN lineas l ON e.linea_id = l.id
		WHERE l.sistema ILIKE ? AND e.geom IS NOT NULL
	`

	if result := con.DB.Raw(query, sistema).Scan(&resultados); result.Error != nil {
		log.Println("Error obteniendo GeoJson de estaciones", result.Error)
		return modelsGeojson.FeatureCollection{}
	}

	featureCollection := modelsGeojson.FeatureCollection{
		Type:     "FeatureCollection",
		Features: []modelsGeojson.Feature{},
	}

	// 3. Transformamos cada fila en un 'Feature' de tipo Point
	for _, row := range resultados {
		var geometry modelsGeojson.Geometry
		if err := json.Unmarshal([]byte(row.Mapa), &geometry); err != nil {
			log.Println("Error Parseando geometría de la estación", row.Nombre, err)
			continue
		}

		// Usamos los campos exactos de tu ResultGeoJsonEstacion
		propertys := map[string]interface{}{
			"nombre":             row.Nombre,
			"sistema":            row.Sistema,
			"tipo":               row.Tipo,
			"alcaldia_municipio": row.AlcaldiaMunicipio,
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
