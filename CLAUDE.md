# Apimetro — Contexto para Claude Code

## Descripcion del proyecto
API REST de datos geoespaciales sobre el sistema de transporte publico de la Ciudad de Mexico y el Area Metropolitana. Sirve como motor de datos para trazar lineas, puntos y poligonos en aplicaciones de mapas. Software libre bajo licencia BSL 1.1 (convierte a Apache 2.0 el 2029-04-12).

Dos tipos de respuesta:
- **JSON descriptivo**: datos operativos, filtros avanzados (CRUD completo)
- **GeoJSON geografico**: geometrias PostGIS listas para mapas (solo lectura)

Repositorio: https://github.com/galigaribaldi/Apimetro
Produccion: https://apimetro.dev

## Stack tecnologico
- **Lenguaje**: Go 1.25
- **Framework web**: Gin v1.9 + CORS (gin-contrib/cors v1.7.7)
- **Base de datos**: PostgreSQL 15 + PostGIS 3.4 (imagen `postgis/postgis:15-3.4`)
- **ORM**: GORM v1.25
- **Documentacion**: Swaggo v1.16.4 (anotaciones en codigo -> genera Swagger UI en `/swagger/`)
- **Hot reload**: Air (`.air.toml`)
- **Contenedores**: Docker + docker-compose con perfiles (dev/qa/main/prod)
- **ETL**: Python 3 (scripts en `ETL/`)

## Estructura de carpetas
```
cmd/
  main.go                       <- Entry point + anotaciones Swagger globales
  pkg/
    controller/
      Controller.go             <- Conexion a DB, buildDSN, auto-migrate
      geojson/                  <- Consultas espaciales (ST_AsGeoJSON, PostGIS) + AGEBs (plutarco)
      transporte/               <- CRUD de entidades
      middleware/               <- ValidarSistema (valida :sistema en la ruta)
      utils/GeoJson/            <- Structs para mapear resultados de consultas espaciales
    models/                     <- Modelos GORM + structs de respuesta GeoJSON
    routes/
      Routes.go                 <- Router principal, embed.FS para static, grupos de rutas
      static/                   <- Landing page (index.html), docs (docs.html), logo.png
      GeoJsonRoutes*.go         <- Handlers GeoJSON + Analitico + anotaciones Swagger
  docs/                         <- Swagger autogenerado (NO editar manualmente)
docs/                           <- Copia del Swagger generado
db/
  init/
    init.sql                    <- DDL esquema public (tablas, indices, PostGIS)
    init_plutarco.sql           <- DDL esquema plutarco (AGEBs, calles, uso_suelo, curvas_nivel)
    roles.sh                    <- Crea rol apimetro_read (SELECT-only) al iniciar Docker
    seed.sql                    <- Datos (~37MB), NO en git — se genera con scripts/load-seed.sh
  NOTES.txt                    <- Guia de entornos, tablas, comandos Make, proceso seed
ETL/
  main.py                      <- Orquestador de cargas ETL
  conf.py                      <- Config DB (usa os.getenv)
  DataCharge/                   <- Scripts de carga (LoadAgebs.py, LoadPlutarcoGeo.py, etc.)
  Data/                         <- Datos fuente (shapefiles, CSVs) — NO en git
scripts/
  load-seed.sh                 <- Genera seed.sql local y sube al servidor via SCP
Makefile                        <- Comandos de build, docs, Docker
docker-compose.yml              <- Multi-entorno (dev/qa/main) con perfiles
docker-compose.prod.yml         <- Produccion (127.0.0.1:8080, solo Nginx)
```

## Comandos principales

```bash
# Desarrollo local con hot-reload (regenera Swagger al inicio)
make dev

# Solo regenerar documentacion Swagger
make docs

# Compilar binario
make build

# Docker — levantar entorno DEV (API :8080, DB :5433)
make docker-dev

# Docker — levantar entorno QA (API :8081, DB :5434)
make docker-qa

# Docker — levantar entorno MAIN (API :8082, DB :5435)
make docker-main

# Bajar contenedores
make docker-down-dev
make docker-down-qa
make docker-down-main

# Exportar esquema DB local a init.sql
make db-sync
```

Los archivos `.env.*` viven en `~/.SecretsFiles/` (fuera del repo). El Makefile los referencia con `SECRETS_DIR`.

