# Notas de Replicabilidad — Propuesta Anillo Periférico Interior

**Fecha inicial:** 2026-09-16 | **Última actualización:** 2026-09-21
**Contexto:** Réplica del estudio VFTModel con red propuesta de Anillo Periférico Interior
**Estado:** Entornos operativos — los 3 contenedores están corriendo con datos validados

---

## 1. Propuesta General

Replicar el análisis topológico completo del modelo VFT sobre dos escenarios alternativos que agregan un Anillo Periférico Interior a la red actual de transporte de la ZMVM:

| Escenario | Contenido | Sistema |
|-----------|-----------|---------|
| **Escenario MB** | Red actual + 4 líneas de anillo periférico como Metrobús (BRT) | `"MB"` |
| **Escenario METRO** | Red actual + 4 líneas de anillo periférico como Metro | `"METRO"` |

Las 4 líneas del anillo corresponden a los IDs 71-74, subdivididas por punto cardinal. El inicio de una línea es el final de la anterior, cerrando el anillo completo.

---

## 2. Decisión Arquitectónica: Claves Existentes

Se decidió usar las claves de sistema ya existentes en VFTModel (`"MB"` y `"METRO"`) en lugar de crear nuevas (como `"METRO_ANILLO"` o `"MB_PERIF"`). Esto elimina la necesidad de modificar código en VFTModel:

- `SistemaTransporte` enum en `src/api/schemas/schemas.py` → sin cambio
- `FALLBACK_VELOCIDAD` y `FALLBACK_FRECUENCIA` en `src/core/models/impedance.py` → sin cambio
- `FALLBACK_FRECUENCIA` en `src/core/services/graph_builder.py` → sin cambio

Las nuevas líneas heredan automáticamente los parámetros operativos del sistema al que pertenecen.

---

## 3. Parámetros Operativos por Escenario

| Propiedad | Escenario MB | Escenario METRO |
|-----------|-------------|-----------------|
| `sistema` | `"MB"` | `"METRO"` |
| `jerarquia_transporte` | `"masivo_mediano"` | `"masivo_pesado"` |
| `derecho_de_via` | `"confinado"` | `"exclusivo"` |
| `velocidad_promedio_kmh` | `16.3 km/h` | `36.0 km/h` |
| `frecuencia_minutos` | `5.0 min` | `3.0 min` |
| Fricción resultante (CF) | `1.152` (α=0.2) | `1.0` (α=0.0) |
| Boarding cost (transbordo) | `2.5 min` | `1.5 min` |

---

## 4. Arquitectura de Entornos Aislados

### Principio

Cada escenario corre como un proceso independiente de VFTModel, apuntando a una instancia separada de Apimetro que sirve la red correspondiente. Cero riesgo de contaminación cruzada — cada proceso tiene su propio caché en memoria.

### Puertos reales (implementación final)

| Entorno | API | DB PostgreSQL | Descripción |
|---------|-----|---------------|-------------|
| DEV | :8080 | :5433 | Red real (caso base) |
| Scenario-MB | :8083 | :5436 | Red real + Anillo como BRT |
| Scenario-METRO | :8084 | :5437 | Red real + Anillo como Metro |

### Diagrama

```
   ┌────────────────────┐   ┌────────────────────┐   ┌────────────────────┐
   │  Apimetro DEV      │   │  Apimetro MB       │   │  Apimetro METRO    │
   │  red actual        │   │  red + anillo BRT  │   │  red + anillo Metro│
   │  :8080 / :5433     │   │  :8083 / :5436     │   │  :8084 / :5437     │
   └────────────────────┘   └────────┬───────────┘   └────────┬───────────┘
                                     │                         │
                                     ▼                         ▼
                          ┌──────────────────┐     ┌──────────────────┐
                          │  VFTModel A      │     │  VFTModel B      │
                          │  .env.scenario-mb│     │  .env.scenario-me│
                          │  :8001           │     │  :8002           │
                          └──────────────────┘     └──────────────────┘
```

### Comandos para levantar (Apimetro)

