# 1.7 Refuerzo de Gobierno de TI bajo COBIT 2019 (AS-IS / TO-BE) — extensión de CE0115

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


## Referencias

Armstrong & Associates, Inc. (2025). U.S. Third-Party Logistics (3PL) Market Size Estimates: Domestic Transportation Management. https://www.3plogistics.com/

Arvis, J.-F., Ojala, L., Shepherd, B., Ulybina, D., & Wiederer, C. (2023). Connecting to compete 2023: Trade logistics in an uncertain global economy — The logistics performance index and its indicators. World Bank Group.

Farromeque Quiroz, R. (2017). PERLOG-LATAM: Perfil logístico de América Latina. Banco de Desarrollo de América Latina (CAF).

Ministerio de Comercio Exterior y Turismo & Grupo Banco Mundial. (2016). Análisis integral de la logística en el Perú: 5 cadenas de exportación. MINCETUR.

Ministerio de la Producción. (2025). Las Mipyme en cifras 2024. Oficina General de Evaluación de Impacto y Estudios Económicos, PRODUCE.

Sociedad de Comercio Exterior del Perú \[ComexPerú\]. (2022). Los costos logísticos de las empresas en el país son del 16% en promedio, pero un 21.1% para las microempresas. Semanario Económico.


---

