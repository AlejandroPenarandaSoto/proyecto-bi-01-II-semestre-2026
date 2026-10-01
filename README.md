# Solución de Inteligencia de Negocios para una empresa de telecomunicaciones (Costa Rica)

Proyecto académico de 4 semanas que integra un **modelo dimensional**, un **proceso ETL** y un **dashboard** para analizar facturación, consumo, incidencias y cancelaciones de clientes.

## 1. Problema y objetivo

Los datos de facturación, consumo, incidencias y cancelaciones están separados, lo que impide tener una visión integrada del negocio.

**Objetivo general:** diseñar e implementar una solución de BI que consolide esos datos y permita responder las preguntas de negocio para apoyar decisiones comerciales y operativas.

**Objetivos específicos**
1. Analizar ingresos por plan, servicio y segmento según región y periodo (top 5 de cada uno).
2. Evaluar consumo de datos, minutos y SMS por plan, segmento y periodo (total y promedio por cliente, 6 meses).
3. Identificar los 5 tipos de incidencia más frecuentes y los 5 más lentos, por canal, región y servicio.
4. Describir la tasa de cancelación por plan, antigüedad, segmento y periodo, señalando los 3 grupos con mayor tasa.

## 2. Preguntas de negocio

1. ¿Qué planes, servicios y segmentos generan más ingresos por región y periodo?
2. ¿Cómo se distribuye el consumo de datos, minutos y SMS por plan, segmento y periodo?
3. ¿Qué tipos de incidencia concentran más casos y mayores tiempos de resolución según canal, región y servicio?
4. ¿Cómo se comporta la tasa de cancelación (sobre clientes activos al inicio de cada mes) según plan, antigüedad, segmento y periodo?
5. ¿Cómo varía la tasa de cancelación entre clientes con consumo bajo, medio y alto (enero–junio 2026)?

## 3. Usuarios

Gerencia general, gerencia comercial y de ventas, operaciones y gestión de servicios, retención y fidelización, atención al cliente y soporte técnico.

## 4. KPIs principales

- **Ingresos:** ingreso total facturado, ingreso promedio por cliente, % de ingresos por plan, variación entre periodos.
- **Consumo:** consumo total por servicio, consumo promedio por cliente, % por segmento, variación entre periodos.
- **Incidencias:** cantidad total, resueltas, % por tipo, tiempo promedio de resolución.
- **Cancelaciones:** tasa de cancelación (cancelados del periodo / activos al inicio × 100), cantidad de clientes que cancelaron, variación en puntos porcentuales.

## 5. Herramientas

| Etapa | Herramienta |
|---|---|
| Generación de datos | Python + IA (datos sintéticos) |
| ETL | KNIME Analytics Platform |
| Almacenamiento | MySQL |
| Visualización | Power BI Desktop |

**Flujo:** CSV → KNIME (limpieza, homologación, derivación) → MySQL (modelo dimensional) → Power BI.

## 6. Fuente de datos

- Archivo: `telecom_costa_rica_datos_sinteticos.csv` (11,119 registros, 650 clientes ficticios, enero–junio 2026).
- Cada fila es un evento (`id_evento`); `tipo_evento` indica el proceso: FACTURACION, CONSUMO, INCIDENCIA o CANCELACION.
- Incluye datos de cliente, segmento, geografía (región, provincia, cantón, distrito), plan, servicios, fechas de alta/baja, y campos específicos por proceso (monto, consumo GB/min/SMS, datos de incidencia, motivo de cancelación).
- Los campos que no aplican a un evento quedan vacíos.
- El modelo operacional relacional incluye: `clientes`, `planes`, `servicios`, `regiones`, `contratos`, `plan_servicio`, `tipos_incidencia`, `canales_atencion` y las tablas de operaciones.

## 7. Modelo dimensional

**Tabla de hechos:** `fact_telecomunicaciones`, con un evento operacional por fila.