```bash
# OPCIÓN RECOMENDADA — Destruir y reconstruir todo desde cero (incluye ETL automático)
make docker-down-all && make docker-all

# Verificar integridad tras reconstruir
make verify-integrity
```

```bash
# Por entorno individual (si solo se necesita uno)
make docker-dev                  # Red real
make docker-dev-scenario-mb      # Red + Anillo MB
make docker-dev-scenario-metro   # Red + Anillo METRO

# Bajar un entorno específico con destrucción de volumen
make docker-down-all             # destruye los 3
make docker-down-scenario-mb     # solo MB
make docker-down-scenario-metro  # solo METRO
```

**Qué hace `make docker-all` automáticamente:**
1. `chmod +x` en `03_roles.sh` y `05_apply_anillar.sh`
2. Levanta los 3 perfiles en background (`--build -d`)
3. `wait-for-init` — espera que `plutarco.agebs` tenga datos (seed_plutarco completo, ~8-10 min)
4. `plutarco-etl-all` — corre `LoadAfluencia` + `LoadAfluenciaEstacion` para los 3 puertos DB
5. Informa que los entornos están listos

```bash
# Seguir logs de los 3 entornos (requieren terminales separadas)
make logs-dev    # :8080 / :5433
make logs-mb     # :8083 / :5436
make logs-metro  # :8084 / :5437
make logs        # los 3 juntos (stream unificado)
```

> **Pipeline de init en cada contenedor (orden estricto):**
> `01_init.sql` → `02_init_plutarco.sql` → `03_roles.sh` → `04_seed.sql` → `05_anillar.sql`
> (sync secuencias) → `05_apply_anillar.sh` (migración anillo si `$ANILLAR_MIGRATION`) →
> `06_seed_catalogo.sql` (catalogo_homologacion) → `seed_plutarco.sql` (geo INEGI, ~114MB)

### Archivos de entorno para VFTModel

```bash
# .env.scenario-mb
APIMETRO_URL=http://localhost:8083/movilidad

# .env.scenario-metro
APIMETRO_URL=http://localhost:8084/movilidad
```

### Targets de Makefile (VFTModel)

```makefile
run-scenario-mb:
    ENV_FILE=.env.scenario-mb python -m uvicorn src.api.main:app --host 0.0.0.0 --port $(PORT) --reload

run-scenario-metro:
    ENV_FILE=.env.scenario-metro python -m uvicorn src.api.main:app --host 0.0.0.0 --port $(PORT) --reload
```

### Ejecución simultánea

```bash
# Terminal 1 — Escenario MB
make run-scenario-mb PORT=8001

# Terminal 2 — Escenario METRO
make run-scenario-metro PORT=8002
```

- `http://localhost:8083/swagger/index.html` → Swagger Apimetro MB
- `http://localhost:8084/swagger/index.html` → Swagger Apimetro METRO
- `http://localhost:8001/docs` → Swagger VFTModel con red + anillo MB
- `http://localhost:8002/docs` → Swagger VFTModel con red + anillo METRO

---

## 5. Indicadores a Calcular por Escenario

Los 6 indicadores implementados son agnósticos a la estructura de red — funcionan con cualquier cantidad de nodos y aristas sin modificación de código.

| Indicador | Archivo | Efecto esperado con anillo |
|-----------|---------|---------------------------|
| **SCC** | `topological/scc_analysis/` | Componente gigante sube (más nodos conectados) |
| **T** (tiempo promedio) | `topological/average_travel_time/` | Baja — el anillo crea atajos que reducen caminos mínimos |
| **B** (intermediación) | `topological/betweenness_centrality/` | Redistribución — nodos del anillo absorben carga |
| **k_in** (fuerza capilar) | `topological/capillar_strength.py` | Nuevos hubs en intersecciones anillo-red existente |
| **DI** (detour factor) | `topological/detaurFactor/` | Baja — rutas más directas por el periférico |
| **C** (cobertura) | `spatial/spatial_coverage.py` | Sube — nuevas estaciones cubren zonas sin servicio |

