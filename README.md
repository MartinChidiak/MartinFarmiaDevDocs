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

Las skills compartidas con todo el equipo siguen viviendo versionadas en
`farmia_app/skills`. Una skill personal solo debe pasar al repositorio mediante
una rama y un PR que incluyan la skill completa, sus referencias y la
documentacion correspondiente.

## Seguridad

No versionar configuraciones reales, `.env`, API keys, passwords, tokens,
dumps de base de datos, artefactos con datos ni historiales completos de
worktrees. La configuracion real y `worktree-notes/` estan excluidos por
`.gitignore`; verificar siempre `git diff --cached` antes de cada push.

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
