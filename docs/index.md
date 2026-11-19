# OnCargo — Documentación EPE

<p align="center" markdown>
![Logotipo de OnCargo](assets/img/OnCargo-web-fondo-claro.png#only-light){ width="320" }
![Logotipo de OnCargo](assets/img/OnCargo-web-fondo-oscuro.png#only-dark){ width="320" }
</p>

**OnCargo** (antes LOGYX) es una plataforma B2B que conecta PYMEs peruanas del corredor Lima–Sierra Sur (Lima–Arequipa–Juliaca–Puno–Cusco) con transportistas mediante un marketplace de fletes, subasta/negociación de tarifas, motor de costos, tracking y gestión documental y de reputación. La tesis del proyecto: la colaboración entre PYMEs fragmentadas puede replicar el poder de negociación logístico de una gran corporación.

Este sitio reúne la documentación de la **Evaluación del Perfil de Egreso (EPE)**, organizada según las tres áreas evaluadas del programa de Ingeniería de Sistemas de la Universidad Peruana Unión.

<p align="center" markdown>
[:material-presentation-play: Ver presentación del proyecto](presentacion.html){ .md-button .md-button--primary }
</p>

## Áreas de evaluación

<div class="grid cards" markdown>

- :material-laptop-account: **[Área de Software](software/index.md)**

    Entregables E1–E5. Especificación (SRS, prototipos, arquitectura, UML), base de datos con RLS, sistema implementado (Quarkus, Astro y Android/Kotlin), validación (pruebas, CI/CD, backlog, auditoría) y sustentación. Incluye [los cambios respecto al diseño inicial](software/cambios-diseno-inicial.md).

    Competencias: CE021–CE024, CE0217

- :material-strategy: **[Área de Gestión de TI](gestion-ti/index.md)**

    Entregables E1–E4. Diagnóstico organizacional y alineamiento estratégico, business case, plan de gestión del proyecto y modelado de procesos AS-IS/TO-BE.

    Competencia: CE01

- :material-server-network: **[Área de Infraestructura](infraestructura/index.md)**

    Semestre 1 (diseño de red, planificación de seguridad, diseño de centro de datos) y Semestre 2 (implementación y control de red, seguridad y datacenter).

    Competencias: C1–C3

</div>

## Stack del sistema implementado

| Capa | Tecnología |
|---|---|
| Backend | Quarkus 3.40 · Java 21 · arquitectura hexagonal modular |
| Web | Astro 7 (SSR) · islas React · Tailwind 4 · shadcn/ui · MapLibre |
| Móvil | Android nativo: Kotlin · Jetpack Compose (iOS/SwiftUI planificado) |
| Datos | PostgreSQL 16 con Row-Level Security (organizaciones aisladas en una BD compartida) · Flyway (24 migraciones, 57 tablas) · documentos en MinIO (S3-compatible) |
| Tiempo real | SSE sobre outbox transaccional |
| Mapas | MapLibre + OpenFreeMap; rutas por carretera en el backend y en los mapas web y Android ([ADR-0008](software/cambios-diseno-inicial.md#7-rebrand-oncargo-y-migracion-a-hostinger)) |
| Despliegue | VPS Hostinger KVM 2 (Brasil) · Docker Compose · Caddy (HTTPS automático) · DNS en Hostinger (dominio `oncargo.tech`; Cloudflare planificado) · GitHub Actions |

!!! note "Diseño inicial vs. sistema real"
    El diseño original del EPE (Angular, Flutter, Redis, WebSocket, despliegue en AWS) evolucionó durante la construcción. Ver [Cambios respecto al diseño inicial](software/cambios-diseno-inicial.md), que incluye el **rebrand a OnCargo** y la **migración de la infraestructura de AWS a un VPS Hostinger**.

## Recursos

| Recurso | Link |
|---|---|
| :material-file-document-multiple: Entregables PDF/DOCX — Software | [Drive](https://drive.google.com/drive/folders/1i53tJRzGlQJKzFkyocFTw7BqKLGSR9pS?usp=sharing) |
| :material-file-document-multiple: Entregables PDF/DOCX — Gestión de TI | [Drive](https://drive.google.com/drive/folders/1u4SWkKHHsdrup8Ap_6_YBXLzr1Vq7CHd?usp=sharing) |
| :material-file-document-multiple: Entregables PDF/DOCX — Infraestructura | [Drive](https://drive.google.com/drive/folders/1Up9sKYe7uLqgN7L3EcqbCTTgAxQTGWVz?usp=sharing) |
| :material-vector-square: Prototipo navegable (Figma) | [Ver en Figma](https://www.figma.com/proto/VPAgeR1zHUZCXKvBwKsYez/LOGYX-PROTOTIPOS?node-id=0-1&t=BFJbHyiHm6diGpam-1) |

## Equipo

Jorge Luis Gutiérrez Miranda · Fabrizio Yerald Alfonso Sánchez Saravia · Alex Coila Jarita

Universidad Peruana Unión — Facultad de Ingeniería y Arquitectura, Escuela de Ingeniería de Sistemas · Juliaca, Perú
