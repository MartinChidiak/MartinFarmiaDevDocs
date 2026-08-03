# Manual de carga de datos Gestion

Este manual explica como cargar desde la UI el flujo demo completo
`GESTION-UI-DEMO-20260610130452`. El objetivo es que una persona pueda recrear
datos de practica en Gestion y despues entender que representa cada dato cuando
lo consulta como usuario final.

## Alcance

- Alcance: local, datos de practica, modulo Gestion.
- Fuera de alcance: produccion, staging, inserts SQL directos, cambios de API,
  cambios de Prisma schema o cargas masivas.
- Regla operativa: cargar desde la UI. Usar DBeaver solo para verificar.
- Prefijo del ejemplo: `GESTION-UI-DEMO-20260610130452`.

El flujo confirmado en la base local contiene:

| Area | Registro demo |
| --- | --- |
| Proveedor | `GESTION-UI-DEMO-20260610130452 Proveedor Insumos` |
| Cliente Gestion | `GESTION-UI-DEMO-20260610130452 Cliente Comercial` |
| Cuenta financiera | `GESTION-UI-DEMO-20260610130452 Caja Operativa` |
| Categorias | `GESTION-UI-DEMO-20260610130452 Insumos`, `GESTION-UI-DEMO-20260610130452 Venta granos` |
| Producto | `GESTION-UI-DEMO-20260610130452 Fertilizante MAP` |
| Deposito | `GESTION-UI-DEMO-20260610130452 Deposito Mixto` |
| Cultivo | `GESTION-UI-DEMO-20260610130452 Maiz Demo` |
| Orden/laboreo | `GESTION-UI-DEMO-20260610130452 Fertilizacion base` |
| Contrato | `GESTION-UI-DEMO-20260610130452 Acopio Comprador` |
| Cartas/movimientos grano | `GESTION-UI-DEMO-20260610130452-CP-001`, `GESTION-UI-DEMO-20260610130452-CP-002` |
| Liquidacion | `GESTION-UI-DEMO-20260610130452-LIQ-001` |
| Factura | `GESTION-UI-DEMO-20260610130452-FAC-001` |
| Orden de pago | `GESTION-UI-DEMO-20260610130452-OP-001` |

## Antes de cargar

1. Entrar a FarmIA local y abrir `Gestion`.
2. Usar el prefijo completo en nombres, referencias, cartas de porte, facturas
   y liquidaciones. Eso permite encontrar todo rapido en DBeaver.
3. Tener al menos una campana disponible. Las pantallas de Gestion Agro y
   Finanzas piden `Campana`.
4. Para el ejemplo, usar ubicacion manual en el cultivo:
   - Cliente/empresa: `GESTION-UI-DEMO-20260610130452 Empresa Agricola`
   - Campo: `GESTION-UI-DEMO-20260610130452 Campo Escuela`
   - Lote: `GESTION-UI-DEMO-20260610130452 Lote Norte`
5. No crear datos con SQL si el objetivo es practicar la experiencia real. La UI
   aplica validaciones que un insert directo puede saltear.

Las rutas principales existen en `frontend/src/App.tsx`. El boton de carga
manual y los accesos `?registrar=...` se resuelven en
`frontend/src/components/flujos/RegistroGestion.tsx`.

## 1. Maestros base

Los maestros son datos reutilizables. Se cargan primero porque otros flujos los
necesitan como listas seleccionables.

### 1.1 Proveedor

| Punto | Detalle |
| --- | --- |
| Ruta UI | `/flujos/proveedores` |
| Accion | `Nuevo proveedor` |
| Obligatorios | `Nombre` |
| Opcionales | CUIT, contacto, telefono, email, notas |
| Tabla principal | `proveedores_flujo` |
| Relacion posterior | Se usa en factura recibida, orden de pago, compra de insumo, OT y laboreo como proveedor/contratista |
| Usuario final ve | Ficha 360 del proveedor, facturas pendientes, pagos, saldo y actividad |

Restricciones conocidas:

- Si el proveedor ya tiene facturas, movimientos o documentos aplicados, la baja
  segura es desactivar, no borrar definitivamente.
- La factura a pagar tambien permite crear proveedor rapido, pero para una carga
  ordenada conviene crearlo antes desde `/flujos/proveedores`.

### 1.2 Cliente de Gestion

