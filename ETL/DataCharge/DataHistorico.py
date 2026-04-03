# -*- coding: utf-8 -*-
"""
@author: Galileo Garibaldi
@date: 2026-03-25
@description: Clase ETL encargada de extraer, transformar y cargar datos operativos (velocidad promedio y frecuencia) desde archivos GTFS hacia la base de datos PostgreSQL.
@route: DataCharge/DataHistorico.py
@notes: Calcula programáticamente las velocidades y frecuencias resolviendo el edge case de los tiempos GTFS mayores a 24h. Cruza la geometría (shapes.txt) con los tiempos de parada (stop_times.txt). Genera un Excel de validación previa.
"""

import pandas as pd
import numpy as np
from sqlalchemy import create_engine, text
from conf import host, database, user, password, port

class HistoricoOperacionETL():
    rutaGTFS_trips = "Data/trips.txt"
    rutaGTFS_stop_times = "Data/stop_times.txt"
    rutaGTFS_shapes = "Data/shapes.txt"
    
    @staticmethod
    def parse_gtfs_time(time_str):
        if pd.isna(time_str): return np.nan
        h, m, s = map(int, str(time_str).split(':'))
        return h * 3600 + m * 60 + s

    @staticmethod
    def haversine(lat1, lon1, lat2, lon2):
        R = 6371.0 # Radio de la Tierra en km
        lat1, lon1, lat2, lon2 = map(np.radians, [lat1, lon1, lat2, lon2])
        dlat = lat2 - lat1
        dlon = lon2 - lon1
        a = np.sin(dlat/2)**2 + np.cos(lat1) * np.cos(lat2) * np.sin(dlon/2)**2
        c = 2 * np.arcsin(np.sqrt(a))
        return R * c

    def generar_excel_validacion(self, df, filename="Validacion_Operativa.xlsx"):
        """Genera un reporte en Excel con métricas y tablas para revisar antes del INSERT"""
        print(f"\n[EXCEL] Generando archivo de validación en '{filename}'...")
        
        with pd.ExcelWriter(filename, engine='xlsxwriter') as writer:
            # Pestaña 1: Resumen Estadístico
            desc = df[['velocidad_kmh', 'frecuencia_minutos']].describe().round(2)
            desc.to_excel(writer, sheet_name='Resumen_Estadistico')
            
            # Pestaña 2: Todos los datos calculados
            df.to_excel(writer, sheet_name='Datos_Calculados', index=False)
            
        print("[EXCEL] ¡Archivo generado con éxito! Revísalo en tu carpeta raíz.\n")

    def extractGTFS(self):
        print("Leyendo archivos GTFS para operación...")
        trips = pd.read_csv(self.rutaGTFS_trips, usecols=['route_id', 'trip_id', 'shape_id'])
        stop_times = pd.read_csv(self.rutaGTFS_stop_times, usecols=['trip_id', 'arrival_time', 'departure_time', 'stop_sequence'])
        shapes = pd.read_csv(self.rutaGTFS_shapes, usecols=['shape_id', 'shape_pt_lat', 'shape_pt_lon', 'shape_pt_sequence'])
        return trips, stop_times, shapes

    def processOperation(self, trips, stop_times, shapes):
        print("Calculando frecuencias y velocidades promedio...")
        
        trips_stops = pd.merge(stop_times, trips, on='trip_id')
        
        # --- CÁLCULO DE FRECUENCIAS (CORREGIDO) ---
        first_stops = trips_stops[trips_stops['stop_sequence'] == 1].copy()
        first_stops['start_sec'] = first_stops['departure_time'].apply(self.parse_gtfs_time)
        
        frecuencias = first_stops.groupby('shape_id').agg(
            primer_despacho=('start_sec', 'min'),
            ultimo_despacho=('start_sec', 'max'),
            total_viajes=('start_sec', 'count')
        ).reset_index()
        
        # Condición estricta: total_viajes > 1 Y tiempo_ultimo > tiempo_primero
        frecuencias['frecuencia_minutos'] = np.where(
            (frecuencias['total_viajes'] > 1) & (frecuencias['ultimo_despacho'] > frecuencias['primer_despacho']),
            ((frecuencias['ultimo_despacho'] - frecuencias['primer_despacho']) / 60.0) / (frecuencias['total_viajes'] - 1),
            np.nan 
        )
        frecuencias = frecuencias[['shape_id', 'frecuencia_minutos']]
        # --- CÁLCULO DE VELOCIDADES ---
        trips_stops['time_sec'] = trips_stops['arrival_time'].apply(self.parse_gtfs_time)
        tiempos_viaje = trips_stops.groupby('trip_id')['time_sec'].agg(['min', 'max']).reset_index()
        tiempos_viaje['duracion_horas'] = (tiempos_viaje['max'] - tiempos_viaje['min']) / 3600.0

        shapes = shapes.sort_values(by=['shape_id', 'shape_pt_sequence'])
        shapes['lat_shift'] = shapes.groupby('shape_id')['shape_pt_lat'].shift(1)
        shapes['lon_shift'] = shapes.groupby('shape_id')['shape_pt_lon'].shift(1)
        shapes['dist_km'] = self.haversine(shapes['shape_pt_lat'], shapes['shape_pt_lon'], shapes['lat_shift'], shapes['lon_shift'])
        distancias = shapes.groupby('shape_id')['dist_km'].sum().reset_index()

        viajes_completos = pd.merge(tiempos_viaje, trips[['trip_id', 'shape_id']], on='trip_id')
        viajes_completos = pd.merge(viajes_completos, distancias, on='shape_id')
        viajes_completos = viajes_completos[viajes_completos['duracion_horas'] > 0]
        viajes_completos['velocidad_kmh'] = viajes_completos['dist_km'] / viajes_completos['duracion_horas']

        velocidades = viajes_completos.groupby('shape_id')['velocidad_kmh'].mean().reset_index()

        # --- CONSOLIDACIÓN E INYECCIÓN DE FUENTE ---
        resultados_etl = pd.merge(velocidades, frecuencias, on='shape_id', how='outer')
        resultados_etl['velocidad_kmh'] = resultados_etl['velocidad_kmh'].round(2)
        resultados_etl['frecuencia_minutos'] = resultados_etl['frecuencia_minutos'].round(2)
        resultados_etl['fuente'] = "https://datos.cdmx.gob.mx/dataset/gtfs"
        
        # --- GENERAR EXCEL ANTES DE RETORNAR ---
        self.generar_excel_validacion(resultados_etl)
        
        return resultados_etl

    def chargeHistoricoDB(self, df):
        conexion = f"postgresql://{user}:{password}@{host}:{port}/{database}"
        engine = create_engine(conexion)
        
        print(f"-> Inyectando métricas de operación a PostgreSQL ({len(df)} registros)...")
        
        with engine.begin() as conn:
            df.to_sql('temp_gtfs_etl', conn, if_exists='replace', index=False)
            
            sql_insert = text("""
            INSERT INTO historico_operacion (ramal_id, velocidad_promedio_kmh, frecuencia_minutos, fuente, fecha_registro)
            SELECT 
                r.id AS ramal_id,
                t.velocidad_kmh,
                t.frecuencia_minutos,
                t.fuente,
                CURRENT_DATE
            FROM temp_gtfs_etl t
            INNER JOIN ramals r ON t.shape_id = r.shape_gtfs
            ON CONFLICT (ramal_id) DO UPDATE 
            SET 
                velocidad_promedio_kmh = EXCLUDED.velocidad_promedio_kmh,
                frecuencia_minutos = EXCLUDED.frecuencia_minutos,
                fuente = EXCLUDED.fuente,
                fecha_registro = CURRENT_DATE;
            """)
            conn.execute(sql_insert)
            conn.execute(text("DROP TABLE temp_gtfs_etl;"))