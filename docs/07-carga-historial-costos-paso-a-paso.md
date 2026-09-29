# Cargar historial de costos desde una planilla propia — paso a paso

Estado documentado: 19 de agosto de 2026, contra la rama
`tincho/gestion-arreglos-historial` (mergeada con `upstream/main`).

Guia para entender el flujo y despues transmitirlo al cliente. Escrita a
partir del codigo (`gestion-costos-historial.service.ts`,
`gestion-agro-maestros.controller.ts`), no de la UI.

## 1. El modelo mental: la cadena de dependencias

Historial de costos es la **ultima capa** de una cadena. Cada eslabon tiene
que existir antes del siguiente:

```
Lote con superficie > 0   (GIS)
        v
Campana                    (maestro global)
        v
Cultivo del lote en esa campana
   -> Historial de cultivos  (lo que efectivamente se sembro)
   -> o Plan de cultivos     (lo planificado)
        v
[FarmIA genera la plantilla YA PRECARGADA con esas identidades]
        v
Costos: productos, labores, dosis, precios
```

La identidad de un registro de costos es
**lote + campana + cultivo** (`uq_gestion_costo_historial_identidad`). Por eso
no se puede cargar costos "sueltos": FarmIA necesita saber a que cultivo de
que lote y campana imputarlos.

**Consecuencia practica que sorprende:** no se descarga una plantilla en
blanco y se llena. Se **prepara** una plantilla eligiendo el contexto
(campana, cultivo, lotes), y baja con esas filas ya identificadas. Si despues
se editan a mano las columnas Campana, Cultivo o Lote de una fila preparada,
la importacion falla con *"No modifiques Campana, Cultivo ni Lote..."*.

## 2. Precondiciones duras (validadas por el importador)

| Precondicion | Mensaje de error si falta |
| --- | --- |
| El lote existe en la ruta Cliente/Campo/Lote | `La ruta Cliente / Campo / Lote no existe` |
| La ruta no es ambigua | `La ruta Cliente / Campo / Lote es ambigua` |
| Nada archivado | `El lote, campo o cliente esta archivado` |
| **Lote con superficie > 0** | `Falta cargar la superficie del lote; definila en el lote o subi su shape antes de importar costos` |
| El cultivo existe en Maestros Agro | `El cultivo no existe en Maestros Agro` |
| El grupo de costo existe y esta activo | `El grupo de costo X no existe o esta archivado` |

Sobre la superficie, el comentario del codigo es explicito: *"La superficie
fisica del lote es la verdad unica: declarada a mano o derivada de su shape.
Sin ella no hay Ha lote confiable."* (ver
[06-propuesta-superficie-lote-informada-vs-shape.md](./06-propuesta-superficie-lote-informada-vs-shape.md)).

## 3. Los dos maestros que todo el mundo confunde

Este es el punto que mas hay que explicarle al cliente. El propio codigo lo
documenta como un problema que hubo que arreglar:

> *"Tipo, Componente, Labor / producto y Labor / etapa asociada se alimentaban
> de tres maestros distintos con nombres solapados: 'Fertilizacion' podia ser
> un grupo de costo o un tipo de labor en columnas vecinas."*

| | **Grupo de costo** | **Tipo de labor** |
| --- | --- | --- |
| Que es | La bolsa contable donde cae el gasto | La tarea fisica que se hizo |
| Maestro | Maestros Agro > Grupos de costo | Maestros Agro > Tipos de labor |
| Ejemplos | Agroquimicos, Fertilizantes, Semilla, Aplicacion, Siembra | Pulverizada terrestre, Disco, Siembra |
| Columna | `Grupo de costo` | `Labor asociada` |

La aclaracion clave del sistema: *"Un mismo producto puede ir a grupos
distintos segun como se uso: una semilla puede imputarse a Semilla o a Semilla
de cobertura."* O sea, **el grupo de costo no es un atributo fijo del
producto**, es como se imputo esa vez.

Y hay una regla que confunde: en una fila de **producto**, `Labor asociada`
es **obligatoria** (con que labor se aplico). En una fila de **labor**, FarmIA
completa solo `Labor asociada`, `Dosis = 1` y `Unidad = ha`.

### Grupos de costo que vienen sembrados (11)

