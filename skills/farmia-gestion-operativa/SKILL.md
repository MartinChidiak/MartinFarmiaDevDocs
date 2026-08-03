---
name: farmia-gestion-operativa
description: Plan, audit, and prioritize FarmIA Gestion Operativa work. Use when the task mentions Gestion roadmap, comprobantes a caja, Inicio Gestion, Facturas y pagos, Caja or Libro Diario, Documentos IA, Ficha 360, proveedor or cliente saldos, Gestion Agro operating flows, Proyeccion tab AI, Gestion data loading, prod-vs-dev Gestion audits, or next implementation steps for the Gestion module.
---

# FarmIA Gestion Operativa

Use this skill to route Gestion product memory without loading every FarmIA note into the prompt. Keep `AGENTS.md` for always-on operating rules; use these references for Gestion-specific product, code, and audit context.

## Start

1. Read `AGENTS.md`.
2. Read `references/gestion-v1-roadmap.md` for product priorities, scope boundaries, and success criteria.
3. Read `references/gestion-code-map.md` before recommending files, interfaces, tests, or implementation order.
4. Read `references/gestion-audit-evidence.md` when comparing prod/dev, validating UI changes, or using prior audit findings.
5. Read `references/proyeccion-tab-ai-guide.md` for Proyeccion AI behavior, editing rules, validation, and common pitfalls.
6. Read `references/gestion-data-loading-manual.md` only when preparing, explaining, or validating manual Gestion data loads.
7. If the task crosses frontend, API, DB, browser validation, branches, PRs, staging, or production, also read `skills/farmia-regression/SKILL.md`.
8. If the task is only app startup or local ports, prefer `skills/farmia-startup/SKILL.md`.

## Decision Rules

- Default the V1 product focus to `comprobantes a caja`: incoming documents or manual operations become reviewed records that impact invoices, payments, collections, caja, stock, agenda, and reports with traceable origins.
- Do not start with formal accounting, IVA, AFIP, bank reconciliation, credits, placements, or complete ERP parity unless the user explicitly changes scope.
- Keep `Movimiento` as real caja/flow, not a formal accounting entry.
- Preserve fiscal data for future exports, but do not turn V1 into fiscal liquidation.
- Keep Gestion separate from GIS processing and Monitoreo unless a feature explicitly bridges them.
- Before deleting a Gestion worktree, preserve its ignored task notes under `C:\Users\marti\OneDrive\Farmia\personal-codex\worktree-notes`; never archive `.env` files or secrets there.
- Prefer current code over docs if they disagree; state the discrepancy and cite the code path.
- Treat `farmia_app_prod` as comparison-only. Implement and commit in `farmia_app`.

## Planning Workflow

- Start with the user goal and map it to the roadmap phase: agenda/caja, facturas/pagos/cobranzas, Documentos IA, Ficha 360, Gestion Agro, or contador exports.
- Trace the business impact before naming files: source document or manual action -> reviewed entity -> caja/cuenta corriente/stock -> agenda/report.
- Identify the minimum durable contract: source-of-truth model, API read/write path, frontend hook/component, validation/evidence.
- Include a risk check for duplicated saldos, automatic caja movement edits, document apply without review, and Gestion/GIS/Monitoreo boundary confusion.
- Recommend the smallest validation set: focused service tests first, then targeted Playwright or prod-vs-dev audit when the change is user-visible.

## Reference Map

- `references/gestion-v1-roadmap.md`: product intent, phases, guardrails, immediate checklist, and criteria before moving to accounting/fiscal work.
- `references/gestion-code-map.md`: routes, frontend components, hooks, API modules, model groups, safety boundaries, and validation commands.
- `references/gestion-audit-evidence.md`: local prod/dev setup, visual audit findings, improved empty states, redirects, and prior comparison evidence.
- `references/proyeccion-tab-ai-guide.md`: Proyeccion AI code paths, product rules, editable/read-only behavior, validation, and pitfalls.
- `references/gestion-data-loading-manual.md`: ordered manual data-loading procedure, relational example, user interpretation, and DBeaver checks.
