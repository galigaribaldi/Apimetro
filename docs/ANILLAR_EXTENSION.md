# Extensión Anillo Periférico Interior

**Fecha:** 2026-09-16 | **Actualizado:** 2026-09-18
**Estado:** Validado y funcionando
**Rama:** `feat/propuesta-anillar` (no se mergea a DEV ni a main)
**Clasificación de datos:** `propuesta_periferico`

---

## Descripción

Propuesta académica que modela el Anillo Periférico Interior de la ZMVM como sistema de transporte masivo. Se generan 2 escenarios aislados para análisis comparativo con VFTModel (indicadores topológicos: SCC, T, B, k_in, DI, C).

Cada escenario levanta una **copia completa de la red real** más las 4 líneas del Anillo Periférico Interior inyectadas como datos adicionales. Esto permite a VFTModel evaluar el impacto del anillo sobre la red existente.

> **IMPORTANTE:** Esta rama NO debe mergearse a DEV ni a main. Los datos del anillo son hipotéticos y contaminarían la red real. La rama se mantiene aislada para uso exclusivo de VFTModel.

---

## Arquitectura de simulación

Apimetro expone 3 entornos Docker independientes que pueden correr simultáneamente. Cada uno tiene su propia base de datos, volumen, red y puertos:

| Entorno | Contenido | Comando | API | DB |
|---------|-----------|---------|-----|-----|
| **DEV (baseline)** | Red real | `make docker-dev` | `:8080` | `:5433` |
| **Escenario MB** | Red real + anillo como BRT | `make docker-dev-scenario-mb` | `:8083` | `:5436` |
| **Escenario METRO** | Red real + anillo como Metro | `make docker-dev-scenario-metro` | `:8084` | `:5437` |

### Aislamiento

Cada entorno usa recursos Docker dedicados:

| Recurso | DEV | Escenario MB | Escenario METRO |
|---------|-----|-------------|-----------------|
| Contenedor DB | `apimetro_db_dev` | `apimetro_db_scenario_mb` | `apimetro_db_scenario_metro` |
| Contenedor API | `apimetro_api_dev` | `apimetro_api_scenario_mb` | `apimetro_api_scenario_metro` |
| Volumen | `pgdata_dev` | `pgdata_scenario_mb` | `pgdata_scenario_metro` |
| Red | `apimetro_net_dev` | `apimetro_net_scenario_mb` | `apimetro_net_scenario_metro` |
| Perfil Docker | `dev` | `scenario-mb` | `scenario-metro` |

Los datos de un escenario **nunca** aparecen en otro. Verificado: consultar `sistema=METRO` en el escenario MB devuelve 0 resultados, y viceversa.

---

## Flujo de trabajo para VFTModel

El análisis comparativo requiere correr VFTModel contra los 3 entornos:

```
1. make docker-dev                  → Baseline (red sin anillo)
2. make docker-dev-scenario-mb      → Red + anillo como BRT
3. make docker-dev-scenario-metro   → Red + anillo como Metro
4. Comparar indicadores topológicos entre los 3 resultados
```

### Conexión desde VFTModel

```bash
# Baseline (red real)
APIMETRO_URL=http://localhost:8080/movilidad

# Escenario MB (BRT)
APIMETRO_URL=http://localhost:8083/movilidad

# Escenario METRO
APIMETRO_URL=http://localhost:8084/movilidad
```

### Endpoints disponibles por escenario

```bash
# Estaciones en GeoJSON (puntos)
GET /movilidad/mapas/geojsonEstacion?sistema=MB
GET /movilidad/mapas/geojsonEstacion?sistema=METRO

# Líneas/ramales en GeoJSON (MultiLineString) con métricas operativas
GET /movilidad/mapas/geojsonLinea?sistema=MB
GET /movilidad/mapas/geojsonLinea?sistema=METRO
```

---

## Procedimiento técnico

### Pre-requisitos

- Docker y docker-compose instalados
- Archivos `.env.dev` en `~/.SecretsFiles/` (mismos que el entorno DEV)
- Estar en la rama `feat/propuesta-anillar`
- **Seed de datos (`04_seed.sql`) en `db/init/`** — ver sección siguiente

### Obtener el seed de la red real

El archivo `db/init/04_seed.sql` contiene el dump de la red de transporte real (~37 MB: estaciones, líneas, ramales, históricos). **No está en el repositorio** (gitignoreado por peso).

Sin este archivo, los escenarios levantan con tablas vacías y el anillo se inserta sin red real de fondo — lo cual invalida el análisis comparativo con VFTModel.

**Opciones para obtenerlo:**

1. **Solicitar al equipo Apimetro** — Pedir el archivo directamente (medio privado: Drive, SCP, etc.)
2. **Generarlo desde una instancia local** — Si ya tienes una DB Apimetro con datos:
   ```bash
   # Genera el dump y lo deja en db/init/04_seed.sql
   PGPASSWORD=postgres pg_dump \
     --data-only --inserts --disable-triggers \
     -t lineas -t ramals -t estacions \
     -t descripcion_lineas -t descripcion_estacions \
     -t historico_operacion -t limites_territoriales \
     -h localhost -p 5432 -U prueba db_apimetro \
     > db/init/04_seed.sql
   ```

