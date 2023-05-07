package models

type Estacion struct {
	ID                 uint   `json: "id" 	gorm: "primary_key"`
	Nombre             string `json: "name"`
	Cve_est            string `json: "cveest"`
	Tipo               string `json: "tipo"`
	Alcaldia_municipio string `json: "alacaldia_municipio"`
	Anio               int16  `json: "anio"`
	Estado_ciudad      string `json: "estado_ciudad"`
	Longitud           string `json: "longitud"`
	Latitud            string `json: "latitud"`
}
