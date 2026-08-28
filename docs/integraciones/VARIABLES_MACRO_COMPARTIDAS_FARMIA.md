# Variables macro compartidas en FarmIA

Fecha de trabajo: 2026-08-03

## Ubicacion del cambio

- Repositorio: checkout activo de `farmia_app` en la máquina usada.
- Worktree aislado: worktree temático bajo la raíz configurada para esa máquina.
- Rama: `tincho/gestion-administrativa-macro-compartida`
- Base de creacion: `upstream/main` en `7096322cdc9069b965ce837ba3a6dbc185c83dcd`
- Destino previsto, solo cuando se autorice: push de esa rama a `upstream` y PR contra `upstream/main`.

No se hizo push, commit ni cambio directo sobre `main` durante este trabajo.

## Problema que resuelve

La pantalla de Variables macro permitia que cada usuario ejecutara manualmente las mismas consultas a BCRA y ArgentinaDatos. Eso duplicaba llamadas, podia producir historiales distintos entre empresas y hacia depender la vigencia de los datos de una accion humana.

La regla nueva separa dos clases de informacion:

- Las observaciones oficiales de mercado son globales. Un valor del dolar oficial, mayorista, MEP, CCL o blue para una fecha es el mismo para todos los workspaces.
- Las decisiones de una empresa siguen siendo privadas. `usd_manual`, `usd_proyeccion` y `usd_proyeccion_constante` continúan asociadas al perfil/workspace.

## Que se implemento

### Persistencia global

Se agregaron tres modelos Prisma sin `userId`:

- `VariableMacroSeriePublica`: catalogo de las cinco series externas.
- `VariableMacroValorPublico`: historico por serie y fecha.
- `VariableMacroSyncRun`: auditoria de cada ejecucion, incluidas fallas parciales y cantidad de filas creadas/actualizadas.

Los datos API que ya pudieran existir duplicados por workspace se copian de forma compatible a las tablas publicas. Si hay mas de una copia para la misma serie y fecha, prevalece la actualizada mas recientemente. Esta operacion no borra las filas legacy; la eliminacion queda deliberadamente pendiente hasta comparar staging y produccion.

### Sincronizacion central

El nuevo servicio consulta BCRA y ArgentinaDatos desde el backend. La carga historica inicial comienza en `2010-01-01` por defecto y BCRA se consulta en ventanas acotadas para respetar su limite. Las ejecuciones posteriores releen diez dias para absorber correcciones tardias.

Se agrego un CLI (`variables-macro-sync`) que no depende de un usuario. En AWS, EventBridge Scheduler lanza una tarea ECS efimera de lunes a viernes a las 21:30 de Argentina. Una fuente puede fallar sin descartar las series que sí se obtuvieron; el run queda auditado como `partial`.

Los endpoints manuales de sincronizacion se conservaron solo como recuperacion y requieren rol `admin`.

### Consumo en API y frontend

La API combina las series globales persistidas con las series privadas de la empresa manteniendo el contrato de lectura existente. Las conversiones y sugerencias de tipo de cambio resuelven correctamente ambos alcances.

La pantalla ya no ofrece a cada usuario un boton para llamar proveedores. Muestra el estado del dataset compartido, la fecha de mercado mas reciente y la ultima actualizacion. Los filtros de fecha solo consultan la base de FarmIA.

## Como funcionaria en produccion

1. El deploy aplica el schema con las tres tablas nuevas.
2. La primera lectura o sincronizacion copia de forma segura cualquier dato API legacy a las tablas publicas.
3. El scheduler ejecuta una unica tarea central por dia habil.
4. La tarea consulta los proveedores, hace upsert por serie/fecha y registra el run.
5. Todos los usuarios consumen el mismo historico desde PostgreSQL.
6. Cada empresa conserva y edita solamente sus valores manuales y proyecciones.

El sistema no depende de que un usuario tenga la pantalla abierta. BCRA y ArgentinaDatos no requieren secretos en esta integracion; no se guardaron credenciales en este documento ni en el repositorio.

## Validaciones realizadas

- Prisma schema valido y cliente generado.
- Build de API aprobado.
- TypeScript y build de frontend aprobados.
- `npm run check:types` aprobado, incluidos los controles de UI legacy, navegacion, autosave y rendimiento de imagery.
- 63 pruebas focalizadas aprobadas para Variables Macro y la politica de ownership de workspaces.
- `npm run check:api:test` aprobado: 143 suites; 2.477 casos aprobados y 2 omitidos, mas el control de deploy Prisma.
- Validador del worktree aprobado.
- `git diff --check` sin errores de whitespace.

No se ejecuto `terraform fmt/validate` porque Terraform no esta instalado en esta maquina. Tampoco se levanto el stack de este worktree para una comprobacion visual o una escritura en PostgreSQL local. Ambos puntos siguen siendo obligatorios antes del PR.

## Antes de subir a upstream

1. Confirmar que la rama sigue actualizada respecto de `upstream/main`; si hubo cambios relevantes, integrar `main` sin usar `origin/main`.
2. Revisar el diff completo y confirmar que no contiene secretos, archivos `.env`, dumps ni documentacion personal.
3. Ejecutar como minimo:
   - `npm run check:types`
   - `npm run check:api:test`
   - validacion de frontend y flujo en navegador
   - `terraform fmt -check` y `terraform validate` para `infra/app`
4. Levantar el stack del worktree y verificar:
   - una empresa nueva ve el mismo dataset global;
   - las series manuales/proyectadas no se comparten;
   - no existe una llamada externa al cambiar filtros o abrir la pantalla;
   - un fallo de proveedor conserva el historico anterior.
5. Probar el cambio primero en staging:
   - aplicar schema sin aceptar perdida de datos;
   - ejecutar una sincronizacion controlada;
   - comparar valores globales con muestras legacy;
   - observar salida y duracion de la task en CloudWatch;
   - confirmar horario real de publicacion de cada proveedor.
6. Definir alertas operativas para runs `failed`/`partial` o datos envejecidos. El registro existe, pero este cambio no agrega una alarma dedicada.
7. Solo luego de una conciliacion satisfactoria decidir si se eliminan las copias API legacy por workspace. Debe ser otro cambio reversible y revisado; este branch no las borra.
8. Solicitar revision explicita de Gestion/infra porque el PR toca Prisma, datos globales e infraestructura programada. El riesgo del PR es alto aunque la UI sea acotada.
9. Antes del push, declarar expresamente:
   - rama: `tincho/gestion-administrativa-macro-compartida`
   - remoto: `upstream`
   - comando previsto: `git push -u upstream tincho/gestion-administrativa-macro-compartida`
   - PR previsto: esa rama contra `upstream/main`

## Pendientes no bloqueantes para una siguiente iteracion

- Alarma/monitor visible para dataset desactualizado o ultimo run fallido.
- Politica de retencion para `VariableMacroSyncRun` si el historial operativo crece durante años.
- Limpieza controlada de filas API legacy, solo despues de verificar equivalencia.
- Confirmar con producto si fines de semana/feriados deben ejecutar igualmente una comprobacion o si basta el cron de dias habiles.
- Evaluar una fuente oficial directa para MEP/CCL/blue si en el futuro cambian requisitos de trazabilidad de ArgentinaDatos.
