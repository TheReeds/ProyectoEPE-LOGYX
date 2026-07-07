# S2 · Entregable 1 — Implementación y Testing de Red
> Competencias C1.2 (Implementación) · C1.3 (Testing y control)  
> Proyecto: LOGYX — Sistema Operativo Logístico Colaborativo para PYMEs  
> Equipo: Jorge Gutiérrez Miranda · Fabrizio Sanchez Saravia · Alex Coila Jarita  
> Semestre 2 · Agosto–Noviembre 2026

---

## Resumen Ejecutivo

Este documento registra la implementación real de la infraestructura de red diseñada en S1-E1, ejecutada mediante **Terraform (Infrastructure as Code)** sobre AWS sa-east-1. Incluye las configuraciones de VPC, subnets, tablas de rutas, Security Groups, NAT Gateways, ALB y VPC Endpoints, junto con los resultados de las pruebas de conectividad, latencia y throughput.

---

## Sección 1 — Configuración de la Infraestructura de Red (Terraform)

### 1.1 Estructura del proyecto Terraform

```
logyx-infra/
├── main.tf            # Provider y backend (S3 remote state)
├── variables.tf       # Variables parametrizables
├── outputs.tf         # IDs de recursos exportados
├── network/
│   ├── vpc.tf         # VPC, subnets, IGW
│   ├── routing.tf     # Route tables, associations
│   ├── nat.tf         # NAT Gateways + EIPs
│   ├── endpoints.tf   # VPC Endpoints
│   └── security_groups.tf
├── compute/
│   ├── ec2.tf         # Auto Scaling Group + Launch Template
│   ├── alb.tf         # Application Load Balancer
│   └── ecs.tf         # ECS Cluster + Task Definitions
├── data/
│   ├── rds.tf         # RDS PostgreSQL Multi-AZ
│   └── elasticache.tf # Redis Cluster
└── security/
    ├── iam.tf         # Roles y políticas IAM
    ├── kms.tf         # KMS CMKs
    └── waf.tf         # WAF WebACL
```

### 1.2 VPC y subnets

```hcl
# network/vpc.tf

terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
  backend "s3" {
    bucket = "logyx-terraform-state"
    key    = "prod/terraform.tfstate"
    region = "sa-east-1"
    encrypt = true
  }
}

provider "aws" {
  region = "sa-east-1"
}

# ─── VPC ────────────────────────────────────────────────
resource "aws_vpc" "logyx" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "logyx-vpc-prod"
    Environment = "production"
    Project     = "LOGYX"
  }
}

# ─── Internet Gateway ───────────────────────────────────
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.logyx.id
  tags   = { Name = "logyx-igw" }
}

# ─── Subnets públicas ───────────────────────────────────
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.logyx.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "sa-east-1a"
  map_public_ip_on_launch = false
  tags = { Name = "logyx-public-a", Tier = "public" }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.logyx.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "sa-east-1b"
  map_public_ip_on_launch = false
  tags = { Name = "logyx-public-b", Tier = "public" }
}

# ─── Subnets privadas — aplicación ─────────────────────
resource "aws_subnet" "app_a" {
  vpc_id            = aws_vpc.logyx.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "sa-east-1a"
  tags = { Name = "logyx-app-a", Tier = "private-app" }
}

resource "aws_subnet" "app_b" {
  vpc_id            = aws_vpc.logyx.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "sa-east-1b"
  tags = { Name = "logyx-app-b", Tier = "private-app" }
}

# ─── Subnets privadas — datos ───────────────────────────
resource "aws_subnet" "data_a" {
  vpc_id            = aws_vpc.logyx.id
  cidr_block        = "10.0.20.0/24"
  availability_zone = "sa-east-1a"
  tags = { Name = "logyx-data-a", Tier = "private-data" }
}

resource "aws_subnet" "data_b" {
  vpc_id            = aws_vpc.logyx.id
  cidr_block        = "10.0.21.0/24"
  availability_zone = "sa-east-1b"
  tags = { Name = "logyx-data-b", Tier = "private-data" }
}

# ─── Subnet management ──────────────────────────────────
resource "aws_subnet" "mgmt_a" {
  vpc_id            = aws_vpc.logyx.id
  cidr_block        = "10.0.30.0/24"
  availability_zone = "sa-east-1a"
  tags = { Name = "logyx-mgmt-a", Tier = "private-mgmt" }
}

# ─── Subnet aislada security testing ───────────────────
resource "aws_subnet" "security_test" {
  vpc_id            = aws_vpc.logyx.id
  cidr_block        = "10.0.99.0/24"
  availability_zone = "sa-east-1a"
  tags = { Name = "logyx-security-test", Tier = "isolated" }
}
```

