# AIOS Supercell — Quick Start Guide

**Get your Windows 11 AIOS supercell operational in under 2 hours.**

---

## ⚡ TL;DR — 5 Commands to Full Stack

```powershell
# 1. Clone with submodules
git clone --recursive https://github.com/Tecnocrat/aios-win.git C:\aios-supercell

# 2. Bootstrap core OS
C:\aios-supercell\scripts\00-master-bootstrap.ps1

# 3. Deploy all stacks (after restart)
C:\aios-supercell\scripts\05-deploy-all-stacks.ps1

# 4. Initialize Vault
C:\aios-supercell\scripts\vault-manager.ps1 -Action init
```

---

## 🎯 Access Your Services

| Service | URL | Default Credentials |
|---------|-----|---------------------|
| **Traefik Dashboard** | https://traefik.lan | admin:changeme |
| **Grafana** | https://grafana.lan | admin:changeme |
| **Prometheus** | https://prometheus.lan | None |
| **Loki** | https://loki.lan | None |
| **Vault** | https://vault.lan | See token file |
| **Whoami (test)** | https://whoami.lan | None |

**⚠️ Change default passwords immediately!**

---

## 📋 Pre-Flight Checklist

Before starting, ensure:

- [ ] Fresh Windows 11 installation
- [ ] Administrator access
- [ ] 16GB+ RAM (32GB recommended)
- [ ] 100GB+ free disk space
- [ ] Internet connection
- [ ] No existing WSL2/Docker installations

---

## 🚀 Step-by-Step Execution

### Step 0: Clone Repository (5 min)

```powershell
# Clone with submodules
git clone --recursive https://github.com/Tecnocrat/aios-win.git C:\aios-supercell
cd C:\aios-supercell

# Verify submodule
git submodule status
```

### Step 1: Core OS Bootstrap (30-60 min)

```powershell
# Open PowerShell as Administrator
Set-ExecutionPolicy Bypass -Scope Process -Force

# Run master bootstrap
C:\aios-supercell\scripts\00-master-bootstrap.ps1
```

**What happens:**
1. Creates directory structure
2. Disables sleep/hibernation
3. Enables RDP with NLA
4. Installs PowerShell 7, Windows Terminal
5. Enables Hyper-V, WSL2
6. **RESTART** (auto-resumes after login)
7. Installs Ubuntu on WSL2
8. Installs Docker Desktop

**Output:**
```
✓ Core OS hardened and optimized
✓ PowerShell 7, Windows Terminal installed
✓ Hyper-V and WSL2 enabled
✓ Ubuntu on WSL2 configured
✓ Docker Desktop ready
```

---

### Step 2: Deploy All Stacks (15 min)

```powershell
# Run unified deployment script
C:\aios-supercell\scripts\05-deploy-all-stacks.ps1
```

**What happens:**
1. Generates TLS certificates for *.lan domains
2. Updates Windows hosts file
3. Creates Docker network (aios-network)
4. Deploys Traefik ingress stack
5. Deploys observability stack (Prometheus, Grafana, Loki)
6. Deploys Vault secrets stack
7. Initializes Vault with Shamir unsealing

**Output:**
```
✓ TLS certificates generated
✓ Hosts file updated with .lan domains
✓ Docker network created
✓ Traefik ingress deployed
✓ Observability stack deployed
✓ Vault deployed and initialized
✓ All services accessible via HTTPS
```

---

### Step 3: Verify Deployment (5 min)

```powershell
# Check all containers
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Test services
curl https://traefik.lan -k
curl https://grafana.lan -k
curl https://prometheus.lan -k
curl https://vault.lan -k
```

**⚠️ CRITICAL: Backup these files NOW:**
- `C:\aios-supercell\config\vault-unseal-keys.json`
- `C:\aios-supercell\config\vault-root-token.txt`

**Access Vault:**
- Open browser: https://vault.lan
- Login with token from `C:\aios-supercell\config\vault-root-token.txt`

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

✅ **Traefik ingress** — HTTPS termination, hostname routing  
✅ **Prometheus** — Metrics collection from all services  
✅ **Grafana** — Visual dashboards and alerting  
✅ **Loki** — Centralized log aggregation  
✅ **Vault** — Secrets management and policy enforcement  

---

## 🔐 Immediate Security Actions

```powershell
# 1. Change Traefik password
# Edit C:\aios-supercell\server\stacks\ingress\docker-compose.yml
# Generate new password: htpasswd -nb admin YourNewPassword

# 2. Change Grafana password
# Login to https://grafana.lan
# Go to Profile > Change Password

# 3. Secure Vault keys
# Copy to encrypted USB or password manager
Copy-Item C:\aios-supercell\config\vault-*.* D:\SecureBackup\

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
C:\aios-supercell\scripts\vault-manager.ps1 -Action unseal
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

1. **Explore Grafana dashboards** — Add custom panels for your metrics
2. **Configure alerts** — Edit `stacks/observability/prometheus/alerts/`
3. **Store secrets in Vault** — Migrate hardcoded credentials
4. **Deploy AI services** — Add Whisper, TTS, or CV models
5. **Set up backups** — Configure automated Vault backups

**See full README.md for advanced configurations.**

---

## 📞 Help & Resources

- **Logs:** `C:\aios-supercell\logs\`
- **Config:** `C:\aios-supercell\config\`
- **Full docs:** `C:\aios-supercell\README.md`
- **Docker logs:** `docker logs [container-name] -f`

---

**🎯 Goal achieved: Windows 11 → AIOS Supercell in < 2 hours**

Now go build something recursive. 🧬
