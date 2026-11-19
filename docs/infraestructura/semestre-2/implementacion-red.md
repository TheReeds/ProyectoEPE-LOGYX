# S2 · Entregable 1 — Implementación y Testing de Red
> Competencias C1.2 (Implementación) · C1.3 (Testing y control)  
> Proyecto: OnCargo — Sistema Operativo Logístico Colaborativo para PYMEs  
> Equipo: Jorge Gutiérrez Miranda · Fabrizio Sanchez Saravia · Alex Coila Jarita  
> Semestre 2 · Agosto–Noviembre 2026 · **Versión 2.3 (H-03, H-10 y H-11 cerrados en el código, alertas por ntfy, 19-nov-2026)** · v2.2: endurecimiento aplicado y pruebas ejecutadas · v2.1: estado real del despliegue · v2.0: diseño previo al despliegue · v1.0: AWS


!!! info "Versión 2.1: lo que realmente está desplegado en el VPS Hostinger"
    La versión 1.0 describía una implementación con Terraform sobre AWS. La versión 2.0 rediseñó la red para un VPS Hostinger con Cloudflare delante, pero se escribió **antes** de aprovisionar el servidor. Esta versión 2.1 documenta **lo que se desplegó de verdad**, tomado de la carpeta `infra/vps/` del monorepo (`compose.yml`, `Caddyfile`, `bootstrap.sh`, `deploy.sh`, `publish-apk.sh` y `README.md`, commit `cad2b77` del 16-nov-2026).

    **Diferencias principales con la v2.0:** no se usa Cloudflare (el DNS está en el panel de Hostinger y apunta directo a la IP del VPS); Caddy obtiene el certificado de Let's Encrypt por sí mismo; no existe el filtro de rangos de Cloudflare en `DOCKER-USER`; las redes Docker usan subredes automáticas; los documentos se guardan en MinIO dentro del VPS y no en Cloudflare R2. El servidor funciona hoy como **entorno de pruebas** (cuentas demo activas).

!!! success "Versión 2.2 (19-nov-2026): endurecimiento de red aplicado y pruebas ejecutadas"
    Se aplicaron y verificaron en el VPS (commits `9d1f6a2` y `b44014a` de `oncargo-code`): lista blanca `DOCKER-USER` para los puertos que publica Docker, red `internal` sin salida a Internet, registro de accesos de Caddy con tokens redactados, *jails* de fail2ban sobre ese registro, `/q/*` cerrado salvo la salud, cabeceras adicionales y redirección del acceso por IP al dominio con HTTPS. Se cerraron los hallazgos **H-01, H-02, H-04, H-05, H-06 y H-09** (sección 6) y se ejecutaron T1–T9, T11, T13 y T15 (sección 4). La evaluación completa control por control está en [Implementación de Seguridad, Sección 0](implementacion-seguridad.md).

---

## Resumen Ejecutivo

La red de OnCargo se implementó en un único **VPS Hostinger KVM 2** (Ubuntu 24.04, 2 vCPU, 8 GB de RAM, 96 GB de disco) con tres capas: (1) el **host**, protegido con UFW (solo 22, 80 y 443 entrantes), SSH solo con clave y fail2ban; (2) **Caddy** como único proceso que publica puertos (80/443 TCP y 443/UDP para HTTP/3), con HTTPS automático de Let's Encrypt, cabeceras de seguridad y *streaming* SSE sin *buffer*; y (3) dos **redes Docker** (`edge` e `internal`) que separan lo expuesto (proxy, web, API) de lo que guarda datos (PostgreSQL y MinIO).

Los nombres públicos son `oncargo.tech` (web Astro SSR, con la página de descarga del APK en `/app/`) y `api.oncargo.tech` (API Quarkus para la app Android y el stream SSE). El acceso por `http://<IP_PUBLICA_VPS>` sirvió sin TLS solo mientras el DNS propagaba; desde la v2.2 responde `308` a `https://oncargo.tech`.

