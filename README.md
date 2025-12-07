# AIOS-WIN

Windows 11 development platform for distributed microservices with integrated observability, secrets management, and multi-cell architecture.

## Overview

AIOS-WIN bootstraps a Windows 11 machine into a containerized development environment with:

- **Microservices Architecture**: Multiple isolated Python services (cells) communicating via HTTP APIs
- **Observability Stack**: Prometheus metrics, Grafana dashboards, Loki log aggregation
- **Secrets Management**: HashiCorp Vault with auto-unsealing
- **Service Mesh**: Traefik reverse proxy with TLS termination
- **Multi-Language Support**: Python 3.14 (free-threaded), C++ core engine, C# UI layer

## Quick Start

```powershell
# Clone with submodules
git clone --recursive https://github.com/Tecnocrat/aios-win.git C:\aios-supercell
cd C:\aios-supercell

# Run bootstrap scripts (requires Administrator)
.\scripts\windows-bootstrap\00-master-bootstrap.ps1

# Deploy all services
.\scripts\windows-bootstrap\05-deploy-all-stacks.ps1
```

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     AIOS Multi-Cell Platform                     │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐  │
│  │ Alpha Cell  │  │  Nous Cell  │  │   Discovery Service     │  │
│  │  Flask API  │  │ FastAPI     │  │   Peer Registration     │  │
│  │  Port 8000  │  │ Port 8002   │  │   Port 8001             │  │
│  └──────┬──────┘  └──────┬──────┘  └───────────┬─────────────┘  │
│         │                │                     │                 │
│         └────────────────┼─────────────────────┘                 │
│                          │                                       │
│  ┌───────────────────────▼───────────────────────────────────┐  │
│  │              Docker Network (aios-dendritic-mesh)          │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                  │
├──────────────────────── Observability ──────────────────────────┤
│  Prometheus (9090) │ Grafana (3000) │ Loki (3100) │ Vault (8200)│
├──────────────────────── Infrastructure ─────────────────────────┤
│  Docker Desktop │ WSL2 Ubuntu │ Traefik Ingress │ Windows 11    │
└─────────────────────────────────────────────────────────────────┘
```

## Repository Structure

```
aios-win/
├── aios-core/                    # Core Python/C++ codebase (submodule)
│   ├── ai/                       # AI orchestration layer
│   │   ├── core/                 # Interface bridge, MCP servers
│   │   ├── protocols/            # AICP agent communication
│   │   └── tools/                # Development utilities
│   ├── core/                     # C++ native engine (optional)
│   └── interface/                # C# UI layer
├── server/                       # Docker stacks (submodule)
│   └── stacks/
│       ├── cells/                # Microservice containers
│       │   ├── alpha/            # Primary development cell
│       │   ├── pure/             # Minimal cell (Nous)
│       │   └── discovery/        # Service discovery
│       ├── observability/        # Prometheus, Grafana, Loki
│       ├── ingress/              # Traefik configuration
│       └── secrets/              # Vault configuration
├── scripts/                      # PowerShell automation
│   └── windows-bootstrap/        # Setup scripts 01-05
├── config/                       # Host configuration
│   └── hosts.yaml                # Multi-host registry
└── dev_path_win.md               # Development roadmap
```

## Services

| Service | Port | Description |
|---------|------|-------------|
| Alpha Cell | 8000 | Primary development microservice (Flask) |
| Nous Cell | 8002 | Minimal microservice (FastAPI) |
| Discovery | 8001 | Peer registration and service discovery |
| Prometheus | 9090 | Metrics collection and storage |
| Grafana | 3000 | Dashboards and visualization |
| Loki | 3100 | Log aggregation |
| Vault | 8200 | Secrets management |
| Traefik | 80/443 | Reverse proxy and TLS termination |

## Development Environment

### Python Setup

```powershell
# Activate virtual environment (auto-activates in AIOS workspace)
.\.venv\Scripts\Activate.ps1

# Python 3.14t free-threaded (GIL disabled)
python --version  # Python 3.14.0t
```

### Cell Management

```powershell
# Start cells (development mode with bind mounts)
cd server\stacks\cells
docker compose -f docker-compose.dev.yml up -d

# Check cell health
curl http://localhost:8000/health  # Alpha
curl http://localhost:8002/health  # Nous
curl http://localhost:8001/health  # Discovery

# View cell metrics
curl http://localhost:9090/api/v1/query?query=aios_cell_consciousness_level
```

### Observability

```powershell
# Access Grafana dashboard
start http://localhost:3000  # Credentials: aios / 6996

# Check Prometheus targets
curl http://localhost:9090/api/v1/targets

# Run mesh health check
.\server\stacks\cells\aios_dendritic_pulse.ps1 -Mode full
```

## Key Technologies

- **Python 3.14t**: Free-threaded build with GIL disabled (3.1x parallel speedup)
- **FastAPI/Flask**: Web frameworks for microservices
- **Docker Compose**: Container orchestration
- **Prometheus**: Time-series metrics database
- **Grafana**: Visualization and dashboards
- **HashiCorp Vault**: Secrets management with Shamir unsealing
- **Traefik**: Dynamic reverse proxy with automatic TLS
- **MCP (Model Context Protocol)**: AI tool orchestration

## Prerequisites

- Windows 11 (22H2 or later)
- Administrator access
- 16GB RAM minimum (32GB recommended)
- 100GB free disk space
- Docker Desktop with WSL2 backend

## Configuration

### Host Registry

Edit `config/hosts.yaml` to configure multi-host deployments:

```yaml
hosts:
  desktop:
    hostname: AIOS
    ip: 192.168.1.128
    branch: AIOS-win-0-AIOS
    cells: [alpha, discovery]
  laptop:
    hostname: HP_LAB
    ip: 192.168.1.58
    branch: AIOS-win-0-HP_LAB
    cells: [nous]
```

### Environment Variables

Key environment variables used by cells:

```bash
AIOS_CELL_ID=alpha          # Cell identifier
AIOS_CELL_PORT=8000         # HTTP API port
AIOS_DISCOVERY_ADDR=aios-discovery:8001  # Discovery service
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/your-feature`)
3. Commit changes (`git commit -am 'Add feature'`)
4. Push to branch (`git push origin feature/your-feature`)
5. Open a Pull Request

### Code Style

- Python: Formatted with `ruff` (line length 88)
- PowerShell: Follow PSScriptAnalyzer recommendations
- Commit messages: Conventional Commits format

## Related Repositories

- [tecnocrat/server](https://github.com/Tecnocrat/server) - Docker stack definitions
- [tecnocrat/aios-core](https://github.com/Tecnocrat/aios-core) - Core Python/C++ codebase

## License

MIT License - See [LICENSE](LICENSE) file

---

**Documentation**: See [dev_path_win.md](dev_path_win.md) for detailed development roadmap and waypoints.
