# -*- coding: utf-8 -*-
"""
LoadAfluenciaEstacion.py — ETL: Afluencia mensual por estación (Metro) → plutarco.afluencia_estacion
Issue: #45

Fuente:
  CSV descargado de datos.cdmx.gob.mx — "Afluencia Diaria del Metro (Simple)"
  URL: https://datos.cdmx.gob.mx/dataset/afluencia-diaria-del-metro-cdmx
  Encoding: Latin-1
  Columnas: fecha, anio, mes, linea, estacion, afluencia

Prerequisitos:
  1. Tabla creada: db/migrations/v3.0_afluencia_estacion.sql
  2. Estaciones del Metro en public.estacions (195 registros)

Idempotencia: ON CONFLICT (estacion_id, anio, mes_num) DO NOTHING — seguro re-ejecutar.
"""
import psycopg2
import pandas as pd
import unicodedata
import re
import os
from conf import host, database, user, password, port

DATA_DIR = "Data/Pesos"
CSV_FILE = "afluenciastc_simple_04_2026.csv"
CSV_URL = "https://datos.cdmx.gob.mx/dataset/f2046fd5-51b5-4876-b008-bd65d95f9a02/resource/0e8ffe58-28bb-4dde-afcd-e5f5b4de4ccb/download/afluenciastc_simple_04_2026.csv"

MESES = {
    1: "Enero", 2: "Febrero", 3: "Marzo", 4: "Abril",
    5: "Mayo", 6: "Junio", 7: "Julio", 8: "Agosto",
    9: "Septiembre", 10: "Octubre", 11: "Noviembre", 12: "Diciembre",
}

MES_A_NUM = {v: k for k, v in MESES.items()}

# Mapeo manual para las 11 estaciones que no coinciden directamente
NORMALIZACION_ESTACION = {
    "Gómez Farias": "Gómez Farías",
    "Peñón viejo": "Peñón Viejo",
    "Niños Héroes": "Niños Héroes y Poder Judicial CDMX",
}


def _nfc(texto: str) -> str:
    if not isinstance(texto, str):
        return str(texto).strip()
    return unicodedata.normalize("NFC", texto.strip())


def _fix_latin1(texto: str) -> str:
    """Decodifica mojibake Latin-1 → UTF-8 (soporta doble mojibake)."""
    result = texto
    for _ in range(3):
        try:
            decoded = result.encode('latin-1').decode('utf-8')
            if decoded == result:
                break
            result = decoded
        except (UnicodeDecodeError, UnicodeEncodeError):
            break
    return result


def _normalizar_estacion(nombre: str) -> str:
    """Normaliza nombre de estación del CSV para match con BD."""
    nombre = _nfc(_fix_latin1(nombre))

    # Regla 1: lookup directo en tabla de excepciones
    if nombre in NORMALIZACION_ESTACION:
        return NORMALIZACION_ESTACION[nombre]

    # Regla 2: "/" → " y " (pero Zócalo/Tenochtitlan → solo "Zócalo")
    if "/" in nombre:
        partes = nombre.split("/")
        # Caso especial: Zócalo/Tenochtitlan → Zócalo
        if partes[0].strip() == "Zócalo":
            return "Zócalo"
        # Caso especial: Niños Héroes no necesita "/" pero tampoco lo tiene
        return " y ".join(p.strip() for p in partes)

    # Regla 3: UAM-Azcapotzalco → UAM Azcapotzalco (pero UAM-I se queda)
    if nombre == "UAM-Azcapotzalco":
        return "UAM Azcapotzalco"

    return nombre


def _normalizar_linea(linea_csv: str) -> str:
    """Extrae num_comercial de 'Línea 1'/'Linea 1'/'LÃ­nea 1' → '1', '12' → 'L12'.
    Usa regex para ser robusto ante cualquier variante de mojibake."""
    texto = linea_csv.strip()
    match = re.search(r'(\d+|[A-B])$', texto, re.IGNORECASE)
    if match:
        num = match.group(1).upper()
        if num == "12":
            num = "L12"
        return num
    # Fallback
    linea = _nfc(_fix_latin1(texto))
    num = linea.replace("Línea ", "").replace("Linea ", "").strip()
    if num == "12":
        num = "L12"
    return num


