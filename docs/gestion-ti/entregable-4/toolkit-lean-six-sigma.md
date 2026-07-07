# 4.6 Complemento Metodológico: Toolkit Lean Six Sigma aplicado a LOGYX

Como refuerzo metodológico de la gestión de procesos, el proyecto de mejora AS-IS/TO-BE de LOGYX se desarrolla adicionalmente con el conjunto completo de herramientas de Lean Six Sigma utilizado por el equipo en el curso de Gestión de Procesos (ciclo 8): 5W2H, diagrama de Swimlane, diagrama de Ishikawa, árboles causales por categoría, diagrama de Pareto, sesión de brainstorming, plan de acción y plan de control. A diferencia de una síntesis tabular, cada herramienta se desarrolla aquí en su propio apartado, con introducción metodológica, desarrollo aplicado al caso real de LOGYX, el diagrama o espacio correspondiente, y su interpretación.

## 4.6.1 Herramienta 5W2H

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

## 4.6.2 Diagrama de Swimlane (análisis VA/NVA/NNVA)

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

## 4.6.3 Diagrama de Ishikawa (causa–efecto): desarrollo ampliado

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

## 4.6.4 Árboles Causales por Categoría

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

Causa raíz: vacío de mercado —ausencia de una solución tecnológica diseñada para el segmento PYME/transportista independiente del corredor, a diferencia de las soluciones enterprise existentes. Solución asociada en LOGYX: arquitectura de monolito modular de bajo costo operativo (documentación técnica de la solución), con comisión escalonada 2%–8% accesible a la escala de la PYME.

**4.6.4.3 Árbol Causal — Procedimiento**

| **Nivel**                 | **Análisis “por qué”**                                                                                                                                                                                                                                  |
|---------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Problema                  | No existe un procedimiento estándar para contratar transporte; cada envío se negocia de forma única e informal.                                                                                                                                         |
| ¿Por qué? (1)             | Porque no hay un formato o proceso definido de solicitud, cotización y aceptación de transporte que las partes conozcan y sigan.                                                                                                                        |
| ¿Por qué? (2)             | Porque la relación PYME–transportista se ha construido tradicionalmente sobre la confianza personal bilateral, no sobre un protocolo replicable entre cualquier par de actores del ecosistema.                                                          |
| ¿Por qué? (3)             | Porque no existe una autoridad o estándar sectorial (gremial o tecnológico) que haya propuesto y difundido un procedimiento común de contratación para el segmento informal del transporte de carga.                                                    |
| ¿Por qué? (4, causa raíz) | Porque la fragmentación de la oferta (miles de transportistas independientes sin organización gremial fuerte) impide que emerja orgánicamente un estándar de procedimiento sin un actor articulador que lo proponga y lo haga cumplir tecnológicamente. |

Causa raíz: ausencia de un actor articulador que defina y haga cumplir un procedimiento estándar de contratación en un mercado estructuralmente fragmentado. Solución asociada en LOGYX: el flujo TO-BE (sección 4.3) impone un procedimiento único y obligatorio —publicación, subasta, aceptación, ejecución con evidencia— para todos los actores que operan en la plataforma, actuando LOGYX como el articulador tecnológico que el mercado no había producido por sí solo.

## 4.6.5 Diagrama de Pareto

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

## 4.6.6 Sesión de Brainstorming

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

## 4.6.7 Plan de Acción

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

## 4.6.8 Plan de Control y Seguimiento

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

## 4.6.9 Síntesis en Formato A3

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

## Referencias

Armstrong & Associates, Inc. (2025). U.S. Third-Party Logistics (3PL) Market Size Estimates: Domestic Transportation Management. https://www.3plogistics.com/

Arvis, J.-F., Ojala, L., Shepherd, B., Ulybina, D., & Wiederer, C. (2023). Connecting to compete 2023: Trade logistics in an uncertain global economy — The logistics performance index and its indicators. World Bank Group.

Farromeque Quiroz, R. (2017). PERLOG-LATAM: Perfil logístico de América Latina. Banco de Desarrollo de América Latina (CAF).

Ministerio de Comercio Exterior y Turismo & Grupo Banco Mundial. (2016). Análisis integral de la logística en el Perú: 5 cadenas de exportación. MINCETUR.

Ministerio de la Producción. (2025). Las Mipyme en cifras 2024. Oficina General de Evaluación de Impacto y Estudios Económicos, PRODUCE.

Sociedad de Comercio Exterior del Perú \[ComexPerú\]. (2022). Los costos logísticos de las empresas en el país son del 16% en promedio, pero un 21.1% para las microempresas. Semanario Económico.


---
