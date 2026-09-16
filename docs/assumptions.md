# Supuestos y limitaciones

> EconoMina es un simulador educativo. No reemplaza una evaluación económica profesional, un estudio de factibilidad, una valorización de reservas, un modelo financiero auditado ni la aprobación de un proyecto minero real. Ningún resultado constituye una recomendación de inversión. Las interpretaciones se expresan siempre "bajo los supuestos ingresados".

## Supuestos del modelo

| Tema | Supuesto |
|---|---|
| Periodo | Anual. Año 0 = inversión inicial (CAPEX + desarrollo). |
| Moneda | Constante (USD o PEN), sin inflación ni tipo de cambio. |
| Precio | Constante durante la vida del proyecto; todo el metal recuperado se vende en el año. |
| Ley y recuperación | Constantes; sin variabilidad por bloques ni dilución adicional. |
| Producción | Constante; el último año puede ser menor si se agotan las reservas. |
| Vida de operación | Mínimo entre la vida útil y los años que alcanzan las reservas. |
| Costos | Variables por tonelada y fijos por año, constantes. |
| Regalías | Porcentaje del ingreso bruto. |
| Impuestos | Opcionales; tasa única sobre (margen − depreciación lineal), sin pérdidas arrastrables. |
| Cierre | Se paga completo en el último año de operación. |
| Otros | Sin capital de trabajo, financiamiento, sostenimiento, valor residual ni costos de fundición y refinación. |
| Tasa de descuento | Constante; representa el costo de oportunidad y el riesgo. |

## Limitaciones

- La ley de corte es un modelo simplificado; una ley de corte profesional considera restricciones de capacidad, costos incrementales, planificación, dilución, pérdidas, impuestos y el valor del dinero en el tiempo.
- La sensibilidad cambia una variable a la vez; no captura correlaciones ni reemplaza un análisis probabilístico (Monte Carlo).
- El modelo ley-tonelaje de la sensibilidad es exponencial e ilustrativo.
- La TIR puede no existir o ser múltiple con flujos no convencionales; en esos casos se prioriza el VAN.
- Las clasificaciones de rentabilidad y riesgo son orientativas.
- El progreso se guarda solo en el dispositivo; no se sincroniza entre equipos.
- Los puntos de equilibrio cambian una sola variable y mantienen el resto constante.

## Datos ficticios

Todos los proyectos, nombres, precios y costos son **ficticios** y se eligieron para ilustrar situaciones típicas. No representan cotizaciones vigentes ni proyectos reales.

### Proyecto base

| Dato | Valor |
|---|---|
| Nombre | Proyecto Andino Cu (ficticio) |
| Reservas / ley / recuperación | 20 Mt · 0.8 % Cu · 88 % |
| Producción / capacidad | 2.0 Mt/año · 6 000 t/día × 350 días |
| Precio / regalía | 4.00 USD/lb · 3 % |
| Inversión / cierre | 300 M + 40 M USD · 30 M USD |
| Costos | 18.5 USD/t variables · 18 M USD/año fijos |
| Tasa / vida útil | 10 % · 10 años |
| Resultado | VAN ≈ 50.5 M USD · TIR ≈ 13.5 % · riesgo medio (VAN pesimista < 0) |
| Equilibrio | Precio ≈ 3.73 USD/lb · ley ≈ 0.745 % Cu · margen de seguridad ≈ 6.8 % |

### Casos empresariales (verificados por pruebas)

| Caso | Mineral | VAN base | TIR | VAN pesimista | Decisión educativa |
|---|---|---|---|---|---|
| 1. Mina rentable | Cu | ≈ +299.6 M | ≈ 27.5 % | positivo | Continuar con estudios de mayor detalle |
| 2. VAN negativo | Au | ≈ −31.8 M | ≈ 6.5 % | negativo | No avanzar sin optimizar ley, CAPEX o recuperación |
| 3. Alta ley | Au | ≈ +120.9 M | ≈ 61.8 % | positivo | Atractivo; ampliar reservas y controlar dilución |
| 4. Baja ley, gran escala | Cu | ≈ +2 851.6 M | ≈ 24.5 % | positivo | Atractivo; analizar financiamiento, tasa y gestión social |
| 5. Sensible al precio | Ag | ≈ +11.1 M | ≈ 11.5 % | negativo | No decidir solo con el caso base; evaluar coberturas y costos |
| 6. OPEX elevado | Zn | ≈ −85.9 M | ≈ −8.3 % | negativo | No avanzar sin un plan de reducción de costos |

Montos en millones de USD. Los valores exactos dependen del redondeo.

## Validaciones de entrada

La aplicación rechaza o advierte:

- Precio ≤ 0; recuperación fuera de 0–100 % o igual a 0.
- Ley, reservas o producción negativas o iguales a cero; ley mayor al máximo físico.
- Vida útil ≤ 0 o mayor a 60 años; tasa de descuento fuera de 0–100 % (advertencia si supera 30 %).
- Días de operación fuera de 1–366; capacidad de planta ≤ 0; regalías o impuestos fuera de 0–100 %.
- CAPEX u otros costos negativos.
- Producción mayor que la capacidad anual de planta.
- Incompatibilidad entre reservas, producción y vida útil (advertencia).
- Divisiones entre cero en costos unitarios, ley de corte y metal recuperado.
