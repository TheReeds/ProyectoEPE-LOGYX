# LOGYX — EPE Área de Gestión de Tecnologías de Información (GTI)

> Documento consolidado de los 4 entregables evaluados (Índice de Líneas Evaluadas GTI).
> Generado a partir de los 4 Word finales, sin resumir contenido — apto para estructurar como sitio MkDocs
> (una sección/página por Entregable, o subdividido por sub-secciones numeradas H2/H3).

## Tabla de contenido de este documento

1. ENTREGABLE 1 — DIAGNÓSTICO ORGANIZACIONAL Y ALINEAMIENTO ESTRATÉGICO (CE0111–CE0115)
2. ENTREGABLE 2 — BUSINESS CASE DEL PROYECTO (CE0113)
3. ENTREGABLE 3 — PLAN DE GESTIÓN DEL PROYECTO (CE0121–CE0125)
4. ENTREGABLE 4 — MODELADO DE PROCESOS AS-IS / TO-BE (CE0131–CE0135)

---

<!-- ============================================================ -->
<!-- ENTREGABLE 1 — DIAGNÓSTICO ORGANIZACIONAL Y ALINEAMIENTO ESTRATÉGICO (CE0111–CE0115) -->
<!-- ============================================================ -->

**UNIVERSIDAD PERUANA UNIÓN**

Facultad de Ingeniería y Arquitectura — Escuela de Ingeniería de Sistemas

**LOGYX**

*Infraestructura Digital Colaborativa para la Logística de PYMEs*

**Entregable 1: Diagnóstico Organizacional y Alineamiento Estratégico**

Evaluación del Perfil de Egreso (EPE) — Área de Gestión de Tecnologías de Información (GTI)

*Línea evaluada: CE0111–CE0115*

Docente:

**Integrantes:**

Fabrizio Yerald Alfonso Sánchez Saravia

Alex Coila Jarita

Jorge Luis Gutiérrez Miranda

Migue Alexandre Huayhua Chambi

Juliaca, Perú — Julio 2026

# **Nota Metodológica**

Este documento es uno de los 4 entregables del área de Gestión de Tecnologías de Información (GTI) del Perfil de Egreso, conforme al índice de líneas evaluadas: Entregable 1 — Diagnóstico Organizacional y Alineamiento Estratégico (CE0111–CE0115); Entregable 2 — Business Case del Proyecto (CE0113); Entregable 3 — Plan de Gestión del Proyecto (CE0121–CE0125); Entregable 4 — Modelado de Procesos AS-IS/TO-BE (CE0131–CE0135). La línea CE014 (Solución Técnica Integrada) se evalúa en otro momento y no forma parte de esta entrega; las referencias a su contenido en este documento se declaran explícitamente como “fuera del alcance de esta ronda de evaluación”.

Este documento específico corresponde al Entregable 1. El diagnóstico se desarrolla bajo un enfoque de doble lente: (1) el análisis interno (AMOFHIT, Matriz EFI, FODA/CAME) evalúa a LOGYX como organización —el sujeto que ejecuta el proyecto—; (2) el análisis externo (Porter, PESTEL, Matriz EFE) evalúa el ecosistema logístico PYME–transportista del corredor Lima–Sierra Sur como el mercado donde LOGYX opera, representado mediante una PYME arquetipo para el análisis de procesos (desarrollado en el Entregable 4).

Como refuerzo de la Matriz de Riesgos Estratégicos (CE0115), se incorpora al final de este documento (sección 1.7) un análisis de Gobierno de TI bajo el marco COBIT 2019, que profundiza el diagnóstico de riesgo desde la perspectiva de gobierno corporativo de TI.

# **Entregable 1 — Diagnóstico Organizacional y Alineamiento Estratégico**

*(Evalúa: CE011 — Gestión e Innovación de TI · Evidencias CE0111, CE0112, CE0113, CE0114, CE0115)*

## **1.1 Contexto Organizacional (CE0111)**

### **1.1.1 Unidad de análisis**

El objeto del presente diagnóstico es el ecosistema logístico de las pequeñas y medianas empresas del corredor Lima–Sierra Sur (Lima–Arequipa–Juliaca–Puno–Cusco). Un ecosistema, a diferencia de una organización individual, carece de estructura jerárquica y documentos institucionales propios; por ello, para efectos operativos del análisis, se emplea como recurso metodológico declarado una PYME arquetipo: una empresa manufacturera o comercial del corredor, con envíos regulares de 0.5 a 5 toneladas y frecuencia semanal, que coordina su transporte de manera informal. Esta figura sintetiza el perfil de los segmentos identificados en el estudio de mercado del proyecto y permite aplicar los instrumentos de análisis estratégico (FODA, EFI, EFE, PESTEL, Porter, CAME) sobre un sujeto concreto sin perder la representatividad del ecosistema.

LOGYX —plataforma colaborativa de logística B2B— constituye la solución TIC que se propondrá como resultado de este diagnóstico, y su diseño técnico se desarrolla en la documentación técnica de la solución (fuera del alcance de esta ronda de evaluación). Esta separación metodológica garantiza que el diagnóstico no esté sesgado hacia la solución: primero se caracteriza el problema del ecosistema con evidencia verificable, y solo después se justifica la intervención tecnológica.

### **1.1.2 Descripción del sector y entorno competitivo**

El tejido empresarial peruano está compuesto por **2,330,226 MIPYMEs formales** (Ministerio de la Producción, 2025), concentradas mayoritariamente en los sectores Comercio (44.1%) y Servicios (41.3%), con Manufactura representando el 8.7%.

Geográficamente, Lima concentra más del 40% del total nacional de empresas formales; tras la capital, las regiones de **Arequipa, Cusco y Puno** representan colectivamente los mercados comerciales más grandes del país (Cuadro 4.5, PRODUCE 2025).

En el plano macro-logístico, el Perú obtiene un puntaje de **3.0 sobre 5 en el Logistics Performance Index 2023** del Banco Mundial, con rezagos particulares en infraestructura física (2.5) y eficiencia aduanera (2.6) (Arvis et al., 2023).

El entorno competitivo del servicio de transporte de carga en el corredor está dominado por la informalidad: coordinación por WhatsApp, llamadas y Excel; intermediarios sin tecnología ni trazabilidad; y la figura del “hombre-camión” que atomiza la oferta.

### **1.1.3 Estructura organizacional de la PYME arquetipo**

| **Rol**                      | **Funciones**                                           | **Relación con la logística**                                            |
|------------------------------|---------------------------------------------------------|--------------------------------------------------------------------------|
| Gerente–propietario          | Dirección general, decisiones comerciales y financieras | Negocia personalmente cada flete por teléfono; decide el transportista   |
| Administrador / contador     | Facturación, pagos, tributos                            | Registra el gasto de flete sin desglose ni comparativo                   |
| Encargado de almacén         | Recepción, despacho y empaque de mercadería             | Coordina la hora de recojo por WhatsApp; sin evidencia formal de entrega |
| Ventas / atención al cliente | Pedidos y relación con clientes                         | Informa al cliente el estado del envío “llamando al chofer”              |

La función logística no existe como área: está distribuida informalmente entre el gerente, el almacén y ventas, sin procesos definidos, sin indicadores y sin sistemas de información de soporte.

### **1.1.4 Cadena de valor logística del corredor**

**Actividades primarias del flujo logístico**

| **Eslabón**                    | **Actividad actual**                                | **Dónde se destruye valor**                                        |
|--------------------------------|-----------------------------------------------------|--------------------------------------------------------------------|
| 1\. Generación de la necesidad | La PYME identifica un envío pendiente               | Sin planificación: gestión reactiva                                |
| 2\. Búsqueda de transporte     | Llamadas y WhatsApp a 5–10 transportistas conocidos | Horas-hombre del gerente; oferta limitada                          |
| 3\. Negociación de precio      | Regateo verbal sin referencia de mercado            | Opacidad según urgencia y asimetría                                |
| 4\. Intermediación (frecuente) | Broker informal consigue el camión y cobra margen   | Margen sin valor agregado (15.3%, Armstrong & Associates, 2025)    |
| 5\. Ejecución del transporte   | El transportista recoge y traslada la carga         | 40–45% de recorridos regionales en vacío (Farromeque Quiroz, 2017) |
| 6\. Entrega y conformidad      | Entrega sin evidencia formal                        | Disputas sin resolución; fraude y pérdidas                         |
| 7\. Pago y registro            | Efectivo o transferencia; registro manual           | Sin trazabilidad contable ni datos para negociar                   |

Conclusión: los eslabones 2, 3, 4 y 5 concentran la destrucción de valor —actividades de coordinación e información, no de transporte físico—, evidenciando que el problema es de naturaleza informacional y abordable mediante una solución TIC.

<img src="media/image7.png" style="width:6.45232in;height:3.84952in" />

*Figura 5. Cadena de Valor de Porter aplicada a LOGYX (actividades primarias, de apoyo y margen).*

### **1.1.5 Mapa de stakeholders**

| **Stakeholder**                                | **Poder**         | **Interés**      | **Cuadrante / estrategia** |
|------------------------------------------------|-------------------|------------------|----------------------------|
| PYMEs del corredor (demanda)                   | Bajo (individual) | Alto             | Mantener informados        |
| Empresas transportistas medianas               | Medio             | Alto             | Gestionar de cerca         |
| Transportistas independientes                  | Bajo (individual) | Alto             | Mantener informados        |
| Brokers / intermediarios informales            | Medio             | Alto (contrario) | Monitorear                 |
| Asociaciones de transportistas (Juliaca, Puno) | Alto              | Medio            | Gestionar de cerca         |
| Cámaras de comercio y gremios                  | Alto              | Medio            | Mantener satisfechos       |
| MTC / SUNAT (reguladores)                      | Alto              | Bajo             | Mantener satisfechos       |
| Clientes finales de las PYMEs                  | Bajo              | Medio            | Monitorear                 |

### **1.1.6 Aspectos Generales de la Organización LOGYX**

A diferencia de las secciones 1.1.1 a 1.1.5 (que caracterizan el ecosistema de mercado en el que LOGYX opera), esta sección presenta a LOGYX como organización —el sujeto que ejecuta el proyecto—, con el mismo nivel de detalle institucional exigido en un diagnóstico organizacional formal.

**Reseña histórica**

LOGYX nace como proyecto de fin de carrera del equipo de Ingeniería de Sistemas de la Universidad Peruana Unión (sede Juliaca), a partir de la identificación directa del problema de fragmentación logística que afecta a las PYMEs del corredor Lima–Sierra Sur. El proyecto se formaliza en el marco de la Evaluación del Perfil de Egreso (EPE), con el propósito de evolucionar de un ejercicio académico a un emprendimiento tecnológico viable.

**Ubicación geográfica**

Sede principal del equipo: Juliaca, región Puno, Perú. Ámbito de operación proyectado: corredor Lima–Arequipa–Juliaca–Puno–Cusco.

**Cobertura y modalidad de operación**

LOGYX no opera locales físicos de atención al público: es una plataforma digital (aplicación web y móvil) con cobertura en todo el corredor Lima–Sierra Sur desde el lanzamiento del MVP, escalable a nuevos corredores en fases posteriores del roadmap (Entregable 1, sección 1.5).

**Equipo (número de integrantes y roles)**

- Fabrizio Yerald Alfonso Sánchez Saravia — Co-founder & Backend Engineer

- Alex Coila Jarita — Co-founder & Mobile Engineer

- Jorge Luis Gutiérrez Miranda — CEO & Lead Developer

- Migue Alexandre Huayhua Chambi — Integrante del equipo de desarrollo

**Razón social y naturaleza jurídica**

A la fecha de este documento, LOGYX opera como proyecto académico–emprendedor en fase de incubación, sin constitución legal formal. La forma societaria proyectada para la etapa de operación comercial es una Sociedad Anónima Cerrada (S.A.C.), conforme a la Ley General de Sociedades del Perú, a definirse formalmente al iniciar la fase de comercialización real (posterior al piloto de la solución).

**Población objetivo y alcance**

PYMEs manufactureras y comerciales del corredor Lima–Sierra Sur con envíos regulares de 0.5 a 5 toneladas, y transportistas independientes o empresas de transporte de 1 a 50 unidades. Dimensionamiento completo del mercado (TAM–SAM–SOM) en el Entregable 2, sección 2.3.

**Proveedores y aliados estratégicos**

- Proveedores de infraestructura cloud (servicios de cómputo, base de datos y almacenamiento)

- Proveedor de servicio de ruteo y geolocalización (cálculo de distancias reales)

- Pasarela de pagos digital (para la fase de escrow, roadmap H2)

- Asociaciones de transportistas de Juliaca y Puno (aliados clave de la estrategia de arranque de la solución)

- Cámaras de comercio y gremios empresariales del corredor (canal de acceso a la demanda)

**Productos y servicios ofrecidos**

Marketplace de carga con subasta inversa, motor de precios de referencia, negociación moderada, tracking multi-parada con evidencia digital, sistema de reputación verificable, y consolidación/aprovechamiento de cargas de retorno. Detalle funcional completo en la Documentación General del Producto LOGYX (fuera del alcance de esta ronda de evaluación).

**Identidad institucional: misión, visión y valores de LOGYX**

**Misión:** democratizar el acceso a capacidades logísticas de nivel corporativo para las PYMEs y transportistas del corredor Lima–Sierra Sur, mediante una plataforma digital colaborativa que reduce costos, genera confianza verificable y elimina la ineficiencia de la coordinación informal.

**Visión:** ser la infraestructura digital de referencia de la logística colaborativa en el sur del Perú, y sentar las bases para expandirse como el sistema operativo logístico de las PYMEs latinoamericanas.

- Confianza: verificación real de identidad y desempeño de cada actor de la plataforma

- Transparencia: precios de referencia y reputación visibles para todas las partes

- Colaboración: el valor de la red crece cuanto más se usa entre todos los actores

- Innovación aplicada: soluciones tecnológicas diseñadas para la realidad del corredor, no adaptaciones genéricas

**Tecnología y modernización**

Arquitectura de monolito modular sobre infraestructura cloud, con aplicaciones web y móviles nativas. Detalle técnico completo en la documentación técnica de la solución (fuera del alcance de esta ronda de evaluación).

**Logo institucional**

**\[COMPLETAR POR EL EQUIPO — insertar aquí el logo institucional de LOGYX (imagen), una vez definido por el equipo.\]**

## **1.2 Análisis Estratégico (CE0112)**

### **1.2.1 Orientación estratégica de la PYME arquetipo**

- **Misión:** producir y comercializar bienes de calidad para clientes del corredor Lima–Sierra Sur, entregando a tiempo y a costos competitivos.

- **Visión:** ser una empresa regional confiable, con operaciones logísticas predecibles y costos comparables a los de una empresa grande.

- **Valores:** cumplimiento, confianza, mejora continua y orientación al cliente.

- OE1 — Reducir el costo logístico como % de las ventas, cerrando la brecha de ~5 pp (ComexPerú, 2022).

- OE2 — Elevar la confiabilidad de las entregas con evidencia formal.

- OE3 — Ganar capacidad de planificación del gasto logístico.

- OE4 — Ampliar el alcance comercial a nuevas plazas del corredor.

### **1.2.2 Análisis Interno: Fortalezas y Debilidades (AMOFHIT)**

El análisis interno se desarrolla siguiendo las seis áreas funcionales del modelo AMOFHIT (Administración, Marketing, Operaciones, Finanzas, Recursos Humanos, Sistemas de Información), aplicado a LOGYX como organización. Para cada área se desarrolla el fundamento de la fortaleza y de la debilidad identificadas, antes de presentar el resumen tabulado.

**Administración y gerencia (A).** La estructura organizacional plana de LOGYX —cuatro fundadores sin niveles jerárquicos intermedios— permite decisiones ágiles: una modificación de arquitectura o una reorientación de prioridad de sprint se decide en horas, no en semanas. Esta agilidad es una fortaleza real en la fase de MVP, donde la velocidad de iteración es crítica. Sin embargo, la contraparte de esa misma estructura es la dependencia total del criterio del equipo fundador: no existen mecanismos de gobierno corporativo, comités de decisión formales, ni checks and balances que prevengan sesgos de decisión concentrados en pocas personas —precisamente la brecha que el refuerzo de gobierno bajo COBIT 2019 (sección 1.7) busca cerrar.

**Marketing y clientes (M).** El equipo mantiene relación directa y cercana con los primeros usuarios objetivo del corredor (gremios de transportistas de Juliaca y Puno, PYMEs contactadas en la fase de validación exploratoria), lo que permite iterar el producto con retroalimentación real. La debilidad es estructural: sin track record de mercado ni marca reconocida, LOGYX no puede aún prometer plazos de adopción confiables a inversionistas ni a los propios usuarios — es una limitación común a cualquier startup pre-lanzamiento, pero que debe declararse explícitamente en el diagnóstico.

**Operaciones y logística (O).** El equipo posee conocimiento empírico acumulado de las rutas del corredor y de los patrones de comportamiento de transportistas informales, adquirido durante la fase de investigación del problema (Entregable 1, sección 1.1.4). Este conocimiento de dominio es una fortaleza que reduce el riesgo de diseñar una solución desalineada con la realidad operativa del sector. La debilidad es que ese conocimiento aún no se traduce en un proceso propio de operación de LOGYX como empresa: la gestión interna del equipo (sprints, entregas, coordinación) es todavía reactiva, sin la disciplina de proceso que la propia plataforma promete a sus usuarios.

