# Limpieza de documentacion local

Fecha de relevamiento: 2026-08-10.

`<raiz-historica-FarmIA>` representa la carpeta local usada durante esta
auditoria. Es evidencia historica, no una ruta requerida por los scripts.

## Alcance inspeccionado

Carpetas revisadas:

- `<raiz-historica-FarmIA>\0_Instructivos`
- `<raiz-historica-FarmIA>\1_Objetivo_Pasos`
- `<raiz-historica-FarmIA>\2_Auditorias`
- `<raiz-historica-FarmIA>\3_Competencia`
- `<raiz-historica-FarmIA>\Gestion - Agro`
- el checkout privado de DevDocs usado entonces;
- el checkout de `farmia_app` usado entonces.

No se borraron archivos durante esta primera pasada.

## Hechos

- `farmia_app/docs` ya contiene una documentacion compartida amplia y mas
  actual que los instructivos historicos.
- `2_Auditorias` concentra muchos reportes de estado puntual, corridas E2E,
  snapshots, errores de Playwright y exportaciones.
- `0_Instructivos` contiene guias de junio que pueden contradecir la estructura
  actual del monorepo.
- `docs/integraciones` del checkout privado tenia dos documentos no versionados que
  son candidatos claros para `MartinFarmiaDevDocs`: A3 MarketData y Variables
  Macro Compartidas.
- El repo `MartinFarmiaDevDocs` fue clonado limpio desde GitHub en
  un checkout local de `MartinFarmiaDevDocs`.

## Clasificacion recomendada

### Mantener como fuente actual

Destino: `farmia_app/docs`, versionado por rama y PR en el repo de app.

Usar para:

- contratos compartidos de arquitectura;
- reglas que Leo u otro colaborador debe respetar;
- setup local y validacion;
- decisiones que afectan ramas, PRs, staging, production, AWS o datos.

Ejemplos ya existentes:

- `docs/ARCHITECTURE.md`
- `docs/PROJECT_STRUCTURE.md`
- `docs/DATA_AND_FIXTURES.md`
- `docs/GIT_TEAM_WORKFLOW.md`
- `docs/GESTION_UI.md`

### Versionar en MartinFarmiaDevDocs

Destino: `docs/` del checkout local de `MartinFarmiaDevDocs`.

Usar para:

- mapas personales de lectura;
- criterios de priorizacion y limpieza;
- resumenes de integraciones propias antes de PR;
- decisiones privadas que no son contrato de equipo.

Ya incorporado en esta pasada:

- `docs/README.md`
- `docs/01-mapa-farmia-actual.md`
- `docs/02-gestion-operativa-actual.md`
- `docs/90-limpieza-documentacion-local.md`
- `docs/integraciones/A3_MARKETDATA_FARMIA.md`
- `docs/integraciones/VARIABLES_MACRO_COMPARTIDAS_FARMIA.md`

### Archivar localmente

Destino sugerido:
`<raiz-historica-FarmIA>\archivo-documentacion-local\YYYY-MM-DD`.

Usar para:

- auditorias completas ya reemplazadas por docs curadas;
- reportes de una corrida puntual;
- comparaciones de branches ya cerradas;
- screenshots y `error-context.md` que solo prueban un fallo viejo.

No subir a Git salvo que se convierta en una decision vigente.

### Candidatos a borrar despues de revisar

Borrar solo luego de una segunda pasada humana o si existe respaldo claro.

Patrones con bajo valor durable:

- `playwright-report*/data/*.md`
- `e2e-artifacts/**/error-context.md`
- `final-artifacts/**/error-context.md`
- exportaciones `.xlsx` generadas por auditorias;
- reportes repetidos de la misma prueba manual cuando solo cambia timestamp;
- capturas o evidencia derivada de bugs ya cerrados y documentados.

### No versionar nunca

- `.env`, `.env.*`
- tokens, passwords, API keys o claves privadas;
- dumps SQL/PostgreSQL;
- artefactos con datos reales de clientes;
- carpetas `data/`, `data_erp/`, `facturas_ai/` si contienen informacion
  real;
- reportes HTML/Playwright completos con datos sensibles.

## Primera decision sobre carpetas locales

### `0_Instructivos`

Mantener temporalmente. Convertir solo lo vigente a docs cortas.

Riesgo: varios archivos de junio hablan de setup, login, Swagger o estructura
previa. Antes de usarlos, comparar con `farmia_app/docs/README.md`,
`COMO_INICIAR_SERVICIOS.md` y `PROJECT_STRUCTURE.md`.

### `1_Objetivo_Pasos`

