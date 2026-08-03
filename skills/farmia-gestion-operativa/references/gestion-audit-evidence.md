# Gestion Audit Evidence

Source material:

- `C:\Users\marti\OneDrive\Farmia\0_Instructivos\2_Summarys\Farmia_Dos_Apps_Locales_Prod_y_Dev.md`
- `C:\Users\marti\OneDrive\Farmia\2_Auditorias\GESTION_LOCAL_TEST_GUIDE_2026-06-12.md`
- `C:\Users\marti\OneDrive\Farmia\2_Auditorias\gestion-prod-dev-2026-06-15-rerun\REPORT.md`

## Local Prod/Dev Setup

- `farmia_app_prod` is the local production reference. Do not edit code or commit there.
- `farmia_app` is the development repo. Make code changes, tests, commits, and pushes there.
- Local production reference normally runs:
  - Frontend: `http://localhost:5173`
  - API: `http://localhost:3000`
  - Worker: `http://localhost:8000`
  - Postgres: `localhost:5432`
  - LocalStack: `http://localhost:4566`
- Local development side-by-side setup normally runs:
  - Frontend: `http://localhost:5174`
  - API: `http://localhost:3001`
  - Worker: `http://localhost:8001`
  - Postgres: `localhost:5433`
  - LocalStack: `http://localhost:4567`
- When both run, validate dev on `5174` and compare against prod reference on `5173`.

## 2026-06-12 Gestion Local Test Guide

The documented change set focused on UI/flow improvements without changing accounting rules, payments, Prisma, or API contracts:

- Legacy Gestion Agro URLs redirect to real sibling routes.
- Inicio Gestion dashboard agenda empty state became actionable.
- Facturas a pagar empty state gained direct links.
- Facturas a cobrar empty state gained direct links.
- A focused smoke E2E was added for routes, empty states, and a `factura emitida -> Ficha 360 cliente -> cobro -> Caja` circuit.

Important legacy redirects:

- `/flujos/gestion-agro/produccion` -> `/flujos/produccion`
- `/flujos/gestion-agro/labores` and `/flujos/gestion-agro/operaciones` -> `/flujos/labores`
- `/flujos/gestion-agro/insumos` -> `/flujos/insumos`
- `/flujos/gestion-agro/stock-granos` -> `/flujos/stock-granos`
- `/flujos/gestion-agro/ventas-granos` -> `/flujos/ventas-granos`
- `/flujos/gestion-agro/liquidaciones` and `/flujos/gestion-agro/liquidaciones-granos` -> `/flujos/liquidaciones`
- `/flujos/gestion-agro/margen-bruto` -> `/flujos/margen-bruto`

## 2026-06-15 Prod-vs-Dev Rerun

Use `2_Auditorias/gestion-prod-dev-2026-06-15-rerun/REPORT.md` as the primary visual evidence for that comparison.

Facts from the rerun:

- Prod local was navigated at `http://localhost:5173`.
- Dev local was navigated at `http://localhost:5174`.
- Dev DB had been corrected with `prisma db push --url ...`.
- No network responses were mocked.
- Preflight API passed for prod and dev: `/api/health/live`, `/api/me`, and `/api/dashboard-flujos` responded 200.
- All listed legacy Gestion Agro redirects passed in dev.
- Dashboard agenda showed the old prod empty state and the improved dev empty state.
- Facturas a pagar and a cobrar showed actionable links in dev and no table links in prod.

Key inference:

- Dev no longer blocked on login/API after the DB correction.
- Dev contained the expected UI improvements for redirects, agenda empty state, and invoice empty states.

Recommendation from the rerun:

- Use the rerun folder as primary visual evidence.
- If exact prod/dev data parity matters, seed dev before repeating. For empty states, an empty dev base is useful.

## Audit Method

- Separate facts, assumptions, inferences, and recommendations.
- Record preflight API status before trusting screenshots.
- Prefer no network mocks unless the audit intentionally tests a deterministic UI state.
- Pair prod/dev screenshots by case and preserve full-page outputs.
- If dev shows login or `/api/me` errors, resolve runtime/DB auth state before comparing UI behavior.
