# -*- coding: utf-8 -*-
import time
from DataCharge import DataLinea
from DataCharge import DataRamal
from DataCharge import DataEstacion
from DataCharge import DataHistorico

def main_etl():
    print("==================================================")
    print(" INICIANDO PROCESO ETL - APIMETRO (GTFS STANDARD) ")
    print("==================================================")
    
    try:
        """
        # ----------------------------------------------------
        # 1. CARGA DE LÍNEAS (Solo metadatos, sin geometría)
        # ----------------------------------------------------
        print("\n--- 1. PROCESANDO LÍNEAS ---")
        etl_linea = DataLinea.LineaETL()
        df_lineas = etl_linea.extractMetadata()
        print(f"-> Se leyeron {len(df_lineas)} líneas del Excel.")
        etl_linea.chargeLineaDB(df_lineas)
        
        time.sleep(2) # Pausa breve para asegurar los commits en la BD
        
        # ----------------------------------------------------
        # 2. CARGA DE RAMALES (Metadatos + Geometría LineString)
        # ----------------------------------------------------
        print("\n--- 2. PROCESANDO RAMALES ---")
        etl_ramal = DataRamal.RamalETL()
        df_ramal_meta = etl_ramal.extractMetadata()
        gdf_shapes = etl_ramal.extractShapesGTFS()
        
        gdf_ramal_final = etl_ramal.processAndMerge(df_ramal_meta, gdf_shapes)
        print(f"-> Se procesaron {len(gdf_ramal_final)} ramales con geometría.")
        etl_ramal.chargeRamalGeo(gdf_ramal_final)
        
        time.sleep(2)
        
        # ----------------------------------------------------
        # 3. CARGA DE ESTACIONES (Modelo de Nodos + Geometría Point)
        # ----------------------------------------------------
        print("\n--- 3. PROCESANDO ESTACIONES ---")
        etl_estacion = DataEstacion.EstacionETL()
        df_estacion_meta = etl_estacion.extractMetadata()
        gdf_stops = etl_estacion.extractStopsGTFS()
        
        gdf_estacion_final = etl_estacion.processAndMerge(df_estacion_meta, gdf_stops)
        print(f"-> Se procesaron {len(gdf_estacion_final)} nodos/estaciones con geometría.")
        etl_estacion.chargeEstacionGeo(gdf_estacion_final)
        """
        # ----------------------------------------------------
        # 4. CARGA DE HISTÓRICOS DE OPERACIÓN (Velocidad y Frecuencia)
        # ----------------------------------------------------
        print("\n--- 4. PROCESANDO HISTÓRICOS DE OPERACIÓN ---")
        etl_historico = DataHistorico.HistoricoOperacionETL()
        df_trips, df_stop_times, df_shapes = etl_historico.extractGTFS()
        
        # Aquí se calculan las métricas y se genera el Excel automáticamente
        df_historico_final = etl_historico.processOperation(df_trips, df_stop_times, df_shapes)
        print(f"-> Se calcularon métricas para {len(df_historico_final)} ramales.")
        
        # COMENTAMOS LA INYECCIÓN A LA BASE DE DATOS PARA VALIDACIÓN PREVIA
        etl_historico.chargeHistoricoDB(df_historico_final)
        #print("-> [PAUSA DE VALIDACIÓN] Carga a BD omitida. Revisa el Excel generado.")

        print("\n==================================================")
        print(" ¡PROCESO ETL FINALIZADO (Fase de Validación)! 🥳 ")
        print("==================================================")

    except Exception as e:
        print("\n==================================================")
        print(f"[ERROR CRÍTICO] La ejecución del ETL falló.")
        print(f"Detalle del error: {e}")
        print("==================================================")

if __name__ == "__main__":
    main_etl()