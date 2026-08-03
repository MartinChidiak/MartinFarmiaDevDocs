# Gestion Code Map

Source material: `C:\Users\marti\OneDrive\Farmia\0_Instructivos\1_Tecnicos\5_Gestion_Module_Detailed_Summary.md`, `AGENTS.md`, and current repo docs.

## Frontend Routes And Pages

- `/flujos`: `frontend/src/pages/flujos/FlujosDashboardPage.tsx`, the Inicio Gestion hub and cash summary.
- `/flujos/facturas-pagos`: `FacturasPagosPage.tsx`, accounts payable and receivable.
- `/flujos/libro-diario`: `LibroDiarioPage.tsx`, Caja / daily cash movements.
- `/flujos/documentos`: `DocumentosPage.tsx`, Documentos IA inbox/review/apply/archive.
- `/flujos/proveedores`: `ProveedoresPage.tsx`.
- `/flujos/clientes`: `ClientesGestionPage.tsx`.
- `/flujos/gestion-agro`: `GestionAgroHubPage.tsx`, the operations hub.
- Gestion Agro real routes are sibling routes such as `/flujos/produccion`, `/flujos/labores`, `/flujos/insumos`, `/flujos/stock-granos`, `/flujos/ventas-granos`, `/flujos/liquidaciones`, and `/flujos/margen-bruto`.

## Frontend Structure

- Keep Gestion UI under `frontend/src/components/flujos/`.
- Keep Gestion Agro shared UI under `frontend/src/components/flujos/gestion-agro/`.
- Use Gestion primitives from `frontend/src/components/flujos/ui/`: `GestionPage`, cards, tables, fields, buttons, modals, alerts, badges, segmented controls, tabs, empty states.
- Do not introduce MUI/theme legacy dependencies.
- For new Gestion UI foundations, run `npm run check:frontend-legacy`.
- Gestion data access currently uses broad hooks such as `frontend/src/lib/gestion-hooks.ts` and `frontend/src/lib/gestion-agro-hooks.ts`; follow existing patterns before inventing a new hook layer.

## API Map

Active Gestion module families include:

- `dashboard-flujos`: main Gestion dashboard/read model.
- `gestion-documentos`: document upload, AI processing, review, apply/link/archive.
- `facturas`: supplier invoices and payment-related flow.
- `facturas-emitidas`: issued invoices and client-side flow.
- `proveedores-flujo`: suppliers and supplier Ficha 360.
- `clientes-flujo` or emitted-invoice client endpoints: clients and client Ficha 360 depending on the existing path.
- `cuentas-financieras`, `movimientos`, `egresos-fijos`, `proyeccion`, `reservas`, `convenios`, `categorias`.
- `gestion-agro`: facade over production, inventory, purchase orders, receipts, commercial/grain, land rent, machinery, and reports services.

## Data Model Groups

- Core shared agronomic entities may be referenced: `Cliente`, `Campo`, `Lote`, `Campana`.
- Do not duplicate core entities inside Gestion. Use manual name fields when structured core data is unavailable.
- Gestion-owned keywords in Prisma work: `flujo`, `gestion`, `factura`, `movimiento`, `pago`, `compra`, `recepcion`, `liquidacion`, `stock`, `proyeccion`, `reserva`, `convenio`, `egreso`.
- If editing `api/prisma/schema.prisma`, stay inside Gestion-owned models unless the change explicitly touches Core/GIS/support.

## Business Flow Anchors

- Documentos IA: upload -> `DocumentoGestion` -> extraction -> review -> apply/link/archive.
- Caja / Libro Diario: `Movimiento` is the record of real cash/flow.
- Supplier invoices: supplier invoice -> payment order -> applications -> movement -> supplier Ficha 360.
- Issued invoices: issued invoice -> collection -> movement -> client Ficha 360.
- Fixed expenses: reminder until paid; caja impact only when a payment/movement is registered.
- Gestion Agro: purchases/receipts/labors/grain/liquidations should feed stock, margin, vencimientos, or caja only through explicit rules.

## Boundaries

- Gestion is not GIS processing. Avoid touching `Analisis`, worker GIS modules, file-type precedence, S3 analysis keys, or prescriptions for Gestion-only work.
- Gestion is not Monitoreo / Notas de lote. Do not move Monitoreo into `/flujos` or link it to Gestion Agro models without a product decision.
- Ownership still matters. Reuse existing ownership/common services instead of ad hoc checks.
- When docs and current code disagree, inspect code and report the discrepancy.

## Validation

- Baseline after Gestion frontend/API work: `npm run check:types`.
- API/business logic: `npm run check:api:test` or focused API specs.
- Gestion UI foundations: `npm run check:frontend-legacy`.
- Focused browser coverage when useful: `e2e/gestion/flujos.spec.ts`, `e2e/gestion/gestion-agro.spec.ts`, or the current focused Gestion smoke spec if present.
- For prod-vs-dev visual comparisons, keep outputs under `2_Auditorias/` with facts, assumptions, inferences, recommendations, and screenshot paths.
