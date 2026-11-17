# S1 · Entregable 2 — Planificación de Seguridad de la Información
> Competencia C2.1 · ISO 27005 / NIST · Activos críticos, riesgos, políticas y roles  
> Proyecto: OnCargo — Sistema Operativo Logístico Colaborativo para PYMEs  
> Equipo: Jorge Gutiérrez Miranda · Fabrizio Sanchez Saravia · Alex Coila Jarita  
> Semestre 1 · Junio 2026 · **Versión 2.0 (rediseño, noviembre 2026)** · Versión original 1.0 sobre AWS


!!! info "Versión 2.0: activos, riesgos y políticas sobre un VPS Hostinger"
    La versión 1.0 asumió AWS (IAM, KMS, Secrets Manager, WAF, GuardDuty, Bastion Host). La infraestructura cambió a un **VPS Hostinger KVM 2** con Docker Compose, Caddy, Cloudflare (DNS/CDN/WAF) y Cloudflare R2, por **costo y simplicidad** (ver [Rebrand OnCargo y migración a Hostinger](../../software/cambios-diseno-inicial.md#7-rebrand-oncargo-y-migracion-a-hostinger)). Este documento rehace el inventario de activos, la matriz de riesgos, las políticas y la respuesta a incidentes para ese entorno. Además se alinearon con el sistema real: JWT RSA de 8 h (sin *refresh token*), *rate limiting* en memoria (sin Redis), RLS con mínimo privilegio (ADR-0001/0006) y tiempo real por SSE (ADR-0007).

    La diferencia de fondo es el **modelo de responsabilidad**: en AWS el proveedor gestionaba servicios (RDS, KMS, WAF); en un VPS el equipo es responsable del sistema operativo, del firewall del host, de los parches, de los respaldos y del cifrado de secretos. Eso aumenta la responsabilidad operativa del equipo y reduce el costo.

---

## Resumen Ejecutivo

OnCargo gestiona datos personales y comerciales de empresas peruanas: RUC, DNI, ubicaciones de carga, contratos de transporte, ofertas y evidencias fotográficas de entrega. La plataforma opera en **un VPS Hostinger KVM 2 (Brasil)** detrás de **Cloudflare**, con documentos y respaldos en **Cloudflare R2**. El proveedor del VPS garantiza la seguridad física y la virtualización; el equipo conserva la responsabilidad sobre **el sistema operativo, la red del host, los contenedores, los datos, el acceso y las aplicaciones**.

Este documento identifica los activos críticos de OnCargo, cuantifica sus riesgos bajo el marco **ISO 27005 y NIST SP 800-30**, define las políticas de seguridad aplicables y establece los roles y responsabilidades del equipo mediante una matriz RACI.

---

## Sección 1 — Identificación de Activos Críticos

### 1.1 Clasificación de Activos

| ID | Activo | Tipo | Criticidad | Propietario |
|----|--------|------|-----------|-------------|
| A-01 | Base de datos PostgreSQL 16 (contenedor `db`, volumen `pgdata`) | Dato | **Crítico** | Jorge G. |
| A-02 | Código fuente (GitHub, monorepo `logyx`) | Software | **Crítico** | Jorge G. |
| A-03 | Secretos y credenciales (`infra/.env`, claves JWT en `infra/secrets/`, tokens de R2 y Cloudflare) | Dato | **Crítico** | Alex C. |
| A-04 | Bucket R2 `oncargo-documents` — documentos y evidencia de entrega | Dato | **Crítico** | Alex C. |
| A-05 | VPS Hostinger KVM 2 (host Ubuntu + Docker + contenedores) | Infraestructura | **Alto** | Alex C. |
| A-06 | Zona DNS y cuenta de Cloudflare, dominio `oncargo.tech` | Infraestructura | **Alto** | Alex C. |
| A-07 | Cuentas administrativas: Hostinger (panel del VPS), Cloudflare, GitHub, registrador | Acceso | **Crítico** | Jorge G. |
| A-08 | Tokens JWT de usuarios activos (RSA, TTL 8 h) | Dato | **Alto** | Fabrizio S. |
| A-09 | Logs de auditoría (`audit_log` en BD, logs de Caddy y de contenedores) | Dato | **Alto** | Fabrizio S. |
| A-10 | Pipeline CI/CD (GitHub Actions) | Software | **Medio** | Fabrizio S. |
| A-11 | Prototipos y documentación técnica | Información | **Medio** | Jorge G. |
| A-12 | Respaldos cifrados en R2 (`oncargo-backups`) y su clave de cifrado | Dato | **Crítico** | Alex C. |

### 1.2 Justificación de criticidad

| Activo | Por qué es crítico |
|--------|-------------------|
| A-01 (PostgreSQL) | Contiene datos de negocios, ubicaciones, contratos, calificaciones. Su pérdida implica pérdida total del negocio. Es el único almacén transaccional. |
| A-07 (cuentas administrativas) | El acceso al panel de Hostinger permite reinstalar o borrar el VPS; el de Cloudflare, redirigir el dominio o leer el tráfico del borde. Irreversible o de alto daño. |
| A-03 (secretos) | Contiene contraseñas de BD, claves privadas del JWT y credenciales de R2. Si se filtran, comprometen todos los servicios. |
| A-12 (respaldos y su clave) | Son la única vía de recuperación ante la pérdida del VPS. Sin la clave de cifrado, los respaldos son ilegibles; con ella en manos ajenas, expone todos los datos. |
| A-04 (R2) | Fotos de entrega y firmas son evidencia legal de contratos de servicio. |

---

## Sección 2 — Análisis de Riesgos (ISO 27005 / NIST SP 800-30)

### 2.1 Escala de valoración

**Probabilidad (P):**
| Nivel | Valor | Descripción |
|-------|-------|-------------|
| Muy baja | 1 | Ocurre una vez en > 5 años |
| Baja | 2 | Ocurre una vez al año |
| Media | 3 | Ocurre una vez al trimestre |
| Alta | 4 | Ocurre mensualmente |
| Muy alta | 5 | Ocurre semanalmente |

**Impacto (I):**
| Nivel | Valor | Descripción |
|-------|-------|-------------|
| Insignificante | 1 | Sin impacto en el negocio |
| Menor | 2 | Interrupción < 2h, sin pérdida de datos |
| Moderado | 3 | Interrupción 2–8h, datos recuperables |
| Mayor | 4 | Interrupción > 8h o pérdida de datos críticos |
| Catastrófico | 5 | Pérdida total de datos, cierre del negocio |

**Nivel de riesgo = P × I:**
| Rango | Nivel | Acción requerida |
|-------|-------|-----------------|
| 1–4 | **Bajo** | Aceptar y monitorear |
| 5–9 | **Medio** | Reducir en plazo de 3 meses |
| 10–16 | **Alto** | Reducir inmediatamente |
| 17–25 | **Crítico** | Tratamiento urgente antes de lanzar |

### 2.2 Matriz de Riesgos

| ID | Amenaza | Vulnerabilidad | Activo afectado | P | I | Riesgo (P×I) | Nivel | Control propuesto |
|----|---------|---------------|-----------------|---|---|-------------|-------|-------------------|
| R-01 | Acceso no autorizado a PostgreSQL | Puerto 5432 publicado o credenciales débiles | A-01 | 3 | 5 | **15** | Alto | `db` sin `ports:` y solo en la red `internal`; contraseñas únicas por rol; `logyx_api` sin escalada (`DatabasePrivilegesTest`) |
| R-02 | Compromiso de cuentas administrativas (Hostinger, Cloudflare, GitHub) | Sin 2FA, credenciales reutilizadas | A-07 | 2 | 5 | **10** | Alto | 2FA obligatorio en todas; gestor de contraseñas; tokens de API acotados |
| R-03 | Inyección SQL en la API | Parámetros no sanitizados | A-01 | 3 | 4 | **12** | Alto | JPA/consultas parametrizadas; Cloudflare WAF; mínimo privilegio y RLS limitan el alcance (ADR-0006) |
| R-04 | Filtración de documentos en R2 | Bucket público por error | A-04 | 2 | 4 | **8** | Medio | Bucket privado sin dominio público ni `r2.dev`; token limitado al bucket; descarga solo vía API con RLS |
| R-05 | Fuerza bruta al login / registros masivos | Sin límite de intentos | A-08 | 4 | 3 | **12** | Alto | `AuthRateLimits` (50/15 min por IP, bloqueo tras 10 fallos por email); Cloudflare *Bot Fight Mode*; fail2ban en el host para SSH |
| R-06 | Robo de JWT activo | Token interceptado o robado por XSS | A-08 | 2 | 4 | **8** | Medio | JWT en cookie `httpOnly` + `Secure` + `SameSite=Lax`; TTL 8 h; TLS (HSTS) en todo el trayecto; CSP |
| R-07 | DDoS a la API pública | Origen único sin balanceador | A-05 | 3 | 3 | **9** | Medio | Cloudflare (DDoS ilimitado en el plan gratuito); el firewall del host solo admite rangos de Cloudflare |
| R-08 | Fuga de secretos en código | `.env` o claves commiteadas a GitHub | A-03 | 3 | 5 | **15** | Alto | `.gitignore` de `infra/.env`, `infra/secrets/` y `*.pem`; GitHub secret scanning; secretos de CI en GitHub Secrets |
| R-09 | Suplantación de organización (RUC falso) | Solo validación Módulo 11 (sin SUNAT) | A-01 | 4 | 3 | **12** | Alto | Integración SUNAT (pendiente); verificación manual por el operador |
| R-10 | Pérdida total de datos | Un solo VPS; respaldos no probados | A-01, A-04, A-12 | 3 | 5 | **15** | Alto | `pg_dump` diario cifrado a R2 (fuera del proveedor) con retención de 30 días; documentos en R2; prueba mensual de restauración |
| R-11 | Acceso SSH no autorizado al VPS | Puerto 22 expuesto a Internet | A-05 | 3 | 4 | **12** | Alto | Solo clave pública, `PasswordAuthentication no`, sin login de root, fail2ban, restricción por IP si es posible |
| R-12 | Supply chain: dependencia o imagen comprometida | Librería Maven/NPM/imagen base maliciosa | A-02, A-05 | 2 | 4 | **8** | Medio | Dependabot; imágenes base oficiales fijadas; CI con pruebas |
| R-13 | Insider threat (equipo) | Commit malicioso o filtración interna | A-02 | 2 | 4 | **8** | Medio | Protección de ramas; revisión de PR; `audit_log` |
| R-14 | Exfiltración de datos de clientes | Acceso excesivo a la BD | A-01 | 2 | 5 | **10** | Alto | RLS por `org_id`; roles de mínimo privilegio; `audit_log` inmutable |
| R-15 | Indisponibilidad de servicios de terceros (OpenFreeMap, futuro ruteo) | Dependencia externa | A-05 | 3 | 2 | **6** | Medio | Rutas por carretera precalculadas en el repositorio (ADR-0008, sin red en ejecución); respaldo × 1.35 marcado `estimated` |
| R-16 | Caída o compromiso del VPS por falta de parches | Sistema operativo sin actualizar | A-05 | 3 | 4 | **12** | Alto | `unattended-upgrades` para seguridad; ventana mensual de parches; reconstrucción reproducible desde el compose |
| R-17 | Falla del proveedor (Hostinger) o de la región | Dependencia de un único proveedor y datacenter | A-05 | 2 | 4 | **8** | Medio | Respaldos fuera del proveedor (R2); runbook de reconstrucción en otro VPS; IP y DNS controlados desde Cloudflare |

### 2.3 Mapa de calor de riesgos

```
Impacto →
         1         2         3         4         5
P  5 |   -    |   -    |   -    |   -    |   -    |
r  4 |   -    |   -    | R-05   |   -    |   -    |
o  3 |   -    | R-15   | R-07   | R-03,  | R-01,  |
b    |        |        |        | R-11,  | R-08,  |
     |        |        |        | R-16   | R-10   |
   2 |   -    |   -    |   -    | R-04,06| R-02   |
     |        |        |        | R-17   |        |
   1 |                 R-12,R-13,R-14 dispersos            |
      ─────────────────────────────────────────────
      Bajo       Bajo     Medio    Alto    Crítico
```

**Riesgos prioritarios (tratamiento inmediato):**
- R-01: PostgreSQL expuesto → ALTO (15)
- R-08: Fuga de secretos → ALTO (15)
- R-10: Pérdida total de datos (VPS único) → ALTO (15)
- R-03: Inyección SQL → ALTO
- R-05: Fuerza bruta → ALTO
- R-11: SSH expuesto → ALTO
- R-16: Falta de parches → ALTO

---

## Sección 3 — Políticas de Seguridad

### POL-01: Política de Control de Acceso e Identidad

**Alcance:** VPS, cuentas de proveedores (Hostinger, Cloudflare, GitHub, registrador) y usuarios del sistema.

| Regla | Detalle |
|-------|---------|
| Cuentas individuales | Cada miembro del equipo usa su propia cuenta en cada proveedor. Sin cuentas compartidas. |
| 2FA obligatorio | Autenticación en dos pasos en Hostinger, Cloudflare, GitHub y el registrador del dominio. |
| Sin `root` remoto | Acceso al VPS con usuario administrador sin privilegios de arranque (`sudo` con registro); `PermitRootLogin no`. |
| Principio de mínimo privilegio | Tokens de API de Cloudflare y R2 acotados a la zona o al bucket; el usuario `logyx_api` de BD no es dueño de nada y no puede escalar. |
| Rotación de credenciales | Tokens de R2 y Cloudflare cada 90 días; contraseñas de BD y claves JWT ante sospecha o salida de un integrante. |
| Revisión trimestral de accesos | Auditar quién tiene acceso a cada panel, a las claves SSH autorizadas y a los secretos de GitHub. |

**Identidades y permisos definidos:**

| Identidad | Permisos | Asignada a |
|---------|----------|-----------|
| Usuario `deploy` (VPS) | Ejecutar `docker compose` en `/opt/oncargo`; sin acceso a otros directorios del sistema | GitHub Actions (clave SSH dedicada) y administradores |
| Usuario `admin` (VPS) | `sudo` con registro; acceso por clave SSH | Responsables de infraestructura |
| Token R2 `oncargo-documents-rw` | Lectura y escritura **solo** del bucket `oncargo-documents` | Contenedor `backend` |
| Token R2 `oncargo-backups-w` | Escritura en `oncargo-backups`; se evalúa si R2 permite excluir el borrado (si no, se mitiga con bloqueo de objetos o un token de solo lectura aparte para restaurar) | Tarea de respaldo del host |
| Token de Cloudflare (DNS) | Editar registros DNS de la zona `oncargo.tech` | Administrador de infraestructura |
| Roles de BD `logyx_owner` / `logyx_app` / `logyx_api` | Ver [Seguridad y Administración BD](../../software/entregable-2/seguridad.md) | Backend (Flyway/`SystemTx` y aplicación) |

### POL-02: Política de Cifrado

| Ámbito | Mecanismo | Estándar |
|--------|-----------|---------|
| Datos en tránsito (web/API) | TLS en el borde (Cloudflare, modo Full strict) y TLS hasta el origen con Caddy (Let's Encrypt, renovación automática); HSTS de 1 año | TLS 1.2/1.3 |
| Datos en tránsito (BD) | Red `internal` de Docker sin exposición; `sslmode=require` si la BD se separa en otro host | PostgreSQL SSL |
| Datos en reposo (R2) | Cifrado en reposo gestionado por Cloudflare (AES-256) | Cloudflare R2 |
| Datos en reposo (VPS) | Sin cifrado de disco del proveedor garantizado: los datos sensibles dependen del control de acceso al host; se evalúa cifrar el volumen de `pgdata` | A decidir |
| Contraseñas de usuario | bcrypt (`BcryptPasswordHasher`) | No reversible |
| Secretos de aplicación | Archivos `infra/.env` (permiso 600) y claves JWT montadas como *secrets* de Docker; copia cifrada fuera del VPS en un gestor de contraseñas | — |
| Respaldos | `pg_dump` cifrado con `age`/OpenSSL AES-256 **antes** de subirlo a R2; la clave se guarda aparte | AES-256 |

### POL-03: Política de Backup y Recuperación

| Tipo de backup | Frecuencia | Retención | Verificación |
|---------------|-----------|-----------|-------------|
| `pg_dump -Fc` de la BD, cifrado, a R2 `oncargo-backups` | Diario (02:00, hora de Lima) | 30 días (regla de ciclo de vida de R2) | Prueba mensual de restauración en un entorno local |
| `pg_dump` manual previo a cada despliegue mayor | Antes de cada deploy con migraciones | 90 días | Al crear (tamaño y `pg_restore --list`) |
| Documentos en R2 `oncargo-documents` | Continuo (el almacenamiento es R2) | Sin borrado automático; versionado del bucket evaluado | Muestra aleatoria mensual |
| Copia de secretos y claves JWT | Al crearse o rotarse | Mientras estén vigentes | Al rotar |
| Snapshot del VPS (panel de Hostinger) | Antes de cambios de sistema operativo (si el plan lo permite) | Última | Al crear |
| Logs | `journald` y logs de Caddy con rotación | 30 días en el VPS | — |

**RTO/RPO:**
- RPO (máx. pérdida de datos): **24 h** con el respaldo diario (reducible a minutos con archivado de WAL hacia R2).
- RTO (tiempo de recuperación): **2–4 h** (nuevo VPS, instalación de Docker, `docker compose up`, restauración del dump y comprobaciones).

### POL-04: Política de Gestión de Vulnerabilidades

| Actividad | Frecuencia | Responsable |
|-----------|-----------|-------------|
| Dependabot (Maven, npm, Gradle, GitHub Actions) | Continua; PR automáticos | Fabrizio S. |
| Revisión de CVEs críticos (NVD) | Semanal | Alex C. |
| Actualizaciones de seguridad del SO (`unattended-upgrades`) | Automáticas diarias; reinicio en la ventana mensual (domingo 03:00) | Alex C. |
| Actualización de imágenes base Docker (`postgres:16-alpine`, Temurin, Node) | Mensual y ante CVE crítico | Alex C. |
| Prueba de seguridad controlada (Nmap externo, OWASP ZAP contra staging local) | Trimestral (S2) | Equipo |
| Revisión de eventos de fail2ban, Cloudflare y `outbox_events FAILED` | Semanal | Jorge G. |

### POL-05: Política de Acceso Remoto

| Regla | Implementación |
|-------|---------------|
| SSH solo con clave pública | `PasswordAuthentication no`; claves individuales en `authorized_keys` |
| Sin `root` por SSH | `PermitRootLogin no`; acceso con usuario `admin` y `sudo` |
| Fuerza bruta contenida | fail2ban sobre el *jail* `sshd`; UFW con límite de conexiones (`ufw limit 22/tcp`) |
| Restricción de origen | Si el equipo cuenta con IP fija, el puerto 22 solo admite esa IP; de lo contrario se cambia el puerto y se mantiene fail2ban |
| Paneles de administración | PostgreSQL y cualquier consola interna **no** se exponen; se accede por túnel SSH (`ssh -L`) |
| Redes no confiables | Usar VPN personal antes de acceder a los paneles de Hostinger o Cloudflare desde redes públicas |

### POL-06: Política de Clasificación y Manejo de Datos

| Clasificación | Ejemplos en OnCargo | Control |
|--------------|-------------------|---------|
| **Público** | Rutas disponibles, precios de referencia (anonimizados) | Sin restricciones |
| **Interno** | Métricas de uso, logs de sistema | Solo acceso interno |
| **Confidencial** | RUC, DNI, datos de contratos, precios acordados | Cifrado en tránsito, acceso por rol y RLS |
| **Altamente confidencial** | Credenciales, claves JWT, clave de cifrado de respaldos, tokens de API | Solo archivos de secretos con permiso restringido; sin registrar el valor en logs |

---

## Sección 4 — Roles y Responsabilidades

### 4.1 Organigrama de seguridad

```
┌─────────────────────────────────────┐
│  Responsable de Seguridad           │
│  Jorge Gutiérrez Miranda            │
│  • Decisiones de arquitectura       │
│  • Cuentas administrativas          │
│  • Revisión de políticas            │
└────────────────┬────────────────────┘
                 │
    ┌────────────┴──────────────┐
    │                           │
┌───▼──────────────┐   ┌───────▼──────────────┐
│ Seguridad de     │   │ Operaciones e        │
│ Infraestructura  │   │ Implementación       │
│ Alex Coila Jarita│   │ Fabrizio Sanchez     │
│ • VPS / UFW      │   │ • CI/CD pipeline     │
│ • Caddy / TLS    │   │ • Monitoreo y alertas│
│ • Backups / R2   │   │ • Incident response  │
│ • Parches del SO │   │ • Análisis de logs   │
└──────────────────┘   └──────────────────────┘
```

### 4.2 Matriz RACI de Seguridad

| Actividad | Jorge G. | Alex C. | Fabrizio S. |
|-----------|----------|---------|-------------|
| Definir políticas de seguridad | **R** | C | I |
| Gestionar cuentas administrativas (Hostinger, Cloudflare, registrador) | **R** | I | I |
| Configurar firewall del host, SSH y redes Docker | C | **R** | I |
| Gestionar tokens de R2/Cloudflare y secretos | **R** | C | I |
| Configurar Caddy, TLS y cabeceras | I | **R** | C |
| Configurar PostgreSQL y backups | C | **R** | I |
| Configurar reglas WAF de Cloudflare | C | **R** | C |
| Configurar monitoreo y alertas | I | C | **R** |
| Configurar fail2ban y revisar eventos | I | **R** | C |
| Responder a incidentes de seguridad | **A** | **R** | C |
| Ejecutar Dependabot / CI | I | I | **R** |
| Auditar accesos (trimestral) | **R** | C | I |
| Documentar procedimientos de seguridad | C | C | **R** |

*R = Responsable · A = Aprobador · C = Consultado · I = Informado*

### 4.3 Procedimiento de respuesta a incidentes

| Fase | Actividad | Responsable | Tiempo máximo |
|------|-----------|-------------|---------------|
| **Detección** | Alerta de monitoreo externo, fail2ban, Cloudflare o `outbox_events` en `FAILED` | Fabrizio S. | — |
| **Clasificación** | Determinar severidad (Baja/Media/Alta/Crítica) | Fabrizio S. | 15 min |
| **Contención** | Bloquear IP en Cloudflare o UFW, revocar tokens, detener el contenedor afectado o poner Cloudflare en modo "Under Attack" | Alex C. | 30 min |
| **Erradicación** | Parchear la vulnerabilidad, rotar secretos y claves JWT | Alex C. | 4 h |
| **Recuperación** | Restaurar el servicio (o reconstruir el VPS desde el respaldo) y verificar integridad | Equipo | 2–4 h |
| **Lecciones** | Documentar en informe post-mortem | Jorge G. | 48 h |

---

## Anexos

### Anexo A — Matriz de riesgos completa (ISO 27005)

| ID | Riesgo | Activo | P | I | R | Tratamiento | Estado |
|----|--------|--------|---|---|---|-------------|--------|
| R-01 | PostgreSQL expuesto | A-01 | 3 | 5 | 15 | `db` sin puertos publicados + roles de mínimo privilegio | Implementado en el compose (`db` solo en red `internal`) |
| R-02 | Cuentas administrativas sin 2FA | A-07 | 2 | 5 | 10 | 2FA + gestor de contraseñas | Pendiente (al aprovisionar) |
| R-03 | Inyección SQL | A-01 | 3 | 4 | 12 | JPA parametrizado + RLS + WAF | Implementado (app) / Diseñado (WAF) |
| R-04 | R2 público | A-04 | 2 | 4 | 8 | Bucket privado, descarga solo vía API | Implementado (API con RLS) / Diseñado (bucket R2) |
| R-05 | Fuerza bruta | A-08 | 4 | 3 | 12 | `AuthRateLimits` + Cloudflare + fail2ban | Implementado (app) / Diseñado (host) |
| R-06 | Robo de token | A-08 | 2 | 4 | 8 | Cookie `httpOnly` + TLS + TTL 8 h | Implementado |
| R-07 | DDoS | A-05 | 3 | 3 | 9 | Cloudflare + UFW por rangos | Diseñado |
| R-08 | Fuga de secretos | A-03 | 3 | 5 | 15 | `.gitignore` + secret scanning | Implementado (`.gitignore`) / Diseñado (scanning) |
| R-09 | RUC falso | A-01 | 4 | 3 | 12 | Verificación SUNAT + operador | Pendiente (SUNAT) |
| R-10 | Pérdida de datos | A-01, A-04, A-12 | 3 | 5 | 15 | `pg_dump` cifrado a R2 + prueba mensual | Diseñado |
| R-11 | SSH expuesto | A-05 | 3 | 4 | 12 | Clave + fail2ban + UFW | Diseñado |
| R-12 | Supply chain | A-02 | 2 | 4 | 8 | Dependabot + CI | Implementado (Dependabot) |
| R-13 | Insider | A-02 | 2 | 4 | 8 | PR reviews + `audit_log` | Implementado (`audit_log`) |
| R-14 | Exfiltración | A-01 | 2 | 5 | 10 | RLS + `audit_log` | Implementado |
| R-15 | Servicio de terceros caído | A-05 | 3 | 2 | 6 | Rutas precalculadas (ADR-0008) + respaldo estimado | Implementado (ADR-0008, backend) |
| R-16 | Falta de parches | A-05 | 3 | 4 | 12 | `unattended-upgrades` + ventana mensual | Diseñado |
| R-17 | Falla del proveedor | A-05 | 2 | 4 | 8 | Respaldos en R2 + runbook de reconstrucción | Diseñado |

*Estados:* **Implementado** = existe en el código o el compose del monorepo; **Diseñado** = definido para el despliegue en el VPS y pendiente de ejecutar; **Pendiente** = depende de una integración o de una acción administrativa.

### Anexo B — Referencias a estándares

| Estándar | Aplicación |
|---------|-----------|
| ISO/IEC 27001:2022 | Marco general de SGSI — estructura de políticas |
| ISO/IEC 27005:2022 | Metodología de análisis y gestión de riesgos |
| NIST SP 800-30 Rev.1 | Guía de evaluación de riesgos — escala P × I |
| NIST SP 800-53 | Controles de seguridad de referencia |
| CIS Benchmark Ubuntu Linux 24.04 | Endurecimiento del sistema operativo del VPS |
| CIS Docker Benchmark | Endurecimiento de contenedores y del daemon de Docker |
| OWASP Top 10 | Vulnerabilidades web críticas — mitigadas en la aplicación y con el WAF de Cloudflare |
| Ley N° 29733 (Perú) | Protección de datos personales |

---

*OnCargo · S1 Entregable 2 · Planificación de Seguridad · Competencia C2.1 · Versión 2.0 · Noviembre 2026 (original: Junio 2026)*