El plan de pruebas (sección 4) se mantiene con comandos y criterios de aceptación ajustados a la red real. Los resultados del 19-nov-2026 se registran en cada prueba; las que siguen pendientes lo indican.

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
# infra/vps/compose.yml (fragmento de red, v2.2)
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
    volumes:
      - /var/log/oncargo/caddy:/var/log/caddy   # registro de accesos (v2.2), lo lee fail2ban
    networks: [edge]
    mem_limit: 128m

networks:
  internal:
    internal: true   # v2.2: db y minio sin salida a Internet
  edge:
```

Cada servicio hereda además el ancla `x-hardening` (`no-new-privileges`, `cap_drop: [ALL]`) y tiene `pids_limit`; detalle en [Seguridad, 1.3](implementacion-seguridad.md).

| Aspecto | Estado |
|---------|--------|
| Redes `internal` y `edge`; `db` y `minio` solo en `internal` | Desplegado en el VPS |
| Solo `caddy` publica puertos (80/tcp, 443/tcp, 443/udp) | Desplegado en el VPS |
| `healthcheck` de `db` (`pg_isready`), `minio` (`/minio/health/ready`), `backend` (`/q/health/ready`) y `web` (`/login`) | Desplegado en el VPS (compose y Dockerfiles) |
| Arranque ordenado con `depends_on: condition: service_healthy` (db y minio → backend → web → caddy) | Desplegado en el VPS |
| `internal: true` en la red de datos | **Implementado (v2.2)**: `db` y `minio` no tienen salida a Internet (`wget http://1.1.1.1` desde `db` falla); el backend sale por `edge` |
| Subredes fijas (172.20.0.0/24 y 172.21.0.0/24) | Descartado: Docker asigna `172.18.0.0/16` (`edge`) y `172.19.0.0/16` (`internal`); nada depende de la dirección, todo se resuelve por nombre |

### 1.3 Caddyfile (proxy inverso, TLS y SSE)

Este es el `infra/vps/Caddyfile` desplegado desde la v2.2 (commit `9d1f6a2`). El dominio y la IP llegan por las variables `DOMAIN` y `PUBLIC_IP` del `.env`:

```caddyfile
# OnCargo — Caddy: HTTPS automático (Let's Encrypt) en cuanto el DNS apunte al VPS.
# Endurecimiento (ver infra/vps/README.md § Seguridad del host): registro de accesos para fail2ban,
# cabeceras, /q/* cerrado salvo la salud y el acceso por IP redirigido al dominio.

(access_log) {
	# JSON por petición en /var/log/oncargo/caddy/access.log del host (lo lee fail2ban). Caddy ya oculta
	# Cookie y Authorization; aquí además se tapan los tokens de URL: ?t= (baja), ?token= (restablecer,
	# invitación) y /s/<token> · /public/tracking/<token> (seguimiento público). Retención: 14 días.
	log {
		output file /var/log/caddy/access.log {
			roll_size 20MiB
			roll_keep 10
			roll_keep_for 336h
			mode 0640
		}
		format filter {
			wrap json {
				time_format iso8601
			}
			request>uri regexp "([?&](?:t|token)=|/s/|/public/tracking/)[^&/?]+" "${1}REDACTED"
		}
	}
}

(security) {
	import access_log
	encode zstd gzip
	header {
		Strict-Transport-Security "max-age=31536000; includeSubDomains"
		X-Content-Type-Options "nosniff"
		Referrer-Policy "strict-origin-when-cross-origin"
		# Solo si la aplicación no la fijó (la web ya manda la suya).
		?Permissions-Policy "camera=(), microphone=(), geolocation=(), payment=(), usb=()"
		-Server
		-Via
	}
}

(downloads) {
	# Página de descarga de la app de pruebas (QR) y el APK: /opt/oncargo/downloads en el host.
	redir /app /app/ 308
	handle_path /app/* {
		root * /srv/downloads
		# Página estática servida por Caddy (no pasa por la web): CSP propia. Estilo y script en línea.
		header {
			Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; connect-src 'self'; object-src 'none'; frame-ancestors 'none'; base-uri 'self'; form-action 'self'"
			X-Frame-Options "DENY"
		}
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
	import access_log
	redir https://{$DOMAIN}{uri} 308
}

# API pública para la app Android (la web llama a la API por la red interna).
api.{$DOMAIN} {
	import security
	# Rutas internas de Quarkus (/q/openapi, /q/metrics…): solo la salud queda pública (monitoreo externo).
	@quarkus_internal {
		path /q/*
		not path /q/health /q/health/*
	}
	respond @quarkus_internal 404
	reverse_proxy backend:8080 {
		# SSE (/api/v1/events/stream): sin buffer
		flush_interval -1
	}
}

# Acceso por IP sin TLS: ya no sirve contenido (login en claro, hallazgo H-01). Redirige al dominio con HTTPS.
http://{$PUBLIC_IP} {
	import access_log
	redir https://{$DOMAIN}{uri} 308
}
```

