# -*- coding: utf-8 -*-
import psycopg2
import pandas as pd
import geopandas as gpd
from shapely.geometry import LineString, MultiLineString
from sqlalchemy import create_engine
from conf import host, database, user, password, port

class RamalETL():
    nombreArchivo = "template_apimetro.xlsx" 
    nombreHoja = "Ramales" 
    ruta = "Data"                  # <--- Tu Excel está en Data/
    rutaGTFS = "Data/shapes.txt"
    
    def extractMetadata(self):
        """Extrae la información descriptiva de los ramales desde el NUEVO Excel"""
        archivo = pd.read_excel(f"{self.ruta}/{self.nombreArchivo}", sheet_name=self.nombreHoja)
        df = archivo.fillna(0)
        
        # --- LA MAGIA PARA EVITAR ERRORES DE PANDAS ---
        # 1. Pasamos todas las columnas a minúsculas
        df.columns = [col.lower() for col in df.columns]
        
        # 2. Renombramos ramal_id a id para que PostgreSQL lo acepte
        if 'ramal_id' in df.columns:
            df = df.rename(columns={"ramal_id": "id"})
            
        return df
    
    def extractShapesGTFS(self):
        """Lee el GTFS, agrupa los puntos y genera geometrías (LineStrings)"""
        print(f"Leyendo {self.rutaGTFS}...")
        df_shapes = pd.read_csv(self.rutaGTFS)
        df_shapes = df_shapes.sort_values(['shape_id', 'shape_pt_sequence'])
        
        print("Generando trazos espaciales...")
        shapes_geom = df_shapes.groupby('shape_id').apply(
            lambda x: MultiLineString([LineString(list(zip(x['shape_pt_lon'], x['shape_pt_lat'])))]) 
            if len(x) > 1 else None
        ).reset_index()
        shapes_geom.columns = ['shape_gtfs', 'geom']
        
        gdf_shapes = gpd.GeoDataFrame(shapes_geom, geometry='geom', crs="EPSG:4326")
        gdf_shapes = gdf_shapes.dropna(subset=['geom'])
        return gdf_shapes
    
    def processAndMerge(self, df_meta, gdf_shapes):
        """Une los metadatos del Excel con las geometrías del GTFS"""
        print("Cruzando datos del Excel con geometrías GTFS...")
        # Como ya forzamos a minúsculas en extractMetadata, esto ya no fallará
        df_meta['shape_gtfs'] = df_meta['shape_gtfs'].astype(str)
        gdf_shapes['shape_gtfs'] = gdf_shapes['shape_gtfs'].astype(str)
        
        merged = df_meta.merge(gdf_shapes, on='shape_gtfs', how='inner')
        gdf_final = gpd.GeoDataFrame(merged, geometry='geom', crs="EPSG:4326")
        return gdf_final
    
    def chargeRamalGeo(self, gdf):
        """Sube todo directamente a PostgreSQL"""
        columnas_db = ['id', 'linea_id', 'shape_gtfs', 'nombre_ramal', 'tam_km', 'geom', 'anio_creacion', 'ramal_num', 'estado']
        columnas_presentes = [col for col in columnas_db if col in gdf.columns]
        gdf = gdf[columnas_presentes]
        
        conexion = f"postgresql://{user}:{password}@{host}:{port}/{database}"
        engine = create_engine(conexion)
        
        print(f"-> Inyectando {len(gdf)} ramales con geometría a PostgreSQL...")
        # NOTA: Cambiado a 'ramals' para solucionar el problema con GORM
        gdf.to_postgis('ramals', engine, if_exists='append', index=False)
        print("-> Carga de Ramales exitosa.")