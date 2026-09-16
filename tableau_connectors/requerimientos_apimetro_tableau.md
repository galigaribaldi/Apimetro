# Apimetro — Integración con Tableau Desktop

Este directorio contiene los archivos necesarios para conectar Tableau Desktop a los endpoints de Apimetro sin instalar drivers adicionales ni exponer la base de datos directamente.

---

## Estructura del directorio

```
tableau_connectors/
  apimetro_wdc.html                   ← Conector WDC (datos tabulares + estaciones)
  requerimientos_apimetro_tableau.md  ← Este archivo
```

---

## Parte 1 — Web Data Connector (WDC) para datos tabulares

### Qué es un WDC

Un Web Data Connector es un archivo HTML+JavaScript que Tableau Desktop carga en su browser embebido (Chromium). La página define esquemas de tablas y funciones de fetch; Tableau las llama en dos momentos:

1. **Fase interactiva**: muestra el formulario al usuario (seleccionar tablas, confirmar URL).
2. **Fase de datos**: Tableau llama `getSchema` para conocer columnas y tipos, luego `getData` para obtener las filas. En esta fase no hay UI visible.

### Prerrequisitos

- Tableau Desktop 2020.4 o superior (soporte WDC 2.0).
- Apimetro corriendo localmente (`make dev` o `make docker-dev`). El servidor responde en `http://localhost:8080`.
- No se requiere ningún driver ni plugin adicional. El CORS de Apimetro ya está configurado con `AllowOrigins: ["*"]`.

### Cómo conectar en Tableau Desktop

1. Abrir Tableau Desktop.
2. En el panel **Conectar** → sección **A un servidor** → seleccionar **Conector de datos web**.
3. En el campo de URL, ingresar la ruta local al archivo WDC:
   ```
   file:///Users/hcabrera/Documents/Personal_Documents/Apimetro/tableau_connectors/apimetro_wdc.html
   ```
4. Tableau abre el formulario del conector. Confirmar la URL base (`http://localhost:8080`) y seleccionar las tablas.
5. Hacer clic en **Obtener datos**. Tableau descarga y tabulariza la respuesta.
6. (Opcional) Crear un extracto `.hyper` para trabajar sin conexión.

### Tablas disponibles en el WDC

#### `afluencia_linea`

Fuente: `GET /movilidad/analitico/afluencia-linea`

| Campo | Tipo Tableau | Descripción |
|-------|-------------|-------------|
| `linea_id` | Int | ID de la línea (`public.lineas.id`) |
| `sistema` | String | CBB, MB, METRO, TL, TROLE |
| `num_comercial` | String | Número comercial de la línea |
| `nombre_linea` | String | Nombre completo |
| `anio` | Int | Año del registro |
| `mes_num` | Int | Mes (1-12) |
| `mes` | String | Nombre del mes |
| `afluencia` | Int | Pasajeros ese mes |
| `fuente` | String | Organismo publicador |

Cobertura actual: 1,197 registros. Sistemas y años disponibles:

| Sistema | Años |
|---------|------|
| CBB | 2021-2026 |
| MB | 2020-2021 |
| METRO | 2020-2021 |
| TL | 2020-2026 |
| TROLE | 2020-2026 |

Filtros disponibles vía query param: `sistema`, `linea_id`, `anio`, `mes_num`.

---

#### `afluencia_estacion`

Fuente: `GET /movilidad/analitico/afluencia-estacion`

| Campo | Tipo Tableau | Descripción |
|-------|-------------|-------------|
| `estacion_id` | Int | ID de la estación (`public.estacions.id`) |
| `nombre_estacion` | String | Nombre de la estación |
| `linea_id` | Int | ID de la línea |
| `num_comercial` | String | Número comercial de la línea (1-12, A, B, L12) |
| `nombre_linea` | String | Nombre completo |
| `anio` | Int | Año del registro |
| `mes_num` | Int | Mes (1-12) |
| `mes` | String | Nombre del mes |
| `afluencia` | Int | Pasajeros ese mes en esa estación |
| `fuente` | String | STC-Metro-DatosAbiertos (CC BY 4.0) |

