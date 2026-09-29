# Prod vs staging vs local: plan de cultivos, historial y maestros

Estado documentado: 19 de agosto de 2026.

Analisis previo a probar en local la carga de `Planting HJN 25.26.xlsx`.
Fuentes: exports en `El Criterio/1- Prod`, `2- Staging`, `3- Local`, mas
inspeccion directa de la base local del worktree
`gestion-arreglos-historial` (`farmia_wt_gestion_arreglos_historial`).

## Resumen ejecutivo

| Tema | Prod | Staging | Local |
| --- | --- | --- | --- |
| Plan de cultivos | 344 filas | 344 filas (identico a prod) | 344 filas, 4 superficies distintas |
| Historial de cultivos | (no exportado) | 59 filas, 4 clientes | 29 filas, solo Aumaq |
| Historial de costos | no existe la feature | existe, sin datos exportados | 3 registros reales + 2 residuos E2E |
| Codigo | `main` | atrasado respecto de local | 7 commits + 29 archivos sin commitear |

Conclusion corta: **local y staging no son comparables hoy** ni en datos ni
en codigo. El historial de cultivos salio de archivos fuente distintos, y la
rama local tiene cambios de esquema que staging todavia no tiene.

## 1. Plan de cultivos

Prod y staging son **identicos en contenido** (mismas 344 filas; solo cambia
el orden de las filas en el CSV, por eso los hashes difieren).

Local difiere en exactamente 4 superficies:

| Lote | Staging / Prod | Local |
| --- | --- | --- |
| Aumaq / El Desafio / 21A | 27 | 26.84 |
| El Criterio / Don Juan / Completo | (vacio) | 497.26 |
| El Criterio / Laguna del Sol / LDS PERIM | 5112.06 | 12.68 |
| HJ Navas / La Emilia / IIB | 20.92 | 21.23 |

**Causa:** al copiar los lotes de staging a local (ver
[04-copiar-datos-staging-a-local.md](./04-copiar-datos-staging-a-local.md))
el `PATCH /lotes/:id/geometry` recalcula `superficieHa` a partir del
poligono. En 341 de 345 lotes el valor tipeado ya coincidia con la geometria;
en estos 4 no.

Los valores locales son los **geometricamente correctos** (verificado con
`ST_Area` sobre la geometria: coinciden al centavo). Los de staging son
valores cargados a mano que no concuerdan con su propia geometria. El caso
extremo es `LDS PERIM`: staging dice 5112.06 ha pero el poligono mide 12.68
ha — probablemente un perimetro en metros tipeado como hectareas.

## 2. Historial de cultivos

No es lo mismo que historial de costos: **el historial de cultivos es el
prerequisito**. Primero se define que se sembro en cada lote/campana, y
recien sobre eso se cargan costos.

| | Staging | Local |
| --- | --- | --- |
| Filas | 59 | 29 |
| Clientes | Aumaq 27, HJ Navas 15, Scarponi-Peloso-Cereales25 9, Scarponi-Peloso 8 | Aumaq 29 |
| Archivo origen | `farmia-historial-cultivos-2026-2027B.xlsx` | `farmia-historial-cultivos-2026-2027.xlsx` |
| Campana | 2026/2027 | 2026/2027 |
| Estado | todo `planificado` | todo `planificado` |

**Se cargaron archivos fuente distintos** (con y sin la `B`), asi que ni
siquiera coinciden los cultivos del mismo lote:

| Lote (Aumaq / El Desafio) | Staging | Local |
| --- | --- | --- |
| 1 | Girasol | Cebada |
| 10 | Girasol | Maiz |
| 18 A | Trigo | Cebada |
| 21A | Soja | Cebada |

Ademas staging cubre San Roque, HJ Navas y ambos Scarponi-Peloso, que en
local no tienen historial; y local cubre lotes de El Desafio (11 A, 11 B, 14,
15, 16, 17, 19, 26, 2B) que staging no tiene.

## 3. Historial de costos

- **Prod: la feature no existe todavia.** Por eso el export de prod trae
  `seguimiento-productivo` en su lugar.
- **Local:** 3 registros reales (Aumaq / El Desafio, lotes `1`, `10`, `11 A`,
  campana 2026/2027) mas 2 residuos de tests E2E (`E2E-GESTION-T2-...`), 10
  versiones y 10 mapeos de catalogo.
- **Staging:** tiene la feature pero no hay export de costos entre los
  archivos, asi que **no se pudo comparar**. Si hace falta, exportar el
  historial de costos de staging y repetir el cruce.

Los 2 registros E2E en local conviene borrarlos antes de probar, para que no
ensucien la lectura de la prueba.

