# S1 · Entregable 2 — Planificación de Seguridad de la Información
> Competencia C2.1 · ISO 27005 / NIST · Activos críticos, riesgos, políticas y roles  
> Proyecto: LOGYX — Sistema Operativo Logístico Colaborativo para PYMEs  
> Equipo: Jorge Gutiérrez Miranda · Fabrizio Sanchez Saravia · Alex Coila Jarita  
> Semestre 1 · Junio 2026

---

## Resumen Ejecutivo

LOGYX gestiona datos personales y comerciales de empresas peruanas: RUC, DNI, ubicaciones de carga, contratos de transporte, historial de pagos y evidencias fotográficas de entrega. La plataforma opera completamente en AWS (sa-east-1), lo que traslada la seguridad física al proveedor cloud, pero mantiene en el equipo la responsabilidad sobre la **seguridad de los datos, el acceso y las aplicaciones** (Modelo de Responsabilidad Compartida AWS).

Este documento identifica los activos críticos de LOGYX, cuantifica sus riesgos bajo el marco **ISO 27005 y NIST SP 800-30**, define las políticas de seguridad aplicables y establece los roles y responsabilidades del equipo mediante una matriz RACI.

---

## Sección 1 — Identificación de Activos Críticos

### 1.1 Clasificación de Activos

| ID | Activo | Tipo | Criticidad | Propietario |
|----|--------|------|-----------|-------------|
| A-01 | Base de datos PostgreSQL (RDS) | Dato | **Crítico** | Jorge G. |
| A-02 | Código fuente (GitHub) | Software | **Crítico** | Jorge G. |
| A-03 | Secretos y credenciales (AWS Secrets Manager) | Dato | **Crítico** | Alex C. |
| A-04 | Bucket S3 — documentos de entrega | Dato | **Crítico** | Alex C. |
| A-05 | Instancias EC2 — backend Quarkus | Infraestructura | **Alto** | Alex C. |
| A-06 | VPC y configuración de red | Infraestructura | **Alto** | Alex C. |
| A-07 | Cuenta AWS root | Acceso | **Crítico** | Jorge G. |
| A-08 | Tokens JWT de usuarios activos | Dato | **Alto** | Fabrizio S. |
| A-09 | Logs de auditoría (CloudWatch + BD) | Dato | **Alto** | Fabrizio S. |
| A-10 | Pipeline CI/CD (GitHub Actions) | Software | **Medio** | Fabrizio S. |
| A-11 | Prototipos y documentación técnica | Información | **Medio** | Jorge G. |
| A-12 | Claves KMS de cifrado | Acceso | **Crítico** | Alex C. |

### 1.2 Justificación de criticidad

