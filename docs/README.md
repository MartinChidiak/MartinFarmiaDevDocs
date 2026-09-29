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
| [Operación local y upstream](./04-operacion-local-y-upstream.md) | Runbook canónico de Git, worktrees (incluido su cierre), Docker, puertos, Prisma, LocalStack, E2E y Windows. |
| [Copiar datos de staging a local](./04-copiar-datos-staging-a-local.md) | Procedimiento y scripts para copiar clientes/campos/lotes reales de staging a cualquier stack local, con geometria incluida. |
| [Diferencias prod/staging/local en Gestion Agro](./05-diferencias-prod-staging-local-gestion-agro.md) | Estado comparado de plan de cultivos, historial de cultivos/costos y maestros; analisis previo a la carga de `Planting HJN 25.26`. |
| [Propuesta: superficie informada vs. shape](./06-propuesta-superficie-lote-informada-vs-shape.md) | **Propuesta personal, sin implementar.** Por que divergen la superficie guardada y la del poligono, y como avisarlo / permitir recalcular. |
| [Carga de historial de costos, paso a paso](./07-carga-historial-costos-paso-a-paso.md) | Cadena de dependencias, maestros agro, grupos de costo vs tipos de labor, las dos plantillas, y el plan de prueba con `Planting HJN 25.26`. |
| [Lote, plan de costos, trabajos y OT — recorrido visual](./08-plan-costos-trabajos-y-ot-paso-a-paso.md) | Caso local completo con 18 capturas: alta de lote, cultivo, presupuesto detallado, trabajos y comparación de OT desde el plan y desde Operaciones. |
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
