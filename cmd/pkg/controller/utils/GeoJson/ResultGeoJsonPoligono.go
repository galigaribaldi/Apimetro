package geojson

type ResultGeoJsonPoligono struct {
	Nombre  string `gorm:"column:nombre"`
	Entidad string `gorm:"column:entidad"`
	Nivel   string `gorm:"column:nivel"`
	Cvegeo  string `gorm:"column:cvegeo"`
	Mapa    string `gorm:"column:mapa"`
}