| Punto | Detalle |
| --- | --- |
| Ruta UI | `/flujos/clientes` |
| Accion | `Nuevo cliente de Gestion` |
| Obligatorios | `Nombre` |
| Opcionales | CUIT, contacto, telefono, email, notas |
| Tabla principal | `clientes_flujo` |
| Relacion posterior | Se usa para facturas emitidas/cuentas a cobrar |
| Usuario final ve | Cliente comercial separado de la estructura GIS `Cliente -> Campo -> Lote` |

Restricciones conocidas:

- `clientes_flujo` no reemplaza a `clientes` del arbol GIS. Es un maestro
  comercial de Gestion.
- Si el cliente tiene facturas emitidas, la baja recomendada es desactivar para
  conservar historial.

### 1.3 Cuenta financiera

| Punto | Detalle |
| --- | --- |
| Ruta UI | `/flujos/cuentas-financieras` |
| Accion | `Nueva cuenta` |
| Obligatorios | `Nombre` |
| Opcionales | tipo, moneda, saldo inicial, observaciones |
| Tabla principal | `cuentas_financieras` |
| Relacion posterior | Se vincula a ordenes de pago y movimientos de caja |
| Usuario final ve | Caja/banco con saldo inicial, ingresos, egresos y saldo actual |

Restricciones conocidas:

- El nombre es unico por usuario.
- Si la cuenta tiene movimientos u ordenes de pago, no se debe borrar; se
  desactiva para conservar trazabilidad.

### 1.4 Categorias

| Punto | Detalle |
| --- | --- |
| Ruta UI | `/flujos/categorias` |
| Accion | `Nueva categoria` o carga de categorias estandar |
| Obligatorios | nombre, tipo (`ingreso` o `egreso`) |
| Opcionales | icono, color |
| Tabla principal | `categorias` |
| Relacion posterior | Clasifica movimientos, facturas emitidas, proyeccion y reportes |
| Usuario final ve | Agrupaciones de ingresos/egresos en Caja, Proyeccion y reportes |

Para este demo usar:

- `GESTION-UI-DEMO-20260610130452 Insumos`, tipo `egreso`.
- `GESTION-UI-DEMO-20260610130452 Venta granos`, tipo `ingreso`.

Restricciones conocidas:

- Una categoria con movimientos reales no se elimina definitivamente desde la UI.
  La alternativa segura es desactivarla.

## 2. Inventario

Inventario separa el maestro del producto, el lugar fisico y los movimientos de
stock.

### 2.1 Producto

| Punto | Detalle |
| --- | --- |
| Ruta UI | `/flujos/insumos?registrar=producto` o `/flujos/insumos` + carga manual |
| Accion | `Nuevo producto` |
| Obligatorios | nombre, unidad |
| Opcionales | tipo, stock minimo, costo referencia, activo |
| Tabla principal | `productos_gestion` |
| Relacion posterior | Se usa en movimientos de insumo y laboreos con insumo |
| Usuario final ve | Catalogo de insumos/productos disponibles para stock y labores |

Ejemplo demo: `GESTION-UI-DEMO-20260610130452 Fertilizante MAP`.

Restricciones conocidas:

- Un producto con movimientos o labores no se borra definitivamente. Se
  desactiva.
- El tipo visible incluye agroquimico, fertilizante, semilla, combustible u otro.

### 2.2 Deposito

| Punto | Detalle |
| --- | --- |
| Ruta UI | `/flujos/insumos?registrar=deposito` o `/flujos/insumos` + carga manual |
| Accion | `Nuevo deposito` |
| Obligatorios | nombre |
| Opcionales | tipo (`mixto`, `insumos`, `granos`), ubicacion, activo |
| Tabla principal | `depositos_gestion` |
| Relacion posterior | Origen/destino de insumos y granos |
| Usuario final ve | Lugar fisico donde se guarda stock |

Ejemplo demo: `GESTION-UI-DEMO-20260610130452 Deposito Mixto`.

Restricciones conocidas:

- Para usar el mismo deposito en insumos y granos, elegir `mixto`.
- Un deposito con stock, granos o labores asociadas se desactiva, no se borra.

### 2.3 Compra de insumo

| Punto | Detalle |
| --- | --- |
| Ruta UI | `/flujos/insumos?registrar=movimiento-insumo` |
| Accion | `Compra de insumo` |
| Obligatorios | fecha, producto, deposito, cantidad |
| Opcionales | costo unitario, observaciones |
| Tabla principal | `movimientos_insumo` |
| Relacion posterior | Aumenta stock disponible para laboreos |
| Usuario final ve | Entrada de stock y costo de referencia del insumo |

Ejemplo demo:

- Movimiento `compra`.
- Producto MAP.
- Deposito mixto.
- Cantidad: `15000`.
- Costo unitario: `940`.

Restricciones conocidas:

- El modal de carga rapida crea una `compra`. El consumo operativo se genera
  despues desde `Registrar laboreo`, no editando manualmente la compra.
- Para movimientos de salida, consumo, transferencia o ajuste negativo, el
  backend valida que no se supere el stock disponible.

## 3. Produccion

### 3.1 Cultivo de campana

| Punto | Detalle |
| --- | --- |
| Ruta UI | `/flujos/produccion?registrar=cultivo` |
| Accion | `Nuevo cultivo` |
| Obligatorios | campana, cultivo, ubicacion |
| Opcionales | subcampana, convenio, variedad, estado, ha planificadas, ha sembradas, fecha de siembra, rinde estimado |
| Tabla principal | `gestion_cultivos` |
| Relacion posterior | Base para OT, laboreo, cosecha, stock de grano y margen operativo |
| Usuario final ve | Cultivo operativo de campana con superficie, estado y ubicacion |

Ejemplo demo:

- Cultivo: `GESTION-UI-DEMO-20260610130452 Maiz Demo`.
- Ubicacion manual: Empresa Agricola / Campo Escuela / Lote Norte.
- Ha sembradas: `118`.

Restricciones conocidas:

- La ubicacion puede ser manual o vinculada a un lote existente. Si se vincula a
  lote, se usa el arbol Core `Cliente -> Campo -> Lote`.
- El backend exige lote o ubicacion manual. No alcanza con cargar solo campana y
  cultivo.
- Este cultivo no es un `analisis` GIS. Es la unidad operativa de Gestion.

## 4. Operaciones

### 4.1 Orden de trabajo

| Punto | Detalle |
| --- | --- |
| Ruta UI | `/flujos/labores?registrar=orden` |
| Accion | `Planificar OT` |
| Obligatorios | campana, cultivo, labor, ha planificadas |
| Opcionales | fecha planificada, proveedor/contratista, maquinaria, estado, notas |
| Tabla principal | `ordenes_trabajo` |
| Relacion posterior | Se puede seleccionar al registrar el laboreo real |
| Usuario final ve | Tarea planificada que todavia no mueve stock ni caja |

Ejemplo demo:

- Labor: `GESTION-UI-DEMO-20260610130452 Fertilizacion base`.
- Ha planificadas: `118`.

Restricciones conocidas:

- La OT no mueve stock ni caja. Es planificacion.
- Si se selecciona un cultivo, la OT hereda contexto de campana/ubicacion.

### 4.2 Laboreo con insumo

| Punto | Detalle |
| --- | --- |
| Ruta UI | `/flujos/labores?registrar=laboreo` |
| Accion | `Registrar laboreo` |
| Obligatorios | campana, fecha, labor, ha realizadas |
| Opcionales | cultivo, OT, proveedor, maquinaria, costo labor/ha, insumos aplicados, notas |
| Tablas principales | `laboreos_gestion`, `laboreos_insumos`, `movimientos_insumo` |
| Relacion posterior | Consume stock del producto/deposito y deja costo operativo en el cultivo |
| Usuario final ve | Labor ejecutada, insumos usados, costo y trazabilidad contra OT/cultivo |

Ejemplo demo:

- Labor: `GESTION-UI-DEMO-20260610130452 Fertilizacion base`.
- Ha realizadas: `118`.
- Insumo: MAP desde deposito mixto.
- Consumo generado: `10620`.
- Costo unitario: `940`.

Restricciones conocidas:

- Si se agregan insumos al laboreo, el backend valida stock disponible por
  producto y deposito.
- El consumo crea un movimiento `movimientos_insumo.tipo = 'consumo'` vinculado
  al laboreo.
- Si se elige una OT, el formulario copia labor, hectareas y proveedor como
  punto de partida; el dato final es el laboreo registrado.

## 5. Comercial grano

### 5.1 Contrato de venta

| Punto | Detalle |
| --- | --- |
| Ruta UI | `/flujos/ventas-granos?registrar=contrato` |
| Accion | `Crear contrato` |
| Obligatorios | campana, fecha, comprador, grano, kg vendidos |
| Opcionales | subcampana, convenio, vendedor/participante, corredor, tipo precio, precio, moneda, TC, comision, estado |
| Tabla principal | `contratos_grano` |
| Relacion posterior | Limita entregas, fijaciones y liquidaciones |
| Usuario final ve | Venta comprometida, kg vendidos, kg pendientes de entregar/liquidar/fijar |

