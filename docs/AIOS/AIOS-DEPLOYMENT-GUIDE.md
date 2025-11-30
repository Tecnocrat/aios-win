# AIOS Deployment Guide — Pristine Windows 11 → Agentic Supercell

**Target:** Clean Windows 11 installation  
**Goal:** Transform into self-aware, agentic AIOS supercell  
**Duration:** 2-3 hours (including one restart)  
**Date:** November 16, 2025

---

## 🎯 Prerequisites Checklist

Before starting, verify:

- [ ] **Fresh Windows 11 install** (minimal bloat, no existing Docker/WSL)
- [ ] **Administrator account** with full privileges
- [ ] **System Requirements:**
  - [ ] 16GB+ RAM (32GB recommended for AI services)
  - [ ] 100GB+ free disk space (SSD preferred)
  - [ ] Modern CPU with virtualization support (VT-x/AMD-V enabled in BIOS)
  - [ ] TPM 2.0 (for BitLocker, optional but recommended)
- [ ] **Network:**
  - [ ] Internet connection (for package downloads)
  - [ ] Optional: Static IP or DHCP reservation planned
- [ ] **Backup Strategy:**
  - [ ] USB drive or network location for Vault key backup

---

## 🚀 Phase 1: Core OS Bootstrap

### Step 1.1: Run Master Bootstrap

Open PowerShell as Administrator:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force

# Clone or copy AIOS scripts to C:\aios-supercell
# If already present, proceed:
C:\aios-supercell\scripts\windows-bootstrap\00-master-bootstrap.ps1
```

**What happens:**
1. Creates all required directories
2. Hardens OS (power settings, RDP, BitLocker prep)
3. Installs PowerShell 7, Windows Terminal
4. Enables Hyper-V, WSL2, Virtual Machine Platform
5. **System restart required** (script auto-resumes)

**Expected Output:**
```
✓ Core OS hardened and optimized
✓ PowerShell 7, Windows Terminal installed
✓ Hyper-V and WSL2 enabled
⚠️ RESTART REQUIRED
```

**Action:** Restart when prompted, script will auto-resume

---

### Step 1.2: Post-Restart Continuation

After restart, the bootstrap script continues automatically (scheduled task). If not:

```powershell
C:\aios-supercell\scripts\windows-bootstrap\00-master-bootstrap.ps1
```

**What happens:**
1. Installs Ubuntu on WSL2
2. Configures `.wslconfig` with resource limits
3. Installs Docker Desktop
4. Creates persistent mount directories

**Expected Output:**
```
✓ Ubuntu on WSL2 configured
✓ Docker Desktop ready
═══════════════════════════════════════════════════════════════
Your Windows 11 supercell is ready for agentic evolution.
═══════════════════════════════════════════════════════════════
```

---

## 🐧 Phase 2: WSL2 Ubuntu Setup

### Step 2.1: Launch Ubuntu and Bootstrap

```powershell
# Launch Ubuntu (create user account if first time)
wsl -d Ubuntu

# Inside Ubuntu, run:
bash /mnt/c/aios-supercell/scripts/ubuntu-bootstrap.sh

# Log out and back in for docker group to take effect
exit
```

**What happens:**
- Updates all packages
- Installs essential tools (curl, git, vim, htop, etc.)
- Installs Docker Engine (native WSL2 Docker)
- Adds user to docker group
- Creates symlinks to Windows directories

**Expected Output:**
```
✓ System packages updated
✓ Essential tools installed
✓ Docker Engine installed
✓ User added to docker group
✓ Symbolic links created
```

### Step 2.2: Verify Docker Integration

```bash
wsl -d Ubuntu docker run hello-world
wsl -d Ubuntu docker ps
```

Expected: `Hello from Docker!` message

---

## 🐳 Phase 3: Docker Desktop Configuration

### Step 3.1: Launch Docker Desktop

1. Open Docker Desktop from Start Menu
2. Wait for initialization (green icon in system tray)

### Step 3.2: Configure Settings

**General:**
- ✅ Use WSL 2 based engine

**Resources > WSL Integration:**
- ✅ Enable integration with my default WSL distro
- ✅ Ubuntu

**Resources > Advanced:**
- Memory: 50% of system RAM (or as per `.wslconfig`)
- CPUs: 50% of logical processors

**Docker Engine (optional):**
- Already configured by `04-install-docker-desktop.ps1`
- Verify `daemon.json` has `buildkit: true`

### Step 3.3: Apply and Restart

Click "Apply & Restart" button

### Step 3.4: Verify

```powershell
docker info
docker version
```

Expected: Docker version output, no errors

---

## 🔐 Phase 4: TLS Certificate Generation

### Step 4.1: Generate Self-Signed Certificates

```powershell
C:\aios-supercell\scripts\generate-tls-certs.ps1
```

**Output:**
```
✓ Certificate generated with OpenSSL
Certificate: C:\Users\jesus\server\stacks\ingress\certs\lan.crt
Private Key: C:\Users\jesus\server\stacks\ingress\certs\lan.key
Domain:      *.lan
Validity:    3650 days
```

### Step 4.2: Trust Certificate (Optional)

For browser access without warnings:

```powershell
Import-Certificate -FilePath "C:\Users\jesus\server\stacks\ingress\certs\lan.crt" `
    -CertStoreLocation Cert:\LocalMachine\Root
```