**Conteos esperados en el seed:**

| Tabla | Registros |
|-------|-----------|
| estacions | 22,878 |
| ramals | 693 |
| historico_operacion | 690 |
| limites_territoriales | 553 |
| lineas | 317 |

### Levantar un escenario

Los comandos funcionan igual que `make docker-dev`: levantan los contenedores, cargan la data automáticamente y se quedan en primer plano mostrando logs.

```bash
# Terminal 1 — Escenario MB
make docker-dev-scenario-mb

# Terminal 2 — Escenario METRO
make docker-dev-scenario-metro
```

La migración del anillo (`v4.0_anillar_*.sql`) se monta como volumen en `/docker-entrypoint-initdb.d/05_anillar.sql` y se ejecuta automáticamente al inicializar la base de datos. No se requiere ningún paso adicional de carga.

### Verificar datos cargados

```bash
# Conteos del anillo en escenario MB
make anillar-status CONTAINER=apimetro_db_scenario_mb

# Conteos del anillo en escenario METRO
make anillar-status CONTAINER=apimetro_db_scenario_metro
```

Resultado esperado:
```
    tabla     | count
--------------+-------
 lineas       |     4
 estacions    |    98
 ramals       |     8
 historico_op |     8
```

### Verificar endpoints

```bash
# Estaciones MB — debe devolver 98
curl -s "localhost:8083/movilidad/mapas/geojsonEstacion?sistema=MB" | jq '.features | length'

# Líneas MB — debe devolver 8 (4 líneas x 2 sentidos)
curl -s "localhost:8083/movilidad/mapas/geojsonLinea?sistema=MB" | jq '.features | length'

# Estaciones METRO — debe devolver 98
curl -s "localhost:8084/movilidad/mapas/geojsonEstacion?sistema=METRO" | jq '.features | length'

# Líneas METRO — debe devolver 8
curl -s "localhost:8084/movilidad/mapas/geojsonLinea?sistema=METRO" | jq '.features | length'
```

### Verificar aislamiento

```bash
# No debe haber datos METRO en el escenario MB (esperado: 0)
curl -s "localhost:8083/movilidad/mapas/geojsonEstacion?sistema=METRO" | jq '.features | length'

# No debe haber datos MB en el escenario METRO (esperado: 0)
curl -s "localhost:8084/movilidad/mapas/geojsonEstacion?sistema=MB" | jq '.features | length'
```

### Bajar y limpiar

```bash
# Bajar escenario MB (incluye borrado de volúmenes)
make docker-down-scenario-mb

# Bajar escenario METRO (incluye borrado de volúmenes)
make docker-down-scenario-metro

# Limpiar datos del anillo sin bajar contenedores
make anillar-cleanup CONTAINER=apimetro_db_scenario_mb
make anillar-cleanup CONTAINER=apimetro_db_scenario_metro
```

> **Nota:** `docker-down-scenario-*` borra los volúmenes (`-v`). La próxima vez que levantes el escenario, la DB se reinicializa desde cero con seed + migración del anillo.

---

## Estructura de datos

### 4 Líneas (por escenario)

| Línea | Nombre | Estaciones | Dirección |
|-------|--------|-----------|-----------|
| Sur (AP71) | Periférico Interior Sur | 25 | Oriente → Poniente |
| Poniente (AP72) | Periférico Interior Poniente | 31 | Sur → Norte |
| Norte (AP73) | Periférico Interior Norte | 24 | Poniente → Oriente |
| Oriente (AP74) | Periférico Interior Oriente | 18 | Norte → Sur |

**Total: 98 estaciones, 8 ramales (ida + regreso), 8 registros históricos por escenario.**

### Conectividad del anillo

Las 4 líneas forman un anillo cerrado. La última estación de cada línea comparte coordenadas exactas con la primera estación de la siguiente:

```
L71 Sur ──→ Luis Cabrera ════ Luis Cabrera ──→ L72 Poniente
L72 Poniente ──→ Parque Naucalli ══════ Parque Naucalli ──→ L73 Norte
L73 Norte ──→ Colonias de Aragón ══════ Colonias de Aragón ──→ L74 Oriente
L74 Oriente ──→ Periférico Oriente/Tláhuac ══════ Periférico Oriente/Tláhuac ──→ L71 Sur
```

VFTModel usa `node_id = (lon, lat)`, por lo que coordenadas idénticas generan un nodo compartido (transbordo implícito).

### IDs y rangos

| Elemento | Escenario MB | Escenario METRO |
|----------|-------------|-----------------|
| Líneas (lineas.id) | 2071-2074 | 3071-3074 |
| Estaciones (estacions.id) | 20001-20098 | 30001-30098 |
| estacion_id_oficial | 20001-20098 | 30001-30098 |
| num_comercial | AP71-AP74 | AP71-AP74 |

