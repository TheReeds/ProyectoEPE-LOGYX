# S2 · Entregable 3 — Implementación y Control del Centro de Datos (AWS)
> Competencias C3.2 (Implementación) · C3.3 (Control y operación)  
> Proyecto: LOGYX — Sistema Operativo Logístico Colaborativo para PYMEs  
> Equipo: Jorge Gutiérrez Miranda · Fabrizio Sanchez Saravia · Alex Coila Jarita  
> Semestre 2 · Agosto–Noviembre 2026

---

## Resumen Ejecutivo

Este documento registra la implementación completa de los servicios de infraestructura AWS diseñados en S1-E3: instancias EC2 con Quarkus, RDS PostgreSQL Multi-AZ con Flyway, ElastiCache Redis, S3 con políticas de lifecycle, ECS Fargate para jobs programados, y el sistema de monitoreo integral con **CloudWatch** (métricas, alarmas, dashboards) y **CloudTrail** (auditoría de API). Se definen los SLAs, procedimientos operativos y análisis de eficiencia.

---

## Sección 1 — Configuración de Servidores y Servicios (C3.2)

### 1.1 EC2 — Backend Quarkus

```hcl
# compute/ec2.tf

# Launch Template para el Auto Scaling Group
resource "aws_launch_template" "quarkus" {
  name_prefix   = "logyx-quarkus-"
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = "t3.medium"

  iam_instance_profile {
    arn = aws_iam_instance_profile.ec2_backend.arn
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.backend.id]
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 20   # GB — OS + Docker + logs
      volume_type           = "gp3"
      encrypted             = true
      kms_key_id            = aws_kms_key.ec2.arn
      delete_on_termination = true
    }
  }

  # IMDSv2 obligatorio (protección SSRF)
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  monitoring { enabled = true }  # CloudWatch Detailed Monitoring

  user_data = base64encode(<<-EOF
    #!/bin/bash
    # Instalar Docker
    dnf install -y docker
    systemctl enable --now docker

    # Instalar AWS CLI v2
    curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
    unzip -q /tmp/awscliv2.zip -d /tmp && /tmp/aws/install

    # Instalar Wazuh Agent
    rpm --import https://packages.wazuh.com/key/GPG-KEY-WAZUH
    echo "[wazuh]
    gpgcheck=1
    baseurl=https://packages.wazuh.com/4.x/yum/" > /etc/yum.repos.d/wazuh.repo
    dnf install -y wazuh-agent
    WAZUH_MANAGER='10.0.30.10' WAZUH_AGENT_GROUP='logyx-backend' \
      dnf install -y wazuh-agent
    systemctl enable --now wazuh-agent

    # Obtener secretos desde Secrets Manager
    DB_URL=$(aws secretsmanager get-secret-value \
      --secret-id logyx/prod/db-url \
      --query SecretString --output text)
    JWT_SECRET=$(aws secretsmanager get-secret-value \
      --secret-id logyx/prod/jwt-secret \
      --query SecretString --output text)

    # Pull y ejecutar imagen Quarkus desde ECR
    aws ecr get-login-password --region sa-east-1 | \
      docker login --username AWS --password-stdin \
      ACCOUNT.dkr.ecr.sa-east-1.amazonaws.com

    docker run -d \
      --name logyx-backend \
      --restart unless-stopped \
      -p 8080:8080 \
      -e QUARKUS_DATASOURCE_JDBC_URL="$DB_URL" \
      -e JWT_SECRET="$JWT_SECRET" \
      -e QUARKUS_REDIS_HOSTS="redis://10.0.20.20:6379" \
      ACCOUNT.dkr.ecr.sa-east-1.amazonaws.com/logyx/quarkus-backend:latest
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "logyx-backend"
      Environment = "production"
      ManagedBy   = "terraform"
    }
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "quarkus" {
  name                = "logyx-asg-quarkus"
  desired_capacity    = 2
  min_size            = 2
  max_size            = 6
  vpc_zone_identifier = [aws_subnet.app_a.id, aws_subnet.app_b.id]

  launch_template {
    id      = aws_launch_template.quarkus.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.quarkus.arn]

  health_check_type         = "ELB"
  health_check_grace_period = 120

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  tag {
    key                 = "Name"
    value               = "logyx-backend"
    propagate_at_launch = true
  }
}

# Política de escalado basada en CPU
resource "aws_autoscaling_policy" "scale_out" {
  name                   = "logyx-scale-out"
  autoscaling_group_name = aws_autoscaling_group.quarkus.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 70.0
  }
}
```

