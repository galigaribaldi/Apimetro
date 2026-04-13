## Descripción

<!-- Explica qué resuelve o agrega este PR. Sé específico. -->

Closes #<!-- número de issue -->

---

## Tipo de cambio

- [ ] `feat` — Nueva funcionalidad o endpoint
- [ ] `fix` — Corrección de bug
- [ ] `refactor` — Refactorización sin cambio de comportamiento
- [ ] `docs` — Solo documentación (Swagger, READMEs, NOTES)
- [ ] `chore` — Infraestructura / DevOps (Docker, Makefile, CI)
- [ ] `perf` — Mejora de rendimiento

---

## Breaking changes

- [ ] Este PR **no** introduce breaking changes
- [ ] Este PR **sí** introduce breaking changes → describir abajo:

<!-- Si hay breaking changes, describir qué se rompe y cómo migrar: -->

---

## Endpoints afectados

<!-- Lista los endpoints que cambian, se agregan o se eliminan. -->

| Método | Ruta | Cambio |
|--------|------|--------|
| GET | `/movilidad/...` | |

---

## Ejemplo de prueba

<!-- Pega al menos un curl que demuestre el comportamiento nuevo o corregido. -->

```bash
curl "http://localhost:8080/movilidad/..."
```

Respuesta esperada:
```json
{

}
```

---

## Checklist

- [ ] El código compila sin errores (`make build`)
- [ ] Probé el entorno DEV con `make docker-dev`
- [ ] Verifiqué los endpoints afectados manualmente
- [ ] Si modifiqué `routes/` o `models/`, corrí `make docs` y Swagger UI carga sin errores
- [ ] No incluyo archivos `.env`, contraseñas ni datos de producción
- [ ] No edité archivos en `cmd/docs/` ni `docs/` manualmente
- [ ] El PR apunta a la rama `DEV`, no directamente a `main`
