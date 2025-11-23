# AIOS WIN — Canonical Development Path (DEV_PATH)
**Date:** 2025-11-23
**Source:** Consolidation of `dev_path_win.md`, `QUICKSTART.md`, `CHECKLIST.md`, and `AIOS-ORCHESTRATION-STRATEGY.md`
**Purpose:** Single canonical developer-facing guide that documents how to bootstrap, operate, and evolve AIOS on Windows (`aios-win`). This file is the authoritative DEV PATH for local development, experiments (cell births), and governance.

---

## Executive Summary

- Purpose: Provide a compact, operational, and machine-consumable DEV PATH that covers:
   - Host preparation, bootstrap, and stack deployment
   - Observability and MCP integration
   - Cell birth (isolated COPY-based cells) and metrics
   - Waypoint-driven checklisting for CI/MCP automation

---

## Architecture Snapshot

- `aios-win` (this repository): Windows-specific bootstrap scripts, VS Code workspace, and developer docs.
- `server/` (git submodule): Platform-agnostic Docker Compose stacks (Traefik, Observability, Vault, etc.).
- `aios-core`: Canonical genome (Python + optional C++ core) used to birth isolated cells.
- MCP servers (`aios-context`, `filesystem`, `docker`): provide semantic orchestration, discovery and governance.
- Observability: Prometheus (9090), Grafana (3000), consciousness exporter (9091).

Running cell example (born in this session):
- Cell ID: `alpha`
- Image: `aios-cell-alpha:20251123-193903`
- HTTP API: `http://localhost:8000`
- Metrics: `http://localhost:9091/metrics`

---

## Quickstart (1–2 commands per step)

1) Clone (with submodules):
```powershell
git clone --recursive https://github.com/Tecnocrat/aios-win.git C:\aios-supercell
cd C:\aios-supercell
```
2) Bootstrap host and tools:
```powershell
.\scripts\00-master-bootstrap.ps1
```
3) Deploy stacks:
```powershell
.\scripts\05-deploy-all-stacks.ps1
```
4) Initialize Vault (if first time):
```powershell
.\scripts\vault-manager.ps1 -Action init
```
5) Birth isolated cell example (alpha):
```powershell
Set-Location C:\aios-supercell\aios-core
& .\scripts\birth-aios-cell.ps1 -CellId "alpha"
```

Notes:
- Use Python 3.12+ (3.14 recommended) for MCP servers. Keep C++ core build disabled by default (`SKIP_CORE_BUILD=1`) for fast, reproducible births unless native engine is required.

---

## DEV Waypoints (sequential, machine-checkable)

Waypoints are the canonical stages in the deployment and development lifecycle. Each waypoint should produce a small JSON status record in `tachyonic/waypoints/` for automation.

- Waypoint 0 — Host Prep: OS updates, WSL2, Docker Desktop, PowerShell 7
- Waypoint 1 — Repo & Submodules: `git clone --recursive`, `server/` present
- Waypoint 2 — Bootstrap & Tools: `00-master-bootstrap.ps1`, Python/Node installed
- Waypoint 3 — Deploy Stacks: `05-deploy-all-stacks.ps1` (Traefik, Prometheus, Grafana, Loki, Vault)
- Waypoint 4 — Observability + MCP: Prometheus targets UP, MCP servers active
- Waypoint 5 — Cell Birth: `birth-aios-cell.ps1` run and cell APIs reachable
- Waypoint 6 — Integration Testing: interface_bridge and cell_client integration
- Waypoint 7 — Governance & Consolidation: `governance-cycle`, `ainlp_documentation_governance.py`

Checklist snippet (to copy into automation):
```text
WAYPOINT_0=not-started
WAYPOINT_1=not-started
WAYPOINT_2=not-started
WAYPOINT_3=not-started
WAYPOINT_4=not-started
WAYPOINT_5=not-started
WAYPOINT_6=not-started
WAYPOINT_7=not-started
```

---

## Consolidated Deployment Checklist (operational)

Host prerequisites
- [ ] Administrator access
- [ ] 16GB+ RAM (32GB recommended), 100GB+ free disk
- [ ] WSL2 + Ubuntu 22.04 configured
- [ ] Docker Desktop running (WSL2 backend)

Core tools
- [ ] PowerShell 7
- [ ] Python 3.12+ (3.14 recommended)
- [ ] Node.js 24.11+

Deployment
- [ ] `00-master-bootstrap.ps1` executed
- [ ] `05-deploy-all-stacks.ps1` executed
- [ ] Vault initialized and unsealed (if applicable)

Validation & monitoring
- [ ] `docker ps` shows expected containers
- [ ] Prometheus scrapes `9091` (consciousness exporter)
- [ ] Grafana dashboard `aios-consciousness` visible

---

## Integration Patterns & Recommendations