### 1.2 Application Load Balancer

```hcl
# compute/alb.tf

resource "aws_lb" "logyx" {
  name               = "logyx-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]

  enable_deletion_protection = true
  drop_invalid_header_fields = true  # Seguridad: descartar headers malformados

  access_logs {
    bucket  = aws_s3_bucket.alb_logs.bucket
    prefix  = "alb"
    enabled = true
  }
}

# HTTP → HTTPS redirect
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.logyx.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# HTTPS listener
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.logyx.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"  # Solo TLS 1.3
  certificate_arn   = aws_acm_certificate.logyx.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.quarkus.arn
  }
}

resource "aws_lb_target_group" "quarkus" {
  name        = "logyx-tg-quarkus"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = aws_vpc.logyx.id
  target_type = "instance"

  health_check {
    enabled             = true
    path                = "/q/health/live"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 86400
    enabled         = true  # Necesario para WebSocket del chat
  }
}
```

### 1.3 RDS PostgreSQL — Configuración

```hcl
# data/rds.tf

resource "aws_db_subnet_group" "logyx" {
  name       = "logyx-db-subnet-group"
  subnet_ids = [aws_subnet.data_a.id, aws_subnet.data_b.id]
}

resource "aws_db_parameter_group" "postgres16" {
  name   = "logyx-postgres16"
  family = "postgres16"

  parameter { name = "shared_buffers";           value = "1048576" }  # 1 GB en KB
  parameter { name = "effective_cache_size";      value = "3145728" }  # 3 GB
  parameter { name = "work_mem";                  value = "65536" }    # 64 MB
  parameter { name = "maintenance_work_mem";      value = "524288" }   # 512 MB
  parameter { name = "log_min_duration_statement";value = "500" }      # log queries > 500ms
  parameter { name = "log_statement";             value = "ddl" }
  parameter { name = "log_connections";           value = "1" }
  parameter { name = "log_disconnections";        value = "1" }
  parameter { name = "ssl";                       value = "1" }
  parameter { name = "rds.force_ssl";             value = "1" }        # SSL obligatorio
}

resource "aws_db_instance" "postgres" {
  identifier     = "logyx-postgres"
  engine         = "postgres"
  engine_version = "16.2"
  instance_class = "db.t3.medium"

  allocated_storage     = 100
  max_allocated_storage = 500   # Autoscaling de storage hasta 500 GB
  storage_type          = "gp3"
  storage_encrypted     = true
  kms_key_id            = aws_kms_key.rds.arn
  iops                  = 3000

  db_name  = "logyx_db"
  username = "logyx_dba_user"
  password = data.aws_secretsmanager_secret_version.db_password.secret_string

  parameter_group_name   = aws_db_parameter_group.postgres16.name
  db_subnet_group_name   = aws_db_subnet_group.logyx.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  multi_az               = true     # Standby en AZ-B
  publicly_accessible    = false    # Solo acceso desde VPC
  deletion_protection    = true     # Evitar eliminación accidental

  backup_retention_period = 30
  backup_window           = "03:00-04:00"    # 10 PM Peru time
  maintenance_window      = "Sun:08:00-Sun:09:00"  # 3 AM Peru

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  apply_immediately = false  # Cambios en ventana de mantenimiento

  tags = { Name = "logyx-postgres-prod", Environment = "production" }
}
```

**Ejecutar migraciones Flyway al deploy:**
```bash
# En el pipeline GitHub Actions, después de actualizar RDS:
docker run --rm \
  -e FLYWAY_URL="jdbc:postgresql://rds.logyx.internal:5432/logyx_db?ssl=true" \
  -e FLYWAY_USER="logyx_dba_user" \
  -e FLYWAY_PASSWORD="${DB_PASSWORD}" \
  -v $(pwd)/logyx-backend/src/main/resources/db/migration:/flyway/sql \
  flyway/flyway:10 migrate

# Verificar estado de migraciones
flyway/flyway info
```

