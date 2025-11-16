# AIOS Knowledge Base — Windows 11 Agentic Evolution

**Generated:** November 16, 2025  
**Purpose:** Context allocation for AIOS supercell deployment on pristine Windows 11  
**Scope:** Full-stack agentic infrastructure from bare OS to self-aware distributed system

---

## 🧠 Executive Summary

This knowledge base synthesizes the **complete AIOS architecture**, captured from the existing codebase at `c:\aios-supercell`. It serves as the **canonical reference** for evolving a clean Windows 11 installation into an agentic, self-aware infrastructure platform.

### Core Principles
1. **Supercell Architecture:** Windows 11 as a stem cell, capable of differentiating into any infrastructure role
2. **Layered Substrate:** Pure Windows → WSL2 Ubuntu → Docker → Observability/Ingress/Secrets
3. **Agentic Behavior:** Self-monitoring, policy-driven, autonomous adaptation
4. **GitOps Ready:** Declarative configs, version-controlled stacks, reproducible deployments
5. **Zero-Trust Security:** Vault-managed secrets, TLS everywhere, policy enforcement

---

## 📐 Architecture Layers

### Layer 0: Windows 11 Host (Pure Core)
**Location:** `scripts/01-core-os-hardening.ps1`

**Purpose:** Transform Windows 11 into an always-on, hardened substrate

**Capabilities:**
- Disables sleep/hibernation (`powercfg -h off`)
- Sets High Performance power plan
- Enables Remote Desktop with NLA (secure remote access)
- BitLocker prep (full-disk encryption when TPM available)
- Windows Defender exclusions for AIOS paths
- Performance-optimized visual settings

**Key Directories:**
```
C:\aios-supercell\
├── scripts\          # Automation scripts (PowerShell + Bash)
├── config\           # State tracking, Vault keys, bootstrap state
├── data\             # Persistent storage (WSL home, volumes, backups)
├── logs\             # Execution logs with timestamps
└── ops\              # GitOps artifacts (Terraform, Ansible, runbooks)

C:\Users\jesus\server\stacks\
├── ingress\          # Traefik + TLS certificates
├── observability\    # Prometheus, Grafana, Loki, exporters
├── secrets\          # Vault + init scripts
├── ai-services\      # Future: Whisper, TTS, vision models
└── data\             # Future: Databases (PostgreSQL, Redis, etc.)
```

---

### Layer 1: WSL2 Ubuntu (Linux Execution Layer)
**Location:** `scripts/03-install-wsl-ubuntu.ps1`, `scripts/ubuntu-bootstrap.sh`

**Purpose:** Linux userland inside Windows for Docker and container orchestration

**Resource Management:**
- **Memory:** 50% of system RAM (via `.wslconfig`)
- **CPU:** 50% of logical cores
- **Swap:** 8GB swap file at `C:\aios-supercell\data\wsl-swap.vhdx`
- **Networking:** `localhostForwarding=true`, `networkingMode=mirrored`
- **Systemd:** Enabled for Docker and service management

**Ubuntu Bootstrap:**
```bash
# Essential tools
apt: curl, wget, git, vim, htop, net-tools, build-essential

# Docker Engine (native WSL2 Docker, not just Desktop)
- Docker CE + CLI + containerd
- User added to docker group
- Ready for `docker compose` and `docker run`

# Symbolic links
~/aios-supercell → /mnt/c/aios-supercell
~/server → /mnt/c/Users/jesus/server
```

**State Files:**
- `.wslconfig` at `$env:USERPROFILE\.wslconfig`
- Bootstrap state at `C:\aios-supercell\config\bootstrap-state.json`

---

### Layer 2: Docker Desktop (Container Runtime)
**Location:** `scripts/04-install-docker-desktop.ps1`

**Purpose:** Container orchestration with WSL2 backend

**Configuration:**
```json
{
  "builder": {
    "gc": { "defaultKeepStorage": "20GB", "enabled": true }
  },
  "features": { "buildkit": true },
  "log-driver": "json-file",
  "log-opts": { "max-size": "10m", "max-file": "3" },
  "storage-driver": "overlay2"
}
```

**Integration:**
- WSL2 backend enabled
- Ubuntu distribution integrated
- BuildKit for efficient image builds
- Log rotation to prevent disk bloat

---

