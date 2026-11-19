# Semestre 2 — Implementación

!!! info "Versión 2.1: lo que realmente está desplegado en el VPS Hostinger"
    Los tres entregables documentan el despliegue real del **VPS Hostinger KVM 2** (Ubuntu 24.04, 2 vCPU, 8 GB, 96 GB) con Docker Compose: Caddy con HTTPS automático, web Astro, backend Quarkus, PostgreSQL 16 y MinIO, según la carpeta `infra/vps/` del monorepo (commit `cad2b77`). La versión 2.0 se había escrito antes de aprovisionar el servidor y suponía Cloudflare, R2, respaldos cifrados y Uptime Kuma, que **no se desplegaron**; cada documento los marca como *No implementado (mejora)*. El servidor opera como **entorno de pruebas** (cuentas demo). **Versión 2.2 (19-nov-2026):** la propuesta de seguridad se evaluó control por control y se aplicó en el VPS lo de bajo riesgo y reversible, con evidencia (salidas de comandos) en [Implementación de Seguridad, Sección 0](implementacion-seguridad.md): lista blanca `DOCKER-USER`, SSH y fail2ban ampliados, contenedores sin capacidades y de solo lectura, red de datos sin Internet, registro de accesos de Caddy, respaldos cifrados y chequeo de salud. Se ejecutaron también buena parte de las pruebas de red. Lo que depende de una decisión del responsable (Cloudflare, copia externa de respaldos, registro CAA, monitor externo) figura como *Pendiente*; las alertas, el reinicio por kernel y la contraseña demo propia se resolvieron en la v2.3. Ver [Rebrand OnCargo y migración a Hostinger](../../software/cambios-diseno-inicial.md#7-rebrand-oncargo-y-migracion-a-hostinger).

Producto final: **Informe de Implementación Integral y Operativa**, con presentación ejecutiva, evidencias unificadas (logs, pruebas), análisis de riesgos global, declaración de cumplimiento ético ACM y recomendaciones finales.

!!! success "Versiones 2.2 y 2.3 (19-nov-2026): endurecimiento, respaldos, monitoreo y alertas aplicados"
    Endurecimiento versionado del host y los contenedores (`harden.sh`, lista blanca `DOCKER-USER`, red `internal` sin salida a Internet, fail2ban sobre SSH y Caddy, auditd), log de accesos de Caddy, respaldo diario cifrado con prueba de restauración ejecutada (SIM-1), chequeo de salud cada 5 minutos con alertas por ntfy, contraseña demo propia del VPS y reinicio por kernel verificado. **Pendiente:** copia de respaldos fuera del VPS, monitor externo, registro CAA, Cloudflare, MFA con evidencia y las pruebas que faltan.

## Entregables

- **[C1.2/C1.3 — Implementación y Testing de Red](implementacion-red.md):** configuración real del VPS (Caddyfile, UFW, redes Docker `edge`/`internal`, DNS en Hostinger), direccionamiento IP, routing, controles de acceso, plan de pruebas T1–T15, monitoreo (healthchecks, `oncargo-health`, log de Caddy, fail2ban) y hallazgos H-01 a H-12 con su estado
- **[C2.2–C2.4 — Implementación, Monitoreo y Ética de Seguridad](implementacion-seguridad.md):** controles técnicos aplicados y verificados (SSH endurecido, UFW + `DOCKER-USER`, fail2ban, contenedores sin capacidades, secretos, roles de BD, TLS, auditd), gestión de parches, continuidad (respaldos cifrados; copia externa pendiente), detección, KPIs, auditoría, ética ACM
- **[C3.2/C3.3 — Implementación y Control de Datacenter](implementacion-datacenter.md):** aprovisionamiento, `compose.yml` real con cinco servicios, MinIO, trabajos programados, respaldo diario cifrado con `verify` (SIM-1 ejecutado), SLA, monitoreo, runbooks (`deploy.sh`, vuelta atrás, reconstrucción), eficiencia y costos
- **[Documentos de gestión del SGSI](gestion-sgsi.md):** alcance y exclusiones (VPN), inventario de activos C-I-D, riesgo residual, Declaración de Aplicabilidad (93 controles del Anexo A de ISO 27001), matriz de accesos, auditoría interna, acta de revisión por la dirección y declaración de ética para firmar

## Rúbricas resumidas

| Entregable | Criterios | Puntaje máx. |
|---|---|---|
| Implementación de Red | Dispositivos · Direccionamiento IP · Routing · ACL · Estándares · Pruebas · Monitoreo | 28 |
| Implementación de Seguridad | Controles técnicos · Mínimo privilegio · Parches · Continuidad · KPIs · Auditoría · Vulnerabilidades · Ética ACM | 32 |
| Implementación de Datacenter | Servidores · Servicios · Almacenamiento · Respaldo · SLA · Monitoreo · Documentación/eficiencia | 28 |

El producto final del semestre suma las tres rúbricas (máx. 88 puntos) más los criterios adicionales **Funcionalidad Integral** (pruebas end-to-end) y **Profesionalismo** (presentación formal).
