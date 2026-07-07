# 1.1 Contexto Organizacional (CE0111)

## 1.1.1 Unidad de análisis

El objeto del presente diagnóstico es el ecosistema logístico de las pequeñas y medianas empresas del corredor Lima–Sierra Sur (Lima–Arequipa–Juliaca–Puno–Cusco). Un ecosistema, a diferencia de una organización individual, carece de estructura jerárquica y documentos institucionales propios; por ello, para efectos operativos del análisis, se emplea como recurso metodológico declarado una PYME arquetipo: una empresa manufacturera o comercial del corredor, con envíos regulares de 0.5 a 5 toneladas y frecuencia semanal, que coordina su transporte de manera informal. Esta figura sintetiza el perfil de los segmentos identificados en el estudio de mercado del proyecto y permite aplicar los instrumentos de análisis estratégico (FODA, EFI, EFE, PESTEL, Porter, CAME) sobre un sujeto concreto sin perder la representatividad del ecosistema.

LOGYX —plataforma colaborativa de logística B2B— constituye la solución TIC que se propondrá como resultado de este diagnóstico, y su diseño técnico se desarrolla en la documentación técnica de la solución (fuera del alcance de esta ronda de evaluación). Esta separación metodológica garantiza que el diagnóstico no esté sesgado hacia la solución: primero se caracteriza el problema del ecosistema con evidencia verificable, y solo después se justifica la intervención tecnológica.

## 1.1.2 Descripción del sector y entorno competitivo

El tejido empresarial peruano está compuesto por **2,330,226 MIPYMEs formales** (Ministerio de la Producción, 2025), concentradas mayoritariamente en los sectores Comercio (44.1%) y Servicios (41.3%), con Manufactura representando el 8.7%.

Geográficamente, Lima concentra más del 40% del total nacional de empresas formales; tras la capital, las regiones de **Arequipa, Cusco y Puno** representan colectivamente los mercados comerciales más grandes del país (Cuadro 4.5, PRODUCE 2025).

En el plano macro-logístico, el Perú obtiene un puntaje de **3.0 sobre 5 en el Logistics Performance Index 2023** del Banco Mundial, con rezagos particulares en infraestructura física (2.5) y eficiencia aduanera (2.6) (Arvis et al., 2023).

El entorno competitivo del servicio de transporte de carga en el corredor está dominado por la informalidad: coordinación por WhatsApp, llamadas y Excel; intermediarios sin tecnología ni trazabilidad; y la figura del “hombre-camión” que atomiza la oferta.

## 1.1.3 Estructura organizacional de la PYME arquetipo

| **Rol**                      | **Funciones**                                           | **Relación con la logística**                                            |
|------------------------------|---------------------------------------------------------|--------------------------------------------------------------------------|
| Gerente–propietario          | Dirección general, decisiones comerciales y financieras | Negocia personalmente cada flete por teléfono; decide el transportista   |
| Administrador / contador     | Facturación, pagos, tributos                            | Registra el gasto de flete sin desglose ni comparativo                   |
| Encargado de almacén         | Recepción, despacho y empaque de mercadería             | Coordina la hora de recojo por WhatsApp; sin evidencia formal de entrega |
| Ventas / atención al cliente | Pedidos y relación con clientes                         | Informa al cliente el estado del envío “llamando al chofer”              |

La función logística no existe como área: está distribuida informalmente entre el gerente, el almacén y ventas, sin procesos definidos, sin indicadores y sin sistemas de información de soporte.

## 1.1.4 Cadena de valor logística del corredor

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

## 1.1.5 Mapa de stakeholders

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

## 1.1.6 Aspectos Generales de la Organización LOGYX

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

