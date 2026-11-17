# Área de Infraestructura Tecnológica

**Competencia general:** Diseña y ejecuta proyectos de infraestructura tecnológica para contribuir en la solución de problemas de la organización siguiendo estándares internacionales, presentando formalmente sus resultados con una actitud ética alineada a la **ACM**.

!!! info "Rediseño de la infraestructura: de AWS a un VPS Hostinger"
    La versión 1.0 de esta área diseñó el despliegue sobre AWS (VPC multi-AZ, EC2, RDS, S3, CloudFront). Con el sistema construido y el rebrand a **OnCargo**, la infraestructura se rediseñó por **costo y simplicidad**: un **VPS Hostinger KVM 2** (2 vCPU, 8 GB RAM, 100 GB NVMe, datacenter en Brasil) con Docker Compose y **Caddy** (HTTPS automático), documentos y backups en **Cloudflare R2**, y DNS/CDN en **Cloudflare** para el dominio `oncargo.tech`. Todos los documentos de esta área reflejan ese diseño; el detalle del cambio, con el antes y el después, está en [Rebrand OnCargo y migración a Hostinger](../software/cambios-diseno-inicial.md#7-rebrand-oncargo-y-migracion-a-hostinger).

## Competencias específicas

| Competencia | Nombre | Enfoque |
|---|---|---|
| **C1** | Conectividad | Diseña, implementa y valida infraestructuras de red organizacionales: segmentación, disponibilidad, rendimiento y cumplimiento normativo |
| **C2** | Gestión de la Seguridad de la Información | Planifica e implementa controles de seguridad basados en ISO 27001 y NIST: protección de activos, gestión de riesgos, continuidad operativa |
| **C3** | Implementación de Centro de Datos | Diseña y despliega servicios de infraestructura y datacenter: virtualización, almacenamiento, alta disponibilidad y monitoreo |

## Organización por semestre

- **[Semestre 1 · Diseño](semestre-1/index.md)** (marzo–junio) — Diseño de red, planificación de seguridad, diseño de centro de datos
- **[Semestre 2 · Implementación](semestre-2/index.md)** (agosto–noviembre) — Implementación y testing de red, implementación/monitoreo/ética de seguridad, implementación y control de datacenter

!!! info "Productos finales por semestre"
    Cada semestre culmina en un documento consolidado que integra los tres entregables: **Documento Consolidado de Diseño Preliminar** (Semestre 1) e **Informe de Implementación Integral y Operativa** (Semestre 2), ambos con declaración de cumplimiento ético ACM.
