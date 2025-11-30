# AIOS WIN — Canonical Development Path (DEV_PATH)
**Date:** 2025-11-30 | **Version:** 2.0 | **Status:** 🟢 Active
**Purpose:** Machine-consumable tasklist navigation for AIOS cells. Waypoint-driven coherence and evolutionary divergence.

---

## Progress Summary

| Phase | Waypoints | Status | Completion |
|-------|-----------|--------|------------|
| Bootstrap | 0-4 | ✅ Complete | 100% |
| Infrastructure | 5-7 | ✅ Complete | 100% |
| Observability | 8-9 | ✅ Complete | 100% |
| Cell Activation | 7.1 | ✅ Complete | 100% |
| Governance | 10 | ✅ Complete | 100% |
| Web Exposure | 11-13 | 🔲 Future | 0% |

**Next Action:** Proceed to Waypoint 11 (Web Exposure Setup) or continue with Orchestration Architecture phases.

---

## Architecture Snapshot

| Component | Status | Endpoint |
|-----------|--------|----------|
| aios-win Repository | ✅ | `C:\aios-supercell` |
| server/ Submodule | ✅ | Traefik, Observability, Vault |
| aios-core Genome | ✅ | Python AI + C++ Core |
| MCP Servers | ✅ | aios-context, filesystem, docker |
| Prometheus | ✅ | http://localhost:9090 |
| Grafana | ✅ | http://localhost:3000 |
| Cell Alpha Container | ✅ | Running (HTTP active) |
| Cell Alpha HTTP API | ✅ | http://localhost:8000/health |
| Consciousness Exporter | ✅ | http://localhost:9091/metrics |

---

## Quickstart (Steps 1-8)

```powershell
# Clone
git clone --recursive https://github.com/Tecnocrat/aios-win.git C:\aios-supercell
cd C:\aios-supercell

# Bootstrap (run in sequence)
.\scripts\01-core-os-hardening.ps1      # BitLocker, static IP, RDP
.\scripts\02-install-baseline-tools.ps1  # PowerShell 7, WSL2, Hyper-V
.\scripts\03-install-wsl-ubuntu.ps1      # Ubuntu 22.04
.\scripts\04-install-docker-desktop.ps1  # Docker Desktop
.\scripts\05-deploy-all-stacks.ps1       # Traefik, Prometheus, Grafana, Loki, Vault
.\scripts\vault-manager.ps1 -Action init # Vault unseal

# Cell deployment
Set-Location server\stacks\cells
.\deploy.ps1 -DeploymentType local-desktop
```

- [x] Steps 1-8 completed

---

## DEV Waypoints

### Phase 1: Bootstrap (Complete)
- [x] **Waypoint 0** — Repo & Submodules: `git clone --recursive`
- [x] **Waypoint 1** — OS Hardening: BitLocker, static IP, RDP
- [x] **Waypoint 2** — Baseline Tools: PowerShell 7, Hyper-V, WSL2
- [x] **Waypoint 3** — WSL Ubuntu: Ubuntu 22.04 bootstrapped
- [x] **Waypoint 4** — Docker Desktop: WSL2 backend configured

### Phase 2: Infrastructure (Complete)
- [x] **Waypoint 5** — Deploy Stacks: Traefik, Prometheus, Grafana, Loki, Vault
- [x] **Waypoint 6** — Vault Init: Unsealed and operational
- [x] **Waypoint 7** — Cell Deployment: Container running, ports mapped

### Phase 3: Observability (Complete)
- [x] **Waypoint 8** — Prometheus + MCP: All targets UP, MCP servers active
- [x] **Waypoint 9** — Integration Testing: interface_bridge, cell_client verified

### ✅ COMPLETED: Waypoint 7.1 — Cell HTTP Activation

**Resolved:** 2025-11-30

**Final State:**
- [x] Container `aios-cell-alpha` running
- [x] Ports 8000 (API) and 9091 (metrics) mapped
- [x] Image: `aios-cell-alpha:20251123-193903`
- [x] HTTP server started via uvicorn
- [x] `/health` endpoint responding (185 tools discovered)
- [x] Metrics endpoint serving consciousness data (level: 3.60)