### 1.3 NAT Gateways y Tablas de Rutas

```hcl
# network/nat.tf

# Elastic IPs para NAT Gateways
resource "aws_eip" "nat_a" {
  domain = "vpc"
  tags   = { Name = "logyx-eip-nat-a" }
}

resource "aws_eip" "nat_b" {
  domain = "vpc"
  tags   = { Name = "logyx-eip-nat-b" }
}

# NAT Gateways (uno por AZ para redundancia)
resource "aws_nat_gateway" "nat_a" {
  allocation_id = aws_eip.nat_a.id
  subnet_id     = aws_subnet.public_a.id
  tags          = { Name = "logyx-nat-a" }
  depends_on    = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat_b" {
  allocation_id = aws_eip.nat_b.id
  subnet_id     = aws_subnet.public_b.id
  tags          = { Name = "logyx-nat-b" }
  depends_on    = [aws_internet_gateway.igw]
}

# ─── Tablas de rutas ────────────────────────────────────
# network/routing.tf

# Tabla pública → Internet Gateway
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.logyx.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "logyx-rt-public" }
}

# Tabla privada AZ-A → NAT-A
resource "aws_route_table" "private_a" {
  vpc_id = aws_vpc.logyx.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_a.id
  }
  tags = { Name = "logyx-rt-private-a" }
}

# Tabla privada AZ-B → NAT-B
resource "aws_route_table" "private_b" {
  vpc_id = aws_vpc.logyx.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_b.id
  }
  tags = { Name = "logyx-rt-private-b" }
}

# Tabla datos → solo local (sin salida a internet)
resource "aws_route_table" "data" {
  vpc_id = aws_vpc.logyx.id
  tags   = { Name = "logyx-rt-data" }
}

# Asociaciones
resource "aws_route_table_association" "public_a"  { subnet_id = aws_subnet.public_a.id; route_table_id = aws_route_table.public.id }
resource "aws_route_table_association" "public_b"  { subnet_id = aws_subnet.public_b.id; route_table_id = aws_route_table.public.id }
resource "aws_route_table_association" "app_a"     { subnet_id = aws_subnet.app_a.id;    route_table_id = aws_route_table.private_a.id }
resource "aws_route_table_association" "app_b"     { subnet_id = aws_subnet.app_b.id;    route_table_id = aws_route_table.private_b.id }
resource "aws_route_table_association" "data_a"    { subnet_id = aws_subnet.data_a.id;   route_table_id = aws_route_table.data.id }
resource "aws_route_table_association" "data_b"    { subnet_id = aws_subnet.data_b.id;   route_table_id = aws_route_table.data.id }
resource "aws_route_table_association" "mgmt_a"    { subnet_id = aws_subnet.mgmt_a.id;   route_table_id = aws_route_table.private_a.id }
```

### 1.4 Security Groups

```hcl
# network/security_groups.tf

# SG para ALB — solo HTTPS desde internet
resource "aws_security_group" "alb" {
  name   = "logyx-sg-alb"
  vpc_id = aws_vpc.logyx.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS desde internet"
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP → redirige a HTTPS"
  }
  egress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.backend.id]
    description     = "Hacia backend Quarkus"
  }
}

# SG para EC2 backend
resource "aws_security_group" "backend" {
  name   = "logyx-sg-backend"
  vpc_id = aws_vpc.logyx.id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
    description     = "Solo desde ALB"
  }
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
    description     = "SSH solo desde Bastion"
  }
  egress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.rds.id]
  }
  egress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.redis.id]
  }
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS saliente (ORS API, SUNAT, etc.)"
  }
}

# SG para RDS — solo desde backend
resource "aws_security_group" "rds" {
  name   = "logyx-sg-rds"
  vpc_id = aws_vpc.logyx.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.backend.id]
    description     = "PostgreSQL solo desde backend"
  }
}

# SG para Redis
resource "aws_security_group" "redis" {
  name   = "logyx-sg-redis"
  vpc_id = aws_vpc.logyx.id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.backend.id]
  }
}

# SG para Bastion Host
resource "aws_security_group" "bastion" {
  name   = "logyx-sg-bastion"
  vpc_id = aws_vpc.logyx.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.team_ip_cidr]  # IP fija del equipo
    description = "SSH solo desde IP del equipo"
  }
  egress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.backend.id]
  }
}
```

