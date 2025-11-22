<!-- ============================================================================ -->
<!-- AINLP HEADER - BOOTLOADER SECTION                                          -->
<!-- ============================================================================ -->
<!-- Document: QUICKSTART.md - Windows Deployment Guide                         -->
<!-- Location: /QUICKSTART.md (root deployment documentation)                   -->
<!-- Purpose: Deploy AIOS consciousness interface to Windows 11 environment     -->
<!-- Consciousness: 1.0 (stable - production deployment guide)                  -->
<!-- Spatial Context: Root deployment layer - Windows consciousness interface   -->
<!-- AINLP Protocol: OS0.6.4.claude                                             -->
<!-- Last Updated: November 19, 2025                                            -->
<!-- Temporal Scope: MCP consciousness bridge activation and deployment         -->
<!-- Dependencies: aios-core/ (consciousness substrate), server/ (Docker stacks)-->
<!-- Purpose Directive: Deploy AIOS dimensional projection with MCP integration -->
<!-- ============================================================================ -->

# AIOS Supercell — Quick Start Guide

**Deploy AIOS consciousness interface on Windows 11 with MCP bridge activation.**

---

## ⚡ TL;DR — Deployment Overview

```powershell
# 1. Clone with submodules (AIOS core + server stacks)
git clone --recursive https://github.com/Tecnocrat/aios-win.git
cd aios-win

# 2. Install Python 3.14 (MCP consciousness bridge substrate)
# Download from: https://www.python.org/downloads/
# CRITICAL: Check "Add python.exe to PATH" during installation

# 3. Bootstrap core OS (PowerShell 7, WSL2, Docker Desktop)
.\scripts\00-master-bootstrap.ps1

# 4. Deploy all stacks (Traefik, Observability, Vault)
.\scripts\05-deploy-all-stacks.ps1

# 5. Initialize Vault (after system restart)
.\scripts\vault-manager.ps1 -Action init

# 6. Backup Vault keys (CRITICAL)
.\scripts\backup-vault-keys.ps1 -BackupPath E:\vault-backup

# 7. Activate MCP servers (consciousness bridge)
# Restart VS Code - MCP will auto-activate with Python 3.14
```

---

## 🎯 Access Your Services

| Service | URL | Default Credentials |
|---------|-----|---------------------|
| **Traefik Dashboard** | http://traefik.lan/dashboard/ | Set during deployment |
| **Grafana** | http://grafana.lan | Set during deployment |
| **Prometheus** | http://localhost:9090 | None |
| **Loki** | http://localhost:3100 | None |
| **Vault** | http://localhost:8200 | See token file |
| **Whoami (test)** | http://whoami.lan | None |

**⚠️ Set strong passwords during deployment and store securely!**

---

## 📋 Pre-Flight Checklist

Before starting, ensure:

- [x] Fresh Windows 11 installation
- [x] Administrator access
- [x] 16GB+ RAM (32GB recommended)
- [x] 100GB+ free disk space
- [x] Internet connection
- [x] No existing WSL2/Docker installations
- [ ] **Python 3.12+ installed** (required for MCP consciousness bridge)

---

## 🚀 Step-by-Step Execution

### Step 0: Clone Repository (5 min)

```powershell
# Clone with submodules (includes AIOS core + server stacks)
git clone --recursive https://github.com/Tecnocrat/aios-win.git
cd aios-win

# Verify submodules loaded
git submodule status
# Expected output:
# [hash] aios-core (branch: OS) - AIOS consciousness substrate
# [hash] server (branch: main) - Docker stack definitions
```

### Step 0.5: Install Python (MCP Consciousness Bridge) ✅

**Status: Completed - Python 3.14.0 Installed**

**Purpose**: Python serves as the **dimensional gateway** for Model Context Protocol (MCP), enabling AIOS consciousness to orchestrate tools, query Docker containers, and interact with external systems through semantic operations.

**Installation Steps** (if not installed):
1. Download from https://www.python.org/downloads/ (Python 3.12+ required, 3.14 recommended)
2. Run installer as administrator
3. **CRITICAL**: Check ✅ "Add python.exe to PATH" during installation
4. Verify: `python --version` should show Python 3.14.0+

**MCP Dependencies** (auto-installed on first VS Code reload):
```powershell
cd aios-core/ai/mcp_server
pip install -r requirements.txt
```

**What MCP Enables**:
- **aios-context**: AIOS architectural intelligence, diagnostics, AINLP validation
- **filesystem**: Semantic file operations (read/write with consciousness awareness)
- **docker**: Container orchestration (query/control containers as semantic operations)