### Layer 3: Ingress & TLS (Traefik)
**Location:** `scripts/generate-tls-certs.ps1`, `stacks/ingress/`

**Purpose:** HTTPS termination, hostname routing, automatic service discovery

**TLS Certificates:**
- Self-signed wildcard for `*.lan` domains
- 4096-bit RSA, 10-year validity
- OpenSSL-based (fallback to PowerShell if unavailable)
- Trusted root import: `Import-Certificate -CertStoreLocation Cert:\LocalMachine\Root`

**Supported Domains:**
```
grafana.lan      → Grafana dashboard
prometheus.lan   → Prometheus metrics
vault.lan        → Vault UI
traefik.lan      → Traefik dashboard
loki.lan         → Loki logs
whoami.lan       → Test service
```

**Traefik Stack:**
- **Container:** `aios-traefik`
- **Ports:** `80:80`, `443:443`
- **Config:** `traefik.yml` (static), `dynamic/tls.yml` (dynamic)
- **Certificates:** `certs/lan.crt`, `certs/lan.key`
- **ACME:** `acme.json` with restricted permissions (600)
- **Dashboard:** Basic auth (default: `admin:changeme`)

---

### Layer 4: Observability (Prometheus, Grafana, Loki)
**Location:** `stacks/observability/`

**Purpose:** Metrics, dashboards, logs — the node "knows itself"

**Components:**

#### Prometheus
- **Container:** `aios-prometheus`
- **Port:** `9090`
- **Config:** `prometheus.yml` with scrape configs
- **Targets:**
  - Node Exporter (host metrics: CPU, RAM, disk, network)
  - cAdvisor (container metrics: Docker containers)
  - Traefik metrics endpoint
  - Vault health endpoint
- **Alerts:** `alerts/core-alerts.yml` (SLO-driven)

#### Grafana
- **Container:** `aios-grafana`
- **Port:** `3000`
- **Data Sources:**
  - Prometheus (metrics)
  - Loki (logs)
- **Dashboards:** Pre-provisioned via `provisioning/`
- **Default:** `admin:changeme` (MUST CHANGE)

#### Loki
- **Container:** `aios-loki`
- **Port:** `3100`
- **Config:** `loki-config.yml`
- **Purpose:** Centralized log aggregation (like Prometheus for logs)

#### Promtail
- **Container:** `aios-promtail`
- **Config:** `promtail-config.yml`
- **Purpose:** Ships Docker container logs to Loki

#### Exporters
- **Node Exporter:** Host-level metrics (CPU, RAM, disk, network)
- **cAdvisor:** Container-level metrics (Docker runtime stats)

**Outcome:** Full observability stack → the node monitors itself

---

### Layer 5: Secrets & Identity (Vault)
**Location:** `scripts/vault-manager.ps1`, `stacks/secrets/`

**Purpose:** Externalized secrets, policy-driven access, zero-trust

**Vault Container:**
- **Container:** `aios-vault`
- **Port:** `8200`
- **Storage:** File backend (`/vault/file`)
- **Init Script:** `vault-init.sh` (5-key Shamir unseal, threshold=3)

**Vault Manager Actions:**
```powershell
.\vault-manager.ps1 -Action init      # Initialize Vault (first time)
.\vault-manager.ps1 -Action unseal    # Unseal after restart
.\vault-manager.ps1 -Action seal      # Seal for maintenance
.\vault-manager.ps1 -Action status    # Check health
.\vault-manager.ps1 -Action backup    # Backup keys + data
```

**Vault Init Output:**
- **Unseal Keys:** `C:\aios-supercell\config\vault-unseal-keys.json` (5 keys, 3 required)
- **Root Token:** `C:\aios-supercell\config\vault-root-token.txt`
- **⚠️ CRITICAL:** Backup these files to encrypted USB/password manager immediately

**Vault Engines & Auth:**
- **KV v2:** Key-value secrets (enabled at `/secret`)
- **AppRole:** Service-to-service auth
- **JWT/OIDC:** Human auth (future: Keycloak integration)

**AIOS Policy:**
```hcl
# Future: AIOS services policy
path "secret/data/aios/*" {
  capabilities = ["read"]
}
```

---

## 🔄 Bootstrap Workflow

### Phase 1: Master Bootstrap
**Entry Point:** `scripts/00-master-bootstrap.ps1`