**Medidas:** `cantidad_evento`, `monto_facturado`, `cantidad_consumida` (semi-aditiva), `tiempo_resolucion_horas`, `incidencia_resuelta`, `antiguedad_cancelacion_meses` (no aditiva).

**Dimensiones** (todas con llave subrogada `sk_*`; la llave natural se conserva como atributo):

| Dimensión | Atributos clave |
|---|---|
| `dim_tiempo` | fecha, mes, trimestre, semestre, año, día de semana |
| `dim_cliente` | segmento, fechas de alta/baja, antigüedad, rango, nivel de consumo, estado |
| `dim_plan` | nombre, tipo (Prepago, Pospago, Empresarial) |
| `dim_servicio` | nombre, categoría (Internet→Fijo, Móvil→Móvil, TV→Entretenimiento) |
| `dim_region` | región, provincia, cantón |
| `dim_canal_atencion` | nombre, tipo (Digital, Telefónico, Presencial) |
| `dim_tipo_incidencia` | nombre, categoría (Técnica, Facturación, Comercial…) |
| `dim_tipo_consumo` | Datos (GB), Minutos (min), SMS (mensajes) |

## 8. ETL (KNIME)

- **Limpieza:** duplicados, identificadores vacíos, fechas inválidas o en orden incorrecto, montos/consumos/tiempos negativos, espacios sobrantes; los nulos válidos se mantienen.
- **Homologación:** nomenclatura uniforme de tipo de evento, segmento, geografía, servicio, canal y estado; unidades estándar (GB, minutos, mensajes) y formato de fecha único.
- **Derivación:** llaves subrogadas, atributos de tiempo, estado y antigüedad del cliente (corte 30/06/2026), rangos de antigüedad, nivel de consumo por terciles dentro de cada plan y periodo, y medidas de la tabla de hechos.
- **Carga:** primero las dimensiones, luego el hecho. Cada consumo se separa en hasta 3 filas (datos, minutos, SMS). Se validan duplicados, integridad de llaves y conteos contra el origen; los registros inválidos se separan para revisión.

# Solución de Inteligencia de Negocios para una empresa de telecomunicaciones (Costa Rica)

Proyecto académico de 4 semanas que integra un **modelo dimensional**, un **proceso ETL** y un **dashboard** para analizar facturación, consumo, incidencias y cancelaciones de clientes.

## 1. Problema y objetivo

Los datos de facturación, consumo, incidencias y cancelaciones están separados, lo que impide tener una visión integrada del negocio.

**Objetivo general:** diseñar e implementar una solución de BI que consolide esos datos y permita responder las preguntas de negocio para apoyar decisiones comerciales y operativas.

**Objetivos específicos**
1. Analizar ingresos por plan, servicio y segmento según región y periodo (top 5 de cada uno).
2. Evaluar consumo de datos, minutos y SMS por plan, segmento y periodo (total y promedio por cliente, 6 meses).
3. Identificar los 5 tipos de incidencia más frecuentes y los 5 más lentos, por canal, región y servicio.
4. Describir la tasa de cancelación por plan, antigüedad, segmento y periodo, señalando los 3 grupos con mayor tasa.

## 2. Preguntas de negocio

1. ¿Qué planes, servicios y segmentos generan más ingresos por región y periodo?
2. ¿Cómo se distribuye el consumo de datos, minutos y SMS por plan, segmento y periodo?
3. ¿Qué tipos de incidencia concentran más casos y mayores tiempos de resolución según canal, región y servicio?
4. ¿Cómo se comporta la tasa de cancelación (sobre clientes activos al inicio de cada mes) según plan, antigüedad, segmento y periodo?
5. ¿Cómo varía la tasa de cancelación entre clientes con consumo bajo, medio y alto (enero–junio 2026)?

## 3. Usuarios

Gerencia general, gerencia comercial y de ventas, operaciones y gestión de servicios, retención y fidelización, atención al cliente y soporte técnico.

## 4. KPIs principales