**Finanzas (F).** El registro básico de gastos del proyecto existe (inversión de desarrollo, costos de infraestructura, Entregable 2, sección 2.6), lo cual es una base mínima de control financiero. La debilidad relevante es la ausencia de capital de inversión externo: el financiamiento del proyecto depende únicamente de recursos propios del equipo fundador, lo que limita la velocidad de escalamiento una vez validado el modelo y expone al proyecto a restricciones de flujo de caja si la fase de adopción (cold-start) se extiende más allá de lo proyectado.

**Recursos humanos (H).** El equipo reducido de cuatro integrantes permite comunicación rápida y alineación constante —no hay pérdida de información por capas jerárquicas. La debilidad directa de ese mismo tamaño es la limitación de capacidad: el equipo debe escalar simultáneamente el desarrollo técnico del producto y la operación comercial (ventas, onboarding, soporte) sin personal dedicado a cada frente, lo que genera riesgo de cuellos de botella durante el arranque en frío (Entregable 1, riesgo RE2).

**Sistemas de información y tecnología (T e I).** Esta es el área de mayor fortaleza relativa de LOGYX: el equipo diseñó desde el inicio una arquitectura modular escalable (monolito modular migrable a microservicios, documentación técnica de la solución) y domina el stack tecnológico completo (backend, frontend web, móvil, infraestructura cloud). La debilidad, coherente con la fase del proyecto, es que el producto aún está en versión MVP: funcionalidades avanzadas como el escrow de pagos o las cooperativas de volumen (roadmap H2–H3, Entregable 1 sección 1.5) no están implementadas todavía.

| **Área (AMOFHIT)**        | **Fortalezas**                                  | **Debilidades**                             |
|---------------------------|-------------------------------------------------|---------------------------------------------|
| Administración y gerencia | Decisiones ágiles por estructura plana          | Dependencia total del criterio del gerente  |
| Marketing y clientes      | Relación directa y cercana con el cliente       | Sin capacidad de prometer plazos confiables |
| Operaciones y logística   | Conocimiento empírico de rutas y transportistas | Negociación reactiva envío por envío        |
| Finanzas                  | Registro básico de gastos generales             | Costo logístico no desglosado ni comparado  |
| Recursos humanos          | Equipo pequeño, comunicación rápida             | Función logística dispersa sin responsable  |
| Sistemas de información   | Uso cotidiano de smartphone y WhatsApp          | Cero sistemas de información logística      |

### **1.2.3 Matriz EFI — Evaluación de Factores Internos**

*Supuesto declarado del equipo: a partir de esta versión, la Matriz EFI evalúa a LOGYX como organización (startup en fase de incubación), no a una PYME arquetipo ficticia. Los pesos y calificaciones siguen siendo juicio experto del equipo por consenso, metodología estándar en la construcción de matrices EFI/EFE.*

Escala de calificación: 4 = fortaleza mayor, 3 = fortaleza menor, 2 = debilidad menor, 1 = debilidad mayor. Los factores internos considerados son:

- **F1.** Equipo multidisciplinario con dominio técnico full-stack (backend, frontend web, móvil e infraestructura cloud).

- **F2.** Arquitectura de software modular y escalable diseñada desde el inicio (monolito modular, migrable a microservicios).

- **F3.** Diagnóstico de mercado validado con fuentes externas verificadas (ComexPerú, CAF, Banco Mundial, PRODUCE).

- **F4.** Modelo de negocio con comisión escalonada por lealtad (2%–7%), significativamente más eficiente que el margen de un broker tradicional (15.3%).

- **F5.** Diferenciación funcional real frente a la competencia: consolidación de cargas y aprovechamiento de retornos (Smart Load Planner).

- **F6.** Bajo costo de infraestructura inicial gracias a arquitectura cloud eficiente y stack de código abierto.

- **D1.** Sin capital de inversión externo: financiamiento limitado a recursos propios del equipo fundador.

- **D2.** Sin historial de mercado ni marca reconocida: cero clientes activos hasta la fecha de este documento.

- **D3.** Equipo con dominio técnico pero sin experiencia previa en ventas B2B ni desarrollo comercial.

- **D4.** Validación de mercado pendiente de ejecución real: hipótesis de demanda no probada en campo con clientes pagantes.

- **D5.** Equipo reducido (4 integrantes) para escalar simultáneamente desarrollo de producto y operación comercial.

- **D6.** Producto en fase de MVP: funcionalidades avanzadas (escrow de pagos, cooperativas de volumen) aún no implementadas.

<img src="media/image1.png" style="width:6.4625in;height:4.87639in" />Lectura: un puntaje ponderado entre 1.0 y 2.5 indica una posición interna débil; entre 2.5 y 4.0, una posición interna fuerte. El resultado de 2.50 refleja el balance real de una startup en etapa temprana: fortalezas técnicas y de producto sólidas, contrarrestadas por debilidades típicas de validación de mercado y capital, propias de esta fase del proyecto.

### **1.2.4 Análisis del Microentorno — Cinco Fuerzas de Porter**

**1. Rivalidad entre competidores actuales**

Descripción: oferta extremadamente fragmentada (hombre-camión y empresas medianas). La atomización produce una paradoja: hay muchos oferentes, pero la PYME no puede compararlos.

- **Intensidad:** Alta (fragmentación) pero invisible para la demanda.

- Estrategia: mecanismo de comparación transparente (precio + reputación).

**2. Amenaza de productos sustitutos**

Descripción: el principal sustituto es el statu quo de WhatsApp + Excel + llamadas, con costo percibido cero.

- **Intensidad:** Muy alta — factor competitivo más determinante.

- Estrategia: experiencia igual o más simple que WhatsApp, con valor inmediato percibido.

**3. Amenaza de nuevos entrantes**

Descripción: plataformas internacionales (Uber Freight, SAP TM) podrían ingresar; sus barreras son el conocimiento local y la masa crítica necesaria.

- **Intensidad:** Media a mediano plazo.

- Estrategia: capturar el corredor con velocidad y relaciones gremiales.

**4. Poder de negociación de los proveedores (transportistas)**

Descripción: bajo individualmente, pero se invierte en situaciones de escasez percibida.

- **Intensidad:** Baja individual, alta situacional.

- Estrategia: dar visibilidad de la oferta real disponible en tiempo real.

**5. Poder de negociación de los compradores (PYMEs)**

Descripción: es el problema P5 — la PYME negocia como minorista, sin volumen agregado (brecha 21.1% vs. 15.7%, ComexPerú, 2022).

- **Intensidad:** Muy baja — fuerza más desfavorable para la PYME.

- Estrategia: articular consolidación de demanda entre PYMEs.

Conclusión: la fuerza dominante es el sustituto (statu quo informal), lo que define el criterio de diseño: debe ser radicalmente más simple y con valor inmediato para vencer la inercia.

### **1.2.5 Análisis del Macroentorno — PESTEL**

El análisis PESTEL examina las seis dimensiones del macroentorno que condicionan al ecosistema logístico del corredor y, por extensión, la viabilidad de LOGYX. Para cada dimensión se desarrolla el razonamiento antes de presentar el resumen tabulado clasificado en Oportunidad (O) o Amenaza (A).

**Político.** El Estado peruano impulsa la formalización empresarial y la digitalización tributaria como política sostenida: la obligatoriedad progresiva de la Guía de Remisión Electrónica (GRE) de SUNAT presiona a PYMEs y transportistas a documentar digitalmente sus traslados, convirtiendo la trazabilidad —hoy inexistente en el proceso informal— en un requisito regulatorio inminente y no solo en una mejora deseable. Esta presión regulatoria es una oportunidad directa para LOGYX. En sentido contrario, la inestabilidad política recurrente del país genera incertidumbre en la continuidad de programas de apoyo a la MIPYME y en la predictibilidad del marco normativo a mediano plazo, lo que constituye una amenaza para la planificación de largo plazo del proyecto.

**Económico.** El costo logístico nacional promedio equivale al 16% del valor de las ventas, pero se eleva a 21.1% en la microempresa frente a 15.7% en la gran empresa (ComexPerú, 2022): la escala determina el costo, y las empresas del corredor operan en el extremo desfavorable de esa curva —exactamente la brecha que LOGYX busca cerrar. A ello se suma la volatilidad del precio del combustible, insumo dominante de la tarifa de flete, y un contexto de desaceleración del consumo interno que presiona los márgenes de las PYMEs, haciendo el sobrecosto logístico proporcionalmente más doloroso. Estos dos últimos factores son amenazas que LOGYX no controla, pero que refuerzan la urgencia de su propuesta de valor.

**Social.** La cultura operativa del corredor descansa en el acuerdo verbal y la confianza personal: se contrata al transportista “conocido” aunque no sea el más eficiente, porque no existe información verificable sobre alternativas. Esta desconfianza mutua estructural actúa como fricción en cada transacción y es una amenaza directa a la velocidad de adopción de cualquier solución digital. En contraste, la penetración universal de teléfonos inteligentes y el uso cotidiano de WhatsApp entre los actores del ecosistema demuestran que ya operan digitalmente —solo que con herramientas no diseñadas para logística—, lo que representa una oportunidad real de adopción si el diseño de LOGYX iguala esa simplicidad.

**Tecnológico.** La brecha tecnológica es doble. En el plano macro, la infraestructura física del país puntúa 2.5 sobre 5 en el LPI 2023 (Arvis et al., 2023): carreteras de penetración a la sierra vulnerables a interrupciones, una amenaza estructural que ninguna solución de software puede resolver por sí sola. En el plano de oportunidad, la disponibilidad de APIs de ruteo, servicios cloud de bajo costo y pasarelas de pago locales hace técnica y económicamente viable, por primera vez, una plataforma logística digital diseñada específicamente para este segmento —la ventana tecnológica que LOGYX aprovecha.

**Ecológico.** La tasa regional de recorridos en vacío del 40–45% (Farromeque Quiroz, 2017) implica que casi la mitad de los kilómetros recorridos por la flota de carga no transporta mercadería: combustible quemado y emisiones sin valor económico asociado. Este factor es ambivalente según el abordaje: es una amenaza ambiental si el ecosistema no actúa, pero se convierte en la oportunidad ambiental más directa del sector si LOGYX logra consolidar cargas y capturar retornos, alineado además con la creciente exigencia de sostenibilidad en cadenas de suministro corporativas.

**Legal.** Dos marcos condicionan la operación. La normativa del MTC sobre transporte de carga (licencias, permisos de operación, SOAT vigente) hoy no es verificada por las PYMEs al contratar —una amenaza de riesgo legal que LOGYX puede convertir en oportunidad diferenciadora mediante su módulo de verificación KYC. La Ley N° 29733 de Protección de Datos Personales es relevante para cualquier solución que registre datos de conductores (DNI, licencias), geolocalización y datos comerciales de empresas: representa una amenaza de cumplimiento si se ignora, pero una oportunidad de diferenciación por confianza si LOGYX la cumple rigurosamente desde el diseño (desarrollo completo en la documentación técnica de la solución).

| **Dimensión** | **Factor del macroentorno**                                                 | **O/A**                 |
|---------------|-----------------------------------------------------------------------------|-------------------------|
| Político      | Obligatoriedad progresiva de la Guía de Remisión Electrónica (GRE) de SUNAT | O                       |
| Político      | Inestabilidad política recurrente                                           | A                       |
| Económico     | Brecha de costo: 21.1% vs. 15.7% (ComexPerú, 2022)                          | A                       |
| Económico     | Volatilidad del precio del combustible                                      | A                       |
| Económico     | Desaceleración del consumo interno                                          | A                       |
| Social        | Cultura del acuerdo verbal y desconfianza mutua                             | A                       |
| Social        | Penetración universal de smartphone y WhatsApp                              | O                       |
| Tecnológico   | Rezago de infraestructura física: 2.5/5 en el LPI 2023 (Arvis et al., 2023) | A                       |
| Tecnológico   | APIs de ruteo, cloud de bajo costo y pasarelas de pago locales              | O                       |
| Ecológico     | Recorridos en vacío del 40–45% (Farromeque Quiroz, 2017)                    | A / O según abordaje    |
| Ecológico     | Exigencia creciente de sostenibilidad en cadenas de suministro              | O                       |
| Legal         | Normativa MTC de transporte de carga hoy no verificada                      | A                       |
| Legal         | Ley N° 29733 de Protección de Datos Personales                              | A / O si se cumple bien |

### **1.2.6 Matriz EFE — Evaluación de Factores Externos**

*Supuesto declarado del equipo: los pesos y calificaciones de la Matriz EFE son juicio experto del equipo derivado del PESTEL y Porter precedentes. A diferencia de la Matriz EFI (que ahora evalúa a LOGYX como organización), la Matriz EFE mantiene como objeto de análisis el entorno de mercado —el ecosistema PYME–transportista del corredor Lima–Sierra Sur—, que es el entorno externo real donde LOGYX opera.*

Escala de calificación: 4 = respuesta superior, 3 = superior a la media, 2 = media, 1 = mala frente al factor. Los factores externos considerados son:

- **O1.** GRE electrónica: empuja hacia la trazabilidad digital.

- **O2.** Consolidación cooperativa: palanca de negociación.

- **O3.** Tecnología accesible: cloud, APIs y pagos digitales.

- **O4.** 40–45% de capacidad ociosa en retornos capturable.

- **O5.** Ausencia de competidores digitales especializados.

- **A1.** Costos crecientes de combustible.

- **A2.** Dependencia de infraestructura vial vulnerable.

- **A3.** Entrada futura de plataformas internacionales.

- **A4.** Resistencia cultural al cambio (statu quo informal).

- **A5.** Inestabilidad política y regulatoria.

- **A6.** Brecha de costos estructural de la microempresa.

- **A7.** Ley 29733: requisitos de protección de datos personales.

<img src="media/image2.png" style="width:6.4625in;height:3.87431in" />Lectura: un puntaje de 2.21 (bajo el punto medio de 2.5) indica que el ecosistema responde débilmente a oportunidades y amenazas del entorno, consistente con la ausencia de mecanismos que le permitan capitalizarlas. Junto al EFI de LOGYX (sección 1.2.3), evidencia que el diagnóstico interno y externo son consistentes entre sí: la organización aún no cuenta con una posición interna consolidada, y el entorno externo tampoco ofrece condiciones favorables sin intervención activa.

### **1.2.7 Análisis FODA y Cruce Estratégico CAME**

*Decisión metodológica: el FODA y el cruce CAME de esta sección se reconstruyen con los mismos factores internos (F1–F6, D1–D6) de la Matriz EFI de LOGYX (sección 1.2.3), manteniendo las oportunidades y amenazas (O1–O5, A1–A7) de la Matriz EFE (sección 1.2.6). Así, el diagnóstico interno (LOGYX como organización) y el diagnóstico externo (el mercado donde opera) quedan integrados bajo una misma matriz FODA, evitando dos sistemas de códigos incompatibles.*

<table>
<colgroup>
<col style="width: 50%" />
<col style="width: 50%" />
</colgroup>
<tbody>
<tr class="odd">
<td><strong>Fortalezas (F)</strong></td>
<td><strong>Debilidades (D)</strong></td>
</tr>
<tr class="even">
<td><p>F1. Equipo multidisciplinario full-stack (backend, frontend, móvil, cloud)</p>
<p>F2. Arquitectura modular y escalable diseñada desde el inicio</p>
<p>F3. Diagnóstico de mercado validado con fuentes externas verificadas</p>
<p>F4. Comisión escalonada (2%–7%), más eficiente que un broker tradicional (15.3%)</p>
<p>F5. Diferenciación funcional real: consolidación de cargas y retornos</p>
<p>F6. Bajo costo de infraestructura inicial (cloud eficiente, stack abierto)</p></td>
<td><p>D1. Sin capital de inversión externo</p>
<p>D2. Sin historial de mercado ni marca reconocida</p>
<p>D3. Sin experiencia previa en ventas B2B</p>
<p>D4. Validación de mercado real aún pendiente de ejecución</p>
<p>D5. Equipo reducido (4 integrantes) para escalar producto y comercial a la vez</p>
<p>D6. Producto en fase MVP: funcionalidades avanzadas aún no implementadas</p></td>
</tr>
</tbody>
</table>

<table>
<colgroup>
<col style="width: 50%" />
<col style="width: 50%" />
</colgroup>
<tbody>
<tr class="odd">
<td><strong>Oportunidades (O)</strong></td>
<td><strong>Amenazas (A)</strong></td>
</tr>
<tr class="even">
<td><p>O1. GRE electrónica: empuje regulatorio a la trazabilidad</p>
<p>O2. Consolidación cooperativa como palanca de negociación</p>
<p>O3. Tecnología accesible (cloud, APIs, pagos digitales)</p>
<p>O4. 40–45% de capacidad ociosa en retornos capturable</p>
<p>O5. Ausencia de competidores digitales especializados</p></td>
<td><p>A1. Costos crecientes de combustible</p>
<p>A2. Dependencia de infraestructura vial vulnerable</p>
<p>A3. Entrada futura de plataformas internacionales</p>
<p>A4. Resistencia cultural al cambio (statu quo informal)</p>
<p>A5. Inestabilidad política y regulatoria</p>
<p>A6. Brecha de costos estructural de la microempresa</p>
<p>A7. Ley 29733: requisitos de protección de datos personales</p></td>
</tr>
</tbody>
</table>

El análisis CAME traduce el cruce FODA en cuatro líneas de acción: Corregir debilidades aprovechando oportunidades (DO), Afrontar amenazas reduciendo debilidades (DA), Mantener fortalezas para neutralizar amenazas (FA), y Explotar fortalezas sobre oportunidades (FO):

