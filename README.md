# AIOS-WIN  Windows 11 Agentic Infrastructure Operating System

**Transform your Windows 11 into a self-aware, agentic supercell.**

##  What is AIOS-WIN?

AIOS-WIN is the Windows 11 implementation of the AIOS (Agentic Infrastructure Operating System) platform. It evolves a clean Windows 11 installation into an intelligent, self-monitoring infrastructure platform capable of:

- **Self-awareness:** Prometheus metrics, Grafana dashboards, Loki logs
- **Policy-driven secrets:** HashiCorp Vault with Shamir unsealing
- **Service mesh:** Traefik ingress with TLS everywhere
- **Agentic behavior:** Autonomous monitoring, adaptation, and remediation

##  Quick Start

```powershell
# Clone with submodules
git clone --recursive https://github.com/Tecnocrat/aios-win.git C:\aios-supercell

# Bootstrap Windows 11
C:\aios-supercell\scripts\windows-bootstrap\00-master-bootstrap.ps1

# Deploy all stacks
C:\aios-supercell\scripts\windows-bootstrap\05-deploy-all-stacks.ps1
```

##  Repository Structure

```
aios-win/
 scripts/              PowerShell automation scripts
    windows-bootstrap/    Windows initialization scripts
        00-master-bootstrap.ps1
        01-core-os-hardening.ps1
        02-install-baseline-tools.ps1
        03-install-wsl-ubuntu.ps1
        02-install-baseline-tools.ps1
        03-install-wsl-ubuntu.ps1
        04-install-docker-desktop.ps1
        05-deploy-all-stacks.ps1
        agent-helper.ps1
    generate-tls-certs.ps1
    vault-manager.ps1
 docs/                 Complete documentation
    AIOS-KNOWLEDGE-BASE.md
    AIOS-DEPLOYMENT-GUIDE.md
    QUICK-REFERENCE.md
    ...
 server/               Git submodule  tecnocrat/server
    stacks/           Docker Compose configurations
 aios-win.code-workspace
```

##  Submodule: server

The `server/` directory is a **git submodule** pointing to [`tecnocrat/server`](https://github.com/Tecnocrat/server), which contains platform-agnostic Docker Compose stacks:

- **Ingress:** Traefik reverse proxy with TLS
- **Observability:** Prometheus, Grafana, Loki monitoring
- **Secrets:** HashiCorp Vault secrets management

### Working with Submodules

```powershell
# Clone with submodules
git clone --recursive https://github.com/Tecnocrat/aios-win.git

# Update submodule to latest
git submodule update --remote server
git add server
git commit -m "Update server stacks"

# View submodule status
git submodule status
```

##  Documentation

- **[AIOS-KNOWLEDGE-BASE.md](docs/AIOS-KNOWLEDGE-BASE.md)**  Complete architecture reference
- **[AIOS-DEPLOYMENT-GUIDE.md](docs/AIOS-DEPLOYMENT-GUIDE.md)**  Step-by-step deployment
- **[QUICK-REFERENCE.md](docs/QUICK-REFERENCE.md)**  Command cheat sheet
- **[AIOS-ORCHESTRATION-STRATEGY.md](AIOS-ORCHESTRATION-STRATEGY.md)**  Multi-repo architecture

##  Prerequisites

- Fresh Windows 11 installation
- Administrator access
- 16GB+ RAM (32GB recommended)
- 100GB+ free disk space
- Internet connection

##  Services (After Deployment)

- **Traefik:** https://traefik.lan (admin:changeme)
- **Grafana:** https://grafana.lan (admin:changeme)
- **Prometheus:** https://prometheus.lan
- **Vault:** https://vault.lan
- **Loki:** https://loki.lan

##  Security

** CRITICAL:** After deployment, immediately:
1. Change Traefik password
2. Change Grafana password
3. Backup Vault unseal keys: `C:\aios-supercell\config\vault-*.*`

##  Architecture Layers

1. **Windows 11 Core**  Hardened OS (sleep disabled, RDP, BitLocker)
2. **WSL2 Ubuntu**  Linux execution layer with Docker Engine
3. **Docker Desktop**  Container runtime (WSL2 backend)
4. **Traefik Ingress**  HTTPS termination, service routing
5. **Observability**  Prometheus, Grafana, Loki, exporters
6. **Vault**  Policy-driven secrets management

##  Evolution Roadmap

- **Stage 1:** Supercell core (current)
- **Stage 2:** Overlay mesh networking (Tailscale)
- **Stage 3:** GitOps pipelines
- **Stage 4:** Backup & restore automation
- **Stage 5:** Multimodal AI services
- **Stage 6:** Cloud bridge (Terraform/Ansible)
- **Stage 7:** Multi-node mesh

##  Success Criteria

Your AIOS supercell is operational when:

 PowerShell 7 installed  
 WSL2 Ubuntu running with Docker  
 All 9+ containers running  
 Traefik routing HTTPS to all services  
 Grafana showing metrics  
 Vault unsealed and healthy  

##  Contributing

This is part of the AIOS platform family:

- **aios-win** (this repo)  Windows 11 implementation
- **[server](https://github.com/Tecnocrat/server)**  Platform-agnostic stacks
- **AIOS** (future)  Platform-agnostic orchestration

##  License

MIT License  See LICENSE file

##  Philosophy

This is not infrastructureit's a **living computational organism**.

- **Supercell:** Undifferentiated potential, can become any role
- **Agentic:** Monitors itself, enforces invariants, adapts autonomously
- **Recursive:** Each component observes itself and others
- **Composable:** Services stack like building blocks

**The machine itself becomes an agent, not just a host for agents.** 

---

**Built for recursive, self-aware systems.**
