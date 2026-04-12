package models

type DescripcionEstacion struct {
	ID                 uint     `gorm:"primary_key" json:"descripcion_estacion_id" example:"1"`
	Nombre             string   `json:"nombre" example:"Tacubaya"`
	Cve_est            string   `json:"cve_est" example:"TAC"`
	Tipo               string   `json:"tipo" example:"Terminal"`
	Alcaldia_municipio string   `json:"alcaldia_municipio" example:"Miguel Hidalgo"`
	Anio               string   `json:"anio" example:"1970"`
	Estado_ciudad      string   `json:"estado_ciudad" example:"Ciudad de México"`
	Longitud           float64  `json:"longitud" example:"-99.188"`
	Estacion           Estacion `gorm:"foreignKey:EstacionID;references:ID" json:"-"`
	EstacionID         uint     `json:"estacion_id" example:"1"`
}