| Decisión | Razón | Verificación (sección 4) |
|----------|-------|--------------------------|
| HTTPS automático con Let's Encrypt (sin Cloudflare) | Caddy emite y renueva el certificado al resolver el dominio hacia el VPS; sin costo ni configuración manual | T1, T9 |
| HSTS de 1 año, `nosniff`, `Referrer-Policy`, `Permissions-Policy` (si la aplicación no la fijó); se quitan `Server` y `Via` | Endurecimiento en el borde; la web y la API añaden además su propia CSP y `X-Frame-Options`. HSTS `preload` queda pendiente de aprobación (es prácticamente irreversible) | T8 |
| Registro de accesos (`access_log`): JSON en `/var/log/oncargo/caddy/access.log`, 20 MiB × 10, 14 días; filtro que reemplaza por `REDACTED` los tokens de `?t=`, `?token=`, `/s/<token>` y `/public/tracking/<token>` | Rastro para investigar incidentes y fuente de fail2ban, sin guardar tokens; la IP es dato personal: retención corta | Sección 5.2 |
| `/q/*` responde `404` en `api.` salvo `/q/health*` | `/q/openapi` y otras rutas internas de Quarkus no son públicas (H-04); la salud queda para el monitoreo externo | T13 |
| CSP y `X-Frame-Options` propios en `/app/` | La página del APK la sirve Caddy y no pasa por la web | T15 |
| `flush_interval -1` en la API | Requisito del ADR-0007: cada evento SSE llega al cliente sin esperar a llenar un *buffer* | T7 |
| `www` redirige con 308 al dominio principal | Un solo nombre canónico | T8 |
| `/app/` sirve `index.html`, el QR y `oncargo.apk` desde `/opt/oncargo/downloads` (solo lectura) | Distribución de la app Android de pruebas sin tienda de aplicaciones | T15 |
| Bloque `http://{$PUBLIC_IP}`: `308` a `https://oncargo.tech` | Con el DNS ya propagado, el acceso por IP dejó de servir contenido en claro (H-01); la app usa `https://api.oncargo.tech` | T4 |

**Estado:** Caddyfile **Desplegado en el VPS** (v2.2). Cabeceras de seguridad, HSTS y CSP de la aplicación: **Implementado en el repositorio** (`backend/src/main/resources/application.properties` y `web/src/middleware.ts`). El contenedor de Caddy corre con sistema de archivos de solo lectura, sin capacidades salvo `NET_BIND_SERVICE` y con `no-new-privileges`.

