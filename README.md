# FarmIA DevDocs personal

Repositorio privado `MartinFarmiaDevDocs`: conserva conocimiento durable de
Martin sobre FarmIA sin mezclarlo con `farmia_app`. GitHub (`origin/main`) es la
fuente compartida entre computadoras; cada computadora usa su propio checkout y
su propia configuración ignorada.

## Dos checkouts, una fuente Git

| Computadora | Checkout de DevDocs | Regla |
| --- | --- | --- |
| Laptop A | `C:\dev\farmia_docs` | Trabajar e instalar exclusivamente desde este clon. |
| Laptop B (`C:\Users\marti`) | `C:\Dev\farmia_docs` | Igual; migrada desde OneDrive el 2026-09-29. |

Ambas usan la misma ruta, con `farmia_app` y `worktrees` como carpetas hermanas
(los scripts las detectan solos). No copiar archivos entre computadoras ni usar
ramas permanentes por computadora: los cambios versionados viajan por
`origin/main`. OneDrive ya no forma parte del flujo; la copia vieja en
`OneDrive\Farmia\personal-codex` quedó retirada y no se opera.

El código activo y la documentación versionada de `farmia_app` prevalecen si
una nota privada queda desactualizada.

## Estructura

- `skills/`: skills personales enlazadas a `~\.agents\skills`.
- `docs/`: documentación personal y runbooks canónicos.
- `config/*.example.*`: plantillas seguras y ficticias.
- `config/farmia-project.config.toml`: rutas por máquina, ignoradas por Git.
- `worktree-notes/`: respaldo local ignorado de notas permitidas.
- `install-codex-links.ps1`: instala dinámicamente todas las skills.
- `install-codex-router.ps1`: administra el bloque FarmIA de
  `~\.codex\AGENTS.md` sin tocar otras instrucciones.
- `install-git-guard.ps1`: instala la protección pre-commit en el clon local de
  `farmia_app`.
- `scripts/diagnose-farmia-local.ps1`: diagnóstico local de solo lectura.

Índice documental: [docs/README.md](./docs/README.md).

## Bootstrap de esta laptop

Crear `config/farmia-project.config.toml` a partir del ejemplo y ejecutar:

```powershell
.\install-codex-links.ps1
.\install-codex-router.ps1
.\install-git-guard.ps1
.\scripts\diagnose-farmia-local.ps1
```

Los instaladores calculan el checkout de DevDocs desde su propia ubicación y
usan `$env:USERPROFILE`; se pueden ejecutar más de una vez. Reiniciar Codex
después de cambiar enlaces o el router para refrescar el catálogo de skills.

## Flujo cotidiano compartido

```powershell
git switch main
git pull --ff-only
git switch -c martin/<tema>
```

Al terminar:

```powershell
git add <archivos-seguros>
git diff --cached
git commit -m "<descripcion>"
git push -u origin martin/<tema>
```

Después de revisar, integrar a `main`. La otra computadora se actualiza con
`git pull --ff-only`. Las diferencias de rutas y runtime pertenecen al archivo
ignorado de cada máquina, no a ramas permanentes.

## Migración de la laptop B (2026-09-29)

1. Los cambios sin commitear del checkout de OneDrive se commitearon y se
   rebasearon sobre `origin/main` (guías 04–08, `staging-copy`, filtros
   compactos y excepción `.env.example` del hook).
2. Clon nuevo en `C:\Dev\farmia_docs`; `config/farmia-project.config.toml` y
   `worktree-notes/` se copiaron a mano y se verificaron por hash.
3. Se ejecutaron los tres instaladores desde el clon nuevo.

Para una computadora nueva, repetir el bootstrap de arriba en
`C:\dev\farmia_docs`.

## Matriz de destinos

| Contenido | Destino | Versionado |
| --- | --- | --- |
| Contrato o skill útil para todo el equipo | `farmia_app/docs` o `farmia_app/skills` | Sí, mediante rama y PR |
| Procedimiento, criterio, runbook o skill personal durable | Este repositorio privado | Sí |
| Nota temporal de un worktree | Archivo local ignorado del worktree | No |
| Nota permitida que debe sobrevivir al worktree | `worktree-notes/` | No |
| Configuración reutilizable con valores ficticios | `config/*.example.*` | Sí |
| Configuración real, token, password o `.env` | Gestor de secretos o archivo local ignorado | No |
| Dump o artefacto con datos | Almacenamiento local controlado fuera de Git | No |

Antes de limpiar documentación compartida, revisar historial y autoría con Git.
Nunca versionar configuración real, secretos, dumps, exportaciones con datos ni
historiales completos de worktrees.

## Respaldo de notas antes de limpiar worktrees

```powershell
.\backup-worktree-notes.ps1 -WhatIf
.\backup-worktree-notes.ps1
```

Solo se respaldan los nombres permitidos por el script; no se copian `.env`,
configuraciones ni secretos.
