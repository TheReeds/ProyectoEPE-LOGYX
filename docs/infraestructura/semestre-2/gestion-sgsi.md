# S2 · Documentos de gestión del SGSI

> Competencias C2.2–C2.4 (soporte documental del SGSI) · Proyecto: OnCargo — Sistema Operativo Logístico Colaborativo para PYMEs
> Equipo: Jorge Gutiérrez Miranda · Fabrizio Sanchez Saravia · Alex Coila Jarita
> Semestre 2 · Noviembre 2026 · **Versión 1.0 (estado al 19-nov-2026, con la v2.3 de los entregables de implementación)**

!!! info "Qué reúne este documento"
    Los documentos de gestión que la norma ISO/IEC 27001 y la rúbrica piden y que no estaban en los entregables de implementación:

    1. alcance del SGSI (Sistema de Gestión de Seguridad de la Información) y exclusiones justificadas;
    2. inventario de activos con clasificación C-I-D;
    3. tratamiento de riesgos con riesgo residual;
    4. Declaración de Aplicabilidad (SoA) de los 93 controles del Anexo A;
    5. matriz de accesos por rol;
    6. informe de auditoría interna;
    7. acta de revisión por la dirección;
    8. declaración de ética y confidencialidad para firmar.

    Se basan en [Planificación de Seguridad (S1)](../semestre-1/planificacion-seguridad.md) y en el estado real descrito en [Red](implementacion-red.md), [Seguridad](implementacion-seguridad.md) y [Datacenter](implementacion-datacenter.md).

!!! warning "Valores propuestos"
    La clasificación C-I-D, los riesgos residuales y la asignación de accesos son una **propuesta que el equipo debe confirmar** en la revisión por la dirección (sección 7). No se incluyen IP, contraseñas, *tokens* ni datos personales reales.

---

## 1. Alcance del SGSI y exclusiones justificadas

**Declaración de alcance.** El SGSI de OnCargo cubre la plataforma desplegada en `oncargo.tech` y `api.oncargo.tech`:

- el VPS (Virtual Private Server, servidor privado virtual) Hostinger KVM 2 con Ubuntu 24.04 y su endurecimiento (`infra/vps/harden.sh`);
- los 5 contenedores Docker (`caddy`, `web`, `backend`, `db`, `minio`) y sus redes `edge` e `internal`;
- la base de datos PostgreSQL 16 y los documentos en MinIO;
- el dominio y la zona DNS (Domain Name System) en Hostinger;
- el repositorio de código y la integración continua en GitHub;
- las cuentas administrativas y los procesos de despliegue, respaldo, monitoreo y respuesta a incidentes.

**Fuera del alcance:** los equipos personales de los integrantes (salvo como origen del acceso administrativo), la infraestructura física del proveedor y los sistemas de los usuarios finales.

| Elemento de la rúbrica | Decisión | Justificación |
|---|---|---|
| VPN IPsec híbrida entre *on-premise* y nube | Excluida | La arquitectura tiene un solo sitio: no existe red local propia que unir con la nube. El tráfico público va cifrado con TLS y el acceso administrativo por SSH solo con clave, `AllowUsers` y fail2ban con `recidive`. Si se monta una VPN de administración con WireGuard, esta exclusión se reemplaza por su evidencia. |
| VMware ESXi y AWS | Sustituidos por equivalentes | La línea permite ajustar la tecnología si se mantiene la equivalencia técnica: KVM de Hostinger + Docker reemplazan al hipervisor y las VM; el VPS y las redes Docker, a la VPC y sus subredes. Costo aproximado: USD 13/mes frente a ~USD 333/mes en AWS, para un proyecto sin financiamiento. |
| Controles físicos (centro de datos, energía, cableado) | Transferidos al proveedor | El servidor es virtual y está en instalaciones de Hostinger; el equipo no tiene acceso físico. |
| Redundancia (Tier II o superior) | Aceptada como Tier I | Un solo servidor sin réplica: disponibilidad estimada ≈ 99.47 %, que cumple el ≥ 99 % del SRS. La redundancia queda en la hoja de ruta. |

---

## 2. Inventario de activos con clasificación C-I-D

