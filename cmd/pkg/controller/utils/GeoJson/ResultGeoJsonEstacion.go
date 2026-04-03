package geojson

type ResultGeoJsonEstacion struct {
	Nombre              string  `gorm:"column:nombre"`
	Sistema             string  `gorm:"column:sistema"`
	NumComercial        string  `gorm:"column:num_comercial"`
	Tipo                string  `gorm:"column:tipo"`
	AlcaldiaMunicipio   string  `gorm:"column:alcaldia_municipio"`
	Mapa                string  `gorm:"column:mapa"`
	JerarquiaTransporte *string `gorm:"column:jerarquia_transporte"`
	EsCetram            bool
	NombreCetram        *string
}
