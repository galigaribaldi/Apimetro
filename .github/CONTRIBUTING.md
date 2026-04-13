# Guía de Contribución — Apimetro

Gracias por tu interés en colaborar. Lee esta guía antes de abrir un PR o un issue.

> **Licencia:** Apimetro usa **BSL 1.1**. Las contribuciones aceptadas se incorporan bajo esa misma licencia. El uso no-comercial (personal, académico, sector público) es libre; el uso comercial requiere licencia — escribe a galigaribaldi0@gmail.com.

---

## Índice

1. [Qué puedes contribuir](#qué-puedes-contribuir)
2. [Configurar el entorno](#configurar-el-entorno)
3. [Convención de ramas](#convención-de-ramas)
4. [Convención de commits](#convención-de-commits)
5. [Flujo de trabajo](#flujo-de-trabajo)
6. [Estilo de código Go](#estilo-de-código-go)
7. [Reglas de Swagger](#reglas-de-swagger)
8. [Reportar bugs](#reportar-bugs)

---

## Qué puedes contribuir

- Corrección de bugs documentados en issues
- Nuevos endpoints o filtros (abre un issue de feature request primero)
- Mejoras a la documentación Swagger (anotaciones en `routes/` y `models/`)
- Scripts ETL para nuevos sistemas de transporte
- Mejoras al esquema SQL en `db/init/init.sql`

**No se aceptan PRs que:**
- Cambien credenciales o datos de producción en `.env.main`
- Modifiquen archivos autogenerados en `cmd/docs/` o `docs/` directamente
- Deshabiliten el rol `apimetro_read` o eliminen restricciones de seguridad

---

## Configurar el entorno

### Opción A — Docker (recomendado)

```bash
git clone https://github.com/galigaribaldi/Apimetro.git
cd Apimetro

# Copiar variables de entorno
cp .env.dev.example .env.dev   # editar si es necesario

# Levantar entorno completo
make docker-dev
```

La API queda disponible en `http://localhost:8080` y Swagger en `http://localhost:8080/swagger/`.

### Opción B — Local sin Docker

Requisitos: Go 1.25+, PostgreSQL 15+ con PostGIS, `swag` y `air` en `~/go/bin/`.

```bash
go mod tidy
make dev
```

La API se conecta por defecto a `postgresql://prueba:postgres@localhost:5432/db_apimetro`.

---

## Convención de ramas

Crear siempre desde `main` o `DEV` (según lo que corresponda):

| Prefijo | Cuándo usarlo |
|---------|---------------|
| `feat/descripcion` | Nueva funcionalidad o endpoint |
| `fix/descripcion` | Corrección de bug |
| `docs/descripcion` | Solo documentación (Swagger, READMEs) |
| `refactor/descripcion` | Refactorización sin cambio de comportamiento |
| `chore/descripcion` | Cambios de infraestructura, Makefile, Docker |

Ejemplos:
```
feat/endpoint-cercania-estaciones
fix/geojson-poligono-nil-pointer
docs/swagger-param-sistema
chore/healthcheck-docker-compose
```

---

## Convención de commits

Usar [Conventional Commits](https://www.conventionalcommits.org/):

```
<tipo>(<scope opcional>): <descripción en imperativo>
```

| Tipo | Cuándo |
|------|--------|
| `feat` | Nueva funcionalidad |
| `fix` | Corrección de bug |
| `docs` | Documentación |
| `refactor` | Sin cambio funcional |
| `test` | Agregar o corregir tests |
| `chore` | Build, CI, dependencias |
| `perf` | Mejora de rendimiento |

Ejemplos:
```
feat(geojson): agregar filtro por radio en geojsonEstacion
fix(controller): corregir DSN cuando DB_HOST está vacío
docs(swagger): completar anotaciones de geojsonLinea
chore(docker): agregar healthcheck al servicio db_qa
```

---

## Flujo de trabajo

1. Abre (o comenta en) el issue relacionado antes de codificar.
2. Crea tu rama desde `DEV`:
   ```bash
   git checkout DEV
   git pull origin DEV
   git checkout -b feat/mi-mejora
   ```
3. Haz tus cambios. Corre la API y prueba manualmente.
4. Si tocaste `routes/` o `models/`, regenera Swagger:
   ```bash
   make docs
   ```
5. Verifica que compila:
   ```bash
   make build
   ```
6. Abre el PR contra la rama `DEV` (no directamente contra `main`).
7. Llena el template de PR completamente — PRs sin checklist completo no se revisan.

---

## Estilo de código Go

- Seguir las convenciones estándar de Go (`gofmt`, `go vet`).
- Nombres en inglés para variables, funciones y structs. Comentarios y documentación en español.
- Los campos de texto en queries deben usar `norm.NFC.String()` antes de comparar (ver ejemplos en `controller/transporte/`).
- No agregar manejo de errores para escenarios imposibles. Confiar en las garantías de GORM y Gin.
- No crear helpers para operaciones de un solo uso.

---

## Reglas de Swagger

- Las anotaciones viven en `cmd/pkg/routes/` y en `cmd/main.go`. **Nunca editar `cmd/docs/` a mano.**
- Cada `@Param` debe incluir descripción con valores válidos.
- Los structs en `models/` deben mantener los tags `example:` en todos los campos.
- Después de cualquier cambio en anotaciones, correr `make docs` y verificar que Swagger UI carga sin errores.

---

## Reportar bugs

Usa el template de **Bug Report** en los issues de GitHub. Incluye siempre:
- El endpoint exacto con todos los parámetros usados
- El error o respuesta inesperada recibida
- Los logs del servidor (`make docker-dev` o `make dev`)
- Versión de Docker o Go que estás usando