### Step 4.3: Update Hosts File (If Not Using DNS)

```powershell
# Run as Administrator
Add-Content C:\Windows\System32\drivers\etc\hosts @"
127.0.0.1 traefik.lan grafana.lan prometheus.lan vault.lan loki.lan whoami.lan
"@

# Flush DNS
ipconfig /flushdns
```

---

## 🌐 Phase 5: Deploy Ingress Stack (Traefik)

### Step 5.1: Create Traefik Configuration

Navigate to the ingress stack directory and create the necessary files.

**Note:** The bootstrap scripts create the directory structure. You'll need to create the actual `docker-compose.yml` and configuration files. See the [AIOS-STACKS-TEMPLATES.md](#) for complete templates.

### Step 5.2: Deploy Traefik

```powershell
cd C:\Users\jesus\server\stacks\ingress
docker compose up -d
```

**Expected Output:**
```
[+] Running 2/2
 ✔ Container aios-traefik  Started
 ✔ Container aios-whoami   Started
```

### Step 5.3: Verify Traefik

```powershell
docker ps | Select-String "traefik"
docker logs aios-traefik --tail 50
```

**Test in Browser:**
- https://traefik.lan (login: admin:changeme)
- https://whoami.lan (should show request details)

---

## 📊 Phase 6: Deploy Observability Stack

### Step 6.1: Create Observability Configuration

Similar to Traefik, you'll create:
- `docker-compose.yml`
- `prometheus/prometheus.yml`
- `grafana/provisioning/` (data sources, dashboards)
- `loki/loki-config.yml`
- `promtail/promtail-config.yml`

