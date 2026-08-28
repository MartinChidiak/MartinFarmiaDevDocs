# FarmIA DevDocs personal

Repositorio privado `MartinFarmiaDevDocs`: conserva conocimiento durable de
Martin sobre FarmIA sin mezclarlo con `farmia_app`. GitHub (`origin/main`) es la
fuente compartida entre computadoras; cada computadora usa su propio checkout y
su propia configuración ignorada.

## Dos checkouts, una fuente Git

| Computadora | Checkout de DevDocs | Regla |
| --- | --- | --- |
| Laptop actual | `C:\dev\farmia_docs` | Trabajar e instalar exclusivamente desde este clon. |
| Otra laptop | `C:\Users\Martin\OneDrive\Farmia\personal-codex` | Esperar OneDrive, luego sincronizar mediante Git. |

No copiar archivos entre los dos directorios ni usar ramas permanentes por
computadora. OneDrive solo transporta físicamente el checkout de la otra laptop;
los cambios versionados viajan por `origin/main`.

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

## Bootstrap pendiente de la otra laptop

1. Esperar que OneDrive finalice la sincronización.
2. En su checkout, preservar cambios con un stash identificado y `-u`.
3. Volver a `main` y ejecutar `git pull --ff-only`.
4. Crear o validar su `config/farmia-project.config.toml` ignorado.
5. Ejecutar los tres instaladores desde ese checkout.
6. Revisar el stash archivo por archivo. No aplicar directamente la versión
   vieja de `farmia-gestion-operativa` si referencia documentos inexistentes.

No operar ese checkout desde esta laptop ni usar ambas computadoras a la vez
sobre la misma carpeta OneDrive.

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