Versión actualizada del inventario de la S1 (sin Cloudflare ni R2, que no están desplegados) y que sirve también como **inventario final** del centro de datos. **C** = Confidencialidad, **I** = Integridad, **D** = Disponibilidad (Alta, Media, Baja).

| ID | Activo | Tipo | Ubicación | Propietario | C | I | D | Criticidad | Evidencia |
|---|---|---|---|---|---|---|---|---|---|
| A-01 | Base de datos PostgreSQL 16 | Dato | VPS, contenedor `db`, volumen `pgdata`, red `internal` sin salida a Internet | Jorge G. | Alta | Alta | Alta | Crítico | `docker compose ps`; roles de la base |
| A-02 | Código fuente (`oncargo-code`) | Software | GitHub | Jorge G. | Media | Alta | Media | Crítico | Repositorio y protección de ramas |
| A-03 | Secretos (`.env`, claves JWT, contraseña demo) | Dato | VPS, `/opt/oncargo/state/` (`700`, `.env` `600`) | Alex C. | Alta | Alta | Media | Crítico | `stat` de permisos, sin mostrar contenido |
| A-04 | Documentos y evidencias de entrega | Dato | VPS, MinIO, bucket `oncargo-documents` (privado, consola desactivada) | Alex C. | Alta | Alta | Media | Crítico | Petición anónima → `403` |
| A-05 | Servidor VPS Hostinger KVM 2 | Infraestructura | Hostinger | Alex C. | Media | Alta | Alta | Alto | Panel de Hostinger |
| A-06 | Dominio `oncargo.tech` y zona DNS | Infraestructura | Panel de Hostinger | Alex C. | Baja | Alta | Alta | Alto | Registros DNS (T1) |
| A-07 | Cuentas administrativas (Hostinger, GitHub) | Acceso | Hostinger y GitHub | Jorge G. | Alta | Alta | Media | Crítico | Captura del MFA activo (pendiente) |
| A-08 | Tokens JWT de sesión | Dato | Cookie `httpOnly` + `Secure` y app móvil | Fabrizio S. | Alta | Alta | Media | Alto | Configuración de la cookie |
| A-09 | Registros (`audit_log`, logs de contenedores, acceso de Caddy, journald, auditd) | Dato | VPS | Fabrizio S. | Media | Alta | Media | Alto | `ausearch -k oncargo_secrets`; log de Caddy |
| A-10 | Integración continua (GitHub Actions) | Software | GitHub | Fabrizio S. | Baja | Alta | Media | Medio | Ejecuciones en verde |
| A-11 | Documentación técnica | Información | GitHub (`ProyectoEPE-LOGYX`) | Jorge G. | Baja | Media | Media | Medio | Sitio de documentación |
| A-12 | Respaldos cifrados (age) | Dato | VPS, `/var/backups/oncargo` (14 días); identidad privada fuera del VPS | Alex C. | Alta | Alta | Alta | Crítico | `oncargo-backup list` y `verify` |

---

## 3. Tratamiento de riesgos y riesgo residual

Completa la matriz de la S1 con **tratamiento, responsable, plazo y riesgo residual**. Inherente = P × I antes de los controles (valores de la S1). Escala: 1–4 bajo, 5–9 medio, 10–16 alto, 17–25 crítico.