## Sistemas de transporte soportados
`METRO`, `MB` (Metrobus), `CBB` (Cablebus), `RTP`, `TROLE` (Trolebus), `TL` (Tren Ligero), `MEXIBUS`, `MEXICABLE`, `INTERURBANO`, `CC` (Cable Car), `TODOS`

## Rutas de la API
```
# Paginas web (embed.FS)
GET  /                                    -> Landing page (index.html)
GET  /docs                                -> Referencia API (docs.html)
GET  /swagger/*any                        -> Swagger UI

# GeoJSON (solo lectura)
GET  /movilidad/mapas/geojsonEstacion     -> Estaciones en GeoJSON
GET  /movilidad/mapas/geojsonLinea        -> Lineas en GeoJSON con metricas operativas
GET  /movilidad/mapas/geojsonPoligono     -> Poligonos administrativos en GeoJSON

# Analitico (esquema plutarco, sin ValidarSistema)
GET  /movilidad/analitico/agebs           -> AGEBs urbanas en GeoJSON (paginado)

# CRUD (JSON descriptivo)
CRUD /movilidad/:sistema/linea
CRUD /movilidad/:sistema/estacion
CRUD /movilidad/:sistema/descripcion-linea
CRUD /movilidad/:sistema/descripcion-estacion
```

## Base de datos

### Esquemas
- **public**: datos de transporte (lineas, ramals, estacions, historico_operacion, limites_territoriales)
- **plutarco**: datos INEGI para analisis (agebs, calles, uso_suelo, curvas_nivel)

### Seguridad
- Rol `apimetro_read`: SELECT-only sobre esquemas public y plutarco — lo usa la API
- Rol `admin_apimetro` (POSTGRES_USER): superusuario, solo Docker para init
- Nunca exponer credenciales admin en la API
- AutoMigrate solo corre cuando DB_HOST="" o DB_HOST=localhost (entorno local)

### DSN por defecto (desarrollo local sin Docker)
```
postgresql://prueba:postgres@localhost:5432/db_apimetro
```
Extension requerida: PostGIS.

## Convenciones del proyecto

### Codigo Go
- Anotaciones Swagger en archivos de `routes/` y en `main.go`. Los archivos en `docs/` y `cmd/docs/` son autogenerados — nunca editarlos manualmente
- Los modelos en `models/` usan tags `example:` para Swagger — mantener esos tags al modificar structs
- El middleware `ValidarSistema` normaliza `:sistema` a mayusculas y lo inyecta como `sistemaValidado` en el contexto Gin
- Los campos de texto en queries usan `norm.NFC.String()` para normalizar caracteres especiales (n con tilde, tildes) antes de buscar
- Queries PostGIS en el grupo `/analitico/` usan Raw SQL con `ST_AsGeoJSON(geom, 6)` (6 decimales, ~11cm precision)
- Paginacion obligatoria en endpoints de datos masivos (ej. AGEBs: default 500)

### Branching
- `main` — produccion (deployed en apimetro.dev)
- `DEV` — desarrollo activo, PRs van aqui primero
- `QA` — pruebas de integracion
- Feature branches: `DEV-<descripcion>` o `feature/<descripcion>` desde DEV

### Archivos estaticos
Los archivos en `cmd/pkg/routes/static/` se embeben en el binario con `//go:embed static`. Cambios en HTML/CSS/imagenes requieren rebuild (`docker compose build api` en produccion).

## Reglas de trabajo con Claude Code
1. **Nunca ejecutar operaciones git** (`add`, `commit`, `push`, `reset`, `checkout --`). Mostrar los comandos para que el usuario los ejecute.
2. **Mostrar los cambios propuestos al usuario antes de aplicarlos.** Esperar aprobacion explicita.
3. Al crear multiples archivos en secuencia, numerarlos ("Modulo 3 de 8") para indicar progreso.
4. Al cerrar un issue de backend, actualizar Swagger (`make docs`) y la coleccion Postman en `cmd/docs/postman_collection/`.
5. Probar cada endpoint nuevo en el contenedor DEV con curl antes de reportar como cerrado. Swagger UI apunta a `apimetro.dev` por `@host` en main.go — probar siempre contra localhost.
6. Los archivos `.env.*` contienen credenciales y viven fuera del repo (`~/.SecretsFiles/`). Nunca commitearlos.
