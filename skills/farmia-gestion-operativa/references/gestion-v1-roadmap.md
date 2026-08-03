# Gestion V1 Roadmap

Source material: `C:\Users\marti\OneDrive\Farmia\1_Objetivo_Pasos\0- Plan_Gestion_Operativa_Farmia_V1.md`.

## Product Intent

- Turn Gestion into a daily operating tool for the field administrator.
- Do not try to replace KUMEN as a complete accounting or fiscal ERP in V1.
- Win on operational simplicity, traceability, and connection to campo/campana/lote.
- Keep formal accounting, IVA books, AFIP, bank reconciliation, credits, placements, and full fiscal closing out of V1 unless explicitly approved.

## Default Focus

Use `comprobantes a caja` as the main V1 focus:

1. A receipt, invoice, document, or manual operation enters FarmIA.
2. The user reviews and confirms it.
3. It becomes an invoice, movement, payment, collection, liquidation, stock record, or related operating record.
4. It impacts Caja, account current, stock, agenda, and reports.
5. The origin of every number stays traceable.

Gestion Agro should feed this core after it is stable. It should not block the MVP.

## Priority Order

1. Strengthen Inicio Gestion as the daily operating agenda.
2. Strengthen Facturas y pagos as the accounts payable/accounts receivable center.
3. Strengthen Caja / Libro Diario as the record of real movements.
4. Strengthen Ficha 360 proveedor/cliente as the operating source for balances.
5. Integrate Documentos IA with mandatory human review before apply.
6. Connect egresos fijos, proyeccion, and caja without duplicated amounts.
7. Consolidate simple operating reports and exports.
8. Evaluate formal accounting, IVA, AFIP, and bank reconciliation only after the operating loop is stable.

## Guardrails

- `Movimiento` represents real caja/flow, not an accounting entry.
- Every real movement should explain its origin: supplier invoice, payment order, issued invoice, document, fixed expense, realized projection, grain liquidation, freight, land rent, or manual movement.
- Do not let automatic movements be edited directly from Caja; users should go to the origin.
- Derive saldos from clear sources. Avoid storing or displaying competing balance truths.
- Capture fiscal fields for future contador exports, but do not liquidate taxes in V1.
- Export for the accountant before integrating AFIP.

## Phases

- Phase 1, agenda and reliable caja: agenda with vencidos, next 7 days, no-date items, documents pending review, fixed expenses, and direct action links.
- Phase 2, invoices, payments, and collections: supplier invoice states, payment orders, partial applications, anticipos, issued invoices, and visible document origin.
- Phase 3, Documentos IA: upload, extract, review, warn, apply, link, archive, and preserve raw/normalized/confidence data.
- Phase 4, Ficha 360: balance, aging, recent invoices, payments/collections, linked documents, agro activity, pending projections, and export.
- Phase 5, Gestion Agro: purchases, receipts, stock, labors, grain, liquidations, fletes, and arrendamientos feeding caja/stock/accounts when appropriate.
- Phase 6, contador exports: received/issued documents, taxes detected, caja movements, balances by tercero, and pending/error documents.

## Immediate Checklist

- Complete the operating agenda with monthly fixed expenses.
- Validate that Documentos IA never creates impact without review/apply.
- Audit that automatic movements cannot be edited directly from Caja.
- Review supplier balances with partial payments and anticipos.
- Review client balances and decide whether partial collections need a dedicated model.
- Preserve fiscal data after applying a Documento IA.
- Add simple contador exports if key fields are missing.
- Cover receipt -> invoice -> payment/collection -> Ficha 360 in tests.

## Criteria Before Accounting/Fiscal Work

Do not move into formal accounting until:

- Caja matches real movements.
- Supplier and client balances are reliable.
- Applied documents are traceable.
- Egresos fijos and proyeccion do not duplicate caja.
- Gestion Agro feeds stock/caja without serious inconsistencies.
- The accountant has enough exports to work outside FarmIA.
