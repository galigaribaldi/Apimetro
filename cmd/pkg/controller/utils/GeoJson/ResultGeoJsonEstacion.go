package geojson

type ResultGeoJsonEstacion struct {
	Nombre            string `gorm:"column:nombre"`
	Sistema           string `gorm:"column:sistema"`
	Tipo              string `gorm:"column:tipo"`
	AlcaldiaMunicipio string `gorm:"column:alcaldia_municipio"`
	Mapa              string `gorm:"column:mapa"`
}
