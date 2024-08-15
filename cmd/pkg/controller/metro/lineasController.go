package metro

import (
	//"fmt"
	"log"
	con "Apimetro/cmd/pkg/controller"

	models "Apimetro/cmd/pkg/models"
	joins "Apimetro/cmd/pkg/models/JOINS"
)

func init() {
	con.ConnectDataBase()
	con.DB.AutoMigrate()
	con.DB.AutoMigrate(&models.Linea{})
}

/*
------
POST
------
*/
func CreateLinea(linea models.Linea) {
	/*var linea2 models.Linea ={
		models.Linea.ID: 12,

	}*/
	con.DB.Create(&linea)
}

/*
------
GET
------
*/

//Seleccionar todos
func SelectAllLines() []models.Linea {
	var lineas []models.Linea
	con.DB.Preload("Descripcion_linea").Find(&lineas)
	return lineas
}

//Seleccionar por id
func SelectLinesById(id int) models.Linea {
	var linea models.Linea
	if result := con.DB.Preload("Descripcion_linea").First(&linea, id); result.Error != nil {
		return linea
	}
	return linea
}

//Seleccionar por Color (español)
func SelectLineByColor(color string) []models.Linea {
	var newLinea []models.Linea
	if result := con.DB.Preload("Descripcion_linea").Where("color_esp LIKE ?", "%"+color+"%").Find(&newLinea); result.Error != nil {
		return newLinea
	}
	return newLinea
}

//Seleccionar por Color (Ingles)
func SelectLineByColorEng(color string) []models.Linea {
	var newLinea []models.Linea
	if result := con.DB.Preload("Descripcion_linea").Where("color_en LIKE ?", "%"+color+"%").Find(&newLinea); result.Error != nil {
		return newLinea
	}
	return newLinea
}

//Seleccionar atraves de JOINS
func SelectLineabyTerminalOriginal(terminal string) []joins.JoinLineaDescripcion {
	var newLineaDescription []joins.JoinLineaDescripcion
	if result := con.DB.Raw(`
	SELECT 
		lin.ID as Linea_ID, 
		lin.nombre as Nombre,
		lin.sistema as sistema_linea, 
		lin.Anio_inauguracion as Anio_Inauguracion_Linea,
		lin.color_en as Color_En_Linea, 
		lin.color_esp as Color_Esp_Linea,
		lin.tam_km as Tam_Km_Linea,
		lin.existe as Existe_Linea,
		lin.ramal_id as Ramal_Id_Linea,
		lin.linea_base_ramal as Linea_Base_Ramal,
		deslin.terminal_original as Terminal_Original_Descripcion,
		deslin.inicio_original as Inicio_Original_Descripcion,
		deslin.direccion as Direccion_Descripcion,
		deslin.anio_inicio_ampliacion as Anio_Inicio_Ampliacion_Descripcion,
		deslin.anio_fin_ampliacion as Anio_Fin_Ampliacion_Descripcion		
	FROM lineas lin
	JOIN descripcion_lineas deslin
	ON lin.id = deslin.Linea_base
	where terminal_original= ?;
	`, terminal).Find(&newLineaDescription); result.Error != nil {
		log.Println("Registro: ", newLineaDescription)
		return newLineaDescription
	}
	log.Println("Registro: ", newLineaDescription)	
	return newLineaDescription	
}

/*
------
DELETE
------
*/
func DeleteLinea(id int) {
	var linea models.Linea
	if result := con.DB.Delete(&linea, id); result.Error != nil {
		return
	}
}

/*
------
UPDATE
------
*/
func UpdateLinea(linea models.Linea) {
	con.DB.Model(&linea).Updates(models.Linea{
		Sistema:           linea.Sistema,
		Anio_inauguracion: linea.Anio_inauguracion,
		Color_en:          linea.Color_en,
		Color_esp:         linea.Color_esp,
	})
}
