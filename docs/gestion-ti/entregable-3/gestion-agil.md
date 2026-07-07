# 3.6 Gestión Ágil

La ejecución se gobierna con Scrum adaptado a un equipo de tres personas a tiempo parcial: sprints de dos semanas, planificación y retrospectiva por sprint, sincronización asíncrona diaria, y tablero de trabajo en la plataforma del repositorio.

## 3.6.1 Backlog del producto (resumen por épicas)

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

## 3.6.2 Historias de usuario (formato y ejemplos)

Cada épica se descompone en historias con el formato estándar Como / Quiero / Para, criterios de aceptación verificables y estimación en puntos de historia. Ejemplos representativos:

- HU-021 (EP-02): Como PYME, quiero publicar una solicitud de carga con origen, destino, peso y fecha, para recibir ofertas competitivas de transportistas verificados. Criterios: la solicitud muestra un precio de referencia calculado antes de publicar; queda visible en el marketplace en menos de un minuto; solo transportistas verificados pueden ofertar.

- HU-034 (EP-02): Como transportista, quiero que la subasta se cierre automáticamente al vencer el tiempo o alcanzar el máximo de ofertas, para que las condiciones de competencia sean iguales para todos. Criterios: cierre automático verificable; ninguna oferta posterior al cierre es aceptada; la PYME recibe notificación con el resumen de ofertas.

- HU-058 (EP-07): Como conductor, quiero confirmar cada entrega con fotografía y firma del receptor incluso sin conexión, para que la evidencia quede registrada y se sincronice al recuperar señal. Criterios: captura local persistente; sincronización automática; la PYME ve la evidencia en su panel.

## 3.6.3 Métricas de la gestión ágil

- Velocidad: puntos completados por sprint, con gráfico de tendencia a partir del Sprint 2.

- Burndown por sprint: trabajo restante diario contra la línea ideal; desviaciones se tratan en la sincronización.

- Calidad: cobertura de pruebas del backend y estado del pipeline como criterio de terminado; ningún incremento se integra con el pipeline en rojo.

El backlog completo —historias por épica con criterios y puntos, planificación detallada por sprint y métricas— se adjunta como evidencia en el Anexo C.

## 3.6.4 Evidencia de Configuración en Azure DevOps

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