Cobertura: 38,219 registros. Sistema: Metro CDMX únicamente. Rango temporal: enero 2010 — abril 2026. 195 estaciones, 12 líneas.

Filtros disponibles: `linea_id`, `estacion_id`, `num_comercial`, `nombre_estacion` (búsqueda parcial), `anio`, `mes_num`.

---

#### `estaciones`

Fuente: `GET /movilidad/mapas/geojsonEstacion` (el WDC extrae `geometry.coordinates` como lat/lon)

| Campo | Tipo Tableau | Descripción |
|-------|-------------|-------------|
| `nombre` | String | Nombre de la estación |
| `sistema` | String | METRO, MB, CBB, RTP, TROLE, TL, MEXIBUS, MEXICABLE, INTERURBANO, CC |
| `linea_id` | Int | ID de la línea |
| `num_comercial` | String | Número comercial |
| `tipo` | String | Subterráneo, Superficie, Elevada |
| `alcaldia_municipio` | String | Alcaldía o municipio |
| `jerarquia_transporte` | String | masivo_pesado, masivo_ligero, etc. |
| `es_cetram` | Bool | Si la estación es CETRAM |
| `lat` | Float | Latitud (para mapa en Tableau) |
| `lon` | Float | Longitud (para mapa en Tableau) |

Esta tabla es la que habilita la capa de mapa de puntos en Tableau. Se puede cruzar con `afluencia_estacion` por `nombre` o con `afluencia_linea` por `linea_id`.

### Relaciones entre tablas en Tableau

```
afluencia_estacion ──[ linea_id ]──► afluencia_linea
afluencia_estacion ──[ nombre_estacion / estacion_id ]──► estaciones
afluencia_linea    ──[ linea_id ]──► estaciones
```

Para mapas de calor de afluencia por estación: cruzar `afluencia_estacion` con `estaciones` por `estacion_id` (o `nombre_estacion` como fallback). Tableau usará `lat`/`lon` de `estaciones` para posicionar los puntos y `afluencia` como métrica de color/tamaño.

---

## Parte 2 — Datos espaciales: líneas y polígonos

Los endpoints `/movilidad/mapas/geojsonLinea` y `/movilidad/mapas/geojsonPoligono` devuelven geometrías de tipo `MultiLineString` y `MultiPolygon` respectivamente. Tableau Desktop **no puede recibir estas geometrías a través de un WDC**; las geometrías complejas requieren entrar como **Spatial File** (conector nativo de Tableau).

### Estructura de los GeoJSON

**`geojsonLinea`** — 668 features, tipo `MultiLineString`

Propiedades por feature:
`linea_id`, `sistema`, `nombre_linea`, `nombre_ramal`, `sentido`, `color_esp`, `distancia_metros`, `tam_km`, `capacidad_vehiculo`, `frecuencia_minutos`, `velocidad_promedio_kmh`, `jerarquia_transporte`, `derecho_de_via`, `fuente`

**`geojsonPoligono`** — 553 features, tipo `MultiPolygon`

Propiedades por feature:
`cvegeo`, `entidad`, `nivel`, `nombre`, `tipo_entidad`

### Opción A — Exportar a archivo estático (solución inmediata)

Descargar el GeoJSON desde el endpoint y guardarlo como archivo local. Tableau lo carga como **Spatial File**:

```bash
# Descargar líneas
curl http://localhost:8080/movilidad/mapas/geojsonLinea \
  -o tableau_connectors/exports/lineas_transporte.geojson

# Descargar polígonos
curl http://localhost:8080/movilidad/mapas/geojsonPoligono \
  -o tableau_connectors/exports/poligonos_territoriales.geojson
```

En Tableau Desktop: **Conectar → Archivo espacial** → seleccionar el `.geojson`.

Limitación: los archivos quedan estáticos. Si Apimetro actualiza los datos, hay que volver a descargarlos.

---

### Opción B — Mini servidor proxy en Python (solución dinámica)

