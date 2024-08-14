package models

type JoinLineaDescripcion struct {
	Linea_ID								int		`json:"linea_id"`
	Nombre									string	`json:"nombre_linea"`
	Sistema_Linea							string	`json:"nombre_sistema_linea"`
	Anio_Inauguracion_Linea					int		`json:"anio_inauguracion_linea"`
	Color_En_Linea							string	`json:"color_eng_linea"`
	Color_Esp_Linea							string	`json:"color_esp_linea"`
	Tam_Km_Linea							float64 `json:"tam_km_linea"`
	Existe_Linea							bool	`json:"existe_linea"`
	Ramal_Id_Linea							int		`json:"ramal_id_linea"`
	Linea_Base_Ramal						int		`json:"linea_base_ramal"`
	Terminal_Original_Descripcion			string	`json:"terminal_original_descripcion"`
	Inicio_Original_Descripcion				string	`json:"inicio_original_descripcion"`
	Direccion_Descripcion					string	`json:"direccion_descripcion"`
	Anio_Inicio_Ampliacion_Descripcion		int		`json:"anio_inicio_ampliacion_descripcion"`
	Anio_Fin_Ampliacion_Descripcion			int		`json:"anio_fin_ampliacion_descripcion"`
}