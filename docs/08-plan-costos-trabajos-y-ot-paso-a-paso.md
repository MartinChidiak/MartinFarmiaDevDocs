# Lote -> plan de costos -> trabajos -> OT — recorrido visual

Estado documentado: 21 de septiembre de 2026, contra la rama local
`tincho/planificacion-costos-cultivos` y la campaña operativa `2026/2027`.

Este informe reproduce el recorrido completo en la interfaz local. Se creó y
aprobó el plan, pero **no se creó ninguna OT**: las dos rutas se detuvieron en
la revisión previa para poder compararlas sin alterar la ejecución.

## 1. Caso usado

| Dato | Valor |
| --- | --- |
| Cliente | `Demo costos y OT 21122150` |
| Campo | `Campo Demostración` |
| Lote | `Lote Norte 36 ha` |
| Superficie | 36 ha |
| Campaña | 2026/2027 |
| Subcampaña | Gruesa |
| Cultivo | Soja |
| Rinde planificado | 3,2 tn/ha |
| Plan | `PLAN-2625be8c-0ca4-409c-9e43-24d879da13d6`, revisión 2 |
| Estado final | Aprobado |

Metadatos técnicos de la corrida:
[recorrido.json](./assets/08-plan-costos-trabajos-ot/recorrido.json).

## 2. Presupuesto coherente cargado

| Grupo | Concepto | Cálculo | Total |
| --- | --- | --- | ---: |
| Siembra | Siembra | 36 ha x USD 42/ha | USD 1.512,00 |
| Aplicación | Pulverización | 36 ha x USD 9/ha | USD 324,00 |
| Semilla | Semilla de soja | 36 ha x 70 kg/ha x USD 0,62/kg | USD 1.562,40 |
| Agroquímicos | Glifosato | 36 ha x 2,5 l/ha x USD 6,80/l | USD 612,00 |
| | **Presupuesto detallado** | | **USD 4.010,40** |

Necesidades calculadas: 2.520 kg de semilla de soja y 90 l de glifosato.

## 3. Paso a paso con capturas

### Paso 1 — Dar de alta el lote

En `Análisis GIS > Lotes`, elegir `Nuevo lote > Carga manual`. El asistente
crea cliente, campo y lote. Se informó 36 ha y se dejó la geometría para más
adelante; alcanza para este recorrido de Gestión.

![Alta del lote](./assets/08-plan-costos-trabajos-ot/01-alta-lote-datos.png)

El lote queda creado y conserva la superficie informada.

![Lote creado](./assets/08-plan-costos-trabajos-ot/02-lote-creado.png)

### Paso 2 — Asignar el cultivo a la campaña operativa

En `Gestión Agro > Planificar > Plan de cultivos`, abrir `Tabla completa`,
ubicar el lote y elegir `Gruesa`, `Soja` y `3,2 tn/ha`.

![Asignar cultivo y rinde](./assets/08-plan-costos-trabajos-ot/03-asignar-cultivo-campana.png)

Al guardar, la fila queda vinculada a Soja y disponible inmediatamente para
el plan de costos.

![Cultivo asignado](./assets/08-plan-costos-trabajos-ot/04-cultivo-asignado.png)

### Paso 3 — Buscar el mismo lote para presupuestarlo

En `Plan de costos e insumos > Por lote`, buscar `Lote Norte 36 ha`. La fila
confirma cliente, cultivo, superficie y estado `Sin plan`; desde allí se usa
`Presupuestar lote`.

![Buscar el lote a presupuestar](./assets/08-plan-costos-trabajos-ot/05-presupuestar-lote-busqueda.png)

Elegir `Empezar desde cero`, sin plantilla.

![Empezar desde cero](./assets/08-plan-costos-trabajos-ot/06-plan-desde-cero.png)

### Paso 4 — Detallar por grupo

Elegir `Detallar por grupo`. Primero se cargó Siembra sobre todo el cultivo a
USD 42/ha.

![Detalle de la labor de siembra](./assets/08-plan-costos-trabajos-ot/07-detalle-labor-siembra.png)

