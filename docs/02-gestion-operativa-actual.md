# Gestion operativa actual

Fecha de relevamiento: 2026-08-10.

Esta guia resume como ubicarse hoy en Gestion. No reemplaza al codigo activo ni
a `farmia_app/docs/ARCHITECTURE.md`.

## Fuentes verificadas

- `farmia_app/docs/ARCHITECTURE.md`, seccion `Gestion Contract`.
- `farmia_app/frontend/src/App.tsx`, rutas `/flujos/*`.
- `farmia_app/api/prisma/schema.prisma`, modelos de Gestion.
- `farmia_app/e2e/gestion/*.spec.ts`, cobertura Playwright disponible.
- Skills personales:
  - `farmia-gestion-operativa`
  - `farmia-documentation-routing`

## Rutas frontend actuales

Rutas declaradas en `frontend/src/App.tsx`:

- `/flujos/libro-diario`
- `/flujos/facturas-pagos`
- `/flujos/convenios`
- `/flujos/gestion-agro`
- `/flujos/documentos`
- `/flujos/ordenes-compra`
- `/flujos/ordenes-compra/:ordenCompraId`
- `/flujos/labores`
- `/flujos/insumos`
- `/flujos/stock-granos`
- `/flujos/valorizaciones`
- `/flujos/ventas-granos`
- `/flujos/liquidaciones`
- `/flujos/margen-bruto`
- `/flujos/stock-cosecha`
- `/flujos/reservas`
- `/flujos/proyeccion`
- `/flujos/ingresos-egresos`
- `/flujos/reportes-operativos`
- `/flujos/cargas-masivas`
- `/flujos/variables-macro`
- `/flujos/plan-siembra`

Algunas rutas viejas redirigen a superficies actuales. No usar auditorias
viejas para inferir rutas sin confirmar en `App.tsx`.

## Carpetas de codigo

Frontend:

- `frontend/src/pages/flujos/`: paginas de ruta.
- `frontend/src/components/flujos/`: UI de Gestion.
- `frontend/src/components/flujos/gestion-agro/`: piezas especificas de
  Gestion Agro.
- `frontend/src/components/flujos/documentos/`: Centro documental y
  Documentos IA.
- `frontend/src/components/flujos/ui/`: primitivos visuales propios de
  Gestion.

API:

- `api/src/gestion-agro/`: fachada e internos de Gestion Agro.
- `api/src/gestion-documentos/`: Documentos IA.
- `api/src/proyeccion/`: Proyeccion.
- `api/src/facturas/`, `api/src/facturas-emitidas/`, `api/src/ordenes-pago/`,
  `api/src/movimientos/`: facturacion, pagos, cobros y Caja.
- `api/src/cartas-porte/`, `api/src/reservas/`: grano/comercial.
- `api/src/variables-macro/`: variables macro.

Persistencia:

- `DocumentoGestion`
- `VariableMacro`, `VariableMacroSerie`, `VariableMacroValor`
- `PlanSiembra`
- `Movimiento`
- `Factura`, `FacturaLinea`, `FacturaEmitida`
- `OrdenCompra`, `OrdenCompraLinea`
- `RecepcionCompra`, `RecepcionCompraLinea`
- `RecepcionCompraCostoAceptacion`
- `GestionCultivo`
- `MovimientoInsumo`, `MovimientoGrano`
- `ContratoGrano`, `LiquidacionGrano`

## Reglas vigentes que importan

- `Movimiento` es Caja real. Una proyeccion, factura, remito, OC o stock no
  genera Caja salvo una accion explicita que crea o confirma movimiento.
- Documentos IA preserva original, normalizacion, warnings, confianza,
  routing y decision humana antes de aplicar.
- Un documento aplicado o una factura con Caja/pago confirmado queda bloqueado;
  se corrige desde el flujo fuente.
- `RecepcionCompra` en borrador no mueve stock. Confirmar recepcion crea
  movimientos de insumo. Anular conserva trazabilidad.
- `OrdenCompra` es documental y de conciliacion; no mueve Caja ni stock.
- Valuacion de granos es modelo de lectura sobre stock fisico y cotizaciones;
  no inventa precios faltantes.
- Gestion Agro usa maestros relacionales por perfil para cultivo, labor,
  compradores y productos; strings legacy son snapshots de lectura.
- Proyeccion es forecast hasta marcar una linea como realizada.

## Pruebas disponibles

Cobertura E2E actual bajo `farmia_app/e2e/gestion`:

- `gestion-agro.spec.ts`
- `gestion-clientes-facturas.spec.ts`
- `gestion-compatibilidad.spec.ts`
- `gestion-compras-stock.spec.ts`
- `gestion-control-caja-proyeccion.spec.ts`
- `gestion-documentos-ia.spec.ts`
- `gestion-integracion-amplia.spec.ts`
- `gestion-maquinaria.spec.ts`
- `gestion-navegacion.spec.ts`

Para cambios de Gestion, empezar con una prueba focalizada antes de correr la
integracion amplia.

## Criterio para leer auditorias viejas

- Junio 2026: historico salvo que el hallazgo reaparezca en codigo actual.
- Primera mitad de julio 2026: contexto util, pero verificar rutas y modelos.
- Desde 2026-07-20: mas cercano al estado actual, aun asi no autoritativo.
- Reportes con snapshots, capturas, `error-context.md` o exportaciones:
  evidencia de una corrida, no documentacion de producto.

## Recomendacion

Para entender Gestion hoy, leer en este orden:

1. `farmia_app/docs/ARCHITECTURE.md`, seccion `Gestion Contract`.
2. `farmia_app/docs/GESTION_UI.md`.
3. Este resumen.
4. Codigo de ruta/frontend/API correspondiente.
5. Prueba E2E del subdominio.