Para mantener los archivos espaciales sincronizados con Apimetro sin descarga manual, se puede levantar un servidor ligero en Python que actúe de proxy: Tableau llama al servidor, el servidor llama a Apimetro y devuelve el GeoJSON.

Este servidor viviría en `tableau_connectors/geo_proxy/` dentro de este mismo repositorio.

#### Diseño propuesto con FastAPI

```
tableau_connectors/
  geo_proxy/
    main.py           ← servidor FastAPI, 3 endpoints
    requirements.txt  ← fastapi, uvicorn, httpx
    README.md
```

**`main.py` — estructura**

```python
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import Response
import httpx

APIMETRO_BASE = "http://localhost:8080"

app = FastAPI(title="Apimetro GeoProxy")
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_methods=["GET"])

@app.get("/lineas.geojson")
async def lineas(sistema: str = ""):
    params = {"sistema": sistema} if sistema else {}
    async with httpx.AsyncClient() as client:
        r = await client.get(f"{APIMETRO_BASE}/movilidad/mapas/geojsonLinea", params=params)
    return Response(content=r.content, media_type="application/geo+json")

@app.get("/poligonos.geojson")
async def poligonos():
    async with httpx.AsyncClient() as client:
        r = await client.get(f"{APIMETRO_BASE}/movilidad/mapas/geojsonPoligono")
    return Response(content=r.content, media_type="application/geo+json")

@app.get("/estaciones.geojson")
async def estaciones(sistema: str = ""):
    params = {"sistema": sistema} if sistema else {}
    async with httpx.AsyncClient() as client:
        r = await client.get(f"{APIMETRO_BASE}/movilidad/mapas/geojsonEstacion", params=params)
    return Response(content=r.content, media_type="application/geo+json")
```

**Cómo arrancarlo**

```bash
cd tableau_connectors/geo_proxy
pip install fastapi uvicorn httpx
uvicorn main:app --port 5050
```

**Cómo conectar en Tableau Desktop**

1. **Conectar → Archivo espacial**.
2. Escribir la URL del proxy como si fuera un archivo web:
   ```
   http://localhost:5050/lineas.geojson
   http://localhost:5050/poligonos.geojson
   ```
3. Tableau descarga el GeoJSON y crea una fuente espacial. Si se hace un extracto `.hyper`, las geometrías quedan guardadas localmente para trabajar sin conexión.

#### Alternativa con Flask (más simple, sin async)

```python
from flask import Flask, Response
from flask_cors import CORS
import requests

APIMETRO_BASE = "http://localhost:8080"

app = Flask(__name__)
CORS(app)

@app.route("/lineas.geojson")
def lineas():
    r = requests.get(f"{APIMETRO_BASE}/movilidad/mapas/geojsonLinea")
    return Response(r.content, mimetype="application/geo+json")

@app.route("/poligonos.geojson")
def poligonos():
    r = requests.get(f"{APIMETRO_BASE}/movilidad/mapas/geojsonPoligono")
    return Response(r.content, mimetype="application/geo+json")

if __name__ == "__main__":
    app.run(port=5050)
```

```bash
pip install flask flask-cors requests
python main.py
```

#### Cuándo usar cada opción

| Criterio | Opción A (archivo estático) | Opción B (proxy) |
|---|---|---|
| Datos que cambian poco | ✓ suficiente | innecesario |
| Datos que se actualizan seguido | requiere re-descargar | siempre fresco |
| Sin servidor corriendo | ✓ funciona | requiere proxy arriba |
| Tableau Server / Public | ✓ sube el archivo | requiere túnel o servidor público |

Para el uso de tesis (datos estables, sesiones de trabajo puntuales) la **Opción A** es suficiente. La **Opción B** tiene sentido si se automatiza el pipeline o se trabaja con datos que se actualizan mensualmente.

---

## Resumen de puertos

| Servicio | Puerto | Estado requerido |
|---|---|---|
| Apimetro API | 8080 | Siempre (para WDC y proxy) |
| Apimetro DB | 5433 | Siempre (para Apimetro) |
| GeoProxy (opcional) | 5050 | Solo para Opción B |
