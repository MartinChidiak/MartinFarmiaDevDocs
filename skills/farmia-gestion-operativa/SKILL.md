---
name: farmia-gestion-operativa
description: Plan, audit, and prioritize FarmIA Gestion work from the current codebase. Use for Gestion Administrativa, Gestion Agro, Inicio Gestion, Caja, invoices, payments and collections, Documentos IA, Ficha 360, purchase and receipt reconciliation, grain operations and valuation, Proyeccion, operational periods, or deciding the next Gestion implementation step.
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
- Preserve ignored task notes with `personal-codex/backup-worktree-notes.ps1` before deleting a worktree. Never archive `.env` files or secrets.
- Keep `Movimiento` as real cash flow, not a formal accounting entry.
- Require explicit, traceable transitions between documents, invoices, payments, collections, stock, grain, Caja, and reports.
- Do not create duplicate economic impact when a read model already derives it from its source.
- Preserve mandatory human review before Documentos IA creates an operational record.
- Keep Gestion separate from GIS processing and Monitoreo unless a feature explicitly bridges them.

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