### Comparativa esperada MB vs METRO

| Indicador | MB (BRT) | METRO |
|-----------|----------|-------|
| **T** | Baja moderada (16.3 km/h, CF=1.152) | Baja fuerte (36 km/h, CF=1.0) |
| **B** | Redistribución moderada | Redistribución fuerte — Metro atrae más caminos mínimos |
| **DI** | Mejora leve — velocidad baja compensa menos | Mejora fuerte — velocidad alta reduce detour |
| **C** | Idéntica — mismas estaciones, misma geometría | Idéntica — mismas estaciones, misma geometría |
| **k_in** | Idéntico — misma topología de red | Idéntico — misma topología de red |

---

## 6. Requisitos para Apimetro

### Datos que debe entregar

Para cada escenario, Apimetro debe servir desde sus endpoints existentes (`/mapas/geojsonEstacion` y `/mapas/geojsonLinea`) la red actual **más** las 4 líneas del anillo periférico.

### Formato de estaciones (nodos)

```json
{
  "type": "Feature",
  "geometry": { "type": "Point", "coordinates": [-99.1234, 19.4567] },
  "properties": {
    "sistema": "MB",
    "tipo_entidad": "estacion",
    "nombre": "Periférico Sur 1",
    "jerarquia_transporte": "masivo_mediano",
    "es_cetram": false,
    "alcaldia_municipio": "Coyoacán",
    "tipo": "Superficie",
    "frecuencia_minutos": null,
    "velocidad_promedio_kmh": null
  }
}
```

### Formato de rutas (aristas)

```json
{
  "type": "Feature",
  "geometry": {
    "type": "LineString",
    "coordinates": [[-99.1234, 19.4567], [-99.1240, 19.4580], ...]
  },
  "properties": {
    "sistema": "MB",
    "tipo_entidad": "ruta",
    "nombre": "Línea 71 - Anillo Norte",
    "derecho_de_via": "confinado",
    "sentido": 1,
    "frecuencia_minutos": 5.0,
    "velocidad_promedio_kmh": 16.3
  }
}
```

### Reglas para las geometrías de rutas

1. **El LineString debe pasar a ≤50m de cada estación** del mismo sistema. El graph builder usa un KDTree con tolerancia `SNAP_TOLERANCE_DEG ≈ 50m` para detectar estaciones sobre el trazo. Si la línea no pasa cerca, la estación queda como nodo aislado sin aristas.

2. **Incluir puntos intermedios en curvas** del periférico. Sin ellos, la distancia Haversine acumulada entre estaciones sería la línea recta, subestimando el tiempo de viaje real.

3. **Cada línea necesita 2 features de ruta**: una con `sentido: 1` (ida) y otra con `sentido: 0` (regreso). El grafo es dirigido (`DiGraph`); sin ambos sentidos, los caminos mínimos solo funcionarían en una dirección del anillo.

4. **Conexión entre las 4 líneas**: la última estación de cada línea debe ser la misma coordenada que la primera estación de la siguiente línea. Dado que `node_id = (lon, lat)`, la coordenada idéntica produce un solo nodo compartido que conecta ambas líneas.

```
Línea 71 (Norte):  estN1 ──→ ... ──→ estN_last
Línea 72 (Este):   estE1 ──→ ... ──→ estE_last     donde estN_last = estE1
Línea 73 (Sur):    estS1 ──→ ... ──→ estS_last     donde estE_last = estS1
Línea 74 (Oeste):  estO1 ──→ ... ──→ estO_last     donde estS_last = estO1
                                                     donde estO_last = estN1  (cierre)
```

5. **Integración con red existente**: las estaciones del anillo que estén a ≤85m (tolerancia Q1) de estaciones existentes de la red actual se conectarán automáticamente vía snapping peatonal del graph builder (Fase 3). Si las estaciones están más lejos, se puede aumentar la tolerancia (Q2=180m, MEAN=245m).

### Datos de estaciones