Tratar como roadmap historico. No usar como backlog vigente sin comparar contra
codigo actual, tests y `docs/ARCHITECTURE.md`.

### `2_Auditorias`

Separar en:

- `historico-resumible`: reportes principales que contienen decisiones o
  hallazgos todavia utiles.
- `evidencia-temporal`: snapshots, error-context, reportes HTML y outputs.
- `eliminable`: duplicados timestamped y exportaciones reproducibles.

Recomendacion: no copiar masivamente a DevDocs.

### `3_Competencia`

Conservar si sirve como benchmark de producto. No mezclar con documentacion
tecnica de FarmIA salvo que se transforme en una decision concreta.

## Primera pasada ejecutada

Ejecutado el 2026-08-10.

Destino:
`<raiz-historica-FarmIA>\Archivado\documentacion-local-archivada\2026-08-10`.

Se movieron carpetas historicas o de evidencia temporal, sin borrar contenido:

| Destino | Origen | Archivos |
| --- | --- | ---: |
| `01_instructivos_historicos\0_Instructivos` | `0_Instructivos` | 12 |
| `02_planes_historicos\1_Objetivo_Pasos` | `1_Objetivo_Pasos` | 1 |
| `03_auditorias_y_evidencia\2_Auditorias` | `2_Auditorias` | 3116 |
| `04_referencias_competencia\3_Competencia` | `3_Competencia` | 23 |
| `05_farmios_test_prints\5_farmios_test\prints` | `5_farmios_test\prints` | 165 |

Total archivado: 3318 archivos, aproximadamente 713 MB.

La carpeta raiz `0_Instructivos` quedo vacia, pero no se pudo eliminar por un
bloqueo de permisos/OneDrive. Su contenido fue movido correctamente.

La carpeta `5_farmios_test` quedo sin contenido visible despues de mover
`prints`.

El checkout privado fue sincronizado con `MartinFarmiaDevDocs`: los dos documentos
de integraciones dejaron de existir como archivos no versionados y ahora viven
como archivos versionados del repo privado.

## Proxima pasada sugerida

1. Intentar eliminar la carpeta vacia `0_Instructivos` cuando OneDrive libere
   el bloqueo.
2. Revisar los pendientes tecnicos marcados en
   `03-auditorias-gestion-decisiones-curadas.md`.

## Segunda pasada ejecutada

Ejecutado el 2026-08-10.

Se revisaron reportes principales dentro de:
`<raiz-historica-FarmIA>\Archivado\documentacion-local-archivada\2026-08-10\03_auditorias_y_evidencia\2_Auditorias`.

Las decisiones todavia utiles quedaron extraidas en:
`docs/03-auditorias-gestion-decisiones-curadas.md`.

Conclusiones:

- los reportes markdown principales siguen archivados como contexto historico;
- las decisiones vigentes ya tienen un resumen corto en el checkout privado;
- se eliminaron 76 carpetas generadas por Playwright, HTML reports,
  screenshots, videos, traces, exportaciones reproducibles y carpetas
  `artifacts*`;
- la limpieza retiro 1454 archivos generados, aproximadamente 355 MB;
- `03_auditorias_y_evidencia\2_Auditorias` quedo con 1662 archivos,
  aproximadamente 210 MB, sin carpetas generadas de esos patrones;
- `adm-zip@0.5.17` queda como pendiente tecnico real, no como asunto de
  limpieza documental.

## Revision adicional: `Gestion - Agro`

Ejecutado el 2026-08-10.

La carpeta `<raiz-historica-FarmIA>\Gestion - Agro` era material local
historico, no un checkout util del repo: tenia `.git`, pero `git status`
indicaba una rama `master` sin commits, sin remotos y con todos los documentos
sin versionar.

Contenido relevado:

- 160 archivos, aproximadamente 25 MB;
- 1 markdown de auditoria/storytelling del 22/07/2026;
- 2 documentos Word narrativos del 24/07/2026;
- 5 PDFs renderizados;
- 96 PNGs de capturas o QA visual;
- 2 scripts Python de construccion de documentos.

Se extrajeron a `03-auditorias-gestion-decisiones-curadas.md` las decisiones
que agregaban valor: guion de demo, limites de MVP y advertencias para no
presentar forecast, deuda, stock o Caja como si fueran el mismo hecho.

El hallazgo historico sobre variables BCR en `api/.env.example` fue contrastado
contra `farmia_app` actual y ya esta absorbido: el ejemplo, `docker-compose.yml`
y `market-price.providers.ts` usan los nombres actuales.
