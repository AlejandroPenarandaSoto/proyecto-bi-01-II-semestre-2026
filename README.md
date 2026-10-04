# Solución de Inteligencia de Negocios para una empresa de telecomunicaciones (Costa Rica)

Proyecto académico de 4 semanas que integra un modelo dimensional, un proceso de ETL y un dashboard para analizar facturación, consumo, incidencias y cancelaciones de clientes.

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
| Generación de datos | Generados por IA (datos sintéticos) |
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

## 9. Resultados obtenidos

| Tema | Resultado |
|---|---|
| **Facturación** | Total ≈ ₡202,19 millones. Planes top: Corporativo Conectividad (₡34,4 M), Corporativo Enterprise (₡31,8 M), Pyme Conectividad (₡31,7 M). Por servicio: Internet ≈ ₡115 M, Móvil ≈ ₡61 M, TV ≈ ₡26 M. Por segmento: Residencial ≈ ₡79 M, Corporativo ≈ ₡66 M, Pyme ≈ ₡57 M. |
| **Consumo** | ≈ 220,88 mil GB, 1,94 millones de minutos y 248,28 mil SMS. Los planes corporativos y Pyme lideran el consumo de minutos y datos. Cada unidad se interpreta por separado. |
| **Incidencias** | 410 casos, tiempo promedio de resolución de 19,72 h. Más frecuentes: cambio de plan (54), lentitud del servicio (50), equipo/router (48). Más lentas: fallas en llamadas/datos móviles (~24 h), equipo/router (~23 h), señal de TV (~22 h). |
| **Cancelaciones** | Tasa mensual: ene 2,27 %, feb 3,20 %, mar 2,03 %, abr 1,23 % (mínimo), may 3,74 % (máximo), jun 2,58 %. Sin tendencia constante. |
| **Consumo e ingresos** | Ingresos por nivel de consumo: Alto ≈ ₡83 M, Medio ≈ ₡78 M, Bajo ≈ ₡42 M (montos totales, no promedios por cliente). |

**Hallazgos clave**
- Los planes corporativos y Pyme generan los mayores ingresos, e Internet es el servicio que más factura.
- La incidencia más frecuente (cambio de plan) no es la que más tarda en resolverse.
- La cancelación fluctúa entre meses; el pico es mayo y el valle abril.
- Los clientes de consumo alto y medio concentran la mayor parte de lo facturado.

## 10. Conclusiones

- El proyecto permitió aplicar el ciclo completo de una solución de BI y distinguir el rol de cada herramienta (KNIME para transformar, Power BI para analizar).
- El desarrollo iterativo permitió corregir errores conceptuales de forma temprana, los requerimientos no se pueden cerrar del todo sin validarlos con el negocio.
- Los datos sintéticos evitaron problemas de confidencialidad y permitieron enfocarse en el diseño, aunque restan realismo.

## 11. Limitaciones

- Datos sintéticos y solo seis meses: los patrones no representan a una empresa real ni permiten ver tendencias de largo plazo.
- Los ingresos por servicio dependen de la regla usada para repartir el monto de facturas con varios servicios.
- La clasificación de nivel de consumo depende de las reglas del proyecto y puede requerir ajustes con nuevos datos.
- La actualización es manual: hay que re-ejecutar KNIME, cargar en MySQL y refrescar Power BI.

## 12. Mejoras futuras

- Usar datos reales y ampliar el periodo a uno o varios años (estacionalidad, tendencias).
- Automatizar el ETL y la actualización del dashboard, con validaciones y registro de errores.
- Registrar el historial de cambios de atributos del cliente (segmento, región) y el consumo mensual.
- Agregar métricas al dashboard (ingreso medio por cliente, evolución mensual del consumo, % de incidencias resueltas).
- Con más historia, construir modelos predictivos de riesgo de cancelación.

> **Nota:** los datos son 100 % sintéticos; no contienen información real de clientes.