- `estacion_id_oficial`: puede ser autogenerado, solo debe ser único y no colisionar con los existentes
- `alcaldia_municipio`: usar el esquema relacional existente (Ciudad de México, CDMX, EDOMEX)
- Año: dato dummy 2026
- Ubicación: coordenadas (lat/lon) reales sobre el trazo del Anillo Periférico Interior

### Instancias de Apimetro

Apimetro necesita poder servir 2 configuraciones de datos en endpoints separados (2 instancias en puertos distintos, o 2 bases de datos seleccionables). VFTModel se conecta a cada una vía la variable `APIMETRO_URL`.

---

## 7. Componentes de VFTModel que NO se Modifican

| Componente | Archivo | Razón |
|------------|---------|-------|
| Enum `SistemaTransporte` | `src/api/schemas/schemas.py:35-48` | MB y METRO ya existen |
| Velocidades fallback | `src/core/models/impedance.py:37-50` | Ya definidas para MB y METRO |
| Frecuencias fallback | `src/core/models/impedance.py:52-65` | Ya definidas para MB y METRO |
| Frecuencias graph builder | `src/core/services/graph_builder.py:36-39` | Ya definidas para MB y METRO |
| Fricción (CF) | `src/core/models/impedance.py:17-30` | Lee `derecho_de_via` del GeoJSON |
| Cliente Apimetro | `src/infrastructure/go_client/client.py` | Descarga cualquier sistema |
| Graph builder | `src/core/services/graph_builder.py` | Agnóstico a número de líneas |
| Caché | `src/api/dependencies.py` | Aislado por proceso |
| Todos los indicadores | `src/core/algorithms/` | Algoritmos genéricos de NetworkX |

---

## 8. Implementación Técnica — Datos del Anillo

### Rangos de IDs validados

| Escenario | linea_id | estacion `id` (BIGSERIAL) | estacion `estacion_id_oficial` (SMALLINT) |
|-----------|----------|--------------------------|------------------------------------------|
| MB (BRT) | 2071–2074 | 31001–31098 | 31001–31098 |
| METRO | 3071–3074 | 32001–32098 | 32001–32098 |

**Restricción clave:** `estacion_id_oficial` es `SMALLINT` (máx 32767). El ID máximo real de estaciones en el seed es **30172**. Los rangos 31001–31098 y 32001–32098 están por encima del max real y dentro del límite SMALLINT.

### Arquitectura de carga de la migración

La migración del anillo **no** se incluye directamente como archivo en `docker-entrypoint-initdb.d` (causaría un error de mount Docker). En cambio:

```
db/init/
  01_init.sql                    ← DDL (schema + tablas)
  02_init_plutarco.sql           ← DDL esquema plutarco
  03_roles.sh                    ← crea rol apimetro_read (SELECT-only)
  04_seed.sql                    ← ~37 MB datos reales (NO en git, sin watermarks)
  05_anillar.sql                 ← resincroniza secuencias SERIAL a MAX(id)+1
  05_apply_anillar.sh            ← lee $ANILLAR_MIGRATION y lo ejecuta con psql
  06_seed_catalogo.sql           ← carga plutarco.catalogo_homologacion (151 entradas)
  seed_plutarco.sql              ← ~114 MB datos geo INEGI (NO en git, sin watermarks)

db/migrations/
  v4.0_anillar_mb.sql            ← montado en /migrations/ (solo lectura)
  v4.0_anillar_metro.sql
```

`05_anillar.sql` corre ANTES de `05_apply_anillar.sh` (orden alfabético). Garantiza que los INSERTs de la migración del anillo obtengan IDs correctos de las secuencias.

`06_seed_catalogo.sql` corre ANTES de `seed_plutarco.sql` (orden alfabético `06` < `se`). El catálogo mapea nombres de CSV → `linea_id`; sin él, `LoadAfluencia` reporta 0 registros.

En `docker-compose.yml`, los contenedores de escenario reciben:

```yaml
environment:
  ANILLAR_MIGRATION: /migrations/v4.0_anillar_mb.sql   # o metro
volumes:
  - ./db/init:/docker-entrypoint-initdb.d
  - ./db/migrations:/migrations:ro
```