|                     |           |                                                                                                                                                                                       |
|---------------------|-----------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **Estrategia CAME** | **Cruce** | **Descripción**                                                                                                                                                                       |
| EXPLOTAR (FO)       | F5+O4     | Usar la diferenciación funcional de consolidación de cargas para capturar la capacidad ociosa de retornos del corredor (40–45%).                                                      |
| EXPLOTAR (FO)       | F1+F2+O3  | Usar el dominio técnico full-stack y la arquitectura escalable junto con la tecnología accesible (cloud, APIs) para acelerar el desarrollo del MVP.                                   |
| CORREGIR (DO)       | D2+D4+O5  | Cerrar la falta de historial de mercado ejecutando la validación real aprovechando la ausencia actual de competidores digitales especializados.                                       |
| CORREGIR (DO)       | D1+O2     | Compensar la falta de capital externo mediante el modelo de consolidación cooperativa, que reduce el costo de adquisición de clientes al operar por recomendación gremial.            |
| MANTENER (FA)       | F3+A3     | Usar el diagnóstico de mercado validado como barrera de conocimiento local frente a la entrada de plataformas internacionales.                                                        |
| MANTENER (FA)       | F4+A6     | Sostener la comisión escalonada como ventaja competitiva frente a la brecha de costos estructural de la microempresa, sin necesidad de subsidiarla.                                   |
| AFRONTAR (DA)       | D5+A4     | Mitigar el riesgo de equipo reducido frente a la resistencia cultural al cambio priorizando un diseño de adopción sin fricción (onboarding asistido) antes de escalar comercialmente. |
| AFRONTAR (DA)       | D6+A7     | Cerrar las funcionalidades de cumplimiento (Ley 29733) como prioridad del MVP, antes que otras funcionalidades avanzadas aún pendientes.                                              |

### **1.2.8 Factores Críticos de Éxito (FCE)**

| **FCE**                                 | **Descripción**                                       | **Origen en el análisis**      |
|-----------------------------------------|-------------------------------------------------------|--------------------------------|
| FCE1. Confianza verificable             | Historial objetivo y verificación legal de cada actor | D1, D2 · Porter F5 · EFI       |
| FCE2. Precio de referencia transparente | Conocer el precio de mercado antes de negociar        | D3, D6 · Porter F5 · ComexPerú |
| FCE3. Consolidación de carga            | Agrupar cargas compatibles y capturar retornos        | O2, O4 · CAME Explotar         |
| FCE4. Trazabilidad extremo a extremo    | Estado y evidencia en cada operación                  | D2, D4 · O1 · CAME Corregir    |
| FCE5. Adopción sin fricción             | Más simple que WhatsApp para vencer la inercia        | A4 · Porter F2 · CAME Afrontar |

## **1.3 Diagnóstico Digital / TI (CE0111/CE0113)**

### **1.3.1 Inventario de sistemas de información AS-IS**

| **Sistema / herramienta**       | **Función que cumple**                   | **Limitación crítica**                 | **Riesgo**                            |
|---------------------------------|------------------------------------------|----------------------------------------|---------------------------------------|
| WhatsApp                        | Canal de coordinación con transportistas | Información no estructurada, dispersa  | Pérdida de acuerdos; sin auditoría    |
| Llamadas telefónicas            | Negociación de precio y urgencias        | Cero registro                          | Disputas sin evidencia                |
| Excel / cuaderno físico         | Registro de envíos y gastos              | Manual, incompleto                     | Errores, sin analítica posible        |
| Efectivo / transferencia        | Pago del flete                           | Sin vínculo con conformidad de entrega | Impago o pago por servicio deficiente |
| Facturación electrónica (SUNAT) | Emisión de comprobantes                  | Aislada del proceso logístico          | Incumplimiento formal; multas         |

### **1.3.2 Nivel de madurez digital**

| **Nivel**      | **Caracterización**                                    | **¿La PYME arquetipo?**     |
|----------------|--------------------------------------------------------|-----------------------------|
| 1\. Ad-hoc     | Procesos informales, herramientas genéricas, sin datos | SÍ — nivel actual dominante |
| 2\. Repetible  | Rutinas establecidas pero manuales                     | Parcial                     |
| 3\. Definido   | Procesos documentados con herramientas específicas     | No                          |
| 4\. Gestionado | Indicadores medidos; decisiones con datos              | No                          |
| 5\. Optimizado | Mejora continua; automatización e inteligencia         | No                          |

Veredicto: nivel 1–2 (ad-hoc/repetible), consistente con el resultado cuantitativo de la Matriz EFI (1.93/4).

### **1.3.3 Brechas tecnológicas**

- **Brecha macro:** infraestructura 2.5 y aduanas 2.6 en el LPI 2023 (Arvis et al., 2023).

- **Brecha de trazabilidad:** 0% de envíos con seguimiento o evidencia formal.

- **Brecha de información de mercado:** sin referencia de precios por ruta.

- **Brecha de confianza verificable:** sin historial consultable de transportistas.

- **Brecha de consolidación:** sin mecanismo técnico de agrupación de cargas.

## **1.4 Identificación del Problema (CE0111)**

### **1.4.1 Definición estructurada del problema**

| **Código** | **Problema**                  | **Manifestación**                      | **Evidencia**                           |
|------------|-------------------------------|----------------------------------------|-----------------------------------------|
| P1         | Fragmentación operativa       | Gestión por WhatsApp, Excel y papel    | Inventario AS-IS; madurez 1–2; EFI 1.93 |
| P2         | Opacidad de precios           | Negociación sin referencia de mercado  | Cadena de valor eslabón 3; Porter F5    |
| P3         | Baja utilización logística    | Recorridos en vacío del 40–45%         | Farromeque Quiroz (2017); EFE O4        |
| P4         | Déficit de confianza          | Contratación sin historial verificable | Brecha de confianza; FCE1               |
| P5         | Falta de poder de negociación | Costo logístico 21.1% vs. 15.7%        | ComexPerú (2022); EFI D7; EFE A6        |

### **1.4.2 Análisis de causas raíz**

<table>
<colgroup>
<col style="width: 25%" />
<col style="width: 74%" />
</colgroup>
<thead>
<tr class="header">
<th><strong>Espina</strong></th>
<th><strong>Causas identificadas</strong></th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>Método (proceso)</td>
<td><p>• No existe proceso logístico definido</p>
<p>• Búsqueda por contactos personales (5–10 llamadas)</p>
<p>• Sin planificación ni consolidación de cargas propias</p></td>
</tr>
<tr class="even">
<td>Información (datos)</td>
<td><p>• Sin referencia de precios por ruta</p>
<p>• Sin historial de desempeño de transportistas</p>
<p>• Registro manual e incompleto del gasto</p></td>
</tr>
<tr class="odd">
<td>Tecnología</td>
<td><p>• Herramientas genéricas en lugar de sistemas del dominio</p>
<p>• Cero trazabilidad: sin GPS ni evidencia digital</p></td>
</tr>
<tr class="even">
<td>Personas (organización)</td>
<td><p>• Función logística dispersa entre roles</p>
<p>• Dependencia de la memoria del gerente</p></td>
</tr>
<tr class="odd">
<td>Mercado (estructura)</td>
<td><p>• Oferta atomizada sin mecanismo de agregación</p>
<p>• Intermediarios sin tecnología</p>
<p>• Demanda fragmentada sin poder de compra</p></td>
</tr>
<tr class="even">
<td>Entorno</td>
<td><p>• Infraestructura vial vulnerable</p>
<p>• Informalidad y débil fiscalización</p></td>
</tr>
</tbody>
</table>

Cuatro de las seis espinas corresponden a causas de coordinación e información, no a limitaciones físicas del transporte. La causa raíz sistémica es la ausencia de una capa de información compartida entre los actores.

*Supuesto declarado del equipo: el diagrama de Ishikawa visual se elaborará en herramienta con archivo fuente editable (draw.io, Bizagi o Enterprise Architect) a partir de esta tabla, para cumplir el requisito de formato de sustentación (Anexo C).*

### **1.4.3 Impacto estratégico**

- Sobre OE1: la brecha de ~5 pp erosiona el margen operativo, pudiendo equivaler a la utilidad neta de una PYME.

- Sobre OE2: sin trazabilidad, cada envío es un acto de fe; incidentes sin resolución formal.

- Sobre OE3: sin datos históricos, el gasto logístico es impredecible.

- Sobre OE4: la logística actúa como barrera al crecimiento comercial.

> *Se asume como hipótesis de trabajo, sustentada en la revisión bibliográfica del sector, que la informalidad en la coordinación logística de las PYMEs del corredor Lima–Arequipa–Juliaca genera pérdidas recurrentes de envíos y sobrecostos operativos. Esta hipótesis se apoya en evidencia indirecta: la alta tasa de recorridos en vacío documentada para la región (40–45%, Farromeque Quiroz, 2017), la brecha de costos logísticos que penaliza desproporcionadamente a la micro y pequeña empresa (21.1% vs. 15.7% de la gran empresa, ComexPerú, 2022), y el rezago estructural de Perú en infraestructura y eficiencia logística (puntaje 3.0/5 en el LPI 2023, Arvis et al., 2023). No existe actualmente una medición pública específica de la frecuencia de incidentes de coordinación para el corredor Lima–Sierra Sur, por lo que este dato queda fuera del alcance cuantificado del diagnóstico y se declara como supuesto de diseño del proyecto, no como estadística verificada.*

### **1.4.4 Justificación de la intervención y alineamiento estratégico**

| **FCE requerido**                    | **¿Alcanzable con el AS-IS?** | **¿Por qué no?**                                         |
|--------------------------------------|-------------------------------|----------------------------------------------------------|
| FCE1. Confianza verificable          | No                            | WhatsApp no genera historial ni verifica identidad legal |
| FCE2. Precio de referencia           | No                            | No existe fuente de datos de precios                     |
| FCE3. Consolidación de carga         | No                            | Requiere visibilidad simultánea de múltiples cargas      |
| FCE4. Trazabilidad extremo a extremo | No                            | Sin GPS, estados ni evidencia digital                    |
| FCE5. Adopción sin fricción          | —                             | El AS-IS fija el estándar de simplicidad a igualar       |

Ninguno de los cuatro primeros FCE es alcanzable con las herramientas actuales. Se justifica la intervención mediante una solución TIC colaborativa (LOGYX), contra la línea base establecida aquí (comparativo en el Entregable 4).

## **1.5 Roadmap de Tecnología (CE0114)**

| **Horizonte**                   | **Periodo**  | **Objetivo tecnológico**            | **Capacidades incorporadas**                                                               |
|---------------------------------|--------------|-------------------------------------|--------------------------------------------------------------------------------------------|
| H1 — Digitalizar la transacción | 0–6 meses    | Reemplazar la coordinación informal | Marketplace · subasta · negociación registrada · tracking · evidencia · verificación legal |
| H2 — Optimizar la red           | 6–12 meses   | Capturar la eficiencia estructural  | Consolidación inteligente · retornos · pricing dinámico · reputación · escrow              |
| H3 — Inteligencia y servicios   | 12–24+ meses | Convertir datos en valor predictivo | Predicción de demanda · ML · cooperativas · factoring logístico                            |

## **1.6 Matriz de Riesgos Estratégicos (CE0115)**

| **ID** | **Riesgo estratégico**                              | **P** | **I** | **Nivel**    | **Estrategia de respuesta**                               |
|--------|-----------------------------------------------------|-------|-------|--------------|-----------------------------------------------------------|
| RE1    | Resistencia cultural al cambio (statu quo WhatsApp) | 4     | 5     | 20 — Crítico | Diseño más simple, onboarding asistido, valor inmediato   |
| RE2    | Arranque en frío del marketplace                    | 4     | 5     | 20 — Crítico | Cold-start secuencial (oferta luego demanda con SLA 24h)  |
| RE3    | Desintermediación fuera de plataforma               | 3     | 4     | 12 — Alto    | Reputación no portable, moderación, beneficios exclusivos |
| RE4    | Dependencia de infraestructura vial vulnerable      | 3     | 4     | 12 — Alto    | Monitoreo y alertas de ruta                               |
| RE5    | Entrada de competidor internacional                 | 2     | 4     | 8 — Medio    | Velocidad de captura; conocimiento local                  |
| RE6    | Cambio regulatorio adverso                          | 2     | 3     | 6 — Medio    | Cumplimiento Ley 29733 y normativa MTC desde el origen    |
| RE7    | Incumplimiento de la promesa de ahorro              | 2     | 4     | 8 — Medio    | Medición del ahorro real desde el piloto                  |

## **1.7 Refuerzo de Gobierno de TI bajo COBIT 2019 (AS-IS / TO-BE) — extensión de CE0115**

Como complemento al modelado de procesos operativos (secciones 3.1 a 3.6), se aplicó el marco COBIT 2019 de ISACA para diagnosticar el estado actual (AS-IS) y diseñar el estado objetivo (TO-BE) del gobierno de TI de LOGYX como organización. A diferencia del AS-IS/TO-BE operativo (proceso de contratación de transporte), este análisis cubre el nivel de gobierno: qué prácticas de gestión del riesgo, seguridad, cumplimiento y monitoreo debe establecer LOGYX para operar con confianza.

LOGYX no es una organización con TI de soporte: la tecnología es el producto. Por ello, el sistema de gobierno de TI no es un complemento de la operación —es la operación misma—, lo que eleva la relevancia de los procesos de gestión del riesgo, seguridad, gestión de servicios y monitoreo por encima del promedio de una organización de tamaño equivalente.

**1.7.1 Factores de Diseño (síntesis DF1–DF11)**

|        |                                    |                                                                                                                                                                    |
|--------|------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **\#** | **Factor de Diseño**               | **Resultado aplicado a LOGYX**                                                                                                                                     |
| DF1    | Estrategia empresarial             | Innovación/Diferenciación (5) + Servicio/Estabilidad (4): la plataforma es el diferenciador. Eleva procesos de calidad, riesgo y operación digital.                |
| DF2    | Metas empresariales                | Metas primarias: EG02 (riesgo), EG06 (continuidad), EG03 (cumplimiento), EG12 (transformación digital). Sustenta EDM01, APO12, APO13, DSS05, MEA03.                |
| DF3    | Perfil de riesgo                   | Riesgos críticos: ataques lógicos y datos personales/biométricos. Riesgos altos: incumplimiento normativo, acciones no autorizadas, incidentes de infraestructura. |
| DF4    | Problemas de TI                    | Falta de alineación negocio-TI, proyectos sin gestión formal, gastos de TI sin estructura presupuestal. Confirma el bloque MEA01–MEA04.                            |
| DF5    | Panorama de amenazas               | Alto: cibercriminalidad en sector tech, superficie de ataque ampliada por APIs externas y datos personales.                                                        |
| DF6    | Requisitos de cumplimiento         | Alto: Ley N° 29733 + D.S. 003-2013-JUS, normativa MTC, PCI-DSS vía pasarela de pagos. Hace de MEA03 inclusión obligatoria.                                         |
| DF7    | Rol de TI                          | Estratégico + Transformación + Fábrica: TI es el producto. Eleva todos los objetivos de gobierno por encima de la línea base.                                      |
| DF8    | Modelo de aprovisionamiento        | Mixto: interno + nube + tercerizado (conectividad, ruteo). Refuerza DSS05 para control sobre servicios externos.                                                   |
| DF9    | Métodos de implementación          | Predominantemente tradicional (planificación formal) con componente ágil y DevOps. Efecto transversal sobre BAI01 y APO05.                                         |
| DF10   | Estrategia de adopción tecnológica | Seguidor: adopta tecnologías probadas rápidamente. Eleva APO02, APO11, BAI01, BAI02, BAI04, BAI11.                                                                 |
| DF11   | Tamaño de la empresa               | Startup pequeña (4 fundadores, sin área de TI formal). Aplica el modelo COBIT completo con despliegue gradual y documentación proporcional.                        |

**1.7.2 Cascada de metas: de la estrategia de negocio a los procesos priorizados**

La cascada de metas justifica por qué los procesos de gobierno seleccionados son los correctos para LOGYX, partiendo de sus metas de negocio concretas:

|                               |                                                                                                                                                                |
|-------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **Nivel de la cascada**       | **Elementos**                                                                                                                                                  |
| Metas corporativas (EG)       | EG02 Gestión de riesgos del negocio · EG06 Continuidad y disponibilidad del servicio · EG03 Cumplimiento de leyes y regulaciones · EG12 Transformación digital |
| ↓ Metas de alineamiento (AG)  | AG02 Gestión del riesgo de TI · AG07 Seguridad de información y privacidad · AG01 Cumplimiento de I&T con leyes externas · AG05 Entrega de servicios de I&T    |
| ↓ Procesos COBIT prioritarios | APO12 Gestión del riesgo · APO13 Gestión de la seguridad · DSS05 Servicios de seguridad · MEA03 Cumplimiento de requisitos externos · EDM01 Marco de gobierno  |

La cascada demuestra que los procesos de seguridad y cumplimiento no son opcionales para LOGYX: son la traducción directa de sus metas de negocio en capacidades de gobierno requeridas, lo que justifica su inclusión en el portafolio aunque el proyecto esté en fase MVP.

**1.7.3 Componentes del sistema de gobierno: AS-IS vs. TO-BE**