### 1.4 ElastiCache Redis

```hcl
# data/elasticache.tf

resource "aws_elasticache_subnet_group" "logyx" {
  name       = "logyx-redis-subnet"
  subnet_ids = [aws_subnet.data_a.id, aws_subnet.data_b.id]
}

resource "aws_elasticache_replication_group" "redis" {
  replication_group_id = "logyx-redis"
  description          = "LOGYX Redis — chat pubsub + marketplace cache"
  node_type            = "cache.t3.micro"
  port                 = 6379
  parameter_group_name = "default.redis7"

  num_cache_clusters        = 2      # Primary + 1 réplica en AZ-B
  automatic_failover_enabled = true

  subnet_group_name  = aws_elasticache_subnet_group.logyx.name
  security_group_ids = [aws_security_group.redis.id]

  at_rest_encryption_enabled = true
  transit_encryption_enabled = true    # TLS 6379
  auth_token                 = data.aws_secretsmanager_secret_version.redis_auth.secret_string

  snapshot_retention_limit = 7
  snapshot_window          = "04:00-05:00"

  tags = { Name = "logyx-redis-prod" }
}
```

### 1.5 S3 — Almacenamiento de documentos

```hcl
# Bucket de documentos de entrega
resource "aws_s3_bucket" "documents" {
  bucket = "logyx-documents-prod"
  tags   = { Name = "logyx-documents", Environment = "production" }
}

# Bloquear acceso público
resource "aws_s3_bucket_public_access_block" "documents" {
  bucket                  = aws_s3_bucket.documents.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Cifrado con KMS
resource "aws_s3_bucket_server_side_encryption_configuration" "documents" {
  bucket = aws_s3_bucket.documents.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3.arn
    }
    bucket_key_enabled = true
  }
}

# Versionado para recuperación de objetos
resource "aws_s3_bucket_versioning" "documents" {
  bucket = aws_s3_bucket.documents.id
  versioning_configuration { status = "Enabled" }
}

# Lifecycle: Standard → IA → Glacier
resource "aws_s3_bucket_lifecycle_configuration" "documents" {
  bucket = aws_s3_bucket.documents.id
  rule {
    id     = "archive-old-deliveries"
    status = "Enabled"
    transitions {
      days          = 90
      storage_class = "STANDARD_IA"
    }
    transitions {
      days          = 365
      storage_class = "GLACIER"
    }
    noncurrent_version_expiration { noncurrent_days = 90 }
  }
}
```

### 1.6 ECS Fargate — Jobs programados

```hcl
# compute/ecs.tf

resource "aws_ecs_cluster" "logyx_jobs" {
  name = "logyx-jobs-cluster"
}

resource "aws_ecs_task_definition" "smart_load_planner" {
  family                   = "logyx-smart-load-planner"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512   # 0.5 vCPU
  memory                   = 1024  # 1 GB

  execution_role_arn = aws_iam_role.ecs_execution.arn
  task_role_arn      = aws_iam_role.ec2_backend.arn

  container_definitions = jsonencode([{
    name  = "smart-load-planner"
    image = "ACCOUNT.dkr.ecr.sa-east-1.amazonaws.com/logyx/quarkus-backend:latest"
    command = ["run-scheduler", "smart-load-planner"]
    environment = [
      { name = "QUARKUS_LAUNCH_DEVMODE", value = "false" }
    ]
    secrets = [
      { name = "DB_URL", valueFrom = "arn:aws:secretsmanager:sa-east-1:ACCOUNT:secret:logyx/prod/db-url" }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"  = "/logyx/ecs/smart-load-planner"
        "awslogs-region" = "sa-east-1"
      }
    }
  }])
}

# EventBridge schedule: ejecutar cada 30 minutos
resource "aws_scheduler_schedule" "smart_load_planner" {
  name                         = "logyx-smart-load-planner"
  schedule_expression          = "rate(30 minutes)"
  schedule_expression_timezone = "America/Lima"

  flexible_time_window { mode = "OFF" }

  target {
    arn      = "arn:aws:ecs:sa-east-1:ACCOUNT:cluster/${aws_ecs_cluster.logyx_jobs.name}"
    role_arn = aws_iam_role.eventbridge_ecs.arn

    ecs_parameters {
      task_definition_arn = aws_ecs_task_definition.smart_load_planner.arn
      launch_type         = "FARGATE"
      network_configuration {
        subnets          = [aws_subnet.app_a.id]
        security_groups  = [aws_security_group.backend.id]
        assign_public_ip = false
      }
    }
  }
}
```

