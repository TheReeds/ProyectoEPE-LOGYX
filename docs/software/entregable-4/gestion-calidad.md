# E4 — Gestión del Desarrollo y Matriz de Calidad

> Competencia CE024 · Gestión técnica del desarrollo, métricas y auditoría estructurada
> Proyecto: OnCargo — Sistema Operativo Logístico Colaborativo para PYMEs
> Equipo: Jorge Gutiérrez Miranda · Fabrizio Sanchez Saravia · Alex Coila Jarita
> Versión: 1.0 · 19-nov-2026 · Fuente: repositorio `oncargo-code` (commit `848ba00`)

!!! info "Qué agrega este documento"
    Completa el [Backlog](backlog.md), el [Plan de Pruebas](plan-pruebas.md) y la [Auditoría](auditoria.md) con cuatro piezas que pide la rúbrica de CE024 y que no estaban escritas:

    1. la comparación de marcos de trabajo que justifica Scrum;
    2. la evolución medida del desarrollo (pruebas y alcance por entrega);
    3. una matriz de calidad ISO/IEC 25010 con métricas, objetivos y estado;
    4. una autoevaluación de madurez de procesos con CMMI-DEV nivel 2, junto con indicadores de *code smells*.

    Todas las cifras salen del repositorio o de los mensajes de *commit* verificados. Lo que no se ha medido se declara como pendiente.

---

## 1. Comparación de marcos de trabajo

| Criterio | Scrum | Kanban | XP (Extreme Programming) | Cascada |
|---|---|---|---|---|
| Unidad de planificación | Sprint de duración fija con objetivo | Flujo continuo con límite de trabajo en curso | Iteraciones cortas con historias | Fases secuenciales |
| Roles | Product Owner, Scrum Master, equipo | Sin roles prescritos | Cliente en el sitio, programadores | Jefe de proyecto y especialistas |
| Manejo de cambios | Entre sprints, por el backlog | En cualquier momento | En cualquier iteración | Costoso: requiere rehacer fases |
| Prácticas técnicas | No las prescribe | No las prescribe | TDD, programación en pares, integración continua | No las prescribe |
| Encaje con un equipo de 3 a tiempo parcial | Bueno, con ceremonias livianas | Bueno | Parcial: el cliente en el sitio no es posible | Bajo |
| Encaje con un semestre académico con hitos | **Alto**: los sprints calzan con los entregables | Medio: no tiene cortes naturales | Medio | Medio: rígido ante requisitos que cambian |

**Decisión: Scrum adaptado a tres personas, con prácticas técnicas de XP y visualización Kanban.**

- **Scrum** da el marco: backlog con 15 épicas y 77 historias, 8 sprints planificados de dos semanas alineados con los hitos del EPE y una *Definition of Done* (código + pruebas + CI en verde + documentación).
- **De XP se tomaron** la integración continua (5 workflows), las pruebas automatizadas como requisito para cerrar una historia y la refactorización continua, verificada por `ModuleBoundariesTest`.
- **De Kanban, el flujo:** en la ejecución el trabajo se organizó por fases y por «olas» de entrega sobre el monorepo, con zonas de trabajo paralelas (sección 2). Es un ajuste habitual cuando las épicas dependen unas de otras.
- **Cascada se descartó** porque los requisitos cambiaron al construir: lo muestran RF68–RF90 en el [SRS](../entregable-1/srs.md) y los ADR 0009–0014.

**Roles:** el equipo debe confirmar quién ejerció de *Product Owner* y de *Scrum Master*. El Project Charter de Gestión de TI nombra a Fabrizio Sánchez como director del proyecto.

---

## 2. Evolución medida del desarrollo

El historial del monorepo empieza el 10-nov-2026, cuando se consolidó. Cada entrega registra en su *commit* las pruebas que pasaron, así que esa es la serie verificable de avance.

| Fecha | Entrega (*commit*) | Alcance principal | Pruebas del backend sin fallos |
|---|---|---|---|
| 10-nov-2026 | Fases 1–6 (`c6444d4` … `23fe5a9`) | Núcleo, negociación, documentos, reputación, incidencias, notificaciones, operador, viajes, outbox y tiempo real (V1–V12) | 182 |
| 16-nov-2026 | UI pública y huecos de flujo (`2975f7e`) | Verificación de organizaciones, retiro de ofertas, estado final al resolver incidencias, rutas por carretera (V13) | No registrado en el *commit* |
| 17-nov-2026 | Cuentas y roles (`b9f9579`) | Contraseñas, sesiones revocables, roles ADMIN/OPS/VIEWER, auditoría del operador (V14–V15) | 311 |
| 18-nov-2026 | Ola 1, tanda 1 (`b945dd3`) | Roles en la UI, avisos por persona, libreta de direcciones, búsqueda, parámetros y comisión (V16–V18) | 369 |
| 18-nov-2026 | Ola 1, tanda 2 (`2f291a1`) | Contactos por parada, seguimiento público, conductor sin señal, RN02 por fecha (V19–V20) | 404 |
| 19-nov-2026 | Ola 2 (`9279674`) | Plantillas recurrentes, preferidos, alertas de carga, documentos de flota, ajustes del envío, operador 360 (V21–V23) | 507 |
| 19-nov-2026 | Ola 2, zona F (`68a4c13`) | Cobros sin pasarela, reportes, tarifario, calendario y correo por preferencias (V24) | **564** |

