# E2 — Business Case del Proyecto
> Competencia: CE0113 · Proyecto: OnCargo


## Nota Metodológica

Este documento es el **Entregable 2** del área de Gestión de Tecnologías de Información (GTI) del Perfil de Egreso, conforme al índice de líneas evaluadas: Entregable 1 — Diagnóstico Organizacional y Alineamiento Estratégico (CE0111–CE0115); Entregable 2 — Business Case del Proyecto (CE0113); Entregable 3 — Plan de Gestión del Proyecto (CE0121–CE0125); Entregable 4 — Modelado de Procesos AS-IS/TO-BE (CE0131–CE0135). La línea CE014 (Solución Técnica Integrada) se evalúa en otro momento y no forma parte de esta entrega; las referencias a su contenido en este documento se declaran explícitamente como “fuera del alcance de esta ronda de evaluación”.

El Caso de Negocio (CE0113) se presenta como documento independiente, con numeración propia (secciones 2.1 a 2.8). En versiones anteriores de este trabajo se desarrolló como sección 1.7 del Diagnóstico Organizacional; esa ubicación quedó superada y el Entregable 1 ya no lo contiene. Justifica la viabilidad y conveniencia del proyecto OnCargo como respuesta al diagnóstico del Entregable 1.

En la versión 2.0 de este documento el producto adopta el nombre comercial **OnCargo** (denominación anterior: LOGYX) y la estimación de costos (2.6) y la evaluación financiera (2.7) se recalculan sobre la nueva infraestructura de despliegue (VPS Hostinger KVM 2 y servicios Cloudflare) en lugar del diseño original sobre AWS; los supuestos de ingresos, horizonte y tasa de descuento no cambian. La sección 2.7 incluye la comparación de indicadores entre ambas versiones.

## 2.1 Justificación del proyecto

El proyecto aborda el problema estructural diagnosticado (P1–P5). Su expresión económica más medible es la brecha de costos: 16% promedio nacional, **21.1% en la microempresa vs. 15.7% en la gran empresa** (ComexPerú, 2022). El beneficio central es el cierre progresivo de esa brecha.

## 2.2 Objetivos del proyecto (SMART)

| **ID** | **Objetivo SMART**                                                                                 |
|--------|----------------------------------------------------------------------------------------------------|
| OP1    | Poner en operación el MVP de OnCargo en el corredor Lima–Sierra Sur en 16 semanas desde el Sprint 1. |
| OP2    | Incorporar 20 transportistas verificados con flota declarada antes de la semana 4.                 |
| OP3    | Alcanzar 80 PYMEs activas y NPS ≥ 45 al cierre de la semana 12.                                    |
| OP4    | Completar 200 empresas activas y el punto de equilibrio al cierre de la semana 24.                 |
| OP5    | Lograr ≥ 60% de solicitudes con oferta en 24h desde el mes 2.                                      |
| OP6    | Reducir el tiempo de contratación de un flete de días a menos de 60 minutos.                       |

## 2.3 Dimensionamiento del mercado (TAM → SAM → SOM)

- **TAM:** 2,330,226 MIPYMEs formales (Ministerio de la Producción, 2025).

- **SAM:** ~50,000 PYMEs del corredor Lima–Sierra Sur (derivación propia, Anexo A).

- **SOM (año 1):** 300–500 PYMEs y 100–150 transportistas.

## 2.4 Análisis de Alternativas

| **Criterio (peso)**            | **A. Statu quo** | **B. Broker tradicional** | **C. SaaS existente** | **D. Desarrollar OnCargo** |
|--------------------------------|------------------|---------------------------|-----------------------|--------------------------|
| Costo total PYME (25%)         | 3                | 1                         | 2                     | 4                        |
| Cobertura de FCE (30%)         | 1                | 2                         | 3                     | 5                        |
| Adecuación al corredor (20%)   | 5                | 4                         | 1                     | 4                        |
| Escalabilidad (15%)            | 1                | 1                         | 3                     | 5                        |
| Riesgo de implementación (10%) | 5                | 4                         | 3                     | 2                        |
| PUNTAJE PONDERADO              | 2.60             | 2.15                      | 2.40                  | 4.25                     |

