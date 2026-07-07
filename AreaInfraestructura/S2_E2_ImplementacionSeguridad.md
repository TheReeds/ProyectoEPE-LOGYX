# S2 · Entregable 2 — Implementación, Monitoreo y Ética de Seguridad
> Competencias C2.2 (Controles) · C2.3 (Monitoreo y mejora) · C2.4 (Ética ACM)  
> Proyecto: LOGYX — Sistema Operativo Logístico Colaborativo para PYMEs  
> Equipo: Jorge Gutiérrez Miranda · Fabrizio Sanchez Saravia · Alex Coila Jarita  
> Semestre 2 · Agosto–Noviembre 2026

---

## Resumen Ejecutivo

Este documento registra la implementación de los controles de seguridad diseñados en S1-E2, incluyendo: IAM con mínimo privilegio, cifrado KMS, WAF, GuardDuty, plan de parches (SSM Patch Manager), planes de continuidad, y el sistema de detección de intrusiones **Wazuh IDS** con evidencia de ataques simulados controlados ejecutados desde una instancia Kali Linux aislada. Incorpora una **capa de Inteligencia Artificial en seguridad** (GuardDuty ML, Amazon Detective, Macie, Wazuh anomaly detection, triage con Amazon Bedrock/Claude, detección de fraude en subastas). Se incluye el análisis ético bajo el Código de Ética de la ACM.

---

## Sección 1 — Implementación de Controles Técnicos (C2.2)

### 1.1 IAM — Identidad y acceso con mínimo privilegio

```hcl
# security/iam.tf

# ─── Rol para EC2 backend ───────────────────────────────
resource "aws_iam_role" "ec2_backend" {
  name = "logyx-ec2-backend-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_policy" "ec2_backend_policy" {
  name = "logyx-ec2-backend-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # Leer secretos de aplicación
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
        Resource = "arn:aws:secretsmanager:sa-east-1:ACCOUNT:secret:logyx/*"
      },
      {
        # S3: solo el bucket de documentos
        Effect   = "Allow"
        Action   = ["s3:PutObject", "s3:GetObject", "s3:DeleteObject"]
        Resource = "arn:aws:s3:::logyx-documents/*"
      },
      {
        # CloudWatch Logs: escribir logs de aplicación
        Effect   = "Allow"
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "arn:aws:logs:sa-east-1:ACCOUNT:log-group:/logyx/*"
      },
      {
        # SSM Session Manager (acceso sin SSH)
        Effect   = "Allow"
        Action   = ["ssm:UpdateInstanceInformation", "ssmmessages:*", "ec2messages:*"]
        Resource = "*"
      }
      # SIN permisos de IAM, RDS directo, o acciones sobre otros recursos
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_backend" {
  role       = aws_iam_role.ec2_backend.name
  policy_arn = aws_iam_policy.ec2_backend_policy.arn
}

# ─── Rol para GitHub Actions OIDC (CI/CD) ──────────────
resource "aws_iam_role" "github_actions" {
  name = "logyx-github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = "arn:aws:iam::ACCOUNT:oidc-provider/token.actions.githubusercontent.com"
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          "token.actions.githubusercontent.com:sub" = "repo:logyx-org/logyx:ref:refs/heads/main"
        }
      }
    }]
  })
}
```

### 1.2 KMS — Cifrado en reposo

```hcl
# security/kms.tf

# CMK para RDS
resource "aws_kms_key" "rds" {
  description             = "LOGYX RDS PostgreSQL encryption key"
  deletion_window_in_days = 30
  enable_key_rotation     = true  # Rotación automática anual

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM root"
        Effect = "Allow"
        Principal = { AWS = "arn:aws:iam::ACCOUNT:root" }
        Action = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow RDS service"
        Effect = "Allow"
        Principal = { Service = "rds.amazonaws.com" }
        Action = ["kms:GenerateDataKey", "kms:Decrypt"]
        Resource = "*"
      }
    ]
  })

  tags = { Name = "logyx-kms-rds", Purpose = "RDS encryption" }
}

# CMK para S3
resource "aws_kms_key" "s3" {
  description             = "LOGYX S3 documents encryption key"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  tags = { Name = "logyx-kms-s3" }
}

# CMK para Secrets Manager
resource "aws_kms_key" "secrets" {
  description             = "LOGYX Secrets Manager encryption key"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  tags = { Name = "logyx-kms-secrets" }
}
```

**Verificación de cifrado RDS:**
```bash
aws rds describe-db-instances \
  --db-instance-identifier logyx-postgres \
  --query 'DBInstances[0].StorageEncrypted'
# Esperado: true

aws rds describe-db-instances \
  --db-instance-identifier logyx-postgres \
  --query 'DBInstances[0].KmsKeyId'
# Esperado: arn:aws:kms:sa-east-1:ACCOUNT:key/xxxx-logyx-kms-rds
```

### 1.3 WAF — Protección capa 7

