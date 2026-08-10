# Mapa actual de FarmIA

Fecha de relevamiento: 2026-08-10.

## Hechos verificados

- Checkout activo inspeccionado:
  `C:\Users\marti\OneDrive\Farmia\farmia_app`.
- El repo activo esta en `main` y atrasado 39 commits respecto de
  `upstream/main` al momento del relevamiento.
- La documentacion compartida principal vive en `farmia_app/docs`.
- `farmia_app/AGENTS.md` declara que el producto activo es el monorepo
  FarmIA / AgroApp, no la vieja app Streamlit.
- Apps activas segun `AGENTS.md` y `docs/PROJECT_STRUCTURE.md`:
  `frontend/`, `api/`, `worker/` y `mobile/`.
- Flujo core: `Cliente -> Campo -> Lote -> Analisis`.
- Gestion operativa vive bajo rutas `/flujos/*`.

## Fuentes autoritativas para empezar

En `farmia_app`:

- `AGENTS.md`: reglas operativas para Codex y convenciones del repo.
- `docs/README.md`: indice de documentacion compartida.
- `docs/CONTEXT.md`: orientacion rapida del proyecto.
- `docs/PROJECT_STRUCTURE.md`: mapa actual de carpetas y dominios.
- `docs/ARCHITECTURE.md`: contratos, riesgos y reglas de negocio.
- `docs/DATA_AND_FIXTURES.md`: datos versionados, datos locales y artefactos.
- `docs/GIT_TEAM_WORKFLOW.md`: ramas, PRs, staging y produccion.

## Modulos principales

### Frontend

- Entrada: `frontend/src/main.tsx`.
- Rutas: `frontend/src/App.tsx`.
- Paginas: `frontend/src/pages/`.
- Componentes por dominio: `frontend/src/components/`.
- Tipos API: `frontend/src/lib/types/`.
- Hooks API: `frontend/src/lib/hooks/`.

Superficies principales:

- GIS/agronomia: clientes, campos, lotes, analisis, prescripcion,
  comparaciones, monitoreo.
- Gestion: `frontend/src/pages/flujos/` y `frontend/src/components/flujos/`.
- Mobile-first Monitoreo: `mobile/`, no `components/flujos/`.
- Admin/soporte/equipo: `/ops`, `/equipo`, access sharing.

### API

- Entrada HTTP: `api/src/main.ts`.
- Registro de modulos: `api/src/app.module.ts`.
- Modelo de datos: `api/prisma/schema.prisma`.
- Workers dedicados Nest:
  - `api/src/document-ai-worker.ts`
  - `api/src/analysis-processing-worker.ts`
  - `api/src/cosecha-ndvi-worker.ts`

Grupos relevantes:

- Core agro: `clientes`, `campos`, `lotes`, `campanas`, `analisis`.
- Archivos y procesamiento: `archivos`, `biblioteca`, `jobs`, `storage`.
- Acceso y soporte: `auth`, `me`, `compartidos`, `workspaces`, `admin`.
- Gestion: `gestion-agro`, `gestion-documentos`, `facturas`,
  `movimientos`, `ordenes-pago`, `proyeccion`, `variables-macro`,
  `cartas-porte`, `reservas`, `convenios-flujo`, `proveedores-flujo`.

### Worker

- Entrada: `worker/main.py`.
- Pipeline principal: `worker/services/processor.py`.
- GIS/export: `worker/modules/`.
- Contrato fragil: el worker lee DB/S3 directamente y consume JSONB de
  `Analisis`.

### Mobile

- App Expo/React Native para Monitoreo de campo.
- El roadmap vigente es mobile-first y offline-first.
- No debe mezclarse con Gestion salvo enlaces contextuales de lectura.

## Contratos fragiles

- `ARCHIVO_TIPOS` debe coincidir en frontend, API y worker.
- S3 de analisis usa patrones historicos que el worker consume.
- `Analisis.opciones`, `parametrosFinancieros` y `mapeosColumnas` son JSONB
  implicitos entre UI, API y worker.
- Gestion mueve dinero fisico solo mediante `Movimiento`; proyecciones,
  documentos, ordenes o stock no son Caja por existir.
- Documentos IA siempre requiere revision humana antes de crear entidades
  operativas.
- Stock de insumos y granos se explica desde ledgers fisicos, no desde
  totales inventados.

## Inferencia

La documentacion local anterior a mediados de julio de 2026 debe tratarse como
historica por defecto. Muchas rutas, modelos y reglas de Gestion cambiaron
despues de esas auditorias.

## Recomendacion

Usar este archivo como puerta de entrada personal. Para cambios de codigo o PRs
en `farmia_app`, abrir primero los docs compartidos del repo activo y verificar
contra codigo actual.
