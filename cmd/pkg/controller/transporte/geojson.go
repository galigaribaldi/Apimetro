package transporte

import (
	con "Apimetro/cmd/pkg/controller"
	utilsGeoJson "Apimetro/cmd/pkg/controller/utils/GeoJson"
	modelsGeojson "Apimetro/cmd/pkg/models/ResponseGeoJson"
	"encoding/json"
	"log"
)

func SelectGeoJsonLineaConFiltros(filtros map[string]interface{}) modelsGeojson.FeatureCollection {
	var resultados []utilsGeoJson.ResultGeoJsonLinea

	query := con.DB.Table("lineas").
		Select("lineas.nombre AS nombre_linea, lineas.sistema, lineas.color_esp, lineas.tam_km, ramals.nombre_ramal, ST_AsGeoJSON(ramals.geom) AS mapa").
		Joins("INNER JOIN ramals ON lineas.id = ramals.linea_id").
		Where("ramals.geom IS NOT NULL")

	// Aplicamos Filtros
	if sis, ok := filtros["sistema"]; ok && sis != "" && sis != "%" {
		query = query.Where("lineas.sistema ILIKE ?", sis)
	}
	if nc, ok := filtros["num_comercial"]; ok && nc != "" {
		query = query.Where("lineas.num_comercial = ?", nc)
	}
	if existe, ok := filtros["existe"]; ok {
		query = query.Where("lineas.existe = ?", existe)
	}
	if nr, ok := filtros["nombre_ramal"]; ok && nr != "" {
		query = query.Where("ramals.nombre_ramal ILIKE ?", "%"+nr.(string)+"%")
	}

	if result := query.Scan(&resultados); result.Error != nil {
		log.Println("Error obteniendo GeoJson de líneas", result.Error)
		return modelsGeojson.FeatureCollection{}
	}

	featureCollection := modelsGeojson.FeatureCollection{
		Type:     "FeatureCollection",
		Features: []modelsGeojson.Feature{},
	}

	// Parseo a Feature
	for _, row := range resultados {
		var geometry modelsGeojson.Geometry
		if err := json.Unmarshal([]byte(row.Mapa), &geometry); err != nil {
			log.Println("Error Parseando geometría del ramal", row.NombreRamal, err)
			continue
		}
		propertys := map[string]interface{}{
			"nombre_linea": row.NombreLinea,
			"sistema":      row.Sistema,
			"color_esp":    row.ColorEsp,
			"tam_km":       row.TamKm,
			"nombre_ramal": row.NombreRamal,
		}
		featureCollection.Features = append(featureCollection.Features, modelsGeojson.Feature{
			Type:       "Feature",
			Geometry:   geometry,
			Properties: propertys,
		})
	}
	return featureCollection
}

func SelectGeoJsonEstacionConFiltros(filtros map[string]interface{}) modelsGeojson.FeatureCollection {
	var resultados []utilsGeoJson.ResultGeoJsonEstacion

	// Usamos Distinct() para evitar estaciones duplicadas si se hace JOIN con ramales
	query := con.DB.Table("estacions").
		Select("estacions.nombre, lineas.sistema, estacions.tipo, estacions.alcaldia_municipio, ST_AsGeoJSON(estacions.geom) AS mapa").
		Joins("INNER JOIN lineas ON estacions.linea_id = lineas.id").
		Where("estacions.geom IS NOT NULL").
		Distinct()

	// 1. Filtros básicos
	if sis, ok := filtros["sistema"]; ok && sis != "" && sis != "%" {
		query = query.Where("lineas.sistema ILIKE ?", sis)
	}
	if nc, ok := filtros["num_comercial"]; ok && nc != "" {
		query = query.Where("lineas.num_comercial = ?", nc)
	}
	if alc, ok := filtros["alcaldia_municipio"]; ok && alc != "" {
		query = query.Where("estacions.alcaldia_municipio ILIKE ?", "%"+alc.(string)+"%")
	}

	// 2. NUEVO FILTRO: nombre_ramal
	// Hacemos el JOIN dinámico a la tabla ramals solo si mandan este filtro
	if nr, ok := filtros["nombre_ramal"]; ok && nr != "" {
		query = query.Joins("INNER JOIN ramals ON lineas.id = ramals.linea_id").
			Where("ramals.nombre_ramal ILIKE ?", "%"+nr.(string)+"%")
	}

	// Nota: "estado_ciudad" pertenece a la tabla descripcion_estacions, si deseas filtrarlo
	// tendrías que hacer un JOIN adicional a esa tabla aquí.

	if result := query.Scan(&resultados); result.Error != nil {
		log.Println("Error obteniendo GeoJson de estaciones", result.Error)
		return modelsGeojson.FeatureCollection{}
	}

	featureCollection := modelsGeojson.FeatureCollection{
		Type:     "FeatureCollection",
		Features: []modelsGeojson.Feature{},
	}

	for _, row := range resultados {
		var geometry modelsGeojson.Geometry
		if err := json.Unmarshal([]byte(row.Mapa), &geometry); err != nil {
			log.Println("Error Parseando geometría de la estación", row.Nombre, err)
			continue
		}
		propertys := map[string]interface{}{
			"nombre":             row.Nombre,
			"sistema":            row.Sistema,
			"tipo":               row.Tipo,
			"alcaldia_municipio": row.AlcaldiaMunicipio,
		}
		featureCollection.Features = append(featureCollection.Features, modelsGeojson.Feature{
			Type:       "Feature",
			Geometry:   geometry,
			Properties: propertys,
		})
	}
	return featureCollection
}
