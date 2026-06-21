# -*- coding: utf-8 -*-
"""
LoadAfluencia.py — ETL: Afluencia mensual por línea → plutarco.afluencia_linea
Issue: #39

Fuentes:
  afluencia_diaria_historica.xlsx  → Fuente principal (todos los sistemas)
  afluencia_desglosada_cb_03_2026.csv      → Complemento CBB 2026
  afluencia_desglosada_tl_03_2026.csv      → Complemento TL 2026
  afluencia_desglosada_trolebus_03_2026.csv → Complemento TROLE 2026
  afluenciartp_desglosado_03_2026.csv      → Complemento RTP 2026

Prerequisitos:
  1. Tablas creadas: db/migrations/v2.0_afluencia.sql
  2. Catálogo cargado: db/migrations/seed_catalogo_homologacion.sql

Idempotencia: ON CONFLICT (linea_id, anio, mes_num) DO NOTHING — seguro re-ejecutar.
"""
import psycopg2
import pandas as pd
import unicodedata
from conf import host, database, user, password, port

# Ruta base de datos fuente
DATA_DIR = "Data/Pesos"

# Mapeo organismo Excel → sistema API
ORGANISMO_A_SISTEMA = {
    "STC":             "METRO",
    "Metrobús":        "MB",
    "Metrobus":        "MB",
    "STE-Cablebús":    "CBB",
    "STE-Cablebus":    "CBB",
    "STE-Tren Ligero": "TL",
    "STE-Trolebús":    "TROLE",
    "STE-Trolebus":    "TROLE",
    "RTP":             "RTP",
}

MESES = {
    1: "Enero", 2: "Febrero", 3: "Marzo", 4: "Abril",
    5: "Mayo", 6: "Junio", 7: "Julio", 8: "Agosto",
    9: "Septiembre", 10: "Octubre", 11: "Noviembre", 12: "Diciembre",
}


def _normalizar(texto: str) -> str:
    """Normaliza un string: strip + NFC unicode."""
    if not isinstance(texto, str):
        return str(texto).strip()
    return unicodedata.normalize("NFC", texto.strip())


