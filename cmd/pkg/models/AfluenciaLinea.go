package models

// AfluenciaLinea representa un registro de afluencia mensual por línea de transporte.
type AfluenciaLinea struct {
	LineaID      int    `json:"linea_id" gorm:"column:linea_id" example:"191"`
	Sistema      string `json:"sistema" gorm:"column:sistema" example:"METRO"`
	NumComercial string `json:"num_comercial" gorm:"column:num_comercial" example:"1"`
	NombreLinea  string `json:"nombre_linea" gorm:"column:nombre_linea" example:"Metro Línea 1"`
	Anio         int    `json:"anio" gorm:"column:anio" example:"2025"`
	MesNum       int    `json:"mes_num" gorm:"column:mes_num" example:"3"`
	Mes          string `json:"mes" gorm:"column:mes" example:"Marzo"`
	Afluencia    int64  `json:"afluencia" gorm:"column:afluencia" example:"24300000"`
	Fuente       string `json:"fuente" gorm:"column:fuente" example:"DGST"`
}

// AfluenciaLineaResponse es la respuesta del endpoint GET /movilidad/analitico/afluencia-linea.
type AfluenciaLineaResponse struct {
	Total int              `json:"total" example:"150"`
	Data  []AfluenciaLinea `json:"data"`
}