| Tipo insumo | Tipo labor |
| --- | --- |
| Agroquimicos | Aplicacion |
| Fertilizantes | Cosecha |
| Otros insumos | Dosis variable (VRT) |
| Semilla | Fertilizacion |
| Semilla de cobertura | Otras labores |
| | Siembra |

Son **por perfil de usuario** y se pueden crear/editar
(`POST /gestion-costos-historial/grupos`).

## 4. Las dos plantillas (no confundirlas)

### a) Plantilla de catalogo (`FARMIA_HISTORIAL_COSTOS_CATALOGO_V4`)

Vincula cada concepto con su grupo de costo. Columnas:

`Accion | Clase | Codigo | Concepto | Grupo de costo`

- `Accion`: `existente` (documenta lo vigente), `nuevo` (agrega vinculacion),
  `desvincular`, `reactivar`
- `Clase`: `Labor` o `Producto`

**No da de alta maestros.** El codigo es tajante: *"Esta planilla ya no crea
labores ni productos. Si un concepto no existe, dalo de alta primero en
Maestros Agro y descarga el catalogo de nuevo."*

### b) Plantilla de carga (hoja `Carga`)

La version vigente al 20 de agosto de 2026 tiene 24 columnas visibles:

`Campana | Cliente | Campo | Lote | Cultivo | Fecha | Ha lote | Ha laboradas |
Que se cargo | Grupo de costo | Labor asociada | Dosis | Cantidad total |
Unidad | Moneda | TC ARS/USD | Costo unitario | U$S TOT | U$S/Ha |
Proveedor | Responsable | Fuente del precio | Referencia de origen | Notas`

Reglas:
- `Ha lote` = superficie fisica GIS; `Ha laboradas` = lo realmente trabajado
  (se ajusta a mano)
- `Fuente del precio` es **obligatoria**
- `Moneda` vacia = USD; `ARS` exige `TC ARS/USD`
- En labor: total = `Ha laboradas` x `Costo unitario`
- Amarillo = obligatorio pendiente; gris = no aplica a esa fila
- Solo se importa la hoja `Carga`; las demas son informativas

## 5. Paso a paso para el cliente

**Orden obligatorio.** Cada paso desbloquea el siguiente.

### Paso 0 — GIS listo
Lotes creados con su shape (o al menos superficie declarada > 0).
`Analisis GIS > Lotes`.

### Paso 1 — Maestros Agro
`Configuracion > Maestros Agro` (`/configuracion/maestros-agro`)

En este orden (las dependencias van de arriba hacia abajo):
1. **Unidades** — l, kg, u, ha, bolsa, pack, tn, g, ml
2. **Familias** y **Categorias** de producto
3. **Productos** — cada uno con familia, categoria y unidad base
4. **Tipos de labor**
5. **Cultivos** (y **Variedades** si se usan semillas identificadas)

### Paso 2 — Proveedores
`Configuracion > Maestros administrativos`
(`/configuracion/maestros-administrativos`). Hacen falta para `Proveedor` y
`Fuente del precio`.

### Paso 3 — Grupos de costo
Revisar los 11 sembrados y crear los propios si el esquema contable del
cliente no encaja.

### Paso 4 — Catalogo: concepto -> grupo de costo
Descargar la plantilla de catalogo (baja precargada con lo vigente), asignar
grupo a cada producto/labor nuevo, y subirla. Si falta un concepto, volver al
Paso 1: **el catalogo no crea maestros**.

### Paso 5 — Cultivo por lote y campana
`Gestion Agro > Historial de cultivos` (`/flujos/historial-cultivos`) o
`Plan de cultivos`. Sin esto no hay de donde generar la plantilla de costos.

### Paso 6 — Preparar la plantilla de costos
`Gestion Agro > Historial de costos` (`/flujos/historial-costos`). Elegir
campana, cultivo y lotes; opcionalmente prefiltrar por grupos de costo y
pedir N filas vacias por contexto. Baja el Excel precargado.

### Paso 7 — Completar y subir
Llenar solo la hoja `Carga`. Subir -> **preview** (valida fila por fila y
muestra errores) -> **aplicar**. La preview no escribe nada; recien `aplicar`
persiste.

