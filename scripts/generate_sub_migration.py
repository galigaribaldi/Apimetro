#!/usr/bin/env python3
"""
generate_sub_migration.py
Genera el SQL de migración para ACHECK-01: segmentar el SUB (linea_id=102)
de 2 ramals (línea completa) a 12 ramals (6 segmentos × 2 sentidos).

Fuente de geometría: GTFS local (ETL/Data/stops.txt + ETL/Data/shapes.txt)
Ejecutar desde la raíz del repo:
    python3 scripts/generate_sub_migration.py > db/migrations/v5.0_sub_segmentos.sql

Verifica el SQL generado antes de ejecutarlo en la DB.
"""

import csv
import math
import os

# ─── Configuración ──────────────────────────────────────────────────────────
LINEA_ID   = 102
FUENTE     = ("https://es.wikipedia.org/wiki/"
              "Ferrocarril_Suburbano_de_la_Zona_Metropolitana_del_Valle_de_M%C3%A9xico")

# IDs actuales a eliminar (confirmados en Fase 0)
OLD_RAMAL_IDA    = 224   # sentido=1, nombre "Buenavista"
OLD_RAMAL_REGRESO = 225  # sentido=0, nombre "Cuautitlán"
OLD_HO_IDA       = 1324
OLD_HO_REGRESO   = 1323

# Rutas GTFS
BASE = os.path.join(os.path.dirname(__file__), "..", "ETL", "Data")
STOPS_FILE       = os.path.join(BASE, "stops.txt")
SHAPES_FILE      = os.path.join(BASE, "shapes.txt")
STOP_TIMES_FILE  = os.path.join(BASE, "stop_times.txt")

# Shape IDs del SUB por sentido
SHAPE_IDA    = "B_SH0700L1000_1"   # sentido=1 (Cuautitlán→Buenavista)
SHAPE_REGRESO = "B_SH0700L1000_0"  # sentido=0 (Buenavista→Cuautitlán)

# Trip representativo por sentido (para leer stop_times)
TRIP_IDA     = "B_07100L1000_1"
TRIP_REGRESO = "B_07100L1000_0"


# ─── Lectura GTFS ───────────────────────────────────────────────────────────

def read_stops():
    """Retorna dict {stop_id: {"name": str, "lat": float, "lon": float}}"""
    stops = {}
    with open(STOPS_FILE, newline="", encoding="utf-8") as f:
        for row in csv.DictReader(f):
            if row["stop_id"].startswith("B_0700L1-"):
                stops[row["stop_id"]] = {
                    "name": row["stop_name"].strip(),
                    "lat":  float(row["stop_lat"]),
                    "lon":  float(row["stop_lon"]),
                }
    return stops


def read_shape(shape_id):
    """Retorna lista de (lat, lon) ordenada por shape_pt_sequence."""
    pts = []
    with open(SHAPES_FILE, newline="", encoding="utf-8") as f:
        for row in csv.DictReader(f):
            if row["shape_id"] == shape_id:
                pts.append((int(row["shape_pt_sequence"]),
                             float(row["shape_pt_lat"]),
                             float(row["shape_pt_lon"])))
    pts.sort(key=lambda x: x[0])
    return [(lat, lon) for _, lat, lon in pts]


def read_stop_order(trip_id):
    """Retorna lista de stop_ids en orden de stop_sequence para el trip dado."""
    stops = []
    with open(STOP_TIMES_FILE, newline="", encoding="utf-8") as f:
        for row in csv.DictReader(f):
            if row["trip_id"] == trip_id:
                stops.append((int(row["stop_sequence"]), row["stop_id"]))
    stops.sort(key=lambda x: x[0])
    return [s[1] for s in stops]


# ─── Geometría ──────────────────────────────────────────────────────────────

def haversine_m(lat1, lon1, lat2, lon2):
    """Distancia en metros entre dos puntos WGS84."""
    R = 6_371_000
    phi1, phi2 = math.radians(lat1), math.radians(lat2)
    dphi = math.radians(lat2 - lat1)
    dlam = math.radians(lon2 - lon1)
    a = math.sin(dphi/2)**2 + math.cos(phi1)*math.cos(phi2)*math.sin(dlam/2)**2
    return R * 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))


def closest_shape_index(shape_pts, lat, lon):
    """Índice (0-based) del punto del shape más cercano a (lat, lon)."""
    min_dist = float("inf")
    idx = 0
    for i, (slat, slon) in enumerate(shape_pts):
        d = haversine_m(lat, lon, slat, slon)
        if d < min_dist:
            min_dist = d
            idx = i
    return idx, min_dist


def build_segments(shape_pts, stop_ids, stops):
    """
    Construye 6 segmentos entre estaciones consecutivas.
    Retorna lista de {"from": str, "to": str, "coords": [(lat,lon),...]}
    """
    # Para cada stop, encontrar el índice del shape point más cercano
    split_indices = []
    for sid in stop_ids:
        s = stops[sid]
        idx, dist = closest_shape_index(shape_pts, s["lat"], s["lon"])
        split_indices.append((sid, idx, dist, s["lat"], s["lon"]))

    segments = []
    for i in range(len(split_indices) - 1):
        sid_from, idx_from, dist_from, lat_from, lon_from = split_indices[i]
        sid_to,   idx_to,   dist_to,   lat_to,   lon_to   = split_indices[i+1]

        # Shape points entre las dos estaciones (exclusive los extremos del shape
        # si son el punto exacto de la estación — usamos la coord de la parada)
        middle_pts = shape_pts[idx_from+1 : idx_to]

        # El segmento usa coords exactas de parada como extremos + shape pts intermedios
        coords = [(lat_from, lon_from)] + middle_pts + [(lat_to, lon_to)]

        # Eliminar coordenadas duplicadas consecutivas
        deduped = [coords[0]]
        for pt in coords[1:]:
            if pt != deduped[-1]:
                deduped.append(pt)

        segments.append({
            "from":   stops[sid_from]["name"],
            "to":     stops[sid_to]["name"],
            "coords": deduped,
        })

    return segments