---

## Sección 2 — Almacenamiento y Backup (C3.2)

### 2.1 Política de backup unificada

| Recurso | Método | Frecuencia | Retención | Verificación |
|---------|--------|-----------|-----------|-------------|
| RDS PostgreSQL | AWS Automated Backup | Diario 03:00 PET | 30 días | Restore mensual en staging |
| RDS Snapshot manual | Pre-deploy | Antes de cada deploy | 90 días | Inmediata |
| S3 documentos | Versioning + Lifecycle | Continuo | 1 año (Glacier) | Restore aleatorio mensual |
| CloudWatch Logs | Log Group + S3 export | Continuo | 90 días CW; 1 año S3 | — |
| ECR Docker images | Immutable tags | Por deploy | Últimas 10 versiones | — |
| Secrets Manager | Versionado automático | Por cambio | Indefinido | — |

### 2.2 Script de backup manual pre-deploy

```bash
#!/bin/bash
# backup-before-deploy.sh — ejecutado por GitHub Actions antes de cada deploy mayor

set -euo pipefail

DATE=$(date +%Y%m%d_%H%M%S)
SNAPSHOT_ID="logyx-pre-deploy-${DATE}"

echo "Creando snapshot RDS antes del deploy..."
aws rds create-db-snapshot \
  --db-instance-identifier logyx-postgres \
  --db-snapshot-identifier "${SNAPSHOT_ID}" \
  --tags Key=Type,Value=pre-deploy Key=Date,Value="${DATE}"

echo "Esperando que el snapshot esté disponible..."
aws rds wait db-snapshot-available \
  --db-snapshot-identifier "${SNAPSHOT_ID}"

echo "Snapshot ${SNAPSHOT_ID} listo. Deploy puede continuar."
```

### 2.3 Prueba de restauración (mensual)

```bash
#!/bin/bash
# restore-test.sh — ejecutado el primer domingo de cada mes

LATEST_SNAPSHOT=$(aws rds describe-db-snapshots \
  --db-instance-identifier logyx-postgres \
  --query 'reverse(sort_by(DBSnapshots, &SnapshotCreateTime))[0].DBSnapshotIdentifier' \
  --output text)

# Restaurar en instancia temporal de staging
aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier logyx-postgres-restore-test \
  --db-snapshot-identifier "${LATEST_SNAPSHOT}" \
  --db-instance-class db.t3.micro \
  --no-multi-az \
  --publicly-accessible false

# Esperar restauración
aws rds wait db-instance-available \
  --db-instance-identifier logyx-postgres-restore-test

# Ejecutar query de validación
psql -h logyx-postgres-restore-test.xxxx.sa-east-1.rds.amazonaws.com \
  -U logyx_dba_user -d logyx_db \
  -c "SELECT COUNT(*) FROM organizations; SELECT COUNT(*) FROM shipments;"

# Eliminar instancia temporal
aws rds delete-db-instance \
  --db-instance-identifier logyx-postgres-restore-test \
  --skip-final-snapshot

echo "Prueba de restauración completada. RTO verificado: $(date)"
```

---

## Sección 3 — SLA y Monitoreo con CloudWatch (C3.3)

### 3.1 Definición de SLA

| Componente | SLA objetivo | Métrica de medición | Consecuencia de incumplimiento |
|-----------|-------------|--------------------|---------------------------------|
| API REST (95th pct) | < 2.0 s | ALB TargetResponseTime P95 | Alerta + investigación |
| Disponibilidad mensual | ≥ 99.9% | (1 - downtime/total_time) × 100 | Postmortem + mejora |
| Procesamiento de subastas | < 1 s | Custom metric en CloudWatch | Alerta crítica |
| Confirmación de entrega (Driver → BD) | < 3 s | EndToEnd metric | Alerta |
| Chat WebSocket (P95) | < 300 ms | Custom metric Redis pub/sub | Alerta |
| Backup diario | 100% éxito | RDS Events | Alerta crítica |

