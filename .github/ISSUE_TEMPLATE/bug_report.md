---
name: Reporte de Bug
about: Crea un reporte para ayudarnos a mejorar Apimetro
title: '[BUG] '
labels: bug
assignees: galigaribaldi
---

## Descripción del bug

<!-- Descripción clara y concisa de lo que está fallando. -->

---

## Endpoint afectado

```
METHOD /movilidad/...
```

Parámetros usados:
```bash
curl "http://localhost:8080/movilidad/..."
```

---

## Pasos para reproducir

1. Levantar el entorno con `make docker-dev` (o `make dev`)
2. Hacer petición a `...`
3. Observar el error

---

## Comportamiento esperado

<!-- Qué debería haber devuelto o hecho la API. -->

---

## Comportamiento actual

<!-- Qué devuelve o hace realmente. Incluir el status HTTP y el body de respuesta. -->

**Status HTTP:** `500` / `400` / `...`

**Respuesta recibida:**
```json
{

}
```

---

## Logs del servidor

<!-- Pegar la salida relevante del terminal donde corre `make docker-dev` o `make dev`. -->

```
[GIN] ...
```

---

## Entorno

| Campo | Valor |
|-------|-------|
| OS | Ubuntu / macOS / Windows |
| Go version | `go version` |
| Docker version | `docker --version` |
| Entorno usado | DEV / QA / Local |
| Puerto API | :8080 / :8081 / :8082 |

---

## Contexto adicional

<!-- Cualquier otra información relevante: capturas de pantalla, datos de entrada especiales, etc. -->
