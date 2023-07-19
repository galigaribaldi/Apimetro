# -*- coding: utf-8 -*-
import psycopg2
import psycopg2.extras as extras
import pandas as pd
from WebR import requestWebLinea
from conf import host, database, user, password, port, keepalive_kwargs
class LineaETL():
    nombreArchivo = "data.xlsx"
    nombreHoja = "Linea"
    ruta = "Data"
    
    def extractIngresos(self):
        archivo = pd.read_excel(self.ruta + "/" + self.nombreArchivo, sheet_name=self.nombreHoja)
        df = archivo.fillna(0)
        return df
    
    def generateList(self, dataframe):
        lista = list(tuple([
            int(dataframe["LINEA_ID"][i]),
            str(dataframe["NOMBRE"][i]),
            str(dataframe["SISTEMA"][i]),
            int(dataframe["ANIO_INAUGURACION"][i]),
            str(dataframe["COLOR_EN"][i]),            
            str(dataframe["COLOR_ESP"][i]),
            float(dataframe["TAM_KM"][i]),
            bool(dataframe["EXISTE"][i])
        ])for i in range(len(dataframe)))
        return lista
    
    def chargeLinea(self, tuples):
        conexion = psycopg2.connect(host=host, database=database, user=user, password=password, port = port,**keepalive_kwargs)
        query = "INSERT INTO lineas(id, sistema, nombre,anio_inauguracion, color_en, color_esp, tam_km, existe) VALUES (%s, %s, %s, %s, %s, %s, %s, %s);"
        cursor = conexion.cursor()
        extras.execute_batch(cursor, query, tuples, page_size=100)
        conexion.commit()
        cursor.close()
        conexion.close()
        
    def chargeLineaWeb(self, tuples):
        for j in tuples:
            requestWebLinea.postLinea(
                lineaId = j[0],
                nombre = j[1],
                sistema = j[2],
                anioInauguracion = j[3],
                colorEn = j[4],
                colorEsp = j[5],
                tamKm= j[6],
                existe=j[7]
            )
        return requestWebLinea.getLinea()