| ID | Riesgo | Inherente | Tratamiento | Control aplicado o previsto | Responsable | Estado / plazo | Residual |
|---|---|---|---|---|---|---|---|
| R-01 | Acceso no autorizado a PostgreSQL | 3×5 = 15 | Mitigar | Sin puerto publicado; red `internal: true`; roles de mínimo privilegio; RLS | Alex C. | Implementado | 1×5 = 5 |
| R-02 | Compromiso de cuentas administrativas | 2×5 = 10 | Mitigar | MFA en Hostinger y GitHub; gestor de contraseñas | Jorge G. | Falta evidencia del MFA | 1×5 = 5 |
| R-03 | Inyección SQL en la API | 3×4 = 12 | Mitigar | Consultas parametrizadas (JPA); A3 con sqlmap | Alex C. | A3 pendiente | 1×4 = 4 |
| R-04 | Filtración de documentos | 2×4 = 8 | Mitigar | MinIO sin puertos ni consola; bucket privado; acceso solo por la API | Alex C. | Implementado | 1×4 = 4 |
| R-05 | Fuerza bruta al login | 4×3 = 12 | Mitigar | `AuthRateLimits`; fail2ban `oncargo-caddy-auth`; H-10 corregido en el código | Fabrizio S. | Desplegar `848ba00` | 2×3 = 6 |
| R-06 | Robo de JWT activo | 2×4 = 8 | Mitigar | Cookie `httpOnly` + `Secure` (H-02); acceso por IP redirige a HTTPS (H-01) | Alex C. | Implementado (v2.2) | 1×4 = 4 |
| R-07 | DDoS | 3×3 = 9 | Aceptar | Sin protección de borde; Cloudflare planificado | Jorge G. | Hoja de ruta | 3×3 = 9 |
| R-08 | Fuga de secretos en el código | 3×5 = 15 | Mitigar | Secretos generados en el VPS; contraseña demo propia (H-03); nada en Git | Alex C. | Implementado | 1×5 = 5 |
| R-09 | Suplantación de organización (RUC falso) | 4×3 = 12 | Mitigar | Verificación manual por el operador | Jorge G. | Implementado | 2×3 = 6 |
| R-10 | Pérdida total de datos | 3×5 = 15 | Mitigar | Respaldo diario cifrado, 14 días, `verify` ejecutado (SIM-1); falta copia fuera del VPS | Alex C. | R2 pendiente | Hoy 2×5 = 10; con copia externa 1×5 = 5 |
| R-11 | Acceso SSH no autorizado | 3×4 = 12 | Mitigar | Solo clave, `AllowUsers`, algoritmos modernos, fail2ban + `recidive`, auditd | Alex C. | Implementado (v2.2) | 1×4 = 4 |
| R-12 | Dependencia o imagen comprometida | 2×4 = 8 | Mitigar | Dependabot; MinIO fijado por *digest*; `cap_drop ALL`, `no-new-privileges`, `read_only` | Fabrizio S. | Implementado | 2×4 = 8 |
| R-13 | Amenaza interna | 2×4 = 8 | Mitigar | Revisión por PR; historial de Git; auditd sobre secretos y cuentas | Jorge G. | Implementado | 1×4 = 4 |
| R-14 | Exfiltración de datos de clientes | 2×5 = 10 | Mitigar | RLS por organización; la app no puede saltarse RLS | Alex C. | Implementado | 1×5 = 5 |
| R-15 | Caída de servicios de terceros | 3×2 = 6 | Aceptar | Rutas precalculadas | Jorge G. | — | 3×2 = 6 |
| R-16 | Falta de parches | 3×4 = 12 | Mitigar | `unattended-upgrades`; reinicio por kernel hecho (19-nov-2026); Lynis | Alex C. | Implementado | 1×4 = 4 |
| R-17 | Falla del proveedor (Hostinger) o de la región | 2×4 = 8 | Mitigar | Runbook de reconstrucción en otro VPS (DC §4.3) y `harden.sh` reproducible; falta la copia de respaldos fuera del proveedor | Alex C. | R2 pendiente | Hoy 2×4 = 8; con copia externa 1×4 = 4 |

**Resultado:** 16 de 17 riesgos quedan en nivel bajo o medio. **R-10** sigue alto hasta tener la copia fuera del VPS; **R-07** y **R-15** se aceptan por costo.

---

## 4. Declaración de Aplicabilidad (SoA)

Recorre los 93 controles del Anexo A de ISO/IEC 27001:2022. **Estados:** Implementado · Parcial · Planificado · Proveedor (lo cumple Hostinger o GitHub) · No aplica.
**Fuentes:** *Plan* = [Planificación de Seguridad](../semestre-1/planificacion-seguridad.md) · *Seg* = [Seguridad](implementacion-seguridad.md) · *Red* = [Red](implementacion-red.md) · *DC* = [Datacenter](implementacion-datacenter.md).

### 4.1 Controles organizacionales (5.1 a 5.37)

