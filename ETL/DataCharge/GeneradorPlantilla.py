# -*- coding: utf-8 -*-
import pandas as pd
import os
import sys

def generar_template_excel():
    carpeta_gtfs = "gtfsFiles"
    print(f"==================================================")
    print(f" GENERADOR DE PLANTILLA ETL - APIMETRO ")
    print(f"==================================================")
    
    # 1. Validación de seguridad (Mecanismo de defensa)
    archivos_requeridos = ["routes.txt", "stops.txt", "trips.txt", "stop_times.txt"]
    for archivo in archivos_requeridos:
        if not os.path.exists(os.path.join(carpeta_gtfs, archivo)):
            print(f"\n[ERROR CRÍTICO] Falta el archivo '{archivo}' en la carpeta '{carpeta_gtfs}'.")
            if archivo == "stop_times.txt":
                print("-> RECUERDA: Este archivo es vital para crear los nodos del Grafo (Estaciones compartidas).")
            sys.exit(1) # Detenemos el script de forma segura
            
    print(f"\nLeyendo archivos GTFS desde '{carpeta_gtfs}'...")
    
    df_routes = pd.read_csv(os.path.join(carpeta_gtfs, "routes.txt"))
    df_stops = pd.read_csv(os.path.join(carpeta_gtfs, "stops.txt"))
    df_trips = pd.read_csv(os.path.join(carpeta_gtfs, "trips.txt"))
    
    print("Leyendo stop_times.txt (Esto puede tardar unos segundos, es un archivo pesado)...")
    df_stop_times = pd.read_csv(os.path.join(carpeta_gtfs, "stop_times.txt"))
    
    # ==========================================
    # PESTAÑA 1: LÍNEAS (Limpieza y Estandarización)
    # ==========================================
    print("\n[1/3] Procesando Líneas...")
    
    def estandarizar_nombre_y_sistema(row):
        agencia = str(row['agency_id']).strip().upper()
        corto = str(row['route_short_name']).strip()
        largo = str(row['route_long_name']).strip()
        
        # Parche Semovi/Trolebus
        if agencia == 'SEMOVI' and 'TROLE' in largo.upper():
            agencia = 'TROLE'
            
        # Generación del nombre descriptivo
        if agencia == 'METRO':
            nombre = f"Metro Línea {corto}"
        elif agencia == 'MB':
            nombre = f"Metrobús Línea {corto}"
        elif agencia == 'CBB':
            nombre = f"Cablebús Línea {corto}"
        elif agencia == 'TROLE':
            nombre = f"Trolebús Línea {corto}"
        elif agencia == 'TL':
            nombre = "Tren Ligero"
        elif agencia == 'SUB':
            nombre = "Tren Suburbano"
        elif agencia == 'INTERURBANO':
            nombre = "Tren El Insurgente"
        elif agencia == 'CC':
            nombre = f"Concesionado Ruta {corto}: {largo}"
        else:
            nombre_base = largo if largo != 'nan' and largo != '' else corto
            nombre = f"{agencia} Ruta {corto}: {nombre_base}"
            
        return pd.Series([nombre, agencia, corto])

    df_routes[['nombre_comercial', 'sistema_corregido', 'num_comercial']] = df_routes.apply(estandarizar_nombre_y_sistema, axis=1, result_type='expand')
    
    lineas_data = {
        "LINEA_ID": range(1, len(df_routes) + 1),
        "ROUTE_GTFS": df_routes['route_id'].astype(str).str.strip(),
        "NOMBRE": df_routes['nombre_comercial'], 
        "NUM_COMERCIAL": df_routes['num_comercial'], 
        "SISTEMA": df_routes['sistema_corregido'],
        "ANIO_INAUGURACION": "",   
        "COLOR_EN": df_routes['route_color'].astype(str).str.strip(), 
        "COLOR_ESP": df_routes['route_color'].astype(str).str.strip(),
        "TAM_KM": "",              
        "EXISTE": True,
        "RAMAL": "",               
        "BASE": ""                 
    }
    df_lineas = pd.DataFrame(lineas_data)
    map_route_to_linea_id = dict(zip(df_lineas['ROUTE_GTFS'], df_lineas['LINEA_ID']))

    # ==========================================
    # PESTAÑA 2: RAMALES 
    # ==========================================
    print("[2/3] Procesando Ramales...")
    df_shapes_unique = df_trips[['route_id', 'shape_id', 'trip_headsign']].dropna(subset=['shape_id']).drop_duplicates(subset=['shape_id'])
    df_shapes_unique['trip_headsign'] = df_shapes_unique['trip_headsign'].astype(str).str.strip()
    
    ramales_data = {
        "RAMAL_ID": range(1, len(df_shapes_unique) + 1),
        "LINEA_ID": df_shapes_unique['route_id'].map(map_route_to_linea_id),
        "SHAPE_GTFS": df_shapes_unique['shape_id'].astype(str).str.strip(),
        "NOMBRE_RAMAL": df_shapes_unique['trip_headsign'].replace('nan', ''), 
        "TAM_KM": "",              
        "ANIO_CREACION": 2024,
        "RAMAL_NUM": 1,
        "ESTADO": "Existe" 
    }
    df_ramales = pd.DataFrame(ramales_data)
    df_ramales['NOMBRE_RAMAL'] = df_ramales.apply(
        lambda row: f"Ramal {row['SHAPE_GTFS']}" if row['NOMBRE_RAMAL'] == "" else row['NOMBRE_RAMAL'], 
        axis=1
    )

    # ==========================================
    # PESTAÑA 3: ESTACIONES (Modelo de Grafo)
    # ==========================================
    print("[3/3] Cruzando datos espaciales de Estaciones y Líneas...")
    df_stops['stop_name'] = df_stops['stop_name'].astype(str).str.strip()
    
    # Unimos tiempos de parada con viajes
    df_st_trips = df_stop_times[['trip_id', 'stop_id', 'stop_sequence']].merge(
        df_trips[['trip_id', 'route_id']], 
        on='trip_id', 
        how='inner'
    )
    
    # Nodos únicos del grafo
    df_estaciones_por_linea = df_st_trips.sort_values(['route_id', 'trip_id', 'stop_sequence'])\
                                         .drop_duplicates(subset=['route_id', 'stop_id']).copy()
    
    df_estaciones_por_linea['LINEA_ID_NUEVO'] = df_estaciones_por_linea['route_id'].map(map_route_to_linea_id)
    df_nodos_finales = df_estaciones_por_linea.merge(df_stops[['stop_id', 'stop_name']], on='stop_id', how='left')
    
    df_nodos_finales = df_nodos_finales.dropna(subset=['LINEA_ID_NUEVO'])
    df_nodos_finales['LINEA_ID_NUEVO'] = df_nodos_finales['LINEA_ID_NUEVO'].astype(int)
    
    estaciones_data = {
        "ESTACION_ID": range(1, len(df_nodos_finales) + 1),
        "STOP_GTFS": df_nodos_finales['stop_id'].astype(str).str.strip(),
        "NOMBRE": df_nodos_finales['stop_name'],
        "CVE_EST": "",               
        "TIPO": "",                  
        "ALCALDIA_MUNICIPIO": "",    
        "ANIO": "",                  
        "ESTADO_CIUDAD": "CDMX",     
        "LINEA_ID": df_nodos_finales['LINEA_ID_NUEVO'], 
        "NUM_ESTACION": df_nodos_finales['stop_sequence'], 
        "ESTACION_ID_OFICIAL": "",   
        "SISTEMA": "",               
        "EXISTE": True
    }
    df_estaciones = pd.DataFrame(estaciones_data)

    # ==========================================
    # EXPORTAR A EXCEL
    # ==========================================
    nombre_archivo_salida = "template_apimetro_limpio.xlsx"
    print(f"\nGuardando y formateando datos en '{nombre_archivo_salida}'...")
    
    with pd.ExcelWriter(nombre_archivo_salida, engine='xlsxwriter') as writer:
        df_lineas.to_excel(writer, sheet_name='Lineas', index=False)
        df_ramales.to_excel(writer, sheet_name='Ramales', index=False)
        df_estaciones.to_excel(writer, sheet_name='Estaciones', index=False)
        
    print("==================================================")
    print(" ¡PLANTILLA GENERADA CON ÉXITO! ")
    print("==================================================")

if __name__ == "__main__":
    generar_template_excel()