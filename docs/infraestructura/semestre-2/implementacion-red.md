# S2 · Entregable 1 — Implementación y Testing de Red
> Competencias C1.2 (Implementación) · C1.3 (Testing y control)  
> Proyecto: OnCargo — Sistema Operativo Logístico Colaborativo para PYMEs  
> Equipo: Jorge Gutiérrez Miranda · Fabrizio Sanchez Saravia · Alex Coila Jarita  
> Semestre 2 · Agosto–Noviembre 2026 · **Versión 2.0 (rediseño, noviembre 2026)** · Versión original 1.0 sobre AWS


!!! info "Versión 2.0: implementación de red sobre un VPS Hostinger con Caddy y Cloudflare"
    La versión 1.0 describía la implementación con Terraform sobre AWS (VPC, subnets, NAT Gateways, ALB, Security Groups, VPC Endpoints). Al rediseñar la infraestructura por costo y simplicidad, este documento se **reescribió por completo** para el diseño de [Diseño de Red v2.0](../semestre-1/diseno-red.md): un único **VPS Hostinger KVM 2** con Docker Compose, **Caddy** como proxy inverso y **Cloudflare** como borde. El contexto del cambio está en [Rebrand OnCargo y migración a Hostinger](../../software/cambios-diseno-inicial.md#7-rebrand-oncargo-y-migracion-a-hostinger).

    **Alcance honesto de este documento:** las configuraciones (Caddyfile, reglas de firewall, compose, scripts) son las que se aplican en el VPS. Lo que ya existe en el repositorio se marca como *Implementado en el repositorio*; lo que se ejecutará al aprovisionar el servidor, como *Definido para el VPS (pendiente de ejecutar)*. **Las pruebas de la sección 4 son un plan de verificación con resultado esperado; no se presentan mediciones que aún no se han realizado.**

---

## Resumen Ejecutivo

Este documento especifica la implementación de la red de OnCargo en tres anillos: (1) **Cloudflare** (DNS, CDN, WAF y mitigación DDoS del plan gratuito) como único punto de entrada público; (2) el **host Ubuntu 24.04** del VPS, con UFW para el acceso administrativo y un filtro en la cadena `DOCKER-USER` que solo admite los rangos de Cloudflare en los puertos 80 y 443; y (3) la **red de contenedores** de Docker Compose, con las redes `edge` (172.20.0.0/24) e `internal` (172.21.0.0/24), donde la base de datos no publica ningún puerto.

Se entregan el `Caddyfile` completo (HTTPS automático, SSE sin *buffering*, cabeceras, IP real del cliente desde Cloudflare), el compose de red, el script que carga los rangos de Cloudflare, la configuración de Cloudflare, el esquema de direccionamiento y un **plan de pruebas** de conectividad, seguridad de red, rendimiento y SSE con resultado esperado para cada prueba. Todas las pruebas están en estado **Pendiente de ejecución en el VPS**: el servidor se aprovisiona al cierre del semestre y los resultados se registrarán en el Anexo A. El monitoreo es ligero (logs de Caddy, fail2ban, Uptime Kuma y paneles de Cloudflare) porque un VPS de 8 GB no admite pilas de observabilidad pesadas.

**Leyenda de estados usada en todo el documento:**

| Estado | Significado |
|--------|-------------|
| **Implementado en el repositorio** | Existe en `infra/` o en el código del monorepo `logyx` (compose, Dockerfiles, roles de BD, *rate limiting*, cabeceras). |
| **Definido para el VPS (pendiente de ejecutar)** | La configuración está escrita en este documento y se aplica al aprovisionar el VPS; aún no se ejecutó. |
| **Pendiente** | Depende de una integración, una verificación o una decisión posterior. |

---

## Sección 1 — Configuración de la Infraestructura de Red (C1.2)

### 1.1 Estructura de archivos de configuración en el VPS

El repositorio se clona en `/opt/oncargo` y los archivos de red conviven con `infra/` (los marcados con asterisco **no existen todavía** en el repositorio y se agregan al aprovisionar):

```
/opt/oncargo/                      # clon del monorepo (usuario deploy)
├── backend/  web/                 # contextos de build (Dockerfile existentes)
└── infra/
    ├── docker-compose.yml         # existente: desarrollo y staging local
    ├── docker-compose.prod.yml *  # producción: Caddy + redes con subred fija, sin MinIO
    ├── Caddyfile *                # proxy inverso, TLS, SSE, cabeceras
    ├── caddy/cloudflare-ips.caddy *  # generado por firewall-cloudflare.sh
    ├── .env                       # secretos (permiso 600, fuera de Git)
    ├── secrets/                   # claves JWT (permiso 700, fuera de Git)
    ├── db/init-roles.sh           # existente: roles de mínimo privilegio
    └── scripts/
        ├── gen-jwt-keys.sh        # existente
        └── firewall-cloudflare.sh *   # ipset + DOCKER-USER + lista de proxies de Caddy
```

### 1.2 Compose de red (fragmento de `docker-compose.prod.yml`)

Este fragmento muestra solo lo que define la red: subredes fijas, puertos publicados y comprobaciones de salud. El archivo completo, con variables de entorno, límites de memoria y endurecimiento, está en [Implementación de Centro de Datos, sección 1.4](implementacion-datacenter.md).

```yaml
# infra/docker-compose.prod.yml (fragmento de red)
name: oncargo

services:
  caddy:
    image: caddy:2-alpine
    restart: unless-stopped
    ports:
      - "80:80"          # único servicio que publica en 0.0.0.0
      - "443:443"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile:ro
      - ./caddy/cloudflare-ips.caddy:/etc/caddy/cloudflare-ips.caddy:ro
      - caddy_data:/data           # certificados y cuenta ACME
      - caddy_config:/config
      - /var/log/caddy:/var/log/caddy
    networks: [edge]
    depends_on:
      web:     { condition: service_healthy }
      backend: { condition: service_healthy }
    healthcheck:
      test: ["CMD-SHELL", "wget -qO- http://127.0.0.1:2019/config/ >/dev/null || exit 1"]
      interval: 30s
      timeout: 5s
      retries: 3

  web:                           # sin "ports:": solo Caddy lo alcanza (red edge)
    networks: [edge]
    # healthcheck definido en web/Dockerfile (GET /login en :4321)

  backend:                       # sin "ports:": Caddy (api.oncargo.tech) y web lo alcanzan por la red edge
    networks: [edge, internal]
    # healthcheck definido en backend/Dockerfile (GET /q/health/ready en :8080)

  db:                            # sin "ports:", solo en la red internal
    networks: [internal]
    # healthcheck: pg_isready -U postgres -d logyx

networks:
  edge:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/24
  internal:
    driver: bridge
    internal: true               # sin salida a Internet ni al host: la BD no puede iniciar conexiones hacia fuera
    ipam:
      config:
        - subnet: 172.21.0.0/24

volumes:
  caddy_data:
  caddy_config:
```

| Aspecto | Estado |
|---------|--------|
| Redes `internal` y `edge`, `db` sin puertos publicados, `web`/`backend` solo en `127.0.0.1` (compose de desarrollo) | **Implementado en el repositorio** (`infra/docker-compose.yml`) |
| `healthcheck` de `backend` (`/q/health/ready`) y `web` (`/login`) | **Implementado en el repositorio** (Dockerfiles) |
| Subredes fijas, servicio `caddy`, `internal: true`, retiro de los puertos de `web`/`backend` | **Definido para el VPS (pendiente de ejecutar)** |

!!! note "Por qué `internal: true`"
    `backend` pertenece a las dos redes: usa `edge` para salir hacia R2 (HTTPS) y `internal` para hablar con `db`. `db` queda solo en `internal`, que no tiene puerta de enlace hacia Internet; así un compromiso de la base de datos no puede abrir conexiones salientes. Es una mejora respecto del compose actual (donde `internal` es una red de Docker común) y debe validarse en el primer arranque.

### 1.3 Caddyfile (proxy inverso, TLS y SSE)

```caddyfile
# infra/Caddyfile
{
	# Correo de la cuenta ACME (Let's Encrypt): variable de entorno del contenedor
	email {$ACME_EMAIL}

	servers {
		# Solo se confía en la IP de Cloudflare como proxy. El archivo lo genera
		# firewall-cloudflare.sh con la lista vigente (https://www.cloudflare.com/ips).
		import /etc/caddy/cloudflare-ips.caddy
		# Cloudflare sobrescribe CF-Connecting-IP con la IP real de quien conecta;
		# X-Forwarded-For NO sirve: Cloudflare conserva lo que envíe el cliente y solo agrega al final.
		client_ip_headers CF-Connecting-IP
	}
}

# ---- Fragmentos reutilizables ----------------------------------------------
(common) {
	# Cabeceras base. El prefijo "?" solo las agrega si la aplicación no las envió
	# (la web ya envía CSP y las demás; la API envía HSTS y nosniff).
	header {
		?Strict-Transport-Security "max-age=31536000; includeSubDomains"
		?X-Content-Type-Options "nosniff"
		?X-Frame-Options "DENY"
		?Referrer-Policy "strict-origin-when-cross-origin"
		?Permissions-Policy "camera=(), microphone=(), geolocation=()"
		-Server
	}
	log {
		output file /var/log/caddy/access.log {
			roll_size 50MiB
			roll_keep 10
			roll_keep_for 720h
		}
		format json
	}
}

# Compresión para todo EXCEPTO los streams SSE (la compresión retiene los eventos).
(compress) {
	@compressible not path /eventos /api/v1/events/stream
	encode @compressible zstd gzip
}

# Parámetros de proxy comunes
(proxy_headers) {
	# IP real del cliente, no la de Cloudflare ni la que el cliente declaró en X-Forwarded-For.
	# El backend la usa para el rate limiting (AuthRateLimits) y solo la acepta de TRUSTED_PROXIES.
	header_up X-Forwarded-For {client_ip}
	header_up X-Real-IP {client_ip}
}

# ---- oncargo.tech: aplicación web (Astro SSR) ------------------------------
www.oncargo.tech {
	redir https://oncargo.tech{uri} permanent
}

oncargo.tech {
	import common
	import compress
	reverse_proxy web:4321 {
		import proxy_headers
		flush_interval -1                   # SSE de /eventos: sin buffering
		transport http {
			dial_timeout 5s
			response_header_timeout 60s     # las cabeceras SSE llegan de inmediato
			# Sin read_timeout: el stream puede durar mientras viva el JWT (8 h); el latido es de 20 s
		}
	}
}

# ---- api.oncargo.tech: API para la app Android y SSE ----------------------
api.oncargo.tech {
	import common
	import compress

	# Solo se publica la comprobación de salud (monitoreo externo); lo demás de /q/ no sale de la red
	@internal_only path /q/metrics* /q/openapi* /q/swagger-ui* /q/dev* /q/info*
	respond @internal_only 404

	request_body {
		max_size 13MB                       # el backend admite cuerpos de 12 MB (subida de 10 MB)
	}

	reverse_proxy backend:8080 {
		import proxy_headers
		flush_interval -1                   # /api/v1/events/stream: sin buffering
		transport http {
			dial_timeout 5s
			response_header_timeout 60s
		}
	}
}
```

Puntos de diseño que explican la configuración:

| Decisión | Razón | Verificación (sección 4) |
|----------|-------|--------------------------|
| `trusted_proxies` solo con rangos de Cloudflare y `client_ip_headers CF-Connecting-IP` | Evita que un cliente falsifique su IP escribiendo `X-Forwarded-For` y así eluda el *rate limiting* por IP | T10 |
| `header_up X-Forwarded-For {client_ip}` | Cloudflare **conserva** el `X-Forwarded-For` que envíe el cliente y agrega la IP real al final; si el backend leyera el primer valor, tomaría el falsificado. Con el valor reemplazado llega una sola IP, la verificada | T10 |
| `flush_interval -1` y sin compresión en `/eventos` y `/api/v1/events/stream` | Requisito de ADR-0007: un solo evento debe llegar al navegador sin esperar a llenar un *buffer* | T7, T11 |
| Sin `read_timeout` en el transporte | El límite real de lectura lo impone Cloudflare (100 s sin datos); el latido de 20 s del backend queda muy por debajo | T7 |
| `respond 404` para `/q/metrics`, `/q/openapi`, `/q/swagger-ui`, `/q/dev` | Reduce la superficie pública; el contrato OpenAPI se versiona en el repositorio (`docs/api/`) | T13 |
| `request_body max_size 13MB` | Alineado con el límite de la aplicación (12 MB); Cloudflare gratuito admite hasta 100 MB | — |
| Logs JSON de acceso con rotación (50 MiB × 10, 30 días) | Insumo de fail2ban y de la revisión semanal; Caddy reemplaza por `REDACTED` las cabeceras `Authorization` y `Cookie` | T10 |

**Estado:** Caddyfile **Definido para el VPS (pendiente de ejecutar)**. Cabeceras de seguridad, HSTS y CSP de la aplicación: **Implementado en el repositorio** (`backend/src/main/resources/application.properties` y `web/src/middleware.ts`).

!!! warning "Emisión del certificado de origen detrás de Cloudflare"
    Con el registro DNS en modo *proxied*, el desafío HTTP-01 de Let's Encrypt llega al origen **a través de Cloudflare**, y el desafío TLS-ALPN-01 no funciona. Caddy reintenta con HTTP-01 por el puerto 80, que el filtro permite porque la petición proviene de Cloudflare. Esto debe **comprobarse en el primer arranque** (`docker compose logs caddy | grep -i "certificate obtained"`). Si la emisión falla, la alternativa documentada es un **certificado de origen de Cloudflare** (Origin CA, gratuito, hasta 15 años) montado en Caddy con `tls /etc/caddy/origin.pem /etc/caddy/origin.key`, que es válido para el modo *Full (strict)* sin depender de Let's Encrypt.

### 1.4 Firewall: UFW para el host y filtro de Cloudflare en `DOCKER-USER`

Docker publica los puertos con reglas propias en las cadenas `nat` y `FORWARD` de `iptables`, **antes** de que UFW las evalúe. Por eso `ufw allow from <rango Cloudflare> to any port 443` **no restringe** a un contenedor con `ports: "443:443"`. El diseño de la versión 2.0 de [Diseño de Red](../semestre-1/diseno-red.md) ya advertía que solo Caddy publica puertos; la implementación completa esa regla con dos mecanismos:

| Mecanismo | Protege | Qué hace |
|-----------|---------|----------|
| **UFW** | Servicios del host (SSH) | Política de entrada `deny`; permite solo 22/tcp con límite de conexiones |
| **`DOCKER-USER` + ipset** | Puertos publicados por Docker (80 y 443 de Caddy) | Descarta lo que no provenga de los rangos de Cloudflare en la interfaz pública |

**UFW (aprovisionamiento inicial):**

```bash
# Ejecutar como admin (sudo). Primero SSH: de lo contrario se pierde el acceso.
sudo ufw default deny incoming
sudo ufw default allow outgoing      # R2, apt, Let's Encrypt, GitHub
sudo ufw limit 22/tcp comment 'SSH (clave + fail2ban)'
# Si el equipo tiene IP fija:  sudo ufw allow from <IP_EQUIPO> to any port 22 proto tcp
sudo ufw enable
sudo ufw status verbose
```

**Script `firewall-cloudflare.sh`** (carga los rangos vigentes en un `ipset`, filtra `DOCKER-USER` y regenera la lista de proxies confiables de Caddy):

```bash
#!/usr/bin/env bash
# infra/scripts/firewall-cloudflare.sh
# Idempotente. Se ejecuta al arrancar (firewall-cloudflare.service) y cada semana (timer).
# Requiere: apt install -y ipset curl iptables
set -euo pipefail

WAN_IF="${WAN_IF:-$(ip -4 route show default | awk '{print $5; exit}')}"
CADDY_SNIPPET=/opt/oncargo/infra/caddy/cloudflare-ips.caddy
tmp4=$(mktemp); tmp6=$(mktemp); trap 'rm -f "$tmp4" "$tmp6"' EXIT

curl -fsS --max-time 15 https://www.cloudflare.com/ips-v4 -o "$tmp4"
curl -fsS --max-time 15 https://www.cloudflare.com/ips-v6 -o "$tmp6"

# Validación mínima: solo CIDR; si la descarga devolvió otra cosa, no se toca el firewall
grep -Eqv '^[0-9a-fA-F:./]+$' "$tmp4" "$tmp6" && { echo "Lista de rangos inválida"; exit 1; }
[ "$(wc -l < "$tmp4")" -ge 10 ] || { echo "Lista IPv4 sospechosamente corta"; exit 1; }

# 1) ipset IPv4 (reemplazo atómico)
ipset create -exist cloudflare4 hash:net family inet
ipset create -exist cloudflare4_new hash:net family inet
ipset flush cloudflare4_new
while read -r cidr; do ipset add -exist cloudflare4_new "$cidr"; done < "$tmp4"
ipset swap cloudflare4_new cloudflare4
ipset destroy cloudflare4_new

# 2) Cadena propia: pasa solo Cloudflare; descarta el resto
iptables -N CLOUDFLARE_ONLY 2>/dev/null || true
iptables -F CLOUDFLARE_ONLY
iptables -A CLOUDFLARE_ONLY -m set --match-set cloudflare4 src -j RETURN
iptables -A CLOUDFLARE_ONLY -j DROP

# 3) Enganche en DOCKER-USER (Docker lo evalúa antes de sus propias reglas), una sola vez
iptables -C DOCKER-USER -i "$WAN_IF" -p tcp -m multiport --dports 80,443 -j CLOUDFLARE_ONLY 2>/dev/null \
  || iptables -I DOCKER-USER 1 -i "$WAN_IF" -p tcp -m multiport --dports 80,443 -j CLOUDFLARE_ONLY

# 4) Lista de proxies confiables para Caddy (IPv4 + IPv6)
{ printf 'trusted_proxies static'; cat "$tmp4" "$tmp6" | tr '\n' ' '; printf '\n'; } > "$CADDY_SNIPPET".new
mv "$CADDY_SNIPPET".new "$CADDY_SNIPPET"

# 5) Recargar Caddy si ya está en ejecución (sin cortar conexiones)
if docker ps --format '{{.Names}}' | grep -q '^oncargo-caddy-1$'; then
  docker exec oncargo-caddy-1 caddy reload --config /etc/caddy/Caddyfile
fi
echo "Cloudflare: $(wc -l < "$tmp4") rangos IPv4, $(wc -l < "$tmp6") IPv6; interfaz pública: $WAN_IF"
```

**Unidades `systemd`** (carga al arrancar y actualización semanal):

```ini
# /etc/systemd/system/firewall-cloudflare.service
[Unit]
Description=Filtro de Cloudflare para los puertos 80/443 publicados por Docker
After=docker.service network-online.target
Requires=docker.service
PartOf=docker.service

[Service]
Type=oneshot
ExecStart=/opt/oncargo/infra/scripts/firewall-cloudflare.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

```ini
# /etc/systemd/system/firewall-cloudflare.timer
[Unit]
Description=Actualización semanal de los rangos de Cloudflare

[Timer]
OnCalendar=Mon 04:00 America/Lima
Persistent=true

[Install]
WantedBy=timers.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now firewall-cloudflare.service firewall-cloudflare.timer
```

!!! note "IPv6"
    Docker no publica puertos en IPv6 por omisión y no se crea ningún registro AAAA, de modo que el origen solo es alcanzable por IPv4. Los rangos IPv6 de Cloudflare se incluyen únicamente en `trusted_proxies` de Caddy.

!!! note "Firewall del panel de Hostinger"
    Si el plan KVM 2 incluye un firewall de red en el panel de Hostinger, puede añadirse como tercera capa (22, 80 y 443 entrantes). Su disponibilidad y sintaxis **se verifican al aprovisionar**; el diseño no depende de él.

**Estado:** reglas UFW, `DOCKER-USER`, `ipset` y unidades `systemd`: **Definido para el VPS (pendiente de ejecutar)**.

### 1.5 Configuración de Cloudflare

| Área | Ajuste | Valor | Motivo | Estado |
|------|--------|-------|--------|--------|
| DNS | `oncargo.tech` (A) | IP del VPS, **Proxied** | Oculta el origen | Definido para el VPS (pendiente de ejecutar) |
| DNS | `www` (CNAME) | `oncargo.tech`, Proxied | Caddy redirige al apex | Definido |
| DNS | `api` (A) | IP del VPS, Proxied | API de la app Android | Definido |
| DNS | Registros AAAA | Ninguno | El origen no escucha por IPv6 | Definido |
| DNS | DNSSEC | Activado (registro DS en el registrador) | Integridad de las respuestas DNS | Pendiente (acción en el registrador) |
| SSL/TLS | Modo de cifrado | **Full (strict)** | El origen presenta un certificado válido (Let's Encrypt u Origin CA) | Definido |
| SSL/TLS | Versión mínima de TLS | 1.2 (TLS 1.3 activado) | Estándar de transporte | Definido |
| SSL/TLS | *Always Use HTTPS* | Activado | Redirección en el borde | Definido (verificar la emisión ACME, sección 1.3) |
| SSL/TLS | HSTS de Cloudflare | Desactivado | Ya lo envían la API y la web; se evita duplicarlo | Definido |
| Velocidad | *Rocket Loader* y ofuscación de correos | **Desactivados** | Inyectan scripts que rompen la hidratación de Astro y la CSP | Definido |
| Caché | Regla 1: `api.oncargo.tech` | *Bypass cache* | La API es dinámica y envía `Cache-Control: no-store` | Definido |
| Caché | Regla 2: `oncargo.tech/_astro/*` | *Eligible for cache*, TTL de borde 1 mes | Activos con *hash* en el nombre | Definido |
| Caché | Regla 3: `/eventos`, `/login*` | *Bypass cache* | Stream SSE y sesión | Definido |
| Seguridad | WAF: conjunto gestionado gratuito | Activado | Reglas de alto impacto (el conjunto OWASP completo es de planes de pago; verificar en el panel) | Definido |
| Seguridad | Regla de *rate limiting* (1 regla gratuita) | `POST /api/v1/auth/login` y `/login` | Primera barrera antes de `AuthRateLimits` (límites y duración del bloqueo acotados en el plan gratuito; verificar) | Definido |
| Seguridad | *Bot Fight Mode* | Activado, **con verificación obligatoria** | Puede desafiar a clientes que no son navegadores (app Android, k6, Uptime Kuma); si interfiere, se desactiva y se confía en el *rate limiting* | Pendiente de verificar con la app |
| Seguridad | Regla temporal de exclusión por IP | Solo durante las pruebas de carga | Evita que *Bot Fight Mode* o el WAF alteren las mediciones | Definido |
| Red | Tiempo máximo de lectura del proxy | 100 s (fijo, plan gratuito) | El latido SSE de 20 s lo respeta | Definido |
| Red | HTTP/3 | Activado (solo entre cliente y borde) | Menor latencia móvil | Definido |
| Origen | *Authenticated Origin Pulls* (mTLS desde Cloudflare) | Opcional | Capa adicional sobre el filtro por IP | Pendiente (mejora) |

---

## Sección 2 — Implementación de Direccionamiento y Routing

### 2.1 Esquema IP definitivo

| Segmento | CIDR / dirección | Componentes | Asignación | Estado |
|----------|------------------|-------------|------------|--------|
| IP pública del VPS | 1 × IPv4 (`<IP_PUBLICA_VPS>`, la entrega Hostinger) | Interfaz `eth0` (nombre a confirmar con `ip -br a`) | Estática del proveedor | Pendiente (se registra al aprovisionar) |
| Red `edge` | 172.20.0.0/24 (puerta de enlace 172.20.0.1) | `caddy`, `web`, `backend` | Direcciones dinámicas dentro del rango; se resuelve por nombre | Definido para el VPS |
| Red `internal` | 172.21.0.0/24 (sin puerta de enlace externa) | `backend`, `db` | Dinámicas; se resuelve por nombre | Definido para el VPS |
| Bridge por omisión de Docker | 172.17.0.0/16 | Sin contenedores de OnCargo | No se usa | Informativo |
| Cloudflare (borde) | Rangos publicados por Cloudflare | Único origen admitido en 80/443 | Cargados por `firewall-cloudflare.sh` | Definido para el VPS |

Solo se fijan las **subredes**, no las direcciones de cada contenedor: Docker las reasigna al recrear el servicio y todo el tráfico interno usa nombres DNS. La única dirección que depende del rango es `TRUSTED_PROXIES=172.20.0.0/24` en el backend (valor por omisión del repositorio: `127.0.0.1,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16`, que ya cubre la red `edge`; se acota para minimizar la confianza).

### 2.2 DNS

**DNS público (Cloudflare):** ver la sección 1.5. Resolución esperada: `oncargo.tech`, `www.oncargo.tech` y `api.oncargo.tech` devuelven direcciones de Cloudflare, nunca la IP del VPS (prueba T1).

**DNS interno (servidor DNS embebido de Docker, 127.0.0.11):**

| Nombre | Resuelve a | Visible desde |
|--------|-----------|---------------|
| `web` | Contenedor `web` | `caddy`, `backend` (red `edge`) |
| `backend` | Contenedor `backend` | `caddy`, `web` (red `edge`); `db` (red `internal`) |
| `db` | Contenedor `db` | Solo `backend` (red `internal`) |

La separación de redes hace que `web` y `caddy` **no puedan ni resolver** el nombre `db` (prueba T6). El DNS interno reemplaza la zona privada de la versión 1.0 y no requiere configuración adicional.

### 2.3 Routing

En un VPS con Docker el *routing* lo resuelve el kernel del host; no hay *routers* configurables. Lo relevante es verificar tres tablas:

| Tabla | Contenido esperado | Comando de verificación |
|-------|--------------------|------------------------|
| Rutas del host | `default via <gateway del proveedor> dev eth0`; `172.20.0.0/24 dev br-xxxx`; `172.21.0.0/24 dev br-yyyy` | `ip route` |
| NAT de salida (`nat/POSTROUTING`) | `MASQUERADE` para 172.20.0.0/24 (salida de `backend` hacia R2); **sin** regla para 172.21.0.0/24 | `sudo iptables -t nat -S POSTROUTING` |
| NAT de entrada (`nat/DOCKER`) | `DNAT` de 80 y 443 hacia Caddy y de ningún otro puerto | `sudo iptables -t nat -S DOCKER` |

**Rutas de tráfico (equivalente al *routing* estático de una red tradicional):**

| Origen | Destino | Camino | Observación |
|--------|---------|--------|-------------|
| Usuario | `oncargo.tech` | Cloudflare → `eth0:443` → DNAT → `caddy` → `web:4321` | Pasa por el filtro `CLOUDFLARE_ONLY` |
| App Android | `api.oncargo.tech` | Cloudflare → `eth0:443` → `caddy` → `backend:8080` | Idem |
| `web` | `backend:8080` | Red `edge`, sin salir del host | La cookie `httpOnly` se convierte en `Bearer` |
| `backend` | `db:5432` | Red `internal` | Sin rutas externas |
| `backend` | R2 (`<ACCOUNT_ID>.r2.cloudflarestorage.com:443`) | Red `edge` → NAT → `eth0` | Único tráfico saliente de datos |

---

## Sección 3 — Controles de Acceso y Estándares

### 3.1 Controles por capa (equivalente a las ACL)

| Capa | Control | Regla | Justificación | Estado |
|------|---------|-------|---------------|--------|
| Borde | Cloudflare WAF y *rate limiting* | Conjunto gestionado, regla de *login*, *Bot Fight Mode* | Filtra tráfico malicioso antes del origen | Definido para el VPS (pendiente de ejecutar) |
| Host | `DOCKER-USER` + ipset | 80/443 solo desde rangos de Cloudflare | Quien consulte la IP de origen no obtiene respuesta | Definido para el VPS (pendiente de ejecutar) |
| Host | UFW | Entrada `deny`; 22/tcp con `limit` | Superficie administrativa mínima | Definido para el VPS (pendiente de ejecutar) |
| Host | SSH | Solo clave pública, sin `root`, fail2ban | Ver [Implementación de Seguridad](implementacion-seguridad.md) | Definido para el VPS (pendiente de ejecutar) |
| Proxy | Caddy | TLS, cabeceras, bloqueo de `/q/*` internos, límite de cuerpo | Punto único de entrada | Definido para el VPS (pendiente de ejecutar) |
| Contenedores | Redes `edge`/`internal` | `db` solo en `internal`; sin `ports:` salvo Caddy | Segmentación de datos | Implementado en el repositorio (compose de desarrollo) |
| Aplicación | `AuthRateLimits` | Login 50/15 min por IP; bloqueo tras 10 fallos por correo; registro 10/15 min por IP | Contiene la fuerza bruta | Implementado en el repositorio |
| Aplicación | CSP, HSTS, `checkOrigin`, `X-Frame-Options`, `nosniff` | Ver [Seguridad](../../software/entregable-2/seguridad.md) | Defensa contra XSS, CSRF, *clickjacking* | Implementado en el repositorio |
| Aplicación | Límite de 5 streams SSE por usuario | `429 LOGYX-RTM-001` | Agotamiento de conexiones | Implementado en el repositorio |
| Datos | Roles `logyx_owner` / `logyx_app` / `logyx_api` y RLS | Mínimo privilegio | Aislamiento por organización | Implementado en el repositorio |

### 3.2 Cumplimiento de estándares de red

| Estándar | Control aplicado | Evidencia prevista |
|----------|------------------|--------------------|
| TIA/EIA-568 (estructura) | No aplica al cableado (lo administra el proveedor); la estructura se expresa en capas lógicas: borde, proxy, aplicación, datos | Diagrama de la sección 1.2 y `docker network ls` |
| IEEE 802.1Q (segmentación) | Redes Docker separadas (`edge`, `internal`) y filtros por puerto | `docker network inspect oncargo_edge oncargo_internal` |
| IEEE 802.3 (Ethernet) | Interfaz virtual `virtio` de KVM; sin control sobre la capa física | `ethtool -i eth0` en el VPS |
| ISO/IEC 27001 (control de acceso) | Mínimo privilegio, segmentación, registro de accesos, cifrado en tránsito | Configuraciones de las secciones 1.3 y 1.4 + logs de Caddy |
| RFC 8446 (TLS 1.3) / HSTS (RFC 6797) | TLS 1.2/1.3 en el borde y en el origen; HSTS de 1 año | Pruebas T8 y T9 |
| RFC 6585 (código 429) | Respuesta `429` con `Retry-After` en el *rate limiting* | Prueba de la sección 3 de [Seguridad](implementacion-seguridad.md) |

---

## Sección 4 — Pruebas de Conectividad y Rendimiento (C1.3)

!!! warning "Estado de las pruebas"
    Todas las pruebas de esta sección son un **plan de verificación**: se define el comando, el resultado esperado y el criterio de aceptación. La columna *Resultado* permanece en **Pendiente de ejecución en el VPS** hasta que se ejecuten y se adjunte la evidencia en el Anexo A. Las cifras de latencia y rendimiento son **objetivos de diseño o estimaciones**, no mediciones.

### 4.1 Pruebas de conectividad y seguridad de red

| ID | Prueba | Resultado esperado | Resultado |
|----|--------|--------------------|-----------|
| T1 | DNS apunta a Cloudflare, no al origen | Direcciones de Cloudflare; ninguna coincide con la IP del VPS | Pendiente de ejecución en el VPS |
| T2 | Acceso HTTPS a la web con tiempos | `200` (o `302` a `/login`); TLS válido | Pendiente de ejecución en el VPS |
| T3 | Salud de la API | `200` con `"status":"UP"` | Pendiente de ejecución en el VPS |
| T4 | Acceso directo al origen sin pasar por Cloudflare | Sin respuesta (tiempo de espera agotado) | Pendiente de ejecución en el VPS |
| T5 | Escaneo de puertos externo (Nmap) | Solo 22/tcp abierto; 80/443 filtrados; resto cerrado o filtrado | Pendiente de ejecución en el VPS |
| T6 | Aislamiento de la base de datos | 5432 inalcanzable desde fuera; `web` no resuelve `db`; `backend` sí | Pendiente de ejecución en el VPS |
| T7 | SSE a través de Cloudflare | `stream.ready` inmediato y `: ping` cada ~20 s durante más de 100 s sin corte | Pendiente de ejecución en el VPS |
| T8 | Redirección HTTP→HTTPS y cabeceras | `301/308` a HTTPS; HSTS, `nosniff`, `X-Frame-Options`, CSP presentes | Pendiente de ejecución en el VPS |
| T9 | Certificados (borde y origen) | Borde: emitido por Cloudflare; origen: Let's Encrypt (u Origin CA), vigente | Pendiente de ejecución en el VPS |
| T10 | IP real del cliente y no falsificable | `client_ip` de Caddy = IP pública del tester; un `X-Forwarded-For` falso no cambia el valor | Pendiente de ejecución en el VPS |
| T11 | Sin compresión en SSE | Sin cabecera `Content-Encoding` en el stream; con compresión en HTML | Pendiente de ejecución en el VPS |
| T12 | Recuperación de contenedor | Tras `docker kill` del backend, vuelve a `healthy` en < 1–2 min | Pendiente de ejecución en el VPS |
| T13 | Rutas internas de `/q/` ocultas | `404` en `/q/metrics`, `/q/openapi`, `/q/swagger-ui`; `200` en `/q/health/ready` | Pendiente de ejecución en el VPS |
| T14 | Inicio de sesión en el navegador (`checkOrigin`) | Login correcto sin error `403 Cross-site POST form submissions are forbidden` | Pendiente de ejecución en el VPS |

#### T1 — DNS

```bash
for h in oncargo.tech www.oncargo.tech api.oncargo.tech; do
  echo "== $h"; dig +short "$h" A; dig +short "$h" AAAA
done
# Esperado: IPs de Cloudflare (104.x, 172.64-71.x, 188.114.x…); sin AAAA; ninguna es <IP_PUBLICA_VPS>
dig +short NS oncargo.tech          # Esperado: servidores de nombres de Cloudflare
```

#### T2 y T3 — Web y API con desglose de tiempos

```bash
# Archivo de formato de curl
cat > curl-format.txt <<'EOF'
dns: %{time_namelookup}s  tcp: %{time_connect}s  tls: %{time_appconnect}s  ttfb: %{time_starttransfer}s  total: %{time_total}s  http: %{http_code}  ip: %{remote_ip}\n
EOF
curl -s -o /dev/null -w "@curl-format.txt" https://oncargo.tech/
curl -s -w "\n" https://api.oncargo.tech/q/health/ready
# Esperado: {"status":"UP","checks":[...]} con la comprobación de la base de datos en UP
```

#### T4 — Acceso directo al origen

```bash
# Desde una red que NO es Cloudflare (por ejemplo, desde Lima). Se reemplaza el DNS por la IP real:
curl -sv --max-time 8 --resolve oncargo.tech:443:<IP_PUBLICA_VPS> https://oncargo.tech/ -o /dev/null
# Esperado: "Connection timed out" o "Operation timed out" (el filtro CLOUDFLARE_ONLY descarta el paquete)
curl -sv --max-time 8 http://<IP_PUBLICA_VPS>/ -o /dev/null
# Esperado: igual, sin respuesta
```

#### T5 y T6 — Escaneo externo y aislamiento de la base de datos

```bash
# Desde una máquina externa al VPS y a Cloudflare, con autorización del equipo (infraestructura propia)
sudo nmap -Pn -sS -p- --min-rate 1000 -oN nmap-full.txt <IP_PUBLICA_VPS>
nmap -Pn -sV -p 22,80,443,5432,8080,4321,2019,9000 <IP_PUBLICA_VPS>
# Esperado: 22/tcp open (OpenSSH); 80, 443, 5432, 8080, 4321, 2019 -> filtered o closed

# Dentro del VPS (usuario deploy), con el compose de producción:
cd /opt/oncargo/infra
docker compose -f docker-compose.prod.yml exec backend getent hosts db   # Esperado: 172.21.0.x  db
docker compose -f docker-compose.prod.yml exec web     getent hosts db   # Esperado: sin salida (código 2)
docker compose -f docker-compose.prod.yml exec caddy   getent hosts db   # Esperado: sin salida (código 2)
docker compose -f docker-compose.prod.yml exec db pg_isready -U postgres -d logyx   # Esperado: accepting connections
sudo ss -tlnp | grep -E ':(5432|8080|4321)\b' || echo "Ningún puerto de aplicación escucha en el host"
```

#### T7 — SSE a través de Cloudflare

```bash
# TOKEN: JWT de una cuenta de prueba (staging local o cuenta de pruebas en producción)
TOKEN="<JWT>"
curl -N -sS --max-time 130 \
  -H "Authorization: Bearer $TOKEN" -H "Accept: text/event-stream" \
  https://api.oncargo.tech/api/v1/events/stream \
| while IFS= read -r line; do printf '%s  %s\n' "$(date +%T)" "$line"; done
# Esperado:
#   t+0 s    event: stream.ready            (llega de inmediato, no al llenarse un buffer)
#   t+20 s   : ping
#   t+40 s   : ping    ... hasta t+130 s sin que Cloudflare corte la conexión (límite de 100 s sin datos)
# Variante web (mismo comportamiento): /eventos, con la cookie de sesión
```

El criterio de aceptación es doble: el primer evento llega en menos de 2 s (sin *buffering*) y el intervalo entre `: ping` no supera 25 s.

#### T8, T9 y T11 — Cabeceras, TLS y compresión

```bash
curl -sI http://oncargo.tech/ | head -5                                 # Esperado: 301/308 con Location: https://...
curl -sI https://oncargo.tech/login | grep -iE 'strict-transport|content-security|x-frame|x-content|referrer'
curl -sI https://api.oncargo.tech/q/health/ready | grep -iE 'strict-transport|x-content|x-frame|cache-control'

# Certificado que ve el visitante (borde de Cloudflare)
echo | openssl s_client -connect oncargo.tech:443 -servername oncargo.tech 2>/dev/null \
  | openssl x509 -noout -issuer -subject -dates
# Certificado del origen (desde el VPS): Let's Encrypt (o Origin CA)
echo | openssl s_client -connect 127.0.0.1:443 -servername oncargo.tech 2>/dev/null \
  | openssl x509 -noout -issuer -subject -dates

# Compresión: HTML sí, SSE no
curl -sI -H 'Accept-Encoding: gzip, br' https://oncargo.tech/login | grep -i content-encoding
curl -sI -H 'Accept-Encoding: gzip, br' -H "Authorization: Bearer $TOKEN" \
  https://api.oncargo.tech/api/v1/events/stream --max-time 3 | grep -i content-encoding || echo "SSE sin compresión (correcto)"
```

#### T10 — IP real del cliente

```bash
MYIP=$(curl -s https://api.ipify.org)
curl -s -o /dev/null -H 'X-Forwarded-For: 203.0.113.99' https://api.oncargo.tech/q/health/ready
# En el VPS: la última entrada del log debe mostrar client_ip = $MYIP y no 203.0.113.99 ni una IP de Cloudflare
sudo tail -n 1 /var/log/caddy/access.log | jq '{client_ip: .request.client_ip, remote_ip: .request.remote_ip, uri: .request.uri, status}'
echo "IP esperada: $MYIP"
# Esperado: client_ip == $MYIP; remote_ip == IP de Cloudflare (el vecino directo)
```

#### T12 — Recuperación de un contenedor

```bash
# En una ventana: sondeo cada 2 s
while true; do printf '%s ' "$(date +%T)"; curl -s -o /dev/null -w "%{http_code}\n" --max-time 3 https://api.oncargo.tech/q/health/ready; sleep 2; done
# En otra: simular la caída del backend
docker kill oncargo-backend-1
# Esperado: respuestas 502/5xx durante la reinicialización (el backend tarda en arrancar: start-period 60 s del
# healthcheck) y retorno a 200 sin intervención; registrar el tiempo total de indisponibilidad
```

#### T13 y T14 — Superficie pública y flujo de sesión

```bash
for p in /q/metrics /q/openapi /q/swagger-ui /q/health/ready; do
  printf '%-22s' "$p"; curl -s -o /dev/null -w "%{http_code}\n" "https://api.oncargo.tech$p"
done
# Esperado: 404 404 404 200
```

T14 es manual: iniciar sesión en `https://oncargo.tech/login` con una cuenta de prueba desde un navegador y desde la app Android contra `api.oncargo.tech`. Se verifica de forma explícita porque `security.checkOrigin` de Astro compara el origen de la petición con la URL que ve el servidor detrás de un proxy TLS; si falla, se corrige el reenvío de `X-Forwarded-Proto` y `Host` en Caddy (ya preservados por defecto) o la configuración del adaptador antes del lanzamiento. La misma sesión sirve para comprobar que *Bot Fight Mode* de Cloudflare no desafía a la app Android.

### 4.2 Pruebas de latencia y carga

**Objetivos de diseño** (de [Diseño de Red, sección 4.3](../semestre-1/diseno-red.md)): latencia total desde Lima de ~70–120 ms (**estimada**), P95 < 500 ms y tasa de error < 1 %.

**Condiciones de la prueba.** Se ejecuta desde un equipo en Lima (conexión doméstica o de oficina, anotando operador y ancho de banda) y también desde el propio VPS (para aislar el costo de la red pública). Para que *Bot Fight Mode* y el WAF no alteren la medición, se crea **una regla temporal de Cloudflare** que omite las reglas para la IP del tester y se **elimina al terminar**. La prueba de capacidad de la aplicación (autenticada, con escritura) se hace contra el **staging local**, no contra producción.

**Latencia por repetición (curl):**

```bash
for i in $(seq 1 100); do
  curl -s -o /dev/null -w "%{time_connect} %{time_appconnect} %{time_starttransfer} %{time_total}\n" https://api.oncargo.tech/q/health/ready
done | awk '{c+=$1; a+=$2; t+=$3; T+=$4; v[NR]=$4} END {n=NR; asort(v); printf "n=%d connect=%.0fms tls=%.0fms ttfb=%.0fms total_prom=%.0fms p50=%.0fms p95=%.0fms\n", n, c/n*1000, a/n*1000, t/n*1000, T/n*1000, v[int(n*0.5)]*1000, v[int(n*0.95)]*1000}'
# Requiere gawk (asort). Ejecutar a distintas horas para observar la variación.
```

**Ruta de red hasta el borde y hasta el origen** (la parte hasta el origen solo sirve si se ejecuta desde el VPS o con ICMP permitido):

```bash
mtr -rwzc 50 oncargo.tech               # Lima -> borde de Cloudflare (pérdida y latencia por salto)
ping -c 50 oncargo.tech | tail -3       # ICMP hacia el borde de Cloudflare
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
# Alternativa mínima con ApacheBench (sin guion): 2000 peticiones, 20 en paralelo
ab -n 2000 -c 20 -k https://oncargo.tech/login
# Durante la prueba, en el VPS (otra terminal):
docker stats --no-stream
vmstat 5 12
```

**Conexiones SSE simultáneas (500 de diseño):** el límite de la aplicación es de 5 streams por usuario, por lo que se requieren cuentas distintas. Se ejecuta contra el staging local con usuarios del *seed* de desarrollo:

```javascript
// sse-soak.mjs — Node 22:  node sse-soak.mjs tokens.txt http://localhost:8680 500
import { readFileSync } from 'node:fs';
const [file, base, n] = process.argv.slice(2);
const tokens = readFileSync(file, 'utf8').split('\n').filter(Boolean);
let ready = 0, pings = 0, errors = 0;
const open = async (i) => {
  const token = tokens[i % tokens.length];
  try {
    const res = await fetch(`${base}/api/v1/events/stream`, { headers: { Authorization: `Bearer ${token}`, Accept: 'text/event-stream' } });
    if (!res.ok) { errors++; return; }
    for await (const chunk of res.body) {
      const text = Buffer.from(chunk).toString();
      if (text.includes('stream.ready')) ready++;
      if (text.includes(': ping')) pings++;
    }
  } catch { errors++; }
};
for (let i = 0; i < Number(n); i++) { open(i); await new Promise((r) => setTimeout(r, 20)); }
setInterval(() => console.log(`${new Date().toISOString()} ready=${ready} pings=${pings} errors=${errors}`), 10000);
```

Se registra el consumo de memoria y CPU de `backend` y `db` (`docker stats`) con 100, 300 y 500 streams y se confirma que los pools (8 + 20 conexiones) y la conexión dedicada de `LISTEN` no se agotan.

**Metas y resultados:**

| Métrica | Objetivo | Tipo de dato | Resultado |
|---------|----------|--------------|-----------|
| Latencia total P50 (Lima → API) | < 150 ms | Objetivo; estimación de diseño 70–120 ms | Pendiente de ejecución en el VPS |
| Latencia total P95 | < 500 ms | Objetivo | Pendiente de ejecución en el VPS |
| Latencia total P99 | < 2,000 ms | Objetivo (RNF-01: respuesta < 2 s) | Pendiente de ejecución en el VPS |
| Tasa de error | < 1 % | Objetivo | Pendiente de ejecución en el VPS |
| Throughput sostenido | ≥ 100 req/s en lectura | Objetivo (supuesto del MVP: 50–100 req/s) | Pendiente de ejecución en el VPS |
| Pérdida de paquetes (mtr, 50 sondeos) | < 1 % | Objetivo | Pendiente de ejecución en el VPS |
| Streams SSE simultáneos | 500 sin errores | Objetivo (supuesto del MVP) | Pendiente de ejecución en el staging local y en el VPS |
| Memoria libre del host con 500 streams | > 1.5 GB | Umbral de escalado de diseño | Pendiente de ejecución en el VPS |

### 4.3 Rendimiento del enlace del VPS

```bash
# Descarga y subida hacia la red de Cloudflare (punto de medida público de Cloudflare)
curl -s -o /dev/null -w "descarga 100 MB: %{speed_download} B/s en %{time_total}s\n" 'https://speed.cloudflare.com/__down?bytes=100000000'
head -c 50000000 /dev/zero | curl -s -o /dev/null -X POST --data-binary @- -w "subida 50 MB: %{speed_upload} B/s en %{time_total}s\n" 'https://speed.cloudflare.com/__up'
# Convertir a Mbps: B/s x 8 / 1,000,000. Objetivo: >= 100 Mbps de salida (RT-02; el plan incluye 8 TB/mes de transferencia).
```

| Métrica | Objetivo | Resultado |
|---------|----------|-----------|
| Descarga del VPS | ≥ 100 Mbps | Pendiente de ejecución en el VPS |
| Subida del VPS | ≥ 100 Mbps | Pendiente de ejecución en el VPS |

---

## Sección 5 — Monitoreo de Red

### 5.1 Capas de monitoreo (ligero, sin SNMP)

Un VPS de 8 GB comparte la memoria con la base de datos y el backend, por lo que se descartan pilas pesadas (Prometheus, Grafana, Elastic, SIEM). El monitoreo combina herramientas que ya forman parte del sistema:

| Capa | Herramienta | Qué observa | Frecuencia | Estado |
|------|-------------|-------------|------------|--------|
| Disponibilidad externa | **UptimeRobot** (plan gratuito) o Uptime Kuma en otro host | `https://oncargo.tech/login` y `https://api.oncargo.tech/q/health/ready` | 5 min | Definido para el VPS (pendiente de ejecutar) |
| Disponibilidad interna | **Uptime Kuma** (contenedor, perfil `monitoring`) | Contenedores, TCP de `db`, certificado TLS, latido de los respaldos (monitor *push*) | 1 min | Definido para el VPS (pendiente de ejecutar) |
| Salud de contenedores | `healthcheck` de Docker + `restart: unless-stopped` | Estado `healthy` de `backend`, `web`, `db`, `caddy` | 5–30 s | Implementado en el repositorio (`backend`, `web`, `db`) |
| Tráfico HTTP | Logs JSON de Caddy | Estados, latencia, IP real, rutas | Continuo | Definido para el VPS (pendiente de ejecutar) |
| Intrusión de acceso | fail2ban (*jails* `sshd` y `caddy-auth`) | Fuerza bruta SSH y de login | Continuo | Definido para el VPS (pendiente de ejecutar) |
| Borde | Paneles de Cloudflare: *Analytics*, *Security Events* | Solicitudes, bloqueos del WAF, desafíos de bots | Revisión semanal | Definido para el VPS (pendiente de ejecutar) |
| Recursos del host | `docker stats`, `vmstat`, `df`, `journalctl` | CPU, memoria, disco, errores del sistema | Manual y en cada incidente | Definido para el VPS (pendiente de ejecutar) |
| Aplicación | Logs de contenedores y tabla `outbox_events` | Errores `ERROR`; eventos en estado `FAILED` (sin alerta automática hoy) | Revisión semanal | Implementado en el repositorio (tabla y logs) / alerta Pendiente |

**Sobre SNMP.** La rúbrica del curso menciona SNMP porque asume equipos de red propios. En un VPS no existen conmutadores ni *routers* gestionables y el proveedor no expone SNMP; el equivalente funcional son las métricas del host y los registros anteriores. Si en el futuro se requiere una vista histórica, se podría agregar `node_exporter` y una instancia de Prometheus/Grafana en otro equipo (propuesta, no incluida por costo de memoria).

### 5.2 Análisis de los logs de Caddy

```bash
LOG=/var/log/caddy/access.log
# Distribución de códigos de estado
sudo jq -r '.status' $LOG | sort | uniq -c | sort -rn
# Errores 5xx recientes
sudo jq -r 'select(.status>=500) | [.ts, .request.client_ip, .request.method, .request.uri, .status] | @tsv' $LOG | tail -20
# IPs más activas (posible abuso)
sudo jq -r '.request.client_ip' $LOG | sort | uniq -c | sort -rn | head -10
# Latencia P95 en segundos (duration está en segundos)
sudo jq -r '.duration' $LOG | sort -n | awk '{a[NR]=$1} END {print "p95=" a[int(NR*0.95)] " s sobre " NR " peticiones"}'
# Intentos de login rechazados por IP
sudo jq -r 'select(.request.uri=="/api/v1/auth/login" and (.status==401 or .status==429)) | .request.client_ip' $LOG | sort | uniq -c | sort -rn | head
```

### 5.3 fail2ban sobre los logs de acceso

```ini
# /etc/fail2ban/filter.d/caddy-auth.conf
[Definition]
failregex = "client_ip":"<HOST>".*"uri":"/api/v1/auth/login".*"status":(401|429)
ignoreregex =
```

```ini
# /etc/fail2ban/jail.d/caddy-auth.local
[caddy-auth]
enabled  = true
filter   = caddy-auth
logpath  = /var/log/caddy/access.log
maxretry = 15
findtime = 10m
bantime  = 1h
# Detrás de Cloudflare, bloquear la IP en el host NO sirve: el paquete llega desde Cloudflare.
# Por eso esta jail solo registra (acción "dummy") y la lista se revisa cada semana para
# agregar las IPs reincidentes a una regla de bloqueo de Cloudflare.
action   = dummy
```

La *jail* `sshd` (acceso directo, sin Cloudflare) sí bloquea con UFW; su configuración está en [Implementación de Seguridad, sección 1.2](implementacion-seguridad.md).

### 5.4 Monitores de Uptime Kuma

| Monitor | Tipo | Objetivo | Intervalo | Alerta |
|---------|------|----------|-----------|--------|
| Web | HTTP(s) | `https://oncargo.tech/login`, código 200 | 60 s | 3 fallos consecutivos |
| API (salud) | HTTP(s) con palabra clave | `https://api.oncargo.tech/q/health/ready`, contiene `UP` | 60 s | 3 fallos |
| Certificado TLS | HTTP(s) | Caducidad del certificado de `oncargo.tech` | Diario | < 14 días |
| Base de datos | TCP (red interna) | `db:5432` | 60 s | 3 fallos |
| Respaldo diario | *Push* | El script de respaldo llama a la URL *push* al terminar | 26 h | Sin latido |
| Cloudflare R2 | HTTP(s) | `https://<ACCOUNT_ID>.r2.cloudflarestorage.com` (cualquier respuesta HTTP indica que el servicio responde) | 5 min | 3 fallos |

Las notificaciones se envían por correo y por un canal de mensajería del equipo (Telegram o correo según lo disponible). Un monitor ejecutado **en el mismo VPS** no detecta la caída del propio servidor; por eso la disponibilidad externa (UptimeRobot) es obligatoria.

### 5.5 Umbrales de alerta

| Métrica | Umbral | Acción |
|---------|--------|--------|
| Web o API no disponible | 3 fallos de 60 s | Runbook de incidente ([Datacenter, sección 4.2](implementacion-datacenter.md)) |
| Respuestas 5xx en Caddy | > 10 en 5 min | Revisar `docker compose logs backend` |
| Latencia P95 de la API | > 2 s sostenida 10 min | Revisar CPU/memoria; evaluar escalado |
| Memoria disponible del host | < 1.5 GB | Disparador de escalado vertical |
| CPU promedio | > 70 % durante 15 min | Disparador de escalado vertical |
| Disco | > 70 % de 100 GB | Limpiar imágenes (`docker image prune`) y revisar logs |
| Certificado TLS | < 14 días para vencer | Revisar Caddy y el desafío ACME |
| `outbox_events` en `FAILED` | > 0 | Revisión semanal; diagnóstico por `last_error` |

---

## Sección 6 — Riesgos Técnicos Anticipados y Acciones Correctivas

Registro de las incidencias de configuración que el diseño ya identificó (no son fallas ocurridas) y cómo se corrigen:

| ID | Riesgo o incidencia anticipada | Efecto | Acción correctiva | Estado |
|----|-------------------------------|--------|-------------------|--------|
| I-01 | Docker ignora UFW para los puertos publicados | 80/443 abiertos a todo Internet pese a las reglas de UFW | Filtro en `DOCKER-USER` con ipset (sección 1.4); prueba T4/T5 | Corregido en el diseño; verificación pendiente |
| I-02 | Cloudflare conserva el `X-Forwarded-For` del cliente | Un atacante falsifica su IP y evade `AuthRateLimits` | `header_up X-Forwarded-For {client_ip}` con `CF-Connecting-IP`; prueba T10 | Corregido en el diseño; verificación pendiente |
| I-03 | Emisión ACME detrás del proxy de Cloudflare | Caddy no obtiene certificado y el modo *Full (strict)* falla | HTTP-01 por el puerto 80 permitido; alternativa: Origin CA (sección 1.3) | Pendiente de verificar en el primer arranque |
| I-04 | *Bot Fight Mode* desafía a clientes no navegador | La app Android, los monitores o k6 reciben desafíos | Verificación con la app (T14); si interfiere, se desactiva y se usa el *rate limiting* | Pendiente de verificar |
| I-05 | Cloudflare corta conexiones sin datos tras 100 s | Los streams SSE se reconectan continuamente | Latido de 20 s del backend (ADR-0007); prueba T7 | Mitigado en el código; verificación pendiente |
| I-06 | `checkOrigin` de Astro detrás de un proxy TLS | `403` en los formularios por diferencia de esquema | Prueba T14; ajuste del reenvío de cabeceras | Pendiente de verificar |
| I-07 | `internal: true` impide la salida de `db` | Si algo necesitara salir (p. ej. extensiones), fallaría | `db` no requiere salida; validar en el primer arranque | Pendiente de verificar |
| I-08 | Un solo VPS: caída de red del proveedor | Servicio indisponible | Reconstrucción documentada ([Datacenter, sección 4.3](implementacion-datacenter.md)); DNS directo como contingencia | Aceptado (RTO 2–4 h) |

---

## Anexos

### Anexo A — Evidencias de ejecución

| Evidencia | Origen | Estado |
|-----------|--------|--------|
| `docker compose ps` con los cuatro servicios `healthy` | VPS | Pendiente de ejecución en el VPS |
| `docker network inspect` de `edge` e `internal` (subredes 172.20.0.0/24 y 172.21.0.0/24) | VPS | Pendiente de ejecución en el VPS |
| `sudo ufw status verbose` y `sudo iptables -S DOCKER-USER` | VPS | Pendiente de ejecución en el VPS |
| `sudo ipset list cloudflare4 \| head` | VPS | Pendiente de ejecución en el VPS |
| Panel de Cloudflare: registros DNS en modo *Proxied* y modo SSL *Full (strict)* | Cloudflare | Pendiente de ejecución en el VPS |
| Salida de T1 a T14 (capturas o archivos de texto) | Varios | Pendiente de ejecución en el VPS |
| Informe de k6 (humo y carga) y de `ab` | Lima | Pendiente de ejecución en el VPS |
| Traza de SSE con marcas de tiempo (T7) | Lima | Pendiente de ejecución en el VPS |
| `nmap-full.txt` del escaneo externo | Equipo externo | Pendiente de ejecución en el VPS |
| Panel de Uptime Kuma con los monitores de la sección 5.4 | VPS | Pendiente de ejecución en el VPS |
| Configuración existente en el repositorio: `infra/docker-compose.yml`, `backend/Dockerfile`, `web/Dockerfile`, `application.properties`, `middleware.ts` | Repositorio | Implementado en el repositorio |

### Anexo B — Comandos de diagnóstico de red

```bash
# Estado de los servicios y de la red
cd /opt/oncargo/infra && docker compose -f docker-compose.prod.yml ps
docker network ls && docker network inspect oncargo_edge oncargo_internal | jq '.[].IPAM.Config'
ip -br a && ip route

# Reglas de firewall
sudo ufw status numbered
sudo iptables -S DOCKER-USER
sudo iptables -L CLOUDFLARE_ONLY -n -v
sudo ipset list cloudflare4 | head -20
sudo iptables -t nat -S DOCKER | grep -E 'dpt:(80|443)'

# Qué escucha en el host (solo debe aparecer SSH y los puertos 80/443 de docker-proxy)
sudo ss -tlnp

# Caddy
docker compose -f docker-compose.prod.yml logs --tail=100 caddy
docker compose -f docker-compose.prod.yml exec caddy caddy validate --config /etc/caddy/Caddyfile
docker compose -f docker-compose.prod.yml exec caddy caddy reload --config /etc/caddy/Caddyfile

# Conectividad interna
docker compose -f docker-compose.prod.yml exec web wget -qO- http://backend:8080/q/health/ready
docker compose -f docker-compose.prod.yml exec backend getent hosts db

# fail2ban
sudo fail2ban-client status
sudo fail2ban-client status sshd
sudo fail2ban-client status caddy-auth

# Desde fuera: el origen no debe responder y la base de datos tampoco
nmap -Pn -p 22,80,443,5432 <IP_PUBLICA_VPS>
psql -h <IP_PUBLICA_VPS> -p 5432 -U logyx_api -d logyx    # Esperado: tiempo de espera agotado
```

---

*OnCargo · S2 Entregable 1 · Implementación de Red · Competencias C1.2–C1.3 · Versión 2.0 · Noviembre 2026 (original: Agosto–Noviembre 2026)*
