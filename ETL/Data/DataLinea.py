# -*- coding: utf-8 -*-
import psycopg2
import psycopg2.extras as extras
import pandas as pd
import geopandas as gpd
from shapely import wkt
from shapely.geometry import MultiLineString
from sqlalchemy import create_engine
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
            bool(dataframe["EXISTE"][i]),
            int((dataframe["RAMAL"][i])),
            int((dataframe["BASE"][i]))
        ])for i in range(len(dataframe)))
        return lista
    
    def extractWithGeopandas(self, dataframeOrigin):
        def safe_load_wkt(geom_text):
            if geom_text.strip().upper() == "MULTILINESTRING EMPTY":
                return MultiLineString()
            return wkt.loads(geom_text)
        # Convierte columna WKT a objeto geométrico y nómbrala 'geom'
        dataframeOrigin["geom"] = dataframeOrigin["geom"].apply(safe_load_wkt)
        # Corrige los tipos de columnas numéricas
        columnas_enteros = ["id", "anio_inauguracion", "ramal_id", "linea_base_ramal"]
        for col in columnas_enteros:
            dataframeOrigin[col] = dataframeOrigin[col].fillna(0).astype(int)
        dataframeOrigin["existe"] = dataframeOrigin["existe"].astype(bool)
 
        # Crea el GeoDataFrame y define el CRS
        gdf = gpd.GeoDataFrame(dataframeOrigin, geometry="geom", crs="EPSG:4326")
        return gdf
    
    def chargeLineaGeo(self, gdf):
         # Cambia el nombre de la columna geometry → geom
        #gdf = gdf.rename(columns={"geometry": "geom"})
        #gdf.set_geometry("geom", inplace=True)
        ###
        conexion = f"postgresql://{user}:{password}@{host}:{port}/{database}"
        engine = create_engine(conexion)
        gdf.to_postgis(name="lineas", con=engine, if_exists="append", index=False)
        
    
    def chargeLinea(self, tuples):
        conexion = psycopg2.connect(host=host, database=database, user=user, password=password, port = port,**keepalive_kwargs)
        query = "INSERT INTO lineas(id, sistema, nombre,anio_inauguracion, color_en, color_esp, tam_km, existe, ramal_id, linea_base) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s);"
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
                existe=j[7],
                ramal_id=j[8],
                linea_base=j[9]
            )
        return requestWebLinea.getLinea()