**Lectura:** el alcance creció de 12 a 24 migraciones y de 76 a 242 operaciones de API, y las pruebas crecieron con él: ninguna entrega se integró con pruebas fallando. Cada *commit* registra además `astro check` y `build` de la web, la compatibilidad del contrato y, desde las cuentas y roles, `assembleDebug` y las pruebas unitarias de Android.

**Pendiente de evidencia:** la velocidad en puntos por sprint, el *burndown* y las retrospectivas del [Backlog](backlog.md) (secciones 6 y 7). Si el equipo tiene capturas del tablero o actas de retrospectiva, van ahí.

---

## 3. Matriz de calidad ISO/IEC 25010

Escala de estado: **Cumple** (objetivo alcanzado y medido) · **Parcial** (existe, pero falta medir o completar) · **Pendiente**.

| Característica | Subcaracterística | Métrica | Objetivo | Valor actual | Estado | Evidencia |
|---|---|---|---|---|---|---|
| Adecuación funcional | Completitud | RF implementados / RF originales | ≥ 75 % | 52 / 67 (78 %); 13 parciales; además RF68–RF90 implementados | Cumple | [SRS](../entregable-1/srs.md) |
| Adecuación funcional | Corrección | Reglas de negocio con prueba automatizada | 12 / 12 | 12 / 12 (RN01–RN12) | Cumple | Pruebas de dominio |
| Eficiencia de desempeño | Comportamiento temporal | Tiempo total de carga de la web desde Lima | < 2 s | 0.73 s (TTFB 0.38 s, 3 muestras) | Cumple | Infraestructura, Red T2 |
| Eficiencia de desempeño | Capacidad | Usuarios concurrentes del MVP | 500 | Sin prueba de carga | Pendiente | Plan de mejora, fase 1 |
| Eficiencia de desempeño | Uso de recursos | RAM en operación / disponible | < 50 % | ≈ 0.5 GB de 8 GB | Cumple | Infraestructura, Datacenter, Anexo A |
| Compatibilidad | Interoperabilidad | Cambios incompatibles del contrato OpenAPI | 0 | 0 (cada entrega: «contrato compatible») | Cumple | `contract.yml`, `backend.yml` |
| Usabilidad | Accesibilidad | Pantallas clave con axe sin violaciones serias (WCAG AA) | Todas las clave | 9 *specs* de accesibilidad e2e | Parcial | `web/tests/e2e/a11y*.spec.ts` |
| Fiabilidad | Disponibilidad | Disponibilidad mensual | ≥ 99 % | Estimada ≈ 99.5 %; sin monitor externo | Parcial | Infraestructura, Datacenter §3 |
| Fiabilidad | Recuperabilidad | Restauración probada de la BD | Mensual | SIM-1 ejecutado el 19-nov-2026 (restauración en 3 s, conteos idénticos) | Cumple | Infraestructura, Datacenter §2.3 |
| Seguridad | Confidencialidad | Tablas de negocio con RLS | 100 % | 56 / 57 tablas | Cumple | `pg_class.relrowsecurity` |
| Seguridad | Integridad | Escalada de privilegios de `logyx_api` | Imposible | Probado: `SET ROLE` denegado | Cumple | `RowLevelSecurityTest` y pruebas de privilegios |
| Seguridad | Autenticidad | Límites de intentos en login, registro y recuperación | Activos | Activos (50/IP, 10 fallos/correo; ventana 15 min) | Cumple | `application.properties` |
| Mantenibilidad | Modularidad | Violaciones de límites hexagonales | 0 | 0 en cada build | Cumple | `ModuleBoundariesTest` |
| Mantenibilidad | Capacidad de prueba | Cobertura de líneas del backend | ≥ 70 % | No medida | Pendiente | JaCoCo (plan de mejora) |
| Mantenibilidad | Analizabilidad | *Code smells* críticos | 0 | Sin análisis automático; indicadores manuales en §4.2 | Parcial | §4.2 |
| Portabilidad | Instalabilidad | Tiempo de reconstrucción del servidor | ≤ 2 h | Runbook documentado; reinicio verificado en ~2 min | Parcial | Infraestructura, Datacenter §4.3 |