|                                           |                                                                               |                                                                                                                              |
|-------------------------------------------|-------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------|
| **Componente**                            | **AS-IS**                                                                     | **TO-BE**                                                                                                                    |
| Procesos                                  | Cero procesos de gobierno formales; decisiones ad hoc del equipo fundador     | 9 procesos COBIT core al nivel de capacidad 1–2 antes del MVP: EDM01, APO01, APO05, APO12, APO13, BAI01, DSS05, MEA01, MEA03 |
| Estructuras organizacionales              | Sin estructura de gobierno; los fundadores actúan sin diferenciación de roles | Comité de Gobierno de TI (fundadores, agenda quincenal) + CISO funcional + Product Owner como responsable de proceso         |
| Políticas y procedimientos                | Sin políticas formales; decisiones técnicas implícitas en el stack            | Política de privacidad, política de seguridad, procedimiento de gestión de incidentes, política de uso aceptable             |
| Flujos de información                     | Información de gobierno circula informalmente (WhatsApp, llamadas)            | Dashboard de operación en tiempo real, log centralizado de seguridad, reporte quincenal de gobierno, registro de auditoría   |
| Cultura y comportamiento                  | Foco en el producto; riesgo y cumplimiento percibidos como fases futuras      | Security by design y compliance by design como principios del desarrollo desde el Sprint 1                                   |
| Habilidades y competencias                | Competencias técnicas sólidas, sin formación en riesgo/seguridad/cumplimiento | Autoformación estructurada en Ley 29733, OWASP Top 10 y NIST CSF básico antes del lanzamiento                                |
| Servicios, infraestructura y aplicaciones | Stack bien diseñado pero sin infraestructura de gobierno desplegada           | Gestión de secretos, monitoreo (Prometheus/Grafana), CI/CD con security gate, backup automatizado, gestión de parches        |

**1.7.4 Procesos COBIT priorizados (portafolio de 20, síntesis por dominio)**

|             |                                           |           |           |                                                                                                   |
|-------------|-------------------------------------------|-----------|-----------|---------------------------------------------------------------------------------------------------|
| **Proceso** | **Nombre**                                | **AS-IS** | **TO-BE** | **Brecha principal**                                                                              |
| EDM01       | Marco de gobierno establecido y mantenido | 0         | 2         | Implementar el Comité de Gobierno mínimo y el RACI de responsabilidades                           |
| APO01       | Marco de gestión de I&T                   | 0         | 2         | Desarrollar el conjunto mínimo de políticas (privacidad, seguridad, uso aceptable)                |
| APO12       | Gestión del riesgo                        | 0         | 2         | Registro de riesgos mínimo con los 6 riesgos críticos del Business Case y revisión quincenal      |
| APO13       | Gestión de la seguridad                   | 0         | 2         | Controles OWASP Top 10, política de seguridad y proceso de gestión de incidentes antes del MVP    |
| BAI01       | Programas                                 | 0         | 2         | Integrar el plan de proyecto (PMBOK, Entregable 3) con el sistema de gobierno                     |
| DSS05       | Servicios de seguridad                    | 0         | 2         | Autenticación JWT, RBAC, cifrado en tránsito y gestión de secretos antes del MVP                  |
| MEA01       | Monitoreo del desempeño y conformidad     | 0         | 1         | Dashboard de operación con métricas básicas (uptime, latencia, incidentes abiertos)               |
| MEA03       | Cumplimiento de requisitos externos       | 0         | 2         | Política de privacidad pública, registro de tratamiento de datos, notificación de brechas en ≤72h |

*Nota: el portafolio completo priorizó 20 procesos COBIT; esta tabla presenta los 8 de mayor criticidad inmediata para el MVP. El detalle completo de los 20 procesos y su desarrollo metodológico (fases del diseño COBIT, análisis de factores) se documenta como evidencia complementaria del equipo.*

# **Referencias**

Armstrong & Associates, Inc. (2025). U.S. Third-Party Logistics (3PL) Market Size Estimates: Domestic Transportation Management. https://www.3plogistics.com/

Arvis, J.-F., Ojala, L., Shepherd, B., Ulybina, D., & Wiederer, C. (2023). Connecting to compete 2023: Trade logistics in an uncertain global economy — The logistics performance index and its indicators. World Bank Group.

Farromeque Quiroz, R. (2017). PERLOG-LATAM: Perfil logístico de América Latina. Banco de Desarrollo de América Latina (CAF).

Ministerio de Comercio Exterior y Turismo & Grupo Banco Mundial. (2016). Análisis integral de la logística en el Perú: 5 cadenas de exportación. MINCETUR.

Ministerio de la Producción. (2025). Las Mipyme en cifras 2024. Oficina General de Evaluación de Impacto y Estudios Económicos, PRODUCE.

Sociedad de Comercio Exterior del Perú \[ComexPerú\]. (2022). Los costos logísticos de las empresas en el país son del 16% en promedio, pero un 21.1% para las microempresas. Semanario Económico.


---

<!-- ============================================================ -->
<!-- ENTREGABLE 2 — BUSINESS CASE DEL PROYECTO (CE0113) -->
<!-- ============================================================ -->

**UNIVERSIDAD PERUANA UNIÓN**

Facultad de Ingeniería y Arquitectura — Escuela de Ingeniería de Sistemas

**LOGYX**

*Infraestructura Digital Colaborativa para la Logística de PYMEs*

**Entregable 2: Business Case del Proyecto**

Evaluación del Perfil de Egreso (EPE) — Área de Gestión de Tecnologías de Información (GTI)

*Línea evaluada: CE0113*

Docente:

**Integrantes:**

Fabrizio Yerald Alfonso Sánchez Saravia

Alex Coila Jarita

Jorge Luis Gutiérrez Miranda

Migue Alexandre Huayhua Chambi

Juliaca, Perú — Julio 2026

# **Nota Metodológica**

Este documento es uno de los 4 entregables del área de Gestión de Tecnologías de Información (GTI) del Perfil de Egreso, conforme al índice de líneas evaluadas: Entregable 1 — Diagnóstico Organizacional y Alineamiento Estratégico (CE0111–CE0115); Entregable 2 — Business Case del Proyecto (CE0113); Entregable 3 — Plan de Gestión del Proyecto (CE0121–CE0125); Entregable 4 — Modelado de Procesos AS-IS/TO-BE (CE0131–CE0135). La línea CE014 (Solución Técnica Integrada) se evalúa en otro momento y no forma parte de esta entrega; las referencias a su contenido en este documento se declaran explícitamente como “fuera del alcance de esta ronda de evaluación”.

Este documento específico corresponde al Entregable 2 (Business Case), que en versiones anteriores de este trabajo se desarrolló como sección 1.7 del Diagnóstico Organizacional; se presenta aquí como documento independiente conforme al índice de líneas evaluadas vigente, con numeración propia (secciones 2.1 a 2.8).

Esta sección desarrolla el Caso de Negocio exigido por CE0113 dentro del Entregable 1, justificando la viabilidad y conveniencia del proyecto LOGYX como respuesta al diagnóstico precedente.

## **2.1 Justificación del proyecto**

El proyecto aborda el problema estructural diagnosticado (P1–P5). Su expresión económica más medible es la brecha de costos: 16% promedio nacional, **21.1% en la microempresa vs. 15.7% en la gran empresa** (ComexPerú, 2022). El beneficio central es el cierre progresivo de esa brecha.

## **2.2 Objetivos del proyecto (SMART)**

| **ID** | **Objetivo SMART**                                                                                 |
|--------|----------------------------------------------------------------------------------------------------|
| OP1    | Poner en operación el MVP de LOGYX en el corredor Lima–Sierra Sur en 16 semanas desde el Sprint 1. |
| OP2    | Incorporar 20 transportistas verificados con flota declarada antes de la semana 4.                 |
| OP3    | Alcanzar 80 PYMEs activas y NPS ≥ 45 al cierre de la semana 12.                                    |
| OP4    | Completar 200 empresas activas y el punto de equilibrio al cierre de la semana 24.                 |
| OP5    | Lograr ≥ 60% de solicitudes con oferta en 24h desde el mes 2.                                      |
| OP6    | Reducir el tiempo de contratación de un flete de días a menos de 60 minutos.                       |

## **2.3 Dimensionamiento del mercado (TAM → SAM → SOM)**

- **TAM:** 2,330,226 MIPYMEs formales (Ministerio de la Producción, 2025).

- **SAM:** ~50,000 PYMEs del corredor Lima–Sierra Sur (derivación propia, Anexo A).

- **SOM (año 1):** 300–500 PYMEs y 100–150 transportistas.

## **2.4 Análisis de Alternativas**

| **Criterio (peso)**            | **A. Statu quo** | **B. Broker tradicional** | **C. SaaS existente** | **D. Desarrollar LOGYX** |
|--------------------------------|------------------|---------------------------|-----------------------|--------------------------|
| Costo total PYME (25%)         | 3                | 1                         | 2                     | 4                        |
| Cobertura de FCE (30%)         | 1                | 2                         | 3                     | 5                        |
| Adecuación al corredor (20%)   | 5                | 4                         | 1                     | 4                        |
| Escalabilidad (15%)            | 1                | 1                         | 3                     | 5                        |
| Riesgo de implementación (10%) | 5                | 4                         | 3                     | 2                        |
| PUNTAJE PONDERADO              | 2.60             | 2.15                      | 2.40                  | 4.25                     |

La alternativa D (desarrollar LOGYX) obtiene el mayor puntaje, con ventaja decisiva en cobertura de FCE y escalabilidad; su riesgo de implementación se gestiona mediante la estrategia secuencial de arranque descrita en la documentación de implementación de la solución (fuera del alcance de esta ronda de evaluación).

## **2.5 Evaluación de Beneficios**

- **Gasto logístico mensual por PYME:** USD 500–5,000 (derivado de 16–21.1% de ventas de USD 3,000–24,000; Anexo A).

- **Ahorro potencial:** USD 150–1,200 mensuales por PYME al cerrar ~5 pp.

- **Beneficio al transportista:** ingreso adicional por km ya recorrido al reducir retornos vacíos.

## **2.6 Estimación de Costos**

*Supuesto declarado del equipo: 4 integrantes × 15 h/semana × 16 semanas = 960 horas; tarifa de referencia S/ 25/hora.*

| **Concepto**                                  | **Monto (S/)** |
|-----------------------------------------------|----------------|
| Desarrollo del MVP (960 h × S/ 25)            | 24,000         |
| Infraestructura cloud de desarrollo (4 meses) | 760            |
| Dominio, certificados y servicios menores     | 300            |
| Contingencia (10%)                            | 2,506          |
| TOTAL INVERSIÓN INICIAL                       | 27,566         |

Costos operativos: ~S/ 2,000/mes. TCO a 24 meses: S/ 75,566.

## **2.7 Evaluación Financiera**

*Supuesto declarado del equipo: horizonte 24 meses; tasa de descuento anual 18%; ticket promedio S/ 1,200; comisión efectiva 4.5% (rango 2%–7%).*

| **Indicador**                      | **Escenario base**    | **Escenario conservador (50%)** |
|------------------------------------|-----------------------|---------------------------------|
| Ingresos acumulados 24 meses       | S/ 584,820            | S/ 292,410                      |
| Flujo neto acumulado               | S/ 509,254            | S/ 216,844                      |
| Payback                            | Mes 11–12             | Mes 15–16                       |
| ROI a 24 meses                     | ≈ 6.7×                | ≈ 2.9×                          |
| Valor Actual Neto (VAN, 18% anual) | S/ 364,229 (positivo) | S/ 149,932 (positivo)           |
| Tasa Interna de Retorno (TIR)      | ≈ 417.8% anual        | ≈ 217.3% anual                  |

Aun en el escenario conservador el proyecto recupera su inversión dentro del horizonte. La sensibilidad del modelo está en el volumen de operaciones, reforzando que el riesgo dominante es de adopción (RE1/RE2), no financiero.

*Nota sobre la TIR: los valores obtenidos (417.8% en el escenario base, 217.3% en el conservador) son elevados porque la inversión inicial (S/ 27,566) es pequeña en relación con los ingresos proyectados a 24 meses —patrón típico de startups de software de bajo capital intensivo (“asset-light”). El VAN positivo en ambos escenarios (S/ 364,229 y S/ 149,932 respectivamente, descontados al 18% anual) es el indicador más robusto de viabilidad financiera; la TIR se reporta por completitud metodológica, pero su magnitud debe interpretarse con cautela y idealmente contrastarse con un análisis de sensibilidad antes de usarse como argumento independiente ante inversionistas.*

## **2.8 Riesgos Iniciales del Proyecto**

| **ID** | **Riesgo**                               | **P** | **I** | **Nivel** | **Mitigación**                        |
|--------|------------------------------------------|-------|-------|-----------|---------------------------------------|
| RB1    | Adopción insuficiente (arranque en frío) | 4     | 5     | 20        | Estrategia secuencial oferta→demanda  |
| RB2    | Proyección de ingresos no alcanzada      | 3     | 4     | 12        | Escenario conservador viable          |
| RB3    | Riesgo regulatorio                       | 2     | 4     | 8         | Diseño conforme a Ley 29733 y MTC     |
| RB4    | Riesgo competitivo                       | 2     | 4     | 8         | Velocidad de captura del corredor     |
| RB5    | Riesgo técnico                           | 3     | 3     | 9         | MVP acotado; gestión ágil (8 sprints) |

# **Referencias**

Armstrong & Associates, Inc. (2025). U.S. Third-Party Logistics (3PL) Market Size Estimates: Domestic Transportation Management. https://www.3plogistics.com/

Arvis, J.-F., Ojala, L., Shepherd, B., Ulybina, D., & Wiederer, C. (2023). Connecting to compete 2023: Trade logistics in an uncertain global economy — The logistics performance index and its indicators. World Bank Group.

Farromeque Quiroz, R. (2017). PERLOG-LATAM: Perfil logístico de América Latina. Banco de Desarrollo de América Latina (CAF).

Ministerio de Comercio Exterior y Turismo & Grupo Banco Mundial. (2016). Análisis integral de la logística en el Perú: 5 cadenas de exportación. MINCETUR.

Ministerio de la Producción. (2025). Las Mipyme en cifras 2024. Oficina General de Evaluación de Impacto y Estudios Económicos, PRODUCE.

Sociedad de Comercio Exterior del Perú \[ComexPerú\]. (2022). Los costos logísticos de las empresas en el país son del 16% en promedio, pero un 21.1% para las microempresas. Semanario Económico.


---

<!-- ============================================================ -->
<!-- ENTREGABLE 3 — PLAN DE GESTIÓN DEL PROYECTO (CE0121–CE0125) -->
<!-- ============================================================ -->

**UNIVERSIDAD PERUANA UNIÓN**

Facultad de Ingeniería y Arquitectura — Escuela de Ingeniería de Sistemas

**LOGYX**

*Infraestructura Digital Colaborativa para la Logística de PYMEs*

**Entregable 3: Plan de Gestión del Proyecto**

Evaluación del Perfil de Egreso (EPE) — Área de Gestión de Tecnologías de Información (GTI)

*Línea evaluada: CE0121–CE0125*

Docente:

**Integrantes:**

Fabrizio Yerald Alfonso Sánchez Saravia

Alex Coila Jarita

Jorge Luis Gutiérrez Miranda

Migue Alexandre Huayhua Chambi

Juliaca, Perú — Julio 2026

# **Nota Metodológica**

Este documento es uno de los 4 entregables del área de Gestión de Tecnologías de Información (GTI) del Perfil de Egreso, conforme al índice de líneas evaluadas: Entregable 1 — Diagnóstico Organizacional y Alineamiento Estratégico (CE0111–CE0115); Entregable 2 — Business Case del Proyecto (CE0113); Entregable 3 — Plan de Gestión del Proyecto (CE0121–CE0125); Entregable 4 — Modelado de Procesos AS-IS/TO-BE (CE0131–CE0135). La línea CE014 (Solución Técnica Integrada) se evalúa en otro momento y no forma parte de esta entrega; las referencias a su contenido en este documento se declaran explícitamente como “fuera del alcance de esta ronda de evaluación”.

Este documento específico corresponde al Entregable 3 (Plan de Gestión del Proyecto), bajo un enfoque híbrido PMBOK–ágil. Incluye evidencia real de configuración en Azure DevOps (sección 3.6.4) y, como refuerzo de la Gestión de Riesgos del Proyecto (CE0125), una sección de Cumplimiento Normativo (sección 3.7) derivada del análisis de Gobierno de TI bajo COBIT 2019 desarrollado en el Entregable 1.

# **Entregable 3 — Plan de Gestión del Proyecto (PMBOK / Agile)**

*(Evalúa: CE012 — Gestión de Proyectos · Evidencias CE0121, CE0122, CE0123, CE0124, CE0125)*

El plan adopta un enfoque híbrido: los artefactos de gobierno del proyecto siguen las buenas prácticas del PMBOK (acta de constitución, EDT, línea base de costos, gestión de riesgos), mientras que la ejecución del desarrollo se gestiona con Scrum (backlog priorizado, sprints de dos semanas, métricas de velocidad). Esta combinación es la recomendada por el PMI para proyectos de software con alcance evolutivo y equipo pequeño.

## **3.1 Acta de Constitución del Proyecto — Project Charter (CE0121)**