### Paso 8 — Correcciones
Para corregir algo ya cargado se descarga una plantilla en modo `replace`,
que viene atada a la version activa del historial. Si el historial cambio
desde la descarga, la importacion se rechaza y hay que bajar una nueva.

## 6. El caso concreto: `Planting HJN 25.26` en local

### Subconjunto elegible (solo lotes con match directo de nombre)

**156 filas de 1416**, en 12 lotes de 2 campos:

| Lote | Filas | U$S | Cultivo en la planilla |
| --- | --- | --- | --- |
| El Desafio / 12 | 22 | 8.011 | SOJA |
| El Desafio / 2 | 4 | 175 | MAIZ T |
| El Desafio / 20 | 15 | 11.366 | ALPISTE |
| El Desafio / 21B | 12 | 863 | SOJA |
| El Desafio / 22 | 18 | 14.256 | SOJA |
| El Desafio / 23 | 19 | 14.059 | GIRASOL |
| El Desafio / 24 | 6 | 1.599 | MAIZ T |
| El Desafio / 10 | 11 | 2.096 | MAIZ T |
| El Desafio / 6 | 7 | 1.965 | MAIZ T |
| El Desafio / 7 | 6 | 1.363 | MAIZ T |
| Santa Cecilia / 12 | 16 | 6.286 | MAIZ |
| Santa Cecilia / 2 | 20 | 15.548 | SOJA |

### BLOQUEANTE: la campana no coincide

La planilla es de **campana 2025/2026** (fechas del 31-05-2025 al 31-12-2026,
y el nombre lo dice). En local, la campana 2025/2026 tiene:

| Campana | Historial cultivos | Plan cultivos | Historial costos |
| --- | --- | --- | --- |
| 2025/2026 | **0** | **0** | **0** |
| 2026/2027 | 27 | 29 | 3 |

Todo el contexto de cultivos esta en 2026/2027. Por eso los cultivos no
coinciden con la planilla (El Desafio/12: planilla SOJA, FarmIA Trigo; /20:
planilla ALPISTE, FarmIA Trigo; etc.) — **no son datos contradictorios, son
campanas distintas.**

Sin cultivo en 2025/2026 no se puede preparar la plantilla de costos. **Hay
que hacer el Paso 5 primero**, cargando el historial de cultivos 2025/2026 con
los cultivos que dice la propia planilla.

### Maestros que faltan para este subconjunto

Solo 33 productos y 4 labores distintas (contra 106 del archivo completo).

**10 productos a resolver** (varios son alias, no altas nuevas — cruzar con
`FarmIA-Revision-mapeo-HJN-25.26.xlsx`):

`2,4-D ENLIST` · `2,4-D ESTER` · `BIOFUSION` · `CLETODIM` · `CORRECTOR H` ·
`GLIFOSATO 48 AGM` · `S-METOLACLOR` · `SOJA STINE 40 E 53` · `SPEEDWET` ·
`UREA`

**3 tipos de labor a crear:** `Pulverizada terrestre` · `Acondicionador` ·
`Fertilizacion con altina`

### Mapeo Tipo -> Grupo de costo a decidir

| `Tipo` en la planilla | Filas | Grupo de costo sugerido |
| --- | --- | --- |
| HERBICIDAS | 75 | Agroquimicos |
| LABOR | 32 | segun la labor (Aplicacion / Siembra / Otras) |
| HUMECTANTES | 32 | **a decidir**: Agroquimicos u Otros insumos |
| FERTILIZANTES | 9 | Fertilizantes |
| SEMILLAS | 5 | Semilla |
| INSECTICIDA | 3 | Agroquimicos |

`HUMECTANTES` es la decision de fondo: son coadyuvantes, no principios
activos. Depende de como el cliente quiera ver su margen.

### Unidades

`LTS` -> `l` (112) · `UNIDAD` -> `u` (32) · `KG` -> `kg` (7) ·
`BOLSAS` -> `bolsa` (1) · **4 filas sin unidad** (hay que completarlas).

## 7. Orden sugerido para la prueba en local

1. Empezar por **un solo lote y una sola fecha dentro de 2025/2026**. El caso
   elegido es `El Desafio / 12`, fecha 04-03-2026, cultivo Soja.
2. Crear primero su Plan de cultivos o Historial de cultivos 2025/2026.
3. Resolver productos, labores y terceros sin duplicar maestros que ya tengan
   un alias valido.
