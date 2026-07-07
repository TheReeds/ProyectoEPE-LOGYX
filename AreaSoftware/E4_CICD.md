# E4 — Repositorio Git y Pipeline CI/CD
> Competencia CE0242 · Historial Git verificable + Pipeline automatizado  
> Proyecto: LOGYX — Sistema Operativo Logístico Colaborativo para PYMEs  
> Equipo: Jorge Gutiérrez Miranda · Fabrizio Sanchez Saravia · Alex Coila Jarita  
> Versión: 1.0 · Junio 2026

---

## 1. Información General

| Campo | Detalle |
|-------|---------|
| **Plataforma Git** | GitHub |
| **Repositorio** | `github.com/[org]/logyx` *(agregar URL)* |
| **Herramienta CI/CD** | GitHub Actions |
| **Estrategia de ramas** | GitHub Flow (main + feature branches) |
| **Protección de rama main** | PR requerido + CI passing + 1 review |

---

## 2. Estrategia de Ramas

```
main                ← rama de producción, siempre desplegable
  ↑
  └── feature/auth-module          ← nueva funcionalidad
  └── feature/auction-engine       ← nueva funcionalidad
  └── fix/vehicle-capacity-check   ← corrección de bug
  └── docs/e1-srs                  ← actualizaciones de documentación
```

**Reglas:**
- No se hace commit directo a `main`
- Cada feature branch abre un Pull Request
- El PR solo puede mergearse si el pipeline CI pasa completamente
- Los commits siguen Conventional Commits: `feat:`, `fix:`, `test:`, `docs:`, `chore:`

---

## 3. Estructura del Pipeline CI/CD

### 3.1 Diagrama de flujo

```
Push a feature branch o PR hacia main
        │
        ▼
┌─────────────────────────────────────┐
│ Job 1: lint-and-build               │
│   • Checkstyle (Java)               │
│   • ESLint (Angular)                │
│   • flutter analyze                 │
│   • mvn compile (backend)           │
│   • ng build --prod (web)           │
│   • flutter build apk (driver)      │
└─────────────────────────────────────┘
        │ (si pasa)
        ▼
┌─────────────────────────────────────┐
│ Job 2: test-backend                 │
│   • Levanta Testcontainers (PG 16)  │
│   • mvn test (JUnit 5)              │
│   • Genera reporte de cobertura     │
└─────────────────────────────────────┘
        │ (en paralelo con Job 3)
        ▼
┌─────────────────────────────────────┐
│ Job 3: test-frontend                │
│   • ng test --no-watch (Karma)      │
│   • flutter test (unit + widget)    │
└─────────────────────────────────────┘
        │ (ambos deben pasar)
        ▼
┌─────────────────────────────────────┐
│ Job 4: deploy-staging               │
│   Solo en merge a main              │
│   • docker build + push a registry  │
│   • docker-compose up en servidor   │
│   • Smoke test (curl /q/health)     │
└─────────────────────────────────────┘
```

---

## 4. Archivo de Pipeline GitHub Actions

### 4.1 Pipeline principal — `.github/workflows/ci.yml`

