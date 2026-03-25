package geojson

type ResultGeoJsonLinea struct {
	NombreLinea string  `gorm:"column:nombre_linea"`
	Sistema     string  `gorm:"column:sistema"`
	ColorEsp    string  `gorm:"column:color_esp"`
	TamKm       float64 `gorm:"column:tam_km"`
	NombreRamal string  `gorm:"column:nombre_ramal"`
	Mapa        string  `gorm:"column:mapa"`
}