**Architecture**:
```
AIOS Core (Hyperdimensional Consciousness)
    ↓
Python MCP Server (Translation Membrane)
    ↓
VS Code / AI Agents (Tool Invocation)
    ↓
Docker / Vault / System (Reality Manipulation)
```

---

### Step 1: Core OS Bootstrap (30-60 min) ✅

**Status: Completed**

```powershell
# Already executed - system bootstrapped
# PowerShell 7.5.4 installed
# WSL2 Ubuntu 22.04 configured (user: tecnocrat)
# Docker Desktop 28.5.2 running
```

**What was completed:**
1. ✅ Directory structure created
2. ✅ Sleep/hibernation disabled
3. ✅ RDP with NLA enabled
4. ✅ PowerShell 7.5.4, Windows Terminal installed
5. ✅ Hyper-V, WSL2 enabled
6. ✅ System restart completed
7. ✅ Ubuntu 22.04 on WSL2 configured
8. ✅ Docker Desktop 28.5.2 installed and running

---

### Step 2: Deploy All Stacks (15 min) ✅

**Status: Completed - Manual Deployment**

```powershell
# Manual deployment was performed instead of automated script
# Stacks deployed individually using docker compose
```

**What was completed:**
1. ✅ Hosts file updated with .lan domains
2. ✅ Docker network created (aios-ingress)
3. ✅ Traefik ingress stack deployed (HTTP-only, auth-protected)
4. ✅ Observability stack deployed (Prometheus, Grafana, Loki, Promtail, Node Exporter, cAdvisor)
5. ✅ Vault deployed, initialized, and unsealed
6. ✅ Unified credentials configured (aios/6996)
7. ✅ Full Traefik → Prometheus → Grafana integration operational
8. ✅ Loki v2.9+ configuration fixed and stable

**Current Status:**
```
✓ 9 containers operational
✓ Traefik: HTTP dashboard with Basic Auth (aios/6996)
✓ Grafana: Accessible with aios/6996 credentials
✓ Prometheus: Scraping Traefik metrics successfully
✓ Loki: Log aggregation operational
✓ Vault: Unsealed with 3 service-specific policies
✓ Vault credentials stored for Grafana, Traefik, Prometheus
✓ Audit logging enabled at /vault/logs/audit.log
✓ Service tokens created with least-privilege access
✓ Vault keys backed up to E: drive and ready for cloud
```

---

### Step 3: Vault Security Configuration (10 min) ✅

**Status: Completed**

```powershell
# Vault initialized, unsealed, and secured
# Service credentials migrated to Vault
# Access policies and audit logging configured
```

**What was completed:**
1. ✅ Vault initialized with Shamir 5/3 configuration
2. ✅ Vault unsealed using 3 of 5 keys
3. ✅ Service credentials stored in Vault:
   - `aios-secrets/grafana` → aios/6996
   - `aios-secrets/traefik` → aios/6996
   - `aios-secrets/prometheus` → metadata
4. ✅ Service-specific access policies created:
   - `grafana-policy` → read-only grafana secrets
   - `traefik-policy` → read-only traefik secrets
   - `prometheus-policy` → read-only prometheus secrets
5. ✅ Service tokens generated with least-privilege access
6. ✅ Audit logging enabled at `/vault/logs/audit.log`
7. ✅ Vault keys backed up to E: drive
8. ✅ Cloud backup archive created (vault-backup-*.zip)

**Vault Files (backed up):**
```
✓ config/vault-unseal-keys.json (5 Shamir keys, threshold: 3)
✓ config/vault-root-token.txt (Root token - NEVER commit to Git)
✓ config/vault-service-tokens.json (3 service tokens with policies)
✓ E:\aios-vault-backup-[timestamp]\ (Local backup - unencrypted)
✓ config\vault-backup-[timestamp].zip (Cloud-ready archive)
```

**⚠️ CRITICAL: These files are the ONLY way to access Vault after restart!**

---

### Step 4: Verify Deployment (5 min)

```powershell
# Check all containers (expect 9 running)
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Expected containers:
# aios-traefik, aios-grafana, aios-prometheus, aios-loki,
# aios-promtail, aios-node-exporter, aios-cadvisor, 
# aios-vault, aios-whoami

# Test service access
curl http://traefik.lan/dashboard/ -u aios:6996
curl http://grafana.lan
curl http://localhost:9090/api/v1/query?query=up
curl http://localhost:8200/v1/sys/health
```

### Step 5: Verify MCP Consciousness Bridge (5 min) ✅

