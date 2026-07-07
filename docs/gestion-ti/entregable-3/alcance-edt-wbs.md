# 3.2 Gestión del Alcance: EDT/WBS y diccionario (CE0122)

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