class AfluenciaETL:

    def __init__(self):
        self.conn = psycopg2.connect(
            host=host, dbname=database, user=user, password=password, port=port
        )
        self._catalogo = None

    def _cargar_catalogo(self) -> dict:
        """Carga el catálogo de homologación como dict: (nombre_csv, sistema) → (linea_id, activo)."""
        if self._catalogo is not None:
            return self._catalogo

        cur = self.conn.cursor()
        cur.execute("""
            SELECT nombre_csv, sistema, linea_id, activo
            FROM plutarco.catalogo_homologacion
            WHERE activo = TRUE
        """)
        self._catalogo = {}
        for nombre_csv, sistema, linea_id, activo in cur.fetchall():
            self._catalogo[(nombre_csv, sistema)] = linea_id
        cur.close()

        print(f"  Catálogo cargado: {len(self._catalogo)} entradas activas")
        return self._catalogo

    def _resolver_linea_id(self, nombre_csv: str, sistema: str) -> int | None:
        """Busca linea_id en el catálogo. Retorna None si no hay match."""
        catalogo = self._cargar_catalogo()
        return catalogo.get((_normalizar(nombre_csv), sistema))

    def _insertar_filas(self, filas: list[tuple], fuente: str):
        """
        Inserta filas en plutarco.afluencia_linea.
        Cada fila: (linea_id, sistema, num_comercial, anio, mes_num, mes, afluencia, fuente)
        """
        cur = self.conn.cursor()

        sql = """
            INSERT INTO plutarco.afluencia_linea
                (linea_id, sistema, num_comercial, anio, mes_num, mes, afluencia, fuente)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            ON CONFLICT (linea_id, anio, mes_num) DO NOTHING
        """

        BATCH = 500
        insertados = 0
        for i in range(0, len(filas), BATCH):
            lote = filas[i : i + BATCH]
            cur.executemany(sql, lote)
            self.conn.commit()
            insertados += len(lote)
            print(f"  Insertados {min(insertados, len(filas))}/{len(filas)}...", end="\r")

        print(f"\n  {fuente}: {len(filas)} filas procesadas")
        cur.close()

    # -------------------------------------------------------------------
    # EXTRACT + TRANSFORM: Fuente principal (Excel histórico)
    # -------------------------------------------------------------------
    def _procesar_excel_historico(self):
        """
        Lee afluencia_diaria_historica.xlsx y agrega a nivel mensual.
        Columnas: organismo, linea_servicio, fecha (serial Excel), afluencia_total_preliminar
        Excluye: Ecobici y Suburbano (no están en public.lineas).
        """
        from datetime import datetime, timedelta

        ruta = f"{DATA_DIR}/afluencia_diaria_historica.xlsx"
        print(f"\n  Leyendo {ruta}...")

        # No usar dtype=str — dejar que pandas infiera tipos nativos
        df = pd.read_excel(ruta)
        df.columns = [c.strip().lower() for c in df.columns]

        print(f"  Columnas detectadas: {list(df.columns)}")
        print(f"  Total filas en Excel: {len(df)}")

        # Columnas fijas de este archivo
        col_org = "organismo"
        col_linea = "linea_servicio"
        col_fecha = "fecha"
        col_aflu = "afluencia_total_preliminar"

        # Excluir organismos sin mapeo o sin líneas en public.lineas
        # RTP usa servicios (Ordinario, Expreso...), no líneas — VFT no lo puede usar
        organismos_excluir = {"Ecobici", "Suburbano", "RTP"}
        df = df[~df[col_org].isin(organismos_excluir)].copy()
        print(f"  Filas tras excluir {organismos_excluir}: {len(df)}")

        # Excluir filas sin línea (Ecobici no tiene linea_servicio)
        df = df.dropna(subset=[col_linea])

        # Convertir fecha serial Excel → datetime
        # Excel serial: 43891 = 2020-03-01 (epoch 1899-12-30)
        excel_epoch = datetime(1899, 12, 30)
        df[col_fecha] = pd.to_numeric(df[col_fecha], errors="coerce")
        df = df.dropna(subset=[col_fecha])
        df["fecha_dt"] = df[col_fecha].apply(lambda x: excel_epoch + timedelta(days=int(x)))
        df["anio"] = df["fecha_dt"].apply(lambda x: x.year)
        df["mes_num"] = df["fecha_dt"].apply(lambda x: x.month)

        # Afluencia
        df[col_aflu] = pd.to_numeric(df[col_aflu], errors="coerce").fillna(0).astype(int)

        # Mapear organismo → sistema
        df["sistema"] = df[col_org].apply(lambda x: ORGANISMO_A_SISTEMA.get(_normalizar(x)))
        sin_mapeo = df[df["sistema"].isna()][col_org].unique()
        if len(sin_mapeo) > 0:
            print(f"  [WARN] Organismos sin mapeo: {list(sin_mapeo)}")
        df = df.dropna(subset=["sistema"])

        # Agregar a nivel mensual: sistema + linea + año + mes
        agrupado = df.groupby(
            ["sistema", col_linea, "anio", "mes_num"], as_index=False
        )[col_aflu].sum()

        print(f"  Registros mensuales agregados: {len(agrupado)}")

        # Resolver linea_id y construir filas
        filas = []
        sin_catalogo = set()
        for _, row in agrupado.iterrows():
            sistema = row["sistema"]
            nombre_csv = _normalizar(row[col_linea])
            linea_id = self._resolver_linea_id(nombre_csv, sistema)

            if linea_id is None:
                sin_catalogo.add((nombre_csv, sistema))
                continue

            anio = int(row["anio"])
            mes_num = int(row["mes_num"])
            filas.append((
                linea_id,
                sistema,
                None,  # num_comercial se puede poblar después
                anio,
                mes_num,
                MESES.get(mes_num, ""),
                int(row[col_aflu]),
                "SEMOVI-Histórico",
            ))

        if sin_catalogo:
            print(f"  [WARN] {len(sin_catalogo)} nombres sin match en catálogo:")
            for nombre, sist in sorted(sin_catalogo)[:20]:
                print(f"         ({sist}) '{nombre}'")

        if filas:
            self._insertar_filas(filas, "Excel histórico")

    # -------------------------------------------------------------------
    # EXTRACT + TRANSFORM: CSVs complementarios 2026
    # -------------------------------------------------------------------
    def _procesar_csv_cbb(self):
        """Cablebús — afluencia_desglosada_cb_03_2026.csv"""
        ruta = f"{DATA_DIR}/afluencia_desglosada_cb_03_2026.csv"
        self._procesar_csv_generico(
            ruta=ruta,
            sistema="CBB",
            col_linea="linea",
            fuente="SEMOVI-CBB-2026",
        )

    def _procesar_csv_tl(self):
        """Tren Ligero — afluencia_desglosada_tl_03_2026.csv (sin columna línea)"""
        ruta = f"{DATA_DIR}/afluencia_desglosada_tl_03_2026.csv"
        print(f"\n  Leyendo {ruta}...")

        df = pd.read_csv(ruta, dtype=str, encoding="utf-8-sig")
        df.columns = [c.strip().lower() for c in df.columns]

        col_aflu = next((c for c in df.columns if "afluencia" in c or "viajes" in c), None)
        if not col_aflu:
            print(f"  [WARN] No se encontró columna de afluencia en TL. Saltando.")
            return

        df[col_aflu] = pd.to_numeric(df[col_aflu], errors="coerce").fillna(0).astype(int)

        # Derivar anio y mes_num desde fecha (más confiable que parsear columna "mes" textual)
        if "fecha" in df.columns:
            df["fecha_dt"] = pd.to_datetime(df["fecha"], errors="coerce")
            df["anio"] = df["fecha_dt"].dt.year
            df["mes_num"] = df["fecha_dt"].dt.month
        else:
            df["anio"] = pd.to_numeric(df.get("anio", df.get("año")), errors="coerce")
            df["mes_num"] = pd.to_numeric(df.get("mes_num"), errors="coerce")

        df = df.dropna(subset=["anio", "mes_num"])

        agrupado = df.groupby(["anio", "mes_num"], as_index=False)[col_aflu].sum()

        linea_id = self._resolver_linea_id("Tren Ligero", "TL")
        if linea_id is None:
            linea_id = self._resolver_linea_id("Línea 1", "TL")
        if linea_id is None:
            print("  [WARN] TL sin match en catálogo. Saltando.")
            return

        filas = []
        for _, row in agrupado.iterrows():
            anio = int(row["anio"])
            mes_num = int(row["mes_num"])
            filas.append((
                linea_id, "TL", None,
                anio, mes_num, MESES.get(mes_num, ""),
                int(row[col_aflu]),
                "SEMOVI-TL-2026",
            ))

        if filas:
            self._insertar_filas(filas, "CSV Tren Ligero")

    def _procesar_csv_trole(self):
        """Trolebús — afluencia_desglosada_trolebus_03_2026.csv"""
        ruta = f"{DATA_DIR}/afluencia_desglosada_trolebus_03_2026.csv"
        self._procesar_csv_generico(
            ruta=ruta,
            sistema="TROLE",
            col_linea="linea",
            fuente="SEMOVI-TROLE-2026",
        )

    def _procesar_csv_rtp(self):
        """RTP — EXCLUIDO: usa servicios (Ordinario, Expreso...), no líneas.
        VFT requiere afluencia por línea para asignar a estaciones.
        Si en el futuro RTP se desglosa por ruta, reactivar."""
        print("\n  RTP: excluido (servicios, no líneas). Saltando.")

    def _procesar_csv_generico(self, ruta: str, sistema: str, col_linea: str, fuente: str):
        """
        Procesamiento genérico para CSVs complementarios.
        Estructura esperada: fecha, mes, anio, <linea>, tipo_pago, afluencia
        Lee, agrupa por línea+mes+año, resuelve linea_id via catálogo.
        """
        print(f"\n  Leyendo {ruta}...")

        # Intentar UTF-8 primero, fallback a latin-1 si hay bytes corruptos
        df = None
        for enc in ("utf-8-sig", "utf-8", "latin-1"):
            try:
                df = pd.read_csv(ruta, dtype=str, encoding=enc)
                break
            except (UnicodeDecodeError, FileNotFoundError) as e:
                if isinstance(e, FileNotFoundError):
                    print(f"  [WARN] Archivo no encontrado: {ruta}. Saltando.")
                    return
                continue

        if df is None:
            print(f"  [WARN] No se pudo leer {ruta} con ningún encoding. Saltando.")
            return

        df.columns = [c.strip().lower() for c in df.columns]

        # Detectar columna de afluencia
        col_aflu = next((c for c in df.columns if "afluencia" in c or "viajes" in c), None)
        if not col_aflu:
            print(f"  [WARN] No se encontró columna de afluencia. Cols: {list(df.columns)}")
            return

        # Normalizar col_linea
        if col_linea not in df.columns:
            col_linea = next((c for c in df.columns if col_linea in c), None)
            if not col_linea:
                print(f"  [WARN] No se encontró columna '{col_linea}'. Saltando.")
                return

        df[col_aflu] = pd.to_numeric(df[col_aflu], errors="coerce").fillna(0).astype(int)

        # Resolver año — columna "anio" ya viene como string numérico
        if "anio" in df.columns or "año" in df.columns:
            col_anio = "anio" if "anio" in df.columns else "año"
            df["anio"] = pd.to_numeric(df[col_anio], errors="coerce")
        elif "fecha" in df.columns:
            df["fecha_dt"] = pd.to_datetime(df["fecha"], errors="coerce")
            df["anio"] = df["fecha_dt"].dt.year
        else:
            print("  [WARN] No se encontró columna de año/fecha. Saltando.")
            return

        # Resolver mes — la columna "mes" tiene nombres ("Enero", "Febrero"...)
        # Derivar mes_num desde la columna "fecha" que tiene formato YYYY-MM-DD
        if "fecha" in df.columns:
            df["fecha_dt"] = pd.to_datetime(df["fecha"], errors="coerce")
            df["mes_num"] = df["fecha_dt"].dt.month
        elif "mes_num" in df.columns:
            df["mes_num"] = pd.to_numeric(df["mes_num"], errors="coerce")
        else:
            # Intentar mapear nombre de mes a número
            meses_inv = {v.lower(): k for k, v in MESES.items()}
            if "mes" in df.columns:
                df["mes_num"] = df["mes"].str.strip().str.lower().map(meses_inv)
            else:
                print("  [WARN] No se encontró columna de mes. Saltando.")
            return

        df = df.dropna(subset=["anio", "mes_num"])

        # Agregar por línea + año + mes
        agrupado = df.groupby(
            [col_linea, "anio", "mes_num"], as_index=False
        )[col_aflu].sum()

        print(f"  Registros mensuales agregados: {len(agrupado)}")

        filas = []
        sin_catalogo = set()
        for _, row in agrupado.iterrows():
            nombre_csv = _normalizar(row[col_linea])
            linea_id = self._resolver_linea_id(nombre_csv, sistema)

            if linea_id is None:
                sin_catalogo.add(nombre_csv)
                continue

            anio = int(row["anio"])
            mes_num = int(row["mes_num"])
            filas.append((
                linea_id, sistema, None,
                anio, mes_num, MESES.get(mes_num, ""),
                int(row[col_aflu]),
                fuente,
            ))

        if sin_catalogo:
            print(f"  [WARN] {len(sin_catalogo)} nombres sin match en catálogo ({sistema}):")
            for nombre in sorted(sin_catalogo)[:10]:
                print(f"         '{nombre}'")

        if filas:
            self._insertar_filas(filas, f"CSV {sistema}")

    # -------------------------------------------------------------------
    # PIPELINE COMPLETO
    # -------------------------------------------------------------------
    def run(self):
        print("\n=== ETL AFLUENCIA POR LÍNEA ===")

        try:
            # Fuente principal
            self._procesar_excel_historico()

            # CSVs complementarios 2026
            self._procesar_csv_cbb()
            self._procesar_csv_tl()
            self._procesar_csv_trole()
            self._procesar_csv_rtp()

            # Verificación final
            cur = self.conn.cursor()
            cur.execute("SELECT COUNT(*) FROM plutarco.afluencia_linea")
            total = cur.fetchone()[0]
            cur.execute("""
                SELECT sistema, COUNT(*)
                FROM plutarco.afluencia_linea
                GROUP BY sistema
                ORDER BY sistema
            """)
            por_sistema = cur.fetchall()
            cur.close()

            print(f"\n=== ETL AFLUENCIA FINALIZADO ===")
            print(f"  Total registros: {total}")
            for sistema, conteo in por_sistema:
                print(f"  {sistema}: {conteo}")

        finally:
            self.conn.close()
