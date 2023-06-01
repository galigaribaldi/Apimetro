# -*- coding: utf-8 -*-
import psycopg2
import psycopg2.extras as extras
import pandas as pd
from WebR import requestWebEstacion
from conf import host, database, user, password, port, keepalive_kwargs

class EstacionETL():
    nombreArchivo = "data.xlsx"
    nombreHoja = "Estacion"
    ruta = "Data"
    
    def extractIngresos(self):
        archivo = pd.read_excel(self.ruta + "/" + self.nombreArchivo, sheet_name=self.nombreHoja)
        df = archivo.fillna(0)
        return df
    
    def generateList(self, dataframe):
        lista = list(tuple([
            str(dataframe["NOMBRE"][i]),
            str(dataframe["CVE_EST"][i]),
            str(dataframe["TIPO"][i]),
            str(dataframe["ALCALDIAS/MUNICIPIO"][i]),
            str(dataframe["ANIO_INAUGURACION"][i]),
            str(dataframe["ESTADO"][i]),
            float(dataframe["LONGITUD"][i]),
            float(dataframe["LATITUD"][i]),
            int(dataframe["LINEA_ID"][i]),
            int(dataframe["NUM_ESTACION"][i]),
            int(dataframe["ESTACION_ID_OFICIAL"][i]),
            str(dataframe["SISTEMA"][i]),            
        ])for i in range(len(dataframe)))
        return lista
    
    def chargeLinea(self, tuples):
        conexion = psycopg2.connect(host=host, database=database, user=user, password=password, port = port,**keepalive_kwargs)
        query = "INSERT INTO estacions(nombre, cve_est, tipo, alcaldia_municipio, anio, estado_ciudad, longitud, latitud, linea_id, num_estacion, estacion_id_oficial, sistema) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s);"
        cursor = conexion.cursor()
        extras.execute_batch(cursor, query, tuples, page_size=1000)
        conexion.commit()
        cursor.close()
        conexion.close()
        
    def chargeLineaWeb(self, tuples):
        for j in tuples:
            requestWebEstacion.postEstacion(
                nombre=j[0],
                anio=j[4],
                ciudad=j[5],
                alacaldiaMunicipio=j[3],
                lineaId=j[8],
                cveEst=j[1],
                tipo=j[2],
                longitud=j[6],
                latitud=j[7],
                num_estacion=j[9],
                estacion_id_oficial=j[10],
                sistema=j[11],
            )
        return requestWebEstacion.getEstacion()