| Control | Aplica | Cómo se cumple | Estado | Evidencia |
|---|---|---|---|---|
| 5.1 Políticas de seguridad | Sí | POL-01 a POL-06 | Implementado | Plan |
| 5.2 Roles y responsabilidades | Sí | Organigrama y RACI | Implementado | Plan |
| 5.3 Segregación de funciones | Sí | Políticas (Jorge), infraestructura (Alex), CI/CD y monitoreo (Fabrizio) | Implementado | Plan |
| 5.4 Responsabilidades de la dirección | Sí | Aprobación de políticas y revisión por la dirección | Parcial | Sección 7 |
| 5.5 Contacto con autoridades | Sí | Autoridad de datos personales ante una brecha (Ley 29733) | Planificado | Plan |
| 5.6 Contacto con grupos de interés | Sí | Avisos de seguridad de GitHub y Ubuntu | Parcial | Seg §2 |
| 5.7 Inteligencia de amenazas | Sí | Revisión de CVE y Dependabot | Parcial | Seg §2 |
| 5.8 Seguridad en la gestión de proyectos | Sí | ADR y revisión por PR | Implementado | `docs/adr/` del código |
| 5.9 Inventario de activos | Sí | 12 activos con propietario | Implementado | Sección 2 |
| 5.10 Uso aceptable | Sí | Falta una política escrita de uso aceptable | Planificado | — |
| 5.11 Devolución de activos | Sí | Revocar claves y accesos al salir | Planificado | Sección 5 |
| 5.12 Clasificación de la información | Sí | POL-06 y C-I-D | Implementado | Plan · Sección 2 |
| 5.13 Etiquetado | No | Sin documentos físicos; la clasificación basta | No aplica | — |
| 5.14 Transferencia de información | Sí | HTTPS/TLS 1.2–1.3, HSTS; SSH para administrar | Implementado | Red T8–T9 |
| 5.15 Control de acceso | Sí | POL-01; UFW, `DOCKER-USER`, roles de BD y de aplicación | Implementado | Seg §1 |
| 5.16 Gestión de identidades | Sí | Usuario `deploy`; cuentas por persona; roles de BD | Implementado | Seg §1.1, §1.5 |
| 5.17 Información de autenticación | Sí | SSH con clave; bcrypt; contraseña demo propia; MFA en paneles | Parcial (falta evidencia de MFA) | Seg E13 |
| 5.18 Derechos de acceso | Sí | Matriz de accesos por rol | Implementado | Sección 5 |
| 5.19 Seguridad con proveedores | Sí | Hostinger y GitHub identificados | Parcial | Sección 1 |
| 5.20 Acuerdos con proveedores | Sí | Términos estándar aceptados | Parcial | — |
| 5.21 Cadena de suministro TIC | Sí | Dependabot; *digest* de MinIO; imágenes oficiales | Implementado | Seg §2.2–2.3 |
| 5.22 Seguimiento de proveedores | Sí | Estado del VPS en el panel | Parcial | — |
| 5.23 Servicios en la nube | Sí | VPS y GitHub con gestión de accesos | Implementado | Sección 1 |
| 5.24 Planificación de incidentes | Sí | Procedimiento de 6 fases | Implementado | Plan · Seg §1.9 |
| 5.25 Evaluación de eventos | Sí | Clasificación por severidad | Implementado | Plan |
| 5.26 Respuesta a incidentes | Sí | Runbook por niveles; incidente real del 19-nov (SMTP) resuelto | Implementado | DC §4.2, Anexo A |
| 5.27 Aprendizaje de incidentes | Sí | Nota del incidente SMTP y corrección `b44014a` | Implementado | DC Anexo A |
| 5.28 Recopilación de evidencias | Sí | `audit_log`, log de Caddy, journald, auditd | Implementado (v2.2) | Red §5.2 |
| 5.29 Seguridad durante una interrupción | Sí | Runbooks de incidente y reconstrucción | Implementado | DC §4.2–4.3 |
| 5.30 Preparación TIC para la continuidad | Sí | Respaldo + `verify`; reinicio probado; falta copia externa | Parcial | DC §2.3 |
| 5.31 Requisitos legales | Sí | Leyes 29733 y 30096 | Implementado | Seg §5.7 |
| 5.32 Propiedad intelectual | Sí | Licencias libres; atribución de OpenStreetMap | Implementado | Seg §5.6 |
| 5.33 Protección de registros | Sí | journald 1 GB/30 días; auditd; `audit_log` sin borrado desde la app | Implementado | Seg §0 |
| 5.34 Privacidad y datos personales | Sí | RLS, TLS, consentimiento en el registro | Implementado | Seg §5.5 |
| 5.35 Revisión independiente | Sí | Auditoría interna documental | Implementado | Sección 6 |
| 5.36 Cumplimiento de políticas | Sí | KPIs definidos, sin medir | Parcial | Seg §3.5 |
| 5.37 Procedimientos documentados | Sí | Runbooks de despliegue, incidente, reconstrucción y restauración | Implementado | DC §4 |

