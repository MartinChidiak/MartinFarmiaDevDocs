---
name: farmia-local-maintenance
description: Maintain and troubleshoot FarmIA local checkouts safely. Use when aligning farmia_app with upstream/main, preserving dirty changes or stashes, creating or repairing worktrees and LEVANTAR_FARMIA_DEV_LOCAL launchers, diagnosing Docker Compose projects or occupied ports, understanding cold Docker builds, synchronizing Prisma, checking LocalStack or health endpoints, or fixing Windows startup errors such as spawn EINVAL and a frontend that does not start.
---

# FarmIA Local Maintenance

Use the active checkout and its instructions as the source of truth. Read the
canonical runbook at `../../docs/04-operacion-local-y-upstream.md` for detailed
incident procedures, then verify every command against the current code before
acting.

## Inspect first

1. Locate the requested `farmia_app` checkout. Read its `AGENTS.md` and inspect
   `git status --short --branch`, remotes, branch, tracking and worktrees.
2. Preserve unrelated changes. Before alignment, identify local commits,
   untracked files and stashes; never discard or overwrite them implicitly.
3. Read `.farmia-worktree.local.json` when present. Treat its branch, slot,
   Compose project, ports, database and volumes as checkout-specific.
4. Prefer the read-only `scripts/diagnose-farmia-local.ps1` from this DevDocs
   checkout for Git, Compose, ports and health checks.
5. Inspect current scripts and focused tests before relying on a remembered fix.

## Align safely

- Fetch the intended remote and report divergence before changing history.
- Prefer a fast-forward when the target branch has no unique local commits.
- Preserve useful dirty work in a named commit or stash; include untracked files
  only deliberately with `-u`.
- If local commits diverge, stop and choose an explicit PR, merge or rebase
  strategy. Do not use destructive reset as routine alignment.
- Never patch shared `main` ad hoc. Put a missing fix and its test on a topic
  branch.

## Repair local runtime

- Generate launchers and overrides from the current checkout; do not copy them
  from another branch or laptop.
- If a port is occupied, identify its process or exact Compose project and
  compare it with the manifest. Stop only the confirmed obsolete project.
- Do not remove volumes, databases, stashes or caches without explicit scope and
  a reason. A cold build is not data corruption.
- On Windows, verify that the frontend launcher invokes `npm.cmd` with the
  platform-specific spawn behavior covered by tests when diagnosing
  `spawn EINVAL`.
- Use the repository's safe Prisma deployment path and wait for LocalStack
  bootstrap. Never substitute a force-reset command.
- Confirm API, worker, LocalStack, frontend identity and frontend proxy health
  after changes.

## Report

State the cause supported by evidence, what was preserved, the exact checkout,
branch, Compose project and ports affected, commands executed, and validation
results. If private notes conflict with current code, follow the code and flag
the runbook for update.
