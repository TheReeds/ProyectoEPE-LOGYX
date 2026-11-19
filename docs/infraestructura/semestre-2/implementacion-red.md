# S2 · Entregable 1 — Implementación y Testing de Red
> Competencias C1.2 (Implementación) · C1.3 (Testing y control)  
> Proyecto: OnCargo — Sistema Operativo Logístico Colaborativo para PYMEs  
> Equipo: Jorge Gutiérrez Miranda · Fabrizio Sanchez Saravia · Alex Coila Jarita  
> Semestre 2 · Agosto–Noviembre 2026 · **Versión 2.1 (estado real del despliegue, noviembre 2026)** · v2.0: diseño previo al despliegue · v1.0: AWS


!!! info "Versión 2.1: lo que realmente está desplegado en el VPS Hostinger"
    La versión 1.0 describía una implementación con Terraform sobre AWS. La versión 2.0 rediseñó la red para un VPS Hostinger con Cloudflare delante, pero se escribió **antes** de aprovisionar el servidor. Esta versión 2.1 documenta **lo que se desplegó de verdad**, tomado de la carpeta `infra/vps/` del monorepo (`compose.yml`, `Caddyfile`, `bootstrap.sh`, `deploy.sh`, `publish-apk.sh` y `README.md`, commit `cad2b77` del 16-nov-2026).

    **Diferencias principales con la v2.0:** no se usa Cloudflare (el DNS está en el panel de Hostinger y apunta directo a la IP del VPS); Caddy obtiene el certificado de Let's Encrypt por sí mismo; no existe el filtro de rangos de Cloudflare en `DOCKER-USER`; las redes Docker usan subredes automáticas; los documentos se guardan en MinIO dentro del VPS y no en Cloudflare R2. El servidor funciona hoy como **entorno de pruebas** (cuentas demo activas).

---

## Resumen Ejecutivo

La red de OnCargo se implementó en un único **VPS Hostinger KVM 2** (Ubuntu 24.04, 2 vCPU, 8 GB de RAM, 96 GB de disco) con tres capas: (1) el **host**, protegido con UFW (solo 22, 80 y 443 entrantes), SSH solo con clave y fail2ban; (2) **Caddy** como único proceso que publica puertos (80/443 TCP y 443/UDP para HTTP/3), con HTTPS automático de Let's Encrypt, cabeceras de seguridad y *streaming* SSE sin *buffer*; y (3) dos **redes Docker** (`edge` e `internal`) que separan lo expuesto (proxy, web, API) de lo que guarda datos (PostgreSQL y MinIO).

Los nombres públicos son `oncargo.tech` (web Astro SSR, con la página de descarga del APK en `/app/`) y `api.oncargo.tech` (API Quarkus para la app Android y el stream SSE). Mientras el DNS no apunte al VPS, Caddy también atiende `http://<IP_PUBLICA_VPS>` sin TLS, solo para pruebas.

El plan de pruebas (sección 4) se mantiene con comandos y criterios de aceptación ajustados a la red real. Los resultados se registran al ejecutarlas sobre el VPS, que ya está en operación.

**Leyenda de estados usada en todo el documento:**

| Estado | Significado |
|--------|-------------|
| **Desplegado en el VPS** | Está en `infra/vps/` y aplicado en el servidor según `infra/vps/README.md`. |
| **Implementado en el repositorio** | Existe en el código del monorepo (`backend/`, `web/`, `infra/`) y viaja con cada despliegue. |
| **Pendiente de medición** | La prueba está definida; falta ejecutarla en el VPS y adjuntar la evidencia. |
| **No implementado (mejora)** | Formaba parte del diseño v2.0 y no se desplegó; queda como mejora futura. |

---

## Sección 1 — Configuración de la Infraestructura de Red (C1.2)

### 1.1 Estructura de archivos en el VPS

El código no se clona en el servidor: `infra/vps/deploy.sh` empaqueta el commit indicado con `git archive` y lo descomprime en el VPS. Los secretos viven fuera del árbol de código y se conservan entre despliegues:

```
/opt/oncargo/
├── src/                     # código del commit desplegado (backend/, web/, infra/)
│   └── infra/vps/
│       ├── compose.yml      # servicios, redes y límites de memoria
│       ├── Caddyfile        # proxy inverso, TLS, SSE, descarga del APK
│       └── .env -> /opt/oncargo/state/.env      (enlace simbólico)
├── src.old/                 # commit anterior (para volver atrás)
├── state/
│   ├── .env                 # contraseñas aleatorias generadas por bootstrap.sh (chmod 600)
│   ├── secrets/             # claves JWT (jwt-private.pem, jwt-public.pem)
│   └── DEPLOYED             # SHA del commit desplegado
└── downloads/               # index.html (QR), oncargo.apk, version.json
```

| Elemento | Estado |
|----------|--------|
| Estructura `/opt/oncargo/{src,src.old,state,downloads}` | Desplegado en el VPS |
| Secretos fuera del código y fuera de Git (`state/.env`, `state/secrets/`) | Desplegado en el VPS |

### 1.2 Compose de red (fragmento de `infra/vps/compose.yml`)

Solo Caddy publica puertos en el host. El resto de servicios no tiene `ports:` y se comunica por nombre dentro de las redes de Docker:

```yaml
# infra/vps/compose.yml (fragmento de red)
name: oncargo

services:
  db:        # PostgreSQL 16 — solo red internal
    image: postgres:16-alpine
    networks: [internal]
    mem_limit: 768m

  minio:     # almacén S3 de documentos (entorno de pruebas) — solo red internal
    image: chainguard/minio@sha256:fb893e36…
    networks: [internal]
    mem_limit: 384m

  backend:   # Quarkus — habla con db/minio (internal) y lo alcanza Caddy (edge)
    networks: [internal, edge]
    environment:
      TRUSTED_PROXIES: 172.16.0.0/12   # solo Caddy (red edge de Docker) puede fijar X-Forwarded-For
    mem_limit: 1g

  web:       # Astro SSR — solo red edge
    networks: [edge]
    mem_limit: 512m

  caddy:     # único servicio con puertos publicados
    image: caddy:2.10-alpine
    ports:
      - "80:80"
      - "443:443"
      - "443:443/udp"   # HTTP/3
    networks: [edge]
    mem_limit: 128m

networks:
  internal:
  edge:
```

| Aspecto | Estado |
|---------|--------|
| Redes `internal` y `edge`; `db` y `minio` solo en `internal` | Desplegado en el VPS |
| Solo `caddy` publica puertos (80/tcp, 443/tcp, 443/udp) | Desplegado en el VPS |
| `healthcheck` de `db` (`pg_isready`), `minio` (`/minio/health/ready`), `backend` (`/q/health/ready`) y `web` (`/login`) | Desplegado en el VPS (compose y Dockerfiles) |
| Arranque ordenado con `depends_on: condition: service_healthy` (db y minio → backend → web → caddy) | Desplegado en el VPS |
| Subredes fijas (172.20.0.0/24 y 172.21.0.0/24) e `internal: true` en la red de datos | No implementado (mejora): Docker asigna las subredes y la red `internal` conserva salida a Internet |

### 1.3 Caddyfile (proxy inverso, TLS y SSE)

Este es el `infra/vps/Caddyfile` desplegado. El dominio y la IP llegan por las variables `DOMAIN` y `PUBLIC_IP` del `.env`:

```caddyfile
# OnCargo — Caddy: HTTPS automático (Let's Encrypt) en cuanto el DNS apunte al VPS.
(security) {
	encode zstd gzip
	header {
		Strict-Transport-Security "max-age=31536000; includeSubDomains"
		X-Content-Type-Options "nosniff"
		Referrer-Policy "strict-origin-when-cross-origin"
		-Server
	}
}

(downloads) {
	# Página de descarga de la app de pruebas (QR) y el APK: /opt/oncargo/downloads en el host.
	redir /app /app/ 308
	handle_path /app/* {
		root * /srv/downloads
		@apk path *.apk
		header @apk Content-Type "application/vnd.android.package-archive"
		header @apk Content-Disposition "attachment"
		file_server
	}
}

{$DOMAIN} {
	import security
	import downloads
	reverse_proxy web:4321
}

www.{$DOMAIN} {
	redir https://{$DOMAIN}{uri} 308
}

# API pública para la app Android (la web llama a la API por la red interna).
api.{$DOMAIN} {
	import security
	reverse_proxy backend:8080 {
		# SSE (/api/v1/events/stream): sin buffer
		flush_interval -1
	}
}

# Acceso por IP mientras el DNS no apunta al VPS (solo pruebas, sin TLS).
http://{$PUBLIC_IP} {
	encode zstd gzip
	import downloads
	handle /api/* {
		reverse_proxy backend:8080 {
			flush_interval -1
		}
	}
	handle {
		reverse_proxy web:4321
	}
}
```

| Decisión | Razón | Verificación (sección 4) |
|----------|-------|--------------------------|
| HTTPS automático con Let's Encrypt (sin Cloudflare) | Caddy emite y renueva el certificado al resolver el dominio hacia el VPS; sin costo ni configuración manual | T1, T9 |
| HSTS de 1 año, `nosniff`, `Referrer-Policy`, se quita la cabecera `Server` | Endurecimiento en el borde; la web y la API añaden además su propia CSP y `X-Frame-Options` | T8 |
| `flush_interval -1` en la API | Requisito del ADR-0007: cada evento SSE llega al cliente sin esperar a llenar un *buffer* | T7 |
| `www` redirige con 308 al dominio principal | Un solo nombre canónico | T8 |
| `/app/` sirve `index.html`, el QR y `oncargo.apk` desde `/opt/oncargo/downloads` (solo lectura) | Distribución de la app Android de pruebas sin tienda de aplicaciones | T15 |
| Bloque `http://{$PUBLIC_IP}` sin TLS | Permite probar por IP mientras el DNS propaga; **debe retirarse** al pasar a producción | T4 |

**Estado:** Caddyfile **Desplegado en el VPS**. Cabeceras de seguridad, HSTS y CSP de la aplicación: **Implementado en el repositorio** (`backend/src/main/resources/application.properties` y `web/src/middleware.ts`).

!!! warning "Compresión y SSE"
    El fragmento `(security)` aplica `encode zstd gzip` a todo el sitio de la API, incluido el stream SSE. Caddy mantiene el *flush* inmediato con `flush_interval -1`, pero conviene **verificarlo** con la prueba T11. Si los eventos se retrasan, la corrección es excluir `/api/v1/events/stream` del `encode`.

### 1.4 Firewall del host (UFW) y puertos publicados por Docker

Según `infra/vps/README.md`, el host tiene **UFW** con entrada denegada por omisión y solo **22, 80 y 443** permitidos. Docker publica sus puertos con reglas propias de `iptables` que UFW no filtra. Aquí no es un problema, porque el único servicio con puertos publicados es Caddy y usa justamente 80 y 443, que UFW ya permite. La base de datos, MinIO, el backend y la web **no publican ningún puerto**.

```bash
# Configuración equivalente a la aplicada (como usuario deploy con sudo)
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443        # TCP (HTTPS) y UDP (HTTP/3)
sudo ufw enable
sudo ufw status verbose
```