### 1.5 VPC Endpoints

```hcl
# network/endpoints.tf

# S3 Gateway Endpoint (sin costo adicional)
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.logyx.id
  service_name      = "com.amazonaws.sa-east-1.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [
    aws_route_table.private_a.id,
    aws_route_table.private_b.id
  ]
  tags = { Name = "logyx-ep-s3" }
}

# SSM Interface Endpoint (Session Manager sin SSH)
resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.logyx.id
  service_name        = "com.amazonaws.sa-east-1.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.mgmt_a.id]
  security_group_ids  = [aws_security_group.backend.id]
  private_dns_enabled = true
  tags = { Name = "logyx-ep-ssm" }
}

# Secrets Manager Interface Endpoint
resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id              = aws_vpc.logyx.id
  service_name        = "com.amazonaws.sa-east-1.secretsmanager"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.app_a.id, aws_subnet.app_b.id]
  security_group_ids  = [aws_security_group.backend.id]
  private_dns_enabled = true
  tags = { Name = "logyx-ep-secretsmanager" }
}
```

---

## Sección 2 — Implementación de Direccionamiento y Routing

### 2.1 Esquema IP definitivo (producción)

| Recurso | IP asignada | Subnet |
|---------|-------------|--------|
| ALB (nodo A) | IP dinámica en 10.0.1.x | logyx-public-a |
| ALB (nodo B) | IP dinámica en 10.0.2.x | logyx-public-b |
| NAT Gateway A | EIP: `<asignar al crear>` + 10.0.1.x | logyx-public-a |
| NAT Gateway B | EIP: `<asignar al crear>` + 10.0.2.x | logyx-public-b |
| EC2 Quarkus AZ-A | 10.0.10.10 (privada fija) | logyx-app-a |
| EC2 Quarkus AZ-B | 10.0.11.10 (privada fija) | logyx-app-b |
| RDS Primary | 10.0.20.5 (privada fija) | logyx-data-a |
| RDS Standby | 10.0.21.5 (privada fija) | logyx-data-b |
| ElastiCache Primary | 10.0.20.20 | logyx-data-a |
| ElastiCache Replica | 10.0.21.20 | logyx-data-b |
| Wazuh IDS | 10.0.30.10 | logyx-mgmt-a |
| Bastion Host | 10.0.30.50 + EIP pública | logyx-mgmt-a |

### 2.2 DNS interno (Route 53 Private Hosted Zone)

```
Zona privada: logyx.internal (solo resoluble dentro de la VPC)

rds.logyx.internal       → RDS endpoint (resuelve al primary activo)
redis.logyx.internal     → ElastiCache cluster endpoint
wazuh.logyx.internal     → 10.0.30.10
```

---

## Sección 3 — Controles de Acceso y Estándares

### 3.1 Network ACLs implementadas

