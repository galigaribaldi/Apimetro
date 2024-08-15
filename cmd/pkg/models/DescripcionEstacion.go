package models

type DescripcionEstacion struct {
	ID                 uint     `gorm:"primary_key" json:"descripcion_estacion_id"`
	Nombre             string   `json:"nombre"`
	Cve_est            string   `json:"cve_est"`
	Tipo               string   `json:"tipo"`
	Alcaldia_municipio string   `json:"alcaldia_municipio"`
	Anio               string   `json:"anio"`
	Estado_ciudad      string   `json:"estado_ciudad"`
	Longitud           float64  `json:"longitud"`
	Estacion           Estacion `gorm:"foreignKey:EstacionID;references:ID" json:"-"`
	EstacionID         int16    `json:"estacion_id"`
}
