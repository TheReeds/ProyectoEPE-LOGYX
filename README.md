# OnCargo — Documentación EPE

Sitio de documentación de la Evaluación del Perfil de Egreso (EPE) del proyecto **OnCargo** (antes LOGYX; el repositorio y la URL de GitHub Pages conservan el nombre `ProyectoEPE-LOGYX`), generado con [MkDocs](https://www.mkdocs.org/) + [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/).

Organizado por las tres áreas evaluadas del programa:

- **Área de Software** — Entregables E1–E5 (CE021–CE024, CE0217), alineados con el sistema construido (Quarkus 3.40 + Astro 7 + Android/Kotlin, PostgreSQL 16 con RLS, SSE). Ver [Cambios respecto al diseño inicial](docs/software/cambios-diseno-inicial.md)
- **Área de Gestión de TI** — Entregables E1–E4 (CE0111–CE0135)
- **Área de Infraestructura** — Semestre 1 (diseño) y Semestre 2 (implementación) (C1–C3), rediseñada sobre un VPS Hostinger KVM 2 + Docker Compose + Caddy + MinIO, dominio `oncargo.tech` (Cloudflare y R2 planificados)

## Recursos

- Presentación del proyecto — [presentacion.html](https://thereeds.github.io/ProyectoEPE-LOGYX/presentacion.html)
- Entregables PDF/DOCX — [Software](https://drive.google.com/drive/folders/1i53tJRzGlQJKzFkyocFTw7BqKLGSR9pS?usp=sharing) · [Gestión de TI](https://drive.google.com/drive/folders/1u4SWkKHHsdrup8Ap_6_YBXLzr1Vq7CHd?usp=sharing) · [Infraestructura](https://drive.google.com/drive/folders/1Up9sKYe7uLqgN7L3EcqbCTTgAxQTGWVz?usp=sharing)
- Prototipo navegable — [Figma](https://www.figma.com/proto/VPAgeR1zHUZCXKvBwKsYez/LOGYX-PROTOTIPOS?node-id=0-1&t=BFJbHyiHm6diGpam-1)

## Desarrollo local

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
mkdocs serve
```

Abre `http://127.0.0.1:8000`.

## Estructura del repositorio

- `docs/` — contenido publicado del sitio (única carpeta que MkDocs procesa)
- `AreaSoftware/`, `AreaGestionTI/`, `AreaInfraestructura/`, `Guia*.md` — **fuentes de respaldo CONGELADAS** (noviembre 2026): son la versión original (v1.0, junio 2026, con la marca LOGYX y la infraestructura en AWS) de la que se migró `docs/` y **ya no se sincronizan**. La versión vigente es siempre `docs/`: allí el área de Software se alineó con el sistema real, se corrigieron las cifras de costos y del Business Case y se repararon las referencias cruzadas. No se publican en el sitio.

!!! note "Por qué congeladas y no sincronizadas"
    Mantener dos copias en paralelo duplicaría el trabajo y las dejaría inconsistentes; además el contenido de `docs/` ya no es una transcripción de esas fuentes (p. ej. UML, modelo de datos y sistema se reescribieron desde el código). Se conservan solo como historial del diseño inicial. **No las edites; edita `docs/`.**

## Fuente de verdad del software

El sistema real vive en el monorepo `logyx` (backend, web, android, infra, ADR en `docs/adr/`, contrato OpenAPI en `docs/api/`). Este sitio lo documenta; ante cualquier diferencia, manda el código y `docs/STATUS.md` de ese repositorio. Los diagramas y fragmentos mostrados aquí son extractos del código real; las migraciones SQL de [Scripts SQL](docs/software/entregable-2/scripts.md) se incluyen como *snapshot* en `docs/software/entregable-2/sql/`.

## Build de producción

```bash
mkdocs build --strict
```

El sitio publicado se despliega automáticamente a GitHub Pages vía el workflow en `.github/workflows/deploy-docs.yml` en cada push a `main`.