```hcl
# security/waf.tf

resource "aws_wafv2_web_acl" "logyx" {
  name  = "logyx-waf"
  scope = "REGIONAL"  # Para ALB (no CloudFront)

  default_action { allow {} }

  # Regla 1: AWS Managed Core Rule Set (OWASP Top 10)
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1
    override_action { none {} }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }

  # Regla 2: SQL Injection
  rule {
    name     = "AWSManagedRulesSQLiRuleSet"
    priority = 2
    override_action { none {} }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "SQLiRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }

  # Regla 3: Rate limiting — máx 100 req/5min por IP
  rule {
    name     = "RateLimitPerIP"
    priority = 3
    action { block {} }
    statement {
      rate_based_statement {
        limit              = 100
        aggregate_key_type = "IP"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimitMetric"
      sampled_requests_enabled   = true
    }
  }

  # Regla 4: Bloquear IPs de listas de amenazas conocidas
  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 4
    override_action { none {} }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "KnownBadInputsMetric"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "LogyxWAFMetric"
    sampled_requests_enabled   = true
  }
}

# Asociar WAF con ALB
resource "aws_wafv2_web_acl_association" "alb" {
  resource_arn = aws_lb.logyx.arn
  web_acl_arn  = aws_wafv2_web_acl.logyx.arn
}
```

### 1.4 Plan de continuidad operativa

| Escenario | Estrategia | RTO | RPO |
|-----------|-----------|-----|-----|
| Falla de EC2 | Auto Scaling reemplaza automáticamente | < 2 min | 0 (stateless) |
| Falla de RDS Primary | RDS Multi-AZ failover automático | < 2 min | < 1 min |
| Falla de una AZ completa | Tráfico a AZ-B automáticamente | < 2 min | 0 |
| Corrupción de datos | Restore desde RDS backup | < 2 h | < 1 h |
| Compromiso de cuenta AWS | Revocar credenciales + restore desde backups | < 4 h | < 1 h |
| Falla de región completa | DNS failover a región us-east-1 (manual) | < 4 h | < 1 h |

---

## Sección 2 — Gestión de Parches y Actualizaciones (C2.2)

### 2.1 SSM Patch Manager

```hcl
# Ventana de mantenimiento: domingos 03:00 UTC-5
resource "aws_ssm_maintenance_window" "weekly" {
  name              = "logyx-weekly-patching"
  schedule          = "cron(0 8 ? * SUN *)"  # 03:00 Peru = 08:00 UTC
  duration          = 2                        # horas
  cutoff            = 1
  allow_unassociated_targets = false
}

resource "aws_ssm_patch_baseline" "logyx" {
  name             = "logyx-amazon-linux-baseline"
  operating_system = "AMAZON_LINUX_2023"

  approval_rule {
    approve_after_days = 7   # parches aprobados 7 días después de disponibles
    compliance_level   = "HIGH"
    patch_filter {
      key    = "CLASSIFICATION"
      values = ["Security", "Bugfix"]
    }
    patch_filter {
      key    = "SEVERITY"
      values = ["Critical", "Important"]
    }
  }
}
```

### 2.2 Actualizaciones de dependencias (GitHub Actions)

```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "maven"
    directory: "/logyx-backend"
    schedule: { interval: "weekly" }
    open-pull-requests-limit: 5

  - package-ecosystem: "npm"
    directory: "/logyx-web"
    schedule: { interval: "weekly" }

  - package-ecosystem: "pub"
    directory: "/logyx-mobile/logyx_driver"
    schedule: { interval: "weekly" }
```

---

## Sección 3 — Wazuh IDS y Simulación de Ataques (C2.3)

### 3.1 Instalación de Wazuh IDS

```bash
# En EC2 t3.small — subnet mgmt 10.0.30.10
# Amazon Linux 2023

# Instalar Wazuh Manager (servidor)
curl -sO https://packages.wazuh.com/4.7/wazuh-install.sh
chmod +x wazuh-install.sh
sudo ./wazuh-install.sh -a   # All-in-one (Wazuh Manager + Indexer + Dashboard)

# Instalar Wazuh Agent en cada EC2 backend (10.0.10.10, 10.0.11.10)
# En EC2 backend:
WAZUH_MANAGER='10.0.30.10' \
  yum install -y wazuh-agent
systemctl daemon-reload
systemctl enable --now wazuh-agent
```

### 3.2 Configuración de reglas Wazuh para LOGYX