### 4.2 Controles de personas (6.1 a 6.8)

| Control | Aplica | Cómo se cumple | Estado | Evidencia |
|---|---|---|---|---|
| 6.1 Investigación de antecedentes | No | Equipo fundador de 3 estudiantes, sin contrataciones | No aplica | — |
| 6.2 Términos de empleo | No | No hay empleados | No aplica | — |
| 6.3 Concienciación y formación | Sí | Cursos de seguridad e infraestructura; guías del equipo | Parcial | — |
| 6.4 Proceso disciplinario | No | Sin relación laboral | No aplica | — |
| 6.5 Responsabilidades al salir | Sí | Revocar claves y accesos | Planificado | Sección 5 |
| 6.6 Acuerdos de confidencialidad | Sí | Declaración de ética y confidencialidad | Implementado al firmarla | Sección 8 |
| 6.7 Trabajo remoto | Sí | POL-05: SSH con clave; VPN personal en redes públicas | Implementado | Plan |
| 6.8 Notificación de eventos | Sí | Aviso al responsable de seguridad; alertas ntfy | Implementado | Plan · Seg E14 |

### 4.3 Controles físicos (7.1 a 7.14)

| Control | Aplica | Cómo se cumple | Estado |
|---|---|---|---|
| 7.1 Perímetros de seguridad física | Sí | Centro de datos de Hostinger | Proveedor |
| 7.2 Controles físicos de entrada | Sí | Centro de datos de Hostinger | Proveedor |
| 7.3 Seguridad de oficinas | No | El equipo no tiene oficina | No aplica |
| 7.4 Monitoreo de seguridad física | Sí | Centro de datos de Hostinger | Proveedor |
| 7.5 Amenazas físicas y ambientales | Sí | Centro de datos de Hostinger | Proveedor |
| 7.6 Trabajo en áreas seguras | No | Sin áreas seguras propias | No aplica |
| 7.7 Escritorio y pantalla limpios | Sí | Bloqueo de pantalla; ocultar secretos al compartir pantalla | Parcial |
| 7.8 Ubicación de equipos | Sí | Servidor en el proveedor | Proveedor |
| 7.9 Activos fuera de las instalaciones | Sí | Laptops con claves SSH: cifrado de disco y contraseña | Parcial |
| 7.10 Medios de almacenamiento | Sí | Respaldos cifrados con age; identidad privada en el gestor de contraseñas | Implementado |
| 7.11 Servicios de suministro | Sí | Energía y red del centro de datos | Proveedor |
| 7.12 Seguridad del cableado | Sí | Cableado del centro de datos | Proveedor |
| 7.13 Mantenimiento de equipos | Sí | Hardware del proveedor | Proveedor |
| 7.14 Eliminación segura de equipos | Sí | Discos del proveedor; rotación de respaldos a 14 días | Proveedor |

### 4.4 Controles tecnológicos (8.1 a 8.34)