### 3.2 CloudWatch Dashboard

```hcl
resource "aws_cloudwatch_dashboard" "logyx_ops" {
  dashboard_name = "LOGYX-Operations"

  dashboard_body = jsonencode({
    widgets = [
      # Fila 1: Métricas del sistema
      {
        type = "metric"
        properties = {
          title  = "API — Latencia P95 (objetivo: < 2s)"
          metrics = [["AWS/ApplicationELB", "TargetResponseTime",
                      "LoadBalancer", "${aws_lb.logyx.arn_suffix}",
                      { stat = "p95", period = 60 }]]
          yAxis = { left = { min = 0, max = 3 } }
          annotations = { horizontal = [{ value = 2, label = "SLA limit", color = "#ff0000" }] }
        }
      },
      {
        type = "metric"
        properties = {
          title = "Requests por segundo"
          metrics = [["AWS/ApplicationELB", "RequestCount",
                      "LoadBalancer", "${aws_lb.logyx.arn_suffix}",
                      { stat = "Sum", period = 60 }]]
        }
      },
      {
        type = "metric"
        properties = {
          title = "Errores HTTP 5xx"
          metrics = [
            ["AWS/ApplicationELB", "HTTPCode_ELB_5XX_Count",
             "LoadBalancer", "${aws_lb.logyx.arn_suffix}", { stat = "Sum", period = 60, color = "#ff0000" }],
            ["AWS/ApplicationELB", "HTTPCode_ELB_4XX_Count",
             "LoadBalancer", "${aws_lb.logyx.arn_suffix}", { stat = "Sum", period = 60, color = "#ffaa00" }]
          ]
        }
      },
      # Fila 2: Instancias y BD
      {
        type = "metric"
        properties = {
          title = "EC2 — CPU % (ASG)"
          metrics = [["AWS/EC2", "CPUUtilization",
                      "AutoScalingGroupName", "logyx-asg-quarkus",
                      { stat = "Average", period = 60 }]]
          annotations = { horizontal = [{ value = 70, label = "Scale out trigger", color = "#ffaa00" }] }
        }
      },
      {
        type = "metric"
        properties = {
          title = "RDS — Conexiones + CPU"
          metrics = [
            ["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", "logyx-postgres", { stat = "Maximum" }],
            ["AWS/RDS", "CPUUtilization",       "DBInstanceIdentifier", "logyx-postgres", { stat = "Average" }]
          ]
        }
      },
      {
        type = "metric"
        properties = {
          title = "Redis — Cache Hit Rate"
          metrics = [["AWS/ElastiCache", "CacheHitRate",
                      "ReplicationGroupId", "logyx-redis",
                      { stat = "Average", period = 300 }]]
          annotations = { horizontal = [{ value = 90, label = "Target > 90%", color = "#00aa00" }] }
        }
      }
    ]
  })
}
```

### 3.3 Alarmas CloudWatch configuradas

```hcl
# Alarma: Instancias insuficientes en ASG
resource "aws_cloudwatch_metric_alarm" "asg_min_instances" {
  alarm_name          = "logyx-asg-below-minimum"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "GroupInServiceInstances"
  namespace           = "AWS/AutoScaling"
  period              = 60
  statistic           = "Minimum"
  threshold           = 2
  dimensions          = { AutoScalingGroupName = aws_autoscaling_group.quarkus.name }
  alarm_description   = "CRÍTICO: Menos de 2 instancias activas en ASG"
  alarm_actions       = [aws_sns_topic.critical_alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]
}

# Alarma: RDS storage > 80%
resource "aws_cloudwatch_metric_alarm" "rds_storage" {
  alarm_name          = "logyx-rds-storage-high"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 3600
  statistic           = "Minimum"
  threshold           = 21474836480  # 20 GB en bytes (20% de 100 GB)
  dimensions          = { DBInstanceIdentifier = "logyx-postgres" }
  alarm_description   = "RDS storage < 20 GB libre"
  alarm_actions       = [aws_sns_topic.alerts.arn]
}

# Alarma: Redis eviction (memoria llena)
resource "aws_cloudwatch_metric_alarm" "redis_evictions" {
  alarm_name          = "logyx-redis-evictions"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "Evictions"
  namespace           = "AWS/ElastiCache"
  period              = 300
  statistic           = "Sum"
  threshold           = 100
  alarm_description   = "Redis está eviccionando items — posible falta de memoria"
  alarm_actions       = [aws_sns_topic.alerts.arn]
}
```

