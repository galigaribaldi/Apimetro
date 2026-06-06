# -*- coding: utf-8 -*-
"""
LoadPlutarcoGeo.py — ETL: capas geográficas del esquema plutarco
  - plutarco.calles       ← ETL/Data/Vialidades/lineas_ejes_de_vialidad.shp
  - plutarco.uso_suelo    ← ETL/Data/Medio_Fisico/MedioFisicoNatural.gpkg (inegi_ambi_usosue_1993)
  - plutarco.curvas_nivel ← ETL/Data/Medio_Fisico/MedioFisicoNatural.gpkg (CurvasNivel)

Idempotencia: TRUNCATE antes de insertar (tablas de referencia geográfica estática).
"""
import psycopg2
import psycopg2.extras
import pyogrio
import geopandas as gpd
from shapely.geometry import MultiLineString, LineString, MultiPolygon, Polygon
from conf import host, database, user, password, port

BATCH = 1000

SHP_CALLES    = "Data/Vialidades/lineas_ejes_de_vialidad/lineas_ejes_de_vialidad.shp"
GPKG_MEDIO    = "Data/Medio_Fisico/MedioFisicoNatural.gpkg"
LAYER_SUELO   = "inegi_ambi_usosue_1993"
LAYER_CURVAS  = "CurvasNivel"


def _conn():
    return psycopg2.connect(
        host=host, dbname=database, user=user, password=password, port=port
    )


def _to_multi(geom):
    """Convierte LineString→MultiLineString y Polygon→MultiPolygon si es necesario."""
    if geom is None:
        return None
    if isinstance(geom, LineString):
        return MultiLineString([geom])
    if isinstance(geom, Polygon):
        return MultiPolygon([geom])
    return geom


def _insert_batch(cur, sql, filas, nombre):
    total = len(filas)
    for i in range(0, total, BATCH):
        lote = filas[i: i + BATCH]
        cur.executemany(sql, lote)
        cur.connection.commit()
        print(f"  {nombre}: {min(i + BATCH, total):,}/{total:,}...", end="\r")
    print(f"  {nombre}: {total:,}/{total:,} — completado.  ")


# ---------------------------------------------------------------------------
# 1. CALLES
# ---------------------------------------------------------------------------
class CallesETL:
    def run(self):
        print("\n  Leyendo shapefile vialidades...")
        gdf = pyogrio.read_dataframe(SHP_CALLES, encoding="utf-8")
        print(f"  Filas leídas: {len(gdf):,}")

        conn = _conn()
        cur = conn.cursor()
        cur.execute("TRUNCATE TABLE plutarco.calles RESTART IDENTITY;")
        conn.commit()

        sql = """
            INSERT INTO plutarco.calles
                (cvegeo, cve_ent, cve_mun, cve_loc, cvevial, cveseg,
                 nomvial, tipovial, sentido, tiposen, ambito, geom)
            VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,
                    ST_Multi(ST_GeomFromText(%s, 4326)))
        """

        filas = []
        for _, row in gdf.iterrows():
            geom = _to_multi(row.geometry)
            filas.append((
                row.get("CVEGEO"),
                row.get("CVE_ENT"),
                row.get("CVE_MUN"),
                row.get("CVE_LOC"),
                row.get("CVEVIAL"),
                row.get("CVESEG"),
                row.get("NOMVIAL"),
                row.get("TIPOVIAL"),
                row.get("SENTIDO"),
                int(row["TIPOSEN"]) if row.get("TIPOSEN") else None,
                row.get("AMBITO"),
                geom.wkt if geom else None,
            ))

        _insert_batch(cur, sql, filas, "calles")
        cur.close()
        conn.close()


# ---------------------------------------------------------------------------
# 2. USO DE SUELO
# ---------------------------------------------------------------------------
class UsoSueloETL:
    def run(self):
        print("\n  Leyendo capa uso_suelo del GPKG...")
        gdf = pyogrio.read_dataframe(GPKG_MEDIO, layer=LAYER_SUELO, encoding="latin-1")
        print(f"  Filas leídas: {len(gdf):,}")

        conn = _conn()
        cur = conn.cursor()
        cur.execute("TRUNCATE TABLE plutarco.uso_suelo RESTART IDENTITY;")
        conn.commit()

        sql = """
            INSERT INTO plutarco.uso_suelo
                (cve_carta, entidad, tipo, fisonomia, veg_sec,
                 erosion, cult_pri, tipod7, representa, geom)
            VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,
                    ST_Multi(ST_GeomFromText(%s, 4326)))
        """

        filas = []
        for _, row in gdf.iterrows():
            geom = _to_multi(row.geometry)
            filas.append((
                row.get("carta"),
                row.get("entidad"),
                row.get("tipo"),
                row.get("fisonomia"),
                row.get("veg_sec"),
                row.get("erosion"),
                row.get("cult_pri"),
                row.get("tipod7"),
                row.get("representa"),
                geom.wkt if geom else None,
            ))

        _insert_batch(cur, sql, filas, "uso_suelo")
        cur.close()
        conn.close()


# ---------------------------------------------------------------------------
# 3. CURVAS DE NIVEL
# ---------------------------------------------------------------------------
class CurvasNivelETL:
    def run(self):
        print("\n  Leyendo capa curvas_nivel del GPKG...")
        gdf = pyogrio.read_dataframe(GPKG_MEDIO, layer=LAYER_CURVAS, encoding="latin-1")
        print(f"  Filas leídas: {len(gdf):,}")

        conn = _conn()
        cur = conn.cursor()
        cur.execute("TRUNCATE TABLE plutarco.curvas_nivel RESTART IDENTITY;")
        conn.commit()

        sql = """
            INSERT INTO plutarco.curvas_nivel (elevacion, tipo, geom)
            VALUES (%s, %s, ST_Multi(ST_GeomFromText(%s, 4326)))
        """

        filas = []
        for _, row in gdf.iterrows():
            geom = _to_multi(row.geometry)
            elev = row.get("elevacion")
            filas.append((
                float(elev) if elev is not None else None,
                row.get("tipo"),
                geom.wkt if geom else None,
            ))

        _insert_batch(cur, sql, filas, "curvas_nivel")
        cur.close()
        conn.close()


# ---------------------------------------------------------------------------
# PIPELINE COMPLETO
# ---------------------------------------------------------------------------
class PlutarcoGeoETL:
    def run(self):
        print("\n--- CARGANDO CAPAS GEOGRÁFICAS PLUTARCO ---")

        print("\n[1/3] plutarco.calles")
        CallesETL().run()

        print("\n[2/3] plutarco.uso_suelo")
        UsoSueloETL().run()

        print("\n[3/3] plutarco.curvas_nivel")
        CurvasNivelETL().run()

        print("\n--- ETL PLUTARCO GEO FINALIZADO ---")
