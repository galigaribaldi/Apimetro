package models

type Linea struct {
	ID                uint   `gorm:"primary_key" json:"linea_id"`
	Sistema           string `json:"sistema"`
	Anio_inauguracion int    `json:"anio_inauguracion"`
	Color_en          string `json:"color_en"`
	Color_esp         string `json:"color_esp"`
}