El contenedor DEV no tiene `ANILLAR_MIGRATION` → `05_apply_anillar.sh` detecta que la variable está vacía y no hace nada. Aislamiento garantizado.

### Problemas resueltos en la implementación

| Problema | Causa | Solución aplicada |
|----------|-------|-------------------|
| `\restrict` inválido en seed | Watermark del dump original no es SQL válido | Removido de `04_seed.sql` (línea 5) |
| `\unrestrict` al final del seed | Segundo watermark en última línea — `psql` error + `set -e` del entrypoint detenía toda la inicialización | Removido de `04_seed.sql` (línea 25292); `scripts/load-seed.sh` ahora hace `sed` automático |
| Secuencias SERIAL desfasadas | `pg_dump` guarda `setval` con valor al momento del dump, no `MAX(id)` real; seed inserta con IDs explícitos sin avanzar secuencias; `ON CONFLICT DO NOTHING` descartaba INSERTs de ramales en silencio | `05_anillar.sql` resincroniza todas las secuencias a `MAX(id)+1` tras el seed |
| `04b_sync_sequences.sql` orden incorrecto | Locale `en_US.UTF-8` del container ordena letras antes de `_`; `04b` < `04_` → corría antes del seed | Renombrado a `05_anillar.sql` (posición correcta en orden de init) |
| `chk_coords_consistency` falla | Estaciones RTP tienen `geom` pero lon/lat NULL (schema evolucionó después del dump) | Constraint relajada en `01_init.sql:109` — solo valida lon/lat |
| `mountpoint outside of rootfs` | No se puede hacer file-over-directory mount en Docker | Arquitectura `05_apply_anillar.sh` + `/migrations` separado |
| `smallint out of range` | IDs 40001+ / 50001+ exceden SMALLINT máx (32767) | Remapeado a 31001–31098 (MB) y 32001–32098 (METRO) |
| Ramales del anillo no idempotentes | `ramals` no tiene unique constraint en `(linea_id, ramal_num)` — re-ejecuciones acumulaban duplicados | `DELETE FROM ramals/historico_operacion WHERE linea_id BETWEEN ...` al inicio de la sección ramales en ambas migraciones |
| `catalogo_homologacion` vacío → 0 registros de afluencia | El catálogo solo estaba en `db/migrations/` (montado como `/migrations:ro`); DEV no tiene ese volume — `LoadAfluencia` reportaba `Catálogo cargado: 0 entradas activas` | Copiado a `db/init/06_seed_catalogo.sql`; se carga automáticamente en todos los perfiles durante el init |
| `cd ETL` persiste en loop de Makefile | En una receta Makefile unificada (`\`), `cd ETL` en la primera iteración cambia el directorio para todas las siguientes; segunda iteración falla con `No such file or directory` | Usar subshell `(cd ETL && ...)` para aislar el cambio de directorio |

### Conteos validados (2026-09-21)

```bash
# Verificar integridad completa tras rebuild
for CONTAINER in apimetro_db_dev apimetro_db_scenario_mb apimetro_db_scenario_metro; do
  docker exec $CONTAINER bash -c 'psql -U $POSTGRES_USER -d $POSTGRES_DB -c "
  SELECT
    (SELECT COUNT(*) FROM lineas)    AS lineas,
    (SELECT COUNT(*) FROM ramals)    AS ramals,
    (SELECT COUNT(*) FROM estacions) AS estacions,
    (SELECT last_value FROM ramals_id_seq) AS ramals_seq;
  "'
done
```

| Contenedor | lineas | ramals | estaciones (DB) | ramals_seq |
|---|---|---|---|---|
| DEV | 317 | 693 | 22,878 | ≥11,016 |
| Scenario-MB | 321 (+4) | 701 (+8) | 22,976 (+98) | ≥11,048 |
| Scenario-METRO | 321 (+4) | 701 (+8) | 22,976 (+98) | ≥11,048 |

```bash
# Verificar endpoints GeoJSON
for PORT in 8080 8083 8084; do
  L=$(curl -s "http://localhost:$PORT/movilidad/mapas/geojsonLinea"    | python3 -c "import sys,json; print(len(json.load(sys.stdin)['features']))")
  E=$(curl -s "http://localhost:$PORT/movilidad/mapas/geojsonEstacion" | python3 -c "import sys,json; print(len(json.load(sys.stdin)['features']))")
  echo ":$PORT → lineas=$L  estaciones=$E"
done
```

| Puerto | lineas GeoJSON | estaciones GeoJSON | Nota |
|---|---|---|---|
| :8080 DEV | 668 | 22,872 | −6 estaciones baseline sin geom (pre-existente) |
| :8083 MB | 676 (+8) | 22,970 (+98) | ✓ |
| :8084 METRO | 676 (+8) | 22,970 (+98) | ✓ |

**Conteos Plutarco (iguales en los 3 entornos — no dependen del escenario):**

```bash
for CONTAINER in apimetro_db_dev apimetro_db_scenario_mb apimetro_db_scenario_metro; do
  docker exec $CONTAINER bash -c 'psql -U $POSTGRES_USER -d $POSTGRES_DB -c "
  SELECT
    (SELECT COUNT(*) FROM plutarco.agebs)                AS agebs,
    (SELECT COUNT(*) FROM plutarco.catalogo_homologacion) AS catalogo,
    (SELECT COUNT(*) FROM plutarco.afluencia_linea)       AS afluencia_linea,
    (SELECT COUNT(*) FROM plutarco.afluencia_estacion)    AS afluencia_estacion;
  "'
done
```

| Tabla | Conteo | Origen |
|---|---|---|
| `plutarco.agebs` | 11,787 | `seed_plutarco.sql` (carga en init) |
| `plutarco.catalogo_homologacion` | 151 | `06_seed_catalogo.sql` (carga en init) |
| `plutarco.afluencia_linea` | 1,197 | ETL `LoadAfluencia` (carga post-init) |
| `plutarco.afluencia_estacion` | 38,207 | ETL `LoadAfluenciaEstacion` (carga post-init) |

> Los datos Plutarco son del esquema INEGI — no cambian entre escenarios. El catálogo se carga durante el init para que el ETL encuentre las 151 entradas activas y mapee los CSVs correctamente.

---

## 9. Checklist de Ejecución

### Pre-requisitos Apimetro
- [x] Apimetro entrega instancia con red actual + anillo MB (:8083)
- [x] Apimetro entrega instancia con red actual + anillo METRO (:8084)
- [x] URLs y puertos confirmados (ver sección 4)
- [x] Integridad validada (`make verify-integrity` — 5 bloques OK, 2026-09-21)
- [x] ETL Plutarco cargado en los 3 entornos (afluencia_estacion=38,207 por entorno)
- [ ] Crear `.env.scenario-mb` y `.env.scenario-metro` en VFTModel
- [ ] Agregar targets al Makefile de VFTModel

### Ejecución por escenario (VFTModel)
- [ ] Levantar VFTModel apuntando al escenario MB (`make run-scenario-mb PORT=8001`)
- [ ] Levantar VFTModel apuntando al escenario METRO (`make run-scenario-metro PORT=8002`)
- [ ] `POST /api/v1/network/build-auto` → construir grafo (ambos escenarios)
- [ ] `GET /api/v1/network/topological/scc-analysis` → verificar SCC
- [ ] `GET /api/v1/network/spatial-coverage` → cobertura (C)
- [ ] `GET /api/v1/network/topological/capillary-strength` → fuerza capilar (k_in)
- [ ] `GET /api/v1/network/topological/detour-factor` → detour factor (DI)
- [ ] `GET /api/v1/network/topological/average-travel-time` → tiempo promedio (T)
- [ ] `GET /api/v1/network/topological/betweenness-centrality` → intermediación (B)
- [ ] Registrar resultados

### Post-ejecución
- [ ] Comparar resultados: red actual vs. escenario MB vs. escenario METRO
- [ ] Documentar hallazgos en notebook dedicado
