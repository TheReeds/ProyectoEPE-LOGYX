# E1 — Diagnóstico Organizacional y Alineamiento Estratégico
> Competencia: CE0111–CE0115 · Proyecto: LOGYX

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

