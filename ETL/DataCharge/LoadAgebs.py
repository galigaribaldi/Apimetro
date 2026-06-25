# -*- coding: utf-8 -*-
"""
LoadAgebs.py — ETL: AGEBs urbanas + Censo 2020 → plutarco.agebs
Scope: 6 estados de la macrometrópoli (CDMX=09, EdoMex=15, Morelos=17,
       Puebla=21, Querétaro=22, Tlaxcala=29)

Fuentes:
  Shapefiles: Data/AGEBS/ (formato INEGI Marco Geoestadístico Nacional)
  Censo 2020: Data/Censo/ (CSV por entidad, INEGI CPV 2020)

Idempotencia: ON CONFLICT (cve_ageb) DO NOTHING — seguro re-ejecutar.
"""
import psycopg2
import psycopg2.extras
import pandas as pd
import geopandas as gpd
from shapely.geometry import MultiPolygon, Polygon
from conf import host, database, user, password, port


# ---------------------------------------------------------------------------
# Configuración de fuentes por entidad
# ---------------------------------------------------------------------------
ENTIDADES = [
    {
        "cve_ent": "09",
        "nombre":  "Ciudad de México",
        "shp":     "Data/AGEBS/poligono_ageb_urbanas_cdmx/poligono_ageb_urbanas_cdmx.shp",
        "csv":     "Data/Censo/ageb_mza_urbana_09_cpv2020/conjunto_de_datos/conjunto_de_datos_ageb_urbana_09_cpv2020.csv",
        "reproyectar": False,   # Ya en EPSG:4326
    },
    {
        "cve_ent": "15",
        "nombre":  "Estado de México",
        "shp":     "Data/AGEBS/15_mexico/conjunto_de_datos/15a.shp",
        "csv":     "Data/Censo/RESAGEBURB_15CSV20.csv",
        "reproyectar": True,    # ITRF2008/LCC → EPSG:4326
    },
    {
        "cve_ent": "17",
        "nombre":  "Morelos",
        "shp":     "Data/AGEBS/17_morelos/conjunto_de_datos/17a.shp",
        "csv":     "Data/Censo/RESAGEBURB_17CSV20.csv",
        "reproyectar": True,
    },
    {
        "cve_ent": "21",
        "nombre":  "Puebla",
        "shp":     "Data/AGEBS/21_puebla/conjunto_de_datos/21a.shp",
        "csv":     "Data/Censo/RESAGEBURB_21CSV20.csv",
        "reproyectar": True,
    },
    {
        "cve_ent": "22",
        "nombre":  "Querétaro",
        "shp":     "Data/AGEBS/22_queretaro/conjunto_de_datos/22a.shp",
        "csv":     "Data/Censo/RESAGEBURB_22CSV20.csv",
        "reproyectar": True,
    },
    {
        "cve_ent": "29",
        "nombre":  "Tlaxcala",
        "shp":     "Data/AGEBS/29_tlaxcala/conjunto_de_datos/29a.shp",
        "csv":     "Data/Censo/RESAGEBURB_29CSV20.csv",
        "reproyectar": True,
    },
]


