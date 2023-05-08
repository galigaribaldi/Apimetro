package models

type Linea struct {
	ID                uint   `json: "linea_id" 					gorm: "primary_key"`
	Sistema           string `json: "sistema"				gorm: "column: sistema"`
	Anio_inauguracion int    `json: "anio_inauguracion"		gorm: "column: anio_inauguracion"`
	Color_en          string `json: "color_en"				gorm: "column: color_en"`
	Color_esp         string `json: "color_esp"				gorm: "column: color_esp"`
	Ubicacion         string `json: "ubicacion"				gorm: "column: ubicacion"`
}