La alternativa D (desarrollar OnCargo) obtiene el mayor puntaje, con ventaja decisiva en cobertura de FCE y escalabilidad; su riesgo de implementación se gestiona mediante la estrategia secuencial de arranque descrita en la documentación de implementación de la solución (fuera del alcance de esta ronda de evaluación). El puntaje de escalabilidad se refiere a la arquitectura (monolito modular empaquetado en contenedores Docker, portable a infraestructura elástica) y no a la capacidad del servidor inicial: el MVP arranca en un único VPS (sección 2.6) y la migración a mayor capacidad se decide con la demanda observada.

## 2.5 Evaluación de Beneficios

- **Gasto logístico mensual por PYME:** USD 500–5,000 (derivado de 16–21.1% de ventas de USD 3,000–24,000; Anexo A).

- **Ahorro potencial:** USD 150–1,200 mensuales por PYME al cerrar ~5 pp.

- **Beneficio al transportista:** ingreso adicional por km ya recorrido al reducir retornos vacíos.

## 2.6 Estimación de Costos

*Supuesto declarado del equipo: 3 integrantes × 15 h/semana × 16 semanas = 720 horas; tarifa de referencia S/ 25/hora.*

**Arquitectura de despliegue costeada (versión 2.0).** La solución se despliega en un servidor privado virtual **Hostinger KVM 2** (2 vCPU, 8 GB de RAM, 100 GB NVMe, centro de datos en Brasil) con Docker Compose y Caddy como proxy inverso (certificados TLS automáticos de Let's Encrypt); los documentos y los respaldos de base de datos (`pg_dump`) se almacenan en **Cloudflare R2**; el DNS y la CDN se sirven con Cloudflare en su plan gratuito, bajo el dominio `oncargo.tech`. Este esquema sustituye al diseño de la versión 1.0 sobre AWS (EC2, RDS, S3 y CloudFront), cuyo costo de referencia era ≈ USD 333/mes en modalidad *pay-as-you-go* (Anexo A de la v1.0).

**Tipo de cambio.** Los precios en dólares se convierten a **S/ 3.45 por USD**: tipo de cambio venta publicado por la SUNAT para el 06-11-2026 (S/ 3.452), consistente con el cierre interbancario del BCRP de la misma fecha (≈ S/ 3.425–3.43), redondeado a dos decimales. Su efecto se evalúa en la tabla de sensibilidad de la sección 2.7.

| **Concepto**                                                   | **Cálculo (USD)**  | **USD**   | **S/ (× 3.45)** | **Fuente / naturaleza**                                                                                                                              |
|----------------------------------------------------------------|--------------------|-----------|-----------------|------------------------------------------------------------------------------------------------------------------------------------------------------|
| VPS Hostinger KVM 2, prepago 24 meses (mes 0)                  | 8.99 × 24          | 215.76    | 744.37          | Precio promocional publicado por Hostinger (hostinger.com/vps-hosting), verificado en nov-2026; sujeto a cambio                                       |
| Dominio `oncargo.tech`, 2 años (mes 0)                         | 49.20 × 2          | 98.40     | 339.48          | Tarifa de Cloudflare Registrar para .TECH (referencia domainoffer.net, jul-2026); a verificar al momento de la compra                                 |
| Certificados TLS                                               | —                  | 0.00      | 0.00            | Let's Encrypt, emitidos y renovados por Caddy                                                                                                        |
| DNS y CDN                                                      | —                  | 0.00      | 0.00            | Cloudflare, plan gratuito                                                                                                                            |
| Cloudflare R2, consumo ≤ 50 GB-mes (**estimación**)            | (50 − 10) × 0.015  | 0.60/mes  | 2.07/mes        | Tarifa oficial (developers.cloudflare.com/r2/pricing): USD 0.015/GB-mes; gratis 10 GB-mes, 1 M operaciones clase A y 10 M clase B al mes; egress gratis |
| Reserva mensual de nube (R2, operaciones y servicios menores)  | 2.00               | 2.00/mes  | 6.90/mes        | Supuesto del equipo: cubre el consumo estimado de R2 con holgura                                                                                     |
| Renovación del VPS desde el mes 25 (fuera del horizonte)       | 14.99              | 14.99/mes | 51.72/mes       | Precio de renovación publicado por Hostinger                                                                                                         |
| Referencia v1.0: infraestructura AWS                           | 333                | 333.00/mes | 1,148.85/mes   | Anexo A de la v1.0 (solo para el desglose retrospectivo)                                                                                             |

**Inversión inicial (mes 0, base caja):**

| **Concepto**                                              | **Monto (S/)** |
|-----------------------------------------------------------|----------------|
| Desarrollo del MVP (720 h × S/ 25)                        | 18,000.00      |
| Infraestructura: VPS Hostinger KVM 2 (prepago 24 meses)   | 744.37         |
| Dominio `oncargo.tech` (2 años); TLS y DNS/CDN sin costo  | 339.48         |
| Subtotal                                                  | 19,083.85      |
| Contingencia (10%)                                        | 1,908.39       |
| TOTAL INVERSIÓN INICIAL                                   | 20,992.24 (≈ S/ 20,992) |

La inversión inicial sube solo ≈ S/ 26 respecto de la v1.0 (S/ 20,966) porque el prepago adelanta al mes 0 el costo de toda la infraestructura del horizonte de 24 meses (servidor y dominio), mientras que el costo operativo mensual baja de S/ 2,000 a S/ 858.05.

**Costos operativos mensuales.** La v1.0 declaraba una estimación global de ~S/ 2,000/mes sin desglose. Para aislar el efecto del cambio de infraestructura se realiza un **desglose retrospectivo**: la porción de infraestructura cloud se valoriza con la cifra del Anexo A (USD 333 × 3.45 = S/ 1,148.85) y el resto se obtiene por diferencia como "otros costos operativos" (soporte, monitoreo, servicios externos e imprevistos), que se conservan sin cambio:

| **Componente mensual**                                                      | **v1.0 — AWS (S/)** | **v2.0 — VPS + Cloudflare (S/)** | **Base del cálculo**                                                        |
|-----------------------------------------------------------------------------|---------------------|----------------------------------|-----------------------------------------------------------------------------|
| Infraestructura de nube                                                     | 1,148.85            | 6.90                             | v1.0: USD 333 × 3.45 · v2.0: reserva USD 2.00 × 3.45 (VPS y dominio pagados en el mes 0) |
| Otros costos operativos (soporte, monitoreo, servicios externos, imprevistos) | 851.15            | 851.15                           | 2,000 − 1,148.85, obtenido por diferencia (**estimación**)                  |
| **Costo operativo mensual**                                                 | **2,000.00**        | **858.05**                       | 851.15 + 6.90                                                               |

TCO a 24 meses: 20,992.24 + 24 × 858.05 = 20,992.24 + 20,593.20 = **S/ 41,585.44 (≈ S/ 41,585)**, frente a S/ 68,966 en la v1.0. Desde el mes 25, fuera del horizonte evaluado, se sumaría la renovación del VPS (USD 14.99 × 3.45 = S/ 51.72/mes), con lo que el costo operativo mensual pasaría a S/ 909.77.

## 2.7 Evaluación Financiera

*Supuestos declarados del equipo: horizonte 24 meses; tasa de descuento anual 18%; ticket promedio S/ 1,200; comisión efectiva 4.5% (rango 2%–8%); tipo de cambio S/ 3.45 por USD; inversión inicial S/ 20,992.24 en el mes 0; costos operativos S/ 858.05 por mes desde el mes 1 (sección 2.6).*

**Modelo de flujo mensual.** Para calcular VAN, TIR y payback se usa un flujo de caja mensual explícito. Los ingresos acumulados a 24 meses (S/ 584,820 en el escenario base, equivalentes a ≈ 10,830 operaciones de S/ 54 de comisión) se distribuyen con una **rampa lineal**: el ingreso del mes *m* es *k·m*, con *k* = 584,820 / 300 = S/ 1,949.40 (porque Σ m, m = 1…24, es 300). Así el ingreso mensual pasa de S/ 1,949 en el mes 1 a S/ 46,786 en el mes 24, reflejando el crecimiento gradual de la red de PYMEs y transportistas. El escenario conservador aplica el 50% a todos los meses (*k* = S/ 974.70). El flujo del mes *m* es `FC(m) = 1,949.40·m − 858.05`; el del mes 0 es `FC(0) = −20,992.24`. La tasa mensual equivalente es *i* = (1.18)^(1/12) − 1 = 1.389%. El flujo neto acumulado es 584,820 − 20,992.24 − 24 × 858.05 = **S/ 543,234.56**.

El VAN se calcula como `VAN = FC(0) + Σ FC(m) / (1 + i)^m`, m = 1…24, sin descontar el flujo del mes 0. Como verificación independiente se usa la forma cerrada `VAN = −I + k·(Ia)₂₄ − C·a₂₄`, con *v* = 1/(1 + *i*), *a*₂₄ = (1 − *v*²⁴)/*i* = 20.2914 y (*Ia*)₂₄ = (ä₂₄ − 24·*v*²⁴)/*i* = 240.2561 (anualidad creciente 1, 2, …, 24; ä₂₄ = (1 − *v*²⁴)·(1 + *i*)/*i*): −20,992.24 + 1,949.40 × 240.2561 − 858.05 × 20.2914 = S/ 429,952, idéntico a la suma directa. La TIR es la tasa mensual que anula el VAN (se comprueba que VAN(TIR) ≈ 0) y se anualiza como (1 + TIR)^12 − 1. El payback es el primer mes con flujo acumulado ≥ 0 (base: −4,930 al mes 4 y +3,959 al mes 5; conservador: −5,672 al mes 6 y +293 al mes 7).

| **Indicador**                      | **Escenario base**    | **Escenario conservador (50%)** |
|------------------------------------|-----------------------|---------------------------------|
| Ingresos acumulados 24 meses       | S/ 584,820            | S/ 292,410                      |
| Flujo neto acumulado               | S/ 543,235            | S/ 250,825                      |
| Payback (flujo acumulado ≥ 0)      | Mes 5                 | Mes 7                           |
| ROI a 24 meses (sobre TCO S/ 41,585) | ≈ 13.1×             | ≈ 6.0×                          |
| Valor Actual Neto (VAN, 18% anual) | S/ 429,952 (positivo) | S/ 195,774 (positivo)           |
| Tasa Interna de Retorno (TIR)      | 33.0% mensual (≈ 2,974% anualizada) | 21.2% mensual (≈ 901% anualizada) |

*Lectura de la TIR:* es muy alta porque la inversión inicial es pequeña frente a los flujos que genera; la cifra anualizada se reporta por completitud, pero el indicador de decisión es el **VAN** y la tabla de sensibilidad siguiente. Aun en el escenario conservador el proyecto recupera su inversión dentro del horizonte y la TIR mensual supera con holgura la tasa de descuento mensual (1.39%).

**Comparación con la versión 1.0.** La v1.0 del Business Case costeaba la infraestructura sobre AWS (EC2, RDS, S3 y CloudFront). Con los mismos ingresos, horizonte y tasa, el cambio a VPS Hostinger + Cloudflare produce:

| **Indicador**                         | **v1.0 — AWS**                 | **v2.0 — VPS Hostinger + Cloudflare** | **Variación**   |
|---------------------------------------|--------------------------------|---------------------------------------|-----------------|
| Inversión inicial (mes 0)             | S/ 20,966                      | S/ 20,992                             | +S/ 26          |
| Costo operativo mensual               | S/ 2,000                       | S/ 858                                | −S/ 1,142       |
| TCO a 24 meses                        | S/ 68,966                      | S/ 41,585                             | −S/ 27,381      |
| Flujo neto acumulado (base / conservador) | S/ 515,854 / S/ 223,444    | S/ 543,235 / S/ 250,825               | +S/ 27,381      |
| VAN base / conservador                | S/ 406,806 / S/ 172,629        | S/ 429,952 / S/ 195,774               | +S/ 23,146      |
| TIR mensual base / conservador        | 30.1% / 18.2%                  | 33.0% / 21.2%                         | +2.9 / +3.0 pp  |
| TIR anualizada base / conservador     | ≈ 2,261% / ≈ 646%              | ≈ 2,974% / ≈ 901%                     | —               |
| Payback base / conservador            | Mes 6 / Mes 9                  | Mes 5 / Mes 7                         | −1 / −2 meses   |
| ROI a 24 meses base / conservador     | ≈ 7.5× / ≈ 3.2×                | ≈ 13.1× / ≈ 6.0×                      | —               |
| Punto de equilibrio del VAN           | ≈ 13% de los ingresos base (≈ S/ 76,850; ≈ 1,420 operaciones) | ≈ 8.2% (≈ S/ 47,953; ≈ 890 operaciones) | −4.9 pp |

**Sensibilidad** (VAN a 18% anual, S/; en cada fila se varía un solo parámetro del escenario base):

| **Variación**                                  | **VAN (S/)** | **TIR mensual** | **Payback** |
|------------------------------------------------|--------------|-----------------|-------------|
| Ingresos al 100% (base)                        | 429,952      | 33.0%           | Mes 5       |
| Ingresos al 75%                                | 312,863      | 27.6%           | Mes 6       |
| Ingresos al 50% (conservador)                  | 195,774      | 21.2%           | Mes 7       |
| Ingresos al 25%                                | 78,686       | 12.5%           | Mes 11      |
| Ingresos al 15%                                | 31,850       | 7.2%            | Mes 15      |
| Tasa de descuento 12% / 25% / 30% (base)       | 462,642 / 396,721 / 375,693 | —  | —           |
| Inversión inicial +20% (S/ 25,191, base)       | 425,754      | 29.8%           | Mes 6       |
| Tipo de cambio S/ 3.30 / 3.45 / 3.70 por USD (inversión S/ 20,940 / 20,992 / 21,079; costo mensual S/ 857.75 / 858.05 / 858.55) | 430,010 / 429,952 / 429,855 | 33.1% / 33.0% / 33.0% | Mes 5 |
| VPS sin prepago, a precio de renovación (USD 14.99 × 3.45 = S/ 51.72/mes durante los 24 meses; inversión sin VPS S/ 20,173; costo mensual S/ 909.77) | 429,721 | 33.6% | Mes 5 |

El **punto de equilibrio del VAN** (VAN = 0) se alcanza cuando los ingresos acumulados son ≈ 8.2% de los del escenario base (≈ S/ 47,953 en 24 meses, ≈ 890 operaciones de S/ 54). La sensibilidad dominante es el volumen de operaciones, no la tasa de descuento, la inversión, el tipo de cambio ni la modalidad de pago del VPS (estas dos últimas mueven el VAN en menos de S/ 250): el riesgo del proyecto es de adopción (RE1/RE2, RB1), no financiero.

??? note "Cálculo reproducible (fórmulas y script esencial)"

    Modelo implementado en Python (solo biblioteca estándar). El script completo reproduce primero las cifras de la v1.0 (VAN S/ 406,806 y S/ 172,629; TIR 30.1% y 18.2%; payback mes 6 y mes 9) para validar que el modelo es el mismo y luego calcula las de la v2.0.

    ```python
    from decimal import Decimal, ROUND_HALF_UP
    r2 = lambda x: float(Decimal(str(x)).quantize(Decimal("0.01"), ROUND_HALF_UP))

    N, TASA = 24, 0.18
    i = (1 + TASA) ** (1 / 12) - 1                 # 1.389 % mensual
    TC = 3.45                                      # S/ por USD (SUNAT venta 06-11-2026)
    vps = r2(8.99 * 24 * TC)                       # 744.37  (prepago 24 m, mes 0)
    dom = r2(49.20 * 2 * TC)                       # 339.48  (oncargo.tech, 2 años)
    sub = r2(18_000 + vps + dom)                   # 19,083.85
    inv = r2(sub + r2(sub * 0.10))                 # 20,992.24 (contingencia 1,908.39)
    otros = r2(2_000 - r2(333 * TC))               # 851.15 (desglose retrospectivo v1.0)
    C = r2(otros + r2(2.00 * TC))                  # 858.05 (reserva de nube USD 2.00)

    def flujos(f=1.0):                             # f = factor de ingresos (0.5 conservador)
        k = 584_820 * f / 300                      # rampa lineal: ingreso(m) = k·m
        return [-inv] + [k * m - C for m in range(1, N + 1)]

    def van(cf, r=i):
        return sum(c / (1 + r) ** t for t, c in enumerate(cf))

    def tir(cf, lo=-0.99, hi=10.0):                # bisección: VAN(tir) = 0
        for _ in range(200):
            mid = (lo + hi) / 2
            lo, hi = (mid, hi) if van(cf, mid) > 0 else (lo, mid)
        return mid

    def payback(cf):                               # primer mes con acumulado >= 0
        acc = 0
        for t, c in enumerate(cf):
            acc += c
            if t > 0 and acc >= 0:
                return t

    cf = flujos()
    print(round(van(cf)), tir(cf), payback(cf))    # 429952  0.3304  5
    cf = flujos(0.5)
    print(round(van(cf)), tir(cf), payback(cf))    # 195774  0.2116  7
    ```

    Verificaciones: (1) el VAN por suma directa coincide con la forma cerrada `−I + k·(Ia)₂₄ − C·a₂₄`; (2) VAN(TIR) ≈ 0; (3) el VAN es lineal en el factor de ingresos *f*, por lo que el punto de equilibrio es `f* = −VAN(f=0) / (VAN(f=1) − VAN(f=0))` = 8.20%.

## 2.8 Riesgos Iniciales del Proyecto

| **ID** | **Riesgo**                               | **P** | **I** | **Nivel** | **Mitigación**                        |
|--------|------------------------------------------|-------|-------|-----------|---------------------------------------|
| RB1    | Adopción insuficiente (arranque en frío) | 4     | 5     | 20        | Estrategia secuencial oferta→demanda  |
| RB2    | Proyección de ingresos no alcanzada      | 3     | 4     | 12        | Escenario conservador viable          |
| RB3    | Riesgo regulatorio                       | 2     | 4     | 8         | Diseño conforme a Ley 29733 y MTC     |
| RB4    | Riesgo competitivo                       | 2     | 4     | 8         | Velocidad de captura del corredor     |
| RB5    | Riesgo técnico                           | 3     | 3     | 9         | MVP acotado; gestión ágil (8 sprints) |

Los riesgos de costo de la infraestructura (variación del tipo de cambio y fin del precio promocional del VPS) no se tratan como riesgos de negocio independientes: el prepago de 24 meses fija el costo del servidor durante todo el horizonte evaluado y, según la sensibilidad de la sección 2.7, ambos factores mueven el VAN en menos de S/ 250.

## Referencias

Armstrong & Associates, Inc. (2025). U.S. Third-Party Logistics (3PL) Market Size Estimates: Domestic Transportation Management. https://www.3plogistics.com/

Arvis, J.-F., Ojala, L., Shepherd, B., Ulybina, D., & Wiederer, C. (2023). Connecting to compete 2023: Trade logistics in an uncertain global economy — The logistics performance index and its indicators. World Bank Group.

Banco Central de Reserva del Perú \[BCRP\]. (2026). Tipo de cambio interbancario — cierre (06 de noviembre de 2026). Series estadísticas del BCRP. https://estadisticas.bcrp.gob.pe/

Cloudflare, Inc. (2026). R2 pricing. Cloudflare Developers. Recuperado en noviembre de 2026, de https://developers.cloudflare.com/r2/pricing/

DomainOffer. (2026, julio). Precios de registro y renovación del dominio .TECH por registrador (Cloudflare Registrar). https://domainoffer.net/

Farromeque Quiroz, R. (2017). PERLOG-LATAM: Perfil logístico de América Latina. Banco de Desarrollo de América Latina (CAF).

Hostinger International Ltd. (2026). VPS hosting — planes KVM. Recuperado en noviembre de 2026, de https://www.hostinger.com/vps-hosting

Ministerio de Comercio Exterior y Turismo & Grupo Banco Mundial. (2016). Análisis integral de la logística en el Perú: 5 cadenas de exportación. MINCETUR.

Ministerio de la Producción. (2025). Las Mipyme en cifras 2024. Oficina General de Evaluación de Impacto y Estudios Económicos, PRODUCE.

Sociedad de Comercio Exterior del Perú \[ComexPerú\]. (2022). Los costos logísticos de las empresas en el país son del 16% en promedio, pero un 21.1% para las microempresas. Semanario Económico.

Superintendencia Nacional de Aduanas y de Administración Tributaria \[SUNAT\]. (2026). Tipo de cambio oficial — venta (06 de noviembre de 2026). https://www.sunat.gob.pe/


---