```yaml
name: LOGYX CI/CD Pipeline

on:
  push:
    branches: [ main, 'feature/**', 'fix/**' ]
  pull_request:
    branches: [ main ]

env:
  JAVA_VERSION: '21'
  NODE_VERSION: '20'
  FLUTTER_VERSION: '3.22.0'

jobs:

  # ─────────────────────────────────────────
  # JOB 1: Lint y compilación
  # ─────────────────────────────────────────
  lint-and-build:
    name: Lint & Build
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      # ── Backend (Java / Quarkus) ──
      - name: Setup Java ${{ env.JAVA_VERSION }}
        uses: actions/setup-java@v4
        with:
          java-version: ${{ env.JAVA_VERSION }}
          distribution: 'temurin'
          cache: 'maven'

      - name: Checkstyle — Java
        working-directory: logyx-backend
        run: ./mvnw checkstyle:check

      - name: Compilar backend
        working-directory: logyx-backend
        run: ./mvnw compile -q

      # ── Frontend Web (Angular) ──
      - name: Setup Node.js ${{ env.NODE_VERSION }}
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
          cache-dependency-path: logyx-web/package-lock.json

      - name: Install Angular deps
        working-directory: logyx-web
        run: npm ci

      - name: ESLint — Angular
        working-directory: logyx-web
        run: npm run lint

      - name: Build Angular (producción)
        working-directory: logyx-web
        run: npm run build -- --configuration production

      # ── App Flutter Driver ──
      - name: Setup Flutter ${{ env.FLUTTER_VERSION }}
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}

      - name: Flutter analyze
        working-directory: logyx-mobile/logyx_driver
        run: flutter analyze --fatal-infos

      - name: Flutter build APK
        working-directory: logyx-mobile/logyx_driver
        run: flutter build apk --release --no-pub

  # ─────────────────────────────────────────
  # JOB 2: Tests backend con Testcontainers
  # ─────────────────────────────────────────
  test-backend:
    name: Test Backend
    runs-on: ubuntu-latest
    needs: lint-and-build

    services:
      redis:
        image: redis:7-alpine
        ports: [ '6379:6379' ]

    steps:
      - uses: actions/checkout@v4

      - name: Setup Java ${{ env.JAVA_VERSION }}
        uses: actions/setup-java@v4
        with:
          java-version: ${{ env.JAVA_VERSION }}
          distribution: 'temurin'
          cache: 'maven'

      - name: Ejecutar tests JUnit 5 con Testcontainers
        working-directory: logyx-backend
        env:
          JWT_SECRET: ${{ secrets.JWT_SECRET_TEST }}
          ORS_API_KEY: ${{ secrets.ORS_API_KEY_TEST }}
        run: |
          ./mvnw test \
            -Dquarkus.test.profile=test \
            -Dquarkus.datasource.devservices.enabled=true

      - name: Generar reporte de cobertura (JaCoCo)
        working-directory: logyx-backend
        run: ./mvnw jacoco:report

      - name: Subir reporte de cobertura
        uses: actions/upload-artifact@v4
        with:
          name: backend-coverage-report
          path: logyx-backend/target/site/jacoco/

      - name: Verificar cobertura mínima (70%)
        working-directory: logyx-backend
        run: |
          ./mvnw jacoco:check \
            -Djacoco.minimum.coverage=0.70

  # ─────────────────────────────────────────
  # JOB 3: Tests frontend (paralelo con Job 2)
  # ─────────────────────────────────────────
  test-frontend:
    name: Test Frontend
    runs-on: ubuntu-latest
    needs: lint-and-build

    steps:
      - uses: actions/checkout@v4

      # Angular unit tests
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
          cache-dependency-path: logyx-web/package-lock.json

      - name: Install Angular deps
        working-directory: logyx-web
        run: npm ci

      - name: Angular unit tests (Karma headless)
        working-directory: logyx-web
        run: |
          npm test -- \
            --no-watch \
            --no-progress \
            --browsers=ChromeHeadless \
            --code-coverage

      # Flutter unit + widget tests
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}

      - name: Flutter tests — logyx_driver
        working-directory: logyx-mobile/logyx_driver
        run: flutter test --coverage

      - name: Flutter tests — logyx_business
        working-directory: logyx-mobile/logyx_business
        run: flutter test --coverage

  # ─────────────────────────────────────────
  # JOB 4: Deploy a staging (solo en main)
  # ─────────────────────────────────────────
  deploy-staging:
    name: Deploy Staging
    runs-on: ubuntu-latest
    needs: [test-backend, test-frontend]
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    environment: staging

    steps:
      - uses: actions/checkout@v4

      - name: Login a Container Registry
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build y push imagen backend
        uses: docker/build-push-action@v5
        with:
          context: ./logyx-backend
          file: ./logyx-backend/src/main/docker/Dockerfile.jvm
          push: true
          tags: |
            ghcr.io/${{ github.repository }}/logyx-backend:latest
            ghcr.io/${{ github.repository }}/logyx-backend:${{ github.sha }}

      - name: Build y push imagen web
        uses: docker/build-push-action@v5
        with:
          context: ./logyx-web
          push: true
          tags: |
            ghcr.io/${{ github.repository }}/logyx-web:latest
            ghcr.io/${{ github.repository }}/logyx-web:${{ github.sha }}

      - name: Deploy en servidor staging
        uses: appleboy/ssh-action@v1
        with:
          host: ${{ secrets.STAGING_HOST }}
          username: ${{ secrets.STAGING_USER }}
          key: ${{ secrets.STAGING_SSH_KEY }}
          script: |
            cd /opt/logyx
            docker-compose pull
            docker-compose up -d --no-deps backend web
            docker-compose exec -T backend \
              curl -f http://localhost:8080/q/health/live || exit 1
            echo "Deploy completado: $(date)"

      - name: Smoke test — healthcheck
        run: |
          sleep 15
          curl -f https://staging.logyx.pe/api/v1/health || exit 1
          echo "Staging disponible y saludable"
```

