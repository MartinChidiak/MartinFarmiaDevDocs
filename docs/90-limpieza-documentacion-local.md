# Limpieza de documentacion local

Fecha de relevamiento: 2026-08-10.

## Alcance inspeccionado

Carpetas revisadas:

- `C:\Users\marti\OneDrive\Farmia\0_Instructivos`
- `C:\Users\marti\OneDrive\Farmia\1_Objetivo_Pasos`
- `C:\Users\marti\OneDrive\Farmia\2_Auditorias`
- `C:\Users\marti\OneDrive\Farmia\3_Competencia`
- `C:\Users\marti\OneDrive\Farmia\personal-codex\docs`
- `C:\Users\marti\OneDrive\Farmia\farmia_app\docs`

No se borraron archivos durante esta primera pasada.

## Hechos

- `farmia_app/docs` ya contiene una documentacion compartida amplia y mas
  actual que los instructivos historicos.
- `2_Auditorias` concentra muchos reportes de estado puntual, corridas E2E,
  snapshots, errores de Playwright y exportaciones.
- `0_Instructivos` contiene guias de junio que pueden contradecir la estructura
  actual del monorepo.
- `personal-codex/docs/integraciones` tenia dos documentos no versionados que
  son candidatos claros para `MartinFarmiaDevDocs`: A3 MarketData y Variables
  Macro Compartidas.
- El repo `MartinFarmiaDevDocs` fue clonado limpio desde GitHub en
  `C:\Users\marti\OneDrive\Farmia\MartinFarmiaDevDocs`.

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

Destino: `C:\Users\marti\OneDrive\Farmia\MartinFarmiaDevDocs\docs`.

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
`C:\Users\marti\OneDrive\Farmia\archivo-documentacion-local\YYYY-MM-DD`.

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

## Proxima pasada sugerida

1. Crear carpeta local `archivo-documentacion-local\2026-08-10`.
2. Mover ahi auditorias y artefactos temporales, sin borrar todavia.
3. Dejar en la raiz solo documentos que se consultan activamente.
4. Extraer de cada auditoria vigente una decision corta hacia DevDocs.
5. Borrar artefactos generados solo cuando no aporten evidencia unica.
