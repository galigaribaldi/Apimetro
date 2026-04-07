package utils

import (
	"Apimetro/cmd/pkg/models"
	responsegeojson "Apimetro/cmd/pkg/models/ResponseGeoJson"
)

func ConvertEstacionToJson(estaciones []models.Estacion) responsegeojson.FeatureCollection {
	var features []responsegeojson.Feature

	for _, est := range estaciones {
		features = append(features, responsegeojson.Feature{
			Type: "Feature",
			Geometry: responsegeojson.Geometry{
				Type:        "Point",
				Coordinates: []float64{est.Longitud, est.Latitud},
			},
			Properties: map[string]interface{}{
				"estacion_id":        int(est.ID),
				"nombre":             est.Nombre,
				"tipo":               est.Tipo,
				"alcaldia_municipio": est.Alcaldia_municipio,
				"anio":               est.Anio,
				"sistema":            est.Sistema,
				"existe":             est.Existe,
			},
		})
	}

	return responsegeojson.FeatureCollection{
		Type:     "FeatureCollection",
		Features: features,
	}
}
