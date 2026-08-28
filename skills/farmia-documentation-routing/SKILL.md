---
name: farmia-documentation-routing
description: Route FarmIA documentation, personal workflows, task notes, configuration, credentials, dumps, and skills to the correct shared, private, ignored, or secret-managed destination. Use when creating, moving, cleaning, archiving, or deciding whether to version FarmIA files, especially before worktree cleanup or changes to existing team documentation.
---

# FarmIA Documentation Routing

Classify each artifact before changing it. Keep personal working material
available to Codex without allowing it to enter FarmIA upstream accidentally.

## Inspect

1. Locate the relevant `farmia_app` checkout and the current local checkout of
   the private `MartinFarmiaDevDocs` repository. Do not assume a fixed path or
   use the other laptop's checkout.
2. Read the active repository instructions and inspect `git status` before
   proposing edits.
3. For existing tracked documentation, inspect `git log` and `git blame` before
   attributing or removing content. Treat authorship as evidence, not an
   assumption.
4. Separate facts, inferences, and recommendations. List uncertain ownership as
   unknown.

## Route

- Put durable team contracts and documentation in `farmia_app/docs` through the
  repository's normal branch and PR workflow.
- Put team-wide skills in `farmia_app/skills` only when their behavior is useful
  to collaborators and reviewed with the complete skill.
- Put Martin's safe, versioned workflows, criteria, scripts, runbooks, and
  skills in the current `MartinFarmiaDevDocs` checkout, then share them through
  `origin/main`.
- Keep temporary worktree notes ignored. Back up only the supported local task
  notes to this checkout's ignored `worktree-notes/` when they must survive
  cleanup.
- Keep machine identifiers, local paths, worktree roots, and runtime preferences
  in the ignored `config/farmia-project.config.toml`. Track only the example.
- Track only safe example configuration with fictitious values. Keep real API
  keys, passwords, tokens, `.env` files, and live configuration out of every Git
  repository; use the environment's secret manager or a local ignored file.
- Keep dumps, production data, and sensitive artifacts outside Git in
  controlled local storage.

## Protect shared work

- Preserve Leo-authored content during Martin's personal cleanup. Modify another
  author's content only when the user explicitly requests that shared change.
- Prefer surgical edits when personal and shared content coexist in one file.
- Do not move, delete, commit, or push merely because classification identifies
  a better destination. Require the user's requested action and follow the
  destination repository's Git rules.
- Do not copy secrets into examples, documentation, task notes, chat evidence,
  commits, or private repositories.
- Preserve unrelated local changes and stop if a proposed edit overlaps them.
- Treat GitHub as the authority for versioned DevDocs. Never copy between the
  two laptop checkouts or edit the OneDrive checkout from the current laptop.
- Prefer current `farmia_app` code and repository documentation when a private
  note is stale, and update the private note through its normal Git workflow.

## Report

State the recommended destination, whether it is versioned, why, and the
required approval or Git workflow. When auditing only, make no changes.
