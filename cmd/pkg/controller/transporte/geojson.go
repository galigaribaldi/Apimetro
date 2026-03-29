package transporte

import (
	con "Apimetro/cmd/pkg/controller"
	utilsGeoJson "Apimetro/cmd/pkg/controller/utils/GeoJson"
	modelsGeojson "Apimetro/cmd/pkg/models/ResponseGeoJson"
	"encoding/json"
	"log"
	"strings"
)

func SelectGeoJsonLineaConFiltros(filtros map[string]interface{}) modelsGeojson.FeatureCollection {
	var resultados []utilsGeoJson.ResultGeoJsonLinea

	query := con.DB.Table("lineas").
		Select("lineas.nombre AS nombre_linea, lineas.sistema, lineas.color_esp, lineas.tam_km, ramals.nombre_ramal, ST_AsGeoJSON(ST_Multi(ST_Union(ramals.geom))) AS mapa").
		Joins("INNER JOIN ramals ON lineas.id = ramals.linea_id").
		Where("ramals.geom IS NOT NULL")

	// Dividir filtros por sistema (poner varios sistemas)
	if sis, ok := filtros["sistema"]; ok && sis != "" && sis != "%" {
		sistemas := strings.Split(sis.(string), ",")

		var condiciones []string
		var valores []interface{}

		for _, s := range sistemas {
			condiciones = append(condiciones, "lineas.sistema ILIKE ?")
			valores = append(valores, strings.TrimSpace(s))
		}

		query = query.Where(strings.Join(condiciones, " OR "), valores...)
	}
	if nc, ok := filtros["num_comercial"]; ok && nc != "" {
		query = query.Where("lineas.num_comercial = ?", nc)
	}
	if existe, ok := filtros["existe"]; ok {
		query = query.Where("lineas.existe = ?", existe)
	}
	// Separar los parámetros por comas
	if nr, ok := filtros["nombre_ramal"]; ok && nr != "" {
		ramales := strings.Split(nr.(string), ",")

		var condiciones []string
		var valores []interface{}

		for _, ramal := range ramales {
			condiciones = append(condiciones, "ramals.nombre_ramal ILIKE ?")
			valores = append(valores, "%"+strings.TrimSpace(ramal)+"%")
		}

		query = query.Where(strings.Join(condiciones, " OR "), valores...)
	}

	query = query.Group("lineas.nombre, lineas.sistema, lineas.color_esp, lineas.tam_km, ramals.nombre_ramal")

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

	query := con.DB.Table("estacions").
		Select("estacions.nombre, lineas.sistema, estacions.tipo, estacions.alcaldia_municipio, ST_AsGeoJSON(estacions.geom) AS mapa").
		Joins("INNER JOIN lineas ON estacions.linea_id = lineas.id").
		Where("estacions.geom IS NOT NULL").
		Distinct()

	// Dividir filtros por sistema (poner varios sistemas)
	if sis, ok := filtros["sistema"]; ok && sis != "" && sis != "%" {
		sistemas := strings.Split(sis.(string), ",")

		var condiciones []string
		var valores []interface{}

		for _, s := range sistemas {
			condiciones = append(condiciones, "lineas.sistema ILIKE ?")
			valores = append(valores, strings.TrimSpace(s))
		}

		query = query.Where(strings.Join(condiciones, " OR "), valores...)
	}
	if nc, ok := filtros["num_comercial"]; ok && nc != "" {
		query = query.Where("lineas.num_comercial = ?", nc)
	}
	if alc, ok := filtros["alcaldia_municipio"]; ok && alc != "" {
		query = query.Where("estacions.alcaldia_municipio ILIKE ?", "%"+alc.(string)+"%")
	}
	if existe, ok := filtros["existe"]; ok {
		query = query.Where("lineas.existe = ?", existe)
	}

	// 2. NUEVO FILTRO: nombre_ramal
	// Hacemos el JOIN dinámico a la tabla ramals solo si mandan este filtro
	if nr, ok := filtros["nombre_ramal"]; ok && nr != "" {
		ramales := strings.Split(nr.(string), ",")

		var condiciones []string
		var valores []interface{}

		for _, ramal := range ramales {
			condiciones = append(condiciones, "ramals.nombre_ramal ILIKE ?")
			valores = append(valores, "%"+strings.TrimSpace(ramal)+"%") // TrimSpace quita espacios accidentales
		}

		query = query.Joins("INNER JOIN ramals ON lineas.id = ramals.linea_id").
			Where(strings.Join(condiciones, " OR "), valores...)
	}

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
