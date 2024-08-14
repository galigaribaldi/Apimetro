import requests
from Variables import Developer, Production
headers = {'Content-Type': 'application/x-www-form-urlencoded'}

def getDescripcionLinea(terminal_original = None, inicio_original = None, tipo_linea = None, anio_inicio_ampliacion=None, anio_fin_ampliacion=None, direccion=None, descripcion=None, linea_base=None):
    print("GET Descripcion Linea")
    data_send = {}
    if terminal_original != None:
        data_send["terminal_original"] = str(terminal_original)

    if inicio_original != None:
        data_send["inicio_original"] = str(inicio_original)
    
    if tipo_linea != None:
        data_send["tipo_linea"] = str(tipo_linea)
    
    if anio_inicio_ampliacion != None:
        data_send["anio_inicio_ampliacion"] = str(anio_inicio_ampliacion)
    
    if anio_fin_ampliacion != None:
        data_send["anio_fin_ampliacion"] = str(anio_fin_ampliacion)
    
    if direccion != None:
        data_send["direccion"] = str(direccion)
    
    if descripcion != None:
        data_send["descripcion"] = str(descripcion)

    if linea_base != None:
        data_send["linea_base"] = str(linea_base)

    if len(data_send) > 0:
        print("Send Response: ", data_send)
        response = requests.request("GET", Developer.HOST + "/stc/descripcion", headers=headers,params = data_send)
    else:
        response = requests.request("GET", Developer.HOST + "/stc/descripcion", headers=headers)
    return response.json()
def postDescripcionLinea(terminal_original = None, inicio_original = None, tipo_linea = None, anio_inicio_ampliacion=None, anio_fin_ampliacion=None, direccion=None, descripcion=None, linea_base=None):
    print("POST descripcion Linea")
    data_POST = {
        "terminal_original":terminal_original, 
        "inicio_original":inicio_original, 
        "tipo_linea":tipo_linea, 
        "anio_inicio_ampliacion":anio_inicio_ampliacion, 
        "anio_fin_ampliacion":anio_fin_ampliacion, 
        "direccion":direccion, 
        "descripcion":descripcion, 
        "linea_base":linea_base
    }
    response = requests.request(
        "POST", 
        Developer.HOST + "/stc/descripcion", 
        headers = headers,
        json = data_POST,
    )
    return response.json()
def updateDescripcionLinea():
    pass

def deleteDescripcionLinea():
    pass