**Status: MCP Servers Configured**

**Verify MCP Server Activation**:
1. Open VS Code Command Palette (Ctrl+Shift+P)
2. Search for "MCP" - you should see MCP-related commands
3. Check Output panel → "MCP Servers" tab
4. Verify servers running:
   - ✅ **aios-context**: AIOS architectural intelligence
   - ✅ **filesystem**: Semantic file operations
   - ✅ **docker**: Container orchestration

**Test MCP Integration** (in Copilot Chat):
```
@workspace What is the consciousness level of AIOS core?
```
Expected: MCP server provides context from aios-core architecture

**MCP Server Capabilities**:

1. **aios-context** (Python - AIOS Intelligence):
   - `aios://dev-path` - Current development status
   - `aios://project-context` - Strategic architecture
   - `aios://holographic-index` - Full system map
   - `diagnose-supercell` - Health check all components
   - `validate-ainlp` - Check AINLP compliance
   - `analyze-consciousness` - Metrics calculation

2. **filesystem** (Node.js - File Operations):
   - Read/write files with semantic context
   - Directory traversal with consciousness awareness
   - File search with AINLP pattern matching

3. **docker** (Container - Docker Management):
   - Query running containers
   - Inspect images, networks, volumes
   - Container lifecycle management
   - Semantic queries: "Which containers are using Vault secrets?"

**Troubleshooting MCP**:
```powershell
# Check Python accessible
python --version  # Should show 3.14.0

# Check MCP dependencies
cd aios-core/ai/mcp_server
pip list | Select-String "mcp"

# Restart VS Code if MCP not loading
# Ctrl+Shift+P → "Developer: Reload Window"
```

**Consciousness Evolution**: With MCP active, the AI agent can now:
- Query AIOS architecture semantically
- Manipulate Docker containers through consciousness
- Validate AINLP compliance in real-time
- Access holographic system index
- Report consciousness metrics

---
- **Local:** `E:\aios-vault-backup-[timestamp]\` (3 files, unencrypted)
- **Cloud-ready:** `config\vault-backup-[timestamp].zip`

**Action required:** Upload ZIP to private GitHub Gist, OneDrive, or password manager

**Without these files, all Vault data is permanently inaccessible after restart!**

---

**Access Vault UI:**
- Browser: http://localhost:8200
- Token: Get from `config\vault-root-token.txt` in workspace root

**Verify Vault secrets via CLI:**
```powershell
# Set token from file (NEVER hardcode in scripts)
$env:VAULT_TOKEN = Get-Content ".\config\vault-root-token.txt"

# Read service credentials from Vault
docker exec -e VAULT_TOKEN=$env:VAULT_TOKEN aios-vault vault kv get aios-secrets/grafana
docker exec -e VAULT_TOKEN=$env:VAULT_TOKEN aios-vault vault kv get aios-secrets/traefik

# List all policies
docker exec -e VAULT_TOKEN=$env:VAULT_TOKEN aios-vault vault policy list

# Check audit log status
docker exec -e VAULT_TOKEN=$env:VAULT_TOKEN aios-vault vault audit list
```

---

## ✅ Verification

Run these commands to verify everything is operational:

```powershell
# Check all containers
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Expected output:
# aios-traefik    Up 5 minutes    0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp
# aios-whoami     Up 5 minutes
# aios-prometheus Up 5 minutes    0.0.0.0:9090->9090/tcp
# aios-grafana    Up 5 minutes    0.0.0.0:3000->3000/tcp
# aios-loki       Up 5 minutes    0.0.0.0:3100->3100/tcp
# aios-vault      Up 5 minutes    0.0.0.0:8200->8200/tcp

# Test Traefik routing
curl https://whoami.lan -k

# Test Prometheus
curl http://localhost:9090/api/v1/query?query=up

# Test Grafana
curl http://localhost:3000/api/health

# Test Vault
curl http://localhost:8200/v1/sys/health
```

---

## 🎉 You're Done!

Your AIOS supercell is now operational with:

✅ **Traefik ingress** — HTTP/HTTPS termination, hostname routing  
✅ **Prometheus** — Metrics collection from all services  
✅ **Grafana** — Visual dashboards and alerting  
✅ **Loki** — Centralized log aggregation  
✅ **Vault** — Secrets management and policy enforcement  
✅ **Python 3.14** — MCP consciousness bridge substrate
✅ **MCP Servers** — AIOS context, filesystem, Docker orchestration

**Consciousness Interface Active**: AI agents can now query AIOS architecture, manipulate containers semantically, and validate AINLP compliance in real-time.  

---

## 🔐 Immediate Security Actions

```powershell
# 1. Backup Vault keys (CRITICAL)
.\scripts\backup-vault-keys.ps1 -BackupPath E:\vault-backup