### 4.2 Pipeline de seguridad — `.github/workflows/security.yml`

```yaml
name: LOGYX Security Scan

on:
  schedule:
    - cron: '0 3 * * 1'   # Lunes 3AM UTC
  push:
    branches: [ main ]

jobs:
  dependency-scan:
    name: Escaneo de dependencias
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: OWASP Dependency Check — Backend
        uses: dependency-check/Dependency-Check_Action@main
        with:
          project: 'logyx-backend'
          path: './logyx-backend'
          format: 'HTML'
          out: 'dependency-check-report'

      - name: npm audit — Frontend
        working-directory: logyx-web
        run: npm audit --audit-level=high

      - name: Upload reporte OWASP
        uses: actions/upload-artifact@v4
        with:
          name: owasp-report
          path: dependency-check-report/
```

---

## 5. Configuración de Protección de Rama `main`

En GitHub → Settings → Branches → Branch protection rules:

| Regla | Valor |
|-------|-------|
| **Require a pull request before merging** | ✅ Activado |
| **Require approvals** | 1 aprobación mínima |
| **Require status checks to pass** | `lint-and-build`, `test-backend`, `test-frontend` |
| **Require branches to be up to date** | ✅ Activado |
| **Restrict who can push to main** | Solo Admins del repositorio |
| **Allow force pushes** | ❌ Desactivado |
| **Allow deletions** | ❌ Desactivado |

---

## 6. Convención de Commits (Conventional Commits)

```
<tipo>(<ámbito>): <descripción corta>

[cuerpo opcional]
[BREAKING CHANGE: descripción]
```

| Tipo | Cuándo usar |
|------|-------------|
| `feat` | Nueva funcionalidad |
| `fix` | Corrección de bug |
| `test` | Añadir o corregir tests |
| `docs` | Documentación |
| `refactor` | Refactoring sin cambio funcional |
| `chore` | Configuración, deps, CI |
| `perf` | Mejora de rendimiento |

**Ejemplos:**
```
feat(auction): implementar cierre automático al llegar a max_bids
fix(pricing): corregir cálculo de peajes para rutas < 100 km
test(auth): agregar caso de prueba para login con Google OAuth
chore(ci): agregar job de escaneo OWASP semanal
docs(e2): completar diccionario de datos tabla reputation_scores
```

---

## 7. Secrets Requeridos en GitHub

| Secret | Descripción | Alcance |
|--------|-------------|---------|
| `JWT_SECRET_TEST` | JWT secret para tests | Actions |
| `ORS_API_KEY_TEST` | API key ORS para tests | Actions |
| `STAGING_HOST` | IP/dominio del servidor staging | Actions (env: staging) |
| `STAGING_USER` | Usuario SSH del servidor | Actions (env: staging) |
| `STAGING_SSH_KEY` | Clave SSH privada para deploy | Actions (env: staging) |
| `GOOGLE_CLIENT_ID_TEST` / `GOOGLE_CLIENT_SECRET_TEST` | Credenciales OAuth2 de Google para tests (Módulo 1 — Auth, RF06, agregado a `ROADMAP.md` el 2026-07-06) | Actions |
| `SMTP_HOST_TEST` / `SMTP_USERNAME_TEST` / `SMTP_PASSWORD_TEST` | Credenciales del servidor SMTP de pruebas (Módulo 18 — Notifications, RF50, canal email agregado a `ROADMAP.md` el 2026-07-06) | Actions |

> **Nota (agregada 2026-07-06):** las dos filas de arriba se agregaron junto con las
> correcciones al `ROADMAP.md` que incorporaron Google OAuth y el canal de email de
> notificaciones críticas — antes de eso no existían en el ROADMAP y por lo tanto no podían
> haberse anticipado aquí.

---

## 8. Evidencia de CI/CD

| Item | Estado |
|------|--------|
| Archivo `.github/workflows/ci.yml` en repositorio | Pendiente — agregar evidencia |
| Capturas de ejecuciones exitosas del pipeline | Pendiente |
| Badge de CI en README.md | Pendiente |
| Reporte de cobertura JaCoCo | Pendiente |
| URL del entorno staging | Pendiente |

---

*LOGYX · E4 CI/CD · Competencia CE0242 · Versión 1.0 · Junio 2026*
