# Notas de Replicabilidad — Propuesta Anillo Periférico Interior

**Fecha:** 2026-09-16
**Contexto:** Réplica del estudio VFTModel con red propuesta de Anillo Periférico Interior
**Estado:** En preparación — pendiente de que Apimetro entregue los datos

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

### Diagrama

```
                    ┌─────────────────┐
                    │  Apimetro DB    │
                    │  (red actual)   │
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              ▼                             ▼
   ┌──────────────────┐          ┌──────────────────┐
   │  Apimetro A      │          │  Apimetro B      │
   │  red + anillo MB  │          │  red + anillo MET │
   │  :8081            │          │  :8082            │
   └────────┬─────────┘          └────────┬─────────┘
            │                             │
            ▼                             ▼
   ┌──────────────────┐          ┌──────────────────┐
   │  VFTModel A      │          │  VFTModel B      │
   │  .env.scenario-mb │          │  .env.scenario-me│
   │  :8001            │          │  :8002            │
   │                   │          │                   │
   │  SCC, T, B, C,   │          │  SCC, T, B, C,   │
   │  k_in, DI         │          │  k_in, DI         │
   └──────────────────┘          └──────────────────┘
```

### Archivos de entorno necesarios

```bash
# .env.scenario-mb
APIMETRO_URL=http://localhost:8081/movilidad    # ← ajustar al puerto/URL real de Apimetro MB

# .env.scenario-metro
APIMETRO_URL=http://localhost:8082/movilidad    # ← ajustar al puerto/URL real de Apimetro METRO
```

### Targets de Makefile necesarios

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

- `http://localhost:8001/docs` → Swagger con red + anillo MB
- `http://localhost:8002/docs` → Swagger con red + anillo METRO

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

## 8. Checklist de Ejecución

### Pre-requisitos
- [ ] Apimetro entrega instancia con red actual + anillo MB
- [ ] Apimetro entrega instancia con red actual + anillo METRO
- [ ] Confirmar URLs/puertos de cada instancia de Apimetro
- [ ] Crear `.env.scenario-mb` y `.env.scenario-metro`
- [ ] Agregar targets al Makefile

### Ejecución por escenario
- [ ] Levantar VFTModel apuntando al escenario
- [ ] `POST /api/v1/network/build-auto` → construir grafo
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