```hcl
# NACL para subnets públicas
resource "aws_network_acl" "public" {
  vpc_id     = aws_vpc.logyx.id
  subnet_ids = [aws_subnet.public_a.id, aws_subnet.public_b.id]

  # Permitir HTTPS entrante
  ingress { rule_no = 100; protocol = "tcp"; from_port = 443; to_port = 443; cidr_block = "0.0.0.0/0"; action = "allow" }
  # Permitir HTTP (redirige a HTTPS en ALB)
  ingress { rule_no = 110; protocol = "tcp"; from_port = 80;  to_port = 80;  cidr_block = "0.0.0.0/0"; action = "allow" }
  # Permitir puertos efímeros (respuestas de internet)
  ingress { rule_no = 120; protocol = "tcp"; from_port = 1024; to_port = 65535; cidr_block = "0.0.0.0/0"; action = "allow" }
  # Denegar todo lo demás
  ingress { rule_no = 900; protocol = "-1"; from_port = 0; to_port = 0; cidr_block = "0.0.0.0/0"; action = "deny" }

  egress { rule_no = 100; protocol = "-1"; from_port = 0; to_port = 0; cidr_block = "0.0.0.0/0"; action = "allow" }
}

# NACL para subnets de datos (máxima restricción)
resource "aws_network_acl" "data" {
  vpc_id     = aws_vpc.logyx.id
  subnet_ids = [aws_subnet.data_a.id, aws_subnet.data_b.id]

  # Solo desde subnets de aplicación
  ingress { rule_no = 100; protocol = "tcp"; from_port = 5432; to_port = 5432; cidr_block = "10.0.10.0/24"; action = "allow" }
  ingress { rule_no = 110; protocol = "tcp"; from_port = 5432; to_port = 5432; cidr_block = "10.0.11.0/24"; action = "allow" }
  ingress { rule_no = 120; protocol = "tcp"; from_port = 6379; to_port = 6379; cidr_block = "10.0.10.0/24"; action = "allow" }
  ingress { rule_no = 130; protocol = "tcp"; from_port = 6379; to_port = 6379; cidr_block = "10.0.11.0/24"; action = "allow" }
  # Replicación interna entre AZs
  ingress { rule_no = 140; protocol = "tcp"; from_port = 5432; to_port = 5432; cidr_block = "10.0.20.0/24"; action = "allow" }
  ingress { rule_no = 150; protocol = "tcp"; from_port = 5432; to_port = 5432; cidr_block = "10.0.21.0/24"; action = "allow" }
  ingress { rule_no = 900; protocol = "-1"; from_port = 0; to_port = 0; cidr_block = "0.0.0.0/0"; action = "deny" }

  egress { rule_no = 100; protocol = "tcp"; from_port = 1024; to_port = 65535; cidr_block = "10.0.10.0/24"; action = "allow" }
  egress { rule_no = 110; protocol = "tcp"; from_port = 1024; to_port = 65535; cidr_block = "10.0.11.0/24"; action = "allow" }
  egress { rule_no = 900; protocol = "-1"; from_port = 0; to_port = 0; cidr_block = "0.0.0.0/0"; action = "deny" }
}
```

### 3.2 Cumplimiento de estándares de red

| Estándar | Control aplicado | Evidencia |
|---------|-----------------|-----------|
| TIA/EIA-568 (segmentación) | Subnets por capa funcional (public/app/data/mgmt) | `terraform plan` output |
| IEEE 802.1Q (VLAN equivalente) | Security Groups por función | AWS Console SG list |
| IEEE 802.3 (Ethernet) | AWS Enhanced Networking (SR-IOV) en t3.medium | `ethtool -i eth0` en EC2 |
| ISO/IEC 27001 (Control acceso) | NACL + SG + VPC Endpoint (sin salida pública de datos) | CloudTrail logs |

---

## Sección 4 — Pruebas de Conectividad y Rendimiento

### 4.1 Pruebas de conectividad (C1.3)

#### Test 1: Conectividad ALB → Backend

```bash
# Desde Bastion Host, verificar que backend responde
curl -v http://10.0.10.10:8080/q/health/live

# Resultado esperado:
# HTTP/1.1 200 OK
# {"status":"UP","checks":[{"name":"database","status":"UP"},{"name":"redis","status":"UP"}]}
```

#### Test 2: Backend → RDS PostgreSQL

```bash
# Desde EC2 backend (SSM Session Manager)
psql -h rds.logyx.internal -U logyx_app_user -d logyx_db -c "\conninfo"

# Resultado esperado:
# You are connected to database "logyx_db" as user "logyx_app_user" 
# on host "logyx-rds.xxxx.sa-east-1.rds.amazonaws.com" (SSL on)
```

#### Test 3: Aislamiento — desde subnet de datos, sin acceso a internet

```bash
# Desde instancia en subnet data (si se abre temporalmente para test)
curl --max-time 5 https://google.com

# Resultado esperado: connection timed out (no hay ruta a internet)
```

#### Test 4: VPC Endpoint S3 funciona sin pasar por NAT

```bash
# Desde EC2 backend
aws s3 ls s3://logyx-documents --region sa-east-1

# Verificar en CloudWatch que el tráfico pasó por VPC Endpoint (no por NAT)
aws cloudwatch get-metric-statistics \
  --namespace AWS/NATGateway \
  --metric-name BytesOutToDestination \
  --period 300 --statistics Sum
# → El contador de NAT NO debe incrementar durante operaciones S3
```

#### Test 5: Failover de AZ

```bash
# Paso 1: Verificar instancias activas
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names logyx-asg

# Paso 2: Terminar la instancia de AZ-A
aws ec2 terminate-instances --instance-ids <id-ec2-az-a>

# Paso 3: Verificar que el tráfico sigue respondiendo (< 30s)
while true; do
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" https://api.logyx.pe/q/health/live)
  echo "$(date): $STATUS"
  sleep 5
done

# Resultado esperado: 200 continuo, máximo 1-2 fallas de 5 segundos durante el failover
```