4. Mapear los conceptos al grupo de costo.
5. Generar la plantilla oficial desde ese contexto; no reutilizar ni adaptar
   directamente la planilla fuente como plantilla de costos.
6. Completar y previsualizar tres lineas: labor, Furia y Glifosato.
7. Aplicar solo si las tres filas quedan validas y el total esperado es
   U$S 528,24.
8. Escalar recien despues a otros lotes coincidentes.

`El Desafio / 2`, que antes se habia sugerido como smoke test, se descarta:
sus cuatro costos estan fechados el 03-10-2026 (fuera de 2025/2026) y la
planilla declara 267 ha contra 21,86 ha fisicas en FarmIA.

## 8. Pendiente futuro: cobertura incompleta de `Analizar maestros con IA`

Estado: **diagnosticado el 20 de agosto de 2026; no corregir ahora**.

La accion `Historial de costos > Administrar catalogo > Analizar maestros con
IA` no analiza necesariamente todas las filas del archivo. El comportamiento
actual del API es:

- admite XLSX o CSV de hasta 5 MB;
- inspecciona como maximo las primeras 4 hojas;
- por hoja recorre solamente las primeras 120 posiciones y toma hasta 80 filas
  no vacias;
- envia como maximo 160 filas en total y considera hasta 24 columnas por fila;
- omite antes del envio fechas, numeros y columnas sensibles detectables;
- la respuesta admite como maximo 100 conceptos, descarta propuestas con menos
  de 55 % de confianza y deduplica por clase + codigo.

Por lo tanto, en una planilla de una sola hoja con 1.500 filas, la IA recibe
como maximo unas 80 filas. Un resultado como `70 conceptos detectados` significa
70 conceptos unicos aceptados dentro de esa muestra; **no prueba que se hayan
revisado las 1.500 filas**.

Ademas, este boton produce solamente un diagnostico efimero. No crea productos
o labores, no guarda aliases, no confirma vinculaciones y no modifica el
catalogo. Las propuestas pueden quedar como ya vinculadas, vinculacion
pendiente, maestro archivado, coincidencia a revisar o alta requerida.

### Problema de interfaz

El API ya devuelve `sheets[].sampledRows`, pero la pantalla no muestra esa
informacion. El usuario no puede distinguir una revision completa de una
muestra y puede interpretar el numero de conceptos como cobertura total.

### Mejora recomendada para cuando se retome

1. Leer todas las filas del archivo de forma deterministica.
2. Normalizar y deduplicar todas las combinaciones de producto/labor y tipo.
3. Resolver primero codigos, nombres y aliases exactos contra Maestros Agro.
4. Enviar a la IA solamente los conceptos unicos no resueltos, divididos en
   lotes seguros.
5. Agregar y deduplicar las respuestas de todos los lotes.
6. Mostrar cobertura explicita, por ejemplo:
   `1.500 filas leidas · 240 conceptos unicos · 170 vinculados · 45 para revisar · 25 sin resolver`.
7. Mantener el diagnostico sin efectos laterales: cualquier alta o vinculacion
   debe seguir requiriendo confirmacion humana en Maestros Agro o en el catalogo
   FarmIA.

Dividir manualmente el archivo en bloques de 70-80 filas permite cubrirlo como
solucion provisoria, pero no debe considerarse el flujo definitivo.

## 9. Ejecucion local del caso `El Desafio / 12`

Fecha de ejecucion: 20 de agosto de 2026. Usuario local: El Criterio.

### Criterio de identidad

La planilla no trae una columna de cliente confiable. La vinculacion se hizo
exclusivamente por `Campo + Lote` normalizados:

- fuente: `EL DESAFIO / 12`;
- destino local: cliente GIS `Aumaq`, campo `El Desafio`, lote `12`;
- superficie fisica FarmIA: **49,97 ha**;
- superficie declarada por la fuente: **33 ha**;
- superficie realmente trabajada en las tres lineas elegidas: **31 ha**.

No se reemplazo la superficie local por la del Excel. En costos, `Ha lote`
debe seguir siendo 49,97 y `Ha laboradas` debe ser 31.

### Lineas fuente elegidas

