# Extensión Plutarco — Guía de Activación

La extensión **Plutarco** agrega endpoints analíticos al API de Apimetro. Incluye datos geoespaciales del INEGI y series temporales de afluencia del transporte público para alimentar el motor VFT (Valor de Flujo de Transporte).

## Endpoints de la extensión

| Endpoint | Datos | Registros |
|----------|-------|-----------|
| `GET /movilidad/analitico/agebs` | AGEBs urbanas + Censo 2020 (GeoJSON) | 11,787 |
| `GET /movilidad/analitico/afluencia-linea` | Afluencia mensual por línea (5 sistemas) | 1,197 |
| `GET /movilidad/analitico/afluencia-estacion` | Afluencia mensual por estación Metro | 38,219 |

## Prerequisitos

- Docker DEV corriendo (`make docker-dev`)
- Python 3.10+
- Archivos fuente (CSVs y shapefiles) — ver sección "Datos fuente"

## Activación rápida

```bash
# 1. Verificar estado actual
make plutarco-status

# 2. Activación completa (deps + migraciones + ETL)
make plutarco-setup
```

## Activación paso a paso

### Paso 1: Instalar dependencias Python

```bash
pip install -r ETL/requirements.txt
```

Dependencias: `pandas`, `psycopg2-binary`, `geopandas`, `shapely`, `pyogrio`.

### Paso 2: Obtener datos fuente

Los datos no se incluyen en el repositorio (`.gitignore`). Descárgalos manualmente:

#### Afluencia por línea (5 sistemas)

| Archivo | Fuente | Ubicación |
|---------|--------|-----------|
| `afluencia_diaria_historica.xlsx` | SEMOVI (solicitud directa) | `ETL/Data/Pesos/` |
| `afluencia_desglosada_cb_03_2026.csv` | datos.cdmx.gob.mx | `ETL/Data/Pesos/` |
| `afluencia_desglosada_tl_03_2026.csv` | datos.cdmx.gob.mx | `ETL/Data/Pesos/` |
| `afluencia_desglosada_trolebus_03_2026.csv` | datos.cdmx.gob.mx | `ETL/Data/Pesos/` |
| `afluencia_desglosada_acumulada_2024_07.csv` | datos.cdmx.gob.mx | `ETL/Data/Pesos/` |

#### Afluencia por estación (Metro)