| Activo | Por qué es crítico |
|--------|-------------------|
| A-01 (RDS) | Contiene datos de negocios, ubicaciones, contratos, calificaciones. Su pérdida implica pérdida total del negocio. |
| A-07 (AWS root) | Acceso root compromete toda la infraestructura: puede eliminar RDS, S3, VPC. Irreversible. |
| A-03 (Secrets Manager) | Contiene passwords de BD, JWT secret, API keys. Si se filtra, compromete todos los servicios. |
| A-12 (KMS) | Usado para cifrar RDS y S3. Sin las claves, los backups cifrados son ilegibles. |
| A-04 (S3) | Fotos de entrega y firmas son evidencia legal de contratos de servicio. |

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
| R-01 | Acceso no autorizado a RDS | Puerto 5432 expuesto o credenciales débiles | A-01 | 3 | 5 | **15** | Alto | RDS en subnet privada sin acceso público; Secrets Manager para credenciales |
| R-02 | Compromiso de cuenta AWS root | Root sin MFA, credenciales filtradas | A-07 | 2 | 5 | **10** | Alto | MFA obligatorio en root; no usar root para operaciones diarias |
| R-03 | Inyección SQL en la API | Parámetros de query no sanitizados | A-01 | 3 | 4 | **12** | Alto | Panache/PreparedStatements; WAF SQL injection ruleset |
| R-04 | Filtración de datos en S3 | Bucket público accidentalmente | A-04 | 2 | 4 | **8** | Medio | S3 Block Public Access; bucket policy estricta; URLs presignadas |
| R-05 | Ataque de fuerza bruta a login | Sin rate limiting ni bloqueo temporal | A-08 | 4 | 3 | **12** | Alto | Rate limiting en API; bloqueo Redis tras 5 intentos |
| R-06 | Robo de JWT activo (token theft) | Token de larga duración interceptado | A-08 | 2 | 4 | **8** | Medio | Access token 1h; refresh token en cookie HttpOnly; TLS 1.3 |
| R-07 | DDoS a la API pública | Sin protección de capa 7 | A-05 | 3 | 3 | **9** | Medio | AWS Shield Standard (gratuito); WAF rate-based rule |
| R-08 | Fuga de secretos en código | `.env` o API keys commiteadas a GitHub | A-03 | 3 | 5 | **15** | Alto | Secrets Manager; GitHub secret scanning; `.gitignore` |
| R-09 | Suplantación de organización (fake RUC) | Sin validación real de RUC | A-01 | 4 | 3 | **12** | Alto | Integración con API SUNAT; verificación manual por operador |
| R-10 | Pérdida total de datos | Sin backups probados | A-01, A-04 | 2 | 5 | **10** | Alto | RDS automated backups + S3 Versioning; prueba mensual de restauración |
| R-11 | Acceso SSH directo a EC2 | Puerto 22 expuesto en internet | A-05 | 3 | 4 | **12** | Alto | Bastion Host + SSH solo desde IP fija; AWS SSM Session Manager |
| R-12 | Supply chain — dependencia comprometida | Librería Java/NPM maliciosa | A-02, A-05 | 2 | 4 | **8** | Medio | OWASP Dependency Check en CI; Dependabot alertas |
| R-13 | Insider threat — equipo | Commit malicioso o filtración interna | A-02 | 2 | 4 | **8** | Medio | Branch protections; PR reviews; auditoría de accesos |
| R-14 | Exfiltración de datos de clientes | Empleado con acceso excesivo a BD | A-01 | 2 | 5 | **10** | Alto | RLS por org_id; roles mínimo privilegio; audit_log en BD |
| R-15 | Interrupción del servicio ORS | Dependencia de API de tercero | A-05 | 3 | 2 | **6** | Medio | Cache de rutas en Redis; fallback a cálculo estimado |

### 2.3 Mapa de calor de riesgos

```
Impacto →
         1         2         3         4         5
P  5 |   -    |   -    |   -    |   -    |   -    |
r  4 |   -    |   -    | R-05   |   -    |   -    |
o  3 |   -    |   -    | R-07   | R-03   | R-01   |
b  2 |   -    | R-15   |   -    | R-04,06| R-02   |
   1 |                 R-12,R-13,R-14 dispersos            |
      ─────────────────────────────────────────────
      Bajo       Bajo     Medio    Alto    Crítico
```

**Riesgos prioritarios (tratamiento inmediato):**
- R-01: RDS expuesto → CRÍTICO
- R-08: Fuga de secretos → CRÍTICO  
- R-03: Inyección SQL → ALTO
- R-05: Brute force → ALTO
- R-11: SSH expuesto → ALTO

---

## Sección 3 — Políticas de Seguridad

### POL-01: Política de Control de Acceso e Identidad (IAM)

**Alcance:** Todos los recursos AWS y usuarios del sistema.

| Regla | Detalle |
|-------|---------|
| Sin uso de cuenta root | La cuenta root AWS se usa exclusivamente para configuración inicial. MFA obligatorio. |
| Usuarios IAM individuales | Cada miembro del equipo tiene su propio usuario IAM. Sin usuarios compartidos. |
| Principio de mínimo privilegio | Cada IAM role tiene solo los permisos que necesita. Sin `AdministratorAccess` en producción. |
| MFA obligatorio | MFA activado en todos los usuarios IAM con acceso a consola. |
| Rotación de credenciales | Access keys rotan cada 90 días. Secrets Manager gestiona rotación de credenciales de BD. |
| Revisión trimestral de accesos | Auditar qué usuarios tienen qué permisos cada 3 meses. Revocar lo que no se usa. |

**Roles IAM definidos:**

| Rol IAM | Permisos | Asignado a |
|---------|----------|-----------|
| `logyx-ec2-role` | S3 read/write (bucket logyx-docs), Secrets Manager read, SSM, CloudWatch | EC2 instances |
| `logyx-rds-role` | KMS decrypt (para cifrado RDS) | RDS service |
| `logyx-cicd-role` | ECR push, ECS deploy, S3 deploy | GitHub Actions OIDC |
| `logyx-readonly-role` | CloudWatch read, RDS describe | Monitoreo / auditoría |
| `logyx-dev-role` | S3 staging, RDS staging (no prod) | Developers en staging |

### POL-02: Política de Cifrado

