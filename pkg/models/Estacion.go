package models

type Estacion struct {
	ID                    uint                  `gorm:"primary_key" json:"estacion_id"`
	Nombre                string                `json:"nombre"`
	Cve_est               string                `json:"cve_est"`
	Tipo                  string                `json:"tipo"`
	Alcaldia_municipio    string                `json:"alcaldia_municipio"`
	Anio                  string                `json:"anio"`
	Estado_ciudad         string                `json:"estado_ciudad"`
	Longitud              float64               `json:"longitud"`
	Latitud               float64               `json:"latitud"`
	Linea                 Linea                 `gorm:"foreignKey:LineaID;references:ID" json:"-"`
	LineaID               int16                 `json:"linea_id"`
	Num_estacion          int16                 `json:"num_estacion"`
	Estacion_id_oficial   int16                 `json:"estacion_id_oficial"`
	Sistema               string                `json:"sistema"`
	Existe                bool                  `json:"existe"`
	DescripcionEstacion   []DescripcionEstacion `json:"descripcion_estacion"`
	DescripcionEstacionID int16                 `gorm:"foreignKey:DescripcionEstacionID;references:ID" json:"-"`
}
