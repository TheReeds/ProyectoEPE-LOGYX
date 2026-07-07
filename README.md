# LOGYX — Documentación EPE

Sitio de documentación de la Evaluación del Perfil de Egreso (EPE) del proyecto **LOGYX**, generado con [MkDocs](https://www.mkdocs.org/) + [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/).

Organizado por las tres áreas evaluadas del programa:

- **Área de Software** — Entregables E1–E5 (CE021–CE024, CE0217)
- **Área de Gestión de TI** — Entregables E1–E4 (CE0111–CE0135)
- **Área de Infraestructura** — Semestre 1 (diseño) y Semestre 2 (implementación) (C1–C3)

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
- `AreaSoftware/`, `AreaGestionTI/`, `AreaInfraestructura/`, `Guia*.md` — fuente original de la que se migró `docs/`; se conservan como archivo/respaldo y no se publican en el sitio

## Build de producción

```bash
mkdocs build --strict
```

El sitio publicado se despliega automáticamente a GitHub Pages vía el workflow en `.github/workflows/deploy-docs.yml` en cada push a `main`.
