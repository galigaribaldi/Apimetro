# Apimetro API

![Go Version](https://img.shields.io/badge/Go-1.25-00ADD8?style=flat&logo=go)
![Gin Gonic](https://img.shields.io/badge/Gin-Framework-00ADD8?style=flat)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-PostGIS-336791?style=flat&logo=postgresql)
![Swagger](https://img.shields.io/badge/Swagger-Documented-85EA2D?style=flat&logo=swagger)
![Docker](https://img.shields.io/badge/Docker-Multi--Entorno-2496ED?style=flat&logo=docker)
![License](https://img.shields.io/badge/License-BSL%201.1-orange.svg)

**Apimetro** es una API RESTful desarrollada en Go que proporciona información detallada y georreferenciada sobre el Sistema de Transporte Colectivo (STC) y otros sistemas de movilidad de la Ciudad de México y su área metropolitana.

Diseñada para integrarse con mapas y sistemas de información geográfica (SIG), devuelve geometrías directamente en formato **GeoJSON** estándar — lista para consumirse con Leaflet, Mapbox, MapLibre o cualquier cliente de mapas.

> **Modelo de uso:** Apimetro es un proyecto de software libre con modelo **Freemium**. El uso personal, educativo, de investigación y del sector público es gratuito. El uso comercial requiere una licencia. Consulta el archivo [LICENSE](./LICENSE) para más detalles o escribe a galigaribaldi0@gmail.com.

---

## Servidor de Producción

| Recurso | URL |
|---------|-----|
| API base | `https://apimetro.dev/movilidad` |
| Swagger UI | `https://apimetro.dev/swagger/` |
| Health check | `https://apimetro.dev/` |

```bash
# Ejemplo rápido — líneas del Metro en producción
curl "https://apimetro.dev/movilidad/metro/linea?existe=true"
```

---

## Características Principales

- **Respuestas GeoJSON** — Los endpoints de mapas devuelven `FeatureCollection` listos para renderizar en cualquier librería de mapas.
- **Consultas Espaciales** — PostGIS nativo: `ST_AsGeoJSON`, `ST_DWithin`, `ST_Length`, `ST_Union`.
- **Filtrado Avanzado** — Por sistema, alcaldía, CETRAM, jerarquía de transporte, sentido, número comercial y más.
- **Métricas Operativas** — Velocidad promedio (km/h), frecuencia (min), capacidad de vehículo y distancia por ramal.
- **Documentación Interactiva** — Swagger UI disponible en `/swagger/` con todos los esquemas y parámetros documentados.
- **Multi-entorno con Docker** — Perfiles separados para DEV, QA y MAIN con volúmenes y redes independientes.

---

## Sistemas de Transporte Cubiertos

| Clave | Sistema |
|-------|---------|
| `METRO` | Sistema de Transporte Colectivo Metro |
| `MB` | Metrobús |
| `CBB` | Cablebús |
| `RTP` | Red de Transporte de Pasajeros |
| `TROLE` | Servicio de Transportes Eléctricos (Trolebús) |
| `TL` | Tren Ligero |
| `MEXIBUS` | Mexibús |
| `MEXICABLE` | Mexicable |
| `INTERURBANO` | Tren Interurbano México-Toluca |
| `CC` | Corredor Concesionado |
| `TODOS` | Todos los sistemas simultáneamente |

---

## Tecnologías

| Capa | Tecnología |
|------|-----------|
| Lenguaje | [Go 1.25](https://golang.org/) |
| Framework web | [Gin v1.9](https://github.com/gin-gonic/gin) |
| Base de datos | [PostgreSQL 15](https://www.postgresql.org/) + [PostGIS 3.4](https://postgis.net/) |
| ORM | [GORM v1.25](https://gorm.io/) |
| Documentación | [Swaggo v1.16](https://github.com/swaggo/swag) |
| Contenedores | [Docker](https://www.docker.com/) + Docker Compose |
| Hot reload | [Air](https://github.com/air-verse/air) |

---

## Requisitos Previos

### Opción A — Desarrollo local (sin Docker)
- Go 1.25+
- PostgreSQL 15+ con extensión PostGIS habilitada
- [`swag`](https://github.com/swaggo/swag) y [`air`](https://github.com/air-verse/air) instalados en `~/go/bin/`

### Opción B — Docker (recomendado)
- Docker Engine 24+
- Docker Compose v2+
- `make`

---

## Instalación

### 1. Clonar el repositorio

```bash
git clone https://github.com/galigaribaldi/Apimetro.git
cd Apimetro
```

### 2. Descargar dependencias de Go

```bash
go mod tidy
```

### 3. Instalar herramientas de desarrollo

```bash
go install github.com/swaggo/swag/cmd/swag@latest
go install github.com/air-verse/air@latest
```

---

## Ejecución

### Desarrollo local (sin Docker)

```bash
make dev
```
Genera la documentación Swagger y levanta el servidor con hot-reload en `http://localhost:8080`.

La API se conecta por defecto a `postgresql://prueba:postgres@localhost:5432/db_apimetro`. Configura las variables de entorno `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD` y `DB_NAME` para apuntar a otra base de datos.

### Desarrollo con Docker

```bash
make docker-dev
```
Levanta la API en `http://localhost:8080` y PostgreSQL+PostGIS en el puerto `5433`.

Para QA y producción:

```bash
make docker-qa    # API :8081 | DB :5434
make docker-main  # API :8082 | DB :5435
```

Consulta [`db/NOTES.txt`](./db/NOTES.txt) para instrucciones detalladas de cada entorno, incluyendo carga de datos e inicialización de la base de datos.

---

## Documentación de la API

Accede a la documentación interactiva:

- **Producción:** `https://apimetro.dev/swagger/`
- **Local:** `http://localhost:8080/swagger/`

**Base path:** `/movilidad`

Para regenerar la documentación después de modificar anotaciones:

```bash
make docs
```

---

## Endpoints Principales

### GeoJSON — Trazos y geometrías

Todos devuelven un objeto `FeatureCollection` bajo el estándar GeoJSON RFC 7946.

#### `GET /movilidad/mapas/geojsonEstacion`
Estaciones de transporte como puntos georreferenciados.

**Parámetros:** `sistema`, `num_comercial`, `alcaldia_municipio`, `nombre_ramal`, `jerarquia_transporte`, `derecho_de_via`, `es_cetram`, `nombre_cetram`, `cetram_real`

#### `GET /movilidad/mapas/geojsonLinea`
Trazos de líneas con métricas operativas (velocidad, frecuencia, capacidad, distancia).

**Parámetros:** `sistema`, `num_comercial`, `nombre_ramal`, `jerarquia_transporte`, `derecho_de_via`, `es_cetram`, `sentido`, `existe`

#### `GET /movilidad/mapas/geojsonPoligono`
Límites administrativos: alcaldías de la CDMX y municipios del Área Metropolitana.

**Parámetros:** `entidad`, `nivel`, `nombre`

### Datos descriptivos — CRUD por sistema

```
GET  /movilidad/{sistema}/linea
POST /movilidad/{sistema}/linea
PATCH /movilidad/{sistema}/linea?id={id}
DELETE /movilidad/{sistema}/linea?id={id}

GET  /movilidad/{sistema}/estacion
POST /movilidad/{sistema}/estacion
PATCH /movilidad/{sistema}/estacion?id={id}
DELETE /movilidad/{sistema}/estacion?id={id}

GET  /movilidad/{sistema}/descripcion-linea
GET  /movilidad/{sistema}/descripcion-estacion
```

### Analítico — Datos INEGI y afluencia (esquema Plutarco)

Endpoints del módulo analítico. No requieren parámetro `:sistema` en la ruta.

#### `GET /movilidad/analitico/agebs`
AGEBs (Áreas Geo-Estadísticas Básicas) urbanas en formato GeoJSON con atributos censales INEGI Censo 2020.

**Parámetros:** `entidad`, `municipio_alcaldia`, `limit` (default 500), `offset`

#### `GET /movilidad/analitico/afluencia-linea`
Afluencia mensual por línea de transporte público. Respuesta JSON tabular con `total` y `data[]`.

**Parámetros:** `sistema`, `linea_id`, `anio`, `mes_num`

### Ejemplo de consulta

```bash
# Estaciones tipo CETRAM del METRO en formato GeoJSON
curl "https://apimetro.dev/movilidad/mapas/geojsonEstacion?sistema=METRO&es_cetram=true"

# Líneas del Metrobús actualmente en operación
curl "https://apimetro.dev/movilidad/MB/linea?existe=true"

# Polígonos de alcaldías de la CDMX
curl "https://apimetro.dev/movilidad/mapas/geojsonPoligono?entidad=CDMX&nivel=alcaldia"
```

---

## Fuentes de Datos — Afluencia

Los datos de afluencia provienen del **Portal de Datos Abiertos de la Ciudad de México** ([datos.cdmx.gob.mx](https://datos.cdmx.gob.mx)), publicados por la **Secretaría de Movilidad (SEMOVI)** y los organismos operadores de transporte.

### Datasets utilizados

| Dataset | Publicador | Cobertura | URL |
|---------|-----------|-----------|-----|
| Afluencia preliminar en transporte público (histórico) | SEMOVI | STC Metro, Metrobús, STE (Trolebús, Tren Ligero, Cablebús), RTP — datos diarios 2020-2021 | [datos.cdmx.gob.mx](https://datos.cdmx.gob.mx/dataset/afluencia-preliminar-en-transporte-publico) |
| Afluencia diaria del Metro CDMX | STC Metro / SEMOVI | Metro por línea y estación, desde enero 2010 | [datos.cdmx.gob.mx](https://datos.cdmx.gob.mx/dataset/afluencia-diaria-del-metro-cdmx) |
| Afluencia diaria de Metrobús CDMX | SEMOVI | Metrobús por línea, desde julio 2005 | [datos.cdmx.gob.mx](https://datos.cdmx.gob.mx/dataset/afluencia-diaria-de-metrobus-cdmx) |
| Afluencia diaria Servicio de Transportes Eléctricos | STE / SEMOVI | Cablebús, Tren Ligero y Trolebús (desglosada), desde enero 2022 | [datos.cdmx.gob.mx](https://datos.cdmx.gob.mx/dataset/afluencia-diaria-servicio-de-transportes-electricos) |

### Granularidad disponible en las fuentes

Cada dataset del portal ofrece dos versiones del CSV: **Simple** y **Desglosada**. La diferencia está en el nivel de detalle por tipo de acceso.

| Fuente | Granularidad geográfica | Granularidad temporal | Desglose por tipo de pago |
|--------|------------------------|----------------------|--------------------------|
| **Metro (Simple)** | Por **línea y estación** | Diaria | No |
| **Metro (Desglosada)** | Por **línea y estación** | Diaria | Tarjeta, boleto, gratuidad |
| **Metrobús (Simple)** | Por **línea** (sin estación) | Diaria | No |
| **Metrobús (Desglosada)** | Por **línea** (sin estación) | Diaria | Tarjeta, gratuidad |
| **STE Trolebús** | Por **línea** | Diaria | Boleto, prepago, gratuidad |
| **STE Cablebús** | Por **línea** | Diaria | Prepago, gratuidad |
| **STE Tren Ligero** | **Agregado** (sin línea ni estación) | Diaria | Prepago, gratuidad |
| **Histórico (Excel)** | Por **línea/servicio** (sin estación) | Diaria | Tarjeta, boleto, total |

> **Dato clave para VFT:** Solo el Metro tiene datos a nivel de estación en el portal de datos abiertos. Para los demás sistemas, la afluencia más granular disponible es por línea. Para calcular afluencia por estación en esos sistemas, VFT tendría que distribuir la afluencia de la línea entre sus estaciones usando algún modelo de prorrateo.

### Columnas de los archivos fuente

**Excel histórico** (`afluencia_diaria_historica.xlsx`):
`id`, `organismo`, `linea_servicio`, `dia`, `fecha`, `afluencia_tarjeta`, `afluencia_boleto`, `afluencia_total_preliminar`

**CSVs complementarios STE** (Cablebús, Trolebús):
`fecha`, `mes`, `anio`, `linea`, `tipo_pago`, `afluencia`

**CSV Tren Ligero** (sin columna linea — sistema de línea única):
`fecha`, `mes`, `anio`, `tipo_pago`, `afluencia`

**CSV RTP** (excluido — reporta por servicio, no por línea):
`fecha`, `mes`, `anio`, `servicio`, `tipo_pago`, `afluencia`

**CSV acumulado Metrobús** (`afluencia_desglosada_acumulada_2024_07.csv` — no utilizado actualmente):
`anio`, `mes`, `fecha_corte`, `hora`, `genero`, `rango_edad`, `viajes` — contiene datos demográficos (género, rango de edad) y por hora del día, sin desglose por línea ni estación.

### Metodología de procesamiento

1. **Extracción**: Los archivos fuente (Excel y CSVs) se descargan del portal de datos abiertos. El archivo principal (`afluencia_diaria_historica.xlsx`) contiene datos diarios preliminares de todos los sistemas durante la emergencia sanitaria COVID-19 (2020-2021). Los CSVs complementarios contienen datos desglosados por sistema para periodos más recientes (2022-2026).

2. **Transformación**: El ETL (`ETL/DataCharge/LoadAfluencia.py`) agrega los datos diarios a nivel mensual (suma por sistema + línea + año + mes). Los nombres de línea de cada fuente se homologan a un `linea_id` unificado mediante el catálogo `plutarco.catalogo_homologacion` (~151 variantes mapeadas).

3. **Carga**: Los registros mensuales se insertan en `plutarco.afluencia_linea` con idempotencia (`ON CONFLICT DO NOTHING`). Granularidad final: 1 fila = 1 línea x 1 mes x 1 año.

### Cobertura actual

| Sistema | Líneas | Periodo | Registros |
|---------|--------|---------|-----------|
| METRO | 12 | 2020-2021 | 204 |
| TROLE | 12 | 2020-2026 | 688 |
| MB (Metrobús) | 7 | 2020-2021 | 119 |
| CBB (Cablebús) | 3 | 2021-2026 | 118 |
| TL (Tren Ligero) | 1 | 2020-2026 | 68 |
| **Total** | **35** | **2020-2026** | **1,197** |

> **Nota:** Los datos marcados como "preliminares" por SEMOVI fueron publicados durante la emergencia sanitaria COVID-19 con fines informativos. Los datos definitivos son validados por los organismos operadores mediante un proceso mensual de consolidación. RTP fue excluido porque reporta por tipo de servicio (Ordinario, Expreso, Ecobús), no por línea, lo cual no es compatible con el modelo de datos de Apimetro.

---

## Estructura del Proyecto

```
Apimetro/
├── cmd/
│   ├── main.go                        # Entry point + anotaciones Swagger globales
│   ├── docs/                          # Swagger autogenerado (no editar manualmente)
│   └── pkg/
│       ├── controller/
│       │   ├── Controller.go          # Conexión a DB y AutoMigrate
│       │   ├── geojson/               # Consultas espaciales PostGIS
│       │   ├── transporte/            # CRUD de entidades
│       │   ├── middleware/            # Validación del parámetro :sistema
│       │   └── utils/                 # Structs para mapear resultados SQL
│       ├── models/                    # Structs GORM + modelos GeoJSON
│       └── routes/                    # Handlers HTTP + anotaciones Swagger
├── db/
│   ├── init/
│   │   ├── 01_init.sql                # DDL completo (tablas, índices, esquemas)
│   │   ├── 02_init_plutarco.sql       # DDL esquema plutarco (analíticos)
│   │   ├── 03_roles.sh                # Creación del rol apimetro_read
│   │   ├── 04_seed.sql                # Datos de transporte (no incluido en git)
│   │   └── 05_seed_plutarco.sql       # Datos plutarco (no incluido en git)
│   └── NOTES.txt                      # Guía de comandos y operaciones de DB
├── .env.dev                           # Variables de entorno DEV (no en git)
├── .env.qa                            # Variables de entorno QA (no en git)
├── .env.main                          # Variables de entorno MAIN (no en git)
├── docker-compose.yml                 # Orquestación multi-entorno
├── Dockerfile                         # Build de producción (multi-stage)
├── Makefile                           # Comandos de desarrollo y despliegue
├── .air.toml                          # Configuración de hot-reload
└── go.mod                             # Dependencias de Go
```

---

## Variables de Entorno

| Variable | Descripción | Ejemplo |
|----------|-------------|---------|
| `DB_HOST` | Host de la base de datos | `localhost` / `db_dev` |
| `DB_PORT` | Puerto de PostgreSQL | `5432` |
| `DB_NAME` | Nombre de la base de datos | `db_apimetro` |
| `DB_USER` | Usuario de la API (solo lectura) | `apimetro_read` |
| `DB_PASSWORD` | Contraseña del usuario API | `***` |
| `DATABASE_URL` | DSN completo (sobreescribe los anteriores) | `postgresql://user:pass@host/db` — la contraseña debe estar URL-encoded si contiene `/`, `+` o `=` |
| `GIN_MODE` | Modo del servidor Gin | `debug` / `release` |

> En desarrollo local sin Docker, si `DB_HOST` está vacío o es `localhost`, la API ejecutará `AutoMigrate` de GORM automáticamente. En Docker, el esquema es gestionado por `db/init/01_init.sql`.

---

## Contribuciones

Las contribuciones son bienvenidas para uso no comercial. Para contribuir:

1. Haz un fork del repositorio.
2. Crea una rama: `git checkout -b feature/mi-mejora`
3. Haz commit de tus cambios: `git commit -m 'feat: descripción del cambio'`
4. Abre un Pull Request describiendo los cambios.

Si planeas usar Apimetro en un contexto comercial, contacta primero al autor para discutir una licencia comercial.

---

## Licencia

Este proyecto está licenciado bajo la **Business Source License 1.1 (BSL 1.1)**.

- **Uso gratuito:** personal, académico, investigación, periodismo y sector público.
- **Uso comercial:** requiere licencia — contacta a galigaribaldi0@gmail.com.
- **Conversión a Apache 2.0:** el **12 de abril de 2029**, este proyecto se convierte automáticamente en software libre bajo Apache 2.0.

Consulta el archivo [LICENSE](./LICENSE) para el texto completo.

---

## Contacto

**Hernán Galileo Cabrera Garibaldi**
- GitHub: [@galigaribaldi](https://github.com/galigaribaldi)
- Email: galigaribaldi0@gmail.com
