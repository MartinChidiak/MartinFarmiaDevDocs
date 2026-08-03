# Gestion Product Principles

Use these principles for product decisions. Verify implementation status in the current `farmia_app` code and `docs/ARCHITECTURE.md`; do not treat this file as a backlog.

## Product intent

- Make Gestion a daily operating tool for agricultural administration and production management.
- Prefer operational simplicity, traceability, and explicit source records over full ERP parity.
- Keep formal accounting, tax liquidation, AFIP integration, and bank reconciliation out of scope unless the user explicitly prioritizes them.
- Preserve fiscal and commercial data needed for exports without presenting FarmIA as the formal accounting ledger.

## Durable invariants

- `Movimiento` represents real Caja flow. A forecast, reminder, invoice, receipt, purchase order, or stock movement does not become Caja merely by existing.
- Every cash, balance, stock, grain, cost, or report value must be explainable from its source record.
- Automatic records must be corrected from their source workflow, not edited as unrelated manual rows.
- Documentos IA must preserve the original, normalized data, warnings, confidence, routing, and human decision before creating an operational entity.
- Supplier and customer balances must derive from authoritative invoices and applications; avoid competing stored totals.
- Ordered, received, invoiced, paid, and stocked quantities are different facts. Reconciliation may compare them but must not silently create the missing fact.
- Grain stock is physical. Quotes and valuation are read models and must keep unquoted quantities visible rather than inventing prices.
- Gestion Agro mutations use relational master identities. Legacy crop, labor, buyer, grain, and unit strings are display snapshots, not alternate write contracts.
- Gestion may reference Core campaign or location entities, but it must not duplicate GIS processing or create agronomic entities as a side effect of manual display data.
- Operational writes must respect the configured Gestion active period and ownership rules.

## Prioritization

Do not reuse the old fixed V1 phase list. For each request:

1. Inspect what already exists on the active branch.
2. Identify the user-visible gap and its authoritative source record.
3. Prefer completing an end-to-end operating loop over adding another disconnected screen.
4. Prioritize correctness of Caja, balances, stock, grain, and reconciliation before decorative reporting.
5. Add explicit diagnostics for missing data instead of treating unknown amounts as zero.
6. Require targeted regression evidence for any change that can duplicate or erase economic or physical impact.

## Scope decisions that require explicit direction

- Formal accounting entries or chart of accounts.
- Tax books, IVA liquidation, AFIP integration, or fiscal filing.
- External banking APIs or automatic bank reconciliation.
- Automatic acceptance thresholds for commercial differences.
- Cross-domain writes into GIS or Monitoreo.
- Destructive backfills, data deletion, or changes to historical valuation.