**Orchestration:**
1. Creates directory structure
2. Tracks progress in `config/bootstrap-state.json`
3. Executes scripts in sequence:
   - `01-core-os-hardening.ps1` (power, RDP, BitLocker prep)
   - `02-install-baseline-tools.ps1` (PowerShell 7, Terminal, Hyper-V, WSL2)
   - `03-install-wsl-ubuntu.ps1` (Ubuntu + `.wslconfig`)
   - `04-install-docker-desktop.ps1` (Docker + daemon.json)
4. Handles restarts with scheduled task (`AIOS-Bootstrap-Resume`)
5. Logs all actions to `logs/` with timestamps

**Expected Duration:** 30-60 minutes (including one restart)

**State Tracking:**
```json
{
  "stage": 0,
  "completed_scripts": [],
  "last_run": "2025-11-16 12:34:56"
}
```

---

### Phase 2: WSL2 Ubuntu Setup
**Entry Point:** `wsl -d Ubuntu bash /mnt/c/aios-supercell/scripts/ubuntu-bootstrap.sh`

**Actions:**
- Updates apt packages
- Installs essential tools
- Installs Docker Engine
- Adds user to docker group (requires logout/login)
- Creates symlinks to Windows directories

**Verification:**
```bash
docker run hello-world
docker ps
```

---

### Phase 3: TLS Certificate Generation
**Entry Point:** `scripts/generate-tls-certs.ps1`

