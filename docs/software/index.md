# Área de Ingeniería de Software

**Competencia general (CE02):** Gestiona y desarrolla software de manera eficiente y efectiva, basándose en estándares internacionales de calidad a fin de lograr el control y aseguramiento de la calidad según el contexto de la organización.

El sistema OnCargo se construyó de forma progresiva: análisis del contexto, diseño de la solución, implementación y validación de funcionamiento, aplicando buenas prácticas de ingeniería de software y criterios de calidad alineados a **ISO/IEC 25010**.

El trabajo se organiza en cinco entregables progresivos (E1–E5), evaluados mediante rúbricas alineadas a las competencias específicas del programa.

## Competencias específicas

| Competencia | Nombre | Evalúa | Entregable |
|---|---|---|---|
| **CE021** | Ingeniería de Requerimientos | Define y diseña: elicita, analiza y documenta requerimientos, validándolos mediante prototipos y modelos estructurados | [E1 — Documento del Sistema](entregable-1/index.md) |
| **CE022** | Ingeniería de la Información | Persiste y administra datos: modela, implementa y administra bases de datos operacionales seguras y consistentes | [E2 — Base de Datos del Sistema](entregable-2/index.md) |
| **CE023** | Programación | Construye la solución: arquitecturas modulares, desacopladas y escalables, integrando servicios y componentes | [E3 — Sistema Desarrollado](entregable-3/index.md) |
| **CE024** | Calidad de Software | Asegura calidad y proceso: evaluación técnica, métricas y auditorías de calidad, plan de mejora | [E4 — Sistema Validado y Gestionado](entregable-4/index.md) |
| **CE0217** | Competencias transversales | Defensa integral del sistema ante jurado | [E5 — Video Pitch y Sustentación](entregable-5/index.md) |

## Stack técnico implementado

| Capa | Tecnología |
|---|---|
| Backend | Quarkus 3.40 (Java 21), monolito modular con arquitectura hexagonal, estilo bloqueante |
| Frontend Web | Astro 7 (SSR, adapter Node) + islas React + Tailwind 4 + shadcn/ui · MapLibre GL |
| Móvil | App Android nativa: Kotlin + Jetpack Compose + Material 3 (Ktor, Koin) · iOS (SwiftUI) planificado |
| Base de datos | PostgreSQL 16 con Row-Level Security · Flyway (V1–V12) |
| Archivos | Cloudflare R2 (API S3-compatible) en producción; disco local en dev/test |
| Tiempo real | Server-Sent Events (SSE) alimentado por un outbox transaccional |
| Contrato | OpenAPI generado por el backend (fuente de verdad de web y Android) |
| Infraestructura | VPS Hostinger KVM 2 · Docker (multi-stage) + Docker Compose · Caddy (TLS automático) · Cloudflare (DNS/CDN) · dominio `oncargo.tech` · CI en GitHub Actions |
| Mapas | MapLibre + OpenFreeMap (teselas OSM); rutas por carretera en el backend (ADR-0008), mapas pendientes |

!!! warning "El diseño inicial era distinto"
    Los documentos de la primera versión del EPE (Angular, tres apps Flutter, Redis, WebSocket, RLS sin implementar, despliegue en AWS) corresponden al **diseño previo a la construcción**. El sistema real evolucionó y esos cambios, con su justificación, están en **[Cambios respecto al diseño inicial](cambios-diseno-inicial.md)**; los entregables E1–E4 ya están alineados con el sistema construido.

!!! info "Trazabilidad entre entregables"
    La rúbrica CE021 exige **coherencia entre requerimientos, prototipos y diseño** (E1), que luego se refleja en el modelo de datos (E2), la implementación (E3) y se valida en E4. Cada página de entregable referencia explícitamente esta trazabilidad en su sección de "Coherencia del sistema".
