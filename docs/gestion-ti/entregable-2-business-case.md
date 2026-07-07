# E2 — Business Case del Proyecto
> Competencia: CE0113 · Proyecto: LOGYX


## Nota Metodológica

Este documento es uno de los 4 entregables del área de Gestión de Tecnologías de Información (GTI) del Perfil de Egreso, conforme al índice de líneas evaluadas: Entregable 1 — Diagnóstico Organizacional y Alineamiento Estratégico (CE0111–CE0115); Entregable 2 — Business Case del Proyecto (CE0113); Entregable 3 — Plan de Gestión del Proyecto (CE0121–CE0125); Entregable 4 — Modelado de Procesos AS-IS/TO-BE (CE0131–CE0135). La línea CE014 (Solución Técnica Integrada) se evalúa en otro momento y no forma parte de esta entrega; las referencias a su contenido en este documento se declaran explícitamente como “fuera del alcance de esta ronda de evaluación”.

Este documento específico corresponde al Entregable 2 (Business Case), que en versiones anteriores de este trabajo se desarrolló como sección 1.7 del Diagnóstico Organizacional; se presenta aquí como documento independiente conforme al índice de líneas evaluadas vigente, con numeración propia (secciones 2.1 a 2.8).

Esta sección desarrolla el Caso de Negocio exigido por CE0113 dentro del Entregable 1, justificando la viabilidad y conveniencia del proyecto LOGYX como respuesta al diagnóstico precedente.

## 2.1 Justificación del proyecto

El proyecto aborda el problema estructural diagnosticado (P1–P5). Su expresión económica más medible es la brecha de costos: 16% promedio nacional, **21.1% en la microempresa vs. 15.7% en la gran empresa** (ComexPerú, 2022). El beneficio central es el cierre progresivo de esa brecha.

## 2.2 Objetivos del proyecto (SMART)

| **ID** | **Objetivo SMART**                                                                                 |
|--------|----------------------------------------------------------------------------------------------------|
| OP1    | Poner en operación el MVP de LOGYX en el corredor Lima–Sierra Sur en 16 semanas desde el Sprint 1. |
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

| **Criterio (peso)**            | **A. Statu quo** | **B. Broker tradicional** | **C. SaaS existente** | **D. Desarrollar LOGYX** |
|--------------------------------|------------------|---------------------------|-----------------------|--------------------------|
| Costo total PYME (25%)         | 3                | 1                         | 2                     | 4                        |
| Cobertura de FCE (30%)         | 1                | 2                         | 3                     | 5                        |
| Adecuación al corredor (20%)   | 5                | 4                         | 1                     | 4                        |
| Escalabilidad (15%)            | 1                | 1                         | 3                     | 5                        |
| Riesgo de implementación (10%) | 5                | 4                         | 3                     | 2                        |
| PUNTAJE PONDERADO              | 2.60             | 2.15                      | 2.40                  | 4.25                     |

La alternativa D (desarrollar LOGYX) obtiene el mayor puntaje, con ventaja decisiva en cobertura de FCE y escalabilidad; su riesgo de implementación se gestiona mediante la estrategia secuencial de arranque descrita en la documentación de implementación de la solución (fuera del alcance de esta ronda de evaluación).

## 2.5 Evaluación de Beneficios

- **Gasto logístico mensual por PYME:** USD 500–5,000 (derivado de 16–21.1% de ventas de USD 3,000–24,000; Anexo A).

- **Ahorro potencial:** USD 150–1,200 mensuales por PYME al cerrar ~5 pp.

- **Beneficio al transportista:** ingreso adicional por km ya recorrido al reducir retornos vacíos.

## 2.6 Estimación de Costos

*Supuesto declarado del equipo: 3 integrantes × 15 h/semana × 16 semanas = 720 horas; tarifa de referencia S/ 25/hora.*

| **Concepto**                                  | **Monto (S/)** |
|-----------------------------------------------|----------------|
| Desarrollo del MVP (720 h × S/ 25)            | 18,000         |
| Infraestructura cloud de desarrollo (4 meses) | 760            |
| Dominio, certificados y servicios menores     | 300            |
| Contingencia (10%)                            | 1,906          |
| TOTAL INVERSIÓN INICIAL                       | 20,966         |