Ejemplo demo:

- Comprador: `GESTION-UI-DEMO-20260610130452 Acopio Comprador`.
- Grano: `Maiz`.
- Kg vendidos: `12000`.

Restricciones conocidas:

- Si el contrato no es `a_fijar`, el backend exige precio.
- Una entrega vinculada al contrato debe usar el mismo grano.
- Las entregas no pueden superar los kg vendidos.

### 5.2 Ingreso de grano por cosecha

| Punto | Detalle |
| --- | --- |
| Ruta UI | `/flujos/stock-granos?registrar=cosecha` |
| Accion | `Registrar cosecha` |
| Obligatorios | cultivo, fecha, grano, kg netos, deposito destino |
| Opcionales | kg brutos, humedad, mermas, carta de porte, transporte, destino, ha cosechadas, rinde real |
| Tabla principal | `movimientos_grano` |
| Relacion posterior | Aumenta stock de grano y actualiza el cultivo como cosechado |
| Usuario final ve | Entrada real de grano al deposito y datos logisticos de cosecha |

Ejemplo demo:

- Carta de porte: `GESTION-UI-DEMO-20260610130452-CP-001`.
- Tipo: `ingreso_cosecha`.
- Kg netos: `15000`.
- Deposito destino: deposito mixto.

Restricciones conocidas:

- El ingreso de grano requiere deposito destino.
- El deposito debe estar activo y no ser de tipo solo `insumos`.

### 5.3 Entrega de grano

| Punto | Detalle |
| --- | --- |
| Ruta UI | `/flujos/stock-granos?registrar=entrega` o `/flujos/ventas-granos?registrar=entrega` |
| Accion | `Registrar entrega` |
| Obligatorios | contrato, fecha, kg netos, deposito origen |
| Opcionales | destino |
| Tabla principal | `movimientos_grano` |
| Relacion posterior | Reduce stock y suma kg entregados del contrato |
| Usuario final ve | Salida de grano contra comprador/contrato |

Ejemplo demo:

- Carta de porte editada en el movimiento: `GESTION-UI-DEMO-20260610130452-CP-002`.
- Tipo: `entrega`.
- Kg netos: `10000`.
- Deposito origen: deposito mixto.

Restricciones conocidas:

- El movimiento de salida requiere deposito origen.
- La entrega no puede superar el stock disponible.
- La entrega no puede superar los kg vendidos pendientes del contrato.
- El grano de la entrega debe coincidir con el grano del contrato.

### 5.4 Liquidacion de grano

| Punto | Detalle |
| --- | --- |
| Ruta UI | `/flujos/liquidaciones?registrar=liquidacion` |
| Accion | `Registrar liquidacion` |
| Obligatorios | contrato, fecha, kg liquidados, precio |
| Opcionales | tipo, nro liquidacion, moneda, TC, comisiones, retenciones, gastos, vencimiento, fecha cobro |
| Tabla principal | `liquidaciones_grano` |
| Relacion posterior | Si tiene fecha de cobro, genera un `movimientos` de ingreso |
| Usuario final ve | Liquidacion parcial/final/unica, neto a cobrar, estado pendiente/cobrada |

Ejemplo demo:

- Nro: `GESTION-UI-DEMO-20260610130452-LIQ-001`.
- Kg liquidados: `10000`.
- Si se carga fecha de cobro, queda cobrada y genera movimiento financiero.

Restricciones conocidas:

- No se puede liquidar mas kg que los entregados al contrato.
- Una liquidacion ya cobrada desde Gestion no se edita libremente porque tiene
  movimiento financiero asociado.

## 6. Finanzas

### 6.1 Factura recibida

| Punto | Detalle |
| --- | --- |
| Ruta UI | `/flujos/facturas-pagos?registrar=factura-proveedor` |
| Accion | `Factura a pagar` |
| Obligatorios | campana, proveedor, nro factura, fecha emision, monto |
| Opcionales | subcampana, estado, vencimiento/fecha pago, responsable, moneda, TC, imputacion |
| Tabla principal | `facturas` |
| Relacion posterior | Se paga mediante orden de pago |
| Usuario final ve | Cuenta a pagar con saldo pendiente, vencimiento y proveedor |

Ejemplo demo:

- Nro factura: `GESTION-UI-DEMO-20260610130452-FAC-001`.
- Proveedor: proveedor demo.
- Recomendacion para practicar: crearla `pendiente` y pagarla con orden de pago.