| **Campo**                    | **Contenido**                                                                                                                                                                                                                                                                                                                                 |
|------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Nombre del proyecto          | LOGYX — Plataforma colaborativa de logística B2B para PYMEs del corredor Lima–Sierra Sur                                                                                                                                                                                                                                                      |
| Sponsor                      | Docente responsable del EPE — área GTI, EP Ingeniería de Sistemas, UPeU \[confirmar nombre\]                                                                                                                                                                                                                                                  |
| Director del proyecto        | Fabrizio Yerald Alfonso Sánchez Saravia                                                                                                                                                                                                                                                                                                       |
| Equipo del proyecto          | Alex Coila Jarita · Jorge Luis Gutiérrez Miranda · Migue Alexandre Huayhua Chambi                                                                                                                                                                                                                                                             |
| Justificación                | Cerrar la brecha de costos logísticos que penaliza a las PYMEs del corredor (21.1% vs. 15.7% de las ventas, ComexPerú, 2022) mediante una plataforma de consolidación, transparencia y trazabilidad (Business Case, Entregable 2)                                                                                                             |
| Objetivos                    | OP1–OP6 del Business Case (Entregable 2, sección 2.2): MVP operativo en 16 semanas; 20 transportistas verificados a la semana 4; 80 PYMEs y NPS ≥ 45 a la semana 12; 200 empresas y punto de equilibrio a la semana 24                                                                                                                        |
| Alcance preliminar (incluye) | Módulos del MVP: autenticación multi-rol y verificación legal · gestión de flota y conductores · publicación de solicitudes y motor de costos · subasta inversa y ofertas · negociación · tracking multi-parada con evidencia · documentos · notificaciones · reputación básica · panel del operador · consolidación y cargas de retorno (v1) |
| Fuera del alcance (MVP)      | Pagos integrados con escrow en producción · cooperativas con contratos de volumen · predicción con aprendizaje automático · expansión a otros corredores (horizontes H2/H3 del roadmap)                                                                                                                                                       |
| Supuestos                    | Disponibilidad del equipo de 15 h/semana por integrante · acceso a gremios de transportistas de Juliaca/Puno para el arranque · infraestructura cloud en capas gratuita/educativa durante el desarrollo                                                                                                                                       |
| Restricciones                | Plazo académico de 16 semanas para el MVP · presupuesto de S/ 27,566 (línea base) · equipo de 4 personas a tiempo parcial · cumplimiento de Ley 29733 y normativa MTC                                                                                                                                                                         |
| Criterios de éxito           | MVP desplegado y demostrable · flujo completo publicar–ofertar–aceptar–entregar–calificar funcionando de extremo a extremo · cumplimiento de OP1 y avance verificable hacia OP2–OP4                                                                                                                                                           |
| Hitos de alto nivel          | H1: arquitectura y módulos base (fin S2) · H2: marketplace y subastas operativas (fin S6) · H3: tracking y app del conductor (fin S10) · H4: MVP integrado en staging (fin S14) · H5: MVP en producción y demo final (fin S16)                                                                                                                |

## **3.2 Gestión del Alcance: EDT/WBS y diccionario (CE0122)**

La Estructura de Desglose del Trabajo se organiza en cuatro cuentas de control. Los paquetes de trabajo del desarrollo se mapean directamente desde las épicas del backlog del producto (EP-01 a EP-16), garantizando trazabilidad entre el plan predictivo y la ejecución ágil:

| **Código EDT**                         | **Paquete de trabajo**                 | **Descripción (diccionario)**                                   | **Épica origen** |
|----------------------------------------|----------------------------------------|-----------------------------------------------------------------|------------------|
| 1\. Gestión del proyecto               |                                        |                                                                 |                  |
| 1.1                                    | Planificación y seguimiento            | Acta, plan, ceremonias Scrum, informes de avance por sprint     | —                |
| 1.2                                    | Gestión de riesgos y calidad           | Matriz RP viva, plan de pruebas, criterios de aceptación        | —                |
| 2\. Plataforma — núcleo transaccional  |                                        |                                                                 |                  |
| 2.1                                    | Autenticación y verificación legal     | Registro multi-rol, validación de RUC/licencias, perfiles       | EP-01            |
| 2.2                                    | Gestión de flota y conductores         | Alta de vehículos, capacidades, asignación de conductores       | EP-15            |
| 2.3                                    | Solicitudes de carga y motor de costos | Publicación, cálculo de precio de referencia con rutas reales   | EP-02 · EP-05    |
| 2.4                                    | Subasta inversa y ofertas              | Ventana de subasta, ofertas, cierre automático, precio mínimo   | EP-02            |
| 2.5                                    | Negociación                            | Chat moderado, contraofertas, aceptación y contrato digital     | EP-04            |
| 2.6                                    | Publicación de viajes (oferta)         | Viajes disponibles del transportista y reservas de espacio      | EP-03            |
| 3\. Plataforma — operación y confianza |                                        |                                                                 |                  |
| 3.1                                    | Tracking multi-parada                  | Estados por parada, mapa, código de seguimiento                 | EP-06            |
| 3.2                                    | Aplicación del conductor               | Ruta asignada, confirmación con foto y firma, modo sin conexión | EP-07            |
| 3.3                                    | Documentos y evidencias                | Repositorio de guías, órdenes y evidencias por envío            | EP-09            |
| 3.4                                    | Notificaciones                         | Eventos en aplicación y correo por cambio de estado             | EP-10            |
| 3.5                                    | Reputación                             | Calificaciones post-entrega y puntaje compuesto                 | EP-08            |
| 3.6                                    | Incidencias y panel del operador       | Registro y resolución de incidencias; torre de control y SLA    | EP-11 · EP-12    |
| 3.7                                    | Consolidación y retornos (v1)          | Sugerencias de combinación de cargas y cargas de retorno        | EP-13 · EP-14    |
| 4\. Infraestructura y despliegue       |                                        |                                                                 |                  |
| 4.1                                    | Infraestructura como código y CI/CD    | Entornos, pipeline de integración y despliegue continuo         | EP-16            |
| 4.2                                    | Seguridad y datos                      | Políticas de acceso, cifrado, respaldo, cumplimiento 29733      | EP-16            |
| 4.3                                    | Puesta en producción                   | Despliegue final, datos semilla, smoke tests, demo              | —                |

Control de cambios: toda modificación de alcance se evalúa en la reunión de planificación de sprint contra el criterio de valor del MVP; los cambios que afecten hitos H1–H5 requieren aprobación del sponsor.

## **3.3 Gestión del Cronograma (CE0123)**

*Supuesto declarado del equipo: fecha de inicio del Sprint 1 fijada tentativamente para agosto de 2026, sujeta al calendario académico del semestre; toda la planificación está expresada en semanas relativas (S1–S16), por lo que el desplazamiento de la fecha de inicio no altera la estructura.*

| **Sprint** | **Semanas** | **Objetivo del sprint**                                                                         | **Paquetes EDT** | **Hito**                        |
|------------|-------------|-------------------------------------------------------------------------------------------------|------------------|---------------------------------|
| Sprint 1   | S1–S2       | Fundaciones: autenticación multi-rol, modelo de datos base, CI/CD operativo                     | 2.1 · 4.1        | H1 — arquitectura y base lista  |
| Sprint 2   | S3–S4       | Flota y solicitudes: alta de vehículos, publicación de cargas, motor de costos v1               | 2.2 · 2.3        |                                 |
| Sprint 3   | S5–S6       | Marketplace vivo: subasta inversa, ofertas y cierre automático                                  | 2.4              | H2 — marketplace operativo      |
| Sprint 4   | S7–S8       | Negociación y contrato: chat moderado, contraofertas, aceptación; publicación de viajes         | 2.5 · 2.6        |                                 |
| Sprint 5   | S9–S10      | Tracking y conductor: estados multi-parada, app del conductor con evidencia                     | 3.1 · 3.2        | H3 — tracking extremo a extremo |
| Sprint 6   | S11–S12     | Confianza documental: documentos, notificaciones, reputación básica                             | 3.3 · 3.4 · 3.5  |                                 |
| Sprint 7   | S13–S14     | Operación: incidencias, panel del operador, consolidación y retornos v1; integración en staging | 3.6 · 3.7        | H4 — MVP integrado en staging   |
| Sprint 8   | S15–S16     | Endurecimiento y salida: seguridad, datos semilla, producción, demo final                       | 4.2 · 4.3        | H5 — MVP en producción          |

<img src="media/image8.png" style="width:6.45232in;height:3.01837in" />

*Figura 6. Diagrama de Gantt del proyecto LOGYX (16 semanas, 8 sprints, 5 hitos H1–H5).*

Dependencias críticas de la ruta: 2.1 → 2.3 → 2.4 → 2.5 → 3.1 → 3.2 (el flujo transaccional completo). Los paquetes 3.3–3.5 pueden avanzar en paralelo desde el Sprint 5; 3.7 depende de que 2.3 y 2.6 estén estables. El diagrama de Gantt visual se elabora sobre esta tabla manteniendo estos vínculos.

## **3.4 Gestión de Costos: presupuesto y línea base (CE0124)**

El presupuesto total del proyecto es de S/ 27,566 (detalle en Entregable 2, sección 2.6). La línea base de costos se distribuye por sprint conforme al esfuerzo planificado (120 horas por sprint del equipo completo):

| **Periodo**             | **Costo de desarrollo (S/)** | **Otros costos (S/)** | **Acumulado (S/)** |
|-------------------------|------------------------------|-----------------------|--------------------|
| Sprint 1 (S1–S2)        | 3,000                        | 440 (infra + dominio) | 3,440              |
| Sprint 2 (S3–S4)        | 3,000                        | 190                   | 6,630              |
| Sprint 3 (S5–S6)        | 3,000                        | 190                   | 9,820              |
| Sprint 4 (S7–S8)        | 3,000                        | 190                   | 13,010             |
| Sprint 5 (S9–S10)       | 3,000                        | 190                   | 16,200             |
| Sprint 6 (S11–S12)      | 3,000                        | 190                   | 19,390             |
| Sprint 7 (S13–S14)      | 3,000                        | 190                   | 22,580             |
| Sprint 8 (S15–S16)      | 3,000                        | 190                   | 25,770             |
| Reserva de contingencia |                              | 1,796                 | 27,566             |

<img src="media/image9.png" style="width:6.01487in;height:3.24038in" />

*Figura 7. Curva S de la línea base de costos acumulada, LOGYX (16 semanas).*

Control presupuestal: el consumo real de horas se registra por sprint en la herramienta de gestión; una desviación acumulada mayor al 10% activa la revisión de alcance con el sponsor. La reserva de contingencia solo se libera contra riesgos materializados de la matriz RP.

## **3.5 Gestión de Riesgos del Proyecto (CE0125)**

Riesgos operativos del proyecto (distintos de los estratégicos RE y de negocio RB), con análisis cualitativo y plan de respuesta:

| **ID** | **Riesgo del proyecto**                                                     | **P** | **I** | **Nivel** | **Respuesta**                                                                                                    |
|--------|-----------------------------------------------------------------------------|-------|-------|-----------|------------------------------------------------------------------------------------------------------------------|
| RP1    | Disponibilidad del equipo menor a la planificada (carga académica paralela) | 4     | 4     | 16        | Mitigar: alcance del sprint dimensionado al 80% de la capacidad teórica; buffer del Sprint 8 para endurecimiento |
| RP2    | Subestimación de la complejidad de los módulos de consolidación/retornos    | 3     | 4     | 12        | Mitigar: versión 1 acotada (sugerencias básicas); la optimización avanzada pasa al horizonte H2                  |
| RP3    | Bloqueos por dependencias externas (APIs de rutas, validación de RUC)       | 3     | 3     | 9         | Mitigar: contratos simulados (mocks) desde el Sprint 1; proveedor alterno identificado                           |
| RP4    | Deuda técnica acumulada que frena los últimos sprints                       | 3     | 3     | 9         | Mitigar: definición de terminado estricta, revisión de código cruzada y pruebas automatizadas en CI              |
| RP5    | Pérdida de un integrante (salud, retiro del curso)                          | 2     | 4     | 8         | Aceptar con plan: documentación continua y propiedad compartida del código (sin silos por persona)               |
| RP6    | Incidente de seguridad o pérdida de datos en desarrollo                     | 2     | 4     | 8         | Mitigar: respaldos automáticos, secretos fuera del repositorio, política de accesos mínimos                      |

La matriz se revisa en la retrospectiva de cada sprint: los riesgos materializados se registran con su impacto real y las respuestas se ajustan. El registro histórico de riesgos forma parte de la evidencia de gestión del proyecto.

## **3.6 Gestión Ágil**

La ejecución se gobierna con Scrum adaptado a un equipo de cuatro personas a tiempo parcial: sprints de dos semanas, planificación y retrospectiva por sprint, sincronización asíncrona diaria, y tablero de trabajo en la plataforma del repositorio.

### **3.6.1 Backlog del producto (resumen por épicas)**

| **Épica** | **Nombre**                   | **Alcance esencial**                              | **Sprint(s)** |
|-----------|------------------------------|---------------------------------------------------|---------------|
| EP-01     | Autenticación y verificación | Registro multi-rol, verificación legal de actores | 1             |
| EP-02     | Marketplace y subastas       | Solicitudes, subasta inversa, ofertas, cierre     | 2–3           |
| EP-03     | Publicación de viajes        | Oferta de espacio del transportista y reservas    | 4             |
| EP-04     | Negociación                  | Chat moderado y contraofertas                     | 4             |
| EP-05     | Motor de costos              | Precio de referencia con distancias reales        | 2             |
| EP-06     | Tracking multi-parada        | Estados por parada y seguimiento                  | 5             |
| EP-07     | Aplicación del conductor     | Ruta, evidencia (foto + firma), modo sin conexión | 5             |
| EP-08     | Reputación                   | Calificaciones y puntaje compuesto                | 6             |
| EP-09     | Documentos                   | Repositorio de guías y evidencias                 | 6             |
| EP-10     | Notificaciones               | Eventos en aplicación y correo                    | 6             |
| EP-11     | Incidencias                  | Registro y resolución con hilo de comentarios     | 7             |
| EP-12     | Panel del operador           | Torre de control, SLA y asignación manual         | 7             |
| EP-13     | Consolidación (Smart Load)   | Sugerencias de combinación de cargas (v1)         | 7             |
| EP-14     | Cargas de retorno            | Detección de cargas cerca del destino final       | 7             |
| EP-15     | Gestión de flota             | Vehículos, capacidades y conductores              | 2             |
| EP-16     | Infraestructura y CI/CD      | Entornos, pipeline, seguridad y respaldos         | 1 y 8         |

### **3.6.2 Historias de usuario (formato y ejemplos)**

Cada épica se descompone en historias con el formato estándar Como / Quiero / Para, criterios de aceptación verificables y estimación en puntos de historia. Ejemplos representativos:

- HU-021 (EP-02): Como PYME, quiero publicar una solicitud de carga con origen, destino, peso y fecha, para recibir ofertas competitivas de transportistas verificados. Criterios: la solicitud muestra un precio de referencia calculado antes de publicar; queda visible en el marketplace en menos de un minuto; solo transportistas verificados pueden ofertar.

- HU-034 (EP-02): Como transportista, quiero que la subasta se cierre automáticamente al vencer el tiempo o alcanzar el máximo de ofertas, para que las condiciones de competencia sean iguales para todos. Criterios: cierre automático verificable; ninguna oferta posterior al cierre es aceptada; la PYME recibe notificación con el resumen de ofertas.

- HU-058 (EP-07): Como conductor, quiero confirmar cada entrega con fotografía y firma del receptor incluso sin conexión, para que la evidencia quede registrada y se sincronice al recuperar señal. Criterios: captura local persistente; sincronización automática; la PYME ve la evidencia en su panel.

### **3.6.3 Métricas de la gestión ágil**

- Velocidad: puntos completados por sprint, con gráfico de tendencia a partir del Sprint 2.

- Burndown por sprint: trabajo restante diario contra la línea ideal; desviaciones se tratan en la sincronización.

- Calidad: cobertura de pruebas del backend y estado del pipeline como criterio de terminado; ningún incremento se integra con el pipeline en rojo.

El backlog completo —historias por épica con criterios y puntos, planificación detallada por sprint y métricas— se adjunta como evidencia en el Anexo C.

### **3.6.4 Evidencia de Configuración en Azure DevOps**

La planificación ágil descrita en las secciones 2.6.1 a 2.6.3 se implementó y configuró en Azure DevOps (organización fabriziosanchezs, proyecto LOGYX), como evidencia verificable de que el plan de sprints no es únicamente teórico. A continuación se documenta la configuración real de la herramienta: creación del proyecto, programación de los 8 sprints con sus fechas exactas, carga del backlog de épicas e historias de usuario, y su distribución en el Sprint Backlog y Taskboard.

<img src="media/image10.png" style="width:6.45232in;height:1.96401in" />

*Figura 8. Proyecto LOGYX creado en Azure DevOps (organización fabriziosanchezs).*

<img src="media/image11.png" style="width:6.45232in;height:2.76096in" />

*Figura 9. Iterations configuradas: 8 sprints con fechas de inicio y fin (03/08/2026 – 20/11/2026).*

<img src="media/image12.png" style="width:6.45232in;height:2.77649in" />

*Figura 10. Iterations activadas para el equipo LOGYX Team.*

<img src="media/image13.png" style="width:6.45232in;height:3.30441in" />

*Figura 11. Backlog de Épicas (EP-01 a EP-16) cargado en Azure Boards.*

<img src="media/image14.png" style="width:6.45232in;height:1.3977in" />

*Figura 12. Historias de usuario (HU-021, HU-034, HU-058) asignadas a sus sprints correspondientes.*

<img src="media/image15.png" style="width:6.45232in;height:1.11455in" />

*Figura 13. Sprint Backlog del Sprint 3 (31 ago – 11 sep 2026), con HU-021 y HU-034.*

<img src="media/image16.png" style="width:6.45232in;height:2.0239in" />

