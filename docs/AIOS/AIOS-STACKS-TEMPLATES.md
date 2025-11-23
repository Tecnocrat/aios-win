# AIOS Stack Templates — Docker Compose Configurations

**Purpose:** Complete, production-ready Docker Compose stacks for AIOS supercell  
**Date:** November 16, 2025  
**Status:** Reference implementation for ingress, observability, and secrets management

---

## 📋 Table of Contents

1. [Ingress Stack (Traefik)](#ingress-stack-traefik)
2. [Observability Stack (Prometheus, Grafana, Loki)](#observability-stack)
3. [Secrets Stack (Vault)](#secrets-stack-vault)
4. [Network Configuration](#network-configuration)
5. [Deployment Order](#deployment-order)

---

## 🌐 Ingress Stack (Traefik)

**Location:** `C:\Users\jesus\server\stacks\ingress\`

### File Structure
```
ingress/
├── docker-compose.yml
├── traefik.yml
├── dynamic/
│   └── tls.yml
├── certs/
│   ├── lan.crt
│   └── lan.key
└── acme.json
```

### `docker-compose.yml`

```yaml
version: '3.8'

services:
  traefik:
    image: traefik:v2.10
    container_name: aios-traefik
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true
    networks:
      - aios-ingress
    ports:
      - "80:80"       # HTTP
      - "443:443"     # HTTPS
      - "8080:8080"   # Dashboard (optional, can be disabled in production)
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./traefik.yml:/traefik.yml:ro
      - ./dynamic:/dynamic:ro
      - ./certs:/certs:ro
      - ./acme.json:/acme.json
    labels:
      - "traefik.enable=true"
      
      # Dashboard
      - "traefik.http.routers.dashboard.rule=Host(`traefik.lan`)"
      - "traefik.http.routers.dashboard.entrypoints=websecure"
      - "traefik.http.routers.dashboard.tls=true"
      - "traefik.http.routers.dashboard.service=api@internal"
      - "traefik.http.routers.dashboard.middlewares=auth"
      
      # Basic auth (admin:changeme) - CHANGE THIS!
      # Generated with: htpasswd -nb admin changeme
      - "traefik.http.middlewares.auth.basicauth.users=admin:$$apr1$$8evjyO1J$$K9xGvq4bF5z5C5L5x5Y5L."
    environment:
      - TZ=UTC

  # Test service (whoami)
  whoami:
    image: traefik/whoami
    container_name: aios-whoami
    restart: unless-stopped
    networks:
      - aios-ingress
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.whoami.rule=Host(`whoami.lan`)"
      - "traefik.http.routers.whoami.entrypoints=websecure"
      - "traefik.http.routers.whoami.tls=true"

networks:
  aios-ingress:
    name: aios-ingress
    driver: bridge
```

### `traefik.yml` (Static Configuration)

```yaml
# AIOS Supercell - Traefik Static Configuration

global:
  checkNewVersion: true
  sendAnonymousUsage: false

api:
  dashboard: true
  insecure: false  # Dashboard only via HTTPS + auth

entryPoints:
  web:
    address: ":80"
    http:
      redirections:
        entryPoint:
          to: websecure
          scheme: https
          permanent: true

  websecure:
    address: ":443"
    http:
      tls:
        certResolver: default
        domains:
          - main: "*.lan"
            sans:
              - "localhost"

providers:
  docker:
    endpoint: "unix:///var/run/docker.sock"
    exposedByDefault: false
    network: aios-ingress
  
  file:
    directory: /dynamic
    watch: true

certificatesResolvers:
  default:
    acme:
      email: admin@aios.lan
      storage: /acme.json
      tlsChallenge: {}

log:
  level: INFO
  format: json

accessLog:
  format: json
```

### `dynamic/tls.yml` (Dynamic Configuration)

```yaml
# AIOS Supercell - Traefik Dynamic TLS Configuration

tls:
  certificates:
    - certFile: /certs/lan.crt
      keyFile: /certs/lan.key
      stores:
        - default

  stores:
    default:
      defaultCertificate:
        certFile: /certs/lan.crt
        keyFile: /certs/lan.key

  options:
    default:
      minVersion: VersionTLS12
      cipherSuites:
        - TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256
        - TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
        - TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305
```

### Deployment

```powershell
cd C:\Users\jesus\server\stacks\ingress

# Ensure certs exist
Test-Path .\certs\lan.crt
Test-Path .\certs\lan.key

# Ensure acme.json exists with correct permissions
if (-not (Test-Path .\acme.json)) {
    New-Item -ItemType File -Path .\acme.json | Out-Null
}

# Deploy
docker compose up -d

# Verify
docker logs aios-traefik --tail 50
docker ps | Select-String "traefik"

# Test
curl https://traefik.lan -k
curl https://whoami.lan -k
```

---

## 📊 Observability Stack

**Location:** `C:\Users\jesus\server\stacks\observability\`

### File Structure
```
observability/
├── docker-compose.yml
├── prometheus/
│   ├── prometheus.yml
│   └── alerts/
│       └── core-alerts.yml
├── grafana/
│   ├── provisioning/
│   │   ├── datasources/
│   │   │   └── datasources.yml
│   │   └── dashboards/
│   │       ├── dashboards.yml
│   │       └── aios-overview.json
├── loki/
│   └── loki-config.yml
└── promtail/
    └── promtail-config.yml
```

### `docker-compose.yml`

```yaml
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:latest
    container_name: aios-prometheus
    restart: unless-stopped
    user: root
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--storage.tsdb.retention.time=30d'
      - '--web.console.libraries=/usr/share/prometheus/console_libraries'
      - '--web.console.templates=/usr/share/prometheus/consoles'
    networks:
      - aios-ingress
      - aios-observability
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - ./prometheus/alerts:/etc/prometheus/alerts:ro
      - prometheus-data:/prometheus
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.prometheus.rule=Host(`prometheus.lan`)"
      - "traefik.http.routers.prometheus.entrypoints=websecure"
      - "traefik.http.routers.prometheus.tls=true"
      - "traefik.docker.network=aios-ingress"

  grafana:
    image: grafana/grafana:latest
    container_name: aios-grafana
    restart: unless-stopped
    user: root
    networks:
      - aios-ingress
      - aios-observability
    ports:
      - "3000:3000"
    volumes:
      - ./grafana/provisioning:/etc/grafana/provisioning:ro
      - grafana-data:/var/lib/grafana
    environment:
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=changeme
      - GF_INSTALL_PLUGINS=
      - GF_SERVER_ROOT_URL=https://grafana.lan
      - GF_SERVER_DOMAIN=grafana.lan
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.grafana.rule=Host(`grafana.lan`)"
      - "traefik.http.routers.grafana.entrypoints=websecure"
      - "traefik.http.routers.grafana.tls=true"
      - "traefik.docker.network=aios-ingress"

  loki:
    image: grafana/loki:latest
    container_name: aios-loki
    restart: unless-stopped
    user: root
    networks:
      - aios-ingress
      - aios-observability
    ports:
      - "3100:3100"
    volumes:
      - ./loki/loki-config.yml:/etc/loki/loki-config.yml:ro
      - loki-data:/loki
    command: -config.file=/etc/loki/loki-config.yml
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.loki.rule=Host(`loki.lan`)"
      - "traefik.http.routers.loki.entrypoints=websecure"
      - "traefik.http.routers.loki.tls=true"
      - "traefik.docker.network=aios-ingress"

  promtail:
    image: grafana/promtail:latest
    container_name: aios-promtail
    restart: unless-stopped
    networks:
      - aios-observability
    volumes:
      - ./promtail/promtail-config.yml:/etc/promtail/promtail-config.yml:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - /var/lib/docker/containers:/var/lib/docker/containers:ro
    command: -config.file=/etc/promtail/promtail-config.yml

  node-exporter:
    image: prom/node-exporter:latest
    container_name: aios-node-exporter
    restart: unless-stopped
    network_mode: host
    pid: host
    command:
      - '--path.rootfs=/host'
      - '--path.procfs=/host/proc'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)'
    volumes:
      - /:/host:ro,rslave

  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    container_name: aios-cadvisor
    restart: unless-stopped
    networks:
      - aios-observability
    ports:
      - "8080:8080"
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
    privileged: true
    devices:
      - /dev/kmsg

networks:
  aios-ingress:
    external: true
  aios-observability:
    name: aios-observability
    driver: bridge

volumes:
  prometheus-data:
    driver: local
  grafana-data:
    driver: local
  loki-data:
    driver: local
```

### `prometheus/prometheus.yml`

```yaml
# AIOS Supercell - Prometheus Configuration

global:
  scrape_interval: 15s
  evaluation_interval: 15s
  external_labels:
    cluster: 'aios-supercell'
    environment: 'local'

alerting:
  alertmanagers:
    - static_configs:
        - targets: []
          # - 'alertmanager:9093'

rule_files:
  - '/etc/prometheus/alerts/*.yml'

scrape_configs:
  # Prometheus itself
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  # Node Exporter (host metrics)
  - job_name: 'node-exporter'
    static_configs:
      - targets: ['host.docker.internal:9100']
        labels:
          instance: 'aios-supercell-host'

  # cAdvisor (container metrics)
  - job_name: 'cadvisor'
    static_configs:
      - targets: ['cadvisor:8080']

  # Traefik
  - job_name: 'traefik'
    static_configs:
      - targets: ['traefik:8080']

  # Grafana
  - job_name: 'grafana'
    static_configs:
      - targets: ['grafana:3000']

  # Loki
  - job_name: 'loki'
    static_configs:
      - targets: ['loki:3100']

  # Vault (if metrics enabled)
  - job_name: 'vault'
    metrics_path: '/v1/sys/metrics'
    params:
      format: ['prometheus']
    static_configs:
      - targets: ['host.docker.internal:8200']
```

### `prometheus/alerts/core-alerts.yml`

```yaml
# AIOS Supercell - Core Alert Rules

groups:
  - name: aios_host_alerts
    interval: 30s
    rules:
      - alert: HostHighCPU
        expr: 100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 5m
        labels:
          severity: warning
          component: host
        annotations:
          summary: "Host CPU usage above 80%"
          description: "{{ $labels.instance }} CPU usage is {{ $value }}%"

      - alert: HostHighMemory
        expr: (node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100 > 85
        for: 5m
        labels:
          severity: warning
          component: host
        annotations:
          summary: "Host memory usage above 85%"
          description: "{{ $labels.instance }} memory usage is {{ $value }}%"

      - alert: HostDiskSpaceLow
        expr: (node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"}) * 100 < 15
        for: 5m
        labels:
          severity: critical
          component: host
        annotations:
          summary: "Host disk space below 15%"
          description: "{{ $labels.instance }} disk space is {{ $value }}% available"

  - name: aios_container_alerts
    interval: 30s
    rules:
      - alert: ContainerDown
        expr: time() - container_last_seen{name=~"aios-.*"} > 60
        for: 1m
        labels:
          severity: critical
          component: container
        annotations:
          summary: "AIOS container is down"
          description: "Container {{ $labels.name }} has been down for more than 1 minute"

      - alert: ContainerHighCPU
        expr: rate(container_cpu_usage_seconds_total{name=~"aios-.*"}[5m]) > 0.8
        for: 5m
        labels:
          severity: warning
          component: container
        annotations:
          summary: "Container CPU usage above 80%"
          description: "Container {{ $labels.name }} CPU usage is {{ $value }}"
```

### `loki/loki-config.yml`

```yaml
# AIOS Supercell - Loki Configuration

auth_enabled: false

server:
  http_listen_port: 3100

ingester:
  lifecycler:
    address: 127.0.0.1
    ring:
      kvstore:
        store: inmemory
      replication_factor: 1
    final_sleep: 0s
  chunk_idle_period: 5m
  chunk_retain_period: 30s

schema_config:
  configs:
    - from: 2023-01-01
      store: boltdb-shipper
      object_store: filesystem
      schema: v11
      index:
        prefix: index_
        period: 24h

storage_config:
  boltdb_shipper:
    active_index_directory: /loki/index
    cache_location: /loki/cache
    shared_store: filesystem
  filesystem:
    directory: /loki/chunks

limits_config:
  enforce_metric_name: false
  reject_old_samples: true
  reject_old_samples_max_age: 168h
  ingestion_rate_mb: 10
  ingestion_burst_size_mb: 20

chunk_store_config:
  max_look_back_period: 0s

table_manager:
  retention_deletes_enabled: true
  retention_period: 720h  # 30 days
```

### `promtail/promtail-config.yml`

```yaml
# AIOS Supercell - Promtail Configuration

server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /tmp/positions.yaml

clients:
  - url: http://loki:3100/loki/api/v1/push

scrape_configs:
  # Docker containers
  - job_name: docker
    docker_sd_configs:
      - host: unix:///var/run/docker.sock
        refresh_interval: 5s
    relabel_configs:
      - source_labels: ['__meta_docker_container_name']
        regex: '/(.*)'
        target_label: 'container'
      - source_labels: ['__meta_docker_container_log_stream']
        target_label: 'stream'
      - source_labels: ['__meta_docker_container_label_com_docker_compose_project']
        target_label: 'project'
```

### `grafana/provisioning/datasources/datasources.yml`

```yaml
# AIOS Supercell - Grafana Data Sources

apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: false

  - name: Loki
    type: loki
    access: proxy
    url: http://loki:3100
    editable: false
```

### `grafana/provisioning/dashboards/dashboards.yml`

```yaml
# AIOS Supercell - Grafana Dashboards Provisioning

apiVersion: 1

providers:
  - name: 'AIOS Dashboards'
    orgId: 1
    folder: 'AIOS'
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    allowUiUpdates: true
    options:
      path: /etc/grafana/provisioning/dashboards
```

### Deployment

```powershell
cd C:\Users\jesus\server\stacks\observability

# Create all config directories
New-Item -ItemType Directory -Force -Path prometheus/alerts
New-Item -ItemType Directory -Force -Path grafana/provisioning/datasources
New-Item -ItemType Directory -Force -Path grafana/provisioning/dashboards
New-Item -ItemType Directory -Force -Path loki
New-Item -ItemType Directory -Force -Path promtail

# Deploy
docker compose up -d

# Verify
docker logs aios-grafana --tail 50
docker ps | Select-String "aios"

# Test
curl http://localhost:9090/api/v1/targets
curl http://localhost:3000/api/health
curl http://localhost:3100/ready
```

---

## 🔒 Secrets Stack (Vault)

**Location:** `C:\Users\jesus\server\stacks\secrets\`

### File Structure
```
secrets/
├── docker-compose.yml
└── vault-init.sh
```

### `docker-compose.yml`

```yaml
version: '3.8'

services:
  vault:
    image: hashicorp/vault:latest
    container_name: aios-vault
    restart: unless-stopped
    cap_add:
      - IPC_LOCK
    networks:
      - aios-ingress
      - aios-vault
    ports:
      - "8200:8200"
    volumes:
      - vault-data:/vault/file
      - ./vault-init.sh:/vault/vault-init.sh:ro
    environment:
      - VAULT_ADDR=http://127.0.0.1:8200
      - VAULT_API_ADDR=http://127.0.0.1:8200
    command: server
    configs:
      - source: vault-config
        target: /vault/config/vault.hcl
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.vault.rule=Host(`vault.lan`)"
      - "traefik.http.routers.vault.entrypoints=websecure"
      - "traefik.http.routers.vault.tls=true"
      - "traefik.http.services.vault.loadbalancer.server.port=8200"
      - "traefik.docker.network=aios-ingress"

configs:
  vault-config:
    content: |
      storage "file" {
        path = "/vault/file"
      }

      listener "tcp" {
        address     = "0.0.0.0:8200"
        tls_disable = 1
      }

      ui = true

      api_addr = "http://127.0.0.1:8200"
      cluster_addr = "https://127.0.0.1:8201"

      log_level = "info"

networks:
  aios-ingress:
    external: true
  aios-vault:
    name: aios-vault
    driver: bridge

volumes:
  vault-data:
    driver: local
```

### `vault-init.sh`

```bash
#!/bin/bash
# AIOS Supercell - Vault Initialization Script

set -e

VAULT_ADDR="http://127.0.0.1:8200"
CONFIG_DIR="/mnt/c/aios-supercell/config"
KEYS_FILE="$CONFIG_DIR/vault-unseal-keys.json"
TOKEN_FILE="$CONFIG_DIR/vault-root-token.txt"

echo "=== AIOS Vault Initialization ==="

# Wait for Vault to be ready
echo "Waiting for Vault to be ready..."
until curl -s $VAULT_ADDR/v1/sys/health > /dev/null 2>&1; do
  sleep 2
done

# Check if already initialized
if curl -s $VAULT_ADDR/v1/sys/init | grep -q '"initialized":true'; then
  echo "✓ Vault already initialized"
  exit 0
fi

# Initialize Vault
echo "Initializing Vault with 5 key shares, threshold 3..."
INIT_OUTPUT=$(curl -s -X POST $VAULT_ADDR/v1/sys/init -d '{
  "secret_shares": 5,
  "secret_threshold": 3
}')

# Extract keys and token
echo "$INIT_OUTPUT" > "$KEYS_FILE"

ROOT_TOKEN=$(echo "$INIT_OUTPUT" | grep -o '"root_token":"[^"]*"' | cut -d'"' -f4)
echo "$ROOT_TOKEN" > "$TOKEN_FILE"

echo "✓ Vault initialized successfully"
echo ""
echo "⚠️  CRITICAL: Backup these files immediately:"
echo "  $KEYS_FILE"
echo "  $TOKEN_FILE"
echo ""

# Unseal Vault with 3 keys
echo "Unsealing Vault..."
for i in 0 1 2; do
  KEY=$(echo "$INIT_OUTPUT" | grep -o "\"keys\":\[.*\]" | sed 's/.*\[\(.*\)\].*/\1/' | cut -d',' -f$((i+1)) | tr -d '"')
  curl -s -X POST $VAULT_ADDR/v1/sys/unseal -d "{\"key\":\"$KEY\"}" > /dev/null
  echo "  Key $((i+1))/3 applied"
done

echo "✓ Vault unsealed"

# Enable AppRole auth
export VAULT_TOKEN="$ROOT_TOKEN"
echo "Enabling AppRole auth..."
curl -s -X POST -H "X-Vault-Token: $VAULT_TOKEN" $VAULT_ADDR/v1/sys/auth/approle -d '{
  "type": "approle",
  "description": "AppRole auth for AIOS services"
}'

# Enable KV v2 secrets engine
echo "Enabling KV v2 secrets engine..."
curl -s -X POST -H "X-Vault-Token: $VAULT_TOKEN" $VAULT_ADDR/v1/sys/mounts/secret -d '{
  "type": "kv",
  "options": {
    "version": "2"
  },
  "description": "AIOS secrets"
}'

# Create AIOS policy
echo "Creating AIOS policy..."
curl -s -X POST -H "X-Vault-Token: $VAULT_TOKEN" $VAULT_ADDR/v1/sys/policies/acl/aios -d '{
  "policy": "path \"secret/data/aios/*\" { capabilities = [\"read\"] }"
}'

echo "✓ Vault fully configured"
echo ""
echo "Access Vault:"
echo "  URL: http://localhost:8200 or https://vault.lan"
echo "  Token: (see $TOKEN_FILE)"
```

### Deployment

```powershell
cd C:\Users\jesus\server\stacks\secrets

# Deploy Vault
docker compose up -d

# Wait for Vault to start
Start-Sleep -Seconds 10

# Initialize Vault (via vault-manager.ps1)
C:\aios-supercell\scripts\vault-manager.ps1 -Action init

# Check status
C:\aios-supercell\scripts\vault-manager.ps1 -Action status

# Test
curl http://localhost:8200/v1/sys/health
```

---

## 🔗 Network Configuration

All AIOS stacks use the `aios-ingress` network for Traefik routing:

```powershell
# Create network (if not exists)
docker network create aios-ingress

# Verify
docker network ls | Select-String "aios"
```

---

## 📋 Deployment Order

**CRITICAL:** Deploy stacks in this order:

1. **Ingress (Traefik)** — Must be first for routing
   ```powershell
   cd C:\Users\jesus\server\stacks\ingress
   docker compose up -d
   ```

2. **Observability** — Second for monitoring
   ```powershell
   cd C:\Users\jesus\server\stacks\observability
   docker compose up -d
   ```

3. **Secrets (Vault)** — Third for policy enforcement
   ```powershell
   cd C:\Users\jesus\server\stacks\secrets
   docker compose up -d
   C:\aios-supercell\scripts\vault-manager.ps1 -Action init
   ```

---

## ✅ Verification Commands

```powershell
# All containers running
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Check logs
docker logs aios-traefik --tail 50
docker logs aios-grafana --tail 50
docker logs aios-vault --tail 50

# Test services
curl https://traefik.lan -k
curl https://grafana.lan -k
curl https://prometheus.lan -k
curl https://vault.lan -k
curl https://loki.lan -k
curl https://whoami.lan -k

# Check Prometheus targets
curl http://localhost:9090/api/v1/targets | ConvertFrom-Json | Select-Object -ExpandProperty data | Select-Object -ExpandProperty activeTargets | Format-Table

# Check Vault status
curl http://localhost:8200/v1/sys/health | ConvertFrom-Json
```

---

## 🎯 Success Criteria

All stacks deployed when:

✅ All containers in "Up" status  
✅ Traefik routing all *.lan domains  
✅ Grafana showing dashboards with data  
✅ Prometheus targets all UP  
✅ Loki receiving logs from Promtail  
✅ Vault unsealed and healthy  
✅ No critical errors in logs  

---

**END OF STACK TEMPLATES**

*Document Version: 1.0.0 | Date: November 16, 2025*