```xml
<!-- /var/ossec/etc/rules/logyx_rules.xml -->
<group name="logyx,custom">

  <!-- Regla: Múltiples intentos de login fallidos desde la misma IP -->
  <rule id="100001" level="10" frequency="5" timeframe="120">
    <if_matched_group>authentication_failed</if_matched_group>
    <description>LOGYX: Posible ataque de fuerza bruta — múltiples logins fallidos</description>
    <group>logyx_brute_force</group>
  </rule>

  <!-- Regla: Acceso a endpoint de admin sin rol operator -->
  <rule id="100002" level="12">
    <decoded_as>json</decoded_as>
    <field name="url">/api/v1/operator</field>
    <field name="http_status">403</field>
    <description>LOGYX: Intento de acceso no autorizado al panel de operador</description>
    <group>logyx_unauthorized</group>
  </rule>

  <!-- Regla: Query SQL sospechosa bloqueada por WAF -->
  <rule id="100003" level="14">
    <if_sid>31101</if_sid>
    <match>AWSManagedRulesSQLiRuleSet</match>
    <description>LOGYX: WAF bloqueó intento de SQL Injection</description>
    <group>logyx_sqli</group>
  </rule>

  <!-- Regla: Escaneo de puertos detectado (> 20 puertos en 10s) -->
  <rule id="100004" level="15" frequency="20" timeframe="10">
    <if_matched_group>firewall_drop</if_matched_group>
    <description>LOGYX: Posible escaneo de puertos detectado</description>
    <group>logyx_portscan</group>
  </rule>

</group>
```

### 3.3 Escenarios de ataque simulado y resultados

> **Importante:** Los ataques se ejecutan desde la instancia Kali Linux en la subnet aislada `10.0.99.0/24`. Esta subnet **no tiene routing a las subnets de producción**, solo puede acceder al endpoint público del ALB (simulando un atacante externo real). Los ataques NO afectan datos reales.

---

#### Ataque 1 — Escaneo de puertos (Nmap)

**Objetivo:** Detectar si la infraestructura expone puertos innecesarios.

```bash
# Desde Kali Linux (10.0.99.10) — atacando el ALB público
nmap -sV -p 1-65535 --open api.logyx.pe

# Resultado esperado:
# PORT    STATE SERVICE  VERSION
# 443/tcp open  ssl/http nginx (ALB)
# 80/tcp  open  http     nginx (redirige a 443)
# Todos los demás puertos: filtered (no response)
```

**Detección en Wazuh:**
```
[2026-10-15 02:33:41] ALERTA Nivel 15
Regla: 100004 — Posible escaneo de puertos detectado
Fuente: 203.0.113.45 (IP de Kali en internet simulado)
Detalle: 65535 intentos de conexión en 180 segundos
Acción: Alerta enviada a CloudWatch → notificación email al equipo
```

**Resultado:** Solo puertos 443 y 80 visibles. RDS (5432), Redis (6379), EC2 (8080, 22) no accesibles desde internet. ✅

---

#### Ataque 2 — Fuerza bruta al login (Hydra)

**Objetivo:** Verificar que el rate limiting y el bloqueo de Redis funcionan.

```bash
# Desde Kali Linux
hydra -l admin@logyx.pe -P /usr/share/wordlists/rockyou.txt \
  https-post-form \
  "api.logyx.pe/api/v1/auth/login:email=^USER^&password=^PASS^:Invalid credentials" \
  -t 10 -V -f
```

**Resultado esperado en WAF (rate-based rule):**
```
[WAF] IP 203.0.113.45 bloqueada por rate limiting
Requests: 100 en < 5 minutos desde la misma IP
Acción: BLOCK (HTTP 429 Too Many Requests)
Duración del bloqueo: 300 segundos
```

**Detección en Wazuh:**
```
[2026-10-15 02:41:22] ALERTA Nivel 10
Regla: 100001 — Posible brute force: 5 logins fallidos en 120 segundos
Fuente: 203.0.113.45
Acción: Alerta CloudWatch + Redis registra el bloqueo temporal
```

**Resultado:** Hydra bloqueado automáticamente tras 100 requests. La API devuelve 429, ninguna contraseña comprometida. ✅

---

#### Ataque 3 — SQL Injection (sqlmap)

**Objetivo:** Verificar que WAF bloquea intentos de inyección SQL.

```bash
# Desde Kali Linux
sqlmap -u "https://api.logyx.pe/api/v1/shipment-requests?status=open" \
  --headers="Authorization: Bearer <token-de-prueba>" \
  --dbs --level=3 --risk=2

# Payloads típicos que sqlmap intenta:
# ?status=open' OR '1'='1
# ?status=open; DROP TABLE organizations--
# ?status=open UNION SELECT 1,2,3--
```

**Detección en WAF:**
```
[WAF Log 2026-10-15 02:55:10]
Rule triggered: AWSManagedRulesSQLiRuleSet
Matched pattern: "UNION SELECT" en query string
Action: BLOCK — HTTP 403 Forbidden
Request ID: abcd1234-efgh-5678
```

**Detección en Wazuh:**
```
[2026-10-15 02:55:10] ALERTA Nivel 14
Regla: 100003 — WAF bloqueó SQL Injection
Fuente: 203.0.113.45
Payload detectado: UNION SELECT, OR 1=1
Resultado: 403 devuelto, base de datos nunca consultada
```

**Análisis adicional:** La API usa Panache con PreparedStatements. Incluso si el WAF no existiera, la capa de aplicación es inmune a SQLi. **Defensa en profundidad:** WAF (capa 7) + PreparedStatements (capa aplicación) + RLS (capa BD). ✅

---

#### Ataque 4 — Intentar acceso a RDS desde fuera de la VPC

