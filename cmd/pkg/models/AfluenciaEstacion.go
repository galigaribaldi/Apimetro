package models

// AfluenciaEstacion representa un registro de afluencia mensual por estación del Metro.
type AfluenciaEstacion struct {
	EstacionID     int    `json:"estacion_id" gorm:"column:estacion_id" example:"12001"`
	NombreEstacion string `json:"nombre_estacion" gorm:"column:nombre_estacion" example:"Pantitlán"`
	LineaID        int    `json:"linea_id" gorm:"column:linea_id" example:"191"`
	NumComercial   string `json:"num_comercial" gorm:"column:num_comercial" example:"L1"`
	NombreLinea    string `json:"nombre_linea" gorm:"column:nombre_linea" example:"Metro Línea 1"`
	Anio           int    `json:"anio" gorm:"column:anio" example:"2024"`
	MesNum         int    `json:"mes_num" gorm:"column:mes_num" example:"3"`
	Mes            string `json:"mes" gorm:"column:mes" example:"Marzo"`
	Afluencia      int64  `json:"afluencia" gorm:"column:afluencia" example:"1850000"`
	Fuente         string `json:"fuente" gorm:"column:fuente" example:"STC-Metro-DatosAbiertos"`
}

// AfluenciaEstacionResponse es la respuesta del endpoint GET /movilidad/analitico/afluencia-estacion.
type AfluenciaEstacionResponse struct {
	Total int                 `json:"total" example:"500"`
	Data  []AfluenciaEstacion `json:"data"`
}
