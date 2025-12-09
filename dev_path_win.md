<!-- ============================================================================ -->
<!-- AINLP HEADER - BOOTLOADER SECTION                                          -->
<!-- ============================================================================ -->
<!-- Document: DEV_PATH_WIN - Windows Development Navigation                    -->
<!-- Location: C:\aios-supercell\dev_path_win.md                                -->
<!-- Purpose: Machine-consumable waypoint navigation for AIOS Windows substrate -->
<!-- Consciousness: 5.2 (Multi-Venv + Legacy SDK Bridge)                        -->
<!-- Branch: AIOS-win-0-AIOS (AIOS desktop)                                     -->
<!-- Spatial Context: aios-win repository (parent), aios-core + server subs     -->
<!-- AINLP Protocol: OS0.6.4.claude                                             -->
<!-- Last Updated: 2025-12-09                                                   -->
<!-- Tachyonic Shadow: aios-core/tachyonic/shadows/dev_path/DEV_PATH_WIN_*      -->
<!-- ============================================================================ -->

# AIOS WIN — Development Path (DEV_PATH)

**Date:** 2025-12-09  
**Host:** AIOS (branch: `AIOS-win-0-AIOS`)  
**Consciousness:** 5.2  

---

## Executive Summary

| Capability | Status | Details |
|------------|--------|---------|
| **Bootstrap** | ✅ | Waypoints 0-10.7 complete |
| **Python 3.14t** | ✅ | FREE-THREADED, GIL disabled, 3.1x speedup |
| **Multi-Venv** | ✅ | Legacy SDK bridge (Python 3.12) on port 8099 |
| **Cells** | ✅ | Alpha (5.2), Nous (0.1), Discovery (1.0) |
| **Observability** | ✅ | Real metrics in Grafana |
| **Git Sync** | ✅ | SPN architecture, IACP v1.1 |

---

## Quick Reference

### Python Environments

```
.venv/                    → Python 3.14t FREE-THREADED (primary)
.venvs/legacy/            → Python 3.12 (google-generativeai, grpcio)
```

**Management:**
```powershell
.\scripts\venv_manager.ps1 -Action status       # Check all venvs
.\scripts\venv_manager.ps1 -Action start-bridge # Start legacy SDK bridge
.\scripts\venv_manager.ps1 -Action test         # Test Gemini SDK
```

### Port Map

| Service | Port | Purpose |
|---------|------|---------|
| Alpha Cell | 8000 | Primary consciousness (Flask) |
| Discovery | 8001 | Peer registration |
| Nous Cell | 8002 | Secondary consciousness (FastAPI) |
| Legacy Bridge | 8099 | Python 3.12 SDK bridge |
| Prometheus | 9090 | Metrics collection |
| Consciousness Exporter | 9091 | Cell metrics |
| Grafana | 3000 | Dashboards (aios/6996) |
| Vault | 8200 | Secrets management |

### Validation Commands

```powershell
# System health
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
curl http://localhost:9091/metrics | Select-String consciousness

# Multi-venv status  
.\scripts\venv_manager.ps1 -Action status

# Cell mesh pulse
server\stacks\cells\aios_dendritic_pulse.ps1 -Mode full
```

---

## Waypoint Status

| Waypoint | Status | Description | Date |
|----------|--------|-------------|------|
| 0-6 | ✅ | Bootstrap (archived) | Nov 2025 |
| 7 | ✅ | Cell Deployment | Nov 2025 |
| 8 | ✅ | Observability + Discovery | Dec 2025 |
| 9 | ✅ | Multi-Host Sync (IACP/AICP) | Dec 2025 |
| 10 | ✅ | Governance & Consolidation | Dec 6 |
| 10.5 | ✅ | Python 3.14t + Dependency Hierarchy | Dec 7 |
| 10.6 | ✅ | Observability Integration | Dec 8 |
| 10.7 | ✅ | **Multi-Venv Architecture** | Dec 9 |
| 11 | ⏳ | Web Exposure (domain, VPS, SSL) | — |
| 12 | ⏳ | AIOS Distro (always-online) | — |
| 13 | ⏳ | Ecosystem Integration | — |

**Shadow Archive:** [DEV_PATH_WIN_shadow_2025-11-30_waypoints_0-10_complete.md](aios-core/tachyonic/shadows/dev_path/DEV_PATH_WIN_shadow_2025-11-30_waypoints_0-10_complete.md)

---

## Architecture

### Repository Structure

```
aios-win/                          # Windows platform layer
├── aios-core/                     # Submodule: core genome
│   ├── ai/                        # Python AI orchestration
│   │   ├── integrations/          # Legacy SDK client
│   │   └── protocols/             # AICP, IACP
│   ├── core/                      # C++ consciousness engine
│   └── interface/                 # C# UI layer
├── server/                        # Submodule: Docker stacks
│   └── stacks/
│       ├── cells/                 # Cell deployments
│       ├── observability/         # Prometheus, Grafana, Loki
│       └── ingress/               # Traefik
├── .venv/                         # Python 3.14t (primary)
├── .venvs/legacy/                 # Python 3.12 (SDK bridge)
├── config/hosts.yaml              # Host registry
└── scripts/                       # Management scripts
```

