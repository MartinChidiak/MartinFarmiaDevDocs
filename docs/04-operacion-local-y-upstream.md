# Operación local y alineación con upstream

Runbook personal canónico para mantener y levantar `farmia_app` en Windows. El
código y las instrucciones del checkout activo prevalecen sobre este documento.
Diagnosticar primero; preservar cambios; no borrar volúmenes ni stashes como
respuesta automática.

## 1. Alinear un checkout con `upstream/main`

### Síntoma

El checkout quedó atrasado, se regeneraron launchers viejos o una corrección ya
presente en upstream no aparece localmente.

### Causa habitual

La rama local no fue actualizada, tiene commits propios o hay cambios sin
guardar. `origin` y `upstream` pueden representar autoridades distintas.

### Diagnóstico

```powershell
git status --short --branch
git remote -v
git fetch --all --prune
git rev-list --left-right --count HEAD...upstream/main
git stash list
```

`fetch` actualiza referencias pero no el working tree. Antes de cambiar la
historia, identificar archivos modificados, commits locales y stashes.

### Solución segura

1. Si hay trabajo útil, crear un commit en una rama temática o un stash con
   nombre; usar `git stash push -u -m "..."` solo si también deben preservarse
   archivos sin seguimiento.
2. Cambiar a la rama que debe alinearse.
3. Preferir `git merge --ff-only upstream/main` cuando la rama debe avanzar sin
   reescritura.
4. Si hay commits propios, revisar el grafo y decidir explícitamente entre PR,
   merge o rebase. No usar `reset --hard` como mantenimiento rutinario.
5. Regenerar la configuración local del worktree si cambió la rama o el runtime.

### Prevención

Empezar desde `upstream/main` actualizado, trabajar en ramas cortas y revisar
`git status` antes de limpiar o regenerar.

**Última verificación:** 2026-08-28, contra `farmia_app` activo y sus scripts de
worktree.

## 2. Manifest, launchers y aislamiento de worktrees

### Síntoma

Faltan `LEVANTAR_FARMIA_DEV_LOCAL.*`, el launcher nombra otra rama o
`worktree:validate` rechaza el checkout.

### Causa habitual

Los archivos runtime son locales y están ligados a la rama. El manifest
`.farmia-worktree.local.json` define `branch`, `slot`, proyecto Compose, base,
puertos y volúmenes; copiar launchers desde otro checkout conserva identidad y
puertos incorrectos.

### Diagnóstico

```powershell
npm run worktree:validate
Get-Content .farmia-worktree.local.json
git branch --show-current
```

### Solución segura

Ejecutar el configurador del checkout actual (`npm run worktree:configure`) o el
creador de worktrees documentado por el repositorio. Revisar el manifest y usar
el launcher recién generado. No versionar ni copiar esos archivos entre ramas.

### Prevención

Regenerar el runtime después de cambiar de rama y validar antes de levantar.

**Última verificación:** 2026-08-28, manifest versión 1 en
`scripts/farmia-worktree-runtime.mjs`.

## 3. Puerto Compose ocupado

### Síntoma

Docker falla con `Bind for 0.0.0.0:<puerto> failed: port is already allocated`.

### Causa habitual

Otro proyecto Compose o proceso conserva el puerto. Dos manifests con el mismo
`slot` generan el mismo conjunto de puertos aunque los proyectos tengan nombres
distintos.

### Diagnóstico

```powershell
docker compose ls
docker ps --format "table {{.Names}}\t{{.Ports}}\t{{.Label \"com.docker.compose.project\"}}"
Get-NetTCPConnection -State Listen | Where-Object LocalPort -eq <puerto>
```

Comparar el puerto con `ports` y `composeProject` del manifest. No asumir que el
contenedor cuyo nombre se parece al worktree es el único propietario.

### Solución segura

Detener el proyecto exacto que ya no se usa con su manifest o con
`docker compose --project-name <proyecto> ... down`. No agregar `--volumes`
salvo pedido explícito: las bases y objetos locales pueden ser valiosos. Si
ambos worktrees deben coexistir, asignar un slot libre y regenerar el runtime.

### Prevención

Mantener slots únicos, bajar proyectos al terminar y diagnosticar antes de
reutilizar puertos.