## 4. Maestros agro (base local)

| Tabla | Filas |
| --- | --- |
| `cultivos_maestro` | 19 |
| `cultivos_variedades` | **0** |
| `productos_gestion` | 188 |
| `productos_presentaciones_gestion` | 3 |
| `familias_producto_gestion` | 18 |
| `categorias_producto_gestion` | 30 |
| `campanas` | 9 |

`cultivos_variedades` vacio es relevante: `Planting HJN 25.26` trae semillas
con variedad (`SOJA STINE 40 EA 53`, `MAIZ LT 722`, `TRIGO AYMARA`), asi que
o se crean variedades o se cargan como productos sueltos.

## 5. Estado del codigo

Rama local `tincho/gestion-arreglos-historial`: **7 commits por delante de
`main`** mas **29 archivos modificados sin commitear**, incluido
`api/prisma/schema.prisma`.

Commits no mergeados (los que staging no tiene):

```
18fed983 fix(gestion-agro): alinear auditoria de historial de costos
06a3d9e0 fix(gestion-agro): mostrar todas las subcampanas en historial
1c42f0e0 feat(gestion-agro): simplificar historial y diagnostico de costos
3026d0f2 feat(gis): sugerir cultivo de Gestion Agro al crear analisis...
bb74c90d feat(gestion-agro): columna Origen y antecedente precargado...
8855c263 feat(gestion-agro): sincronizar plan de cultivos con el historial...
a6cee3d1 fix(gestion-importaciones): aceptar UUID de cualquier version...
```

Como hay cambios de `schema.prisma` sin commitear, cualquier diferencia de
comportamiento entre staging y local puede venir del codigo, no de los datos.
No atribuir a datos lo que puede ser version.

## 6. `Planting HJN 25.26.xlsx` — que trae

Hoja `PLANTING 25-26 HJN`: **1416 filas de datos** (encabezado en la fila 7,
las 6 primeras estan vacias). Hoja `COSTOS`: resumen, no es dato de carga.

Columnas: `Campo | Cultivo | LOTE | FECHA | HAS LOTE | HAS LABOREADAS |
Produc./labor | Tipo | Dosis | Dosis tot. | Unidad | u$s/unit. | U$S TOT. |
Imp/ha | Proveedor | Tipo de cambio`

Total: **U$S 1.325.946**, 106 productos/labores distintos.

| Campo en la planilla | Filas | Etiquetas de lote | U$S |
| --- | --- | --- | --- |
| EL DESAFIO | 348 | 24 | 275.363 |
| LAGUNA DEL SOL | 300 | 8 | 251.873 |
| LA EMILIA | 214 | 18 | 189.801 |
| DON JUAN | 181 | 6 | 192.847 |
| STA CECILIA | 167 | 9 | 142.346 |
| LA CHIQUI | 89 | 2 | 72.988 |
| LA ESCUADRA | 59 | 4 | 101.793 |
| LA HORCONERA | 35 | 3 | 44.655 |
| LOS CERRITOS | 23 | 1 | 54.282 |

Grupos de costo (`Tipo`): HERBICIDAS 653, LABOR 316, HUMECTANTES 269,
FERTILIZANTES 77, SEMILLAS 52, INSECTICIDA 27, FUNGICIDA 5. Hay
inconsistencias de singular/plural (`HUMECTANTE` vs `HUMECTANTES`,
`FERTILIZANTE` vs `FERTILIZANTES`) y 1 fila con `Tipo` vacio.

Cultivos: `SOJA 2DA` y `SOJA 2da` conviven (mismo cultivo, distinta
capitalizacion).

## 7. Riesgo principal de la prueba de carga

**El importador matchea lote por nombre exacto y, si no lo encuentra, crea el
lote.** En `gestion-importaciones.service.ts`:

```ts
let lote = await tx.lote.findFirst({
  where: { campoId: campo.id, nombre: loteNombre },
});
if (!lote) {
  lote = await tx.lote.create({
    data: { campoId: campo.id, nombre: loteNombre,
      notas: 'Creado desde carga de historial de cultivos. Sin geometria GIS.' },
  });
}
```

Lo mismo aplica a cliente y campo. Cargar la planilla tal cual **crearia
campos y lotes fantasma sin geometria**, ensuciando los 345 lotes que se
acaban de copiar limpios de staging.

### Cobertura real

De **75 etiquetas de lote** en la planilla, solo **12 matchean directo**
(16%):

