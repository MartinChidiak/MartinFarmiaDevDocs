# Gestion Code Navigation

Use search-first navigation because Gestion changes frequently. Confirm every path against the active branch before editing.

## Start from contracts

- Repo rules: `AGENTS.md`.
- Business invariants: `docs/ARCHITECTURE.md`, section `Gestion Contract`.
- UI conventions: `docs/GESTION_UI.md` and `frontend/src/components/flujos/ui/`.
- Routes: `frontend/src/App.tsx`.
- Data model: `api/prisma/schema.prisma`.

Useful discovery commands:

```powershell
rg -n "Gestion Contract|Proyeccion|DocumentoGestion|OrdenCompra|RecepcionCompra|ContratoGrano" docs/ARCHITECTURE.md
rg -n "flujos/|GestionAgro|Proyeccion" frontend/src/App.tsx
rg --files frontend/src/components/flujos frontend/src/pages/flujos frontend/src/lib
rg --files api/src e2e/gestion | rg "gestion|factura|pago|proyeccion|compra|recepcion|grano"
```

## Frontend

- Route pages: `frontend/src/pages/flujos/`.
- Gestion domain UI: `frontend/src/components/flujos/`.
- Gestion Agro UI: `frontend/src/components/flujos/gestion-agro/`.
- Shared Gestion primitives: `frontend/src/components/flujos/ui/`.
- Current compatibility hook barrels include `frontend/src/lib/flujos-hooks.ts` and `frontend/src/lib/gestion-agro-hooks.ts`; inspect their imports and domain modules before adding another broad hook file.
- Public contract types live under `frontend/src/lib/types/`.

Keep pages as route orchestrators. Put reusable state and API access in the existing domain hooks and keep domain UI in its component folder.

## API and data

- Gestion Agro facade and internal services: `api/src/gestion-agro/`.
- Documentos IA: `api/src/gestion-documentos/`.
- Imports: `api/src/gestion-importaciones/`.
- Projection: `api/src/proyeccion/`.
- Supplier invoices, issued invoices, payment orders, movements, financial accounts, and dashboards have separate modules under `api/src/`; locate the controller and service together.
- Active-period policy: `api/src/common/gestion-active-period-policy.ts`.
- Prisma is authoritative for persistence. FarmIA uses `db push`, not migration-first development.

Trace controller -> DTO -> service -> Prisma/read model. For economic or physical effects, search every consumer of the affected relation or status before changing it.

## High-risk boundaries

- Caja creation, annulment, or automatic movement ownership.
- Supplier/customer balance applications and partial payments.
- Document application, tombstones, S3 originals, and AI routing.
- Purchase order, receipt, invoice, and accepted-cost reconciliation.
- Grain delivery, liquidation, reversal, pricing, and valuation.
- Inventory cost layers and historical valuation snapshots.
- Operational-period and workspace ownership checks.
- Prisma schema, backfills, or data deletion.

## Validation

Use the smallest relevant set:

```powershell
npm run check:types
npm run check:api:test
npm run check:frontend-legacy
```

Focused browser coverage lives under `e2e/gestion/`, including:

- `gestion-agro.spec.ts`
- `gestion-clientes-facturas.spec.ts`
- `gestion-compras-stock.spec.ts`
- `gestion-control-caja-proyeccion.spec.ts`
- `gestion-documentos-ia.spec.ts`
- `gestion-integracion-amplia.spec.ts`
- `gestion-navegacion.spec.ts`

Choose a focused spec before the broad integration flow. If a test name or path no longer exists, search the current directory instead of recreating the historical filename.