*Figura 14. Taskboard del Sprint 3: columnas To Do / In Progress / Done.*

Las fechas de las Figuras 9 y 10 coinciden exactamente con el cronograma declarado en la sección 3.3 (Gestión del Cronograma) y con el Diagrama de Gantt (Figura 6), garantizando consistencia entre la planificación documentada y la configuración real de la herramienta de gestión ágil.

## **3.7 Cumplimiento Normativo — Hallazgos del Análisis COBIT (extensión de CE0125)**

El análisis de gobierno de TI bajo COBIT 2019 (Entregable 1, sección 1.7) identificó obligaciones normativas concretas que la solución LOGYX debe satisfacer desde su diseño. El detalle técnico del cumplimiento de la Ley N° 29733 se desarrolla en la documentación técnica de la solución (fuera del alcance de esta ronda de evaluación); esta sección consolida las obligaciones accionables derivadas del análisis COBIT, sin repetir las medidas técnicas ya detalladas.

**Ley N° 29733 — Protección de Datos Personales**

|                                                            |                        |                                                                      |
|------------------------------------------------------------|------------------------|----------------------------------------------------------------------|
| **Obligación**                                             | **Norma**              | **Acción requerida**                                                 |
| Política de privacidad pública y visible                   | Art. 18, Ley 29733     | Redactar e implementar en la app y web antes del primer usuario real |
| Consentimiento informado para tratamiento de datos         | Art. 13, Ley 29733     | Implementar flujo de aceptación explícita en el onboarding           |
| Registro de actividades de tratamiento                     | Art. 39, Reglamento    | Crear y mantener el registro interno de tratamiento de datos         |
| Medidas de seguridad técnicas (cifrado, control de acceso) | Art. 39, Reglamento    | Implementar antes de procesar datos de usuarios reales               |
| Notificación de brechas a la ANPD en ≤72 horas             | Art. 39bis, Reglamento | Redactar y ensayar el procedimiento de notificación                  |
| Designación de responsable del tratamiento                 | Art. 37, Reglamento    | Asignar formalmente al CISO funcional del equipo                     |

**Normativa MTC y PCI-DSS**

- Riesgo de vigencia de la verificación: las licencias MTC y el SOAT pueden caducar entre la verificación inicial y la operación. El Trust Engine debe implementar alertas automáticas de vencimiento (SOAT 30 días antes, licencia MTC 60 días antes).

- Responsabilidad vicaria: el proceso de verificación legal multicapa (RUC + MTC + SOAT) constituye la evidencia de diligencia debida de LOGYX frente a un eventual incidente con un transportista verificado.

- PCI-DSS: LOGYX delega el procesamiento de tarjetas a la pasarela de pagos (certificada PCI-DSS); el diseño no debe almacenar datos de tarjeta en ningún momento (tokenización delegada), política que debe quedar documentada explícitamente.

**Top 5 riesgos críticos de TI para el gobierno de LOGYX**

|                                                              |               |                                                                                  |
|--------------------------------------------------------------|---------------|----------------------------------------------------------------------------------|
| **Riesgo**                                                   | **Severidad** | **Tratamiento recomendado**                                                      |
| Brecha de datos personales de usuarios                       | Crítico       | Cifrado en reposo/tránsito, RBAC, procedimiento de notificación a la ANPD        |
| Indisponibilidad del servicio de escrow (aplicable desde H2) | Crítico       | SLA interno 99.5%, mecanismo de contingencia, notificación automática al usuario |
| Compromiso de credenciales de API (SUNAT, MTC, ruteo)        | Alto          | Gestión de secretos, rotación periódica, sin secretos en el repositorio          |
| Carga fraudulenta (carrier fantasma con RUC válido)          | Alto          | Trust Engine con KYC multicapa y detección de fraude desde el primer carrier     |
| Pérdida de datos operativos sin respaldo                     | Alto          | Backup automático con retención de 30 días y prueba mensual de restauración      |


---

<!-- ============================================================ -->
<!-- ENTREGABLE 4 — MODELADO DE PROCESOS AS-IS / TO-BE (CE0131–CE0135) -->
<!-- ============================================================ -->

**UNIVERSIDAD PERUANA UNIÓN**

Facultad de Ingeniería y Arquitectura — Escuela de Ingeniería de Sistemas

**LOGYX**

*Infraestructura Digital Colaborativa para la Logística de PYMEs*

**Entregable 4: Modelado de Procesos AS-IS / TO-BE**

Evaluación del Perfil de Egreso (EPE) — Área de Gestión de Tecnologías de Información (GTI)

*Línea evaluada: CE0131–CE0135*

Docente:

**Integrantes:**

Fabrizio Yerald Alfonso Sánchez Saravia

Alex Coila Jarita

Jorge Luis Gutiérrez Miranda

Migue Alexandre Huayhua Chambi

Juliaca, Perú — Julio 2026

# **Nota Metodológica**

Este documento es uno de los 4 entregables del área de Gestión de Tecnologías de Información (GTI) del Perfil de Egreso, conforme al índice de líneas evaluadas: Entregable 1 — Diagnóstico Organizacional y Alineamiento Estratégico (CE0111–CE0115); Entregable 2 — Business Case del Proyecto (CE0113); Entregable 3 — Plan de Gestión del Proyecto (CE0121–CE0125); Entregable 4 — Modelado de Procesos AS-IS/TO-BE (CE0131–CE0135). La línea CE014 (Solución Técnica Integrada) se evalúa en otro momento y no forma parte de esta entrega; las referencias a su contenido en este documento se declaran explícitamente como “fuera del alcance de esta ronda de evaluación”.

Este documento específico corresponde al Entregable 4 (Modelado de Procesos AS-IS/TO-BE). El proceso se modela sobre el ecosistema PYME–transportista (PYME arquetipo) diagnosticado en el Entregable 1, y se complementa con el toolkit completo de Lean Six Sigma (5W2H, Swimlane, Ishikawa, árboles causales, Pareto, Brainstorming, Plan de Acción y Plan de Control, sección 4.6) aplicado específicamente al caso de LOGYX.

# **Entregable 4 — Modelado de Procesos AS-IS / TO-BE**

*(Evalúa: CE013 — Gestión de Procesos · Evidencias CE0131, CE0132, CE0133, CE0134, CE0135)*

## **4.1 Identificación y Caracterización del Proceso (CE0131)**

Del diagnóstico del Entregable 1 se selecciona el proceso crítico del ecosistema: la contratación y ejecución de un envío de carga, por ser el proceso donde convergen los cinco problemas identificados (P1–P5) y donde se destruye la mayor parte del valor (eslabones 2–7 de la cadena de valor).

| **Campo de la ficha** | **Contenido**                                                                                                                    |
|-----------------------|----------------------------------------------------------------------------------------------------------------------------------|
| Nombre del proceso    | Contratación y ejecución de un envío de carga interprovincial                                                                    |
| Objetivo              | Trasladar mercadería de la PYME desde el origen hasta el cliente/destino, en la fecha comprometida y al menor costo posible      |
| Dueño del proceso     | Gerente–propietario de la PYME (rol implícito; no existe función logística formal)                                               |
| Actores               | PYME (gerente, almacén, ventas) · transportista/empresa de transporte · conductor · intermediario (frecuente) · cliente receptor |
| Entradas              | Pedido del cliente o necesidad de reposición · mercadería lista · datos del destino                                              |
| Salidas               | Mercadería entregada · pago del flete · (deseable pero hoy ausente: evidencia de entrega y registro del gasto)                   |
| Frecuencia            | Semanal (perfil arquetipo: envíos de 0.5–5 toneladas)                                                                            |
| Sistemas de soporte   | WhatsApp, llamadas, Excel/cuaderno, efectivo/transferencia (inventario AS-IS, sección 1.3.1)                                     |

## **4.2 Proceso Actual — AS-IS (CE0132)**

### **4.2.1 Descripción narrativa**

El proceso actual inicia cuando el encargado de almacén informa al gerente que hay mercadería lista para despachar. El gerente interrumpe sus actividades y comienza la búsqueda de transporte: llama o escribe por WhatsApp a entre cinco y diez transportistas de su lista de contactos personales, describiendo verbalmente la carga, el destino y la fecha. Algunos no responden; otros no tienen capacidad disponible; los que responden cotizan verbalmente un precio que el gerente no puede contrastar con ninguna referencia de mercado.

Con frecuencia interviene un intermediario (broker informal) que “consigue el camión” a cambio de un margen que la PYME no conoce con precisión. La negociación se resuelve por teléfono, sin registro: el precio final depende de la urgencia de la PYME y de la percepción de escasez del momento. Cerrado el acuerdo verbal, el almacén coordina la hora de recojo por WhatsApp.

Durante el traslado no existe visibilidad: si el cliente pregunta por su pedido, el área de ventas “llama al chofer”. La entrega se realiza sin evidencia formal —sin fotografía, sin firma digital, a lo sumo un mensaje de “ya entregué”. El pago se hace en efectivo o por transferencia, muchas veces adelantado en parte, sin vínculo con la conformidad de la entrega. Finalmente, el gasto se anota (a veces) en un Excel o cuaderno, sin desglose que permita análisis posterior. Si surge una disputa —carga dañada, retraso, cobro distinto al pactado— no hay registro que permita resolverla: es palabra contra palabra.

### **4.2.2 Modelo BPMN AS-IS (especificación textual)**

El diagrama BPMN AS-IS se estructura en cuatro carriles (pools/lanes). Especificación para su elaboración en herramienta editable (Anexo B):

<table>
<colgroup>
<col style="width: 24%" />
<col style="width: 75%" />
</colgroup>
<thead>
<tr class="header">
<th><strong>Carril</strong></th>
<th><strong>Elementos del flujo</strong></th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>PYME — Gerente</td>
<td><p>1. Evento de inicio: mercadería lista para despacho</p>
<p>2. Tarea: contactar transportistas (5–10 llamadas/mensajes) — bucle</p>
<p>3. Compuerta exclusiva: ¿alguna respuesta con capacidad? (No → volver a 2 / recurrir a intermediario)</p>
<p>4. Tarea: negociar precio verbalmente (sin referencia)</p>
<p>5. Compuerta: ¿acuerdo? (No → volver a 2)</p>
<p>6. Tarea: confirmar acuerdo verbal</p></td>
</tr>
<tr class="even">
<td>Intermediario (opcional)</td>
<td><p>7. Tarea: buscar camión disponible en su red</p>
<p>8. Tarea: agregar margen y cotizar a la PYME</p></td>
</tr>
<tr class="odd">
<td>PYME — Almacén</td>
<td><p>9. Tarea: coordinar hora de recojo por WhatsApp</p>
<p>10. Tarea: entregar mercadería al conductor (sin acta formal)</p></td>
</tr>
<tr class="even">
<td>Transportista / Conductor</td>
<td><p>11. Tarea: recoger la carga</p>
<p>12. Tarea: trasladar (sin visibilidad para la PYME) — evento intermedio: consultas del cliente atendidas “llamando al chofer”</p>
<p>13. Tarea: entregar sin evidencia formal</p>
<p>14. Tarea: cobrar (efectivo/transferencia)</p></td>
</tr>
<tr class="odd">
<td>PYME — Administración</td>
<td><p>15. Tarea: registrar gasto en Excel/cuaderno (a veces)</p>
<p>16. Evento de fin: envío cerrado sin evidencia · Camino de excepción: disputa sin registro → fin insatisfactorio</p></td>
</tr>
</tbody>
</table>

<img src="media/image3.png" style="width:6.4625in;height:2.47708in" />

### **4.2.3 Indicadores actuales (línea base)**

| **KPI del proceso**                                | **Valor AS-IS (línea base)**                             | **Fuente / naturaleza**                            |
|----------------------------------------------------|----------------------------------------------------------|----------------------------------------------------|
| Recorridos en vacío (lado transportista)           | 40–45% en la región                                      | Farromeque Quiroz (2017) — verificada              |
| Costo logístico sobre ventas (lado PYME)           | 21.1% (microempresa) vs. 15.7% (gran empresa)            | ComexPerú (2022) — verificada                      |
| Tiempo de contratación de un flete                 | Horas a días (llamadas múltiples y espera de respuestas) | Estimación del equipo sobre el proceso narrado     |
| Contactos necesarios por envío                     | 5–10 llamadas/mensajes                                   | Estimación del equipo                              |
| Envíos con precio de referencia previo             | 0%                                                       | Por definición del AS-IS (no existe la referencia) |
| Envíos con evidencia formal de entrega             | 0%                                                       | Por definición del AS-IS                           |
| Envíos con seguimiento en tiempo real              | 0%                                                       | Por definición del AS-IS                           |
| Disputas con posibilidad de resolución documentada | 0%                                                       | Por definición del AS-IS                           |

### **4.2.4 Problemas detectados en el flujo**

- La búsqueda secuencial por contactos (tareas 2–3) consume horas del gerente y limita la oferta a su red personal — manifestación directa de P1 y P5.

- La negociación sin referencia (tarea 4) institucionaliza la opacidad de precios — P2.

- La intervención del intermediario (tareas 7–8) añade margen sin añadir información ni garantías — P2/P5.

- El traslado sin visibilidad (tarea 12) y la entrega sin evidencia (tarea 13) generan el déficit de confianza — P4.

- El transportista regresa vacío tras la tarea 13 porque el proceso no contempla carga de retorno — P3.

- El registro opcional (tarea 15) impide la analítica y la mejora continua — P1.

## **4.3 Proceso Propuesto — TO-BE (CE0133)**

### **4.3.1 Descripción narrativa del rediseño**

En el proceso rediseñado, la PYME publica la solicitud de carga en la plataforma en un formulario de dos minutos; el sistema calcula automáticamente un precio de referencia basado en la distancia real de la ruta y el histórico del corredor, y abre una subasta con ventana de tiempo definida. Los transportistas verificados cuyo perfil es compatible reciben la notificación y ofertan; la PYME compara ofertas viendo simultáneamente precio y reputación verificada, puede contraofertar por el canal moderado y acepta la mejor combinación precio–confianza, generándose el contrato digital.

Durante la ejecución, el conductor gestiona su ruta desde la aplicación móvil: cada parada registra estado, y la entrega se confirma con fotografía y firma digital del receptor —incluso sin conexión, con sincronización posterior. La PYME y su cliente ven el avance en tiempo real sin llamar a nadie. Al confirmarse la entrega, se habilita la calificación mutua que alimenta la reputación compuesta de ambos actores. Terminada la ruta, el sistema notifica al transportista las cargas de retorno disponibles cerca de su destino, atacando directamente el recorrido en vacío. Todo queda registrado: precios, tiempos, evidencias y calificaciones alimentan la analítica de la PYME y el precio de referencia del corredor.

### **4.3.2 Modelo BPMN TO-BE (especificación textual)**

<table>
<colgroup>
<col style="width: 24%" />
<col style="width: 75%" />
</colgroup>
<thead>
<tr class="header">
<th><strong>Carril</strong></th>
<th><strong>Elementos del flujo</strong></th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>PYME</td>
<td><p>1. Inicio: mercadería lista</p>
<p>2. Tarea de usuario: publicar solicitud (formulario guiado)</p>
<p>3. Tarea de servicio (automática): cálculo del precio de referencia</p>
<p>4. Evento intermedio temporizador: ventana de subasta</p>
<p>5. Tarea de usuario: comparar ofertas (precio + reputación) y aceptar/contraofertar</p>
<p>6. Evento: contrato digital generado</p></td>
</tr>
<tr class="even">
<td>Plataforma LOGYX</td>
<td><p>7. Tarea de servicio: notificar a transportistas compatibles (matching)</p>
<p>8. Tarea de servicio: cerrar subasta automáticamente (tiempo o máximo de ofertas)</p>
<p>9. Tarea de servicio: moderar mensajes de negociación</p>
<p>10. Tarea de servicio: registrar estados, evidencias y calificaciones</p>
<p>11. Tarea de servicio: detectar y notificar cargas de retorno al finalizar la ruta</p></td>
</tr>
<tr class="odd">
<td>Transportista</td>
<td><p>12. Tarea de usuario: revisar solicitud rankeada y ofertar</p>
<p>13. Tarea de usuario: asignar vehículo y conductor</p>
<p>14. Tarea de usuario: aceptar carga de retorno sugerida (opcional)</p></td>
</tr>
<tr class="even">
<td>Conductor (app)</td>
<td><p>15. Tarea: iniciar ruta asignada</p>
<p>16. Subproceso por parada: llegar → entregar → foto + firma → estado actualizado</p>
<p>17. Evento de fin: última parada confirmada</p></td>
</tr>
</tbody>
</table>

<img src="media/image4.png" style="width:6.4625in;height:2.38264in" />

### **4.3.3 Nuevos indicadores del proceso**

- Tiempo publicación → primera oferta y publicación → aceptación (meta: \< 60 minutos).

- Porcentaje de solicitudes con al menos una oferta en 24 horas (meta SLA: ≥ 60% desde el mes 2).

- Porcentaje de envíos con evidencia completa de entrega (meta: 100% en plataforma).

- Tasa de aceptación de cargas de retorno sugeridas (indicador del ataque a P3).

- Desviación del precio aceptado respecto al precio de referencia (salud del mercado interno).

## **4.4 Propuesta de Automatización mediante TIC (CE0134)**

Las automatizaciones del TO-BE y su mecanismo, referenciando los módulos de la solución (cuyo diseño técnico se desarrolla en la documentación técnica de la solución (fuera del alcance de esta ronda de evaluación)):