def linestring(coords):
    """Convierte lista de (lat, lon) a WKT MultiLineString para PostGIS (columna geometry(MultiLineString,4326))."""
    pts = ", ".join(f"{lon} {lat}" for lat, lon in coords)
    return f"ST_Multi(ST_GeomFromText('LINESTRING({pts})', 4326))"


# ─── Generador SQL ──────────────────────────────────────────────────────────

def generate_sql(segs_ida, segs_regreso):
    lines = []
    lines.append("-- =====================================================")
    lines.append("-- v5.0_sub_segmentos.sql")
    lines.append("-- ACHECK-01: segmentar Tren Suburbano (linea_id=102)")
    lines.append("-- de 2 ramals (línea completa) a 12 (6 segmentos × 2 sentidos)")
    lines.append("-- Fuente geometría: GTFS local (ETL/Data/)")
    lines.append("-- Generado por scripts/generate_sub_migration.py")
    lines.append("-- =====================================================")
    lines.append("")
    lines.append("BEGIN;")
    lines.append("")

    # 1. INSERT nuevos ramals + historico_operacion en una CTE encadenada
    lines.append("-- ── Paso 1: Insertar 12 nuevos ramals + historico_operacion ──")
    lines.append("")

    # IDA (sentido=1)
    lines.append("-- Sentido 1 — IDA")
    for seg in segs_ida:
        seg_name = f"{seg['from']}-{seg['to']}"
        geom     = linestring(seg["coords"])
        lines.append(f"WITH r AS (")
        lines.append(f"    INSERT INTO ramals (linea_id, nombre_ramal, ramal_num, estado, shape_gtfs, tam_km, anio_creacion, geom)")
        lines.append(f"    VALUES ({LINEA_ID}, '{seg_name}', 1, 'Existe', 'B_SH0700L1000_1', 0.0, 2024, {geom})")
        lines.append(f"    RETURNING id")
        lines.append(f")")
        lines.append(f"INSERT INTO historico_operacion (ramal_id, velocidad_promedio_kmh, fuente, fecha_registro)")
        lines.append(f"SELECT id, 65.0, '{FUENTE}', NOW() FROM r;")
        lines.append("")

    # REGRESO (sentido=0)
    lines.append("-- Sentido 0 — REGRESO")
    for seg in segs_regreso:
        seg_name = f"{seg['from']}-{seg['to']}"
        geom     = linestring(seg["coords"])
        lines.append(f"WITH r AS (")
        lines.append(f"    INSERT INTO ramals (linea_id, nombre_ramal, ramal_num, estado, shape_gtfs, tam_km, anio_creacion, geom)")
        lines.append(f"    VALUES ({LINEA_ID}, '{seg_name}', 0, 'Existe', 'B_SH0700L1000_0', 0.0, 2024, {geom})")
        lines.append(f"    RETURNING id")
        lines.append(f")")
        lines.append(f"INSERT INTO historico_operacion (ramal_id, velocidad_promedio_kmh, fuente, fecha_registro)")
        lines.append(f"SELECT id, 65.0, '{FUENTE}', NOW() FROM r;")
        lines.append("")

    # 2. Eliminar historico_operacion viejo
    lines.append("-- ── Paso 2: Eliminar historico_operacion de ramals originales ──")
    lines.append(f"DELETE FROM historico_operacion WHERE id IN ({OLD_HO_IDA}, {OLD_HO_REGRESO});")
    lines.append("")

    # 3. Eliminar ramals originales
    lines.append("-- ── Paso 3: Eliminar los 2 ramals originales (línea completa) ──")
    lines.append(f"DELETE FROM ramals WHERE id IN ({OLD_RAMAL_IDA}, {OLD_RAMAL_REGRESO});")
    lines.append("")

    # 4. Verificación integrada
    lines.append("-- ── Verificación post-migración (debe mostrar 12 ramals y 12 ho) ──")
    lines.append("SELECT COUNT(*) AS ramals_sub FROM ramals r")
    lines.append("  JOIN lineas l ON r.linea_id = l.id WHERE l.sistema = 'SUB';")
    lines.append("")
    lines.append("SELECT COUNT(*) AS ho_sub FROM historico_operacion ho")
    lines.append("  JOIN ramals r ON ho.ramal_id = r.id")
    lines.append("  JOIN lineas l ON r.linea_id = l.id WHERE l.sistema = 'SUB';")
    lines.append("")
    lines.append("COMMIT;")

    return "\n".join(lines)


# ─── Main ────────────────────────────────────────────────────────────────────

def main():
    stops       = read_stops()
    shape_ida   = read_shape(SHAPE_IDA)
    shape_reg   = read_shape(SHAPE_REGRESO)
    order_ida   = read_stop_order(TRIP_IDA)
    order_reg   = read_stop_order(TRIP_REGRESO)

    segs_ida    = build_segments(shape_ida,   order_ida,  stops)
    segs_reg    = build_segments(shape_reg,   order_reg,  stops)

    # Diagnóstico a stderr para no contaminar el SQL
    import sys
    for label, segs in [("IDA", segs_ida), ("REGRESO", segs_reg)]:
        print(f"\n-- {label}: {len(segs)} segmentos", file=sys.stderr)
        for s in segs:
            pts = len(s["coords"])
            print(f"   {s['from']} → {s['to']}: {pts} puntos", file=sys.stderr)

    print(generate_sql(segs_ida, segs_reg))


if __name__ == "__main__":
    main()