| Mecanismo | Protege | Estado |
|-----------|---------|--------|
| UFW: entrada `deny`, permitidos 22/80/443 | Servicios del host | Desplegado en el VPS |
| Solo Caddy publica puertos (el resto, sin `ports:`) | Contenedores | Desplegado en el VPS |
| fail2ban con la *jail* `sshd` | SSH | Desplegado en el VPS |
| Filtro "solo Cloudflare" en `DOCKER-USER` con `ipset` | 80/443 | No implementado (no se usa Cloudflare) |

!!! note "Firewall del panel de Hostinger"
    Hostinger ofrece un firewall de red en su panel que puede añadirse como capa adicional (22, 80 y 443 entrantes). No se documenta como configurado; queda como mejora.

### 1.5 DNS público (panel de Hostinger)

El dominio `oncargo.tech` se administra en el panel de Hostinger (Dominios → oncargo.tech → DNS). Los registros apuntan **directamente** a la IP del VPS; no hay proxy intermedio:

| Tipo | Nombre | Valor | Uso |
|------|--------|-------|-----|
| A | `@` | `<IP_PUBLICA_VPS>` | Web (`oncargo.tech`) y página del APK (`/app/`) |
| A | `www` | `<IP_PUBLICA_VPS>` | Redirección 308 a `oncargo.tech` |
| A | `api` | `<IP_PUBLICA_VPS>` | API de la app Android y SSE |

Antes hay que borrar los registros A/CNAME de *parking* del registrador. Caddy solicita los certificados en cuanto el DNS propaga. No se crean registros AAAA: Docker no publica los puertos por IPv6.

| Elemento | Estado |
|----------|--------|
| Registros A en el panel de Hostinger | Definidos en `infra/vps/README.md`; la propagación se comprueba con T1 |
| Certificados de Let's Encrypt emitidos por Caddy | Automático al propagar el DNS; se comprueba con T9 |
| DNSSEC | No implementado (mejora) |
| Cloudflare (CDN, WAF, mitigación DDoS) | No implementado (mejora) |

---

## Sección 2 — Implementación de Direccionamiento y Routing

### 2.1 Esquema IP

| Segmento | CIDR / dirección | Componentes | Asignación | Estado |
|----------|------------------|-------------|------------|--------|
| IP pública del VPS | 1 × IPv4 (`<IP_PUBLICA_VPS>`) | Interfaz pública del VPS | Estática de Hostinger | Desplegado en el VPS (la IP figura en `infra/vps/README.md`; aquí se omite a propósito) |
| Red `edge` | Subred asignada por Docker dentro de 172.16.0.0/12 | `caddy`, `web`, `backend` | Dinámica; se resuelve por nombre | Desplegado en el VPS |
| Red `internal` | Subred asignada por Docker dentro de 172.16.0.0/12 | `backend`, `db`, `minio` | Dinámica; se resuelve por nombre | Desplegado en el VPS |
| Bridge por omisión de Docker | 172.17.0.0/16 | Sin contenedores de OnCargo | No se usa | Informativo |

Como las subredes no se fijan, el backend confía en todo el bloque privado de Docker: `TRUSTED_PROXIES=172.16.0.0/12`. Solo los contenedores pueden presentarse desde ese rango, así que el *rate limiting* por IP (`AuthRateLimits`) toma la IP real que Caddy pone en `X-Forwarded-For`. Las subredes reales se registran con `docker network inspect` (Anexo A).

### 2.2 DNS

**DNS público:** registros A en Hostinger (sección 1.5). Los tres nombres resuelven a la IP del VPS (prueba T1).

**DNS interno (servidor DNS embebido de Docker, 127.0.0.11):**

| Nombre | Resuelve a | Visible desde |
|--------|-----------|---------------|
| `web` | Contenedor `web` | `caddy`, `backend` (red `edge`) |
| `backend` | Contenedor `backend` | `caddy`, `web` (red `edge`); `db`, `minio` (red `internal`) |
| `db` | Contenedor `db` | `backend`, `minio` (red `internal`) |
| `minio` | Contenedor `minio` | `backend`, `db` (red `internal`) |

Al estar en redes distintas, `web` y `caddy` **no pueden resolver** `db` ni `minio` (prueba T6).

### 2.3 Routing

En un VPS con Docker el *routing* lo hace el kernel del host; no hay *routers* configurables. Lo que se verifica son tres tablas:

| Tabla | Contenido esperado | Comando de verificación |
|-------|--------------------|------------------------|
| Rutas del host | `default via <gateway de Hostinger>` y una ruta por cada *bridge* de Docker (`edge`, `internal`) | `ip route` |
| NAT de salida (`nat/POSTROUTING`) | `MASQUERADE` para las subredes de `edge` e `internal` (salida a Internet de las imágenes y de Let's Encrypt) | `sudo iptables -t nat -S POSTROUTING` |
| NAT de entrada (`nat/DOCKER`) | `DNAT` de 80/tcp, 443/tcp y 443/udp hacia Caddy y de ningún otro puerto | `sudo iptables -t nat -S DOCKER` |

**Rutas de tráfico:**

| Origen | Destino | Camino | Observación |
|--------|---------|--------|-------------|
| Usuario | `oncargo.tech` | Internet → VPS:443 → DNAT → `caddy` → `web:4321` | TLS termina en Caddy |
| App Android | `api.oncargo.tech` | Internet → VPS:443 → `caddy` → `backend:8080` | Incluye el stream SSE |
| Usuario | `oncargo.tech/app/` | Internet → VPS:443 → `caddy` → archivos de `/srv/downloads` | Descarga del APK |
| `web` | `backend:8080` | Red `edge`, sin salir del host | La cookie `httpOnly` se convierte en `Bearer` |
| `backend` | `db:5432` | Red `internal` | Sin puertos publicados |
| `backend` | `minio:9000` | Red `internal` | Documentos y evidencias (API S3) |

---

## Sección 3 — Controles de Acceso y Estándares

### 3.1 Controles por capa (equivalente a las ACL)

| Capa | Control | Regla | Justificación | Estado |
|------|---------|-------|---------------|--------|
| Host | UFW | Entrada `deny`; permitidos 22, 80 y 443 | Superficie mínima | Desplegado en el VPS |
| Host | SSH | Solo clave pública (sin contraseñas); `root` solo con clave; usuario `deploy` con `sudo`; fail2ban | Ver [Implementación de Seguridad](implementacion-seguridad.md) | Desplegado en el VPS |
| Proxy | Caddy | TLS, HSTS, cabeceras, único punto de entrada | Punto único de entrada | Desplegado en el VPS |
| Contenedores | Redes `edge`/`internal` | `db` y `minio` solo en `internal`; sin `ports:` salvo Caddy | Segmentación de datos | Desplegado en el VPS |
| Aplicación | `AuthRateLimits` | Login 50/15 min por IP; bloqueo tras 10 fallos por correo; registro 10/15 min por IP | Contiene la fuerza bruta | Implementado en el repositorio |
| Aplicación | CSP, HSTS, `checkOrigin`, `X-Frame-Options`, `nosniff` | Ver [Seguridad](../../software/entregable-2/seguridad.md) | Defensa contra XSS, CSRF, *clickjacking* | Implementado en el repositorio |
| Aplicación | Límite de 5 streams SSE por usuario | `429 LOGYX-RTM-001` | Agotamiento de conexiones | Implementado en el repositorio |
| Aplicación | CORS desactivado (`CORS_ENABLED=false`) | El navegador nunca llama a la API directamente (la web es SSR) | Reduce la superficie | Desplegado en el VPS |
| Datos | Roles `logyx_owner` / `logyx_app` / `logyx_api` y RLS | Mínimo privilegio | Aislamiento por organización | Desplegado en el VPS (`infra/db/init-roles.sh`) |
| Borde | WAF / CDN | — | — | No implementado (mejora) |

### 3.2 Cumplimiento de estándares de red

| Estándar | Control aplicado | Evidencia |
|----------|------------------|-----------|
| TIA/EIA-568 (estructura) | No aplica al cableado (lo administra Hostinger); la estructura se expresa en capas lógicas: host, proxy, aplicación, datos | `docker network ls` y la sección 1.2 |
| IEEE 802.1Q (segmentación) | Redes Docker separadas (`edge`, `internal`) | `docker network inspect oncargo_edge oncargo_internal` |
| IEEE 802.3 (Ethernet) | Interfaz virtual `virtio` de KVM; sin control sobre la capa física | `ethtool -i <interfaz>` en el VPS |
| ISO/IEC 27001 (control de acceso) | Mínimo privilegio, segmentación, cifrado en tránsito | Secciones 1.3 y 1.4 |
| RFC 8446 (TLS 1.3) / HSTS (RFC 6797) | TLS de Let's Encrypt en Caddy; HSTS de 1 año | Pruebas T8 y T9 |
| RFC 9114 (HTTP/3) | 443/udp publicado por Caddy | Prueba T9 |
| RFC 6585 (código 429) | Respuesta `429` con `Retry-After` en el *rate limiting* | [Implementación de Seguridad](implementacion-seguridad.md), sección 3 |

---

## Sección 4 — Pruebas de Conectividad y Rendimiento (C1.3)

!!! warning "Estado de las pruebas"
    El VPS ya está en operación, pero a la fecha de esta versión **no hay resultados registrados** en el repositorio. Cada prueba indica el comando, el resultado esperado según la configuración real y el criterio de aceptación. La columna *Resultado* queda en **Pendiente de medición** hasta adjuntar la evidencia en el Anexo A.

### 4.1 Pruebas de conectividad y seguridad de red

| ID | Prueba | Resultado esperado | Resultado |
|----|--------|--------------------|-----------|
| T1 | DNS de los tres nombres | `oncargo.tech`, `www` y `api` resuelven a la IP del VPS | Pendiente de medición |
| T2 | Acceso HTTPS a la web con tiempos | `200` (o `302` a `/login`); TLS válido | Pendiente de medición |
| T3 | Salud de la API | `200` con `"status":"UP"` | Pendiente de medición |
| T4 | Acceso por IP sin TLS (`http://<IP>`) | Responde mientras exista el bloque de pruebas; debe dejar de responder al retirarlo | Pendiente de medición |
| T5 | Escaneo de puertos externo (Nmap) | Abiertos solo 22/tcp, 80/tcp y 443/tcp (y 443/udp); 5432, 8080, 4321 y 9000 cerrados o filtrados | Pendiente de medición |
| T6 | Aislamiento de datos | 5432 y 9000 inalcanzables desde fuera; `web` no resuelve `db` ni `minio`; `backend` sí | Pendiente de medición |
| T7 | SSE a través de Caddy | `stream.ready` inmediato y `: ping` cada ~20 s sin cortes | Pendiente de medición |
| T8 | Redirección HTTP→HTTPS y cabeceras | `308` a HTTPS; HSTS, `nosniff`, `Referrer-Policy`, CSP presentes; sin cabecera `Server` | Pendiente de medición |
| T9 | Certificado y protocolos | Emitido por Let's Encrypt, vigente; TLS 1.2/1.3; HTTP/3 anunciado (`alt-svc`) | Pendiente de medición |
| T10 | IP real del cliente | Un `X-Forwarded-For` falso no evade el límite por IP: `429` tras 50 intentos | Pendiente de medición |
| T11 | Compresión y SSE | HTML comprimido; los eventos SSE llegan sin retraso aunque el sitio tenga `encode` | Pendiente de medición |
| T12 | Recuperación de contenedor | Tras `docker kill` del backend, vuelve a `healthy` sin intervención | Pendiente de medición |
| T13 | Rutas internas de `/q/` | `200` en `/q/health/ready`; Swagger UI no incluido en producción | Pendiente de medición |
| T14 | Inicio de sesión en el navegador (`checkOrigin`) | Login correcto sin `403 Cross-site POST form submissions are forbidden` | Pendiente de medición |
| T15 | Descarga del APK | `https://oncargo.tech/app/` muestra el QR; `oncargo.apk` se descarga con `Content-Type: application/vnd.android.package-archive` | Pendiente de medición |

#### T1 — DNS

```bash
for h in oncargo.tech www.oncargo.tech api.oncargo.tech; do
  echo "== $h"; dig +short "$h" A; dig +short "$h" AAAA
done
# Esperado: la IP del VPS en los tres; sin registros AAAA
dig +short NS oncargo.tech          # Esperado: servidores de nombres de Hostinger
```

#### T2 y T3 — Web y API con desglose de tiempos

```bash
cat > curl-format.txt <<'EOF'
dns: %{time_namelookup}s  tcp: %{time_connect}s  tls: %{time_appconnect}s  ttfb: %{time_starttransfer}s  total: %{time_total}s  http: %{http_code}  ip: %{remote_ip}\n
EOF
curl -s -o /dev/null -w "@curl-format.txt" https://oncargo.tech/
curl -s -w "\n" https://api.oncargo.tech/q/health/ready
# Esperado: {"status":"UP","checks":[...]} con la comprobación de la base de datos en UP
```

#### T4 — Acceso por IP (bloque de pruebas)

```bash
curl -s -o /dev/null -w "%{http_code}\n" http://<IP_PUBLICA_VPS>/            # Esperado hoy: 200/302 (web)
curl -s -w "\n" http://<IP_PUBLICA_VPS>/api/q/health/ready                     # Ruta /api/* hacia el backend
# Tras retirar el bloque http://{$PUBLIC_IP} del Caddyfile: sin respuesta útil por IP
```

#### T5 y T6 — Escaneo externo y aislamiento de datos

```bash
# Desde una máquina externa, con autorización del equipo (infraestructura propia)
sudo nmap -Pn -sS -p- --min-rate 1000 -oN nmap-full.txt <IP_PUBLICA_VPS>
sudo nmap -Pn -sU -p 443 <IP_PUBLICA_VPS>
nmap -Pn -sV -p 22,80,443,5432,8080,4321,9000 <IP_PUBLICA_VPS>
# Esperado: 22, 80, 443 open; 5432, 8080, 4321, 9000 closed o filtered

# Dentro del VPS (usuario deploy)
cd /opt/oncargo/src/infra/vps
docker compose exec backend getent hosts db      # Esperado: IP interna de db
docker compose exec web     getent hosts db      # Esperado: sin salida (código 2)
docker compose exec caddy   getent hosts minio   # Esperado: sin salida (código 2)
docker compose exec db pg_isready -U postgres -d logyx   # Esperado: accepting connections
sudo ss -tlnp | grep -E ':(5432|8080|4321|9000)\b' || echo "Ningún puerto de aplicación escucha en el host"
```

#### T7 — SSE

```bash
# TOKEN: JWT de una cuenta demo (el VPS de pruebas tiene DEMO_DATA=true)
TOKEN=$(curl -s https://api.oncargo.tech/api/v1/auth/login -H 'Content-Type: application/json' \
  -d '{"email":"carrier@logyx.pe","password":"<contraseña demo>"}' | jq -r .data.accessToken)
curl -N -sS --max-time 130 -H "Authorization: Bearer $TOKEN" -H "Accept: text/event-stream" \
  https://api.oncargo.tech/api/v1/events/stream \
| while IFS= read -r line; do printf '%s  %s\n' "$(date +%T)" "$line"; done
# Esperado: stream.ready al instante; ": ping" cada ~20 s durante los 130 s
```

Criterio de aceptación: el primer evento llega en menos de 2 s y el intervalo entre `: ping` no supera 25 s.

#### T8, T9 y T11 — Cabeceras, TLS, HTTP/3 y compresión

```bash
curl -sI http://oncargo.tech/ | head -5                     # Esperado: 308 con Location: https://...
curl -sI https://oncargo.tech/login | grep -iE 'strict-transport|content-security|x-frame|x-content|referrer|^server'
curl -sI https://api.oncargo.tech/q/health/ready | grep -iE 'strict-transport|x-content|cache-control|alt-svc'

echo | openssl s_client -connect oncargo.tech:443 -servername oncargo.tech 2>/dev/null \
  | openssl x509 -noout -issuer -subject -dates            # Esperado: issuer Let's Encrypt
nmap --script ssl-enum-ciphers -p 443 oncargo.tech          # Esperado: TLSv1.2 y TLSv1.3

curl -sI -H 'Accept-Encoding: gzip, zstd' https://oncargo.tech/login | grep -i content-encoding   # Esperado: gzip o zstd
# SSE: repetir T7 con -H 'Accept-Encoding: gzip' y comprobar que los ": ping" siguen llegando cada ~20 s
```

#### T10 — IP real del cliente

```bash
# 55 intentos de login con correos distintos y un X-Forwarded-For falso y distinto en cada uno.
# Si el backend creyera esa cabecera, cada intento parecería venir de otra IP y nunca se bloquearía.
# Como solo confía en Caddy (TRUSTED_PROXIES=172.16.0.0/12), cuenta todos contra la IP real: 429 tras 50.
for i in $(seq 1 55); do
  curl -s -o /dev/null -w "%{http_code} " -H "X-Forwarded-For: 203.0.113.$i" -H 'Content-Type: application/json' \
    -d "{\"email\":\"prueba$i@ejemplo.pe\",\"password\":\"x\"}" https://api.oncargo.tech/api/v1/auth/login
done; echo
# Esperado: 401 x50 y luego 429 (con Retry-After). Esperar 15 min antes de volver a usar esa IP para el login.
```

#### T12 — Recuperación de un contenedor

```bash
while true; do printf '%s ' "$(date +%T)"; curl -s -o /dev/null -w "%{http_code}\n" --max-time 3 https://api.oncargo.tech/q/health/ready; sleep 2; done
# En otra terminal (VPS):
docker kill oncargo-backend-1
# Esperado: 502 durante el reinicio (restart: unless-stopped; start-period del healthcheck: 60 s) y retorno a 200
```

#### T13, T14 y T15 — Superficie pública, sesión y APK

```bash
for p in /q/health/ready /q/health /q/swagger-ui /q/openapi; do
  printf '%-18s' "$p"; curl -s -o /dev/null -w "%{http_code}\n" "https://api.oncargo.tech$p"
done
# Esperado: 200 200 404 y /q/openapi según se registre (el Caddyfile no bloquea /q/; ver hallazgo H-04)

curl -sI https://oncargo.tech/app/oncargo.apk | grep -iE 'content-type|content-disposition|content-length'
curl -s https://oncargo.tech/app/version.json
```

T14 es manual: iniciar sesión en `https://oncargo.tech/login` desde un navegador y desde la app Android contra `api.oncargo.tech`.

### 4.2 Pruebas de latencia y carga

**Objetivos de diseño** (de [Diseño de Red, sección 4.3](../semestre-1/diseno-red.md)): P95 < 500 ms y tasa de error < 1 %. Sin CDN, la latencia desde Lima depende de la ruta hasta el centro de datos de Hostinger, así que hay que medirla.

**Latencia por repetición (curl):**

```bash
for i in $(seq 1 100); do
  curl -s -o /dev/null -w "%{time_connect} %{time_appconnect} %{time_starttransfer} %{time_total}\n" https://api.oncargo.tech/q/health/ready
done | awk '{c+=$1; a+=$2; t+=$3; T+=$4; v[NR]=$4} END {n=NR; asort(v); printf "n=%d connect=%.0fms tls=%.0fms ttfb=%.0fms total_prom=%.0fms p50=%.0fms p95=%.0fms\n", n, c/n*1000, a/n*1000, t/n*1000, T/n*1000, v[int(n*0.5)]*1000, v[int(n*0.95)]*1000}'
# Requiere gawk (asort). Ejecutar a distintas horas.
```

**Ruta de red:**

```bash
mtr -rwzc 50 oncargo.tech               # Lima -> VPS (pérdida y latencia por salto)
ping -c 50 oncargo.tech | tail -3
```

**Prueba de humo con k6 (10 usuarios, 60 s, solo lectura):**

```javascript
// k6-smoke.js — ejecutar:  k6 run k6-smoke.js
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  vus: 10,
  duration: '60s',
  thresholds: {
    http_req_duration: ['p(50)<150', 'p(95)<500', 'p(99)<2000'],
    http_req_failed: ['rate<0.01'],
  },
};

export default function () {
  const api = http.get('https://api.oncargo.tech/q/health/ready');
  check(api, { 'api 200': (r) => r.status === 200 });
  const web = http.get('https://oncargo.tech/login');
  check(web, { 'web 200': (r) => r.status === 200 });
  sleep(0.5);
}
```

**Prueba de carga escalonada (hasta ~100 req/s, lectura):**

```javascript
// k6-load.js — escenario del MVP: 50–100 req/s sostenidos
import http from 'k6/http';
import { check } from 'k6';

export const options = {
  scenarios: {
    rampa: {
      executor: 'ramping-arrival-rate',
      startRate: 10, timeUnit: '1s', preAllocatedVUs: 100, maxVUs: 300,
      stages: [
        { target: 50,  duration: '2m' },
        { target: 100, duration: '3m' },
        { target: 100, duration: '3m' },
        { target: 0,   duration: '1m' },
      ],
    },
  },
  thresholds: { http_req_duration: ['p(95)<500'], http_req_failed: ['rate<0.01'] },
};

export default function () {
  const r = http.get('https://oncargo.tech/login');
  check(r, { 'status 200': (x) => x.status === 200 });
}
```

```bash
# Alternativa mínima con ApacheBench
ab -n 2000 -c 20 -k https://oncargo.tech/login
# Durante la prueba, en el VPS:
docker stats --no-stream
vmstat 5 12
```

**Conexiones SSE simultáneas:** el límite de la aplicación es de 5 streams por usuario, así que hacen falta cuentas distintas (el *seed* demo trae siete: `pyme@`, `pyme.ops@`, `pyme.viewer@`, `carrier@`, `carrier2@`, `driver@`, `operator@logyx.pe`). Para 500 streams se usa el *staging* local con más usuarios. Se registra la memoria y la CPU de `backend` y `db` (`docker stats`) y se confirma que los pools de conexiones (8 + 20) no se agotan.

**Metas y resultados:**

| Métrica | Objetivo | Resultado |
|---------|----------|-----------|
| Latencia total P50 (Lima → API) | < 150 ms | Pendiente de medición |
| Latencia total P95 | < 500 ms | Pendiente de medición |
| Latencia total P99 | < 2,000 ms (RNF-01) | Pendiente de medición |
| Tasa de error | < 1 % | Pendiente de medición |
| Throughput sostenido | ≥ 100 req/s en lectura | Pendiente de medición |
| Pérdida de paquetes (mtr, 50 sondeos) | < 1 % | Pendiente de medición |
| Streams SSE simultáneos | 35 en el VPS (7 cuentas × 5) / 500 en *staging* | Pendiente de medición |
| Memoria libre del host bajo carga | > 1.5 GB | Pendiente de medición |

### 4.3 Rendimiento del enlace del VPS

```bash
curl -s -o /dev/null -w "descarga 100 MB: %{speed_download} B/s en %{time_total}s\n" 'https://speed.cloudflare.com/__down?bytes=100000000'
head -c 50000000 /dev/zero | curl -s -o /dev/null -X POST --data-binary @- -w "subida 50 MB: %{speed_upload} B/s en %{time_total}s\n" 'https://speed.cloudflare.com/__up'
# Convertir a Mbps: B/s x 8 / 1,000,000. Objetivo: >= 100 Mbps (RT-02).
```

| Métrica | Objetivo | Resultado |
|---------|----------|-----------|
| Descarga del VPS | ≥ 100 Mbps | Pendiente de medición |
| Subida del VPS | ≥ 100 Mbps | Pendiente de medición |

---

## Sección 5 — Monitoreo de Red

### 5.1 Capas de monitoreo implementadas

Un VPS de 8 GB comparte la memoria entre la base de datos y el backend, por lo que no se instalan pilas pesadas (Prometheus, Grafana, Elastic). Esto es lo que funciona hoy:

| Capa | Herramienta | Qué observa | Estado |
|------|-------------|-------------|--------|
| Salud de contenedores | `healthcheck` de Docker + `restart: unless-stopped` | `healthy` de `db`, `minio`, `backend`, `web`; reinicio automático | Desplegado en el VPS |
| Logs de contenedores | `docker compose logs` con rotación de 10 MB × 3 archivos por contenedor | Errores y eventos de Caddy (certificados, arranque), backend y web | Desplegado en el VPS |
| Registro de accesos HTTP de Caddy | — | Estado, ruta, IP y latencia de cada petición | No implementado: el Caddyfile no tiene la directiva `log` (sección 5.2) |
| Intrusión SSH | fail2ban (*jail* `sshd`) | Fuerza bruta contra SSH | Desplegado en el VPS |
| Recursos del host | `docker stats`, `vmstat`, `df -h`, `journalctl` | CPU, memoria, disco | Manual (bajo demanda) |
| Aplicación | Logs y tabla `outbox_events` | Errores `ERROR`; eventos en `FAILED` | Implementado en el repositorio (revisión manual) |
| Disponibilidad externa (UptimeRobot) | — | Caída del propio VPS | No implementado (mejora prioritaria) |
| Monitoreo interno (Uptime Kuma) | — | Certificado, TCP de `db`, latido de respaldos | No implementado (mejora) |
| Logs de Caddy a archivo y fail2ban sobre el login | — | Fuerza bruta en `/api/v1/auth/login` | No implementado (la aplicación ya limita con `AuthRateLimits`) |

**Sobre SNMP.** La rúbrica menciona SNMP porque asume equipos de red propios. En un VPS no hay conmutadores ni *routers* gestionables y el proveedor no expone SNMP; el equivalente funcional son las métricas del host y los registros anteriores.

### 5.2 Registro de accesos de Caddy

Caddy **no registra accesos** si el sitio no tiene la directiva `log`, y el Caddyfile desplegado no la incluye. Hoy solo quedan sus mensajes de funcionamiento (emisión de certificados, errores de *proxy*). Para activar el registro basta con añadir `log` al fragmento `(security)`; con eso Caddy escribe un JSON por petición en la salida estándar, que Docker rota (10 MB × 3):

```caddyfile
(security) {
	log                      # registro de accesos en JSON (Caddy oculta las cabeceras Authorization y Cookie)
	encode zstd gzip
	# ... (resto sin cambios)
}
```

Una vez activado, se analiza así:

```bash
cd /opt/oncargo/src/infra/vps
# Distribución de códigos de estado (últimas 5,000 líneas)
docker compose logs --no-log-prefix --tail=5000 caddy | jq -r 'select(.status) | .status' | sort | uniq -c | sort -rn
# Errores 5xx
docker compose logs --no-log-prefix --tail=5000 caddy | jq -r 'select(.status>=500) | [.ts, .request.remote_ip, .request.method, .request.uri, .status] | @tsv'
# IPs más activas
docker compose logs --no-log-prefix --tail=5000 caddy | jq -r 'select(.request) | .request.remote_ip' | sort | uniq -c | sort -rn | head
# Intentos de login rechazados por IP
docker compose logs --no-log-prefix --tail=5000 caddy | jq -r 'select(.request.uri=="/api/v1/auth/login" and (.status==401 or .status==429)) | .request.remote_ip' | sort | uniq -c | sort -rn
```

!!! note "Retención"
    Con la rotación de Docker (10 MB × 3) la historia de accesos sería corta. Para conservarla más tiempo se usa `log { output file … }` con rotación propia y un volumen montado.

### 5.3 Umbrales de alerta (revisión manual)

| Métrica | Umbral | Acción |
|---------|--------|--------|
| Web o API no disponible | Cualquier fallo de T2/T3 | Runbook de incidente ([Datacenter, sección 4.2](implementacion-datacenter.md)) |
| Respuestas 5xx en Caddy | > 10 en 5 min | `docker compose logs backend` |
| Memoria disponible del host | < 1.5 GB | Revisar límites y evaluar escalado vertical |
| CPU promedio | > 70 % durante 15 min | Evaluar escalado vertical |
| Disco | > 70 % de 96 GB | `docker image prune`, revisar volúmenes |
| Certificado TLS | < 14 días para vencer | Revisar los logs de Caddy y el DNS |
| `outbox_events` en `FAILED` | > 0 | Diagnóstico por `last_error` |

---

## Sección 6 — Hallazgos y Acciones Correctivas

Riesgos de configuración identificados al documentar el despliegue real (no son incidentes ocurridos):

| ID | Hallazgo | Efecto | Acción correctiva | Estado |
|----|----------|--------|-------------------|--------|
| H-01 | Bloque `http://{$PUBLIC_IP}` sin TLS | La web, la API y el login viajan sin cifrar si se usa la IP | Retirarlo del Caddyfile cuando el dominio tenga HTTPS | Abierto (temporal por diseño) |
| H-02 | `COOKIE_SECURE=false` en `state/.env` | La cookie de sesión también viaja por HTTP | Cambiar a `true` junto con H-01 | Abierto (temporal por diseño) |
| H-03 | `DEMO_DATA=true`: cuentas demo con contraseña conocida | Cualquiera puede entrar como PYME, transportista u operador de prueba | `DEMO_DATA=false` y base nueva para producción | Abierto (entorno de pruebas) |
| H-04 | El Caddyfile no restringe `/q/*` | `/q/openapi` podría quedar público (Swagger UI ya está desactivado en producción) | `respond 404` para `/q/*` salvo `/q/health*` | Abierto |
| H-05 | `encode` aplicado también al stream SSE | Posible retraso de eventos | Verificar con T11; excluir la ruta si hace falta | Pendiente de medición |
| H-06 | La red `internal` no tiene `internal: true` | `db` y `minio` conservan salida a Internet | Añadir `internal: true` (verificar que MinIO y Postgres no la necesiten) | Abierto (mejora) |
| H-07 | Sin CDN ni WAF delante del origen | El VPS recibe todo el tráfico directamente, incluido un DDoS | Evaluar Cloudflare (plan gratuito) para producción | Aceptado en pruebas |
| H-09 | Caddy sin registro de accesos | No hay rastro de peticiones para investigar un incidente | Añadir `log` en el Caddyfile (sección 5.2) | Abierto |
| H-10 | Astro sin `security.allowedDomains` detrás de Caddy | La web ve como IP de todos los usuarios la del contenedor `caddy` (Astro 7 solo confía en `X-Forwarded-For` si el host está validado) y la reenvía al backend: los límites por IP de login (50), registro (10), restablecer contraseña (20/30) y cotización pública (30, cada 15 min) se **comparten entre todos los usuarios de la web**. Unos pocos intentos fallidos de cualquiera bloquean el login web de todos | Añadir `security: { allowedDomains: [{ hostname: 'oncargo.tech', protocol: 'https' }] }` en `web/astro.config.mjs` y verificar con T13 | Abierto (corresponde al repositorio de código) |
| H-11 | El APK publicado en `/app/` es una compilación **debug** (`publish-apk.sh` espera `assembleDebug`) | Permite tráfico sin cifrar y muestra accesos demo; su URL de API depende de `-PapiBaseUrl` al compilar (por omisión `http://10.0.2.2:8080`, solo emulador) | Compilar con `-PapiBaseUrl=https://api.oncargo.tech` y, para producción, publicar un *release* firmado (el *release* usa por omisión `https://api.logyx.pe`, que no es el dominio desplegado) | Abierto (entorno de pruebas) |
| H-08 | Un solo VPS | Servicio indisponible si cae el proveedor | Reconstrucción documentada ([Datacenter, sección 4.3](implementacion-datacenter.md)) | Aceptado (equivalente Tier I) |

---

## Anexos

### Anexo A — Evidencias de ejecución

| Evidencia | Origen | Estado |
|-----------|--------|--------|
| `infra/vps/compose.yml`, `Caddyfile`, `bootstrap.sh`, `deploy.sh`, `publish-apk.sh`, `README.md` | Repositorio (commit `cad2b77`) | Disponible |
| `docker compose ps` con los cinco servicios en marcha (`db`, `minio`, `backend`, `web`, `caddy`) | VPS | Pendiente de captura |
| `docker network inspect oncargo_edge oncargo_internal` (subredes asignadas) | VPS | Pendiente de captura |
| `sudo ufw status verbose` y `sudo fail2ban-client status sshd` | VPS | Pendiente de captura |
| Panel DNS de Hostinger con los registros A | Hostinger | Pendiente de captura |
| Salida de T1 a T15 | Varios | Pendiente de medición |
| Informe de k6 (humo y carga) y de `ab` | Lima | Pendiente de medición |
| `nmap-full.txt` del escaneo externo | Equipo externo | Pendiente de medición |

### Anexo B — Comandos de diagnóstico de red

```bash
# Estado de los servicios y de la red
cd /opt/oncargo/src/infra/vps && docker compose ps
cat /opt/oncargo/state/DEPLOYED                       # commit desplegado
docker network ls && docker network inspect oncargo_edge oncargo_internal | jq '.[].IPAM.Config'
ip -br a && ip route

# Firewall y puertos
sudo ufw status numbered
sudo iptables -t nat -S DOCKER | grep -E 'dpt:(80|443)'
sudo ss -tlnp                                          # solo SSH y docker-proxy en 80/443

# Caddy
docker compose logs --tail=100 caddy
docker compose exec caddy caddy validate --config /etc/caddy/Caddyfile
docker compose exec caddy caddy reload --config /etc/caddy/Caddyfile

# Conectividad interna
docker compose exec web wget -qO- http://backend:8080/q/health/ready
docker compose exec backend getent hosts db minio

# fail2ban
sudo fail2ban-client status sshd

# Desde fuera: la base de datos no debe responder
nmap -Pn -p 22,80,443,5432,9000 <IP_PUBLICA_VPS>
```

---

*OnCargo · S2 Entregable 1 · Implementación de Red · Competencias C1.2–C1.3 · Versión 2.1 · Noviembre 2026*