| **Automatización**                  | **Qué reemplaza del AS-IS**                          | **Mecanismo (módulo)**                                                                          |
|-------------------------------------|------------------------------------------------------|-------------------------------------------------------------------------------------------------|
| Cálculo del precio de referencia    | Negociación a ciegas (tarea AS-IS 4)                 | Motor de costos: distancia real por carretera + histórico del corredor + variables de la carga  |
| Difusión de la solicitud (matching) | 5–10 llamadas manuales del gerente (tarea 2)         | Notificación automática a transportistas verificados con perfil de ruta y capacidad compatibles |
| Cierre de subasta                   | Presión y arbitrariedad de la negociación telefónica | Cierre automático por tiempo o número máximo de ofertas; reglas iguales para todos              |
| Moderación de la negociación        | Acuerdos verbales sin registro (tareas 4–6)          | Chat con registro íntegro y detección de intentos de contacto fuera de plataforma               |
| Trazabilidad y evidencia            | “Llamar al chofer” y entrega sin acta (tareas 12–13) | Estados por parada + captura de foto y firma en la app del conductor (funciona sin conexión)    |
| Detección de carga de retorno       | Retorno en vacío por defecto (P3)                    | Búsqueda automática de cargas abiertas cercanas al destino al confirmar la última entrega       |
| Registro y analítica                | Excel/cuaderno opcional (tarea 15)                   | Persistencia automática de precios, tiempos, evidencias y calificaciones; tablero para la PYME  |

## **4.5 Indicadores de Desempeño y Análisis Comparativo (CE0135)**

| **Dimensión** | **KPI**                                     | **AS-IS (línea base)**      | **TO-BE (meta)**                                                  | **Mejora esperada**                            |
|---------------|---------------------------------------------|-----------------------------|-------------------------------------------------------------------|------------------------------------------------|
| Tiempo        | Tiempo de contratación del flete            | Horas a días                | \< 60 minutos                                                     | Reducción de más del 90% del tiempo de gestión |
| Tiempo        | Contactos manuales por envío                | 5–10 llamadas               | 1 publicación                                                     | Eliminación de la búsqueda secuencial          |
| Costo         | Costo logístico sobre ventas (PYME)         | 21.1% (ComexPerú, 2022)     | Convergencia progresiva hacia el nivel de la gran empresa (15.7%) | Hasta ~5 puntos porcentuales sobre ventas      |
| Costo         | Recorridos en vacío (transportista)         | 40–45% regional (CAF, 2017) | Reducción medible en la flota activa vía retornos y consolidación | Ingreso adicional por km ya recorrido          |
| Calidad       | Envíos con evidencia formal de entrega      | 0%                          | 100% en plataforma                                                | Disputas resolubles con registro               |
| Calidad       | Visibilidad del envío para la PYME/cliente  | Ninguna (llamar al chofer)  | Tiempo real por parada                                            | Confianza y servicio al cliente final          |
| Calidad       | Precio contratado con referencia de mercado | 0%                          | 100% de las solicitudes                                           | Fin de la opacidad (P2)                        |

El comparativo evidencia mejoras en las tres dimensiones exigidas (tiempo, costo y calidad), con dos anclas cuantitativas verificadas por fuentes externas (brecha de costos y recorridos en vacío) y el resto de indicadores medibles desde el primer día de operación de la plataforma, dado que el TO-BE registra sus propias métricas de forma nativa. La línea base declarada aquí es el contrato de medición contra el cual se evaluará el impacto real del piloto.

## **4.6 Complemento Metodológico: Toolkit Lean Six Sigma aplicado a LOGYX**

Como refuerzo metodológico de la gestión de procesos, el proyecto de mejora AS-IS/TO-BE de LOGYX se desarrolla adicionalmente con el conjunto completo de herramientas de Lean Six Sigma utilizado por el equipo en el curso de Gestión de Procesos (ciclo 8): 5W2H, diagrama de Swimlane, diagrama de Ishikawa, árboles causales por categoría, diagrama de Pareto, sesión de brainstorming, plan de acción y plan de control. A diferencia de una síntesis tabular, cada herramienta se desarrolla aquí en su propio apartado, con introducción metodológica, desarrollo aplicado al caso real de LOGYX, el diagrama o espacio correspondiente, y su interpretación.

### **4.6.1 Herramienta 5W2H**

Introducción metodológica: el 5W2H es un instrumento de definición de problema que responde siete preguntas estructuradas (Qué, Dónde, Cuándo, Quién, Por qué, Cómo, Cuánto) para delimitar con precisión el alcance de un proyecto de mejora antes de diseñar la solución. Se utiliza típicamente en la fase de Antecedentes del formato A3 o en la fase Define de DMAIC.

| **Elemento**      | **Respuesta aplicada a LOGYX**                                                                                                                                                                                                                                                                                                                                                                                  |
|-------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| What (Qué)        | Dificultad estructural de las PYMEs del corredor Lima–Sierra Sur para contratar transporte de carga a un precio justo y con trazabilidad, debido a la coordinación informal (WhatsApp, llamadas, Excel) y a la ausencia de un sistema de información logística compartido entre los actores del ecosistema.                                                                                                     |
| Where (Dónde)     | En el corredor logístico Lima–Arequipa–Juliaca–Puno–Cusco, en la interacción entre PYMEs manufactureras/comerciales, transportistas independientes y empresas de transporte medianas.                                                                                                                                                                                                                           |
| When (Cuándo)     | El problema se manifiesta en cada operación de envío, de forma recurrente y semanal (frecuencia típica de la PYME arquetipo), agravándose en fechas de alta demanda cuando la percepción de escasez de transportistas eleva las tarifas de forma arbitraria.                                                                                                                                                    |
| Who (Quién)       | Afecta directamente a gerentes–propietarios de PYMEs (que negocian sin información de mercado), a transportistas independientes (que regresan con el vehículo vacío en 40–45% de sus rutas) y, en menor medida, a los clientes finales de las PYMEs, que sufren retrasos y falta de visibilidad de sus pedidos.                                                                                                 |
| Why (Por qué)     | Es necesario abordarlo porque la brecha de costos logísticos penaliza desproporcionadamente a la empresa de menor escala (21.1% de las ventas en la microempresa vs. 15.7% en la gran empresa, ComexPerú 2022), erosionando la competitividad de cientos de PYMEs del corredor y perpetuando la informalidad del sector transporte.                                                                             |
| How (Cómo)        | El problema se manifiesta mediante búsqueda telefónica de transporte (5–10 llamadas por envío), negociación verbal sin referencia de precios, entrega sin evidencia formal y registro manual e incompleto del gasto logístico. Contribuyen a que persista: la atomización de la oferta (“hombre-camión”), la ausencia de mecanismos de consolidación de carga, y la falta de verificación legal de los actores. |
| How Much (Cuánto) | El costo del problema equivale, para una PYME arquetipo, a un sobrecosto logístico de hasta 5 puntos porcentuales sobre sus ventas frente a lo que pagaría una gran empresa (USD 150–1,200 mensuales según el Entregable 2, sección 2.5), además del costo de oportunidad de las horas-hombre del gerente dedicadas a la búsqueda telefónica de transporte en cada envío.                                       |

> *Resumen 5W2H: el problema de fragmentación operativa en la contratación de transporte de carga en el corredor Lima–Sierra Sur afecta a PYMEs y transportistas debido a la coordinación informal sin sistema de información compartido, con un impacto de hasta 5 puntos porcentuales sobre ventas en sobrecosto logístico, y debe abordarse porque erosiona la competitividad de la pequeña empresa y perpetúa la informalidad del sector, ya que se manifiesta en cada envío semanal, lo que requiere que el ecosistema adopte una plataforma digital colaborativa de logística para resolverlo.*

### **4.6.2 Diagrama de Swimlane (análisis VA/NVA/NNVA)**

Introducción metodológica: el diagrama de Swimlane (carriles funcionales) descompone el proceso en pasos secuenciales, asignándole a cada uno un actor responsable, un tiempo promedio y una clasificación de valor: VA (actividad de Valor Agregado, que el cliente pagaría por ella), NVA (actividad de No Valor Agregado, desperdicio puro) y NNVA (No Valor Agregado pero Necesario, como controles o registros exigidos aunque no agreguen valor directo). Este análisis cuantifica qué proporción del tiempo total del proceso es realmente productiva.

| **Paso del proceso AS-IS**                               | **Actor**             | **Tiempo promedio** | **Clasificación** |
|----------------------------------------------------------|-----------------------|---------------------|-------------------|
| 1\. Contactar transportistas (5–10 llamadas)             | PYME – Gerente        | 3.0 h               | NNVA              |
| 2\. Negociar precio verbalmente                          | PYME – Gerente        | 1.0 h               | NNVA              |
| 3\. Confirmar acuerdo verbal                             | PYME – Gerente        | 0.2 h               | NNVA              |
| 4\. Buscar camión disponible (si hay intermediario)      | Intermediario         | 4.0 h               | NVA               |
| 5\. Agregar margen y cotizar                             | Intermediario         | 0.5 h               | NVA               |
| 6\. Coordinar hora de recojo por WhatsApp                | PYME – Almacén        | 0.5 h               | NNVA              |
| 7\. Entregar mercadería sin acta formal                  | PYME – Almacén        | 0.3 h               | NNVA              |
| 8\. Recoger la carga                                     | Transportista         | 0.5 h               | VA                |
| 9\. Trasladar la carga (tramo Lima–Juliaca, referencial) | Transportista         | 12.0 h              | VA                |
| 10\. Entregar sin evidencia formal                       | Transportista         | 0.3 h               | NNVA              |
| 11\. Cobrar (efectivo/transferencia)                     | Transportista         | 0.5 h               | NNVA              |
| 12\. Registrar gasto en Excel (a veces)                  | PYME – Administración | 0.3 h               | NNVA              |

| **Métrica del Swimlane**                                                | **Valor**  |
|-------------------------------------------------------------------------|------------|
| Tiempo total del proceso (Lead Time)                                    | 23.1 horas |
| Tiempo de Valor Agregado (VA): pasos 8 y 9                              | 12.5 horas |
| Tiempo de No Valor Agregado (NVA): pasos 4 y 5                          | 4.5 horas  |
| Tiempo NNVA (necesario pero sin valor): pasos 1, 2, 3, 6, 7, 10, 11, 12 | 6.1 horas  |
| % de tiempo de Valor Agregado sobre el total                            | 54.1%      |

*Supuesto declarado del equipo: los tiempos del Swimlane son estimaciones del equipo sobre el proceso narrado en 3.2.1, referenciales para dimensionar el desperdicio, no mediciones cronometradas en campo. El diagrama visual (formas de proceso, decisión y conectores, siguiendo la simbología estándar de Swimlane) se elaborará en Bizagi Modeler a partir de esta tabla; el espacio para insertar la captura de pantalla del diagrama de Bizagi se marca a continuación.*

**\[COMPLETAR POR EL EQUIPO — insertar aquí la captura de pantalla del diagrama de Swimlane elaborado en Bizagi Modeler, mostrando los 4 carriles (PYME-Gerente, Intermediario, PYME-Almacén/Transportista, PYME-Administración) con los 12 pasos de la tabla anterior y su clasificación VA/NVA/NNVA codificada por color.\]**

Interpretación: solo el 54.1% del tiempo total del proceso es de Valor Agregado, y ese porcentaje está dominado por el tiempo de traslado físico (que no puede eliminarse). De los pasos controlables por diseño de proceso, el 19.5% del tiempo corresponde a NVA puro (búsqueda de camión e intermediación, pasos 4 y 5) —exactamente el tramo que LOGYX elimina mediante el marketplace digital—, mientras que el 26.4% restante (NNVA) corresponde a coordinación y registro que LOGYX no elimina pero sí automatiza y acelera (de 6.1 horas acumuladas a minutos).

### **4.6.3 Diagrama de Ishikawa (causa–efecto): desarrollo ampliado**

Introducción metodológica: el diagrama de Ishikawa (espina de pescado) organiza las causas potenciales de un efecto no deseado en categorías estándar, facilitando un análisis exhaustivo antes de saltar a soluciones. La versión resumida de este diagrama ya se presentó en el Entregable 1 (sección 1.4.2) como insumo del diagnóstico; aquí se retoma como punto de partida formal del proyecto de mejora de procesos y se amplía con el detalle de por qué cada espina contribuye al efecto central.

> *Efecto central del diagrama: “Sobrecosto e imprevisibilidad logística de la PYME del corredor Lima–Sierra Sur”.*

| **Espina (categoría)**  | **Causas y su contribución al efecto**                                                                                                                                                                                                                                                                                                                                              |
|-------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Método (proceso)        | La ausencia de un proceso logístico definido obliga a gestionar cada envío de forma reactiva: el gerente reinicia la búsqueda de transporte desde cero en cada operación (5–10 llamadas), sin aprovechar acuerdos previos ni consolidar envíos propios. Esto multiplica el tiempo de gestión y elimina cualquier posibilidad de planificación anticipada de rutas o volúmenes.      |
| Información (datos)     | Sin referencia de precios por ruta, cada negociación parte de cero y el precio final depende de la urgencia percibida, no del costo real del servicio. La ausencia de historial de desempeño de transportistas impide discriminar entre un proveedor confiable y uno riesgoso, y el registro manual del gasto impide cualquier análisis de tendencia o negociación basada en datos. |
| Tecnología              | Las herramientas usadas (WhatsApp, llamadas, Excel) no fueron diseñadas para gestión logística: no permiten búsqueda estructurada, no generan estados de envío, y no capturan evidencia digital de entrega. La cero trazabilidad resultante es la causa tecnológica directa del déficit de confianza (P4) y de la imposibilidad de auditar acuerdos verbales.                       |
| Personas (organización) | La función logística no existe como responsabilidad formal: está dispersa entre el gerente (negociación), el almacén (despacho) y ventas (seguimiento al cliente), sin un dueño de proceso. Esto genera dependencia crítica de la memoria y las relaciones personales del gerente, un riesgo operativo si esa persona no está disponible.                                           |
| Mercado (estructura)    | La oferta de transporte está atómicamente fragmentada (transportistas de 1 a 5 unidades) sin mecanismo de agregación de demanda ni de consolidación de cargas compatibles. Los intermediarios informales capturan margen sin aportar tecnología, y la demanda de las PYMEs, también fragmentada, carece de poder de compra colectivo frente a esta oferta dispersa.                 |
| Entorno                 | La infraestructura vial del corredor es estructuralmente vulnerable (puntaje de infraestructura 2.5/5 en el LPI 2023), lo que introduce variabilidad e imprevisibilidad en los tiempos de tránsito, mientras que la débil fiscalización del sector transporte perpetúa la informalidad de los actores (transportistas sin verificación de licencias ni SOAT vigente).               |

<img src="media/image5.png" style="width:4.84688in;height:3.21986in" />

*Figura 1. Diagrama de Ishikawa — causas del sobrecosto e imprevisibilidad logística de LOGYX, elaborado por el equipo a partir del análisis de la sección 4.6.3.*

Interpretación: de las seis categorías, tres (Método, Información, Tecnología) son directamente resolubles mediante una solución TIC —son, de hecho, exactamente los tres pilares funcionales de LOGYX (proceso de subasta estructurado, motor de precios de referencia, y plataforma digital con trazabilidad). La categoría Personas se mitiga indirectamente al externalizar la coordinación del conocimiento tácito del gerente hacia un sistema. Las categorías Mercado y Entorno son estructurales del sector y no se resuelven por completo con tecnología, pero LOGYX actúa sobre Mercado mediante el mecanismo de consolidación de demanda y oferta.

### **4.6.4 Árboles Causales por Categoría**

Introducción metodológica: mientras que el Ishikawa identifica categorías amplias de causas, el árbol causal profundiza cada categoría crítica en niveles sucesivos de “por qué”, hasta llegar a la causa raíz accionable. Se desarrollan tres árboles causales, uno por cada categoría considerada de mayor peso para el diseño de la solución: Personas, Planta (adaptado a Infraestructura Tecnológica, dado que el ecosistema logístico de PYMEs no opera una planta física propia) y Procedimiento.

**4.6.4.1 Árbol Causal — Personas**

| **Nivel**                 | **Análisis “por qué”**                                                                                                                                                                     |
|---------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Problema                  | La función logística depende críticamente de una sola persona (el gerente–propietario).                                                                                                    |
| ¿Por qué? (1)             | Porque no existe un rol o área formalmente responsable de la logística en la PYME.                                                                                                         |
| ¿Por qué? (2)             | Porque la escala de la PYME (pequeña, familiar) no justifica históricamente contratar personal dedicado a logística.                                                                       |
| ¿Por qué? (3)             | Porque el conocimiento de “qué transportista es confiable” y “cuánto debería costar una ruta” ha sido siempre tácito, acumulado en la experiencia personal del gerente, nunca documentado. |
| ¿Por qué? (4, causa raíz) | Porque no ha existido, hasta ahora, una herramienta accesible que capture y comparta ese conocimiento tácito de forma estructurada entre cualquier PYME del corredor.                      |

Causa raíz: ausencia de un mecanismo que externalice y comparta el conocimiento tácito de confiabilidad y precios que hoy vive únicamente en la memoria del gerente. Solución asociada en LOGYX: el módulo de reputación verificable y el motor de precios de referencia convierten ese conocimiento tácito individual en un activo digital compartido por todo el ecosistema.

**4.6.4.2 Árbol Causal — Planta (Infraestructura Tecnológica)**