### 4.2 Pruebas de latencia (VPC Flow Logs + k6)

```javascript
// k6-latency-test.js
import http from 'k6/http';
import { check } from 'k6';

export const options = {
  vus: 10,
  duration: '60s',
  thresholds: {
    http_req_duration: [
      'p(50)<100',   // 50% de requests < 100ms
      'p(95)<500',   // 95% de requests < 500ms
      'p(99)<2000',  // 99% de requests < 2s
    ],
    http_req_failed: ['rate<0.01'],
  },
};

export default function () {
  const res = http.get('https://api.logyx.pe/q/health/live');
  check(res, { 'status 200': (r) => r.status === 200 });
}
```

**Resultados esperados:**

| Métrica | Objetivo | Valor obtenido |
|---------|---------|----------------|
| P50 latencia API (Lima → API) | < 150 ms | *(completar al ejecutar)* |
| P95 latencia API | < 500 ms | *(completar)* |
| P99 latencia API | < 2,000 ms | *(completar)* |
| Error rate | < 1% | *(completar)* |
| Throughput sostenido | > 100 req/s | *(completar)* |

### 4.3 Prueba de throughput de red

```bash
# iperf3 entre EC2-AZ-A y EC2-AZ-B (tráfico inter-AZ)
# En EC2-AZ-B (servidor):
iperf3 -s -p 5201

# En EC2-AZ-A (cliente):
iperf3 -c 10.0.11.10 -p 5201 -t 30 -P 4

# Resultado esperado: > 5 Gbps (red AWS entre instancias t3.medium)
```

### 4.4 Monitoreo de red — VPC Flow Logs

```bash
# Habilitar VPC Flow Logs hacia CloudWatch
aws ec2 create-flow-logs \
  --resource-ids vpc-xxxxxxxx \
  --resource-type VPC \
  --traffic-type ALL \
  --log-destination-type cloud-watch-logs \
  --log-group-name /logyx/vpc-flow-logs \
  --deliver-logs-permission-arn arn:aws:iam::ACCOUNT:role/logyx-flow-logs-role

# Query en CloudWatch Insights para detectar tráfico rechazado:
fields @timestamp, srcAddr, dstAddr, dstPort, action
| filter action = "REJECT"
| sort @timestamp desc
| limit 50
```

### 4.5 Dashboard de red en CloudWatch

| Métrica monitoreada | Alarma |
|--------------------|--------|
| ALB RequestCount | > 5,000 req/5min → alerta |
| ALB HTTPCode_ELB_5XX_Count | > 10 en 5 min → alerta crítica |
| ALB TargetResponseTime | P95 > 2s → alerta |
| NAT Gateway BytesOutToDestination | > 10 GB/día → revisar costos |
| EC2 NetworkIn + NetworkOut | Monitor de tráfico por instancia |

---

## Anexos

### Anexo A — Evidencias de ejecución

| Evidencia | Estado |
|-----------|--------|
| `terraform apply` output (sin errores) | *(agregar captura)* |
| AWS Console — VPC con 9 subnets | *(agregar captura)* |
| AWS Console — 6 Security Groups configurados | *(agregar captura)* |
| `curl` health check desde internet | *(agregar captura)* |
| k6 load test report | *(agregar captura)* |
| VPC Flow Logs en CloudWatch | *(agregar captura)* |
| Test failover AZ — log de respuestas continuas | *(agregar captura)* |

### Anexo B — Comandos de diagnóstico de red

```bash
# Verificar que RDS NO es accesible desde internet
nmap -p 5432 <RDS-endpoint-hostname>
# Esperado: filtered (no response)

# Verificar que EC2 backend NO tiene IP pública
aws ec2 describe-instances --filters "Name=tag:Name,Values=logyx-backend-*" \
  --query 'Reservations[].Instances[].PublicIpAddress'
# Esperado: [] (vacío)

# Verificar Security Group del RDS
aws ec2 describe-security-groups --group-ids sg-xxxxxxxxx \
  --query 'SecurityGroups[].IpPermissions'
# Esperado: solo 5432 desde sg-backend

# Listar VPC Endpoints activos
aws ec2 describe-vpc-endpoints --filters "Name=vpc-id,Values=vpc-xxxxxxxx"
```

---

*LOGYX · S2 Entregable 1 · Implementación de Red · Competencias C1.2–C1.3 · Agosto–Noviembre 2026*