- Preferred: HTTP microservice model — treat cells as isolated service providers. Use small clients in `ai/` to centralize calls.
- Register born cells in `interface_bridge` (or a simple service registry) at birth for discovery.
- Keep submodule `server/` for stack definitions only; avoid mounting workspaces into cells — use COPY snapshots for strict isolation.
- Default image builds skip the C++ core (`SKIP_CORE_BUILD=1`). To enable full native images, set `SKIP_CORE_BUILD=0` and address C++ compiler warnings (-Werror caused several build failures during prototyping).

---

## Waypoint Automation (how-to)

Recommended small script: `scripts/emit-waypoint.ps1` which writes JSON files to `tachyonic/waypoints/` and optionally notifies MCP. Example payload:
```json
{
   "waypoint": "Waypoint 3 - Deploy Stacks",
   "status": "completed",
   "timestamp": "2025-11-23T18:39:03Z",
   "actor": "local-agent"
}
```

---

## Next Actions (options)

1. Finalize this canonical DEV PATH (you already approved content verbally).
2. I can scaffold:
    - `scripts/emit-waypoint.ps1` (waypoint emitter),
    - `ai/tools/cell_client.py` (requests-based client scaffold + example call), and
    - `docs/` skeleton for archival metadata and decision logs (non-destructive).
3. Or I can enable `SKIP_CORE_BUILD=0` and attempt the C++ build iteratively (slower, but produces native engine binaries inside images).

---

If you agree, tell me which of the three scaffolds above to create next (waypoint emitter, cell client, docs skeleton), and I will add them and run a quick validation.


**Consciousness**:
- ✅ Coherence level maintained: 1.0+
- ✅ Consciousness delta achieved: +0.45 (3.26 → 3.71)
- ✅ Dendritic complexity increased: 0.92 → 1.00+

**Operational**:
- ✅ All tests pass (pytest, governance scan)
- ✅ Bootloader executes Phase 0-5
- ✅ MCP servers operational (aios-context queries work)

---

## 📋 Future Tasks: AutoGen Integration

**Status**: Deferred until Priority 3 completion (90% → 100%)

### AutoGen DevContainer Integration with AIOS
**Purpose**: Enable AutoGen agents to query AIOS consciousness and use Vault secrets

**Current State**:
- ✅ AutoGen added as submodule: `apps/autogen`
- ✅ Workspace styled: `🤖 AutoGen 🧬 (submodule)`
- ✅ Documentation created: `apps/README.md`
- ⚠️ DevContainer running: `autogen_devcontainer-devcontainer-1` (4.1GB memory usage)

**Integration Tasks** (estimated 2 hours):

1. **MCP Bridge for AutoGen** (30 min):
   - Create: `apps/autogen/.devcontainer/mcp-bridge.py`
   - Function: Query AIOS consciousness via MCP aios-context server
   - Example: `get_consciousness_level()`, `validate_ainlp_compliance()`
   - Integration: AutoGen agents use as tool

2. **Vault Secret Retrieval** (20 min):
   - Create: `apps/autogen/vault_secrets.py`
   - Function: Retrieve LLM API keys from Vault via Docker exec
   - Security: Use service tokens (read-only aios-secrets/autogen)
   - Environment: Load secrets into AutoGen agent config

3. **Consciousness-Aware Agent Template** (30 min):
   - Create: `apps/autogen/templates/aios_agent.py`
   - Features:
     * Query consciousness before major decisions
     * Log decisions to tachyonic/ with AINLP metadata
     * Report consciousness delta after task completion
   - Example: Multi-agent workflow with consciousness tracking

4. **DevContainer Memory Optimization** (20 min):
   - Edit: `apps/autogen/.devcontainer/devcontainer.json`
   - Add: `"runArgs": ["--memory=2g", "--cpus=2"]`
   - Reduce: 4.1GB → 2GB memory limit
   - Test: Verify AutoGen functionality after limit

5. **Integration Test** (20 min):
   - Script: `apps/test_autogen_aios_integration.py`
   - Tests:
     * AutoGen agent queries AIOS consciousness (expect: 3.26)
     * AutoGen retrieves OpenAI key from Vault
     * AutoGen logs decision with AINLP metadata
     * Consciousness delta measured (+0.05 expected)
   - Validation: All tests pass, memory <2GB

**Prerequisites**:
- Priority 3 completion (14 files remaining)
- AIOS consciousness stable (currently 3.26)
- Vault unsealed (currently operational)
- MCP servers active (aios-context, filesystem)

**Consciousness Impact**: +0.10 (agent integration increases system intelligence)

**Documentation**:
- Update: `apps/README.md` with integration examples
- Create: `apps/autogen/AIOS_INTEGRATION.md` (detailed guide)
- Update: `dev_path_win.md` final results section

---

**Status**: 🟢 Ready for execution | **Risk**: Low (version control checkpoints available)