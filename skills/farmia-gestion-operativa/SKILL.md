---
name: farmia-gestion-operativa
description: Plan, audit, prioritize, and refine FarmIA Gestion work from the current codebase. Use for Gestion Administrativa, Gestion Agro, compact operational UI and filters, Inicio Gestion, Caja, invoices, payments and collections, Documentos IA, Ficha 360, purchase and receipt reconciliation, grain operations and valuation, Proyeccion, operational periods, or deciding the next Gestion implementation step.
---

# FarmIA Gestion Operativa

Use current FarmIA code and contracts as the source of truth. Use the bundled references for durable product rules and code-discovery guidance, not as a substitute for inspecting the active branch.

## Start

1. Locate the active `farmia_app` checkout and read its `AGENTS.md`.
2. Read `docs/ARCHITECTURE.md`, especially `Gestion Contract`, for current business invariants.
3. Inspect the relevant frontend, API, Prisma, and tests before recommending behavior or files.
4. Read `references/gestion-product-principles.md` when prioritizing scope or product behavior.
5. Read `references/gestion-code-navigation.md` before proposing implementation order or validation.
6. Read `references/proyeccion-tab-ai-guide.md` only for Proyeccion, Caja forecast, fixed-flow, or cash-risk work.
7. Use the repo's `farmia-regression` skill for cross-layer implementation, Git/PR coordination, browser validation, staging, production, database, or infrastructure work.
8. Use the repo's `farmia-startup` skill for local startup, ports, Docker, or worktree runtime problems.

## Rules

- Prefer current code and tests when personal notes disagree with the repository. State the discrepancy.
- Treat `upstream/main` as the stable base and follow the active `AGENTS.md` branch and remote rules.
- Do not rely on fixed local ports or a separate `farmia_app_prod` checkout. Use the generated worktree manifest and launcher.
- Preserve supported ignored task notes with `backup-worktree-notes.ps1` from the current `MartinFarmiaDevDocs` checkout before deleting a worktree. Never archive `.env` files or secrets.
- Keep `Movimiento` as real cash flow, not a formal accounting entry.
- Require explicit, traceable transitions between documents, invoices, payments, collections, stock, grain, Caja, and reports.
- Do not create duplicate economic impact when a read model already derives it from its source.
- Preserve mandatory human review before Documentos IA creates an operational record.
- Keep Gestion separate from GIS processing and Monitoreo unless a feature explicitly bridges them.

## Compact filters in Gestion

When the user asks to compact filters on a Gestion screen, use this as the default interaction pattern unless the workflow makes a different control genuinely primary:

- Separate controls that change how data is read from filters that narrow the dataset.
- Keep at most three frequent controls visible in a compact toolbar, without unnecessary vertical labels. Typical examples are view or grouping, type or status, and value or measure.
- Put search, campaign, client, field, lot, crop, dates, and other scope filters behind one `Filtros` button by default. Keep one of them visible only when the user explicitly asks for it or the inspected workflow proves it is the screen's primary repeated action. Show the number of active hidden filters on the button.
- When the closed panel would otherwise hide the dataset's context, show only the most relevant active scope values as removable chips beside `Filtros`; campaign, client, field, and lot are the usual maximum set. Do not mirror search, dates, crop, or secondary filters unless the workflow specifically needs them visible. Hide these chips while the panel is open.
- Preserve hierarchy when removing scope chips: clearing client also clears field and lot, and clearing field also clears lot. Keep long labels compact with ellipsis while preserving the complete accessible name or tooltip.
- Move secondary table options such as sorting or optional columns to a contextual three-dot menu when they do not deserve permanent space.
- Inside the filter panel, avoid cards, repeated explanations, and separate titled sections. Use one responsive grid, a compact clear action, and only the fields needed for scope.
- Use a searchable autocomplete instead of a closed selector for fields with many options or realistic growth, such as campaigns, clients, fields, lots, crops, products, and concepts. Keep a simple select for short closed vocabularies. Use client-side search for bounded loaded sets and virtualization or server filtering when the option set is genuinely large.
- Aim for one row on wide desktop, two deliberate bands at intermediate widths, and stacked controls on mobile. The document must not overflow horizontally; wide tables scroll inside their own container.
- Preserve accessible names, clear-all behavior, existing calculations, and focused desktop/mobile validation.
- Keep a scope filter visible only when it is essential to the screen's primary task or is changed repeatedly during normal use.

## Workflow

1. Restate the user outcome and identify the authoritative business record.
2. Trace the impact chain from source to Caja, account current, stock, agenda, projection, or report.
3. Compare the requested behavior with the current contract and tests; do not assume an old roadmap item remains pending.
4. Identify the smallest durable change across DTO/service/controller, frontend hook/component, Prisma, and tests as applicable.
5. Check for duplicated balances, editable automatic movements, writes outside the active period, missing ownership, and document application without review.
6. Validate with focused tests first, then the smallest relevant Gestion Playwright flow when behavior is user-visible.

## References

- `references/gestion-product-principles.md`: durable scope and prioritization rules.
- `references/gestion-code-navigation.md`: search-first map of current Gestion layers and validation.
- `references/proyeccion-tab-ai-guide.md`: Proyeccion-specific behavior and pitfalls.