class AgebsETL():

    # -----------------------------------------------------------------------
    # 1. EXTRACT
    # -----------------------------------------------------------------------
    def _leer_censo(self, csv_path: str) -> pd.DataFrame:
        """Lee el CSV del Censo y retorna solo filas a nivel AGEB."""
        df = pd.read_csv(
            csv_path,
            dtype=str,          # Todo como string para preservar ceros
            low_memory=False,
            encoding="utf-8-sig",  # Maneja BOM (todos los CSVs del INEGI lo traen)
        )
        # Normalizar columnas a mayúsculas por si hay variación entre archivos
        df.columns = [c.upper().strip() for c in df.columns]

        # Filtro nivel AGEB: MZA=='000', AGEB!='0000', MUN!='000', LOC!='0000'
        df = df[
            (df["MZA"].str.zfill(3) == "000") &
            (df["AGEB"].str.zfill(4) != "0000") &
            (df["MUN"].str.zfill(3)  != "000") &
            (df["LOC"].str.zfill(4)  != "0000")
        ].copy()

        # Construir clave CVEGEO: CVE_ENT(2)+MUN(3)+LOC(4)+AGEB(4) = 13 chars
        df["CVEGEO_calc"] = (
            df["ENTIDAD"].str.zfill(2) +
            df["MUN"].str.zfill(3) +
            df["LOC"].str.zfill(4) +
            df["AGEB"].str.zfill(4)
        )

        return df[["CVEGEO_calc", "NOM_MUN", "POBTOT", "TVIVHAB", "PEA"]].copy()

    def _leer_shapefile(self, shp_path: str, reproyectar: bool) -> gpd.GeoDataFrame:
        """Lee el shapefile INEGI y, si es necesario, reproyecta a WGS84."""
        gdf = gpd.read_file(shp_path)

        if reproyectar:
            gdf = gdf.to_crs(epsg=4326)

        # Asegurar que toda geometría es MultiPolygon (la tabla acepta solo ese tipo)
        gdf["geometry"] = gdf["geometry"].apply(
            lambda g: MultiPolygon([g]) if isinstance(g, Polygon) else g
        )

        return gdf[["CVEGEO", "CVE_ENT", "geometry"]].copy()

    def extract(self) -> gpd.GeoDataFrame:
        """
        Itera las 6 entidades, une shapefile + Censo y devuelve un GeoDataFrame
        consolidado con todas las AGEBs listas para insertar.
        """
        frames = []

        for ent in ENTIDADES:
            print(f"  [{ent['cve_ent']}] {ent['nombre']} — leyendo shapefile...")
            gdf_shp = self._leer_shapefile(ent["shp"], ent["reproyectar"])

            print(f"  [{ent['cve_ent']}] Leyendo CSV Censo...")
            df_censo = self._leer_censo(ent["csv"])

            # JOIN por clave de 13 caracteres
            merged = gdf_shp.merge(
                df_censo,
                left_on="CVEGEO",
                right_on="CVEGEO_calc",
                how="inner",
            )

            n_shp    = len(gdf_shp)
            n_merged = len(merged)
            print(f"  [{ent['cve_ent']}] JOIN: {n_merged}/{n_shp} AGEBs con datos censales")

            frames.append(merged)

        resultado = gpd.GeoDataFrame(pd.concat(frames, ignore_index=True), crs="EPSG:4326")
        print(f"\n  Total AGEBs consolidadas: {len(resultado)}")
        return resultado

    # -----------------------------------------------------------------------
    # 2. LOAD
    # -----------------------------------------------------------------------
    def load(self, gdf: gpd.GeoDataFrame):
        """
        Inserta las AGEBs en plutarco.agebs usando psycopg2 + execute_values.
        ON CONFLICT (cve_ageb) DO NOTHING → idempotente.
        Tras la inserción calcula area_km2 y densidad_pob_km2 con PostGIS.
        """
        conn = psycopg2.connect(
            host=host, dbname=database, user=user, password=password, port=port
        )
        cur = conn.cursor()

        print(f"\n  Preparando {len(gdf)} registros para inserción...")

        def safe_int(val) -> int:
            """Convierte a int; devuelve 0 si es NaN, '*' u otro no numérico.
            INEGI usa '*' para datos suprimidos por confidencialidad."""
            try:
                if pd.isna(val):
                    return 0
                s = str(val).strip()
                return int(s) if s.lstrip("-").isdigit() else 0
            except (ValueError, TypeError):
                return 0

        filas = []
        for _, row in gdf.iterrows():
            geom_wkt = row["geometry"].wkt if row["geometry"] else None
            filas.append((
                str(row["CVEGEO"]),
                str(row["CVE_ENT"]).zfill(2),
                str(row["NOM_MUN"]) if pd.notna(row.get("NOM_MUN")) else None,
                safe_int(row.get("POBTOT")),
                safe_int(row.get("TVIVHAB")),
                safe_int(row.get("PEA")),
                geom_wkt,
            ))

        sql_insert = """
            INSERT INTO plutarco.agebs
                (cve_ageb, entidad, municipio_alcaldia,
                 poblacion_total, viviendas_habitadas, pea,
                 geom)
            VALUES (
                %s, %s, %s, %s, %s, %s,
                ST_Multi(ST_GeomFromText(%s, 4326))
            )
            ON CONFLICT (cve_ageb) DO NOTHING
        """

        BATCH = 500
        insertados = 0
        for i in range(0, len(filas), BATCH):
            lote = filas[i : i + BATCH]
            cur.executemany(sql_insert, lote)
            conn.commit()
            insertados += len(lote)
            print(f"  Insertados {min(insertados, len(filas))}/{len(filas)}...", end="\r")

        print(f"\n  Inserción completada.")

        # Calcular area_km2 y densidad_pob_km2 con PostGIS
        print("  Calculando area_km2 y densidad_pob_km2 con PostGIS...")
        cur.execute("""
            UPDATE plutarco.agebs
            SET
                area_km2 = ROUND((ST_Area(geom::geography) / 1e6)::numeric, 4),
                densidad_pob_km2 = CASE
                    WHEN ST_Area(geom::geography) > 0
                    THEN ROUND((poblacion_total / (ST_Area(geom::geography) / 1e6))::numeric, 4)
                    ELSE 0
                END
            WHERE area_km2 IS NULL;
        """)
        conn.commit()
        print("  Cálculo de áreas completado.")

        cur.close()
        conn.close()

    # -----------------------------------------------------------------------
    # 3. PIPELINE COMPLETO
    # -----------------------------------------------------------------------
    def run(self):
        print("\n--- EXTRAYENDO AGEBs + CENSO ---")
        gdf = self.extract()

        print("\n--- CARGANDO EN plutarco.agebs ---")
        self.load(gdf)

        print("\n--- ETL AGEBs FINALIZADO ---")
