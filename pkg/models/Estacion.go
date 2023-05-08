package models

type Point struct {
	X, Y float64
}
type Estacion struct {
	ID                 uint    `json: "estacion_id" 	gorm: "primary_key"`
	Nombre             string  `json: "name"`
	Cve_est            string  `json: "cveest"`
	Tipo               string  `json: "tipo"`
	Alcaldia_municipio string  `json: "alacaldia_municipio"`
	Anio               int16   `json: "anio"`
	Estado_ciudad      string  `json: "estado_ciudad"`
	Longitud           float64 `json: "longitud"`
	Latitud            float64 `json: "latitud"`
	Linea              Linea   `json: "linea" 			gorm: "references:LineaID"`
	LineaID            int16
	Ubicacion          Point `json: "ubicacion"`
}