Después se cargó Semilla de soja a 70 kg/ha y USD 0,62/kg.

![Detalle de semilla](./assets/08-plan-costos-trabajos-ot/08-detalle-insumo-semilla.png)

También se agregaron Pulverización a USD 9/ha y Glifosato a 2,5 l/ha y
USD 6,80/l. El total calculado del glifosato es USD 612.

![Presupuesto detallado completo](./assets/08-plan-costos-trabajos-ot/09-presupuesto-detallado-completo.png)

### Paso 5 — Convertir conceptos en trabajos

En `Costos y trabajos`, los conceptos detallados aparecen en la bandeja `Del
plan, sin asignar`. Una labor puede iniciar un trabajo y los insumos marcados
se incorporan al mismo trabajo.

![Bandeja de conceptos sin asignar](./assets/08-plan-costos-trabajos-ot/10-bandeja-conceptos-sin-asignar.png)

Se marcó Semilla de soja y se usó `Crear trabajo con esta labor` sobre
Siembra. El trabajo resultante conserva labor, 36 ha, dosis, cantidad y costo
del detalle.

![Trabajo de siembra con su insumo](./assets/08-plan-costos-trabajos-ot/11-trabajo-siembra-con-insumo.png)

Se repitió la lógica para `Aplicación preemergente`, reuniendo Pulverización y
Glifosato. Además, desde `Nuevo trabajo` se creó `Cosecha prevista`, con labor
Cosecha y tarifa de USD 85/ha, sin insumos.

![Nuevo trabajo manual de cosecha](./assets/08-plan-costos-trabajos-ot/12-nuevo-trabajo-manual.png)

El plan terminó con tres trabajos y sin conceptos detallados pendientes de
asignar.

![Tres trabajos armados](./assets/08-plan-costos-trabajos-ot/13-trabajos-armados.png)

### Paso 6 — Aprobar el plan

`Aprobar plan` congela esa revisión. Desde entonces no se edita: cualquier
cambio debe ir a un sucesor. Esta aprobación es la que habilita programar OT
desde sus trabajos.

![Revisión antes de aprobar](./assets/08-plan-costos-trabajos-ot/14-revision-aprobacion-plan.png)

### Paso 7 — Planificar OT desde el plan de costos

Al abrir `Siembra de soja > Programar OT`, el contexto ya está fijado por el
plan. Se proponen las 36 ha pendientes y aparecen fecha, tercero, equipo,
notas y la revisión operativa. El dinero queda en el plan; a la OT pasan labor,
superficie e insumos previstos.

![OT desde el plan de costos](./assets/08-plan-costos-trabajos-ot/15-ot-desde-plan-costos.png)

### Paso 8 — Planificar OT desde Operaciones

En `Gestión Agro > Ejecutar > Operaciones > Planificar OT`, primero se eligen
campaña y cultivo. FarmIA ofrece los tres trabajos pendientes del plan, pero
inicialmente deja seleccionada la alternativa `OT independiente`.

![Elegir origen en Operaciones](./assets/08-plan-costos-trabajos-ot/16-operaciones-elegir-trabajo-plan.png)

Al elegir `Siembra de soja`, la OT queda vinculada a la revisión 2 y se copian
la labor, las 36 ha y la semilla prevista.

![Trabajo del plan seleccionado en Operaciones](./assets/08-plan-costos-trabajos-ot/17-ot-desde-operaciones.png)

La revisión final muestra los mismos datos operativos de la ruta anterior.

![Revisión de OT desde Operaciones](./assets/08-plan-costos-trabajos-ot/18-ot-desde-operaciones-revision.png)

## 4. Comparación de las dos rutas de OT