| Archivo | Fuente | Ubicación |
|---------|--------|-----------|
| `afluenciastc_simple_04_2026.csv` | [datos.cdmx.gob.mx — Afluencia Diaria del Metro](https://datos.cdmx.gob.mx/dataset/afluencia-diaria-del-metro-cdmx) | `ETL/Data/Pesos/` |

#### AGEBs urbanas (6 estados)

| Archivo | Fuente | Ubicación |
|---------|--------|-----------|
| `*a.shp` (shapefiles AGEB) | [INEGI Marco Geoestadístico](https://www.inegi.org.mx/temas/mg/) | `ETL/Data/AGEBS/` |

Descargar shapefiles de entidades: 09 (CDMX), 15 (EdoMex), 17 (Morelos), 21 (Puebla), 22 (Querétaro), 29 (Tlaxcala).

### Paso 3: Ejecutar migraciones DDL

Si es una instalación fresca con Docker, las tablas se crean automáticamente via `02_init_plutarco.sql`. Para entornos existentes:

```bash
# Aplicar migración de afluencia por línea
docker exec apimetro_db_dev psql -U admin_apimetro -d db_apimetro \
    -f /docker-entrypoint-initdb.d/02_init_plutarco.sql

# Cargar catálogo de homologación
docker cp db/migrations/seed_catalogo_homologacion.sql apimetro_db_dev:/tmp/seed_cat.sql
docker exec apimetro_db_dev psql -U admin_apimetro -d db_apimetro -f /tmp/seed_cat.sql
```

### Paso 4: Ejecutar ETLs

```bash
cd ETL

# Afluencia por línea (METRO, MB, CBB, TL, TROLE)
DB_HOST=localhost DB_PORT=5433 python3 -c "from DataCharge import LoadAfluencia; LoadAfluencia.run()"

# Afluencia por estación (solo Metro)
DB_HOST=localhost DB_PORT=5433 python3 -c "from DataCharge import LoadAfluenciaEstacion; LoadAfluenciaEstacion.run()"

# AGEBs (requiere shapefiles)
DB_HOST=localhost DB_PORT=5433 python3 -c "from DataCharge import LoadAgebs; LoadAgebs.run()"
```

### Paso 5: Verificar

```bash
# Status de tablas
make plutarco-status

# Probar endpoints
curl http://localhost:8080/movilidad/analitico/afluencia-estacion?num_comercial=1&anio=2024&mes_num=1
curl http://localhost:8080/movilidad/analitico/afluencia-linea?sistema=METRO
curl "http://localhost:8080/movilidad/analitico/agebs?entidad=09&limit=5"
```

## Comandos Make disponibles

| Comando | Descripción |
|---------|-------------|
| `make plutarco-status` | Ver conteo de registros por tabla |
| `make plutarco-setup` | Activación completa (deps + DDL + ETL) |
| `make plutarco-deps` | Solo instalar dependencias Python |
| `make plutarco-etl` | Solo ejecutar ETLs (asume deps y DDL listos) |

## Comportamiento sin activación

Si la extensión no está activada (tablas vacías), los endpoints retornan HTTP 503 con:

```json
{
  "extension": "plutarco",
  "activacion_requerida": true,
  "mensaje": "Este endpoint requiere activar la extensión Plutarco.",
  "guia": "Ejecuta 'make plutarco-setup' o consulta docs/PLUTARCO_EXTENSION.md",
  "repositorio": "https://github.com/galigaribaldi/Apimetro/blob/main/docs/PLUTARCO_EXTENSION.md"
}
```

Los endpoints base de la API (`/movilidad/:sistema/linea`, mapas GeoJSON, etc.) funcionan sin la extensión.

## Arquitectura

```
Capa 3: DATOS ──── ETL Python carga CSVs/shapefiles a plutarco.*
Capa 2: API ────── Endpoints Go siempre compilados, disclaimer si vacío
Capa 1: DB ─────── DDL se ejecuta en Docker init (tablas vacías por defecto)
```

## Tablas del esquema plutarco

| Tabla | Descripción | ETL |
|-------|-------------|-----|
| `agebs` | AGEBs urbanas + Censo 2020 | `LoadAgebs.py` |
| `afluencia_linea` | Afluencia mensual por línea | `LoadAfluencia.py` |
| `afluencia_estacion` | Afluencia mensual por estación Metro | `LoadAfluenciaEstacion.py` |
| `catalogo_homologacion` | Mapeo nombres CSV a linea_id | seed SQL |
| `calles` | Red vial (parcial, solo CDMX) | `LoadPlutarcoGeo.py` |
| `uso_suelo` | Uso de suelo (datos 1993, obsoletos) | `LoadPlutarcoGeo.py` |
| `curvas_nivel` | Curvas de nivel (parcial) | `LoadPlutarcoGeo.py` |

## Filtros por endpoint

### `/analitico/afluencia-estacion`

| Param | Tipo | Descripción |
|-------|------|-------------|
| `linea_id` | int | ID interno de la línea |
| `num_comercial` | string | Numero comercial: 1, 2, 3, A, B, L12 |
| `estacion_id` | int | ID interno de la estación |
| `nombre_estacion` | string | Busqueda parcial ILIKE |
| `anio` | int | Ano (2010-2026) |
| `mes_num` | int | Mes numerico (1-12) |

### `/analitico/afluencia-linea`

| Param | Tipo | Descripción |
|-------|------|-------------|
| `sistema` | string | METRO, MB, CBB, TL, TROLE |
| `linea_id` | int | ID interno de la línea |
| `anio` | int | Ano |
| `mes_num` | int | Mes numerico (1-12) |

### `/analitico/agebs`

| Param | Tipo | Descripción |
|-------|------|-------------|
| `entidad` | string | Clave 2 digitos (09, 15, 17, 21, 22, 29) |
| `municipio_alcaldia` | string | Busqueda parcial ILIKE |
| `limit` | int | Maximo resultados (default 500) |
| `offset` | int | Paginacion |
