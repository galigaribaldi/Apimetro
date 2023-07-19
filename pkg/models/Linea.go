package models

type Linea struct {
	ID                int     `gorm:"primary_key" json:"linea_id"`
	Nombre            string  `json:"nombre"`
	Sistema           string  `json:"sistema"`
	Anio_inauguracion int     `json:"anio_inauguracion"`
	Color_en          string  `json:"color_en"`
	Color_esp         string  `json:"color_esp"`
	Tam_km            float64 `json:"tam_km"`
	Existe            bool    `json:"existe"`
}
