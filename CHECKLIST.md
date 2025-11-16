# AIOS Supercell — Deployment Checklist

Use this checklist to track your deployment progress.

---

## 📋 Phase 1: Core OS Preparation

- [ ] **Directory structure created**
  - [ ] `C:\aios-supercell\scripts\`
  - [ ] `C:\aios-supercell\config\`
  - [ ] `C:\aios-supercell\data\`
  - [ ] `C:\aios-supercell\logs\`
  - [ ] `C:\Users\jesus\server\stacks\`

- [ ] **OS hardening completed**
  - [ ] Sleep and hibernation disabled
  - [ ] High performance power plan active
  - [ ] Remote Desktop enabled with NLA
  - [ ] Windows Defender exclusions configured
  - [ ] BitLocker status checked

- [ ] **Baseline tools installed**
  - [ ] PowerShell 7
  - [ ] Windows Terminal
  - [ ] Hyper-V enabled
  - [ ] WSL2 enabled
  - [ ] Virtual Machine Platform enabled
  - [ ] System restarted

- [ ] **WSL2 Ubuntu configured**
  - [ ] Ubuntu installed
  - [ ] WSL2 set as default version
  - [ ] `.wslconfig` created with resource limits
  - [ ] Persistent directories created

- [ ] **Docker Desktop installed**
  - [ ] Docker Desktop running
  - [ ] WSL2 backend enabled
  - [ ] Integration with Ubuntu enabled
  - [ ] `docker ps` working

---

## 📋 Phase 2: WSL2 Ubuntu Setup

- [ ] **Ubuntu bootstrap completed**
  - [ ] System packages updated
  - [ ] Essential tools installed (curl, git, vim, etc.)
  - [ ] Docker Engine installed
  - [ ] User added to docker group
  - [ ] Symbolic links created to Windows directories
  - [ ] `docker run hello-world` successful

---

## 📋 Phase 3: TLS Certificates

- [ ] **Certificate generation**
  - [ ] Self-signed certificate created
  - [ ] Private key created
  - [ ] Certificate covers *.lan domains
  - [ ] `acme.json` created with restricted permissions
  - [ ] Certificate imported to Trusted Root (optional)

---

## 📋 Phase 4: Ingress Stack (Traefik)

- [ ] **Traefik deployment**
  - [ ] `docker-compose.yml` configured
  - [ ] `traefik.yml` static config created
  - [ ] `dynamic/tls.yml` dynamic config created
  - [ ] Certificates mounted correctly
  - [ ] Stack deployed: `docker compose up -d`
  - [ ] Traefik container running
  - [ ] Dashboard accessible: https://traefik.lan
  - [ ] Whoami test service accessible: https://whoami.lan
  - [ ] Default password changed

---

## 📋 Phase 5: Observability Stack

- [ ] **Prometheus deployment**
  - [ ] `prometheus.yml` configured
  - [ ] Alert rules created
  - [ ] Container running
  - [ ] Targets discovered and UP
  - [ ] Accessible: https://prometheus.lan

- [ ] **Grafana deployment**
  - [ ] Container running
  - [ ] Prometheus data source connected
  - [ ] Loki data source connected
  - [ ] Accessible: https://grafana.lan
  - [ ] Default password changed
  - [ ] Dashboards loading

- [ ] **Loki deployment**
  - [ ] Loki config created
  - [ ] Container running
  - [ ] Accessible: https://loki.lan

- [ ] **Promtail deployment**
  - [ ] Promtail config created
  - [ ] Container running
  - [ ] Logs being shipped to Loki

- [ ] **Exporters running**
  - [ ] Node Exporter (host metrics)
  - [ ] cAdvisor (container metrics)

---

## 📋 Phase 6: Secrets Management (Vault)

- [ ] **Vault deployment**
  - [ ] Container running
  - [ ] Accessible: https://vault.lan

- [ ] **Vault initialization**
  - [ ] Vault initialized
  - [ ] Unseal keys generated
  - [ ] Root token generated
  - [ ] Keys backed up securely
  - [ ] Vault unsealed
  - [ ] AppRole auth enabled
  - [ ] KV v2 secrets engine enabled
  - [ ] AIOS policy created

---

## 📋 Phase 7: Security Hardening

- [ ] **Credentials changed**
  - [ ] Traefik dashboard password
  - [ ] Grafana admin password
  - [ ] Vault root token secured

- [ ] **Files secured**
  - [ ] Vault unseal keys backed up offline
  - [ ] Root token backed up offline
  - [ ] Sensitive files NOT in Git

- [ ] **Network security**
  - [ ] Hosts file updated (if using .lan domains)
  - [ ] IP whitelisting configured (if exposing publicly)
  - [ ] Windows Firewall rules reviewed

- [ ] **BitLocker enabled** (optional)
  - [ ] System drive encrypted
  - [ ] Recovery key backed up

---

## 📋 Phase 8: Verification Tests

- [ ] **Container health**
  - [ ] All containers in "Up" status
  - [ ] No restart loops
  - [ ] Logs show no errors

- [ ] **Routing tests**
  - [ ] `curl https://traefik.lan` returns dashboard
  - [ ] `curl https://whoami.lan` returns whoami response
  - [ ] `curl https://grafana.lan` returns Grafana UI
  - [ ] `curl https://prometheus.lan` returns Prometheus UI
  - [ ] `curl https://vault.lan` returns Vault UI