**Outputs:**
- `stacks/ingress/certs/lan.crt` (certificate)
- `stacks/ingress/certs/lan.key` (private key)
- `stacks/ingress/acme.json` (Let's Encrypt state, empty initially)

**Trust Certificate (Optional):**
```powershell
Import-Certificate -FilePath "C:\Users\jesus\server\stacks\ingress\certs\lan.crt" `
    -CertStoreLocation Cert:\LocalMachine\Root
```

---

### Phase 4: Deploy Stacks
**Entry Point:** Each stack's `docker-compose.yml`

**Order:**
1. **Ingress** (Traefik) — Must be first for routing
2. **Observability** (Prometheus, Grafana, Loki) — Second for monitoring
3. **Secrets** (Vault) — Third for policy enforcement

**Deployment:**
```powershell
# 1. Traefik
cd C:\Users\jesus\server\stacks\ingress
docker compose up -d

# 2. Observability
cd C:\Users\jesus\server\stacks\observability
docker compose up -d

# 3. Vault
cd C:\Users\jesus\server\stacks\secrets
docker compose up -d
C:\aios-supercell\scripts\vault-manager.ps1 -Action init
```

**Verification:**
```powershell
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

---

## 🎛️ Operational Patterns

### Vault Lifecycle

**Initialize (First Time Only):**
```powershell
.\vault-manager.ps1 -Action init
# Output: vault-unseal-keys.json, vault-root-token.txt
```

**Unseal (After Every Restart):**
```powershell
.\vault-manager.ps1 -Action unseal
# Uses keys from vault-unseal-keys.json
# Requires 3 of 5 keys (Shamir threshold)
```

**Check Status:**
```powershell
.\vault-manager.ps1 -Action status
# Initialized: True
# Sealed: False
# Standby: False
```

**Backup:**
```powershell
.\vault-manager.ps1 -Action backup
# Creates timestamped backup in data/backup/vault-YYYYMMDD-HHMMSS/
```

---

### Container Management

**View All Containers:**
```powershell
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

**View Logs:**
```powershell
docker logs aios-traefik -f
docker logs aios-grafana -f
docker logs aios-vault -f
```

**Restart Stack:**
```powershell
cd C:\Users\jesus\server\stacks\ingress
docker compose restart
```

**Recreate Stack:**
```powershell
docker compose down
docker compose up -d
```

---

### Traefik Routing

**Add New Service:**
1. Add labels to `docker-compose.yml`:
   ```yaml
   labels:
     - "traefik.enable=true"
     - "traefik.http.routers.myservice.rule=Host(`myservice.lan`)"
     - "traefik.http.routers.myservice.entrypoints=websecure"
     - "traefik.http.routers.myservice.tls=true"
   ```
2. Add to hosts file (if not using DNS):
   ```powershell
   Add-Content C:\Windows\System32\drivers\etc\hosts "127.0.0.1 myservice.lan"
   ```
3. Restart stack:
   ```powershell
   docker compose up -d
   ```

---

### Grafana Dashboards

**Access:** https://grafana.lan (admin:changeme)

**Pre-configured Data Sources:**
- Prometheus → Metrics
- Loki → Logs

**Common Queries:**
```promql
# CPU usage
100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Memory usage
(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100

# Container CPU
rate(container_cpu_usage_seconds_total[5m])

# Container memory
container_memory_usage_bytes
```

---

## 🔐 Security Model

### Trust Boundaries

1. **Windows Host:** Trusted root (BitLocker encrypted)
2. **WSL2 Ubuntu:** Trusted execution layer (resource-limited)
3. **Docker Containers:** Isolated, policy-enforced
4. **Vault:** Secret store (Shamir-unsealed, AppRole auth)
5. **Traefik:** TLS termination (trusted certificates)

### Secrets Hierarchy

```
Vault (sealed at rest, unsealed with 3/5 keys)
  ├── /secret/aios/traefik/basicauth
  ├── /secret/aios/grafana/admin-password
  ├── /secret/aios/postgres/password
  └── /secret/aios/services/*
```

### Access Control

- **Traefik Dashboard:** Basic auth (`admin:changeme` → CHANGE)
- **Grafana:** Password auth (`admin:changeme` → CHANGE)
- **Vault:** Token-based (root token → AppRole/JWT)
- **Prometheus/Loki:** No auth (internal only, behind Traefik)

---

## 🧬 Agentic Evolution Roadmap

### Stage 1: Supercell Core (Current)
✅ Windows 11 hardened  
✅ WSL2 Ubuntu with Docker  
✅ Traefik ingress + TLS  
✅ Observability stack (Prometheus, Grafana, Loki)  
✅ Vault secrets management  

**Outcome:** Self-aware, monitorable, policy-driven node

---

### Stage 2: Overlay Mesh (Next)
🎯 **Goal:** Node gains network identity and routable presence

**Components:**
- **Tailscale or ZeroTier:** Overlay mesh VPN
- **Tags:** `role=core`, `role=ingress`, `role=observability`
- **ACLs:** Policy-driven connectivity between nodes

**Outcome:** Node is reachable from anywhere, securely

---

### Stage 3: GitOps Pipelines
🎯 **Goal:** Declarative infrastructure, version-controlled

**Components:**
- **Git Repository:** All compose files, configs, runbooks
- **Promotion Flow:** `lan → dev → staging → prod`
- **CI/CD:** GitHub Actions / Jenkins / Drone

**Outcome:** Infrastructure as code, reproducible deployments

---

### Stage 4: Backup & Restore
🎯 **Goal:** Resilience, disaster recovery

**Components:**
- **Restic:** Encrypted, deduplicated backups
- **Targets:** NAS, S3, external drive
- **Schedule:** Daily Vault backup, weekly full system

**Outcome:** Quarterly restore tests, zero data loss

---

### Stage 5: Multimodal AI Services
🎯 **Goal:** Node differentiates into AI roles

**Components:**
- **Audio:** Whisper (transcription), Coqui TTS (speech)
- **Vision:** Tesseract (OCR), ImageMagick (processing)
- **Text:** Model-serving endpoints (NATS, HTTP)

**Outcome:** Node serves multimodal AI requests

---

### Stage 6: Cloud Bridge
🎯 **Goal:** Hybrid deployments (local + cloud)

**Components:**
- **Terraform:** Declarative cloud infra (AWS, GCP, Azure)
- **Ansible:** Node convergence, configuration management
- **Multi-region:** Promote stacks from local → cloud

**Outcome:** Seamless local-to-cloud workflows

---

### Stage 7: Multi-Node Mesh
🎯 **Goal:** LAN mesh of specialized nodes

**Node Roles:**
- **Core Node:** Orchestration, Vault, Traefik
- **Compute Node:** GPU-accelerated AI workloads
- **Storage Node:** MinIO, NAS, backup target
- **Ingress Node:** Public-facing Traefik, DDoS protection
- **Observability Node:** Centralized Prometheus, Grafana

**Outcome:** Distributed, role-specialized infrastructure

---

## 📊 Metrics & SLOs

### Node-Level SLOs
- **Availability:** 99.5% uptime (43m downtime/month)
- **Response Time:** p95 < 500ms for all services
- **Error Rate:** < 0.1% failed requests
- **Resource Usage:** CPU < 80%, RAM < 85%, Disk < 90%

### Container-Level SLOs
- **Restart Frequency:** < 1 restart/day per container
- **Log Volume:** < 100MB/day per container
- **Build Time:** < 5 minutes for image builds

### Vault-Level SLOs
- **Unseal Time:** < 30 seconds after restart
- **Secret Retrieval:** p99 < 100ms
- **Backup Frequency:** Daily, with quarterly restore tests

---

## 🛠️ Troubleshooting Guide

### Issue: WSL2 Won't Start
```powershell
wsl --shutdown
wsl --status
wsl --list --verbose

# Check Hyper-V
Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All
```

### Issue: Docker Containers Failing
```powershell
docker ps -a
docker logs [container-name]
docker compose down
docker compose up -d
```

### Issue: Vault Sealed After Restart
```powershell
.\vault-manager.ps1 -Action status
.\vault-manager.ps1 -Action unseal
```

### Issue: Traefik Not Routing
```powershell
docker logs aios-traefik
# Check for certificate errors, label mismatches
```

### Issue: Can't Access *.lan Domains
```powershell
# Add to hosts file
Add-Content C:\Windows\System32\drivers\etc\hosts "127.0.0.1 grafana.lan prometheus.lan vault.lan"
ipconfig /flushdns
```

---

## 🔮 Future Enhancements

### Keycloak (Identity Provider)
- **Purpose:** Unified SSO for all AIOS services
- **Auth:** OIDC, SAML
- **Integration:** Vault JWT auth backend

### MinIO (Object Storage)
- **Purpose:** S3-compatible storage for backups, AI models
- **Integration:** Restic backend, Prometheus metrics

### PostgreSQL (Relational Database)
- **Purpose:** Persistent state for services
- **Integration:** Vault dynamic secrets

### Redis (Cache)
- **Purpose:** Session store, message queue
- **Integration:** Prometheus exporter

### NATS (Message Broker)
- **Purpose:** Inter-service communication for agents
- **Integration:** Distributed tracing (OpenTelemetry)

---

## 📚 Reference Commands

### PowerShell Essentials
```powershell
# Bootstrap
C:\aios-supercell\scripts\00-master-bootstrap.ps1

# Vault
.\scripts\vault-manager.ps1 -Action [init|unseal|seal|status|backup]

# Certificates
.\scripts\generate-tls-certs.ps1

# Docker
docker ps
docker logs [container] -f
docker compose up -d
docker compose down
docker system prune -a
```

### WSL Essentials
```powershell
wsl --status
wsl --list --verbose
wsl --shutdown
wsl -d Ubuntu
```

### Verification
```powershell
# Test services
curl https://traefik.lan -k
curl http://localhost:9090/api/v1/targets
curl http://localhost:3000/api/health
curl http://localhost:8200/v1/sys/health

# View all containers
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

---

## 🎯 Success Criteria

Your AIOS supercell is operational when:

✅ Windows 11 hardened (sleep disabled, RDP enabled, BitLocker ready)  
✅ WSL2 Ubuntu running with Docker integration  
✅ Docker Desktop active with WSL2 backend  
✅ Traefik routing HTTPS to all services (*.lan domains)  
✅ Grafana dashboards showing metrics from all nodes  
✅ Loki aggregating logs from all containers  
✅ Vault initialized, unsealed, storing secrets  
✅ All containers healthy (`docker ps` shows all running)  
✅ TLS certificates trusted (no browser warnings)  

---

## 🌟 Philosophy

This is not infrastructure—it's a **living computational organism**.

- **Supercell:** Undifferentiated potential, can become any role
- **Agentic:** Monitors itself, enforces invariants, adapts autonomously
- **Recursive:** Each component observes itself and others
- **Composable:** Services stack like Lego blocks

**The machine itself is an agent**, not just a host.

---

## 📖 Document Metadata

- **Version:** 1.0.0
- **Last Updated:** November 16, 2025
- **Author:** AIOS Supercell Project
- **Codebase:** `c:\aios-supercell`
- **Status:** ✅ Complete (Stage 1: Supercell Core)

---

**END OF KNOWLEDGE BASE**

*This document is the canonical reference for AIOS supercell architecture. All scripts, configs, and workflows are synthesized here for human and AI understanding.*