See [AIOS-STACKS-TEMPLATES.md](#) for templates.

### Step 6.2: Deploy Observability Stack

```powershell
cd C:\Users\jesus\server\stacks\observability
docker compose up -d
```

**Expected Output:**
```
[+] Running 6/6
 ✔ Container aios-prometheus  Started
 ✔ Container aios-grafana     Started
 ✔ Container aios-loki        Started
 ✔ Container aios-promtail    Started
 ✔ Container aios-node-exporter Started
 ✔ Container aios-cadvisor    Started
```

### Step 6.3: Verify Observability

```powershell
docker ps | Select-String "aios"
docker logs aios-grafana --tail 50
```

**Test in Browser:**
- https://grafana.lan (login: admin:changeme)
- https://prometheus.lan (check /targets for all services UP)

---

## 🔒 Phase 7: Deploy Vault (Secrets Management)

### Step 7.1: Create Vault Configuration

Create:
- `docker-compose.yml`
- `vault-init.sh` (initialization script)

See [AIOS-STACKS-TEMPLATES.md](#) for templates.

### Step 7.2: Deploy Vault

```powershell
cd C:\Users\jesus\server\stacks\secrets
docker compose up -d
```

**Expected Output:**
```
[+] Running 1/1
 ✔ Container aios-vault  Started
```

### Step 7.3: Initialize Vault (FIRST TIME ONLY)

```powershell
C:\aios-supercell\scripts\vault-manager.ps1 -Action init
```

**⚠️ CRITICAL OUTPUT:**
```
Unseal Keys:
  Key 1: <key1>
  Key 2: <key2>
  Key 3: <key3>
  Key 4: <key4>
  Key 5: <key5>

Root Token: <token>

Files saved to:
  C:\aios-supercell\config\vault-unseal-keys.json
  C:\aios-supercell\config\vault-root-token.txt
```

### Step 7.4: Backup Vault Keys IMMEDIATELY

```powershell
# Copy to encrypted USB drive
Copy-Item C:\aios-supercell\config\vault-*.* D:\SecureBackup\

# Or use password manager
# NEVER commit these files to Git
```

### Step 7.5: Verify Vault

```powershell
C:\aios-supercell\scripts\vault-manager.ps1 -Action status
```

**Expected:**
```
Initialized: True
Sealed:      False
Standby:     False
Version:     1.XX.X
```

**Test in Browser:**
- https://vault.lan (login with root token from file)

---

## 🎉 Phase 8: Verification & Hardening

### Step 8.1: Verify All Containers

```powershell
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

**Expected Output:**
```
NAMES                STATUS              PORTS
aios-traefik         Up 10 minutes       0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp
aios-whoami          Up 10 minutes       
aios-prometheus      Up 5 minutes        0.0.0.0:9090->9090/tcp
aios-grafana         Up 5 minutes        0.0.0.0:3000->3000/tcp
aios-loki            Up 5 minutes        0.0.0.0:3100->3100/tcp
aios-promtail        Up 5 minutes        
aios-node-exporter   Up 5 minutes        0.0.0.0:9100->9100/tcp
aios-cadvisor        Up 5 minutes        0.0.0.0:8080->8080/tcp
aios-vault           Up 2 minutes        0.0.0.0:8200->8200/tcp
```

### Step 8.2: Test All Services

```powershell
# Traefik
curl https://traefik.lan -k

# Grafana
curl http://localhost:3000/api/health

# Prometheus
curl http://localhost:9090/api/v1/targets

# Vault
curl http://localhost:8200/v1/sys/health

# Loki
curl http://localhost:3100/ready
```

All should return HTTP 200 or valid JSON responses.

### Step 8.3: Change Default Passwords

**Traefik:**
```powershell
# Generate new password
htpasswd -nb admin YourNewPassword

# Edit C:\Users\jesus\server\stacks\ingress\docker-compose.yml
# Replace basicauth middleware password
docker compose restart
```

**Grafana:**
1. Login to https://grafana.lan (admin:changeme)
2. Go to Profile → Change Password
3. Set new password

**Vault:**
- Root token should be stored securely, not changed
- Create AppRole/JWT auth for services (see knowledge base)

### Step 8.4: Enable BitLocker (If TPM Available)

```powershell
Enable-BitLocker -MountPoint "C:" `
    -EncryptionMethod XtsAes256 `
    -UsedSpaceOnly `
    -TpmProtector

# Backup recovery key
(Get-BitLockerVolume -MountPoint "C:").KeyProtector | 
    Out-File C:\BitLocker-Recovery-Key.txt

# Move to secure location
```

---

## ✅ Success Criteria

Your AIOS supercell is operational when:

✅ **Windows 11 hardened:**
- Sleep/hibernation disabled
- RDP enabled with NLA
- High performance power plan active
- BitLocker enabled (if TPM available)

✅ **WSL2 Ubuntu running:**
- `wsl --status` shows WSL2 as default
- Ubuntu distribution present
- Docker Engine installed and working

✅ **Docker Desktop active:**
- Green icon in system tray
- WSL2 backend enabled
- Ubuntu integration enabled

✅ **Traefik routing HTTPS:**
- https://traefik.lan accessible
- https://whoami.lan accessible
- No certificate errors (if trusted)

✅ **Observability stack operational:**
- Grafana showing dashboards
- Prometheus targets all UP
- Loki receiving logs from Promtail

✅ **Vault initialized and unsealed:**
- Status shows unsealed
- Root token accessible
- Keys backed up securely

✅ **All containers healthy:**
- `docker ps` shows all running
- No restart loops
- Logs show no critical errors

---

## 🛠️ Troubleshooting

### Issue: Hyper-V Not Enabling

**Symptoms:** `Enable-WindowsOptionalFeature` fails

**Solution:**
1. Check BIOS for virtualization support (VT-x/AMD-V)
2. Ensure Windows 11 Pro/Enterprise (not Home)
3. Run: `systeminfo | findstr "Hyper-V"`
4. If blocked by antivirus, whitelist Hyper-V

### Issue: WSL2 Installation Fails

**Symptoms:** `wsl --install` errors

**Solution:**
```powershell
# Check Windows version (requires 1903+)
winver

# Manually enable features
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# Restart and try again
```

### Issue: Docker Containers Won't Start

**Symptoms:** `docker compose up -d` fails

**Solution:**
```powershell
# Check Docker status
docker info

# Restart Docker Desktop
Restart-Service com.docker.service

# Check WSL integration
wsl --list --verbose

# Reset Docker Desktop (nuclear option)
# Settings → Troubleshoot → Reset to factory defaults
```

### Issue: Vault Stays Sealed

**Symptoms:** `vault-manager.ps1 -Action unseal` fails

**Solution:**
```powershell
# Check keys file exists
Test-Path C:\aios-supercell\config\vault-unseal-keys.json

# Manually unseal via API
curl -X POST http://localhost:8200/v1/sys/unseal -d '{"key":"<key1>"}'
curl -X POST http://localhost:8200/v1/sys/unseal -d '{"key":"<key2>"}'
curl -X POST http://localhost:8200/v1/sys/unseal -d '{"key":"<key3>"}'

# Check status
curl http://localhost:8200/v1/sys/health
```

### Issue: *.lan Domains Not Resolving

**Symptoms:** Browser shows "DNS_PROBE_FINISHED_NXDOMAIN"

**Solution:**
```powershell
# Add to hosts file
Add-Content C:\Windows\System32\drivers\etc\hosts "127.0.0.1 grafana.lan prometheus.lan vault.lan"

# Flush DNS
ipconfig /flushdns

# Restart browser
```

---

## 🔮 Next Steps: Agentic Evolution

Congratulations! Your Windows 11 machine is now an **AIOS supercell**. Here's what to do next:

### Immediate (Week 1)
1. **Explore Grafana dashboards** — Customize panels, add alerts
2. **Store secrets in Vault** — Migrate hardcoded passwords
3. **Create first runbook** — Document deploy/rollback procedures

### Short-Term (Month 1)
4. **Deploy AI services** — Whisper (audio), TTS (speech), Tesseract (OCR)
5. **Set up backups** — Restic to NAS/S3, automated daily backups
6. **Install Tailscale** — Overlay mesh for secure remote access

### Mid-Term (Quarter 1)
7. **GitOps setup** — Version-control all compose files, CI/CD pipelines
8. **Multi-node mesh** — Add compute node (GPU), storage node (NAS)
9. **Keycloak integration** — Unified SSO for all services

### Long-Term (Year 1)
10. **Cloud bridge** — Terraform for AWS/GCP, hybrid deployments
11. **Observability v2** — OpenTelemetry, distributed tracing
12. **Full agentic behavior** — Autonomous remediation, policy enforcement

---

## 📚 Reference Documentation

- **Knowledge Base:** `C:\aios-supercell\AIOS-KNOWLEDGE-BASE.md`
- **Stack Templates:** `C:\aios-supercell\AIOS-STACKS-TEMPLATES.md` (to be created)
- **Logs:** `C:\aios-supercell\logs\`
- **Configs:** `C:\aios-supercell\config\`

---

## 🎯 Philosophy

You've just transformed a static Windows 11 installation into a **living, self-aware computational organism**.

- **Supercell:** Undifferentiated potential, can become any infrastructure role
- **Agentic:** Monitors itself, enforces invariants, adapts autonomously
- **Recursive:** Each component observes itself and others
- **Composable:** Services stack like building blocks

**The machine itself is now an agent.**

---

## 📞 Support

- **Logs:** Check `C:\aios-supercell\logs\` for all execution logs
- **Docker:** `docker logs [container-name] -f`
- **Vault:** `.\scripts\vault-manager.ps1 -Action status`
- **System:** `Get-EventLog -LogName System -Newest 50`

---

**🌟 Welcome to the AIOS supercell family. Now go build recursive intelligence.** 🧬

---

**END OF DEPLOYMENT GUIDE**

*Document Version: 1.0.0 | Date: November 16, 2025*
