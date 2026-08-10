# FarmIA personal para Codex

Esta carpeta es la fuente estable de configuracion personal de Martin para
FarmIA y el checkout local del repositorio privado `MartinFarmiaDevDocs`. Esta
fuera de `farmia_app` y de `worktrees`, por lo que:

- no puede entrar accidentalmente en un commit o PR de FarmIA;
- no desaparece al borrar un worktree;
- Git conserva el historial de scripts, skills y documentacion personal;
- OneDrive conserva una copia sincronizada del checkout local;
- Codex puede descubrir las skills mediante enlaces personales en
  `C:\Users\marti\.agents\skills`.

## Estructura

- `skills/`: skills personales y sus referencias. Esta es la fuente canonica.
- `docs/`: documentacion personal curada sobre FarmIA, integraciones,
  criterios de lectura y limpieza local.
- `install-codex-links.ps1`: recrea los enlaces globales de Codex si se cambia
  de computadora o se elimina la configuracion local de Codex.
- `backup-worktree-notes.ps1`: copia las notas ignoradas de todos los
  worktrees registrados antes de limpiarlos.
- `config/farmia-project.config.example.toml`: ejemplo seguro sin credenciales.
- `config/farmia-project.config.toml`: configuracion MCP local ignorada por Git.
- `install-git-guard.ps1` y `git-hooks/`: proteccion local contra commits
  accidentales de configuracion personal o secretos.
- `worktree-notes/`: destino recomendado para notas que deban sobrevivir al
  borrado de un worktree. Esta carpeta no se versiona. No guardar secretos ni
  archivos `.env` aqui.

Indice principal de documentos: [docs/README.md](./docs/README.md).

Las skills compartidas con todo el equipo siguen viviendo versionadas en
`farmia_app/skills`. Una skill personal solo debe pasar al repositorio mediante
una rama y un PR que incluyan la skill completa, sus referencias y la
documentacion correspondiente.

## Matriz de destinos

Usar esta matriz antes de crear, mover o limpiar documentacion de FarmIA. El
repositorio privado protege el flujo personal frente a commits accidentales en
`farmia_app`, pero no es un lugar seguro para credenciales ni datos sensibles.

| Contenido | Destino | Versionado | Ejemplo |
| --- | --- | --- | --- |
| Contrato durable para todo el equipo | `farmia_app/docs` | Si, mediante rama y PR | Regla funcional de Caja |
| Skill util para todo el equipo | `farmia_app/skills` | Si, mediante rama y PR | Flujo compartido de regresion |
| Procedimiento, criterio o skill personal | `personal-codex` | Si, en el repositorio privado | Creacion personal de worktrees |
| Nota temporal ligada a un worktree | Archivo local ignorado dentro del worktree | No | Pendientes de implementacion |
| Nota que debe sobrevivir al borrado del worktree | `personal-codex/worktree-notes` | No | Respaldo de un todo local |
| Configuracion reutilizable sin valores reales | `personal-codex/config/*.example.*` | Si, en el repositorio privado | Nombres de variables y valores ficticios |
| API key, password, token o configuracion real | Gestor de secretos del entorno o archivo local ignorado | No | Keys UAT y produccion de A3 Mercados |
| Dump, artefacto con datos o exportacion sensible | Almacenamiento local controlado fuera de Git | No | Backup de PostgreSQL |

Antes de limpiar un documento ya versionado en `farmia_app`, revisar su
historial y autoria con Git. Una limpieza personal debe quitar solamente el
contenido propio identificado; no debe retirar contenido de Leo ni de otros
autores sin una solicitud explicita para ese contenido compartido.

## Seguridad

No versionar configuraciones reales, `.env`, API keys, passwords, tokens,
dumps de base de datos, artefactos con datos ni historiales completos de
worktrees. La configuracion real y `worktree-notes/` estan excluidos por
`.gitignore`; verificar siempre `git diff --cached` antes de cada push.

## Recuperar los enlaces de Codex

El instalador descubre todas las carpetas directas de `skills/` que contengan
un `SKILL.md` y crea sus enlaces en `C:\Users\marti\.agents\skills`. Es seguro
volver a ejecutarlo: conserva los enlaces correctos y no reemplaza archivos o
directorios normales.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File `
  'C:\Users\marti\OneDrive\Farmia\personal-codex\install-codex-links.ps1'
```

Despues de ejecutarlo, reiniciar Codex para refrescar el catalogo de skills.

## Antes de limpiar worktrees

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File `
  'C:\Users\marti\OneDrive\Farmia\personal-codex\backup-worktree-notes.ps1'
```

El respaldo incluye solamente `tasks/todo.gestion-agro.local.md` y
`tasks/lessons.gestion-agro.local.md`. No copia configuraciones ni secretos.

## Proteccion Git local

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File `
  'C:\Users\marti\OneDrive\Farmia\personal-codex\install-git-guard.ps1'
```

El hook se configura solamente en el clon local de `farmia_app` y se comparte
entre sus worktrees. Bloquea commits que intenten incluir `.codex/config.toml`,
archivos `.env` o las antiguas rutas personales dentro del repositorio. No
modifica el repositorio remoto.
