# Propuesta: superficie informada vs. superficie del shape

**Estado: propuesta personal, NO implementada.** Anotada el 19 de agosto de
2026 para retomar mas adelante. No esta en `farmia_app`, no hay rama ni PR,
no se hablo con el equipo.

Contexto de donde salio:
[05-diferencias-prod-staging-local-gestion-agro.md](./05-diferencias-prod-staging-local-gestion-agro.md),
seccion 1 (las 4 superficies que diferian entre staging y local).

> Nota sobre las referencias de codigo: los numeros de linea son del worktree
> `gestion-arreglos-historial` al 19-ago-2026, que tenia cambios sin
> commitear. Van a driftear. Buscar por el nombre de la funcion, no por la
> linea.

## El diagnostico

No es que un entorno se comporte distinto de otro: es el mismo codigo. Lo que
decide el valor final es **el orden de las operaciones sobre el dato**.

Tres caminos escriben geometria y **los tres pisan `superficieHa` con el area
calculada del poligono**:

| Camino | UI | Ancla |
| --- | --- | --- |
| `PATCH /lotes/:id/geometry` | dibujar / editar perimetro | `updateGeometry` en `lote-geometry.service.ts` |
| `POST /lotes/:id/geometry/upload` | subir SHP a un lote | `uploadGeometry` |
| commit de importacion masiva | "Importar / dibujar varios" | `commitCampoGeometryImport` |

Dos caminos escriben la superficie **sin mirar la geometria**, sin validacion
ni aviso:

- `PATCH /lotes/:id` — modal "Editar lote" (`LotesService.update`, escribe
  `data: dto` tal cual)
- `POST /campos/:campoId/lotes` — alta de lote

Y al leer **nunca se recalcula**:

```ts
// api/src/common/utils/lot-surface.ts
export function resolveLotSurfaceHa(superficieHa, resumen) {
  return superficieHa ?? extractSurfaceHaFromResumen(resumen);
}
```

Gana siempre el valor guardado; el unico fallback es el resumen de un
analisis, nunca el poligono. **Una vez que el valor guardado y la geometria
divergen, quedan divergentes para siempre y no se nota en ninguna pantalla.**

Corolario: hay un bug real de comportamiento — si volves a subir el shape,
te pisa en silencio un valor informado a proposito.

## Por que no alcanza con "forzar siempre la calculada"

Hay casos legitimos donde el numero informado **no** deberia ceder ante la
geometria: superficie util vs. perimetral, un lote con una zona no laborable
dentro del poligono, un valor corregido a mano por criterio agronomico. El
agujero no es que se pueda tipear: es que **nada avisa cuando los dos numeros
dejan de coincidir**.

## La propuesta

Guardar el area del shape como dato propio, y marcar el origen del valor
vigente.

```prisma
model Lote {
  superficieHa     Decimal?  // vigente — lo que consume todo el sistema (NO cambia)
  superficieGeomHa Decimal?  @map("superficie_geom_ha")  // area del poligono
  superficieOrigen String?   @map("superficie_origen")   // 'geometria' | 'manual'
}
```

Decisiones de fondo y su porque:

- **Persistir en vez de calcular al leer.** Los listados son el camino
  caliente (345 lotes, dashboards, compartidos). Los caminos de geometria
  **ya calculan** ese numero (`calculateGeometryAreaHa`, que corre PostGIS en
  SQL crudo dentro del API), asi que escribirlo sale casi gratis. Ademas
  convierte la auditoria en una consulta SQL trivial.
- **`superficieHa` sigue siendo la fuente de verdad.**
  `resolveLotSurfaceHa` lo consumen clientes, compartidos, admin, exports y
  el sync de planes. Cambiarle la semantica tiene un radio de impacto enorme
  para el beneficio que da.

### Cambio de comportamiento en los caminos de escritura

| Camino | Hoy | Propuesto |
| --- | --- | --- |
| Cargar / editar shape | pisa `superficieHa` siempre | escribe `superficieGeomHa` siempre; `superficieHa` **solo si origen != 'manual'** |
| Editar superficie a mano | escribe y listo | escribe + marca `origen = 'manual'` |
| "Usar la del shape" | no existe | `superficieHa = superficieGeomHa`, `origen = 'geometria'`, + `syncUnlockedPlans` |

**Detalle de implementacion importante:** hay ~17 sitios en
`lote-geometry.service.ts` que escriben `superficieHa` (create/replace de los
distintos flujos de import). Tocarlos uno por uno es garantia de
inconsistencia. Va un helper unico —algo como
`buildSurfacePatch(actual, geomHa)`— que decida la regla en un solo lugar.

### Umbral del aviso