| Campo planilla | Existe en local | Match directo | Compuestos | Sin match |
| --- | --- | --- | --- | --- |
| EL DESAFIO | Aumaq / El Desafio | 10 | 11 | 3 |
| STA CECILIA | El Criterio / Santa Cecilia (alias) | 2 | 3 | 4 |
| DON JUAN | El Criterio / Don Juan | 0 | 3 | 3 |
| LA EMILIA | HJ Navas / La Emilia | 0 | 10 | 8 |
| LAGUNA DEL SOL | El Criterio / Laguna del Sol | 0 | 2 | 6 |
| LOS CERRITOS | HJ Navas / Los Cerritos | 0 | 0 | 1 |
| LA CHIQUI | **no existe** | — | — | 2 |
| LA ESCUADRA | **no existe** | — | — | 4 |
| LA HORCONERA | **no existe** | — | — | 3 |

Tres problemas distintos:

1. **Campos inexistentes**: `LA CHIQUI`, `LA ESCUADRA`, `LA HORCONERA` no
   estan en ningun cliente. Hay que decidir a que cliente pertenecen y si se
   crean o se excluyen de la prueba.
2. **Alias de campo**: `STA CECILIA` -> `Santa Cecilia`.
3. **Lotes compuestos**: la planilla usa `--` para labores que cubren varios
   lotes (`1--2--6--7`, `0--1--9--8--7`, `2B-7ABC-5HARAS-6-10A-11A-12A-14B`).
   FarmIA **ya usa la misma idea** pero con otra escritura: Santa Cecilia
   tiene lotes llamados `8 y 9`, `10 y 11`, `6 Y 7`. O sea que
   planilla `8--9` == base `8 y 9`.

Ademas las convenciones de nombre difieren por campo:

| Campo | Nombres en FarmIA | Nombres en la planilla |
| --- | --- | --- |
| Don Juan | `11 - 49`, `1A - 37`, `13A - 58.4` (nombre + superficie) | `1-13a-12`, `11-13A` |
| La Emilia | `IIA`, `IIB`, `III 1`, `IV`, `VI` (romanos) | `2`, `3.1`, `3.2`, `4` |
| Los Cerritos | `EL SOLO`, `MARIA NELIDA`, `DON LEON` | `EL SOL-MARIA NELIDA-DON LEON` (los 3 juntos, y `EL SOL` != `EL SOLO`) |
| Santa Cecilia | `Lote 1`, `Lote 15`, `8 y 9` | `1`, `15`, `8--9` |

## 8. Productos

Cruce grueso (match exacto por nombre/codigo) contra los 188
`productos_gestion` locales: 73 de 98 productos de la planilla ya existen, 25
no.

Pero ese numero **sobreestima el faltante**: el analisis fino ya esta hecho
en `FarmIA-Revision-mapeo-HJN-25.26.xlsx`, que distingue bien los casos:

| Solapa | Casos | Que son |
| --- | --- | --- |
| Productos pendientes | 6 | realmente nuevos (FLUMIOXAZIN, PARADISE, FLUMIOXAZIM, TRIGO-AIMARA...) |
| Aliases por confirmar | 13 | ya existen con otro nombre (`UREA` -> `UREA-GRANULADA`, `ATRAZINA 90%` -> `ATRAZINA`, `2,4-D ENLIST` -> `2-4-D`) |
| Parecidos a revisar | 10 | posibles duplicados entre si (`SOJA STINE 40 EA 53` vs `SOJA STINE 40 E 53`, 97%) |
| Labores manuales | 8 | van a Maestros Agro -> Tipos de labor, no a productos |
| Bolsas y packs | 15 | unidad de conteo sin factor conocido a kg/l/u |

Las 8 labores (`Siembra`, `Pulverizada terrestre`, `DISCO`, `RABASTO`,
`RESIEMBRA`, `FERTILIZACION AL VOLEO`, `Fertilizacion con altina`,
`Acondicionador`) **no son productos** y hay que darlas de alta aparte.

## 9. Orden sugerido para la prueba

1. Limpiar los 2 residuos E2E de `gestion_costos_historial` en local.
2. Decidir que hacer con `LA CHIQUI`, `LA ESCUADRA`, `LA HORCONERA` (crear
   bajo que cliente, o recortar la planilla para la prueba).
3. Resolver maestros primero, en el orden que indica la solapa
   "Leer primero" del archivo de revision: unidades -> productos listos ->
   alias confirmados. Despues labores y presentaciones.
4. Definir el mapeo de lotes (alias de campo + criterio para los compuestos)
   **antes** de importar, para no crear lotes fantasma.
5. Recien ahi correr la carga, y validar contra los totales de la planilla
   (U$S 1.325.946 y los subtotales por campo de la tabla de arriba).
