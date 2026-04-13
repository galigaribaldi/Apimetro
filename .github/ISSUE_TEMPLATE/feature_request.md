---
name: Solicitud de Feature
about: Propón una nueva funcionalidad o endpoint para Apimetro
title: '[FEAT] '
labels: enhancement
assignees: galigaribaldi
---

## Problema que resuelve

<!-- Describe el caso de uso concreto. Ej: "No hay forma de consultar estaciones dentro de un radio dado." -->

---

## Solución propuesta

<!-- Describe cómo debería funcionar. Si es un endpoint nuevo, sugiere el diseño: -->

**Endpoint sugerido:**
```
GET /movilidad/...
```

**Parámetros:**

| Parámetro | Tipo   | Requerido | Descripción |
| --------- | ------ | --------- | ----------- |
| `param1`  | string | No        | ...         |

**Respuesta esperada:**
```json
{
  "type": "FeatureCollection",
  "features": []
}
```

---

## Sistema de transporte afectado

<!-- Marca los sistemas relevantes o deja en blanco si aplica a todos. -->

- [ ] METRO
- [ ] MB (Metrobús)
- [ ] CBB (Cablebús)
- [ ] RTP
- [ ] TROLE
- [ ] TL (Tren Ligero)
- [ ] MEXIBUS
- [ ] MEXICABLE
- [ ] INTERURBANO
- [ ] CC (Cable Bus)
- [ ] Todos

---

## Alternativas consideradas

<!-- Otras formas de resolver el mismo problema. ¿Por qué prefieres la solución propuesta? -->

---

## Contexto adicional

<!-- Capturas, referencias, casos de uso específicos, o cualquier otra información relevante. -->