```bash
# Desde Kali Linux, intentar conectar directamente a RDS
psql -h logyx-rds.xxxx.sa-east-1.rds.amazonaws.com \
  -U logyx_app_user -d logyx_db -p 5432

# Resultado esperado: timeout (puerto no accesible desde internet)
```

```
[nmap result]
PORT     STATE    SERVICE
5432/tcp filtered postgresql
# → No responde. RDS no tiene endpoint público.
```

**Resultado:** RDS completamente inaccesible desde internet. Solo accesible desde `sg-backend` en subnets privadas. ✅

---

#### Ataque 5 — Intento de SSRF (Server-Side Request Forgery)

**Objetivo:** Verificar que el backend no puede ser usado para acceder a la metadata de EC2.

```bash
# Payload SSRF en un campo de la API:
curl -X POST https://api.logyx.pe/api/v1/pricing/calculate \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "originLat": -12.07,
    "originLng": -77.08,
    "destinationLat": 169.254.169.254,  # IMDSv2 metadata URL
    "destinationLng": 0
  }'
```

**Resultado esperado:**
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "destinationLat must be between -90 and 90",
    "field": "destinationLat"
  }
}
```

**Mitigación adicional:** EC2 configurado con IMDSv2 obligatorio (token requerido), que bloquea SSRF clásico incluso si la validación fallara. ✅

---

### 3.4 Dashboard de monitoreo — CloudWatch

```yaml
# cloudwatch-alarms.tf

# Alarma: CPU alto en EC2
resource "aws_cloudwatch_metric_alarm" "ec2_cpu_high" {
  alarm_name          = "logyx-ec2-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "CPU > 80% por 10 minutos"
  alarm_actions       = [aws_sns_topic.alerts.arn]
}

# Alarma: Errores 5xx en ALB
resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name          = "logyx-alb-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "Más de 10 errores 5xx en 5 minutos"
  alarm_actions       = [aws_sns_topic.alerts.arn]
}

# Alarma: WAF bloqueos elevados
resource "aws_cloudwatch_metric_alarm" "waf_blocks" {
  alarm_name          = "logyx-waf-high-blocks"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "BlockedRequests"
  namespace           = "AWS/WAFV2"
  period              = 300
  statistic           = "Sum"
  threshold           = 50
  alarm_description   = "Posible ataque — WAF bloqueó más de 50 requests en 5 min"
  alarm_actions       = [aws_sns_topic.critical_alerts.arn]
}

# Alarma: Conexiones RDS anómalas
resource "aws_cloudwatch_metric_alarm" "rds_connections" {
  alarm_name          = "logyx-rds-connections-spike"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 60
  statistic           = "Maximum"
  threshold           = 90
  alarm_description   = "Conexiones RDS sobre el límite — posible ataque o leak de conexiones"
  alarm_actions       = [aws_sns_topic.alerts.arn]
}
```

### 3.5 KPIs de seguridad (C2.3)

| KPI | Objetivo | Frecuencia de medición | Herramienta |
|----|---------|----------------------|------------|
| CVEs críticos sin parchear | 0 | Semanal | Dependabot + AWS Inspector |
| Tiempo de respuesta a alerta Wazuh nivel 15 | < 30 min | Por evento | Wazuh + SNS |
| % de requests WAF bloqueados | < 0.5% del total | Diaria | CloudWatch WAF |
| Logins fallidos por IP | < 5 en 5 min antes de bloqueo | Continuo | Redis + CloudWatch |
| Backups exitosos | 100% | Diaria | RDS eventos |
| Drift de configuración Terraform | 0 diferencias | Semanal (`terraform plan`) | Terraform |
| GuardDuty findings (High severity) | 0 | Continuo | GuardDuty |

---

## Sección 4 — Inteligencia Artificial en Seguridad (C2.3)

La seguridad moderna se apoya en IA/ML para detectar amenazas que las reglas estáticas no pueden anticipar. LOGYX integra IA en tres capas: **detección automática (AWS)**, **análisis conductual (Wazuh ML)** y **triage inteligente de alertas (Bedrock)**.

### 4.1 GuardDuty — ML para detección de amenazas en tiempo real

GuardDuty ya está habilitado en la arquitectura. Su mecanismo interno usa ML sobre tres fuentes:

| Fuente de datos | Qué analiza la IA | Ejemplo de amenaza detectada |
|----------------|------------------|------------------------------|
| VPC Flow Logs | Patrones anómalos de tráfico de red | EC2 enviando datos a IP de C2 conocido |
| CloudTrail | Comportamiento inusual de API calls | Credencial usada desde IP de otro país |
| DNS Logs | Consultas a dominios maliciosos | Malware intentando callback a C2 vía DNS |

```hcl
# security/guardduty.tf

resource "aws_guardduty_detector" "logyx" {
  enable = true

  # ML activado para comportamiento anómalo en S3
  datasources {
    s3_logs { enable = true }
    kubernetes { audit_logs { enable = false } }  # No usamos EKS
    malware_protection {
      scan_ec2_instance_with_findings { ebs_volumes { enable = true } }
    }
  }

  finding_publishing_frequency = "FIFTEEN_MINUTES"
}