**Resultado:** 10 cumple, 5 parcial y 2 pendientes (prueba de carga y cobertura). Las dos pendientes son la fase 1 del plan de mejora de la [Auditoría](auditoria.md).

---

## 4. Madurez de procesos y deuda técnica

### 4.1 Autoevaluación CMMI-DEV nivel 2 (estilo SCAMPI C)

Es una **autoevaluación interna e informal** (SCAMPI clase C): revisa evidencia, pero no la hace un evaluador certificado ni otorga un nivel oficial. La escala es Implementada · Parcial · No implementada · No aplica.

| Área de proceso (nivel 2) | Práctica esperada | Evidencia en OnCargo | Resultado |
|---|---|---|---|
| REQM · Gestión de requisitos | Requisitos entendidos, trazados y con cambios controlados | SRS con estado por RF y trazabilidad a módulos; RF68–RF90 y ADR registran los cambios | Implementada |
| PP · Planificación del proyecto | Estimación, cronograma y plan | 77 historias con puntos, 8 sprints y 294 puntos planificados; Project Charter y cronograma (Gestión de TI) | Implementada |
| PMC · Monitoreo y control | Seguimiento contra el plan y acciones correctivas | `docs/STATUS.md` por fase; pruebas por entrega (§2); sin *burndown* ni velocidad real | Parcial |
| SAM · Gestión de acuerdos con proveedores | Acuerdos con proveedores externos | No hay desarrollo subcontratado; Hostinger con términos estándar | No aplica |
| MA · Medición y análisis | Métricas definidas, recolectadas y usadas | Matriz §3, KPIs de seguridad, conteos por entrega; falta cobertura y carga | Parcial |
| PPQA · Aseguramiento de calidad | Verificación objetiva de procesos y productos | CI obligatorio por convención, revisión de contrato, auditoría técnica; sin protección de rama que lo haga obligatorio | Parcial |
| CM · Gestión de la configuración | Versionado, líneas base y control de cambios | Git, migraciones Flyway versionadas, contrato versionado, `deploy.sh` con vuelta atrás, `DEPLOYED` en el servidor | Implementada |

**Conclusión:** 3 áreas implementadas, 3 parciales y 1 no aplica. Para cumplir el nivel 2 completo faltan tres cosas:

1. **PMC:** registrar la velocidad real y una retrospectiva por entrega.
2. **MA:** medir cobertura y carga.
3. **PPQA:** activar la protección de rama en GitHub para que ningún cambio entre sin CI en verde.

### 4.2 Indicadores de *code smells*

No se ha corrido un analizador estático (SonarQube o similar), así que no hay un número oficial de *code smells*. Como indicador manual se midió el tamaño de los archivos, porque un archivo muy grande suele concentrar demasiadas responsabilidades (olor *Large Class* / *God Class*).

| Plataforma | Archivo más grande (`src/main`) | Líneas | Lectura |
|---|---|---|---|
| Android | `feature/loads/LoadsScreens.kt` | 1 251 | Varias pantallas en un archivo: dividir por pantalla |
| Android | `feature/driver/DriverScreen.kt` | 1 008 | Igual que el anterior |
| Android | `feature/loads/LoadsViewModels.kt` | 851 | Varios ViewModels juntos: separar |
| Web | `features/requests/components/RequestForm.tsx` | 487 | Formulario por pasos: extraer cada paso |
| Backend | `devdata/DemoDataSeeder.java` | 459 | Solo datos demo; riesgo bajo |
| Backend | `settlement/application/SettlementService.java` | 434 | Muchos casos de uso de cobro en un servicio: dividir por caso de uso |
| Backend | `operator/infrastructure/web/OperatorResource.java` | 406 | Muchos *endpoints* del operador en una clase: separar por recurso |

En el backend, ningún archivo de producción pasa de 460 líneas y el dominio no depende de Quarkus ni de JPA (verificado en cada build). La deuda de tamaño está sobre todo en las pantallas de Android.

**Acción propuesta (fase 1 del plan de mejora):**

- agregar SonarQube Cloud o Qodana al CI para tener *code smells*, duplicación y complejidad medidos;
- fijar el objetivo de 0 *blocker* y 0 *critical*;
- dividir los cinco archivos más grandes.

---

*OnCargo · E4 · Gestión del Desarrollo y Matriz de Calidad · CE024 · Versión 1.0 · Noviembre 2026*
