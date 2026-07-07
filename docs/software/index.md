# Área de Ingeniería de Software

**Competencia general (CE02):** Gestiona y desarrolla software de manera eficiente y efectiva, basándose en estándares internacionales de calidad a fin de lograr el control y aseguramiento de la calidad según el contexto de la organización.

El sistema LOGYX se construye de forma progresiva: análisis del contexto, diseño de la solución, implementación y validación de funcionamiento, aplicando buenas prácticas de ingeniería de software y criterios de calidad alineados a **ISO/IEC 25010**.

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
| Backend | Quarkus 3.x (Java 21) |
| Frontend Web | Angular 18+ |
| Mobile | Flutter 3.x |
| Base de datos | PostgreSQL 16 |
| Infraestructura | Docker + Docker Compose (dev) · Cloud (prod) |

!!! info "Trazabilidad entre entregables"
    La rúbrica CE021 exige **coherencia entre requerimientos, prototipos y diseño** (E1), que luego se refleja en el modelo de datos (E2), la implementación (E3) y se valida en E4. Cada página de entregable referencia explícitamente esta trazabilidad en su sección de "Coherencia del sistema".