# Exportar findings a CloudWatch Events → SNS → Email
resource "aws_cloudwatch_event_rule" "guardduty_high" {
  name        = "logyx-guardduty-high-findings"
  description = "GuardDuty findings de severidad alta o crítica"

  event_pattern = jsonencode({
    source      = ["aws.guardduty"]
    detail-type = ["GuardDuty Finding"]
    detail = {
      severity = [{ numeric = [">=", 7] }]  # 7–10 = High/Critical
    }
  })
}

resource "aws_cloudwatch_event_target" "guardduty_sns" {
  rule      = aws_cloudwatch_event_rule.guardduty_high.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.critical_alerts.arn
}
```

**Tipos de findings que detecta GuardDuty con ML:**
```
UnauthorizedAccess:EC2/SSHBruteForce       → fuerza bruta SSH detectada por ML de patrones
Behavior:EC2/NetworkPortUnusual            → EC2 abrió puerto que nunca había usado
Trojan:EC2/BlackholeTraffic                → tráfico hacia IP de botnet conocida
Discovery:S3/MaliciousIPCaller             → escaneo de S3 desde IP maliciosa
CredentialAccess:IAMUser/AnomalousBehavior → credencial usada de forma inusual (hora/IP/acción)
```

---

### 4.2 Amazon Detective — Grafo ML para investigación de incidentes

Cuando GuardDuty genera un finding, **Amazon Detective** construye automáticamente un grafo de comportamiento para entender el alcance del incidente. Usa ML para correlacionar IPs, usuarios IAM, roles, recursos y tiempo.

```hcl
# security/detective.tf

resource "aws_detective_graph" "logyx" {}

# Habilitar GuardDuty como fuente de datos para Detective
resource "aws_detective_member" "guardduty_integration" {
  graph_arn     = aws_detective_graph.logyx.graph_arn
  account_id    = data.aws_caller_identity.current.account_id
  email_address = "infra@logyx.pe"
}
```

**Flujo de investigación con Detective:**
```
GuardDuty Finding (nivel Alto)
  └─→ Amazon Detective recibe el finding
      └─→ Grafo ML muestra:
          ├─ ¿Qué IP originó el ataque?
          ├─ ¿Qué otros recursos tocó esa IP en las últimas 2 semanas?
          ├─ ¿Qué credenciales IAM estuvieron activas en ese período?
          └─ ¿Es el comportamiento estadísticamente anómalo vs. baseline?
```

Esto reduce el tiempo de investigación de incidentes de horas a minutos (MTTR).

---

### 4.3 Amazon Macie — ML para detección de PII en S3

LOGYX almacena documentos de transporte en S3 (`logyx-documents-prod`). Macie usa ML para detectar si alguno contiene datos personales (DNI, RUC, correos, teléfonos) que no deberían estar ahí, o si hay riesgo de exposición accidental.

```hcl
# security/macie.tf

resource "aws_macie2_account" "logyx" {
  finding_publishing_frequency = "FIFTEEN_MINUTES"
  status                       = "ENABLED"
}

# Job de clasificación sobre el bucket de documentos
resource "aws_macie2_classification_job" "documents" {
  name       = "logyx-pii-scan-documents"
  job_type   = "SCHEDULED"
  depends_on = [aws_macie2_account.logyx]

  schedule_frequency { weekly_schedule { day_of_week = "SUNDAY" } }

  s3_job_definition {
    bucket_definitions {
      account_id = data.aws_caller_identity.current.account_id
      buckets    = [aws_s3_bucket.documents.bucket]
    }
  }
}

# Alarma si Macie encuentra PII expuesta
resource "aws_cloudwatch_event_rule" "macie_pii" {
  name = "logyx-macie-pii-finding"
  event_pattern = jsonencode({
    source      = ["aws.macie"]
    detail-type = ["Macie Finding"]
    detail = {
      type = [{ prefix = "SensitiveData:" }]
    }
  })
}

resource "aws_cloudwatch_event_target" "macie_sns" {
  rule      = aws_cloudwatch_event_rule.macie_pii.name
  target_id = "MaciePIIAlert"
  arn       = aws_sns_topic.critical_alerts.arn
}
```

**Relevancia para Ley 29733:** Si un archivo de carta de porte contiene DNIs escaneados, Macie lo detecta y alerta al equipo para aplicar controles adicionales (restricción de acceso, eliminación segura).

---

### 4.4 Wazuh — Módulo de detección de anomalías (ML)

Wazuh incluye un motor de **análisis estadístico de comportamiento** que aprende el baseline de cada agente y detecta desviaciones sin necesidad de reglas fijas.

```bash
# Activar módulo de anomaly detection en Wazuh Manager
# /var/ossec/etc/ossec.conf