!!! note "Compresión y SSE (verificado)"
    El fragmento `(security)` aplica `encode zstd gzip` a todo el sitio de la API. La prueba T11 (19-nov-2026) pidió el stream con `Accept-Encoding: gzip, zstd`: Caddy **no** comprimió `text/event-stream`, `stream.ready` llegó al instante y el `:ping` a los 20 s exactos. H-05 queda cerrado sin cambios.

!!! note "Límite de tasa en el proxy: descartado en Caddy"
    La imagen oficial `caddy:2.10-alpine` no incluye el módulo `rate_limit`: es de terceros y exige compilar una imagen propia con `xcaddy`, que luego habría que mantener. El límite se aplica en la aplicación (`AuthRateLimits`) y en el host (fail2ban `oncargo-caddy-auth` bloquea en 80/443 las IP que acumulan respuestas `429`). En el borde, lo cubriría Cloudflare ([Seguridad, 4.1](implementacion-seguridad.md)).

### 1.4 Firewall del host (UFW) y puertos publicados por Docker

Según `infra/vps/README.md`, el host tiene **UFW** con entrada denegada por omisión y solo **22, 80 y 443** permitidos. Docker publica sus puertos con reglas propias de `iptables` (DNAT en `PREROUTING` y filtrado en `FORWARD`) que **UFW no ve**, porque UFW filtra la cadena `INPUT`. Hoy el único servicio con puertos publicados es Caddy, en 80 y 443, que UFW ya permite. La base de datos, MinIO, el backend y la web **no publican ningún puerto**. Pero un `ports:` agregado por error a otro servicio quedaría expuesto a Internet sin que UFW lo note. Por eso la v2.2 añade la cadena `DOCKER-USER` como lista blanca.

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

**`DOCKER-USER` (v2.2):** `infra/vps/host/docker-user.sh`, aplicado por `oncargo-docker-user.service` después de Docker y en cada arranque:

```text
-A DOCKER-USER -m conntrack --ctstate RELATED,ESTABLISHED -j RETURN
-A DOCKER-USER -i eth0 -p tcp -m conntrack --ctorigdstport 80  --ctdir ORIGINAL -j RETURN
-A DOCKER-USER -i eth0 -p tcp -m conntrack --ctorigdstport 443 --ctdir ORIGINAL -j RETURN
-A DOCKER-USER -i eth0 -p udp -m conntrack --ctorigdstport 443 --ctdir ORIGINAL -j RETURN
-A DOCKER-USER -i eth0 -m conntrack --ctstate INVALID,NEW -j DROP
-A DOCKER-USER -j RETURN
```

La regla compara el puerto **original**, anterior al DNAT. La primera versión usaba `--dports 80,443` y falló la prueba: en `FORWARD` el puerto ya está traducido, y un contenedor de prueba publicado como `18080:80` siguió accesible porque escuchaba internamente en el 80. Con `--ctorigdstport`, el 18080 quedó bloqueado (evidencia E3 de [Seguridad](implementacion-seguridad.md)). La salida de los contenedores y las respuestas no se ven afectadas. IPv6: los puertos publicados en `[::]` los atiende `docker-proxy` en el host, así que ahí sí filtra UFW (cadena `INPUT` de IPv6).

| Mecanismo | Protege | Estado |
|-----------|---------|--------|
| UFW: entrada `deny`, permitidos 22/80/443 | Servicios del host | Desplegado en el VPS |
| Solo Caddy publica puertos (el resto, sin `ports:`) | Contenedores | Desplegado en el VPS |
| `DOCKER-USER`: desde `eth0` solo nuevas conexiones a 80/tcp, 443/tcp y 443/udp | Puertos publicados por Docker | **Implementado (v2.2)** |
| fail2ban: `sshd`, `recidive` y *jails* de Caddy en los *hooks* `input` y `forward` | SSH y 80/443 | **Implementado (v2.2)** ([Seguridad, 1.2](implementacion-seguridad.md)) |
| Filtro "solo Cloudflare" en `DOCKER-USER` con `ipset` | 80/443 | Pendiente (requiere Cloudflare) |

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
| Registro CAA (`0 issue "letsencrypt.org"`) | Pendiente (decisión del usuario, en el panel DNS); hoy no hay CAA |
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
    Cada prueba indica el comando, el resultado esperado según la configuración real y el criterio de aceptación. El 19-nov-2026 (v2.2) se ejecutaron desde Lima T1–T9, T11, T13 y T15; T10, T12 y T14 y las pruebas de carga (4.2) siguen **Pendientes de medición**. T10 consume el límite de login de la IP del evaluador durante 15 min, y desde la v2.2 puede activar la *jail* `oncargo-caddy-auth` (20 respuestas `429` → 1 h fuera de 80/443): conviene ejecutarla desde una IP en `ignoreip`.

