# Fórmulas y unidades de EconoMina

Todas las fórmulas se implementan en `lib/calculators/` y están cubiertas por pruebas en `test/`. Los resultados son **educativos** y válidos solo bajo los supuestos ingresados.

## Unidades base

| Magnitud | Unidad |
|---|---|
| Mineral | toneladas (t); Mt = millones de toneladas |
| Ley | % (Cu, Zn, Pb) o g/t (Au, Ag) |
| Metal | libras (lb) para Cu, Zn, Pb; onzas troy (oz) para Au, Ag |
| Precio | moneda/lb o moneda/oz (USD o PEN) |
| Costos variables | moneda/t |
| Costos fijos | moneda/año |
| CAPEX, desarrollo, cierre | moneda (total) |
| Tasas, recuperación, regalías, impuestos | % (internamente como fracción) |
| Periodo | anual (año 0 = inversión) |

### Factor de conversión F

| Tipo de ley | F | Justificación |
|---|---|---|
| % | 22.0462 lb por (t · %) | 1 % de 1 t = 10 kg = 22.0462 lb |
| g/t | 1 / 31.1035 oz por (t · g/t) | 1 oz troy = 31.1035 g |

## 1. Costos

```
Costo de mina (moneda/t)       = perforación + voladura + carguío y transporte + extracción
Costo variable unitario (c_v)  = costo de mina + procesamiento + mantenimiento + otros variables
Costos fijos anuales (C_f)     = administrativos + otros fijos
Inversión inicial (I0)         = CAPEX + costos de desarrollo

OPEX anual                     = c_v × t + C_f
Costo unitario                 = OPEX anual / t
Costo por unidad de metal      = OPEX anual / metal recuperado anual
Costo total anual              = OPEX anual + (I0 + cierre) / años
Costo operativo total          = OPEX anual × años de operación
```

**Ejemplo (proyecto base):** c_v = 18.5 USD/t; t = 2 000 000; C_f = 18 M → OPEX = 55 M USD/año; costo unitario = 27.5 USD/t; costo total anual = 55 + (340 + 30)/10 = 92 M USD.

## 2. Producción e ingresos

```
Metal contenido   = t × ley × F
Metal recuperado  = metal contenido × R / 100
Ingreso bruto     = metal recuperado × P
Regalías          = ingreso bruto × regalía / 100
Ingreso neto      = ingreso bruto − regalías
Margen operativo  = ingreso neto − OPEX
Margen (%)        = margen operativo / ingreso neto × 100
```

**Ejemplo:** 2 000 000 t × 0.8 % × 22.0462 = 35.27 M lb contenidas; × 88 % = 31.04 M lb; × 4 USD/lb = 124.16 M USD; regalía 3 % → ingreso neto 120.44 M USD; margen = 65.44 M USD (54.3 %).

## 3. Ley de corte (modelo educativo)

```
Ley de corte = C / (Pn × R × F)
Pn = (P − costo de venta) × pagable × (1 − regalía)
```

| Método | C (moneda/t) |
|---|---|
| Equilibrio (break-even) | mina + procesamiento + generales |
| Marginal (material ya extraído) | procesamiento + generales |

Costos generales = mantenimiento + otros variables + costos fijos / producción anual.

**Ejemplo:** C = 7 + 9 + 11.5 = 27.5 USD/t; Pn = 4 × 0.97 = 3.88 USD/lb → ley de corte = 27.5 / (3.88 × 0.88 × 22.0462) ≈ **0.365 % Cu** (marginal ≈ 0.272 % Cu).

**Limitación:** una ley de corte profesional considera además restricciones de capacidad, costos incrementales, planificación, dilución, pérdidas, impuestos y el valor del dinero en el tiempo.

## 4. Flujo de caja

```
n                  = min(vida útil, ⌈reservas / producción anual⌉)
t_año              = min(producción anual, reservas restantes)
Año 0: FC0         = −I0
Depreciación       = I0 / n                       (lineal)
Impuestos          = tasa × (margen − depreciación), solo si es positivo y están activados
Cierre             = costo de cierre en el año n
FCt                = margen − impuestos − cierre
Factor descuento   = 1 / (1 + r)^t
Flujo descontado   = FCt × factor
Recuperación       = primer año con flujo acumulado (sin descontar) ≥ 0
```

## 5. VAN

```
VAN = Σ [FCt / (1 + r)^t] − I0,   t = 1 … n
```