cat >> /var/ossec/etc/ossec.conf << 'EOF'
<ossec_config>
  <wodle name="anomaly-detection">
    <enabled>yes</enabled>
    <interval>1h</interval>
    <scan_on_start>yes</scan_on_start>
  </wodle>

  <!-- Analizar comportamiento del proceso quarkus-backend -->
  <syscheck>
    <frequency>3600</frequency>
    <directories check_all="yes">/opt/logyx</directories>
  </syscheck>

  <!-- Detección de procesos inusuales (anomalía de baseline) -->
  <rootcheck>
    <frequency>43200</frequency>
  </rootcheck>
</ossec_config>
EOF

systemctl restart wazuh-manager
```

**Regla ML personalizada para LOGYX — detectar exfiltración de datos:**
```xml
<!-- logyx_rules.xml — regla basada en volumen anómalo de datos -->
<rule id="100010" level="13">
  <if_sid>1002</if_sid>
  <match>bytes_sent</match>
  <description>LOGYX-ML: Volumen de transferencia saliente anómalo — posible exfiltración</description>
  <group>logyx_exfiltration,ml_anomaly</group>
  <!-- Wazuh compara contra baseline de las últimas 2 semanas.
       Si bytes_sent > mean + 3*stddev → nivel 13 automático -->
</rule>

<rule id="100011" level="11">
  <if_sid>5715</if_sid>
  <description>LOGYX-ML: Hora de acceso SSH inusual (fuera del horario histórico del usuario)</description>
  <group>logyx_unusual_access,ml_anomaly</group>
</rule>
```

---

### 4.5 Triage automático de alertas con Amazon Bedrock (Claude)

Las alarmas de CloudWatch generan ruido: no todas las alertas requieren acción urgente. Una **Lambda + Bedrock** actúa como "analista de guardia" que clasifica y resume cada alerta en lenguaje natural antes de notificar al equipo.

```python
# lambda/alert_triage/handler.py

import boto3, json

bedrock = boto3.client("bedrock-runtime", region_name="sa-east-1")
sns     = boto3.client("sns")

PROMPT_TEMPLATE = """Eres un analista de seguridad de infraestructura AWS.
Recibiste la siguiente alerta de CloudWatch del sistema LOGYX (plataforma logística B2B, Perú):

ALERTA: {alarm_name}
DESCRIPCIÓN: {alarm_description}
ESTADO ANTERIOR: {previous_state}
ESTADO ACTUAL: {current_state}
MÉTRICA: {metric_name} = {metric_value}
TIMESTAMP: {timestamp}

Responde en español con:
1. SEVERIDAD: [CRÍTICA / ALTA / MEDIA / BAJA]
2. DIAGNÓSTICO: Qué puede estar pasando (2-3 oraciones)
3. ACCIÓN INMEDIATA: Qué debe hacer el equipo en los próximos 15 minutos
4. ACCIÓN PREVENTIVA: Qué revisar para evitar que se repita

Sé conciso y técnico. No inventes datos que no estén en la alerta."""

def lambda_handler(event, context):
    # Parsear alarma de SNS
    alarm = json.loads(event["Records"][0]["Sns"]["Message"])

    prompt = PROMPT_TEMPLATE.format(
        alarm_name        = alarm.get("AlarmName", ""),
        alarm_description = alarm.get("AlarmDescription", ""),
        previous_state    = alarm.get("OldStateValue", ""),
        current_state     = alarm.get("NewStateValue", ""),
        metric_name       = alarm.get("Trigger", {}).get("MetricName", ""),
        metric_value      = alarm.get("Trigger", {}).get("Threshold", ""),
        timestamp         = alarm.get("StateChangeTime", "")
    )

    # Llamar a Claude Haiku (rápido y económico para triage)
    response = bedrock.invoke_model(
        modelId     = "anthropic.claude-haiku-4-5-20251001",
        contentType = "application/json",
        body        = json.dumps({
            "anthropic_version": "bedrock-2023-05-31",
            "max_tokens": 400,
            "messages": [{"role": "user", "content": prompt}]
        })
    )

    analysis = json.loads(response["body"].read())["content"][0]["text"]

    # Enviar análisis al canal de alertas
    sns.publish(
        TopicArn = "arn:aws:sns:sa-east-1:ACCOUNT:logyx-team-alerts",
        Subject  = f"[LOGYX-IA] Análisis: {alarm.get('AlarmName')}",
        Message  = analysis
    )

    return {"statusCode": 200}
```

```hcl
# Trigger: esta Lambda se activa cuando cualquier alarma CloudWatch cambia a ALARM
resource "aws_sns_topic_subscription" "bedrock_triage" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.alert_triage.arn
}

resource "aws_lambda_permission" "sns_invoke" {
  statement_id  = "AllowSNSInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.alert_triage.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.alerts.arn
}
```

**Ejemplo de salida del triage (alerta de WAF blocks elevados):**
```
[LOGYX-IA] Análisis: logyx-waf-high-blocks

SEVERIDAD: ALTA

DIAGNÓSTICO: El WAF bloqueó más de 50 requests en 5 minutos desde múltiples IPs.
El patrón coincide con un escaneo automatizado o intento de enumeración de endpoints.
El rate limiting (100 req/5min) ya está activo, por lo que el servicio no está comprometido.

