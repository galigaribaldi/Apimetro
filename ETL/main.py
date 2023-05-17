from WebR import requestWebLinea
from WebR import requestWebEstacion
from Data import DataLinea
from Data import DataEstacion

def WebLineaMain():
    print(requestWebLinea.getLinea(idLine=1))
    #print(requestWebLinea.postLinea(lineaId=6, sistema="STC Metro", anioInauguracion=1980, colorEsp="ROJINEGRO", colorEn="ROJINEGRO"))
    #print(requestWebLinea.updateLinea(lineaId=6, sistema="STC Metro", anioInauguracion=1980, colorEsp="AZULNEGRI", colorEn="AZULNEGRI"))
    #print(requestWebLinea.deleteLinea())
def WebEstacionMain():
    #print(requestWebEstacion.getEstacion(nombre="Pantitlán"))
    """
    print(requestWebEstacion.postEstacion(
        nombre="Gomez Farías", 
        anio=1969, 
        ciudad="CDMX", 
        alacaldiaMunicipio="Venustiano Carranza", 
        lineaId=1, 
        cveEst = "STC0103", 
        tipo="Intermedia", 
        longitud = 19.4166353160295, 
        latitud = -99.0900784397441
        ))

    print(requestWebEstacion.updateEstacion(
        estacionId=9,
        nombre="Gomez Farías", 
        anio=1969, 
        ciudad="CDMX", 
        alacaldiaMunicipio="Venustiano Carranza", 
        lineaId=1, 
        cveEst = "STC0105", 
        tipo="Intermedia", 
        longitud = 19.4166353160295, 
        latitud = -99.0900784397441
        ))
    """
    print(requestWebEstacion.deleteEstacion(lineaId=8))
#WebEstacionMain()
DataLinea.Linea()
DataEstacion.estacion()