package models

type Linea struct {
	ID                uint   `json: "id" 			gorm: "primary_key"`
	Sistema           string `json: "sistema"`
	Anio_inauguracion int    `json: "anio_inauguracion"`
	Color_en          string `json: "color_en"`
	Color_esp         string `json: "color_esp"`
	ubicacion         string `json: "numero"`
}