Restricciones conocidas:

- El monto debe ser mayor a cero.
- Si la moneda es USD, el tipo de cambio debe ser mayor a cero.
- Si la factura tiene pagos aplicados, no se debe cambiar proveedor, campana,
  subcampana u orden de compra; tampoco se elimina sin anular primero la orden
  de pago.

### 6.2 Orden de pago

| Punto | Detalle |
| --- | --- |
| Ruta UI | `/flujos/facturas-pagos`, panel de facturas a pagar |
| Accion | seleccionar factura con saldo, abrir `Orden de pago`, confirmar |
| Obligatorios | factura compatible, monto aplicado mayor a cero |
| Opcionales | fecha pago, medio, cuenta financiera, referencia, observaciones, anticipo |
| Tablas principales | `ordenes_pago`, `ordenes_pago_aplicaciones`, `movimientos` |
| Relacion posterior | Al confirmar, registra egreso en Caja y aplica saldo a la factura |
| Usuario final ve | Pago confirmado, factura parcial/pagada, egreso en Libro diario/Caja |

Ejemplo demo:

- Referencia: `GESTION-UI-DEMO-20260610130452-OP-001`.
- Cuenta: `GESTION-UI-DEMO-20260610130452 Caja Operativa`.

Restricciones conocidas:

- Una orden solo puede mezclar facturas del mismo proveedor, campana y
  subcampana.
- No se puede aplicar dos veces la misma factura en una orden.
- No se puede aplicar un monto mayor al saldo pendiente.
- Al confirmar se crea un `movimientos` de tipo `egreso`, autogenerado.

## Mapa relacional del ejemplo

```text
Proveedor -> Factura -> OrdenPago -> Movimiento

Producto + Deposito -> MovimientoInsumo(compra)
Producto + Deposito -> LaboreoInsumo -> MovimientoInsumo(consumo)

GestionCultivo -> OrdenTrabajo -> LaboreoGestion

GestionCultivo -> MovimientoGrano(ingreso_cosecha)
ContratoGrano -> MovimientoGrano(entrega) -> LiquidacionGrano -> Movimiento
```

Lectura funcional:

- `Proveedor -> Factura -> OrdenPago -> Movimiento`: explica cuentas a pagar y
  egresos reales de caja.
- `Producto + Deposito -> MovimientoInsumo -> Laboreo`: explica stock disponible
  y consumo operativo.
- `GestionCultivo -> OrdenTrabajo -> Laboreo`: explica planificacion vs tarea
  ejecutada.
- `ContratoGrano -> MovimientoGrano entrega -> LiquidacionGrano -> Movimiento`:
  explica venta, entrega fisica, liquidacion y cobro.

## Como interpreta esto el usuario final

- En `Produccion`, el usuario ve que existe un maiz demo de 118 ha en una
  ubicacion manual. Esto es el contexto operativo, no un analisis GIS.
- En `Labores`, ve una fertilizacion planificada y luego ejecutada. La OT muestra
  intencion; el laboreo muestra ejecucion real.
- En `Insumos`, ve que entro MAP al deposito y que el laboreo consumio parte del
  stock. El saldo restante surge de compra menos consumo.
- En `Stock granos`, ve que entraron 15000 kg de maiz por cosecha y salieron
  10000 kg como entrega.
- En `Ventas granos`, ve un contrato de 12000 kg. Despues de entregar 10000 kg,
  quedan pendientes 2000 kg de entrega.
- En `Liquidaciones`, ve que se liquidaron 10000 kg. Si tuvo fecha de cobro,
  tambien aparece como ingreso financiero.
- En `Facturas y pagos`, ve una factura de proveedor y una orden de pago que la
  aplica. Al confirmarla, Caja/Libro diario muestra el egreso.

## Verificacion en DBeaver

Abrir un script SQL en la conexion local `FarmIA Local (agroapp)` y ejecutar
consultas `SELECT` filtrando por el prefijo.

Conteo rapido del ejemplo completo:

```sql
select 'proveedores_flujo' as tabla, count(*) as rows
from proveedores_flujo
where nombre ilike 'GESTION-UI-DEMO-20260610130452%'
union all
select 'clientes_flujo', count(*)
from clientes_flujo
where nombre ilike 'GESTION-UI-DEMO-20260610130452%'
union all
select 'cuentas_financieras', count(*)
from cuentas_financieras
where nombre ilike 'GESTION-UI-DEMO-20260610130452%'
union all
select 'categorias', count(*)
from categorias
where nombre ilike 'GESTION-UI-DEMO-20260610130452%'
union all
select 'productos_gestion', count(*)
from productos_gestion
where nombre ilike 'GESTION-UI-DEMO-20260610130452%'
union all
select 'depositos_gestion', count(*)
from depositos_gestion
where nombre ilike 'GESTION-UI-DEMO-20260610130452%'
union all
select 'gestion_cultivos', count(*)
from gestion_cultivos
where cultivo ilike 'GESTION-UI-DEMO-20260610130452%'
union all
select 'ordenes_trabajo', count(*)
from ordenes_trabajo
where tipo_labor ilike 'GESTION-UI-DEMO-20260610130452%'
union all
select 'laboreos_gestion', count(*)
from laboreos_gestion
where tipo_labor ilike 'GESTION-UI-DEMO-20260610130452%'
union all
select 'contratos_grano', count(*)
from contratos_grano
where comprador ilike 'GESTION-UI-DEMO-20260610130452%'
union all
select 'movimientos_grano', count(*)
from movimientos_grano
where carta_porte ilike 'GESTION-UI-DEMO-20260610130452%'
union all
select 'liquidaciones_grano', count(*)
from liquidaciones_grano
where nro_liquidacion ilike 'GESTION-UI-DEMO-20260610130452%'
union all
select 'facturas', count(*)
from facturas
where nro_factura ilike 'GESTION-UI-DEMO-20260610130452%'
union all
select 'ordenes_pago', count(*)
from ordenes_pago
where referencia ilike 'GESTION-UI-DEMO-20260610130452%';
```

Consultas de practica:

```sql
select *
from proveedores_flujo
where nombre ilike 'GESTION-UI-DEMO-20260610130452%';

select *
from gestion_cultivos
where cultivo ilike 'GESTION-UI-DEMO-20260610130452%';

select *
from movimientos_insumo mi
join productos_gestion p on p.id = mi.producto_id
join depositos_gestion d on d.id = mi.deposito_id
where p.nombre ilike 'GESTION-UI-DEMO-20260610130452%';

select *
from movimientos_grano
where carta_porte ilike 'GESTION-UI-DEMO-20260610130452%';

select *
from contratos_grano
where comprador ilike 'GESTION-UI-DEMO-20260610130452%';

select *
from liquidaciones_grano
where nro_liquidacion ilike 'GESTION-UI-DEMO-20260610130452%';

select *
from facturas
where nro_factura ilike 'GESTION-UI-DEMO-20260610130452%';

select *
from ordenes_pago
where referencia ilike 'GESTION-UI-DEMO-20260610130452%';
```

Nota: no todas las tablas guardan el prefijo en una columna `nombre`. En este
ejemplo se busca por `cultivo`, `tipo_labor`, `comprador`, `carta_porte`,
`nro_liquidacion`, `nro_factura` o `referencia`, segun la tabla.

## Fuentes revisadas

- Rutas: `frontend/src/App.tsx`.
- Launcher de carga manual: `frontend/src/components/flujos/RegistroGestion.tsx`.
- Modales Gestion Agro:
  `frontend/src/components/flujos/gestion-agro/modals/GestionAgroRegistroModals.tsx`.
- Ordenes de pago:
  `frontend/src/components/flujos/pagos/OrdenPagoModal.tsx`.
- Maestros:
  `frontend/src/pages/flujos/ProveedoresPage.tsx`,
  `frontend/src/pages/flujos/ClientesGestionPage.tsx`,
  `frontend/src/pages/flujos/CuentasFinancierasPage.tsx`,
  `frontend/src/pages/flujos/CategoriasPage.tsx`.
- DTOs y reglas backend:
  `api/src/gestion-agro/dto/gestion-agro.dto.ts`,
  `api/src/gestion-agro/gestion-agro-base.service.ts`,
  `api/src/gestion-agro/gestion-agro-commercial.service.ts`,
  `api/src/facturas/dto/create-factura.dto.ts`,
  `api/src/facturas/facturas.service.ts`,
  `api/src/ordenes-pago/dto/orden-pago.dto.ts`,
  `api/src/ordenes-pago/ordenes-pago.service.ts`.
- Modelo de datos: `api/prisma/schema.prisma`.
- Dominios logicos: `docs/DATABASE_DOMAINS.md`.
- Verificacion local read-only en PostgreSQL para el prefijo
  `GESTION-UI-DEMO-20260610130452`.