*Supuesto declarado del equipo: se adapta el término “Planta” (instalaciones físicas de producción) a “Infraestructura Tecnológica”, dado que el ecosistema PYME-transportista no opera una planta industrial propia; el equivalente funcional en un proceso de servicios logísticos es la infraestructura de sistemas que soporta la operación.*

| **Nivel**                 | **Análisis “por qué”**                                                                                                                                                                                            |
|---------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Problema                  | El ecosistema opera con cero infraestructura tecnológica diseñada para logística.                                                                                                                                 |
| ¿Por qué? (1)             | Porque las herramientas utilizadas (WhatsApp, Excel, llamadas) son genéricas, no específicas del dominio logístico.                                                                                               |
| ¿Por qué? (2)             | Porque históricamente no ha existido una plataforma digital especializada operando en el corredor Lima–Sierra Sur, accesible y asequible para PYMEs de esta escala.                                               |
| ¿Por qué? (3)             | Porque las soluciones enterprise existentes (SAP TM y similares) están diseñadas y valorizadas para grandes corporaciones, fuera del alcance económico y de complejidad operativa de una PYME.                    |
| ¿Por qué? (4, causa raíz) | Porque no existía, hasta el desarrollo de este proyecto, una solución diseñada específicamente para el perfil de costo, escala y nivel de informalidad de las PYMEs y transportistas independientes del corredor. |

Causa raíz: vacío de mercado —ausencia de una solución tecnológica diseñada para el segmento PYME/transportista independiente del corredor, a diferencia de las soluciones enterprise existentes. Solución asociada en LOGYX: arquitectura de monolito modular de bajo costo operativo (documentación técnica de la solución), con comisión escalonada 2%–7% accesible a la escala de la PYME.

**4.6.4.3 Árbol Causal — Procedimiento**

| **Nivel**                 | **Análisis “por qué”**                                                                                                                                                                                                                                  |
|---------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Problema                  | No existe un procedimiento estándar para contratar transporte; cada envío se negocia de forma única e informal.                                                                                                                                         |
| ¿Por qué? (1)             | Porque no hay un formato o proceso definido de solicitud, cotización y aceptación de transporte que las partes conozcan y sigan.                                                                                                                        |
| ¿Por qué? (2)             | Porque la relación PYME–transportista se ha construido tradicionalmente sobre la confianza personal bilateral, no sobre un protocolo replicable entre cualquier par de actores del ecosistema.                                                          |
| ¿Por qué? (3)             | Porque no existe una autoridad o estándar sectorial (gremial o tecnológico) que haya propuesto y difundido un procedimiento común de contratación para el segmento informal del transporte de carga.                                                    |
| ¿Por qué? (4, causa raíz) | Porque la fragmentación de la oferta (miles de transportistas independientes sin organización gremial fuerte) impide que emerja orgánicamente un estándar de procedimiento sin un actor articulador que lo proponga y lo haga cumplir tecnológicamente. |

Causa raíz: ausencia de un actor articulador que defina y haga cumplir un procedimiento estándar de contratación en un mercado estructuralmente fragmentado. Solución asociada en LOGYX: el flujo TO-BE (sección 4.3) impone un procedimiento único y obligatorio —publicación, subasta, aceptación, ejecución con evidencia— para todos los actores que operan en la plataforma, actuando LOGYX como el articulador tecnológico que el mercado no había producido por sí solo.

### **4.6.5 Diagrama de Pareto**

Introducción metodológica: el diagrama de Pareto ordena las causas identificadas de mayor a menor peso (frecuencia, costo o impacto asignado) para identificar la “regla 80/20”: el subconjunto minoritario de causas que concentra la mayor parte del efecto negativo, y que por tanto debe priorizarse en la solución.

*Supuesto declarado del equipo: los pesos de cada causa (escala 1 a 10) son una estimación del equipo basada en el análisis cualitativo del Ishikawa y los árboles causales precedentes, siguiendo el mismo criterio de juicio experto declarado para las matrices EFI/EFE del Entregable 1.*

| **\#** | **Causa (ordenada por peso)**                                               | **Peso (1–10)** | **% del total** | **% acumulado** |
|--------|-----------------------------------------------------------------------------|-----------------|-----------------|-----------------|
| 1      | Ausencia de sistema de información logística del dominio                    | 10              | 11.5%           | 11.5%           |
| 2      | Búsqueda de transporte por contactos personales, sin acceso a oferta amplia | 9               | 10.3%           | 21.8%           |
| 3      | Sin referencia de precios de mercado por ruta                               | 9               | 10.3%           | 32.2%           |
| 4      | Sin historial de desempeño de transportistas verificable                    | 8               | 9.2%            | 41.4%           |
| 5      | Función logística dispersa entre roles, sin responsable único               | 8               | 9.2%            | 50.6%           |
| 6      | Cero trazabilidad: sin GPS ni evidencia digital de entrega                  | 7               | 8.0%            | 58.6%           |
| 7      | Oferta atomizada sin mecanismo de agregación (“hombre-camión”)              | 7               | 8.0%            | 66.7%           |
| 8      | Intermediarios informales sin tecnología que capturan margen                | 6               | 6.9%            | 73.6%           |
| 9      | Registro manual e incompleto del gasto logístico                            | 6               | 6.9%            | 80.5%           |
| 10     | Dependencia de la memoria y relaciones personales del gerente               | 5               | 5.7%            | 86.2%           |
| 11     | Demanda fragmentada sin poder de compra colectivo                           | 5               | 5.7%            | 92.0%           |
| 12     | Infraestructura vial vulnerable del corredor                                | 4               | 4.6%            | 96.6%           |
| 13     | Informalidad y débil fiscalización del sector transporte                    | 3               | 3.4%            | 100.0%          |

<img src="media/image6.png" style="width:4.84688in;height:2.75295in" />

*Figura 2. Diagrama de Pareto — causas raíz del problema logístico de LOGYX ordenadas por peso, con línea de porcentaje acumulado y corte de la regla 80/20.*

Interpretación (regla 80/20): las primeras 9 causas (de 13 totales) concentran el 80.5% del peso acumulado. Estas 9 causas —en orden— corresponden mayoritariamente a las categorías Tecnología, Método e Información del Ishikawa, confirmando cuantitativamente que la solución debe priorizar: (1) un sistema de información logística del dominio, (2) un mecanismo de matching que reemplace la búsqueda manual, (3) un motor de precios de referencia, (4) un sistema de reputación verificable, y (5) trazabilidad digital de extremo a extremo. Estas cinco prioridades coinciden exactamente con los cinco Factores Críticos de Éxito definidos en el Entregable 1 (sección 1.2.8), validando la coherencia del diagnóstico con el análisis cuantitativo de causas.

### **4.6.6 Sesión de Brainstorming**

Introducción metodológica: la sesión de brainstorming genera de forma divergente el mayor número posible de ideas de solución frente a las causas raíz priorizadas por el Pareto, antes de converger en el plan de acción. Las ideas generadas por el equipo se agrupan por categoría de intervención.

<table>
<colgroup>
<col style="width: 21%" />
<col style="width: 78%" />
</colgroup>
<thead>
<tr class="header">
<th><strong>Categoría</strong></th>
<th><strong>Ideas generadas</strong></th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>Tecnología / Producto</td>
<td><p>• Plataforma marketplace con publicación de solicitudes y subasta inversa de transportistas</p>
<p>• Motor de cálculo de precio de referencia con distancia real por carretera (API de ruteo)</p>
<p>• Aplicación móvil del conductor con captura de evidencia (foto + firma) funcionando sin conexión</p>
<p>• Sistema de reputación compuesta (verificable, no manipulable) por transportista y por PYME</p></td>
</tr>
<tr class="even">
<td>Proceso / Operación</td>
<td><p>• Verificación legal obligatoria de RUC, licencia MTC y SOAT antes de poder ofertar en la plataforma</p>
<p>• Chat de negociación moderado que bloquea el intercambio de contactos fuera de plataforma</p>
<p>• Detección automática de cargas de retorno cercanas al destino final de un transportista</p>
<p>• Consolidación de cargas compatibles en una misma ruta (Smart Load Planner)</p></td>
</tr>
<tr class="odd">
<td>Alianzas / Arranque</td>
<td><p>• Alianza con asociaciones de transportistas de Juliaca y Puno para onboarding masivo de oferta</p>
<p>• Garantía de SLA de 24 horas con asignación manual del operador si no llegan ofertas</p>
<p>• Programa de acceso gratuito los primeros 3 meses para romper la inercia de adopción</p></td>
</tr>
<tr class="even">
<td>Comunicación / Adopción</td>
<td><p>• Onboarding asistido en sitio o por videollamada para la primera publicación de cada PYME</p>
<p>• Diseño de interfaz que replique la simplicidad de WhatsApp (máximo 3 pasos por pantalla crítica)</p>
<p>• Capacitación por rol en video corto (PYME, transportista, conductor)</p></td>
</tr>
</tbody>
</table>

Interpretación: las ideas de la categoría Tecnología/Producto atacan directamente las 5 causas de mayor peso del Pareto (Rango 1–9); las de Proceso/Operación resuelven las causas de Mercado del Ishikawa (oferta atomizada, intermediarios); y las de Alianzas/Arranque y Comunicación/Adopción existen específicamente para mitigar el riesgo estratégico crítico RE1/RE2 (resistencia al cambio y arranque en frío) identificado en el Entregable 1, sección 1.6. Estas ideas convergen en el plan de acción de la siguiente sección.

### **4.6.7 Plan de Acción**

Introducción metodológica: el plan de acción traduce las ideas priorizadas del brainstorming en compromisos concretos y verificables: qué se hará, quién es el responsable, cuándo se completará y cómo se logrará, alineado con el cronograma de sprints del Entregable 2.

| **\#** | **Oportunidad (¿por qué?)**                                                            | **Acción (¿qué?)**                                                                                           | **Responsable**                      | **Fecha objetivo**              |
|--------|----------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------|--------------------------------------|---------------------------------|
| 1      | Eliminar la búsqueda manual de transporte, causa raíz de mayor peso del Pareto (11.5%) | Desarrollar el módulo de marketplace y subasta inversa con matching automático de transportistas             | Equipo de desarrollo (Sprints 2–3)   | Semana 6 (fin Sprint 3)         |
| 2      | Eliminar la opacidad de precios, causa \#3 del Pareto (10.3%)                          | Implementar el motor de precios de referencia con distancia real por carretera                               | Equipo de desarrollo (Sprint 2)      | Semana 4                        |
| 3      | Resolver la ausencia de historial verificable, causa \#4 (9.2%)                        | Implementar el sistema de reputación compuesta y verificación legal de actores                               | Equipo de desarrollo (Sprints 1 y 6) | Semana 12 (fin Sprint 6)        |
| 4      | Resolver la cero trazabilidad, causa \#6 (8.0%)                                        | Implementar tracking multi-parada y app del conductor con evidencia fotográfica y firma                      | Equipo de desarrollo (Sprint 5)      | Semana 10                       |
| 5      | Atacar la oferta atomizada y el retorno en vacío, causas \#7–8 (14.9% acumulado)       | Implementar el módulo de consolidación y cargas de retorno (v1)                                              | Equipo de desarrollo (Sprint 7)      | Semana 14                       |
| 6      | Mitigar el riesgo de arranque en frío (RE2)                                            | Ejecutar alianza con asociaciones de transportistas de Juliaca/Puno y activar oferta gratuita 3 meses        | Líder de proyecto + equipo comercial | Semana 4 de operación (Fase F1) |
| 7      | Mitigar la resistencia cultural al cambio (RE1)                                        | Diseñar onboarding asistido y capacitación por rol en video corto                                            | Equipo de producto                   | Semana 8 de operación (Fase F2) |
| 8      | Verificar el cierre de la brecha de costos prometida                                   | Medir el ahorro real por PYME activa desde el primer mes de piloto y reportarlo en el tablero de indicadores | Líder de proyecto + torre de control | Continuo desde semana 12        |

El plan de acción se articula directamente con el cronograma de 8 sprints (Entregable 2, sección 2.3) y con las fases de implementación de la solución técnica, evitando duplicar planificación: cada acción aquí referencia el sprint o fase donde se ejecuta.

### **4.6.8 Plan de Control y Seguimiento**

Introducción metodológica: el plan de control define cómo se sostendrá la mejora una vez implementada, especificando qué parámetro crítico se mide, el límite aceptable, el método y lugar de medición, y la frecuencia de revisión —evitando que el proceso regrese a su estado AS-IS una vez terminado el proyecto.

| **Paso controlado**                | **Parámetro crítico**                            | **Entrada/Salida** | **Límite / requerimiento**                                         | **Método de medición**                                               | **Frecuencia**                             |
|------------------------------------|--------------------------------------------------|--------------------|--------------------------------------------------------------------|----------------------------------------------------------------------|--------------------------------------------|
| Publicación y subasta de solicitud | Tiempo hasta la primera oferta                   | Salida             | ≥ 60% de solicitudes con oferta en 24h                             | Registro automático de timestamps en la plataforma                   | Diaria (tablero); mensual (reporte)        |
| Contratación del flete             | Tiempo total de contratación                     | Salida             | \< 60 minutos promedio                                             | Diferencia entre timestamp de publicación y de aceptación            | Mensual                                    |
| Ejecución y entrega                | % de envíos con evidencia completa               | Salida             | 100% de envíos vía plataforma                                      | Auditoría automática de registros con foto y firma                   | Semanal                                    |
| Verificación legal de actores      | % de transportistas verificados antes de ofertar | Entrada            | 100% (RUC + MTC + SOAT vigente)                                    | Validación automática contra padrón SUNAT/MTC al registro            | En tiempo real                             |
| Ahorro por PYME activa             | Brecha de costo cerrada (pp sobre ventas)        | Salida             | Tendencia hacia el cierre de ~5 pp                                 | Cálculo automático: precio de referencia histórico vs. precio pagado | Mensual, reportado por la torre de control |
| Retorno de transportistas          | % de rutas con carga de retorno aceptada         | Salida             | Tendencia creciente sobre la línea base regional (40–45% en vacío) | Registro de aceptación de sugerencias del módulo de retornos         | Mensual                                    |

Responsable del plan de control: la torre de control (Operador LOGYX), con revisión mensual consolidada por el líder de proyecto y presentación de resultados en la retrospectiva de cada fase de implementación de la solución técnica. Cualquier indicador que se desvíe del límite establecido durante dos periodos consecutivos activa una revisión de causa raíz siguiendo el mismo protocolo Ishikawa/árbol causal desarrollado en esta sección.

### **4.6.9 Síntesis en Formato A3**

Finalmente, el desarrollo completo de las ocho herramientas anteriores se consolida en el formato A3 estándar de Lean Six Sigma —una sola vista ejecutiva que resume el proyecto de mejora de principio a fin—, útil para la presentación ante el jurado:

| **Bloque A3**                            | **Contenido (referencia a la sección desarrollada)**                                         |
|------------------------------------------|----------------------------------------------------------------------------------------------|
| 1\. Antecedentes                         | 5W2H completo (sección 4.6.1)                                                                |
| 2\. Situación actual                     | Proceso AS-IS y Swimlane VA/NVA/NNVA (secciones 3.2 y 3.6.2)                                 |
| 3\. Objetivos SMART                      | OP1–OP6 (Entregable 2, sección 2.2)                                                          |
| 4\. Análisis de causa raíz               | Ishikawa ampliado + 3 árboles causales + Pareto (secciones 3.6.3–3.6.5)                      |
| 5\. Propuesta de mejora                  | Proceso TO-BE + brainstorming (secciones 4.3 y 4.6.6)                                        |
| 6\. Plan de trabajo y recursos           | Plan de acción (sección 4.6.7) + cronograma de sprints (Entregable 2)                        |
| 7\. Plan de control y seguimiento        | Plan de control (sección 4.6.8)                                                              |
| 8\. Resultados esperados (antes/después) | Comparativo AS-IS/TO-BE (sección 4.5)                                                        |
| 9\. Ahorros generados (estimado)         | USD 150–1,200 mensuales por PYME (Entregable 2, sección 2.5)                                 |
| 10\. Lecciones aprendidas                | A documentar durante la ejecución del piloto (plan de implementación de la solución técnica) |

*Supuesto declarado del equipo: la plantilla Excel completa de Lean Six Sigma (hojas A-3, 5W2H, Swim Lane, SMART, Ishikawa, árboles causales, Pareto, Brainstorming, Plan de Acción y Plan de Control), usada como base metódica de todo el desarrollo de esta sección, se adjunta como evidencia de respaldo en el Anexo D.*

# **Referencias**

Armstrong & Associates, Inc. (2025). U.S. Third-Party Logistics (3PL) Market Size Estimates: Domestic Transportation Management. https://www.3plogistics.com/

Arvis, J.-F., Ojala, L., Shepherd, B., Ulybina, D., & Wiederer, C. (2023). Connecting to compete 2023: Trade logistics in an uncertain global economy — The logistics performance index and its indicators. World Bank Group.

Farromeque Quiroz, R. (2017). PERLOG-LATAM: Perfil logístico de América Latina. Banco de Desarrollo de América Latina (CAF).

Ministerio de Comercio Exterior y Turismo & Grupo Banco Mundial. (2016). Análisis integral de la logística en el Perú: 5 cadenas de exportación. MINCETUR.

Ministerio de la Producción. (2025). Las Mipyme en cifras 2024. Oficina General de Evaluación de Impacto y Estudios Económicos, PRODUCE.

Sociedad de Comercio Exterior del Perú \[ComexPerú\]. (2022). Los costos logísticos de las empresas en el país son del 16% en promedio, pero un 21.1% para las microempresas. Semanario Económico.


---
