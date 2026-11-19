# E2 — Base de Datos del Sistema

**Competencia evaluada:** CE022 (Ingeniería de la Información)

Este entregable corresponde al diseño, implementación y operación de la base de datos del sistema en producción. La rúbrica **no** evalúa interfaz ni lógica de negocio — evalúa la calidad, consistencia, seguridad y eficiencia de los datos.

## Contenido

- [**Modelo de Datos**](modelo-datos.md) — 57 tablas (V1–V24; detalle de las 24 de V1–V12), diagramas ER, diccionario de datos
- [**Scripts SQL**](scripts.md) — Migraciones Flyway reales: DDL, RLS, funciones y trigger
- [**Seguridad y Administración**](seguridad.md) — Roles de mínimo privilegio, RLS implementado, auditoría, backup y optimización

## Rúbrica Nivel 3 — CE022 (EPE)

| Criterio | Excelente | Bueno | Regular | Deficiente |
|---|---|---|---|---|
| Modelado de datos | Modelo consistente, normalizado y alineado | Modelo adecuado | Modelo incompleto | Modelo incorrecto |
| Integridad y consistencia de datos | Integridad referencial completa | Integridad funcional | Problemas de consistencia | Datos inconsistentes |
| Implementación y consultas SQL | Consultas correctas y eficientes | Consultas funcionales | Consultas deficientes | Sin consultas |
| Programación de base de datos | Uso adecuado de lógica en BD | Uso funcional | Uso limitado | No hay programación |
| Seguridad y administración | Control de accesos y seguridad definidos | Seguridad básica | Seguridad parcial | Sin seguridad |
| Rendimiento y optimización | Índices y consultas optimizadas | Rendimiento aceptable | Problemas de rendimiento | Sistema ineficiente |
