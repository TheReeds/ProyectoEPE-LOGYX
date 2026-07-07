# 1.2 Análisis Estratégico (CE0112)

## 1.2.1 Orientación estratégica de la PYME arquetipo

- **Misión:** producir y comercializar bienes de calidad para clientes del corredor Lima–Sierra Sur, entregando a tiempo y a costos competitivos.

- **Visión:** ser una empresa regional confiable, con operaciones logísticas predecibles y costos comparables a los de una empresa grande.

- **Valores:** cumplimiento, confianza, mejora continua y orientación al cliente.

- OE1 — Reducir el costo logístico como % de las ventas, cerrando la brecha de ~5 pp (ComexPerú, 2022).

- OE2 — Elevar la confiabilidad de las entregas con evidencia formal.

- OE3 — Ganar capacidad de planificación del gasto logístico.

- OE4 — Ampliar el alcance comercial a nuevas plazas del corredor.

## 1.2.2 Análisis Interno: Fortalezas y Debilidades (AMOFHIT)

El análisis interno se desarrolla siguiendo las seis áreas funcionales del modelo AMOFHIT (Administración, Marketing, Operaciones, Finanzas, Recursos Humanos, Sistemas de Información), aplicado a LOGYX como organización. Para cada área se desarrolla el fundamento de la fortaleza y de la debilidad identificadas, antes de presentar el resumen tabulado.

**Administración y gerencia (A).** La estructura organizacional plana de LOGYX —cuatro fundadores sin niveles jerárquicos intermedios— permite decisiones ágiles: una modificación de arquitectura o una reorientación de prioridad de sprint se decide en horas, no en semanas. Esta agilidad es una fortaleza real en la fase de MVP, donde la velocidad de iteración es crítica. Sin embargo, la contraparte de esa misma estructura es la dependencia total del criterio del equipo fundador: no existen mecanismos de gobierno corporativo, comités de decisión formales, ni checks and balances que prevengan sesgos de decisión concentrados en pocas personas —precisamente la brecha que el refuerzo de gobierno bajo COBIT 2019 (sección 1.7) busca cerrar.

**Marketing y clientes (M).** El equipo mantiene relación directa y cercana con los primeros usuarios objetivo del corredor (gremios de transportistas de Juliaca y Puno, PYMEs contactadas en la fase de validación exploratoria), lo que permite iterar el producto con retroalimentación real. La debilidad es estructural: sin track record de mercado ni marca reconocida, LOGYX no puede aún prometer plazos de adopción confiables a inversionistas ni a los propios usuarios — es una limitación común a cualquier startup pre-lanzamiento, pero que debe declararse explícitamente en el diagnóstico.

**Operaciones y logística (O).** El equipo posee conocimiento empírico acumulado de las rutas del corredor y de los patrones de comportamiento de transportistas informales, adquirido durante la fase de investigación del problema (Entregable 1, sección 1.1.4). Este conocimiento de dominio es una fortaleza que reduce el riesgo de diseñar una solución desalineada con la realidad operativa del sector. La debilidad es que ese conocimiento aún no se traduce en un proceso propio de operación de LOGYX como empresa: la gestión interna del equipo (sprints, entregas, coordinación) es todavía reactiva, sin la disciplina de proceso que la propia plataforma promete a sus usuarios.

**Finanzas (F).** El registro básico de gastos del proyecto existe (inversión de desarrollo, costos de infraestructura, Entregable 2, sección 2.6), lo cual es una base mínima de control financiero. La debilidad relevante es la ausencia de capital de inversión externo: el financiamiento del proyecto depende únicamente de recursos propios del equipo fundador, lo que limita la velocidad de escalamiento una vez validado el modelo y expone al proyecto a restricciones de flujo de caja si la fase de adopción (cold-start) se extiende más allá de lo proyectado.

