# 3.7 Cumplimiento Normativo — Hallazgos del Análisis COBIT (extensión de CE0125)

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

