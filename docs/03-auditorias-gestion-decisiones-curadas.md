# Auditorias Gestion - decisiones curadas

Fecha de curacion: 2026-08-10.

Este documento reemplaza como lectura rapida a los reportes historicos grandes
de `2_Auditorias`. No reemplaza al codigo actual ni a
`C:\Users\marti\OneDrive\Farmia\farmia_app\docs\ARCHITECTURE.md`.

## Fuentes revisadas

Archivo local:
`C:\Users\marti\OneDrive\Farmia\Archivado\documentacion-local-archivada\2026-08-10\03_auditorias_y_evidencia\2_Auditorias`.

Reportes principales usados:

- `farmia-app-auditoria-integral-2026-07-30\AUDITORIA_FARMIA_APP_2026-07-30.md`
- `gestion-agro-auditoria-integral-2026-07-21\REPORT.md`
- `gestion-agro-analisis-2026-07-20\INFORME_GESTION_AGRO.md`
- `gestion-agro-regresion-flujos-2026-07-20\REPORTE.md`
- `gestion-agro-remitos-ia-2026-07-20\documentos-ia-routing-2026-07-20.md`
- `gestion-agro-ux-2026-07-17\REPORTE_GESTION_AGRO_UX_2026-07-17.md`
- `2026-07-16_Gestion_Agro_Auditoria_Integral\AUDITORIA_INTEGRAL_GESTION_AGRO_2026-07-16.md`
- `C:\Users\marti\OneDrive\Farmia\Gestion - Agro\AUDITORIA_GESTION_AGRO_STORYTELLING_2026-07-22.md`
- `C:\Users\marti\OneDrive\Farmia\Gestion - Agro\Guia_lectura_Gestion_FarmIA_2026-07-24`
- `C:\Users\marti\OneDrive\Farmia\Gestion - Agro\MVP_Gestion_FarmIA_2026-07-24`

Contraste actual:

- `farmia_app\docs\ARCHITECTURE.md`
- `farmia_app\frontend\src\App.tsx`
- `farmia_app\frontend\src\components\flujos\gestion-agro\StockCosechaPage.tsx`
- `farmia_app\frontend\src\components\flujos\documentos\DocumentoGestionReviewDrawer.tsx`
- `farmia_app\api\src\gestion-agro\cartas-porte.controller.ts`
- `farmia_app\api\src\gestion-agro\gestion-agro-cartas-porte.service.ts`
- `farmia_app\api\src\gestion-documentos\gestion-documentos.service.ts`

## Decisiones vigentes

### Gestion debe separar hechos operativos

Orden de compra, recepcion, factura, costo aceptado, stock, Caja y Proyeccion
son hechos distintos. No conviene comprimirlos en una sola accion automatica.

- Una orden de compra no mueve stock ni Caja.
- Una recepcion en borrador no mueve stock.
- Confirmar una recepcion mueve stock de insumos.
- Una factura de proveedor es financiera; no debe crear stock por si sola.
- Un costo aceptado debe quedar versionado y auditable.
- Caja real nace de movimientos reales, no de documentos operativos pendientes.
- Proyeccion cuenta compromisos o forecast hasta que existe el movimiento real.

Esta decision ya esta absorbida en `ARCHITECTURE.md` como contrato de Gestion.

### Documentos IA es una bandeja compartida, no una ejecucion silenciosa

La decision vigente es que Documentos IA conserve procedencia y contexto:
`businessArea`, `workflowKind`, `intakeContext`, clasificacion, confianza y
decision humana.

Para remitos Agro:

- el upload contextual puede venir de Recepciones;
- si la IA no confirma tipo/contexto con suficiente confianza, queda en
  `Sin clasificar`;
- aplicar un `remito_no_grano` crea una `RecepcionCompra` en borrador;
- ese borrador no mueve stock, Caja, facturas ni costos aceptados;
- el usuario debe completar producto, unidad, deposito y confirmar la
  recepcion.

La auditoria vieja pedia evitar que Agro quedara atado a la ruta visual actual.
El contrato actual lo resuelve persistiendo el workflow, no dependiendo solo de
la pagina desde la que se subio el archivo.

### Los costos o cotizaciones desconocidos no son cero final

En valoracion de granos, insumos, facturas y reportes, lo faltante debe quedar
visible como incompleto, no convertido a cero definitivo. Los reportes y pantallas
deben mostrar calidad de costos, cantidades sin valorizar o diagnosticos
equivalentes.

Decision practica: si no existe precio, cotizacion o costo aceptado suficiente,
mostrar el dato como pendiente/incompleto y permitir completar, no cerrar una
ganancia falsa.

### Gestion Agro necesita superficies canonicas

Las auditorias de julio detectaron rutas duplicadas y navegacion dificil. La
decision vigente es mantener vistas canonicas y dejar las rutas legacy como
compatibilidad, redireccion o acceso secundario.

Regla para futuras pantallas:

