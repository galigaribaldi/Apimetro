package models

type Linea struct {
	ID                uint   `gorm:"primary_key" json:"linea_id"`
	Sistema           string `gorm:"column: sistema" json:"sistema"`
	Anio_inauguracion int    `gorm:"column: anio_inauguracion" json:"anio_inauguracion"`
	Color_en          string `gorm:"column: color_en" json:"color_en"`
	Color_esp         string `gorm:"column: color_esp" json:"color_esp"`
}