| Control | Aplica | Cómo se cumple | Estado | Evidencia |
|---|---|---|---|---|
| 8.1 Dispositivos de usuario | Sí | Laptops con bloqueo y claves SSH protegidas | Parcial | — |
| 8.2 Accesos privilegiados | Sí | `deploy` con sudo; `AllowUsers`; `logyx_owner` solo para migraciones | Implementado | Seg §1.1, §1.5 |
| 8.3 Restricción de acceso a la información | Sí | RLS por organización; roles ADMIN/OPS/VIEWER | Implementado | `RowLevelSecurityTest` |
| 8.4 Acceso al código fuente | Sí | GitHub con acceso del equipo | Implementado | — |
| 8.5 Autenticación segura | Sí | SSH con clave; JWT RSA; cookie `Secure`; MFA en paneles | Parcial (evidencia de MFA) | Seg §1 |
| 8.6 Gestión de la capacidad | Sí | `mem_limit` por contenedor; `oncargo-health` vigila disco y memoria | Implementado | DC §3.3 |
| 8.7 Protección contra malware | Sí | Imágenes oficiales; validación de archivos; contenedores sin capacidades | Parcial | Seg §1.3 |
| 8.8 Vulnerabilidades técnicas | Sí | `unattended-upgrades`, Dependabot, Lynis (índice 65) | Implementado | Seg E12 |
| 8.9 Gestión de la configuración | Sí | `infra/vps/` y `harden.sh` idempotente versionados | Implementado | Repositorio |
| 8.10 Eliminación de información | Sí | Limpieza de eventos y tokens vencidos; rotación de respaldos | Implementado | DC §1.8 |
| 8.11 Enmascaramiento de datos | Sí | Tokens de URL redactados en el log de Caddy; datos demo | Implementado | Red §5.2 |
| 8.12 Prevención de fuga de datos | Sí | Bloqueo de contactos en textos libres; RLS | Parcial | — |
| 8.13 Copias de seguridad | Sí | Diario, cifrado, 14 días, `verify` ejecutado; sin copia externa | Parcial | DC §2.2–2.3 |
| 8.14 Redundancia | Sí | Tier I aceptado | Planificado | Sección 1 |
| 8.15 Registro (logging) | Sí | Logs rotados, log de Caddy, journald, auditd, `audit_log` | Implementado (v2.2) | Red §5.2 |
| 8.16 Actividades de monitoreo | Sí | `oncargo-health` cada 5 min + alertas ntfy; falta monitor externo | Parcial | DC §3.2 · Seg E14 |
| 8.17 Sincronización de relojes | Sí | NTP del sistema; zona America/Lima | Implementado | DC §1.2 |
| 8.18 Programas utilitarios privilegiados | Sí | `sudo` solo para `deploy` | Implementado | Seg §1.1 |
| 8.19 Instalación de software | Sí | Solo repositorios oficiales | Implementado | DC §1.3 |
| 8.20 Seguridad de redes | Sí | UFW (22/80/443) y `DOCKER-USER` como lista blanca | Implementado | Red §1.4 |
| 8.21 Seguridad de servicios de red | Sí | TLS, HSTS, cabeceras, `/q/*` cerrado | Implementado | Red T8, T13 |
| 8.22 Segregación de redes | Sí | `edge` e `internal` (`internal: true`); solo Caddy publica puertos | Implementado | Red T6 |
| 8.23 Filtrado web | No | El servidor no da navegación a usuarios internos | No aplica | — |
| 8.24 Uso de criptografía | Sí | TLS, bcrypt, JWT RSA, respaldos con age | Implementado | Seg §1.6 |
| 8.25 Desarrollo seguro | Sí | PR y CI con pruebas | Implementado | Workflows |
| 8.26 Requisitos de seguridad de aplicaciones | Sí | Requisitos no funcionales en el SRS | Implementado | SRS |
| 8.27 Arquitectura segura | Sí | Mínimo privilegio, defensa en capas, outbox | Implementado | ADR |
| 8.28 Codificación segura | Sí | Consultas parametrizadas; validación; errores sin detalles | Implementado | Código |
| 8.29 Pruebas de seguridad | Sí | Pruebas de RLS en CI; A5 y A8 ejecutados; A2–A4, A6, A7, A9 pendientes | Parcial | Seg §3.3 |
| 8.30 Desarrollo externalizado | No | Todo el desarrollo es del equipo | No aplica | — |
| 8.31 Separación de entornos | Sí | Local, CI y VPS separados; el VPS sigue con `DEMO_DATA=true` | Parcial | DC §1.5 |
| 8.32 Gestión de cambios | Sí | PR, Flyway versionado, `deploy.sh` con vuelta atrás | Implementado | DC §4.1 |
| 8.33 Información de prueba | Sí | Solo datos demo con contraseña propia del VPS | Implementado | Seg E13 |
| 8.34 Protección durante auditorías | Sí | Pruebas con autorización escrita y horario acordado | Implementado | Seg §3.2 |

**Resumen:** de 93 controles, **85 aplican** (9 los cumple el proveedor) y **8 no aplican** (5.13, 6.1, 6.2, 6.4, 7.3, 7.6, 8.23, 8.30).

---

## 5. Matriz de accesos por rol

