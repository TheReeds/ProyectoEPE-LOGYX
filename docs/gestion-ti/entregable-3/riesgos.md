# 3.5 Gestión de Riesgos del Proyecto (CE0125)

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

