# Proyeccion Tab AI Guide

Use this guide when a task asks to change what is visible, editable, compact, or read-only in the Gestion `Proyeccion` tab.

## Read First

- `AGENTS.md`: repo rules, validation, and Gestion boundaries.
- `docs/AI_GUIDELINES.md`: AI workflow and documentation rules.
- `docs/ARCHITECTURE.md`, section `Gestion Contract`: Proyeccion, Caja, fixed expenses, reserves, and DashboardFlujos contracts.
- `docs/GESTION_UI.md`: Gestion UI primitives and visual rules.
- `skills/farmia-gestion-operativa/references/gestion-code-map.md`: Gestion routes, services, tests, and boundaries.
- `skills/farmia-gestion-operativa/references/gestion-v1-roadmap.md`: product intent for Caja, Proyeccion, and operating simplicity.
- `tasks/lessons.md`: recent corrections. Search for `Proyeccion`, `Caja`, `recordatorio`, `estimacion`, and `descripciones estables`.

## Main Code Paths

- Page: `frontend/src/pages/flujos/ProyeccionPage.tsx`
  - Owns the spreadsheet UI, visible month columns, editable month columns, grouped manual rows, locked rows, drafts, paste behavior, details modal, and bulk save.
- Hooks: `frontend/src/lib/flujos-hooks.ts`
  - `useProyeccion`, `useBulkUpdateProyeccionLineas`, `useUpdateProyeccionLinea`, `useProyeccionCajaRecordatorios`.
- Types: `frontend/src/lib/types/flujos.ts`
  - `ProyeccionMes`, `ProyeccionLinea`, `ProyeccionResponse`, `ProyeccionLineaBulkChange`.
- API controller/service: `api/src/proyeccion/proyeccion.controller.ts`, `api/src/proyeccion/proyeccion.service.ts`
  - Builds months, editability, real Caja reference lines, automatic pending lines, manual lines, reserve projection, and write validation.
- DTOs: `api/src/proyeccion/dto/*.ts`
  - Bulk create/update/delete and advanced line updates.
- Dashboard consumer: `api/src/dashboard-flujos/dashboard-flujos.service.ts`
  - Inicio Gestion and `Riesgo de caja` consume Proyeccion read models.
- Tests: `api/src/proyeccion/proyeccion.service.spec.ts`, `api/src/dashboard-flujos/dashboard-flujos.service.spec.ts`.

## Product Rules

- Separate three concerns before editing code:
  - `visible`: the months/rows the user can see.
  - `editable`: the cells the user can change from the grid.
  - `counted`: the lines included in projected totals/reserve.
- Proyeccion is for forecast and operational planning. Caja real is `Movimiento`.
- Caja real movements shown in Proyeccion are reference/audit lines. They must be read-only and must not be counted twice in projected totals.
- Closed months are not editable from Proyeccion. Corrections belong in Caja or in the source module.
- Automatic lines from invoices, emitted invoices, stock, liquidations, arrendamientos, fixed expenses, and real movements are read-only in Proyeccion. They should link to their origin when possible.
- Manual `ProyeccionLinea` rows are editable only when pending, in an editable/open month, and within the correct campaign scope.
- `tratamientoCaja='estimacion'` is forecast only. It should not become an actionable Caja reminder.
- `tratamientoCaja='recordatorio'` is an operational reminder and may later be registered as Caja real.
- Default new/imported forecast rows should normally use `estimacion`, unless the user explicitly wants Caja reminders.

## Compact Row Rules

- The grid must stay compact because users will load many projected ingresos and egresos.
- Do not create one visual row per month when the concept is the same.
- Group manual grid rows by stable concept identity, normally:
  - `descripcion`
  - `tipo`
  - `categoria`
  - `tratamientoCaja`
  - source/import state when needed
- Spreadsheet/import descriptions must be stable across months. Do not include `YYYY-MM`, month names, or one-off suffixes in `descripcion` if the source row is the same concept.
- Keep the month in `fecha`, not in the visible concept name.
- If multiple real rows genuinely share the same concept and month but cannot be merged safely, show them as blocked/detail rows instead of inventing misleading totals.