### 4.1 Pruebas de conectividad y seguridad de red

| ID | Prueba | Resultado esperado | Resultado |
|----|--------|--------------------|-----------|
| T1 | DNS de los tres nombres | `oncargo.tech`, `www` y `api` resuelven a la IP del VPS | **Correcto (19-nov):** los tres → `<IP_PUBLICA_VPS>`; sin AAAA ni CAA |
| T2 | Acceso HTTPS a la web con tiempos | `200` (o `302` a `/login`); TLS válido | **Correcto:** `200`; desde Lima tcp 0.117 s, tls 0.241 s, ttfb 0.38 s, total 0.73 s (3 muestras) |
| T3 | Salud de la API | `200` con `"status":"UP"` | **Correcto:** `200`, `UP` con la comprobación de la base de datos |
| T4 | Acceso por IP sin TLS (`http://<IP>`) | Desde la v2.2: `308` al dominio con HTTPS | **Correcto:** `http://<IP>/login?x=1` → `308 https://oncargo.tech/login?x=1` |
| T5 | Escaneo de puertos externo (Nmap) | Abiertos solo 22/tcp, 80/tcp y 443/tcp (y 443/udp); 5432, 8080, 4321 y 9000 cerrados o filtrados | **Parcial:** escaneo TCP de 9 puertos con `bash /dev/tcp`: abiertos solo 22, 80 y 443. Falta el barrido completo con Nmap |
| T6 | Aislamiento de datos | 5432 y 9000 inalcanzables desde fuera; `web` no resuelve `db` ni `minio`; `backend` sí | **Correcto:** `backend` → `db` 172.19.0.2; `web` → `db` y `caddy` → `minio` sin respuesta (código 2); `db` sin salida a Internet |
| T7 | SSE a través de Caddy | `stream.ready` inmediato y `: ping` cada ~20 s sin cortes | **Correcto** (26 s): `stream.ready` a las 10:53:10 y `:ping` a las 10:53:30. Falta la ventana completa de 130 s |
| T8 | Redirección HTTP→HTTPS y cabeceras | `308` a HTTPS; HSTS, `nosniff`, `Referrer-Policy`, CSP presentes; sin cabecera `Server` | **Correcto:** `308`; HSTS, `nosniff`, `Referrer-Policy`, CSP, `Permissions-Policy` y `X-Frame-Options`; sin `Server` ni `Via` |
| T9 | Certificado y protocolos | Emitido por Let's Encrypt, vigente; TLS 1.2/1.3; HTTP/3 anunciado (`alt-svc`) | **Correcto:** Let's Encrypt `YE1`, vence el 15-feb-2027; TLS 1.2 y 1.3 (1.0/1.1 rechazados); `alt-svc: h3` y `curl --http3-only` responde en HTTP/3 |
| T10 | IP real del cliente | Un `X-Forwarded-For` falso no evade el límite por IP: `429` tras 50 intentos | Pendiente de medición |
| T11 | Compresión y SSE | HTML comprimido; los eventos SSE llegan sin retraso aunque el sitio tenga `encode` | **Correcto:** con `Accept-Encoding: gzip, zstd`, `text/event-stream` sin comprimir y `:ping` a los 20 s |
| T12 | Recuperación de contenedor | Tras `docker kill` del backend, vuelve a `healthy` sin intervención | Pendiente de medición |
| T13 | Rutas internas de `/q/` | `200` en `/q/health*`; `404` en el resto (`/q/openapi`, `/q/dev-ui`, `/q/metrics`) | **Correcto (v2.2):** `/q/health/ready` y `/q/health/live` `200`; `/q/openapi` `404` (antes `200`) |
| T14 | Inicio de sesión en el navegador (`checkOrigin`) | Login correcto sin `403 Cross-site POST form submissions are forbidden` | Pendiente de medición |
| T15 | Descarga del APK | `https://oncargo.tech/app/` muestra el QR; `oncargo.apk` se descarga con `Content-Type: application/vnd.android.package-archive` | **Correcto:** `200`, `application/vnd.android.package-archive` y `Content-Disposition: attachment` |

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
curl -s -o /dev/null -w "%{http_code} %{redirect_url}\n" "http://<IP_PUBLICA_VPS>/login?x=1"
# Resultado (v2.2): 308 https://oncargo.tech/login?x=1
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
# Resultado (v2.2): 200 200 404 404  (el Caddyfile responde 404 en /q/* salvo /q/health*)

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
| Registro de accesos HTTP de Caddy | `log` (snippet `access_log`) → `/var/log/oncargo/caddy/access.log` | Estado, ruta, IP y latencia de cada petición | **Implementado (v2.2)** (sección 5.2) |
| Intrusión SSH | fail2ban (`sshd`, `recidive`) | Fuerza bruta contra SSH y reincidentes | Desplegado en el VPS (`recidive`: v2.2) |
| Escaneo y abuso web | fail2ban (`oncargo-caddy-probe`, `oncargo-caddy-auth`) | Rutas de escaneo; IP que siguen insistiendo tras el `429` | **Implementado (v2.2)** |
| Recursos del host y servicio | `oncargo-health` (temporizador de systemd, cada 5 min) | Web, API, APK, contenedores, disco, memoria, swap, certificado, antigüedad del respaldo | **Implementado (v2.2)**; alertas por ntfy.sh al pasar a FALLA y al volver a OK: **implementado (v2.3)** |
| Aplicación | Logs y tabla `outbox_events` | Errores `ERROR`; eventos en `FAILED` | Implementado en el repositorio (revisión manual) |
| Disponibilidad externa (UptimeRobot o latido a healthchecks.io) | — | Caída del propio VPS | Pendiente (decisión del usuario: requiere una cuenta; `HEARTBEAT_URL` ya soportado) |
| Monitoreo interno (Uptime Kuma) | — | — | Descartado: `oncargo-health` cubre certificado, salud y latido de respaldos sin otro servicio residente |