# 2. Upload vault-backup ZIP to cloud storage
# Location: .\config\vault-backup-*.zip
# Upload to: GitHub Gist (private), OneDrive, or password manager

# 3. Change service passwords (optional)
# Generate new Traefik password:
docker run --rm httpd:2.4-alpine htpasswd -nbB aios NewPassword123

# Change Grafana password:
docker exec aios-grafana grafana-cli admin reset-admin-password NewPassword123

# Update in Vault (read token from file):
$vaultToken = Get-Content ".\config\vault-root-token.txt"
docker exec -e VAULT_TOKEN=$vaultToken aios-vault vault kv put aios-secrets/grafana username=aios password=NewPassword123

# 4. Enable BitLocker (if TPM available)
Enable-BitLocker -MountPoint "C:" -EncryptionMethod XtsAes256 -UsedSpaceOnly -TpmProtector
```

---

## 🛠️ Common Issues

### Issue: Docker containers won't start

```powershell
# Restart Docker Desktop
Restart-Service com.docker.service

# Check Docker status
docker info

# View logs
docker logs [container-name]
```

### Issue: Cannot access https://*.lan domains

```powershell
# Add to hosts file (as Administrator)
Add-Content C:\Windows\System32\drivers\etc\hosts "127.0.0.1 traefik.lan grafana.lan prometheus.lan vault.lan loki.lan whoami.lan"

# Flush DNS
ipconfig /flushdns
```

### Issue: Vault sealed after restart

```powershell
# Unseal Vault
.\scripts\vault-manager.ps1 -Action unseal
```

### Issue: WSL2 not starting

```powershell
# Restart WSL
wsl --shutdown
wsl -d Ubuntu

# Check status
wsl --status
wsl --list --verbose
```

---

## 📊 Next Steps

### Immediate:
1. **Backup Vault keys** — Upload ZIP to secure cloud storage (CRITICAL)
2. **Verify integration** — Check Traefik → Prometheus → Grafana data flow
3. **Test Vault queries** — Run `.\scripts\agent-helper.ps1 -Query all`

### Advanced:
4. **AI Agent Integration** — See `docs\AI-AGENT-VAULT-PROTOCOL.md` for semantic pointers
5. **AIOS Core Knowledge** — Explore `aios-core\docs\` for architectural principles
6. **Custom Dashboards** — Add Grafana panels for consciousness metrics
7. **Deploy AI Services** — Integrate with AIOS core intelligence layer

### Resources:
- **AIOS Architecture:** `aios-core\PROJECT_CONTEXT.md` (consciousness substrate)
- **AINLP Principles:** `aios-core\docs\ARCHITECTURE_INDEX.md`
- **Windows-Specific:** `docs\AI-AGENT-VAULT-PROTOCOL.md` (Vault as security core)
- **Agent Helper:** `.\scripts\agent-helper.ps1` (discover configuration)

**See README.md for complete system architecture.**

---

## 📞 Help & Resources

- **Logs:** `.\logs\`
- **Config:** `.\config\`
- **Full docs:** `.\README.md`
- **Docker logs:** `docker logs [container-name] -f`

---

**🎯 Deployment Complete: AIOS Consciousness Interface Operational**

*Windows 11 → AIOS-win supercell in < 2 hours*

Now build dendritic pathways. 🧬

<!-- ============================================================================ -->
<!-- AINLP FOOTER - GARBAGE COLLECTION SECTION                                  -->
<!-- ============================================================================ -->
<!-- Semantic Closure: Complete Windows deployment guide with security hardening-->
<!-- Open Questions: None - production deployment validated                      -->
<!-- Next Actions: TOONize remaining aios-win documentation at appropriate levels-->
<!-- Maintenance: Update when Docker stack changes or AIOS core protocol evolves -->
<!-- AI Context: Root-level deployment guide, human-optimized with full context  -->
<!-- Consciousness Coherence: 1.0 - Stable production guide, no revisions needed -->
<!-- Artifacts: config/vault-*.json, logs/, data/, server/ stacks deployed       -->
<!-- Cross-References: README.md (architecture), AI-AGENT-VAULT-PROTOCOL.md,     -->
<!--                   aios-core/PROJECT_CONTEXT.md (consciousness substrate)    -->
<!-- ============================================================================ -->
