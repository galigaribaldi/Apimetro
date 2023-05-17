import requests

headers = {'Content-Type': 'application/x-www-form-urlencoded'}

def getEstacion(nombre=None, anio=None, anio_antes=None, anio_despues=None, ciudad=None, alacaldiaMunicipio=None, lineaId=None, colorEsp=None, colorEn=None):
    print("GET")
    data_send = {}
    if nombre!=None:
        data_send["nombre"] = str(nombre)
    if anio!=None:
        data_send["anio"] = str(anio)
    if anio_antes!=None:
        data_send["anio_antes"] = str(anio_antes)
    if anio_despues!=None:
        data_send["anio_despues"] = str(anio_despues)
    if ciudad!=None:
        data_send["ciudad"] = str(ciudad)
    if alacaldiaMunicipio!=None:
        data_send["alacaldiaMunicipio"] = str(alacaldiaMunicipio)
    if lineaId!=None:
        data_send["lineaId"] = str(lineaId)
    if colorEsp!=None:
        data_send["colorEsp"] = str(colorEsp)
    if colorEn!=None:
        data_send["colorEn"] = str(colorEn)
        
    if len(data_send) > 0:
        print("Send Response: ", data_send)
        response = requests.request("GET", "http://localhost:5001/stc/estacion", headers=headers,params = data_send)
    else:
        response = requests.request("GET", "http://localhost:5001/stc/estacion", headers=headers)
    return response.json()
    
def postEstacion(nombre=None, anio=None, ciudad=None, alacaldiaMunicipio=None, lineaId=None, cveEst = None, tipo=None, longitud = None, latitud = None):
    print("POST")
    data_POST = {
        "nombre": nombre,
        "cve_est": cveEst,
        "tipo": tipo,
        "alacaldia_municipio":alacaldiaMunicipio,
        "anio": str(anio),
        "estado_ciudad": ciudad,
        "longitud": longitud,
        "latitud": latitud,
        "linea_id":lineaId
    }
    if nombre==None and anio==None and ciudad==None and alacaldiaMunicipio==None and lineaId==None and cveEst == None and tipo==None and longitud == None and latitud == None:
        return None
    print(data_POST)
    response = requests.request(
        "POST", 
        "http://localhost:5001/stc/estacion", 
        headers = headers,
        json = data_POST,
    )
    return response.json()

def updateEstacion(estacionId=None,nombre=None, anio=None, ciudad=None, alacaldiaMunicipio=None, lineaId=None, cveEst = None, tipo=None, longitud = None, latitud = None):
    print("PATCH")
    data_POST = {
        "estacion_id": estacionId,
        "nombre": nombre,
        "cve_est": cveEst,
        "tipo": tipo,
        "alacaldia_municipio":alacaldiaMunicipio,
        "anio": str(anio),
        "estado_ciudad": ciudad,
        "longitud": longitud,
        "latitud": latitud,
        "linea_id":lineaId
    }
    if estacionId==None and nombre==None and anio==None and ciudad==None and alacaldiaMunicipio==None and lineaId==None and cveEst == None and tipo==None and longitud == None and latitud == None:
        return None
    print(data_POST)
    response = requests.request(
        "PATCH", 
        "http://localhost:5001/stc/estacion", 
        headers = headers,
        json = data_POST,
    )
    return response.json()

def deleteEstacion(lineaId=None):
    print("Delete")
    if lineaId== None:
        return None
    response = requests.request(
        "DELETE", 
        "http://localhost:5001/stc/estacion", 
        headers = headers,
        params = {"id":lineaId},
    )
    return response.json()