Los rangos están lejos del máximo actual (linea=991, estacion=1612) para evitar colisiones con datos reales.

### Parámetros operativos

| Propiedad | MB (BRT) | METRO |
|-----------|----------|-------|
| jerarquia_transporte | masivo_mediano | masivo_pesado |
| derecho_de_via | confinado | exclusivo |
| velocidad_promedio_kmh | 16.3 | 36.0 |
| frecuencia_minutos | 5.0 | 3.0 |
| capacidad_vehiculo | 160 | 1000 |
| Fricción VFTModel (CF, alpha) | 1.152 (0.2) | 1.0 (0.0) |

### Campos GeoJSON expuestos

**Estaciones** (`geojsonEstacion`):
```json
{
  "alcaldia_municipio": "Benito Juárez",
  "es_cetram": false,
  "jerarquia_transporte": "masivo_mediano",
  "linea_id": 2072,
  "nombre": "11 de Abril",
  "nombre_cetram": null,
  "num_comercial": "AP72",
  "sistema": "MB",
  "tipo": "Intermedia",
  "tipo_entidad": "estacion"
}
```

**Líneas** (`geojsonLinea`):
```json
{
  "capacidad_vehiculo": 160,
  "color_esp": "NARANJA",
  "derecho_de_via": "confinado",
  "distancia_metros": 18846.04,
  "frecuencia_minutos": 5,
  "fuente": "Propuesta académica Anillo Periférico Interior 2026",
  "jerarquia_transporte": "masivo_mediano",
  "linea_id": 2071,
  "nombre_linea": "Periférico Interior Sur",
  "nombre_ramal": "Periférico Interior Sur - IDA",
  "sentido": 1,
  "sistema": "MB",
  "tam_km": 0,
  "tipo_entidad": "ruta",
  "velocidad_promedio_kmh": 16.3
}
```

---

## Resultados de validación (2026-09-18)

| Verificación | MB (:8083) | METRO (:8084) |
|--|--|--|
| Estaciones | 98 | 98 |
| Líneas/Ramales | 8 | 8 |
| jerarquia_transporte | masivo_mediano | masivo_pesado |
| derecho_de_via | confinado | exclusivo |
| velocidad_promedio_kmh | 16.3 | 36.0 |
| frecuencia_minutos | 5 | 3 |
| capacidad_vehiculo | 160 | 1000 |
| Aislamiento (datos cruzados) | 0 METRO | 0 MB |

---

## Decisiones técnicas

1. **No se crea sistema nuevo** — Se reutilizan `MB` y `METRO` del middleware existente para evitar cambios de código Go
2. **IDs en rangos altos** — 2xxxx (MB) y 3xxxx (METRO), lejos del max actual (1612)
3. **`clasificacion = 'propuesta_periferico'`** — Permite filtrar/excluir sin tocar endpoints
4. **Estaciones puente con coords idénticas** — VFTModel interpreta coords iguales como nodo compartido
5. **2 ramales por línea (ida + regreso)** — VFTModel usa DiGraph; sin ambos sentidos los caminos mínimos fallan
6. **ST_MakeLine desde puntos de estación** — Cumple tolerancia de snap 50m por definición
7. **historico_operacion obligatorio** — Sin él, velocidad/frecuencia llegan como `null` al GeoJSON
8. **Migración montada como volumen Docker** — Se ejecuta automáticamente al inicializar la DB, sin pasos manuales
9. **Rama aislada** — `feat/propuesta-anillar` no se mergea a DEV/main para no contaminar la red real

---

## Archivos de este feature

```
db/migrations/
  v4.0_anillar_mb.sql               <- Migración escenario MB (118 INSERTs idempotentes)
  v4.0_anillar_metro.sql            <- Migración escenario METRO (118 INSERTs idempotentes)
ETL/Data/Anillar/
  estaciones_periferico_interior.csv <- CSV maestro (98 estaciones, alcaldías corregidas)
scripts/
  anillar_cleanup.sql               <- Rollback (DELETE por rango de IDs)
docs/
  ANILLAR_EXTENSION.md              <- Esta guía
  NOTAS_REPLICABILIDAD_PROPUESTA.md <- Notas técnicas de VFTModel
  TRACKING_ANILLAR_PERIFERICO.md    <- Tracking detallado de fases
docker-compose.yml                  <- Perfiles scenario-mb y scenario-metro
Makefile                            <- Targets docker-dev-scenario-*, anillar-status, anillar-cleanup
```

---

## Comandos de referencia rápida

```bash
# Levantar (primer plano, carga automática)
make docker-dev-scenario-mb
make docker-dev-scenario-metro

# Verificar estado
make anillar-status CONTAINER=apimetro_db_scenario_mb
make anillar-status CONTAINER=apimetro_db_scenario_metro

# Bajar y limpiar volúmenes
make docker-down-scenario-mb
make docker-down-scenario-metro

# Limpiar datos sin bajar contenedores
make anillar-cleanup CONTAINER=apimetro_db_scenario_mb
make anillar-cleanup CONTAINER=apimetro_db_scenario_metro
```