**Última verificación:** 2026-08-28; bases actuales: frontend 5200, API 3200,
worker 8200, PostgreSQL 5500 y LocalStack 4600, más el slot.

## 4. Frontend Windows: `spawn EINVAL`

### Síntoma

`npm run dev:worktree:frontend` termina inmediatamente con `ERROR: spawn EINVAL`.

### Causa

En Windows, Node debe invocar `npm.cmd` mediante shell en este flujo. Invocarlo
con `spawn()` sin `shell: true` produce `EINVAL` en algunas combinaciones de
Node/Windows.

### Diagnóstico

Revisar `scripts/start-worktree-frontend.mjs` y ejecutar la prueba enfocada:

```powershell
npm run check:worktree-startup
```

La rama actual debe resolver `{ command: 'npm.cmd', shell: true }` en `win32`.

### Solución segura

Alinear con la corrección versionada o portar el cambio a una rama temática con
su prueba. No parchear `main` sin commit ni copiar un script suelto desde otro
checkout. Después, regenerar/usar el launcher del checkout actual.

### Prevención

Conservar la prueba de plataforma y ejecutar `check:worktree-startup` al tocar
launchers o procesos hijos.

**Última verificación:** 2026-08-28; la corrección y su test están presentes en
el checkout activo.

## 5. Build Docker aparentemente detenido

### Síntoma

`docker compose build` tarda varios minutos en `apt-get`, `pip install`,
`npm run build` o exportación de capas.

### Causa habitual

Es un build frío: cambió una imagen base, lockfile, requirements, Dockerfile o
el cache no está disponible. Compilar TypeScript y exportar capas grandes también
consume CPU, disco y memoria de Docker Desktop.

### Diagnóstico

Observar qué etapa pierde `CACHED`, verificar recursos de Docker Desktop y
comparar si el segundo build reutiliza capas. Una etapa con progreso lento no es
por sí sola un deadlock.

### Solución segura

Esperar mientras haya progreso. Si se repite, revisar orden de `COPY`, tamaño del
contexto, `.dockerignore`, lockfiles y recursos asignados. No borrar todo el
cache o los volúmenes como primera medida.

### Prevención

Mantener dependencias copiadas antes del código cuando corresponda, contextos
pequeños y caches estables.

**Última verificación:** 2026-08-28, a partir de builds fríos observados en API y
worker.

## 6. Prisma, LocalStack y health checks

### Síntoma

Los contenedores arrancan pero la API, worker, S3 local o frontend no quedan
operativos.

### Causa habitual

El esquema todavía no se sincronizó, LocalStack no terminó su bootstrap, CORS o
los endpoints públicos apuntan a otro slot, o el launcher alcanzó su timeout.

### Diagnóstico

1. Confirmar manifest y proyecto Compose.
2. Revisar estado y logs del proyecto exacto.
3. Consultar sin mutar:
   - API: `http://localhost:<api>/health`
   - worker: `http://localhost:<worker>/health`
   - LocalStack: `http://localhost:<localstack>/_localstack/health`
   - frontend: `http://localhost:<frontend>/__farmia/runtime`
   - proxy: `http://localhost:<frontend>/api/health/live`
4. Verificar que la identidad del frontend coincida con rama y raíz.

### Solución segura

Usar `npm run dev:worktree:infra`, que espera LocalStack, ejecuta su bootstrap y
llama `prisma/deploy-db-push.js` antes de iniciar la aplicación. No reemplazarlo
por `prisma db push --force-reset`; no borrar base o volúmenes sin autorización.
Corregir puertos/orígenes regenerando el override desde el manifest.

### Prevención

Mantener health checks, bootstrap y sincronización Prisma dentro del launcher;
usar `scripts/diagnose-farmia-local.ps1` desde DevDocs antes de intervenir.

**Última verificación:** 2026-08-28, contra `start-worktree-infra.mjs` y el
launcher generado.

## Plantilla para nuevos incidentes

```markdown
## <incidente>

### Síntoma
### Causa
### Diagnóstico
### Solución segura
### Prevención

**Última verificación:** AAAA-MM-DD, commit o referencia comprobada.
```
