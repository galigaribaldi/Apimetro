package metro
import (
	con "Apimetro/cmd/pkg/controller"

	models "Apimetro/cmd/pkg/models"
)

func init() {
	con.ConnectDataBase()
	con.DB.AutoMigrate()
	con.DB.AutoMigrate(&models.DescripcionLinea{})
}

/*
-------
POST
-------
*/

func CreateDescripcionLinea(descripcionLinea models.DescripcionLinea){
	con.DB.Create(&descripcionLinea)
}

/*
-------
GET
-------
*/
func SelectAllDescription() [] models.DescripcionLinea{
	var descripcionLineas []models.DescripcionLinea
	con.DB.Find(&descripcionLineas)
	return descripcionLineas
}

func SelectDescripcionById(id int) models.DescripcionLinea{
	var Descripcionlinea models.DescripcionLinea
	if result := con.DB.First(&Descripcionlinea, id); result.Error != nil {
		return Descripcionlinea
	}
	return Descripcionlinea	
}

func SelectTerminalOriginal(terminal string) []models.DescripcionLinea{
	var newDescripcionLinea []models.DescripcionLinea
	if result := con.DB.Where("terminal_original LIKE ?", "%"+terminal+"%").Find(&newDescripcionLinea); result.Error != nil{
		return newDescripcionLinea
	}
	return newDescripcionLinea
}

func SelectLineaBase(lineaBase string) []models.DescripcionLinea {
	var newDescripcionLinea [] models.DescripcionLinea
	if result := con.DB.Where("linea_base = ?", lineaBase).Find(&newDescripcionLinea); result.Error != nil{
		return newDescripcionLinea
	}
	return newDescripcionLinea
}

/*
-------
DELETE
-------
*/

/*
-------
UPDATE
-------
*/