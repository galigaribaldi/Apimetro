# -*- coding: utf-8 -*-
import pandas as pd
import geopandas as gpd
from sqlalchemy import create_engine
from conf import host, database, user, password, port, keepalive_kwargs

class EstacionETL():
    nombreArchivo = "template_apimetro.xlsx"
    nombreHoja = "Estaciones"
    ruta = "Data"
    rutaGTFS = "Data/stops.txt"
    
    def extractMetadata(self):
        """Extrae la información de las estaciones desde el Excel"""
        archivo = pd.read_excel(f"{self.ruta}/{self.nombreArchivo}", sheet_name=self.nombreHoja)
        
        # 1. Llenamos vacíos con 0 antes de cualquier conversión
        df = archivo.fillna(0)
        
        # 2. BLINDAJE: Todo a minúsculas y sin espacios
        df.columns = df.columns.str.lower().str.strip()
        
        # 3. SOLUCIÓN AL ERROR DE SMALLINT:
        # Forzamos a que las columnas de IDs sean enteros puros (int)
        # Esto quita el ".0" que está rompiendo la base de datos
        columnas_numericas = ['estacion_id_oficial', 'estacion_id', 'linea_id', 'ramal_id']
        
        for col in columnas_numericas:
            if col in df.columns:
                # Convertimos a float primero (por si hay NaN) y luego a int
                df[col] = df[col].astype(float).astype(int)

        # 4. Renombres necesarios
        if 'stop_id' in df.columns and 'stop_gtfs' not in df.columns:
            df = df.rename(columns={"stop_id": "stop_gtfs"})
            
        if 'estacion_id' in df.columns:
            df = df.rename(columns={"estacion_id": "id"})
            
        return df
    
    def extractStopsGTFS(self):
        """Lee stops.txt y genera las geometrías de Punto (Points)"""
        print(f"Leyendo {self.rutaGTFS}...")
        df_stops = pd.read_csv(self.rutaGTFS)
        
        # 1. BLINDAJE: Todo a minúsculas
        df_stops.columns = df_stops.columns.str.lower().str.strip()
        
        # 2. En GTFS, la columna siempre viene como 'stop_id'. La cambiamos para el cruce.
        if 'stop_id' in df_stops.columns and 'stop_gtfs' not in df_stops.columns:
            df_stops = df_stops.rename(columns={'stop_id': 'stop_gtfs'})
            
        print("Generando puntos espaciales...")
        # Armamos los mapas de puntos
        gdf_stops = gpd.GeoDataFrame(
            df_stops, 
            geometry=gpd.points_from_xy(df_stops['stop_lon'], df_stops['stop_lat']),
            crs="EPSG:4326"
        )
        
        # Renombramos la columna de geometría a 'geom' por si Geopandas le puso 'geometry'
        if 'geometry' in gdf_stops.columns and 'geom' not in gdf_stops.columns:
            gdf_stops = gdf_stops.rename_geometry('geom')
            
        return gdf_stops
    
    def processAndMerge(self, df_meta, gdf_stops):
        """Une los metadatos del Excel con las geometrías GTFS"""
        print("Cruzando datos del Excel con geometrías GTFS...")
        
        # Forzamos a texto para que calcen perfecto
        df_meta['stop_gtfs'] = df_meta['stop_gtfs'].astype(str)
        gdf_stops['stop_gtfs'] = gdf_stops['stop_gtfs'].astype(str)
        
        # Hacemos el Join
        merged = df_meta.merge(gdf_stops, on='stop_gtfs', how='inner')
        
        gdf_final = gpd.GeoDataFrame(merged, geometry='geom', crs="EPSG:4326")
        return gdf_final
        
    def chargeEstacionGeo(self, gdf):
        """Sube las estaciones directo a PostgreSQL"""
    
        columnas_db = ['nombre', 'stop_gtfs', 'cve_est', 'tipo', 'alcaldia_municipio', 
                       'anio', 'estado_ciudad', 'longitud', 'latitud', 'geom', 
                       'linea_id', 'num_estacion', 'estacion_id_oficial', 'sistema', 'existe']
        
        columnas_presentes = [col for col in columnas_db if col in gdf.columns]
        gdf = gdf[columnas_presentes]
        
        conexion = f"postgresql://{user}:{password}@{host}:{port}/{database}"
        engine = create_engine(conexion)
        
        print(f"Insertando {len(gdf)} estaciones en la base de datos...")
        gdf.to_postgis(name="estacions", con=engine, if_exists="append", index=False)
        print("¡Carga de Estaciones completada con éxito!")