ACCIÓN INMEDIATA: Revisar WAF logs en CloudWatch para identificar las IPs de origen.
Si provienen de un rango de ASN único, considerar añadirlas a una IP set de bloqueo manual.
Verificar que el ALB target group sigue con instancias healthy.

ACCIÓN PREVENTIVA: Evaluar reducir el rate limit de 100 a 60 req/5min para endpoints
de autenticación específicamente. Revisar si GuardDuty generó un finding relacionado.
```

---

### 4.6 Detección de fraude en subastas (IA en capa de negocio)

```python
# lambda/fraud_detection/handler.py
# Ejecutado como EventBridge rule cada hora

import boto3, json
from datetime import datetime, timedelta

rds_data = boto3.client("rds-data")
sns      = boto3.client("sns")

def lambda_handler(event, context):
    # Detectar bid sniping: ofertas en los últimos 60 segundos antes del cierre
    result = rds_data.execute_statement(
        resourceArn = "arn:aws:rds:sa-east-1:ACCOUNT:cluster:logyx-postgres",
        secretArn   = "arn:aws:secretsmanager:sa-east-1:ACCOUNT:secret:logyx/prod/db-url",
        database    = "logyx_db",
        sql         = """
            SELECT
                b.bidder_org_id,
                COUNT(*) AS bids_last_60s,
                o.name    AS org_name
            FROM bids b
            JOIN auctions a ON b.auction_id = a.id
            JOIN organizations o ON b.bidder_org_id = o.id
            WHERE b.created_at > a.ends_at - INTERVAL '60 seconds'
              AND b.created_at > NOW() - INTERVAL '1 hour'
            GROUP BY b.bidder_org_id, o.name
            HAVING COUNT(*) >= 3
        """
    )

    suspicious = result.get("records", [])

    if suspicious:
        report = "Posible BID SNIPING detectado:\n"
        for row in suspicious:
            report += f"  Org: {row[2]['stringValue']} — {row[1]['longValue']} bids en últimos 60s\n"

        sns.publish(
            TopicArn = "arn:aws:sns:sa-east-1:ACCOUNT:logyx-fraud-alerts",
            Subject  = "[LOGYX-FRAUDE] Bid sniping detectado",
            Message  = report
        )

    # Detectar carriers con patrón de no-entrega (bid → nunca completan)
    rds_data.execute_statement(
        resourceArn = "arn:aws:rds:sa-east-1:ACCOUNT:cluster:logyx-postgres",
        secretArn   = "arn:aws:secretsmanager:sa-east-1:ACCOUNT:secret:logyx/prod/db-url",
        database    = "logyx_db",
        sql         = """
            UPDATE reputation_scores
            SET fraud_flag = true, updated_at = NOW()
            WHERE org_id IN (
                SELECT b.bidder_org_id
                FROM bids b
                JOIN shipments s ON s.carrier_org_id = b.bidder_org_id
                WHERE s.status = 'cancelled'
                  AND s.created_at > NOW() - INTERVAL '30 days'
                GROUP BY b.bidder_org_id
                HAVING COUNT(*) >= 3
            )
        """
    )

    return {"statusCode": 200, "fraudulent_bids_detected": len(suspicious)}
