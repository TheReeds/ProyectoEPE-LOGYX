# Semestre 2 — Implementación

!!! info "Versión 2.0: implementación sobre un VPS Hostinger"
    Los tres entregables se rehicieron para el despliegue en un **VPS Hostinger KVM 2** con Docker Compose, Caddy, Cloudflare y R2 (antes AWS). Cada control y prueba indica su **estado**: implementado en el repositorio, definido para el VPS (pendiente de ejecutar) o pendiente; los resultados de las pruebas se registrarán al aprovisionar el servidor. Ver [Rebrand OnCargo y migración a Hostinger](../../software/cambios-diseno-inicial.md#7-rebrand-oncargo-y-migracion-a-hostinger).

Producto final: **Informe de Implementación Integral y Operativa**, con presentación ejecutiva, evidencias unificadas (logs, pruebas), análisis de riesgos global, declaración de cumplimiento ético ACM y recomendaciones finales.

## Entregables

- **[C1.2/C1.3 — Implementación y Testing de Red](implementacion-red.md):** configuración del VPS (Caddy, UFW, redes Docker, Cloudflare), direccionamiento IP, routing, controles de acceso, plan de pruebas de conectividad/rendimiento, monitoreo (logs, fail2ban, Uptime Kuma)
- **[C2.2–C2.4 — Implementación, Monitoreo y Ética de Seguridad](implementacion-seguridad.md):** controles técnicos (SSH con clave, tokens de mínimo privilegio, cifrado, firewall, backup), gestión de parches, planes de continuidad, detección automatizada, KPIs de seguridad, auditoría, ética ACM
- **[C3.2/C3.3 — Implementación y Control de Datacenter](implementacion-datacenter.md):** configuración del VPS y los servicios en Docker Compose, almacenamiento (volumen NVMe y Cloudflare R2), políticas de respaldo, SLA, monitoreo, runbooks, eficiencia de recursos y costos

## Rúbricas resumidas

| Entregable | Criterios | Puntaje máx. |
|---|---|---|
| Implementación de Red | Dispositivos · Direccionamiento IP · Routing · ACL · Estándares · Pruebas · Monitoreo | 28 |
| Implementación de Seguridad | Controles técnicos · Mínimo privilegio · Parches · Continuidad · KPIs · Auditoría · Vulnerabilidades · Ética ACM | 32 |
| Implementación de Datacenter | Servidores · Servicios · Almacenamiento · Respaldo · SLA · Monitoreo · Documentación/eficiencia | 28 |

El producto final del semestre suma las tres rúbricas (máx. 88 puntos) más los criterios adicionales **Funcionalidad Integral** (pruebas end-to-end) y **Profesionalismo** (presentación formal).