| Ámbito | Mecanismo | Estándar |
|--------|-----------|---------|
| Datos en tránsito (web/API) | TLS 1.3 en ALB + CloudFront | AWS Certificate Manager (ACM) |
| Datos en tránsito (BD) | SSL en conexión RDS (sslmode=require) | PostgreSQL SSL |
| Datos en reposo (RDS) | AES-256 con KMS CMK | AWS KMS |
| Datos en reposo (S3) | SSE-KMS con CMK logyx-s3-key | AWS KMS |
| Contraseñas de usuario | bcrypt cost=12 | No reversible |
| Secretos de aplicación | AWS Secrets Manager (cifrado KMS) | AWS KMS |
| Backups | Cifrado con KMS antes de almacenar | AWS KMS |

### POL-03: Política de Backup y Recuperación

| Tipo de backup | Frecuencia | Retención | Verificación |
|---------------|-----------|-----------|-------------|
| RDS automated backup | Diario (02:00 UTC-5) | 30 días | Prueba mensual de restauración en staging |
| RDS snapshot manual | Antes de cada deploy mayor | 90 días | Al crear |
| S3 versioning | Continuo (por objeto) | 90 días (lifecycle rule) | Aleatorio mensual |
| CloudWatch logs | Continuo | 90 días en CW; 1 año en S3 Glacier | — |
| Secrets Manager | Versionado automático | Indefinido (versiones anteriores) | — |

**RTO/RPO:**
- RPO (máx. pérdida de datos): < 1 hora (RDS automated backup + binlog continuo)
- RTO (tiempo de recuperación): < 2 horas (restore + health checks)

### POL-04: Política de Gestión de Vulnerabilidades

| Actividad | Frecuencia | Responsable |
|-----------|-----------|-------------|
| Escaneo OWASP Dependency Check | En cada PR (CI) | Fabrizio S. |
| Revisión de CVEs críticos (NVD) | Semanal | Alex C. |
| Actualizaciones de OS en EC2 (SSM Patch Manager) | Mensual (ventana mantenimiento: domingo 03:00) | Alex C. |
| Prueba de penetración controlada (Wazuh + Kali) | Trimestral (S2) | Equipo |
| Revisión de Security Hub findings | Mensual | Jorge G. |

### POL-05: Política de Acceso Remoto

| Regla | Implementación |
|-------|---------------|
| Sin SSH directo desde internet | Puerto 22 bloqueado en `sg-backend` desde 0.0.0.0/0 |
| Acceso SSH solo vía Bastion Host | Bastion en subnet pública, solo acepta SSH desde IP fija del equipo |
| Alternativa preferida: SSM Session Manager | No requiere SSH abierto; acceso auditado via CloudTrail |
| VPN para acceso a consola AWS en redes públicas | Usar VPN personal antes de acceder a consola desde redes no confiables |

### POL-06: Política de Clasificación y Manejo de Datos

| Clasificación | Ejemplos en LOGYX | Control |
|--------------|-------------------|---------|
| **Público** | Rutas disponibles, precios de mercado (anonimizados) | Sin restricciones |
| **Interno** | Métricas de uso, logs de sistema | Solo acceso interno |
| **Confidencial** | RUC, DNI, datos de contratos, precios acordados | Cifrado, acceso por rol |
| **Altamente confidencial** | Credenciales, JWT secrets, claves KMS | Solo AWS Secrets Manager, sin logging del valor |

---

## Sección 4 — Roles y Responsabilidades

### 4.1 Organigrama de seguridad

```
┌─────────────────────────────────────┐
│  Responsable de Seguridad           │
│  Jorge Gutiérrez Miranda            │
│  • Decisiones de arquitectura       │
│  • Gestión de cuenta root AWS       │
│  • Revisión de políticas            │
└────────────────┬────────────────────┘
                 │
    ┌────────────┴──────────────┐
    │                           │
┌───▼──────────────┐   ┌───────▼──────────────┐
│ Seguridad de     │   │ Operaciones e        │
│ Infraestructura  │   │ Implementación       │
│ Alex Coila Jarita│   │ Fabrizio Sanchez     │
│ • VPC / SGs      │   │ • CI/CD pipeline     │
│ • KMS / IAM      │   │ • Monitoring alerts  │
│ • Backup / RDS   │   │ • Incident response  │
│ • Patch Manager  │   │ • Log analysis       │
└──────────────────┘   └──────────────────────┘
```

### 4.2 Matriz RACI de Seguridad