Principio de mínimo privilegio; roles según la RACI de la S1. *El equipo debe confirmar la asignación actual.*

| Sistema | Responsable de seguridad (Jorge G.) | Administrador de infraestructura (Alex C.) | Operaciones y CI/CD (Fabrizio S.) | Método de acceso |
|---|---|---|---|---|
| Panel de Hostinger (VPS y DNS) | Administrador | Operador | Sin acceso | Correo, contraseña y MFA |
| VPS por SSH | Sin acceso habitual | Administrador (`deploy` con sudo) | Sin acceso habitual | Clave SSH personal; `AllowUsers` |
| BD `logyx_owner` (migraciones) | — | Solo en despliegues | — | Contraseña generada en el VPS |
| BD `logyx_api` (aplicación) | — | — | — | Solo el backend; sujeto a RLS |
| MinIO | — | Administrador | — | Solo red interna; sin consola |
| Identidad age de los respaldos | — | Custodio | — | Gestor de contraseñas, fuera del VPS |
| Tema de alertas ntfy | Suscrito | Suscrito | Suscrito | App ntfy; el tema no se publica |
| GitHub (repositorios) | Administrador | Escritura | Escritura | Cuenta personal con MFA |
| GitHub Actions y Dependabot | Lectura | Lectura | Administrador | Cuenta personal con MFA |
| Panel del operador de OnCargo | Operador | Operador | Operador | Cuenta de la aplicación (rol OPERATOR) |

**Reglas:** cada persona usa su propia cuenta y clave; revisión trimestral; al salir un integrante se retira su clave de `authorized_keys`, se le quita de GitHub y Hostinger y se rotan los secretos que conocía (auditd registra los cambios en `authorized_keys`).

---

## 6. Informe de auditoría interna (documental)

| Campo | Detalle |
|---|---|
| Tipo | Auditoría interna documental (cláusula 9.2 de ISO 27001) |
| Alcance | Sección 1 |
| Criterios | ISO/IEC 27001:2022 (SoA), POL-01 a POL-06, rúbrica CE03 |
| Método | Revisión de documentos, configuración versionada y evidencias de la v2.3; sin pruebas intrusivas |
| Auditor | Jorge Gutiérrez Miranda (responsable de seguridad) |
| Fecha | ____ / ____ / 2026 |

**No conformidades:**

| ID | Hallazgo | Requisito | Acción correctiva | Responsable | Estado |
|---|---|---|---|---|---|
| NC-01 | Los respaldos quedan en el mismo disco del VPS | 8.13 | Configurar la copia externa (R2, guía en `infra/vps/README.md`) | Alex C. | **Parcial**: automatización y SIM-1 ejecutados (19-nov-2026) |
| NC-02 | Pruebas y simulaciones sin ejecutar: T5 completo con Nmap, T10, T12, T14; A2–A4, A6, A7, A9 | Cláusula 9.1 · 8.29 | Ejecutarlas y guardar evidencia | Alex C. y Fabrizio S. | Abierta |
| NC-03 | MFA de Hostinger y GitHub sin evidencia | 5.17 · 8.5 | Verificar y capturar sin datos de la cuenta | Jorge G. | Abierta |
| NC-04 | Caddy sin log de accesos (H-09) | 8.15 | Snippet `access_log` | Alex C. | **Cerrada (v2.2)** |
| NC-05 | Sin monitoreo externo | 8.16 | UptimeRobot o latido a healthchecks.io | Fabrizio S. | **Parcial**: chequeo interno + alertas ntfy (v2.3) |

**Observaciones:**

| ID | Observación | Acción | Estado |
|---|---|---|---|
| OB-01 | Inventario de la S1 con Cloudflare y R2 | Actualizado en la sección 2 | Cerrada |
| OB-02 | H-10: límites por IP compartidos en la web | Corregido en el código (`848ba00`); desplegar y verificar con A9 | En curso |
| OB-03 | H-11: APK de *debug* en `/app/` | Variante *staging* firmada; *release* para producción | Cerrada para pruebas |
| OB-04 | H-03: contraseña demo publicada | Contraseña propia del VPS (v2.3) | Cerrada |
| OB-05 | KPIs de seguridad sin medir | Medirlos una vez al mes | Abierta |
| OB-06 | `DEMO_DATA=true` en el VPS | `false` y base nueva al pasar a producción | Aceptada en pruebas |
| OB-07 | MinIO con credenciales raíz | Usuario limitado al bucket | Abierta |
| OB-08 | Sin registro CAA ni Cloudflare | Configurar en el panel DNS | Abierta |