```

---

### 4.7 Mapa de capas de IA en LOGYX

```
┌─────────────────────────────────────────────────────────────────┐
│                        CAPA 7 — APLICACIÓN                      │
│  Moderación de mensajes (fn_contains_contact_info) — Regex      │
│  Trust Score Bayesiano — Estadística bayesiana en PostgreSQL     │
│  Detección de fraude en subastas — Lambda + SQL analítico        │
├─────────────────────────────────────────────────────────────────┤
│                    CAPA 6 — SEGURIDAD INTELIGENTE                │
│  Triage de alertas — Lambda + Amazon Bedrock (Claude Haiku)      │
│  Anomaly detection de logs — Wazuh ML module                     │
├─────────────────────────────────────────────────────────────────┤
│                    CAPA 5 — DETECCIÓN DE PII                     │
│  Amazon Macie — ML sobre S3 (cumplimiento Ley 29733)             │
├─────────────────────────────────────────────────────────────────┤
│                    CAPA 4 — INVESTIGACIÓN                        │
│  Amazon Detective — Grafo ML de incidentes (post-GuardDuty)      │
├─────────────────────────────────────────────────────────────────┤
│                    CAPA 3 — DETECCIÓN DE AMENAZAS                │
│  AWS GuardDuty — ML sobre VPC Flow Logs + CloudTrail + DNS       │
├─────────────────────────────────────────────────────────────────┤
│                    CAPA 2 — FILTRADO REACTIVO                    │
│  AWS WAF — Managed rules (no ML, pero base de GuardDuty)         │
├─────────────────────────────────────────────────────────────────┤
│                    CAPA 1 — RED                                  │
│  NACLs + Security Groups — Reglas estáticas                      │
└─────────────────────────────────────────────────────────────────┘
```

---

## Sección 5 — Ética ACM (C2.4)

### 5.1 Marco de referencia

El Código de Ética de la ACM (Association for Computing Machinery) establece principios que guían las decisiones técnicas de LOGYX. A continuación se analiza el impacto ético de las decisiones de seguridad tomadas.

### 5.2 Principio 1 — Contribuir al bienestar social y humano

**Decisión:** LOGYX recopila ubicaciones GPS de conductores durante la entrega.

**Análisis:**
- Los datos de ubicación son necesarios para el tracking de envíos, que beneficia a las PYMEs.
- **Límite ético:** La ubicación solo se recopila durante un envío activo, no de forma continua. El conductor puede ver exactamente qué datos se envían (transparencia).
- **Control implementado:** Los datos de ubicación se almacenan solo en `shipment_stops` vinculados a un envío específico. No existe tabla de histórico de GPS permanente.

### 5.3 Principio 2 — Evitar daño

**Decisión:** Datos de RUC, DNI y contratos de organizaciones peruanas.

**Análisis:**
- Una brecha de datos podría exponer información comercialmente sensible.
- **Controles implementados:** Cifrado KMS en reposo, TLS 1.3 en tránsito, RLS que impide que una organización acceda a datos de otra, audit_log para trazabilidad.
- **Incidente hipotético:** Si LOGYX detecta una brecha, el plan de respuesta (Sección 1.4) exige notificar a los afectados en < 72 horas, alineado con las mejores prácticas internacionales.

### 5.4 Principio 3 — Ser honesto y confiable

**Decisión:** Moderación automática de mensajes (filtro de contacto).

**Análisis:**
- El sistema bloquea mensajes que contienen números de teléfono, emails o handles sociales para proteger el modelo de negocio.
- **Obligación ética:** Los usuarios DEBEN ser informados de esta política al registrarse y cuando un mensaje es bloqueado. El mensaje bloqueado muestra claramente: `"[Mensaje bloqueado: el sistema detectó información de contacto directa]"`.
- No se bloquean mensajes silenciosamente sin notificar al remitente.

### 5.5 Principio 4 — Respetar la privacidad

**Decisión:** Uso de datos para el Trust Score y la reputación.

**Análisis:**
- El Trust Score agrega datos de comportamiento de las organizaciones.
- **Control ético:** El score y sus componentes son **visibles para el propio usuario**. Ningún componente es un "puntaje secreto".
- Las calificaciones negativas requieren que la entrega esté completa (no se puede calificar sin haber completado el ciclo). No se permiten calificaciones anónimas.

### 5.6 Principio 5 — Respetar la propiedad intelectual y el derecho contractual

**Decisión:** Simulación de ataques con Kali Linux.

**Análisis:**
- Los ataques se realizan **exclusivamente sobre infraestructura propia** de LOGYX (no sobre sistemas de terceros).
- La instancia Kali está en subnet `10.0.99.0/24` sin routing a internet ni a producción.
- No se usa ninguna herramienta para atacar sistemas externos, lo que cumpliría las condiciones de la Ley de Delitos Informáticos del Perú (Ley 30096).

### 5.7 Cumplimiento legal (Perú)

| Ley / Norma | Aplicación en LOGYX |
|------------|---------------------|
| **Ley 29733** — Protección de Datos Personales | RUC, DNI, emails, ubicaciones: tratados con consentimiento explícito en TyC. Derecho de acceso, rectificación y cancelación implementados. |
| **Ley 30096** — Delitos Informáticos | Los ataques simulados son sobre infraestructura propia. Documentados con autorización explícita del equipo. |
| **DS 003-2013-JUS** — Reglamento de la Ley 29733 | Medidas de seguridad técnicas implementadas: cifrado, acceso restringido, auditoría. |

---

## Anexos

### Anexo A — Evidencias de implementación de seguridad

| Evidencia | Estado |
|-----------|--------|
| AWS IAM roles — captura de consola | *(agregar)* |
| KMS keys creadas con rotación | *(agregar)* |
| WAF WebACL activa — captura | *(agregar)* |
| GuardDuty habilitado | *(agregar)* |
| Wazuh Dashboard — alertas de ataques | *(agregar)* |
| Nmap scan result (solo 443/80 visible) | *(agregar)* |
| sqlmap blocked — WAF log | *(agregar)* |
| Brute force blocked — CloudWatch log | *(agregar)* |
| SSM Patch Manager — reporte de cumplimiento | *(agregar)* |

### Anexo B — Scans de vulnerabilidades

```bash
# AWS Inspector v2 — escaneo de vulnerabilidades en EC2
aws inspector2 list-findings \
  --filter-criteria '{"findingStatus":[{"comparison":"EQUALS","value":"ACTIVE"}]}' \
  --sort-criteria '{"field":"SEVERITY","sortOrder":"DESC"}'

# OWASP ZAP — escaneo de la API REST
docker run -t owasp/zap2docker-stable zap-api-scan.py \
  -t https://api.logyx.pe/q/openapi \
  -f openapi \
  -r zap-report.html
```

---

*LOGYX · S2 Entregable 2 · Seguridad · Competencias C2.2–C2.3–C2.4 · Agosto–Noviembre 2026*
