package models

// Properties contiene los atributos de cada estación
type Properties struct {
	EstacionID        int    `json:"estacion_id"`
	Nombre            string `json:"nombre"`
	Tipo              string `json:"tipo"`
	AlcaldiaMunicipio string `json:"alcaldia_municipio"`
	Anio              string `json:"anio"`
	Sistema           string `json:"sistema"`
	Existe            bool   `json:"existe"`
}