| Actividad | Jorge G. | Alex C. | Fabrizio S. |
|-----------|----------|---------|-------------|
| Definir políticas de seguridad | **R** | C | I |
| Gestionar cuenta AWS root | **R** | I | I |
| Configurar VPC y Security Groups | C | **R** | I |
| Gestionar IAM roles y usuarios | **R** | C | I |
| Configurar KMS y cifrado | I | **R** | C |
| Configurar RDS y backups | C | **R** | I |
| Implementar WAF rules | C | **R** | C |
| Configurar CloudWatch alarmas | I | C | **R** |
| Configurar Wazuh IDS | I | **R** | C |
| Responder a incidentes de seguridad | **A** | **R** | C |
| Ejecutar dependency check (CI) | I | I | **R** |
| Auditar accesos IAM (trimestral) | **R** | C | I |
| Documentar procedimientos de seguridad | C | C | **R** |

*R = Responsable · A = Aprobador · C = Consultado · I = Informado*

### 4.3 Procedimiento de respuesta a incidentes

| Fase | Actividad | Responsable | Tiempo máximo |
|------|-----------|-------------|---------------|
| **Detección** | Alerta en CloudWatch / Wazuh / GuardDuty | Fabrizio S. | — |
| **Clasificación** | Determinar severidad (Baja/Media/Alta/Crítica) | Fabrizio S. | 15 min |
| **Contención** | Bloquear IP, revocar credenciales, aislar EC2 | Alex C. | 30 min |
| **Erradicación** | Parchear vulnerabilidad, rotar secretos | Alex C. | 4 h |
| **Recuperación** | Restaurar servicio, verificar integridad | Equipo | 2 h |
| **Lecciones** | Documentar en informe post-mortem | Jorge G. | 48 h |

---

## Anexos

### Anexo A — Matriz de riesgos completa (ISO 27005)

| ID | Riesgo | Activo | P | I | R | Tratamiento | Estado |
|----|--------|--------|---|---|---|-------------|--------|
| R-01 | RDS expuesto | A-01 | 3 | 5 | 15 | Subnet privada + sg-rds | Diseñado |
| R-02 | Root sin MFA | A-07 | 2 | 5 | 10 | MFA habilitado | Pendiente |
| R-03 | Inyección SQL | A-01 | 3 | 4 | 12 | PreparedStatements + WAF | Diseñado |
| R-04 | S3 público | A-04 | 2 | 4 | 8 | Block Public Access | Diseñado |
| R-05 | Brute force | A-08 | 4 | 3 | 12 | Rate limit + Redis | Diseñado |
| R-06 | Token theft | A-08 | 2 | 4 | 8 | TLS + short expiry | Diseñado |
| R-07 | DDoS | A-05 | 3 | 3 | 9 | Shield + WAF | Diseñado |
| R-08 | Fuga secretos | A-03 | 3 | 5 | 15 | Secrets Manager | Diseñado |
| R-09 | Fake RUC | A-01 | 4 | 3 | 12 | SUNAT API | Diseñado |
| R-10 | Sin backup | A-01 | 2 | 5 | 10 | RDS backup + prueba | Diseñado |
| R-11 | SSH expuesto | A-05 | 3 | 4 | 12 | Bastion + SSM | Diseñado |
| R-12 | Supply chain | A-02 | 2 | 4 | 8 | Dependency Check | Diseñado |
| R-13 | Insider | A-02 | 2 | 4 | 8 | PR reviews + audit | Diseñado |
| R-14 | Exfiltración | A-01 | 2 | 5 | 10 | RLS + audit_log | Diseñado |
| R-15 | ORS caído | A-05 | 3 | 2 | 6 | Cache Redis | Diseñado |

### Anexo B — Referencias a estándares

| Estándar | Aplicación |
|---------|-----------|
| ISO/IEC 27001:2022 | Marco general de SGSI — estructura de políticas |
| ISO/IEC 27005:2022 | Metodología de análisis y gestión de riesgos |
| NIST SP 800-30 Rev.1 | Guía de evaluación de riesgos — escala P × I |
| NIST SP 800-53 | Controles de seguridad de referencia |
| AWS Well-Architected — Security Pillar | Aplicación práctica en cloud AWS |
| CIS AWS Foundations Benchmark | Checklist de configuración segura de AWS |
| OWASP Top 10 | Vulnerabilidades web críticas — mitigadas con WAF |

---

*LOGYX · S1 Entregable 2 · Planificación de Seguridad · Competencia C2.1 · Junio 2026*