| Fila fuente | Concepto fuente | Mapeo FarmIA | Dosis | Cantidad | U$S/u | Total | Proveedor |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 1231 | Pulverizada terrestre | Labor `Pulverizacion` / Aplicacion | 1 | 31 ha | 6 | 186 | El Criterio |
| 1232 | FURIA | Producto `Furia` / Agroquimicos | 0,22 l/ha | 6,82 l | 19,5 | 132,99 | HJN |
| 1234 | GLIFOSATO 48 AGM | Producto `Glifosato` / Agroquimicos | 1,5 l/ha | 46,5 l | 4,5 | 209,25 | HJN |

Total esperado: **U$S 528,24**. Dividido por la superficie fisica de 49,97
ha, el costo consolidado esperado es aproximadamente **U$S 10,570342/ha**.

La fila 1233 (`SOGIX`) se excluyo del smoke test porque la fuente contiene una
inconsistencia: 9,3 l x U$S 0,356 = U$S 3,3108, pero el total guardado en el
archivo es U$S 15. No se eligio automaticamente cual de esos dos valores es
correcto.

### Respaldo previo

Antes de escribir se genero y verifico un dump restaurable de PostgreSQL en:

`C:\Users\marti\AppData\Local\FarmIA\backups\historial-costos-20260820-111051\agroapp.dump`

### Altas y reutilizaciones

- Soja ya existia en Cultivos maestros; no se creo otro cultivo.
- Furia ya existia; se reutilizo.
- Glifosato ya existia y el alias `GLIFOSATO 48 AGM` ya apuntaba a ese
  producto. El intento de crear otro fue rechazado con HTTP 409, por lo que no
  se duplico.
- `Pulverizacion` ya existia como tipo de labor. Se uso como equivalencia de
  `Pulverizada terrestre`; no se creo una labor redundante.
- Se dio de alta el tercero `HJN`.
- Se dio de alta el tercero `El Criterio`, vinculado al cliente GIS del mismo
  nombre. Esto no cambia que el lote de destino pertenezca a Aumaq.
- Se configuraron las vinculaciones `Pulverizacion -> Aplicacion`,
  `Furia -> Agroquimicos` y `Glifosato -> Agroquimicos`.

### Contexto de cultivo creado

Se creo un Plan de cultivos de **Soja**, campaña **2025/2026**, subcampaña
`gruesa`, para `El Desafio / 12`, con **49,97 ha planificadas**. No se invento
fecha de siembra, cosecha ni produccion.

Como Planificacion solo permite escribir en la campaña operativa, se cambio
temporalmente el periodo local a marzo de 2026, se creo el plan y en un bloque
de restauracion se devolvio la configuracion a **agosto de 2026 / campaña
2026/2027**. La configuracion final fue verificada.

### Plantilla y preview

FarmIA genero una plantilla oficial `append` con tres filas y la identidad
preparada. Quedo guardada fuera de Git en:

`C:\Users\marti\AppData\Local\FarmIA\backups\historial-costos-20260820-111051\FarmIA-costos-El-Desafio-lote-12-preparada.xlsx`

La plantilla ya contiene campaña, cliente, campo, lote, cultivo, fecha,
superficie fisica, conceptos, grupos, unidad, moneda, labor asociada y fuente
de precio. Faltan completar 11 celdas obligatorias:

- fila labor: 31 ha, U$S 6/ha, proveedor El Criterio;
- fila Furia: 31 ha, dosis 0,22, U$S 19,5/l, proveedor HJN;
- fila Glifosato: 31 ha, dosis 1,5, U$S 4,5/l, proveedor HJN.

Se ejecuto dos veces el preview real para confirmar las validaciones. Ambos
intentos quedaron `preview_blocked`, con 3 filas y 0 validas. La labor exige
`Ha laboradas` y `Costo unitario`; cada producto exige ademas `Dosis`. No se
emitio `applyToken` y por lo tanto **no se aplico ningun costo**.

En esta sesion no estaba disponible la dependencia autorizada para editar
XLSX (`@oai/artifact-tool`). No se reemplazo por una escritura directa con
otra libreria ni se insertaron costos saltando el importador. El estado local
final conserva las altas, los mapeos y el plan; el historial de costos del
caso sigue vacio hasta completar la plantilla y obtener un preview valido.