**Sobre SNMP.** La rúbrica menciona SNMP porque asume equipos de red propios. En un VPS no hay conmutadores ni *routers* gestionables y el proveedor no expone SNMP; el equivalente funcional son las métricas del host y los registros anteriores.

### 5.2 Registro de accesos de Caddy

Desde la v2.2 el snippet `access_log` del Caddyfile (sección 1.3) escribe un JSON por petición en `/var/log/caddy/access.log` del contenedor, montado en `/var/log/oncargo/caddy/` del host (directorio `root:adm 750`, archivo `640`). Caddy rota el archivo (20 MiB × 10, máximo 14 días). Caddy ya oculta `Cookie` y `Authorization`; además un filtro `regexp` sobre `request>uri` reemplaza los tokens de URL. La verificación del 19-nov-2026 dio `"uri":"/baja?t=REDACTED&x=1"`, `"uri":"/s/REDACTED"` y `"uri":"/restablecer?token=REDACTED"`, y el token de prueba aparece 0 veces en el archivo.

Análisis (en el VPS; `jq` lo instala `harden.sh`):

```bash
L=/var/log/oncargo/caddy/access.log
# Distribución de códigos de estado
sudo jq -r 'select(.status) | .status' $L | sort | uniq -c | sort -rn
# Errores 5xx
sudo jq -r 'select(.status>=500) | [.ts, .request.client_ip, .request.method, .request.uri, .status] | @tsv' $L
# IPs más activas
sudo jq -r '.request.client_ip' $L | sort | uniq -c | sort -rn | head
# Intentos de login rechazados por IP
sudo jq -r 'select(.request.uri=="/api/v1/auth/login" and (.status==401 or .status==429)) | .request.client_ip' $L | sort | uniq -c | sort -rn
# Lo que fail2ban detectaría
sudo fail2ban-regex $L /etc/fail2ban/filter.d/oncargo-caddy-probe.conf
```