- **Ingresos:** ingreso total facturado, ingreso promedio por cliente, % de ingresos por plan, variación entre periodos.
- **Consumo:** consumo total por servicio, consumo promedio por cliente, % por segmento, variación entre periodos.
- **Incidencias:** cantidad total, resueltas, % por tipo, tiempo promedio de resolución.
- **Cancelaciones:** tasa de cancelación (cancelados del periodo / activos al inicio × 100), cantidad de clientes que cancelaron, variación en puntos porcentuales.

## 5. Herramientas

| Etapa | Herramienta |
|---|---|
| Generación de datos | Python + IA (datos sintéticos) |
| ETL | KNIME Analytics Platform |
| Almacenamiento | MySQL |
| Visualización | Power BI Desktop |

**Flujo:** CSV → KNIME (limpieza, homologación, derivación) → MySQL (modelo dimensional) → Power BI.

## 6. Fuente de datos

- Archivo: `telecom_costa_rica_datos_sinteticos.csv` (11,119 registros, 650 clientes ficticios, enero–junio 2026).
- Cada fila es un evento (`id_evento`); `tipo_evento` indica el proceso: FACTURACION, CONSUMO, INCIDENCIA o CANCELACION.
- Incluye datos de cliente, segmento, geografía (región, provincia, cantón, distrito), plan, servicios, fechas de alta/baja, y campos específicos por proceso (monto, consumo GB/min/SMS, datos de incidencia, motivo de cancelación).
- Los campos que no aplican a un evento quedan vacíos.
- El modelo operacional relacional incluye: `clientes`, `planes`, `servicios`, `regiones`, `contratos`, `plan_servicio`, `tipos_incidencia`, `canales_atencion` y las tablas de operaciones.

## 7. Modelo dimensional

**Tabla de hechos:** `fact_telecomunicaciones`, con un evento operacional por fila.

**Medidas:** `cantidad_evento`, `monto_facturado`, `cantidad_consumida` (semi-aditiva), `tiempo_resolucion_horas`, `incidencia_resuelta`, `antiguedad_cancelacion_meses` (no aditiva).

**Dimensiones** (todas con llave subrogada `sk_*`; la llave natural se conserva como atributo):

| Dimensión | Atributos clave |
|---|---|
| `dim_tiempo` | fecha, mes, trimestre, semestre, año, día de semana |
| `dim_cliente` | segmento, fechas de alta/baja, antigüedad, rango, nivel de consumo, estado |
| `dim_plan` | nombre, tipo (Prepago, Pospago, Empresarial) |
| `dim_servicio` | nombre, categoría (Internet→Fijo, Móvil→Móvil, TV→Entretenimiento) |
| `dim_region` | región, provincia, cantón |
| `dim_canal_atencion` | nombre, tipo (Digital, Telefónico, Presencial) |
| `dim_tipo_incidencia` | nombre, categoría (Técnica, Facturación, Comercial…) |
| `dim_tipo_consumo` | Datos (GB), Minutos (min), SMS (mensajes) |

## 8. ETL (KNIME)

- **Limpieza:** duplicados, identificadores vacíos, fechas inválidas o en orden incorrecto, montos/consumos/tiempos negativos, espacios sobrantes; los nulos válidos se mantienen.
- **Homologación:** nomenclatura uniforme de tipo de evento, segmento, geografía, servicio, canal y estado; unidades estándar (GB, minutos, mensajes) y formato de fecha único.
- **Derivación:** llaves subrogadas, atributos de tiempo, estado y antigüedad del cliente (corte 30/06/2026), rangos de antigüedad, nivel de consumo por terciles dentro de cada plan y periodo, y medidas de la tabla de hechos.
- **Carga:** primero las dimensiones, luego el hecho. Cada consumo se separa en hasta 3 filas (datos, minutos, SMS). Se validan duplicados, integridad de llaves y conteos contra el origen; los registros inválidos se separan para revisión.

> **Nota:** los datos son 100 % sintéticos; no contienen información real de clientes.