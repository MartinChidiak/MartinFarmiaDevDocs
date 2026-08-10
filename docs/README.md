# FarmIA DevDocs

Indice curado de documentacion personal versionada para entender FarmIA sin
arrastrar auditorias viejas ni artefactos temporales.

## Como usar este repo

La fuente durable de contratos compartidos sigue siendo
`C:\Users\marti\OneDrive\Farmia\farmia_app\docs` y el codigo activo de
`farmia_app`. Este repositorio privado sirve para:

- conservar mapas personales de lectura;
- guardar criterios de decision y limpieza;
- documentar integraciones o investigaciones propias antes de llevarlas a PR;
- evitar que notas personales entren por accidente en `farmia_app`.

Si un documento de este repo contradice el codigo actual o `farmia_app/docs`,
preferir el codigo y actualizar este repo.

## Lecturas principales

| Documento | Uso |
| --- | --- |
| [Mapa actual de FarmIA](./01-mapa-farmia-actual.md) | Vista rapida de modulos, carpetas y fuentes autoritativas actuales. |
| [Gestion operativa actual](./02-gestion-operativa-actual.md) | Guia personal para ubicarse en Gestion Administrativa, Gestion Agro, Caja, Documentos IA, compras, granos y Proyeccion. |
| [Auditorias Gestion - decisiones curadas](./03-auditorias-gestion-decisiones-curadas.md) | Segunda pasada sobre auditorias historicas: decisiones que siguen vigentes, hallazgos absorbidos y pendientes reales. |
| [Limpieza de documentacion local](./90-limpieza-documentacion-local.md) | Clasificacion inicial de auditorias, instructivos y artefactos locales. |
| [A3 MarketData](./integraciones/A3_MARKETDATA_FARMIA.md) | Integracion privada de cotizaciones A3, sin credenciales reales. |
| [Variables macro compartidas](./integraciones/VARIABLES_MACRO_COMPARTIDAS_FARMIA.md) | Resumen privado de la centralizacion de variables macro. |

## Regla de vigencia

- Actual: validado contra `farmia_app` o contra docs versionadas recientes.
- Historico: util para contexto, pero no usar como guia de implementacion.
- Archivo local: conservar fuera de Git o borrar luego de una revision humana.
- Sensible: no versionar. Incluye `.env`, tokens, dumps, exportaciones con
  datos reales, reportes generados y capturas con informacion privada.

## Siguiente mantenimiento recomendado

1. Revisar `90-limpieza-documentacion-local.md`.
2. Revisar periodicamente los pendientes marcados en
   `03-auditorias-gestion-decisiones-curadas.md`.
3. Cuando un pendiente se cierre en `farmia_app`, actualizar este repo o mover
   la decision a la documentacion compartida que corresponda.
