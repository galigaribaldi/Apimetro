# -*- coding: utf-8 -*-
import psycopg2
import psycopg2.extras as extras
import pandas as pd
from WebR import requestWebDescripcionLinea
from conf import host, database, user, password, port, keepalive_kwargs

class DescripcionLineaETL():
    nombreArchivo = "data.xlsx"
    nombreHoja = "Descripcion_linea"
    ruta = "Data"
    
    def extractDescripcionLinea(self):
        archivo = pd.read_excel(self.ruta + "/" + self.nombreArchivo, sheet_name=self.nombreHoja)
        df = archivo.fillna(0)
        return df
    
    def generateListDescripcionLinea(self, dataframe):
        lista = list(tuple([
            str(dataframe["TERMINAL_ORIGINAL"][i]),
            str(dataframe["INICIO_ORIGINAL"][i]),
            str(dataframe["TIPO_LINEA"][i]),
            int(dataframe["ANIO_INICIO_AMPLIACION"][i]),            
            int(dataframe["ANIO_FIN_AMPLIACION"][i]),
            str(dataframe["DIRECCION"][i]),
            str(dataframe["DESCRIPCION"][i]),
            int((dataframe["LINEA_BASE"][i]))
        ])for i in range(len(dataframe)))
        return lista
    
    def chargeDescripcionLinea(self, tuples):
        conexion = psycopg2.connect(host=host, database=database, user=user, password=password, port = port,**keepalive_kwargs)
        query = "INSERT INTO descripcion_lineas(terminal_original, inicio_original, tipo, direccion, descripcion, anio_inicio_ampliacion, anio_fin_ampliacion, linea_base) VALUES (%s, %s, %s ,%s, %s, %s, %s, %s, %s, %s, %s, %s);"
        cursor = conexion.cursor()
        extras.execute_batch(cursor, query, tuples, page_size=100)
        conexion.commit()
        cursor.close()
        conexion.close()
        
    def chargeDescripcionLineaWeb(self, tuples):
        for j in tuples:
            requestWebDescripcionLinea.postDescripcionLinea(
                terminal_original = j[0],
                inicio_original = j[1],
                tipo_linea = j[2],
                anio_inicio_ampliacion = j[3],
                anio_fin_ampliacion = j[4],
                direccion = j[5],
                descripcion = j[6],
                linea_base=j[7]
            )
        return requestWebDescripcionLinea.postDescripcionLinea()