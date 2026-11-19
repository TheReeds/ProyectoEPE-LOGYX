# Semestre 2 — Implementación

!!! info "Versión 2.1: lo que realmente está desplegado en el VPS Hostinger"
    Los tres entregables documentan el despliegue real del **VPS Hostinger KVM 2** (Ubuntu 24.04, 2 vCPU, 8 GB, 96 GB) con Docker Compose: Caddy con HTTPS automático, web Astro, backend Quarkus, PostgreSQL 16 y MinIO, según la carpeta `infra/vps/` del monorepo (commit `cad2b77`). La versión 2.0 se había escrito antes de aprovisionar el servidor y suponía Cloudflare, R2, respaldos cifrados y Uptime Kuma, que **no se desplegaron**; cada documento los marca como *No implementado (mejora)*. El servidor opera como **entorno de pruebas** (cuentas demo). **Versión 2.2 (19-nov-2026):** la propuesta de seguridad se evaluó control por control y se aplicó en el VPS lo de bajo riesgo y reversible, con evidencia (salidas de comandos) en [Implementación de Seguridad, Sección 0](implementacion-seguridad.md): lista blanca `DOCKER-USER`, SSH y fail2ban ampliados, contenedores sin capacidades y de solo lectura, red de datos sin Internet, registro de accesos de Caddy, respaldos cifrados y chequeo de salud. Se ejecutaron también buena parte de las pruebas de red. Lo que depende de una decisión del responsable (Cloudflare, copia externa de respaldos, alertas, reinicio por kernel, contraseña demo) figura como *Pendiente*. Ver [Rebrand OnCargo y migración a Hostinger](../../software/cambios-diseno-inicial.md#7-rebrand-oncargo-y-migracion-a-hostinger).

Producto final: **Informe de Implementación Integral y Operativa**, con presentación ejecutiva, evidencias unificadas (logs, pruebas), análisis de riesgos global, declaración de cumplimiento ético ACM y recomendaciones finales.

## Entregables

- **[C1.2/C1.3 — Implementación y Testing de Red](implementacion-red.md):** configuración real del VPS (Caddyfile, UFW, redes Docker `edge`/`internal`, DNS en Hostinger), direccionamiento IP, routing, controles de acceso, plan de pruebas T1–T15, monitoreo (healthchecks, logs, fail2ban) y hallazgos del modo de pruebas
- **[C2.2–C2.4 — Implementación, Monitoreo y Ética de Seguridad](implementacion-seguridad.md):** controles técnicos aplicados (SSH con clave, UFW, fail2ban, secretos generados en el servidor, roles de BD, TLS), gestión de parches, continuidad (con la falta de respaldos declarada), detección, KPIs, auditoría, ética ACM
- **[C3.2/C3.3 — Implementación y Control de Datacenter](implementacion-datacenter.md):** aprovisionamiento, `compose.yml` real con cinco servicios, MinIO, trabajos programados, estado de los respaldos y procedimiento manual, SLA, monitoreo, runbooks (`deploy.sh`, vuelta atrás, reconstrucción), eficiencia y costos

## Rúbricas resumidas

| Entregable | Criterios | Puntaje máx. |
|---|---|---|
| Implementación de Red | Dispositivos · Direccionamiento IP · Routing · ACL · Estándares · Pruebas · Monitoreo | 28 |
| Implementación de Seguridad | Controles técnicos · Mínimo privilegio · Parches · Continuidad · KPIs · Auditoría · Vulnerabilidades · Ética ACM | 32 |
| Implementación de Datacenter | Servidores · Servicios · Almacenamiento · Respaldo · SLA · Monitoreo · Documentación/eficiencia | 28 |

El producto final del semestre suma las tres rúbricas (máx. 88 puntos) más los criterios adicionales **Funcionalidad Integral** (pruebas end-to-end) y **Profesionalismo** (presentación formal).