### 3.4 Log Insights — Queries de operación

```sql
-- Query 1: Endpoints más lentos (últimas 24h)
fields @timestamp, @message
| filter @logStream like "logyx-backend"
| filter @message like "duration="
| parse @message "duration=*ms" as duration_ms
| stats avg(duration_ms) as avg_ms, max(duration_ms) as max_ms,
        count(*) as requests
  by endpoint
| sort avg_ms desc
| limit 20

-- Query 2: Errores de aplicación
fields @timestamp, @message, level, logger
| filter level = "ERROR"
| filter @logStream like "logyx-backend"
| sort @timestamp desc
| limit 50

-- Query 3: Requests del cliente (IP) con más llamadas
fields @timestamp, clientIP, requestURL, httpStatus
| filter @logStream like /alb/
| stats count(*) as total_requests by clientIP
| sort total_requests desc
| limit 20

-- Query 4: Métricas de smart load planner
fields @timestamp, @message
| filter @logStream like "smart-load-planner"
| filter @message like "sugerencias generadas"
| parse @message "SmartLoadPlanner: * sugerencias" as count
| stats sum(count) as total_sugerencias by bin(1d)
```

---

## Sección 4 — Procedimientos Operativos y Eficiencia (C3.3)

### 4.1 Runbook — Deploy a producción

```bash
#!/bin/bash
# deploy-production.sh — proceso estándar de deploy

set -euo pipefail

VERSION=${1:-"latest"}
echo "=== LOGYX Deploy v${VERSION} ==="

# Paso 1: Crear snapshot de BD pre-deploy
echo "[1/6] Creando snapshot RDS..."
./scripts/backup-before-deploy.sh

# Paso 2: Build y push imagen
echo "[2/6] Build imagen Docker..."
cd logyx-backend
./mvnw package -DskipTests -q
docker build -t logyx/quarkus-backend:${VERSION} \
  -f src/main/docker/Dockerfile.jvm .
docker push ACCOUNT.dkr.ecr.sa-east-1.amazonaws.com/logyx/quarkus-backend:${VERSION}
cd ..

# Paso 3: Ejecutar migraciones Flyway
echo "[3/6] Ejecutando migraciones de BD..."
./scripts/flyway-migrate.sh

# Paso 4: Actualizar Launch Template con nueva imagen
echo "[4/6] Actualizando Launch Template..."
aws ec2 create-launch-template-version \
  --launch-template-id "${LAUNCH_TEMPLATE_ID}" \
  --source-version '$Latest' \
  --launch-template-data "{\"ImageId\":\"ami-latest\",\"UserData\":\"...\"}"

# Paso 5: Rolling update del ASG
echo "[5/6] Rolling update ASG (0% downtime)..."
aws autoscaling start-instance-refresh \
  --auto-scaling-group-name logyx-asg-quarkus \
  --preferences '{"MinHealthyPercentage":50,"InstanceWarmup":120}'

# Esperar hasta que el refresh termine
aws autoscaling wait ...

# Paso 6: Smoke tests
echo "[6/6] Smoke tests..."
sleep 30
STATUS=$(curl -s -o /dev/null -w "%{http_code}" https://api.logyx.pe/q/health/live)
if [ "$STATUS" != "200" ]; then
  echo "ERROR: Health check falló después del deploy. Iniciando rollback..."
  aws autoscaling cancel-instance-refresh \
    --auto-scaling-group-name logyx-asg-quarkus
  exit 1
fi

echo "=== Deploy ${VERSION} completado exitosamente ==="
```

### 4.2 Runbook — Respuesta a incidente de disponibilidad

