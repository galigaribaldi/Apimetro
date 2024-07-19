import requests
from Variables import Production, Developer
import time
headers = {'Content-Type': 'application/x-www-form-urlencoded'}

def getLinea(idLine=None, colorEsp=None):
    data_send = {}
    if idLine!=None:
        data_send["idLine"] = str(idLine)
    if colorEsp!=None:
        data_send["color_esp"] = str(colorEsp)
    if len(data_send) > 0:
        print("Send Response: ", data_send)
        response = requests.request("GET", Production.HOST + "/stc/linea", headers=headers,params = data_send)
    else:
        response = requests.request("GET", Production.HOST + "/stc/linea", headers=headers)
    return response.json()
    
def postLinea(lineaId=None, nombre = None,sistema=None, anioInauguracion=None, colorEn=None, colorEsp=None, tamKm =None, existe=None, ramal_id=None, linea_base=None):
    data_POST = {    
        "linea_id": lineaId,
        "nombre": nombre,
        "sistema": sistema,
        "anio_inauguracion": anioInauguracion,
        "color_en": colorEn,
        "color_esp": colorEsp,
        "tam_km": tamKm,
        "existe":existe,
        "ramal_id":ramal_id,
        "linea_base_ramal":linea_base
        }
    print(data_POST)
    #time.sleep(5)
    if lineaId== None and sistema == None and anioInauguracion == None and colorEn == None and colorEsp == None:
        data_POST = None
        return None
    response = requests.request(
        "POST", 
        Production.HOST + "/stc/linea", 
        headers = headers,
        json = data_POST,
    )
    return response.json()

def updateLinea(lineaId=None, nombre = None,sistema=None, anioInauguracion=None, colorEn=None, colorEsp=None, tamKm =None, existe=None, ramal_id=None, linea_base=None):
    data_POST = {    
        "linea_id": lineaId,
        "nombre": nombre,
        "sistema": sistema,
        "anio_inauguracion": anioInauguracion,
        "color_en": colorEn,
        "color_esp": colorEsp,
        "tam_km": tamKm,
        "existe":existe,
        "ramal_id":ramal_id,
        "linea_base_ramal":linea_base
        }
    if lineaId== None and sistema == None and anioInauguracion == None and colorEn == None and colorEsp == None:
        data_POST = None
        return None
    response = requests.request(
        "PATCH", 
        Production.HOST + "/stc/linea", 
        headers = headers,
        json = data_POST,
    )
    return response.json()

def deleteLinea(lineaId=None):
    if lineaId== None:
        return None
    response = requests.request(
        "DELETE", 
        Production.HOST + "/stc/linea", 
        headers = headers,
        params = {"id":lineaId},
    )
    return response.json()