!!! note "Retención y privacidad"
    La IP es un dato personal (Ley 29733). Por eso el registro se conserva 14 días y nunca sale del VPS sin anonimizar ([Seguridad, 4.4](implementacion-seguridad.md)).

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
| H-01 | Bloque `http://{$PUBLIC_IP}` sin TLS | La web, la API y el login viajan sin cifrar si se usa la IP | El bloque ahora responde `308` a `https://oncargo.tech` | **Cerrado (v2.2)**: T4 |
| H-02 | `COOKIE_SECURE=false` en `state/.env` | La cookie de sesión también viaja por HTTP | `COOKIE_SECURE=true` en el VPS y por omisión en `bootstrap.sh` | **Cerrado (v2.2)** |
| H-03 | `DEMO_DATA=true`: cuentas demo con contraseña conocida (publicada en el repositorio) | Cualquiera puede entrar como PYME, transportista u operador de prueba | Corto plazo: `DEMO_PASSWORD` propia del VPS ([Seguridad, 1.4](implementacion-seguridad.md)); producción: `DEMO_DATA=false` y base nueva | **Mitigado (v2.3)**: el VPS usa `LOGYX_DEMO_PASSWORD` propia (Seguridad, E13). Sigue `DEMO_DATA=true` hasta pasar a producción |
| H-04 | El Caddyfile no restringe `/q/*` | `/q/openapi` era público (`200`) | `respond 404` para `/q/*` salvo `/q/health*` | **Cerrado (v2.2)**: T13 |
| H-05 | `encode` aplicado también al stream SSE | Posible retraso de eventos | Verificado con T11: Caddy no comprime `text/event-stream` | **Cerrado (v2.2)**, sin cambios |
| H-06 | La red `internal` no tiene `internal: true` | `db` y `minio` conservan salida a Internet | `internal: true` en `compose.yml` | **Cerrado (v2.2)**: T6 |
| H-07 | Sin CDN ni WAF delante del origen | El VPS recibe todo el tráfico directamente, incluido un DDoS | Plan de Cloudflare en [Seguridad, 4.1](implementacion-seguridad.md) (sin *Bot Fight Mode* en la API) | Aceptado en pruebas; pendiente (decisión del usuario) |
| H-09 | Caddy sin registro de accesos | No hay rastro de peticiones para investigar un incidente | Snippet `access_log` con tokens redactados (sección 5.2) | **Cerrado (v2.2)** |
| H-12 | Docker se salta UFW en los puertos publicados | Un `ports:` añadido por error quedaría expuesto | `DOCKER-USER` como lista blanca por puerto original (sección 1.4) | **Cerrado (v2.2)**: prueba con el puerto 18080 |
| H-10 | Astro sin `security.allowedDomains` detrás de Caddy | La web ve como IP de todos los usuarios la del contenedor `caddy` (Astro 7 solo confía en `X-Forwarded-For` si el host está validado) y la reenvía al backend: los límites por IP de login (50), registro (10), restablecer contraseña (20/30) y cotización pública (30, cada 15 min) se **comparten entre todos los usuarios de la web**. Unos pocos intentos fallidos de cualquiera bloquean el login web de todos | Añadir `security: { allowedDomains: [{ hostname: 'oncargo.tech', protocol: 'https' }] }` en `web/astro.config.mjs` y verificar con T13 | **Corregido en el código** (`848ba00` de `oncargo-code`, con `oncargo.tech` y `www.oncargo.tech`). Pendiente: desplegarlo y confirmarlo con A9 |
| H-11 | El APK publicado en `/app/` es una compilación **debug** (`publish-apk.sh` espera `assembleDebug`) | Permite tráfico sin cifrar y muestra accesos demo; su URL de API depende de `-PapiBaseUrl` al compilar (por omisión `http://10.0.2.2:8080`, solo emulador) | Compilar con `-PapiBaseUrl=https://api.oncargo.tech` y, para producción, publicar un *release* firmado (el *release* usa por omisión `https://api.logyx.pe`, que no es el dominio desplegado) | **Cerrado para pruebas** (`ddd3f33`, `f11fea9`): `/app/` publica la variante *staging* (R8, API `https://api.oncargo.tech`, firmada con un keystore de pruebas) y `publish-apk.sh` rechaza un APK firmado con la clave de *debug*. Producción: *release* firmado, pendiente |
| H-08 | Un solo VPS | Servicio indisponible si cae el proveedor | Reconstrucción documentada ([Datacenter, sección 4.3](implementacion-datacenter.md)) | Aceptado (equivalente Tier I) |

