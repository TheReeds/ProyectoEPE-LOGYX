# 3.3 Gestión del Cronograma (CE0123)

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

