package models

// Estacion represents a transportation station in the STC system
type Estacion struct {
	ID                  uint    `gorm:"primary_key" json:"estacion_id" example:"1"`
	Nombre              string  `json:"nombre" example:"Tacubaya"`
	Cve_est             string  `json:"cve_est" example:"TAC"`
	Tipo                string  `json:"tipo" example:"Terminal"`
	Alcaldia_municipio  string  `json:"alcaldia_municipio" example:"Miguel Hidalgo"`
	Anio                string  `json:"anio" example:"1980"`
	Estado_ciudad       string  `json:"estado_ciudad" example:"Ciudad de México"`
	Longitud            float64 `json:"longitud" example:"-99.188"`
	Latitud             float64 `json:"latitud" example:"19.403"`
	Linea               Linea   `gorm:"foreignKey:LineaID;references:ID" json:"-"`
	LineaID             int16   `json:"linea_id" example:"1"`
	Num_estacion        int16   `json:"num_estacion" example:"1"`
	Estacion_id_oficial int16   `json:"estacion_id_oficial" example:"1001"`
	Sistema             string  `json:"sistema" example:"METRO"`
	Existe              bool    `json:"existe" example:"true"`
	StopGTFS            string  `json:"stop_gtfs" example:"STC_001"`
	EsCetram            bool    `json:"es_cetram" example:"false"`
	NombreCetram        *string `json:"nombre_cetram,omitempty" example:"Tacubaya CETRAM"`
}

//DescripcionEstacion   []DescripcionEstacion `json:"descripcion_estacion"`
//DescripcionEstacionID int16                 `gorm:"foreignKey:DescripcionEstacionID;references:ID" json:"-"`