---

## Anexos

### Anexo A — Evidencias de ejecución

| Evidencia | Origen | Estado |
|-----------|--------|--------|
| `infra/vps/compose.yml`, `Caddyfile`, `bootstrap.sh`, `deploy.sh`, `publish-apk.sh`, `README.md` | Repositorio (commit `cad2b77`) | Disponible |
| `infra/vps/harden.sh`, `host/` (`docker-user.sh`, fail2ban, sshd) y el Caddyfile v2.2 | Repositorio (commits `9d1f6a2`, `b44014a`) | Disponible |
| `docker compose ps` con los cinco servicios en marcha (`db`, `minio`, `backend`, `web`, `caddy`) | VPS | Capturado (19-nov-2026): los cinco `Up`, cuatro con `healthy` (Caddy no define *healthcheck*) |
| `docker network inspect oncargo_edge oncargo_internal` (subredes asignadas) | VPS | Capturado: `edge` 172.18.0.0/16; `internal` 172.19.0.0/16 con `internal=true` |
| `sudo ufw status verbose`, `iptables -S DOCKER-USER` y `fail2ban-client status` | VPS | Capturado ([Seguridad, Sección 0](implementacion-seguridad.md), E2–E4) |
| Panel DNS de Hostinger con los registros A | Hostinger | Pendiente de captura |
| Salida de T1 a T15 | Varios | T1–T9, T11, T13 y T15 registradas en la sección 4.1; T10, T12 y T14 pendientes |
| Informe de k6 (humo y carga) y de `ab` | Lima | Pendiente de medición |
| `nmap-full.txt` del escaneo externo | Equipo externo | Pendiente (se hizo un escaneo TCP parcial sin Nmap: E3 de Seguridad) |

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
sudo fail2ban-client status                          # sshd, recidive, oncargo-caddy-probe, oncargo-caddy-auth
sudo fail2ban-client unban <IP>                       # desbloquear (p. ej. la IP propia tras una prueba)
sudo iptables -L DOCKER-USER -v -n                    # contadores de la lista blanca

# Desde fuera: la base de datos no debe responder
nmap -Pn -p 22,80,443,5432,9000 <IP_PUBLICA_VPS>
```

---

*OnCargo · S2 Entregable 1 · Implementación de Red · Competencias C1.2–C1.3 · Versión 2.2 · Noviembre 2026*