| Tema | Desde Plan de costos | Desde Operaciones | Evaluación |
| --- | --- | --- | --- |
| Contexto inicial | Plan, cultivo y trabajo ya fijados | Hay que elegir cultivo y luego trabajo | Diferencia razonable por el punto de entrada |
| Origen | Siempre el trabajo aprobado | Trabajo aprobado o independiente | Cumple la necesidad de OT sin plan |
| Estado de salida | `Crear borrador` | `Crear borrador` | Alineado |
| Ejecución | El texto aclara que requiere aprobación | El encabezado aclara que requiere aprobación | Alineado |
| Campos | ha, fecha, tercero, equipo, notas | los mismos, más campaña/cultivo | Alineado en lo operativo |
| Insumos | Copia Semilla de soja, 70 kg/ha, 2.520 kg | copia exactamente lo mismo | Alineado |
| Costos | No pasan a la OT | No pasan a la OT | Alineado e intencional |
| Ubicación | `Lote Norte 36 ha` | `Cliente / Campo / Lote` | **No alineado** |
| Opción independiente | No aplica en ese punto de entrada | Queda seleccionada por defecto | Útil, pero puede hacer omitir el plan sin una decisión explícita |
| Etiqueta de superficie | `Hectáreas a programar` | `Ha planificadas` | Misma semántica, distinto lenguaje |

Los textos extraídos de ambos resúmenes coinciden en plan/revisión, trabajo,
cultivo, labor, superficie, fecha, tercero, equipo, notas e insumo. La única
diferencia de dato es la ubicación abreviada frente a la ruta completa.

## 5. Hallazgos

### Hechos comprobados

1. Una OT nacida del plan sólo se ofrece después de aprobarlo; ambas rutas la
   crean como borrador y no la ejecutan.
2. La OT copia la foto operativa del trabajo: revisión de origen, labor,
   superficie, fecha, tercero, equipo, notas y cantidades previstas. No copia
   importes.
3. `Siembra de soja` suma USD 3.074,40 y `Aplicación preemergente` USD 936;
   juntas explican exactamente el presupuesto de USD 4.010,40.
4. `Cosecha prevista`, creada manualmente desde `Nuevo trabajo`, tiene un costo
   propio calculado de USD 3.060, pero el total del presupuesto detallado sigue
   siendo USD 4.010,40. Por lo tanto, en este modo el costo manual del trabajo
   queda en el lado operativo/comparativo y no modifica el detalle
   presupuestado.
5. Desde Operaciones, antes de elegir uno de los trabajos aprobados, la pantalla
   afirma `OT independiente seleccionada`.

### Inferencia

El modelo ya separa correctamente dos responsabilidades: el detalle por grupo
es la fuente del presupuesto y los trabajos son la organización operativa que
después puede producir OT. Esa separación permite OT sin costos, pero el caso
de `Nuevo trabajo` hace fácil creer que su tarifa se incorporó al presupuesto
cuando en realidad queda como diferencia contra él.

### Recomendaciones

1. Cuando el cultivo tenga trabajos aprobados pendientes, pedir una elección
   explícita entre `Usar trabajo del plan` y `Crear OT independiente`, sin dejar
   la independiente seleccionada implícitamente. Debe seguir siendo posible
   crearla sin plan.
2. Usar la misma ubicación completa en ambas revisiones. El plan ya tiene
   cliente, campo y lote en su contexto.
3. Unificar la etiqueta de superficie; `Hectáreas a programar` expresa mejor
   que se consume el saldo del trabajo aprobado.
4. Antes de aprobar, destacar la diferencia entre presupuesto y trabajos. En
   este caso debería verse como una advertencia explícita: trabajos USD 7.070,40
   frente a presupuesto USD 4.010,40, diferencia USD -3.060.
5. Aclarar dentro de `Nuevo trabajo` que, cuando el plan está en modo
   `Detallar por grupo`, una tarifa manual organiza/valoriza el trabajo pero no
   reemplaza ni aumenta el presupuesto por grupos.

## 6. Estado local dejado para revisar

- El ejemplo aprobado queda disponible en local con el cliente
  `Demo costos y OT 21122150`.
- El borrador intermedio generado al ajustar el recorrido fue eliminado junto
  con su cliente/campo/lote; sólo queda el caso final aprobado.
- No se creó OT, no se hizo commit y no se hizo push.
