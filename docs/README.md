# FarmIA DevDocs

Índice curado de documentación personal versionada para entender y operar
FarmIA. El código del checkout activo y `farmia_app/docs` son autoritativos; si
contradicen estas notas, usar el estado actual y actualizar este repositorio.

## Lecturas principales

| Documento | Uso |
| --- | --- |
| [Mapa actual de FarmIA](./01-mapa-farmia-actual.md) | Vista rápida de módulos, carpetas y fuentes autoritativas. |
| [Gestión operativa actual](./02-gestion-operativa-actual.md) | Guía para Gestión Administrativa, Gestión Agro, Caja, Documentos IA, compras, granos y Proyección. |
| [Auditorías Gestión: decisiones curadas](./03-auditorias-gestion-decisiones-curadas.md) | Decisiones aún vigentes, hallazgos absorbidos y pendientes reales. |
| [Operación local y upstream](./04-operacion-local-y-upstream.md) | Runbook canónico de Git, worktrees, Docker, puertos, Prisma, LocalStack y Windows. |
| [Limpieza de documentación local](./90-limpieza-documentacion-local.md) | Clasificación histórica de auditorías, instructivos y artefactos locales. |
| [A3 MarketData](./integraciones/A3_MARKETDATA_FARMIA.md) | Integración privada de cotizaciones A3, sin credenciales. |
| [Variables macro compartidas](./integraciones/VARIABLES_MACRO_COMPARTIDAS_FARMIA.md) | Resumen privado de variables macro. |

## Vigencia

- **Actual:** validado contra código o documentación versionada reciente.
- **Histórico:** contexto útil, no guía de implementación.
- **Local:** conservar fuera de Git o borrar tras revisión humana.
- **Sensible:** nunca versionar; incluye `.env`, tokens, dumps, exportaciones,
  reportes y capturas con información privada.

Para rutas, configuración por máquina y sincronización entre laptops, ver el
[README principal](../README.md).
