# E3 — Plan de Gestión del Proyecto
> Competencia: CE0121–CE0125 · Proyecto: LOGYX

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