- elegir una superficie principal por flujo;
- evitar dos pantallas que hagan lo mismo con distinto estado mental;
- si una ruta vieja queda viva, debe apuntar claramente al flujo canonico;
- los tests E2E historicos que dependian de la navegacion anterior deben
  actualizarse antes de usarlos como evidencia de regresion.

### Campana y contexto deben ser visibles

En Gestion Agro, el usuario necesita saber en que campana, lote, cultivo o
contexto esta operando. Las auditorias UX validan estas reglas:

- el contexto de campana debe estar visible en pantallas operativas;
- `Todas` debe representar una decision explicita, no un filtro accidental;
- los estados de carga no deben mostrar recomendaciones transitorias;
- en mobile, tablas operativas largas necesitan tarjetas o patrones
  equivalentes para lectura y accion.

### La demo debe contar hechos y efectos, no pantallas

Los documentos de `Gestion - Agro` agregan valor como guia de storytelling. La
frase operativa vigente es:

> FarmIA separa y conecta lo planificado, lo comprometido, lo que ocurrio
> fisicamente y el dinero que realmente se movio.

Para explicar Gestion, conviene nombrar siempre:

- el origen del dato;
- el estado del registro;
- el efecto fisico, economico o financiero;
- si la lectura es explicita, estimada, pendiente o parcial.

Esto evita vender como cierre definitivo lo que todavia es forecast,
conciliacion pendiente, costo incompleto o dato estimado.

### Limites de MVP que siguen siendo utiles para presentaciones

Estos limites son de producto/comunicacion, aunque parte del codigo haya
evolucionado despues:

- FarmIA Gestion no reemplaza contabilidad formal, impuestos, AFIP ni
  conciliacion bancaria.
- Gestion Agro puede usar campana, cliente, campo o lote como contexto, pero no
  debe explicarse como procesamiento GIS.
- Crear un cultivo no crea automaticamente OT, labores ni insumos.
- La comparacion OT versus ejecucion es de hectareas; no hay presupuesto
  tecnico completo de dosis/costos por OT como contrato cerrado.
- Maquinaria es opcional; si no se usa, el circuito sigue, pero el margen pierde
  costo propio estructurado de equipos.
- Resultados es lectura calculada sobre fuentes operativas; no debe convertirse
  en un nuevo origen de verdad.

### Carta de Porte debe permitir correccion operativa controlada

El hallazgo P1 historico era que una Carta de Porte cerrada generaba entrada de
stock sin camino claro para reabrir, corregir o anular. En el codigo actual se
observan endpoints y acciones de UI para reabrir/anular, mas borrado de
borradores.

Decision vigente: una operacion cerrada no se borra fisicamente; se revierte o
se reabre con transiciones explicitas. Un borrador sin efectos puede eliminarse.

## Hallazgos historicos ya absorbidos

- `pesoNetoCpTn` y `pesoNetoTn`: la auditoria marco riesgo de desincronizacion.
  El servicio actual recalcula el peso canonico cuando cambia `pesoNetoCpTn`.
- `departureDateTime` desde IA: la auditoria pedia normalizacion. El servicio
  actual tiene validacion/normalizacion para fecha y hora antes de aplicar.
- Borrado de documentos: la arquitectura actual documenta flujo con tombstone y
  limpieza posterior, en lugar de borrar objetos de forma opaca.
- Carta de Porte cerrada: existen acciones actuales para reabrir/anular y
  borrar borradores.
- Variables BCR GIX: el documento de storytelling marcaba que
  `api/.env.example` usaba nombres viejos. El estado actual ya usa
  `BCR_GIX_BASE_URL`, `BCR_GIX_API_KEY` y `BCR_GIX_SECRET`, alineado con
  `docker-compose.yml` y `market-price.providers.ts`.

## Pendientes que no conviene perder

Estos puntos no quedaron cerrados por esta pasada:

- `adm-zip` sigue en `api/package.json` como `^0.5.17`. La auditoria de
  2026-07-30 lo marco como riesgo P1 y recomendaba actualizar o agregar limites
  defensivos para ZIP/shapefile. Requiere tarea tecnica separada.
- La proteccion anti-duplicados de Documentos IA existe por hash y clave fiscal
  o remito, pero no queda probado en esta pasada si la UI enlaza siempre al
  candidato duplicado existente de forma ergonomica.
- Los reportes viejos mencionan deuda de health check local, gates de
  dependencias, lint baseline y `terraform fmt`. No se revalidaron en esta
  limpieza documental.
- Las auditorias E2E previas a la reorganizacion de navegacion deben tratarse
  como evidencia historica, no como especificacion actual.

## Que queda en archivo

Los reportes markdown principales se conservan archivados porque contienen
contexto y evidencia historica. No deben usarse como guia directa de
implementacion sin comparar contra `farmia_app` actual.

Los artefactos generados por Playwright, HTML reports, screenshots, videos,
traces, exportaciones reproducibles y carpetas `artifacts*` no contienen
decisiones unicas despues de esta extraccion. Pueden eliminarse o enviarse a
Papelera manteniendo este resumen y los reportes markdown.
