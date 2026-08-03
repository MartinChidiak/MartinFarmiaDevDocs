# FarmIA personal para Codex

Esta carpeta es la fuente estable de configuracion personal de Martin para
FarmIA. Esta fuera de `farmia_app` y de `worktrees`, por lo que:

- no puede entrar accidentalmente en un commit o PR de FarmIA;
- no desaparece al borrar un worktree;
- OneDrive conserva una copia sincronizada de los archivos normales;
- Codex puede descubrir las skills mediante enlaces personales en
  `C:\Users\marti\.agents\skills`.

## Estructura

- `skills/`: skills personales y sus referencias. Esta es la fuente canonica.
- `install-codex-links.ps1`: recrea los enlaces globales de Codex si se cambia
  de computadora o se elimina la configuracion local de Codex.
- `backup-worktree-notes.ps1`: copia las notas ignoradas de todos los
  worktrees registrados antes de limpiarlos.
- `config/farmia-project.config.toml`: respaldo de la configuracion MCP
  personal aplicada al proyecto.
- `install-git-guard.ps1` y `git-hooks/`: proteccion local contra commits
  accidentales de configuracion personal o secretos.
- `worktree-notes/`: destino recomendado para notas que deban sobrevivir al
  borrado de un worktree. No guardar secretos ni archivos `.env` aqui.

Las skills compartidas con todo el equipo siguen viviendo versionadas en
`farmia_app/skills`. Una skill personal solo debe pasar al repositorio mediante
una rama y un PR que incluyan la skill completa, sus referencias y la
documentacion correspondiente.

## Recuperar los enlaces de Codex

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