## Editable Format

- Quick grid editing should prioritize ARS manual pending lines.
- USD, provider, convenio, manual location, or other advanced metadata should use the details modal unless the existing UI explicitly supports inline editing.
- Inputs should be compact, right-aligned, and stable width so the spreadsheet does not jump while typing or pasting.
- Paste behavior should only apply inside editable month columns.
- New rows should only create changes for filled editable cells.
- Emptying an existing editable cell means delete that manual projection line, not create a zero-value line.
- A row-level metadata change should update all editable cells for that row consistently.

## Read-Only Format

- Non-editable months may still be visible when the view horizon is extended, but cells must not expose inputs.
- Read-only cells should render as compact values or `-`.
- Read-only rows should explain their source with a small badge or origin action, not with duplicated explanatory text in every cell.
- Months outside the selected campaign must not be saved with the selected campaign ID unless the bulk-save contract explicitly supports per-campaign writes.
- Safer default for extended views: show outside-campaign months as read-only and provide a path to open the next campaign for editing.

## Horizon And Campaign Rules

- Do not assume "visible horizon" and "editable campaign" are the same thing.
- `Riesgo de caja` may need a broader read horizon than the editable grid.
- A view can include historical real months and future projected months while the grid only allows edits from the first open month.
- If a view crosses from one campaign to the next, either:
  - keep outside-campaign months read-only, or
  - implement per-campaign save grouping end to end in frontend and API.
- Do not let a cell for July 2026 in campaign `2026/2027` be saved accidentally under campaign `2025/2026`.

## Implementation Checklist

1. Trace current behavior before editing:
   - `ProyeccionPage.tsx` -> `useProyeccion` -> `ProyeccionController` -> `ProyeccionService`.
   - If Inicio Gestion is involved, also trace `DashboardFlujosService` and `FlujosDashboardPage.tsx`.
2. Identify which requirement changed:
   - visible months
   - editable months
   - row grouping
   - read-only formatting
   - projected totals/reserve
   - Caja reminder behavior
3. In `ProyeccionPage.tsx`, inspect these surfaces:
   - month column derivation
   - editable month set
   - manual row grouping
   - locked/read-only row grouping
   - `buildBulkChanges`
   - details modal lock rules
4. In `ProyeccionService`, inspect these surfaces:
   - `getProyeccion`
   - month/horizon builder
   - `getReservaBase`
   - automatic source queries
   - `mapManualLine`
   - `mapMovimientoLine`
   - `assertEditableMonth`
   - `bulkLineas` and `updateLinea`
5. Preserve the invariant:
   - every editable UI path must be rejected by the API if it targets a closed month, realized line, wrong campaign, or wrong ownership.

## Validation

- Run `npm run check:types` after frontend/API contract changes.
- Add or update focused API tests when changing:
  - month horizon
  - campaign crossing
  - editability
  - reserve totals
  - `estimacion` vs `recordatorio`
  - row realization into Caja
- Useful test files:
  - `api/src/proyeccion/proyeccion.service.spec.ts`
  - `api/src/dashboard-flujos/dashboard-flujos.service.spec.ts`
- Use browser/Playwright validation for user-facing layout:
  - `/flujos/proyeccion`
  - `/flujos` section `Riesgo de caja`
- Check visually that:
  - repeated monthly concepts share one compact row where appropriate
  - read-only months do not show editable inputs
  - editable cells do not overflow
  - summary totals match the grid/source data
  - Caja real is visible as reference but not counted twice

## Common Pitfalls

- Adding the month to `descripcion` during imports creates many visual rows for one concept.
- Extending visible months without fetching next-campaign data makes the view look empty.
- Fetching next-campaign data without locking editability can save under the wrong campaign.
- Treating all manual projection lines as Caja reminders pollutes Agenda and Caja.
- Showing Caja real in totals and also in `reservaInicial` double-counts real movements.
- Fixing Proyeccion without checking `Riesgo de caja` can regress Inicio Gestion.