**Conclusión:** el diseño del SGSI es adecuado al tamaño del proyecto. Las no conformidades que quedan son de **evidencia y de decisiones con cuentas del responsable**, no de diseño.

---

## 7. Acta de revisión por la dirección

Cláusula 9.3 de ISO 27001: la dirección revisa los resultados del SGSI y decide qué cambiar. Cierra el ciclo PHVA (Planificar, Hacer, Verificar, Actuar).

| Campo | Detalle |
|---|---|
| Fecha y hora | ____ / ____ / 2026, ____ h |
| Modalidad | Presencial / virtual |
| Asistentes | Jorge Gutiérrez Miranda · Fabrizio Sanchez Saravia · Alex Coila Jarita |

**Temas revisados:**

1. Acciones de revisiones anteriores (primera revisión).
2. Cambios de contexto: migración de AWS al VPS; endurecimiento v2.2 y v2.3.
3. Auditoría interna: 5 no conformidades (1 cerrada, 2 parciales, 2 abiertas) y 8 observaciones.
4. Riesgos: 16 de 17 en nivel bajo o medio; R-10 alto hasta la copia externa.
5. Pruebas y monitoreo: SIM-1 ejecutado; T1–T4, T6–T9, T11, T13, T15, A5 y A8 ejecutados; el resto pendiente.
6. Recursos: sin presupuesto; se priorizan herramientas gratuitas.
7. Mejoras: Cloudflare, R2, réplica, VPN de administración con WireGuard.

**Decisiones:**

| N.º | Decisión | Responsable | Plazo |
|---|---|---|---|
| D-1 | Se aprueban el alcance, la SoA y la matriz de accesos | Jorge G. | En esta reunión |
| D-2 | Se aceptan formalmente R-07 y R-15 | Jorge G. | En esta reunión |
| D-3 | Cerrar NC-01, NC-02, NC-03 y NC-05 | Según la sección 6 | Antes de la sustentación |
| D-4 | Próxima revisión: tras ejecutar las pruebas o en 3 meses | Jorge G. | ____ / ____ / 2026 |

| Nombre | Rol | Firma |
|---|---|---|
| Jorge Gutiérrez Miranda | Responsable de seguridad | ______________________ |
| Fabrizio Sanchez Saravia | Operaciones y CI/CD | ______________________ |
| Alex Coila Jarita | Administrador de infraestructura | ______________________ |

---

## 8. Declaración de ética y confidencialidad

Complementa la [Sección 5 de Seguridad (Ética ACM)](implementacion-seguridad.md). Los integrantes de OnCargo declaramos que, en las actividades de infraestructura y seguridad, incluidas las pruebas y simulaciones de ataque:

1. Seguiremos el **Código de Ética de la ACM**: evitar daños, ser honestos y respetar la privacidad.
2. **Solo probaremos sistemas propios** (el VPS del proyecto y el *staging* local), con autorización escrita del responsable de seguridad y en el horario acordado.
3. Cumpliremos la **Ley 29733** (Protección de Datos Personales) y la **Ley 30096** (Delitos Informáticos).
4. **No usaremos datos personales reales** en pruebas ni evidencias.
5. **No publicaremos** contraseñas, claves, *tokens*, la IP del servidor, el tema de alertas ni otros datos sensibles.
6. Si encontramos una vulnerabilidad, la **reportaremos al equipo** y no la explotaremos fuera de la prueba autorizada.
7. Mantendremos la **confidencialidad** de la información del proyecto, también después de dejarlo.
8. Presentaremos resultados **reales y verificables**.

Juliaca, ____ de ______________ de 2026.

| Nombre | Rol | Firma |
|---|---|---|
| Jorge Gutiérrez Miranda | Responsable de seguridad | ______________________ |
| Fabrizio Sanchez Saravia | Operaciones y CI/CD | ______________________ |
| Alex Coila Jarita | Administrador de infraestructura | ______________________ |

---

*OnCargo · S2 · Documentos de gestión del SGSI · Versión 1.0 · Noviembre 2026*
