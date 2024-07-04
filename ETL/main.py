import time
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
    print(requestWebEstacion.deleteEstacion(lineaId=8))
#WebEstacionMain()

if __name__ == '__main__':
    ##Linea
    c = DataLinea.LineaETL()
    #print(c.extractIngresos())
    tuples = c.generateList(c.extractIngresos())
    print(c.chargeLineaWeb(tuples))
    time.sleep(5)    
    
    ##Estaciones
    c = DataEstacion.EstacionETL()
    #print(c.extractIngresos())
    #time.sleep(5)
    tuples = c.generateList(c.extractIngresos())
    print(tuples[0:1])
    #print(len(tuples))
    print(c.chargeLineaWeb(tuples))    