Costos operativos: ~S/ 2,000/mes. TCO a 24 meses: S/ 68,966.

## 2.7 Evaluación Financiera

*Supuesto declarado del equipo: horizonte 24 meses; tasa de descuento anual 18%; ticket promedio S/ 1,200; comisión efectiva 4.5% (rango 2%–8%).*

| **Indicador**                      | **Escenario base**    | **Escenario conservador (50%)** |
|------------------------------------|-----------------------|---------------------------------|
| Ingresos acumulados 24 meses       | S/ 584,820            | S/ 292,410                      |
| Flujo neto acumulado               | S/ 515,854            | S/ 223,444                      |
| Payback                            | Mes 11–12             | Mes 15–16                       |
| ROI a 24 meses                     | ≈ 7.5×                | ≈ 3.2×                          |
| Valor Actual Neto (VAN, 18% anual) | S/ 370,829 (positivo) | S/ 156,532 (positivo)           |
| Tasa Interna de Retorno (TIR)      | > 417.8% anual        | > 217.3% anual                  |

Aun en el escenario conservador el proyecto recupera su inversión dentro del horizonte. La sensibilidad del modelo está en el volumen de operaciones, reforzando que el riesgo dominante es de adopción (RE1/RE2), no financiero.

*Nota sobre la TIR: los valores originales (417.8% en el escenario base, 217.3% en el conservador) fueron calculados sobre una inversión inicial de S/ 27,566; al reducir el equipo a 3 integrantes, la inversión inicial baja a S/ 20,966, por lo que la TIR real es modestamente superior a esas cifras (se reporta como cota inferior ">" porque el recálculo exacto requiere el modelo de flujo de caja mensual, no incluido en este resumen agregado). El VAN sí se recalculó de forma exacta, ya que solo depende linealmente de la reducción de la inversión inicial (S/ 364,229 + S/ 6,600 = S/ 370,829; S/ 149,932 + S/ 6,600 = S/ 156,532, descontados al 18% anual) y es el indicador más robusto de viabilidad financiera; la TIR se reporta por completitud metodológica, pero su magnitud debe interpretarse con cautela y idealmente contrastarse con un análisis de sensibilidad antes de usarse como argumento independiente ante inversionistas.*

## 2.8 Riesgos Iniciales del Proyecto

| **ID** | **Riesgo**                               | **P** | **I** | **Nivel** | **Mitigación**                        |
|--------|------------------------------------------|-------|-------|-----------|---------------------------------------|
| RB1    | Adopción insuficiente (arranque en frío) | 4     | 5     | 20        | Estrategia secuencial oferta→demanda  |
| RB2    | Proyección de ingresos no alcanzada      | 3     | 4     | 12        | Escenario conservador viable          |
| RB3    | Riesgo regulatorio                       | 2     | 4     | 8         | Diseño conforme a Ley 29733 y MTC     |
| RB4    | Riesgo competitivo                       | 2     | 4     | 8         | Velocidad de captura del corredor     |
| RB5    | Riesgo técnico                           | 3     | 3     | 9         | MVP acotado; gestión ágil (8 sprints) |

## Referencias

Armstrong & Associates, Inc. (2025). U.S. Third-Party Logistics (3PL) Market Size Estimates: Domestic Transportation Management. https://www.3plogistics.com/

Arvis, J.-F., Ojala, L., Shepherd, B., Ulybina, D., & Wiederer, C. (2023). Connecting to compete 2023: Trade logistics in an uncertain global economy — The logistics performance index and its indicators. World Bank Group.

Farromeque Quiroz, R. (2017). PERLOG-LATAM: Perfil logístico de América Latina. Banco de Desarrollo de América Latina (CAF).

Ministerio de Comercio Exterior y Turismo & Grupo Banco Mundial. (2016). Análisis integral de la logística en el Perú: 5 cadenas de exportación. MINCETUR.

Ministerio de la Producción. (2025). Las Mipyme en cifras 2024. Oficina General de Evaluación de Impacto y Estudios Económicos, PRODUCE.

Sociedad de Comercio Exterior del Perú \[ComexPerú\]. (2022). Los costos logísticos de las empresas en el país son del 16% en promedio, pero un 21.1% para las microempresas. Semanario Económico.


---