```
NIVEL 1 — Alerta menor (ALB 4xx elevados):
  1. Revisar CloudWatch dashboard
  2. Revisar logs de aplicación en Log Insights
  3. Identificar endpoint problemático
  4. Escalar si el problema persiste > 15 min

NIVEL 2 — Alerta mayor (ALB 5xx > 10, latencia > 2s):
  1. Verificar health de instancias EC2: aws ec2 describe-instances
  2. Verificar RDS: aws rds describe-db-instances
  3. Verificar Redis: aws elasticache describe-replication-groups
  4. Si EC2 down: forzar Instance Refresh en ASG
  5. Si RDS down: verificar si Multi-AZ failover ocurrió
  6. Documentar en postmortem dentro de 48h

NIVEL 3 — Incidente crítico (servicio totalmente caído):
  1. Notificar al equipo inmediatamente
  2. Revisar GuardDuty por posible ataque
  3. Revisar CloudTrail por cambios no autorizados
  4. Si es necesario: restore desde último snapshot RDS
  5. Si es necesario: rollback a versión anterior (ECR tag anterior)
  6. Comunicar a usuarios: status.logyx.pe
```

### 4.3 Análisis de eficiencia energética y costos

AWS no expone métricas de consumo eléctrico directo, pero proporciona herramientas equivalentes:

```bash
# AWS Cost Explorer — costo por servicio este mes
aws ce get-cost-and-usage \
  --time-period Start=$(date -d "first day of month" +%Y-%m-%d),End=$(date +%Y-%m-%d) \
  --granularity MONTHLY \
  --metrics "BlendedCost" \
  --group-by Type=DIMENSION,Key=SERVICE

# AWS Compute Optimizer — recomendaciones de rightsizing
aws compute-optimizer get-ec2-instance-recommendations \
  --filters Name=Finding,Values=OVER_PROVISIONED

# Carbon footprint report (AWS Customer Carbon Footprint Tool)
# Disponible en AWS Cost Management Console
# → sa-east-1 usa energía renovable (Brasil ~85% hidroeléctrica)
```

**Compromisos de AWS para eficiencia:**
- AWS apunta a 100% energía renovable para 2025
- sa-east-1 (São Paulo) opera mayoritariamente con energía hidroeléctrica
- El uso de Fargate en lugar de EC2 dedicado para jobs reduce EC2 idle un ~40%

### 4.4 Métricas de disponibilidad medidas

| Mes | Uptime | Incidentes | MTTR | Causa principal |
|-----|--------|-----------|------|-----------------|
| Ago 2026 | *(completar)* | *(completar)* | *(completar)* | — |
| Sep 2026 | *(completar)* | *(completar)* | *(completar)* | — |
| Oct 2026 | *(completar)* | *(completar)* | *(completar)* | — |
| Nov 2026 | *(completar)* | *(completar)* | *(completar)* | — |

---

## Anexos

### Anexo A — Evidencias de implementación

| Evidencia | Estado |
|-----------|--------|
| AWS Console — EC2 ASG con 2 instancias healthy | *(agregar captura)* |
| AWS Console — RDS Multi-AZ status: available | *(agregar captura)* |
| AWS Console — ElastiCache cluster primary + replica | *(agregar captura)* |
| AWS Console — S3 bucket con versioning ON + encryption | *(agregar captura)* |
| CloudWatch Dashboard — métricas en tiempo real | *(agregar captura)* |
| ALB health checks all healthy | *(agregar captura)* |
| Flyway — output de `flyway info` con V1–V9 SUCCESS | *(agregar captura)* |
| Rolling deploy completado sin downtime | *(agregar captura de logs)* |
| Prueba de restauración RDS — output del script | *(agregar output)* |

### Anexo B — URLs de recursos operativos

| Recurso | URL / Comando |
|---------|--------------|
| API Health | `https://api.logyx.pe/q/health` |
| API Swagger | `https://api.logyx.pe/q/swagger-ui` |
| CloudWatch Dashboard | `https://console.aws.amazon.com/cloudwatch/home?region=sa-east-1#dashboards:name=LOGYX-Operations` |
| Wazuh Dashboard | `https://10.0.30.10:443` (via Bastion) |
| Status Page | `https://status.logyx.pe` *(pendiente)* |

---

*LOGYX · S2 Entregable 3 · Implementación del Centro de Datos · Competencias C3.2–C3.3 · Agosto–Noviembre 2026*