| Resultado | Clasificación educativa |
|---|---|
| VAN > 0 | Atractivo bajo los supuestos |
| VAN ≈ 0 (tolerancia: máx(1, 0.1 % de I0)) | Indiferente |
| VAN < 0 | No atractivo bajo los supuestos |

**Proyecto base:** VAN(10 %) ≈ **50.53 M USD**.

### Puntos de equilibrio (VAN = 0)

```
Precio de equilibrio P*: VAN(P*) = 0      (resto de datos constantes)
Ley de equilibrio g*:    VAN(g*) = 0
Margen de seguridad      = (valor actual − valor de equilibrio) / valor actual × 100
```

El VAN crece con el precio y con la ley, por lo que se resuelve por bisección (precisión relativa 1e−9). **Proyecto base:** P* ≈ 3.727 USD/lb y g* ≈ 0.745 % Cu; margen de seguridad ≈ 6.8 % en ambos casos, porque precio y ley multiplican el ingreso de la misma forma. **Caso 2 (VAN negativo):** P* ≈ 2 100 USD/oz, margen ≈ −5.0 % (necesita un precio 5 % mayor).

## 6. TIR

```
0 = Σ [FCt / (1 + TIR)^t] − I0
```

Método numérico:

1. Si no hay flujos positivos y negativos → "sin cambio de signo".
2. Barrido de tasas de −90 % a 1000 % (paso 5 %, 1 % y 10 % según el tramo).
3. Bisección en cada intervalo con cambio de signo (tolerancia 1e−10, máx. 200 iteraciones).
4. Sin raíces → "no convergió". Varias raíces → se informan todas y se usa la más cercana a la tasa de descuento.

| Comparación | Clasificación |
|---|---|
| TIR > r | Atractivo |
| TIR ≈ r (±0.05 pp) | Indiferente |
| TIR < r | Menos atractivo |

**Proyecto base:** TIR ≈ **13.47 %**.

## 7. Escenarios

| Factor | Pesimista | Base | Optimista |
|---|---|---|---|
| Precio | × 0.90 | × 1 | × 1.10 |
| Ley | × 0.95 | × 1 | × 1.05 |
| Recuperación (máx. 100 %) | × 0.98 | × 1 | × 1.01 |
| OPEX (variables y fijos) | × 1.10 | × 1 | × 0.95 |
| CAPEX y desarrollo | × 1.10 | × 1 | × 0.95 |

## 8. Sensibilidad

Cada variable se modifica sola en −20 %, −10 %, 0 %, +10 % y +20 %:

```
Valor sensibilizado = valor base × (1 + variación)
Rango del VAN       = VAN máximo − VAN mínimo      (ordena las variables críticas)
```

Variables: precio, ley, recuperación, producción, CAPEX, OPEX, tasa de descuento y ley de corte.

Para la ley de corte se usa un modelo ley-tonelaje exponencial:

```
gm           = ley promedio − c0                 (c0: ley de corte de equilibrio)
Tonelaje(c)  = T0 × e^(−(c − c0) / gm)
Ley media(c) = c + gm
```

## 9. Riesgo educativo

| Nivel | Proyecto (escenarios) | Punto de sensibilidad |
|---|---|---|
| Alto | VAN base < 0 | VAN < 0 |
| Medio | VAN base ≥ 0 y VAN pesimista < 0 | VAN < 15 % de I0 o TIR − r < 3 pp |
| Bajo | VAN base y pesimista ≥ 0 | En otro caso |

## 10. Práctica numérica

Tipos de ejercicio generados (con datos aleatorios dentro de rangos realistas):

| Ejercicio | Fórmula |
|---|---|
| Costo unitario | (c_v × t + C_f) / t |
| Metal contenido (Cu) | Mt × % × 22.0462 = M lb |
| Oro recuperado | t × g/t / 31.1035 × R / 1000 = koz |
| Ingreso neto | metal × P × (1 − regalía) |
| Ley de corte | C / (P × R × 22.0462) |
| Valor presente | FC / (1 + r)^t |
| VAN a 3 años | Σ FC/(1 + r)^t − I0 |
| Periodo de recuperación | I0 / FC anual |

Una respuesta es correcta si |respuesta − valor esperado| ≤ máx(tolerancia % × |valor esperado|, 0.5 × 10^(−decimales)). La tolerancia es 1 % (2 % en el VAN) para admitir redondeos intermedios.