**Recursos humanos (H).** El equipo reducido de tres integrantes permite comunicación rápida y alineación constante —no hay pérdida de información por capas jerárquicas. La debilidad directa de ese mismo tamaño es la limitación de capacidad: el equipo debe escalar simultáneamente el desarrollo técnico del producto y la operación comercial (ventas, onboarding, soporte) sin personal dedicado a cada frente, lo que genera riesgo de cuellos de botella durante el arranque en frío (Entregable 1, riesgo RE2).

**Sistemas de información y tecnología (T e I).** Esta es el área de mayor fortaleza relativa de LOGYX: el equipo diseñó desde el inicio una arquitectura modular escalable (monolito modular migrable a microservicios, documentación técnica de la solución) y domina el stack tecnológico completo (backend, frontend web, móvil, infraestructura cloud). La debilidad, coherente con la fase del proyecto, es que el producto aún está en versión MVP: funcionalidades avanzadas como el escrow de pagos o las cooperativas de volumen (roadmap H2–H3, Entregable 1 sección 1.5) no están implementadas todavía.

| **Área (AMOFHIT)**        | **Fortalezas**                                  | **Debilidades**                             |
|---------------------------|-------------------------------------------------|---------------------------------------------|
| Administración y gerencia | Decisiones ágiles por estructura plana          | Dependencia total del criterio del gerente  |
| Marketing y clientes      | Relación directa y cercana con el cliente       | Sin capacidad de prometer plazos confiables |
| Operaciones y logística   | Conocimiento empírico de rutas y transportistas | Negociación reactiva envío por envío        |
| Finanzas                  | Registro básico de gastos generales             | Costo logístico no desglosado ni comparado  |
| Recursos humanos          | Equipo pequeño, comunicación rápida             | Función logística dispersa sin responsable  |
| Sistemas de información   | Uso cotidiano de smartphone y WhatsApp          | Cero sistemas de información logística      |

## 1.2.3 Matriz EFI — Evaluación de Factores Internos

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

- **D5.** Equipo reducido (3 integrantes) para escalar simultáneamente desarrollo de producto y operación comercial.

- **D6.** Producto en fase de MVP: funcionalidades avanzadas (escrow de pagos, cooperativas de volumen) aún no implementadas.

<img src="media/image1.png" style="width:6.4625in;height:4.87639in" />Lectura: un puntaje ponderado entre 1.0 y 2.5 indica una posición interna débil; entre 2.5 y 4.0, una posición interna fuerte. El resultado de 2.50 refleja el balance real de una startup en etapa temprana: fortalezas técnicas y de producto sólidas, contrarrestadas por debilidades típicas de validación de mercado y capital, propias de esta fase del proyecto.

## 1.2.4 Análisis del Microentorno — Cinco Fuerzas de Porter

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

## 1.2.5 Análisis del Macroentorno — PESTEL

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

## 1.2.6 Matriz EFE — Evaluación de Factores Externos

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

## 1.2.7 Análisis FODA y Cruce Estratégico CAME

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
<p>D5. Equipo reducido (3 integrantes) para escalar producto y comercial a la vez</p>
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

## 1.2.8 Factores Críticos de Éxito (FCE)

| **FCE**                                 | **Descripción**                                       | **Origen en el análisis**      |
|-----------------------------------------|-------------------------------------------------------|--------------------------------|
| FCE1. Confianza verificable             | Historial objetivo y verificación legal de cada actor | D1, D2 · Porter F5 · EFI       |
| FCE2. Precio de referencia transparente | Conocer el precio de mercado antes de negociar        | D3, D6 · Porter F5 · ComexPerú |
| FCE3. Consolidación de carga            | Agrupar cargas compatibles y capturar retornos        | O2, O4 · CAME Explotar         |
| FCE4. Trazabilidad extremo a extremo    | Estado y evidencia en cada operación                  | D2, D4 · O1 · CAME Corregir    |
| FCE5. Adopción sin fricción             | Más simple que WhatsApp para vencer la inercia        | A4 · Porter F2 · CAME Afrontar |

