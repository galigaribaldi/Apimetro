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
			Properties: responsegeojson.Properties{
				EstacionID:        int(est.ID),
				Nombre:            est.Nombre,
				Tipo:              est.Tipo,
				AlcaldiaMunicipio: est.Alcaldia_municipio,
				Anio:              est.Anio,
				Sistema:           est.Sistema,
				Existe:            est.Existe,
			},
		})
	}

	return responsegeojson.FeatureCollection{
		Type:     "FeatureCollection",
		Features: features,
	}
}