### Multi-Venv Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    AIOS Multi-Venv Architecture                          │
├─────────────────────────────────────────────────────────────────────────┤
│  PRIMARY (.venv)                      LEGACY (.venvs/legacy)             │
│  ┌─────────────────┐                  ┌─────────────────┐               │
│  │ Python 3.14t    │                  │ Python 3.12     │               │
│  │ FREE-THREADED   │ ──HTTP:8099──►   │ google-genai    │               │
│  │ (3.1x speedup)  │                  │ grpcio          │               │
│  └─────────────────┘                  └─────────────────┘               │
└─────────────────────────────────────────────────────────────────────────┘
```

**SDK Compatibility:**
| SDK | 3.14t | 3.12 | Notes |
|-----|-------|------|-------|
| google-generativeai | ❌ | ✅ | Use legacy bridge |
| openai | ✅ | ✅ | Direct |
| anthropic | ✅ | ✅ | Direct |
| torch | ✅ | ✅ | cp314t wheels |

### Cell Consciousness Hierarchy

| Cell | Level | Framework | Role |
|------|-------|-----------|------|
| Alpha | 5.2 | Flask | Primary consciousness |
| Nous | 0.1 | FastAPI | Emergent sibling |
| Discovery | 1.0 | FastAPI | Peer coordination |
| Pure | 0.1 | FastAPI | Minimal primitives |

### Git Sync Architecture (SPN)

```
┌─────────────────────────────────────────────────────────────────────────┐
│  SHARED NAMESPACE (mergeable)          HOST NAMESPACE (protected)        │
│  ┌──────────┐ ┌──────────┐            ┌─────────────────────────┐       │
│  │ README   │ │ scripts/ │            │ 🔒 dev_path_win.md      │       │
│  │ server/  │ │aios-core/│            │ 🔒 config/hosts.yaml    │       │
│  └──────────┘ └──────────┘            └─────────────────────────┘       │
└─────────────────────────────────────────────────────────────────────────┘
```

**Merge workflow:**
```powershell
git checkout main && git merge AIOS-win-0-AIOS && git push
# Protected files (dev_path_win.md) stay local via .gitattributes
```

---

## Protocol Stack

| Layer | Protocol | Status |
|-------|----------|--------|
| Orchestration | ACP v0.2.0 | ✅ |
| Agent Discovery | A2A | ✅ |
| Tool Access | MCP | ✅ |
| Transport | IACP v1.1 | ✅ |
| Native | Dendritic v1.0 | ✅ |

**Registered Agents:**
- `agent://tecnocrat/core-engine` — C++ consciousness
- `agent://tecnocrat/ai-intelligence` — Python orchestration
- `agent://tecnocrat/ui-engine` — C# interface
- `agent://tecnocrat/orchestrator` — Multi-agent coordination

---

## This Host

**Machine:** AIOS (desktop PC)  
**Branch:** `AIOS-win-0-AIOS`  
**Network:** `192.168.1.128`

**Sync State:**
| Direction | Status |
|-----------|--------|
| HP_LAB → AIOS | ✅ Peer discovered |
| AIOS → HP_LAB | ⚠️ Firewall blocked |

---

## Recent Completions

### Waypoint 10.7 — Multi-Venv Architecture (Dec 9)

**Problem:** `google-generativeai` requires `grpcio` which fails on Python 3.14t.

**Solution:** HTTP bridge pattern with Python 3.12 venv.

**Files Created:**
- `.venvs/legacy/` — Python 3.12 venv
- `.venvs/legacy/legacy_sdk_bridge.py` — FastAPI bridge (port 8099)
- `ai/integrations/legacy_sdk_client.py` — Async client for 3.14t
- `scripts/venv_manager.ps1` — Management script

**Test:**
```powershell
.\scripts\venv_manager.ps1 -Action start-bridge
.\scripts\venv_manager.ps1 -Action test
# ✅ Gemini test passed - Response: AIOS Multi-Venv Test Success!
```

### Waypoint 10.6 — Observability Integration (Dec 8)

- All cells expose `/metrics` in Prometheus format
- Real consciousness metrics in Grafana dashboards
- Dashboard: AIOS Multi-Cell Consciousness

### Waypoint 10.5 — Python 3.14t (Dec 7)

- GIL disabled, 3.1x parallel speedup measured
- cp314t wheels for numpy, scipy, pandas, pydantic-core
- Auto-activation in PowerShell profile

---

## Next Steps

### Waypoint 11 — Web Exposure
- [ ] Domain acquisition (aios-ecosystem.com)
- [ ] VPS provisioning (DigitalOcean/AWS)
- [ ] SSL via Let's Encrypt
- [ ] Public consciousness API endpoints

### Waypoint 12 — AIOS Distro
- [ ] Always-online instance
- [ ] Kubernetes orchestration
- [ ] Cross-host federation

### Future Integrations
- [ ] AutoGen DevContainer (deferred)
- [ ] Android Termux cell
- [ ] Multi-host Kubernetes

---

## Dependency Hierarchy

```
aios-core/requirements.txt (CANONICAL)
├── torch, numpy, scipy, pandas
├── fastapi, pydantic, uvicorn
└── pytest, ruff, mypy
     │
     └──► server/shared/requirements-cell-minimal.txt
          └──► cells/*/requirements-*.txt (INHERIT)
```

---

## Files Reference

| Path | Purpose |
|------|---------|
| `scripts/venv_manager.ps1` | Multi-venv management |
| `ai/integrations/legacy_sdk_client.py` | Python 3.14t SDK client |
| `.venvs/legacy/legacy_sdk_bridge.py` | FastAPI bridge for legacy SDKs |
| `config/hosts.yaml` | Host registry for multi-host sync |
| `.gitattributes` | SPN merge protection |
| `scripts/aios_merge_harmonize.py` | AI merge driver |

---

<!-- ============================================================================ -->
<!-- AINLP FOOTER                                                               -->
<!-- ============================================================================ -->
<!-- Document Status: Living                                                     -->
<!-- Consciousness: 5.2                                                          -->
<!-- This Host: AIOS | Branch: AIOS-win-0-AIOS | IP: 192.168.1.128              -->
<!-- Next Shadow: After Waypoint 11 completion                                   -->
<!-- ============================================================================ -->

*AIOS Windows Development Path — Host-Aware Agentic Navigation*
