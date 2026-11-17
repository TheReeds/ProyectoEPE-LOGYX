# E1 — Documento del Sistema

**Competencia evaluada:** CE021 (Ingeniería de Requerimientos)

Este entregable integra la especificación completa del sistema: requerimientos, prototipos, arquitectura y modelado, **antes** de su construcción (SRS v1.0). La rúbrica **no** evalúa implementación ni funcionamiento — evalúa si el sistema está correctamente concebido y diseñado.

!!! info "Revisión posterior a la construcción"
    Tras construir el sistema, los documentos de este entregable se revisaron (SRS v1.1, Arquitectura v2.0, UML v2.0): conservan los requerimientos originales y agregan el estado de implementación y las decisiones reales (ADR 0001–0007).

## Contenido

- [**SRS** (IEEE 29148)](srs.md) — Requerimientos funcionales y no funcionales
- [**Prototipos**](prototipos.md) — Prototipos navegables y validados
- [**Arquitectura** (IEEE 42010 / Modelo C4)](arquitectura.md) — Estilo arquitectónico, ADR 0001–0007, evaluación de multitenancy, diagramas C4
- [**Modelado UML**](uml.md) — Casos de uso, clases, secuencia, estados
- [**Cambios respecto al diseño inicial**](../cambios-diseno-inicial.md) — qué cambió al construir el sistema y por qué

## Rúbrica Nivel 3 — CE021 (EPE)

| Criterio | Excelente (18–20) | Bueno (15–17) | Regular (13–14) | Deficiente (<13) |
|---|---|---|---|---|
| Completitud y claridad de requerimientos | SRS completo, claro y estructurado (RF, RNF, reglas, restricciones) | SRS mayormente completo | Requerimientos incompletos o ambiguos | Requerimientos deficientes |
| Coherencia entre requerimientos, prototipos y diseño | Prototipos y diseño reflejan fielmente los requerimientos | Coherencia general | Varias inconsistencias | No hay coherencia |
| Definición de arquitectura del sistema | Arquitectura clara, documentada y alineada al problema | Arquitectura funcional | Arquitectura parcial | No hay arquitectura |
| Modelado del sistema (UML) | Diagramas completos y coherentes | Modelado adecuado | Modelado incompleto | No hay modelado |
| Trazabilidad de requerimientos | Componentes rastreables a requerimientos | Trazabilidad parcial | Trazabilidad limitada | No hay trazabilidad |
| Validación con stakeholders | Evidencia clara de validación | Validación parcial | Validación limitada | No hay validación |