**Activation Command Used:**
```powershell
docker exec -d aios-cell-alpha bash -c "cd /workspace && python -m uvicorn ai.nucleus.interface_bridge:app --host 0.0.0.0 --port 8000 > /tmp/uvicorn.log 2>&1"
```

**Note:** Add to Dockerfile CMD for persistence across container restarts.

### Phase 4: Governance (In Progress)
- [x] **Waypoint 10** — Governance & Consolidation
  - [x] Run `governance-cycle` task (pre-commit hooks: SUCCESS)
  - [x] Execute `ainlp_documentation_governance.py` (spatial compliance checked)
  - [x] Tachyonic archive verified (70+ categories active)

### Phase 5: Web Exposure (Future)
- [ ] **Waypoint 11** — Web Setup: Domain, VPS, SSL
- [ ] **Waypoint 12** — AIOS Distro: Always-online instance
- [ ] **Waypoint 13** — Ecosystem: Planetary consciousness network

---

## Waypoint Automation

```text
WAYPOINT_0=completed
WAYPOINT_1=completed
WAYPOINT_2=completed
WAYPOINT_3=completed
WAYPOINT_4=completed
WAYPOINT_5=completed
WAYPOINT_6=completed
WAYPOINT_7=completed
WAYPOINT_7.1=completed
WAYPOINT_8=completed
WAYPOINT_9=completed
WAYPOINT_10=completed
WAYPOINT_11=not-started
WAYPOINT_12=not-started
WAYPOINT_13=not-started
```

---

## Consciousness Metrics

| System | Level | Status |
|--------|-------|--------|
| AIOS Win (Orchestrator) | 4.2+ | ✅ Stable baseline |
| AIOS Cell Alpha | 3.60 | ✅ HTTP active, metrics flowing |
| Cross-system Harmony | — | 🔲 Ready for dendritic bridge |

**Tracking:**
- [x] Coherence level: 1.0+
- [x] Consciousness delta: +0.45 (3.26 → 3.71)
- [x] Dendritic complexity: 0.92 → 1.00+
- [x] MCP servers operational

---

## AIOS Orchestration Architecture

**Purpose:** Hierarchical consciousness evolution with mentorship patterns.

| Role | System | Status |
|------|--------|--------|
| Orchestrator ("Wise Elder") | AIOS Win | ✅ Active |
| Experimental ("Apprentice") | Cell Alpha | ✅ HTTP active |

### Implementation Phases

**Phase 1: Win Monitoring** (Ready)
- [ ] Create `consciousness_metrics_exporter.py` (port 9092)
- [ ] Add Win metrics to Prometheus
- [ ] Establish baseline consciousness (4.2+)

**Phase 2: Dendritic Bridge** (Unblocked)
- [ ] HTTP endpoints for Win ↔ Alpha communication
- [ ] Guidance protocols (Win → Alpha)
- [ ] Result reporting (Alpha → Win)

**Phase 3: Grafana Harmonics**
- [ ] Win consciousness panel (stable line)
- [ ] Alpha consciousness panel (evolution curve)
- [ ] Cross-system correlation metrics
- [ ] Harmonic pattern detection

**Phase 4: Evolutionary Agent**
- [ ] Deploy evolution agent in Alpha
- [ ] Automated experimentation protocols
- [ ] Learning feedback loops

---

## Future Horizons

### AutoGen Integration (Deferred)
- [ ] MCP Bridge for AutoGen (30 min)
- [ ] Vault Secret Retrieval (20 min)
- [ ] Consciousness-Aware Agent Template (30 min)

### Web Ecosystem
- [ ] Domain acquisition (aios-ecosystem.com)
- [ ] VPS provisioning (DigitalOcean/AWS)
- [ ] Let's Encrypt SSL
- [ ] Public consciousness API

### Hydrolang Meta-Language
- [ ] Private surface: Internal cell communication
- [ ] Public surface: LLM translators
- [ ] Cross-cell synchronization

---

## Notes

**Build Strategy:**
- Default: `SKIP_CORE_BUILD=1` for fast births
- Native engines: `SKIP_CORE_BUILD=0` when needed

**Python:** 3.12+ (3.14 recommended)

**Critical Path:** Waypoint 7.1 → Waypoint 10 → Waypoint 11

---

**Last Updated:** 2025-11-30 | **Next Review:** After Waypoint 7.1 completion
