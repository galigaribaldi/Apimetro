# -*- coding: utf-8 -*-
import pandas as pd
from sqlalchemy import create_engine
from conf import host, database, user, password, port

class LineaETL():
    nombreArchivo = "template_apimetro.xlsx" # Apuntando al nuevo archivo con tus datos
    nombreHoja = "Lineas"
    ruta = "Data"
    
    def extractMetadata(self):
        archivo = pd.read_excel(f"{self.ruta}/{self.nombreArchivo}", sheet_name=self.nombreHoja)
        # Llenamos los vacíos con 0 o strings vacíos para evitar errores en la BD
        df = archivo.fillna(0)
        return df
    
    def chargeLineaDB(self, df):
        """Sube los datos descriptivos de la línea usando SQLAlchemy"""
        # Renombramos para coincidir exactamente con la base de datos
        df = df.rename(columns={
            "linea_id": "id",
            "base": "linea_base_ramal",
            "ramal": "ramal_id"
        })
        
        # Aseguramos que todas las columnas estén en minúsculas
        df.columns = [col.lower() for col in df.columns]
        
        # Filtramos solo las columnas de la tabla 'lineas'
        # ¡NUEVO!: Se agregó 'num_comercial' para que pase hacia la base de datos
        columnas_db = ['id', 'route_gtfs', 'nombre', 'num_comercial', 'sistema', 'anio_inauguracion', 
                       'color_en', 'color_esp', 'tam_km', 'existe', 'ramal_id', 'linea_base_ramal']
                       
        columnas_presentes = [col for col in columnas_db if col in df.columns]
        df_final = df[columnas_presentes]
        
        # Conexión a la base de datos
        conexion = f"postgresql://{user}:{password}@{host}:{port}/{database}"
        engine = create_engine(conexion)
        
        print(f"-> Inyectando {len(df_final)} líneas a la tabla 'lineas' en PostgreSQL...")
        # Subimos los datos (usamos 'append' para agregar a la tabla existente)
        df_final.to_sql('lineas', engine, if_exists='append', index=False)
        print("-> Carga de Líneas (Metadatos) exitosa.")