class AfluenciaEstacionETL:

    def __init__(self):
        self.conn = psycopg2.connect(
            host=host, dbname=database, user=user, password=password, port=port
        )
        self._estaciones = None

    def _cargar_estaciones(self) -> dict:
        """Carga estaciones Metro de la BD como dict: (nombre, num_comercial) → (estacion_id, linea_id)."""
        if self._estaciones is not None:
            return self._estaciones

        cur = self.conn.cursor()
        cur.execute("""
            SELECT e.id, e.nombre, e.linea_id, l.num_comercial
            FROM public.estacions e
            JOIN public.lineas l ON l.id = e.linea_id
            WHERE e.sistema = 'METRO' AND e.existe = true
        """)
        self._estaciones = {}
        for eid, nombre, linea_id, num_com in cur.fetchall():
            self._estaciones[(_nfc(nombre), num_com)] = (eid, linea_id)
        cur.close()

        print(f"  Estaciones BD cargadas: {len(self._estaciones)} (Metro)")
        return self._estaciones

    def _resolver_estacion(self, nombre_csv: str, num_comercial: str):
        """Busca (estacion_id, linea_id) en la BD. Retorna None si no hay match."""
        estaciones = self._cargar_estaciones()
        nombre_norm = _normalizar_estacion(nombre_csv)
        return estaciones.get((nombre_norm, num_comercial))

    def _insertar_filas(self, filas: list):
        """Inserta filas en plutarco.afluencia_estacion."""
        cur = self.conn.cursor()

        sql = """
            INSERT INTO plutarco.afluencia_estacion
                (estacion_id, linea_id, anio, mes_num, mes, afluencia, fuente)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
            ON CONFLICT (estacion_id, anio, mes_num) DO NOTHING
        """

        BATCH = 500
        insertados = 0
        for i in range(0, len(filas), BATCH):
            lote = filas[i: i + BATCH]
            for fila in lote:
                cur.execute(sql, fila)
            self.conn.commit()
            insertados += len(lote)

        cur.close()
        return insertados

    def procesar(self):
        """Proceso principal: leer CSV, agregar a mensual, insertar."""
        ruta = os.path.join(DATA_DIR, CSV_FILE)

        if not os.path.exists(ruta):
            print(f"\n  ARCHIVO NO ENCONTRADO: {ruta}")
            print(f"  Descargar manualmente desde:")
            print(f"  {CSV_URL}")
            print(f"  y guardarlo como {ruta}")
            return

        print(f"\n{'='*60}")
        print(f"  ETL Afluencia por Estación — Metro CDMX")
        print(f"  Fuente: {ruta}")
        print(f"{'='*60}")

        # Leer CSV (encoding Latin-1)
        print("\n  [1/4] Leyendo CSV...")
        df = pd.read_csv(ruta, encoding='latin-1')
        print(f"        {len(df):,} filas leídas")

        # Normalizar columnas
        df.columns = [c.strip().lower() for c in df.columns]

        # Derivar mes_num desde la columna 'mes' (texto)
        df['mes_norm'] = df['mes'].apply(lambda m: _nfc(_fix_latin1(str(m))))
        df['mes_num'] = df['mes_norm'].map(MES_A_NUM)

        sin_mes = df['mes_num'].isna().sum()
        if sin_mes > 0:
            print(f"        ⚠ {sin_mes} filas sin mes válido — descartadas")
            df = df.dropna(subset=['mes_num'])
        df['mes_num'] = df['mes_num'].astype(int)
        df['anio'] = df['anio'].astype(int)

        # Agregar a nivel mensual: suma por estación + línea + año + mes
        print("\n  [2/4] Agregando a nivel mensual...")
        df['afluencia'] = pd.to_numeric(df['afluencia'], errors='coerce').fillna(0).astype(int)
        mensual = df.groupby(['linea', 'estacion', 'anio', 'mes_num'], as_index=False).agg(
            afluencia=('afluencia', 'sum'),
            mes=('mes_norm', 'first'),
        )
        print(f"        {len(mensual):,} registros mensuales")

        # Resolver estacion_id y linea_id
        print("\n  [3/4] Resolviendo estaciones...")
        filas = []
        sin_match = set()

        for _, row in mensual.iterrows():
            num_comercial = _normalizar_linea(row['linea'])
            resultado = self._resolver_estacion(row['estacion'], num_comercial)

            if resultado is None:
                nombre_norm = _normalizar_estacion(_nfc(_fix_latin1(row['estacion'])))
                key = (nombre_norm, num_comercial)
                if key not in sin_match:
                    sin_match.add(key)
                    print(f"        ✗ Sin match: '{row['estacion']}' (Línea {num_comercial}) → normalizado: '{nombre_norm}'")
                continue

            estacion_id, linea_id = resultado
            filas.append((
                estacion_id,
                linea_id,
                int(row['anio']),
                int(row['mes_num']),
                row['mes'],
                int(row['afluencia']),
                'STC-Metro-DatosAbiertos',
            ))

        if sin_match:
            print(f"\n        ⚠ {len(sin_match)} estaciones sin match (filas descartadas)")

        # Insertar
        print(f"\n  [4/4] Insertando {len(filas):,} registros...")
        insertados = self._insertar_filas(filas)
        print(f"        ✓ {insertados:,} registros procesados (ON CONFLICT DO NOTHING)")

        # Resumen
        cur = self.conn.cursor()
        cur.execute("SELECT COUNT(*), SUM(afluencia) FROM plutarco.afluencia_estacion")
        total, suma = cur.fetchone()
        cur.close()

        print(f"\n  RESUMEN FINAL:")
        print(f"    Total en tabla: {total:,} registros")
        print(f"    Afluencia acumulada: {suma:,} viajes")
        print(f"{'='*60}\n")

    def cerrar(self):
        self.conn.close()


def run():
    etl = AfluenciaEstacionETL()
    try:
        etl.procesar()
    finally:
        etl.cerrar()


if __name__ == "__main__":
    run()