No alarmar por redondeo. **Avisar solo si la diferencia supera 1% Y 0,5 ha**
(las dos condiciones). Contra los datos reales de staging se comporta bien:

| Lote | Guardada | Shape | Diferencia | Alerta |
| --- | --- | --- | --- | --- |
| El Criterio / Laguna del Sol / LDS PERIM | 5112,06 | 12,68 | ~40.000% | **Si** — error de carga (parece perimetro en metros) |
| HJ Navas / La Emilia / IIB | 20,92 | 21,23 | 1,5% / 0,31 ha | No — posible superficie util |
| Aumaq / El Desafio / 21A | 27 | 26,84 | 0,6% / 0,16 ha | No — redondeo |

**No reutilizar `LOTE_SURFACE_TOLERANCE_HA`** (= 0,01, en
`lote-surface-sync.service.ts`): esa constante es para igualdad en el sync de
planes, es otro proposito.

Separar **informacion** de **alarma**: en la ficha del lote mostrar siempre
los dos numeros sin juicio ("27 ha informada · shape 26,84 ha"), y el aviso
visible solo por encima del umbral.

### Accion masiva

A nivel campo o cliente: "Recalcular superficies desde shape", **con preview
obligatorio**. El preview tiene que mostrar que lotes cambian, de cuanto a
cuanto, y —clave— **que planes se sincronizan y cuales no**.

`LoteSurfaceSyncService.syncUnlockedPlans` ya devuelve `executedIds`: los
cultivos con `haSembradas` o `haCosechadas` > 0, que **no toca**. Eso debe
aparecer en el preview ("3 planes quedan desalineados porque ya tienen
siembra cargada"). Sin eso, el recalculo desalinea el plan de cultivos en
silencio, que es justo el problema que se quiere evitar.

Cualquier recalculo tiene que pasar por `syncUnlockedPlans`, nunca escribir
el lote directo.

## Fases sugeridas

1. **Visibilidad, sin cambiar comportamiento.** Columnas + backfill (una sola
   SQL con la expresion PostGIS de abajo) + exponer en la API + mostrar ambos
   numeros en la ficha del lote. No rompe nada.
2. **Accion.** Boton "usar la del shape" en el modal + accion masiva con
   preview.
3. **Proteccion.** Que los caminos de geometria respeten `origen = 'manual'`.
   Es el que mas valor da, pero es cambio de comportamiento: merece decision
   explicita y nota en el changelog.

### Alternativa barata para validar la idea antes de tocar el esquema

Exponer el area calculada solo en `GET /lotes/:id` (una llamada a
`calculateGeometryAreaHa`) y mostrar la comparacion unicamente en la ficha.
No da auditoria masiva ni proteccion, pero es poco trabajo y dice si el aviso
es util en la practica.

## Consulta de auditoria

Sirve hoy, sin implementar nada, para medir el alcance en cualquier entorno:

```sql
WITH calc AS (
  SELECT cl.nombre AS cliente, ca.nombre AS campo, l.nombre AS lote,
         l.superficie_ha AS guardada,
         round((ST_Area(
           ST_GeomFromGeoJSON((l.geometry_geojson->'features'->0->'geometry')::text)::geography
         )/10000.0)::numeric, 2) AS calculada
  FROM lotes l
  JOIN campos ca ON l.campo_id = ca.id
  JOIN clientes cl ON ca.cliente_id = cl.id
  WHERE l.geometry_geojson IS NOT NULL AND l.archived_at IS NULL
)
SELECT *, round(guardada - calculada, 2) AS dif
FROM calc
WHERE guardada IS NULL OR abs(guardada - calculada) > 0.01
ORDER BY abs(coalesce(guardada, 0) - calculada) DESC;
```

Nota: solo mira `features->0`. Para lotes multi-feature hay que agregar antes
(el `calculateGeometryAreaHa` del API sí disuelve todos los features con
`ST_UnaryUnion`).

Medicion al 19-ago-2026 en el worktree `gestion-arreglos-historial`: 352
lotes con shape, 0 sin superficie, **0 divergentes** — pero eso es artificial:
la copia desde staging termino con un `PATCH /geometry` en cada lote, que
forzo el recalculo en todos. La medicion que importa es la de produccion.

## Decisiones abiertas

- Si `superficieOrigen` arranca en `'geometria'` para todo el backfill, o si
  los lotes que hoy divergen se marcan `'manual'` (asumiendo que la
  divergencia fue intencional). Lo segundo es mas conservador y evita pisar
  valores puestos a proposito.
- Si el umbral del aviso deberia ser configurable por usuario/cliente o
  alcanza con una constante.
- Si el KML/SHP exportado deberia incluir los dos numeros en la descripcion
  (hoy `exportGeometry` manda solo `superficie_ha`).
