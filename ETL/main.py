# -*- coding: utf-8 -*-
import time
from DataCharge import DataLinea
from DataCharge import DataRamal
from DataCharge import DataEstacion
from DataCharge import DataHistorico
from DataCharge import LoadAgebs
from DataCharge import LoadPlutarcoGeo
from DataCharge import LoadAfluencia

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
        # [COMPLETADO — comentado para evitar reinserción]
        # ----------------------------------------------------
        # print("\n--- 4. PROCESANDO HISTÓRICOS DE OPERACIÓN ---")
        # etl_historico = DataHistorico.HistoricoOperacionETL()
        # df_trips, df_stop_times, df_shapes = etl_historico.extractGTFS()
        # df_historico_final = etl_historico.processOperation(df_trips, df_stop_times, df_shapes)
        # print(f"-> Se calcularon métricas para {len(df_historico_final)} ramales.")
        # etl_historico.chargeHistoricoDB(df_historico_final)

        # ----------------------------------------------------
        # 5. CARGA DE AGEBs URBANAS + CENSO 2020 → plutarco.agebs
        # Scope: 6 estados macrometrópoli (09, 15, 17, 21, 22, 29)
        # [COMPLETADO — comentado para evitar reinserción]
        # Idempotente si se descomenta: ON CONFLICT (cve_ageb) DO NOTHING
        # ----------------------------------------------------
        # print("\n--- 5. PROCESANDO AGEBs URBANAS (PLUTARCO) ---")
        # etl_agebs = LoadAgebs.AgebsETL()
        # etl_agebs.run()

        # ----------------------------------------------------
        # 6. CARGA CAPAS GEO PLUTARCO (calles, uso_suelo, curvas_nivel)
        # Fuentes: lineas_ejes_de_vialidad.shp + MedioFisicoNatural.gpkg
        # [COMPLETADO — comentado para evitar re-ejecución]
        # Re-ejecutable (TRUNCATE + INSERT). Descomenta si necesitas recargar.
        # ----------------------------------------------------
        # print("\n--- 6. PROCESANDO CAPAS GEOGRÁFICAS PLUTARCO ---")
        # etl_geo = LoadPlutarcoGeo.PlutarcoGeoETL()
        # etl_geo.run()

        # ----------------------------------------------------
        # 7. CARGA DE AFLUENCIA POR LÍNEA → plutarco.afluencia_linea
        # Fuentes: Data/Pesos/ (Excel histórico + CSVs complementarios)
        # Prerequisitos: v2.0_afluencia.sql + seed_catalogo_homologacion.sql
        # [PENDIENTE — descomentar cuando tablas y catálogo estén cargados]
        # Idempotente: ON CONFLICT (linea_id, anio, mes_num) DO NOTHING
        # ----------------------------------------------------
        # print("\n--- 7. PROCESANDO AFLUENCIA POR LÍNEA (PLUTARCO) ---")
        # etl_afluencia = LoadAfluencia.AfluenciaETL()
        # etl_afluencia.run()

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