- [ ] **Metrics tests**
  - [ ] Prometheus targets all UP
  - [ ] Grafana shows data in Explore
  - [ ] Alerts not firing (unless expected)
  - [ ] Container metrics visible in cAdvisor

- [ ] **Logs tests**
  - [ ] Loki receiving logs from Promtail
  - [ ] Docker container logs visible in Grafana
  - [ ] AIOS logs being collected

- [ ] **Vault tests**
  - [ ] Vault status shows unsealed
  - [ ] Can read/write secrets
  - [ ] Policies enforced

---

## 📋 Phase 9: Operational Readiness

- [ ] **Documentation reviewed**
  - [ ] README.md read
  - [ ] QUICKSTART.md understood
  - [ ] Troubleshooting section reviewed

- [ ] **Backup strategy**
  - [ ] Vault backup tested
  - [ ] Docker volume backup planned
  - [ ] Configuration files version controlled (Git)

- [ ] **Monitoring configured**
  - [ ] Alert rules reviewed and customized
  - [ ] Notification channels configured (email, Slack, etc.)
  - [ ] SLO thresholds defined

- [ ] **Runbooks created**
  - [ ] Vault unseal procedure documented
  - [ ] Container restart procedures documented
  - [ ] Backup/restore procedures documented
  - [ ] Incident response plan drafted

---

## 📋 Phase 10: Next Evolution (Optional)

- [ ] **Overlay mesh networking**
  - [ ] Tailscale or ZeroTier installed
  - [ ] Node tagged with roles
  - [ ] Remote access tested

- [ ] **GitOps setup**
  - [ ] Git repository initialized
  - [ ] Compose files version controlled
  - [ ] CI/CD pipeline configured

- [ ] **Additional services**
  - [ ] Keycloak (SSO/OIDC)
  - [ ] MinIO (object storage)
  - [ ] PostgreSQL (database)
  - [ ] Redis (cache)
  - [ ] NATS (message broker)

- [ ] **AI services**
  - [ ] Whisper (audio transcription)
  - [ ] TTS (text-to-speech)
  - [ ] ImageMagick + Tesseract (OCR)
  - [ ] Model serving endpoints

- [ ] **Cloud bridge**
  - [ ] Terraform configured
  - [ ] Ansible playbooks created
  - [ ] Hybrid deployments tested

---

## ✅ Deployment Complete

**Date completed:** _______________

**Deployed by:** _______________

**Notes:**

```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

---

## 🎯 Success Criteria

Your AIOS supercell is operational when ALL of these are true:

✅ All Phase 1-8 checkboxes marked  
✅ All containers in "Up" status  
✅ All services accessible via HTTPS  
✅ Metrics visible in Grafana  
✅ Logs aggregated in Loki  
✅ Vault initialized, unsealed, and secured  
✅ No critical errors in logs  
✅ Backup strategy in place  

**Congratulations! Your Windows 11 machine is now an AIOS supercell.** 🧬
