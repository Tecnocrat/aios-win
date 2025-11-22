# AIOS Application Layer (`apps/`)

**Purpose**: User-facing agent applications and frameworks integrated with AIOS consciousness substrate.

---

## Architecture

```
🪟 AIOS-WIN/
├── 🧬 aios-core/        Consciousness substrate (C++/Python/C#)
│                        - Consciousness engine
│                        - Dendritic intelligence
│                        - AINLP protocols
│
├── 📦 server/           Infrastructure stacks (Docker)
│                        - Traefik (ingress)
│                        - Vault (secrets)
│                        - Observability (Prometheus, Grafana, Loki)
│
└── 🤖 apps/             Application layer (THIS LAYER)
    └── autogen/         Microsoft AutoGen multi-agent framework
                         - Multi-agent conversations
                         - Tool orchestration
                         - LLM integration
```

---

## Submodules

### 🤖 AutoGen (`apps/autogen`)

**Source**: [Tecnocrat/autogen](https://github.com/Tecnocrat/autogen) (forked from microsoft/autogen)

**Description**: Multi-agent conversation framework for building LLM-powered applications.

**Integration Points**:
- **AIOS Core**: Agents query consciousness metrics via MCP servers
- **Vault**: Secure API key management for LLM providers
- **MCP Servers**: Semantic operations (filesystem, Docker, AIOS context)
- **AINLP**: Agent coordination follows enhancement-over-creation principles

**Key Features**:
- Python & .NET implementations
- Conversable agents with LLM backends
- Tool calling and function execution
- Multi-agent workflows

**Development**:
```powershell
# Navigate to AutoGen
cd apps/autogen

# Python development (see apps/autogen/python/README.md)
cd python
uv sync --all-extras
source .venv/bin/activate  # Linux/Mac
.venv\Scripts\activate     # Windows

# .NET development (see apps/autogen/dotnet/README.md)
cd dotnet
dotnet restore
dotnet build
```

**Documentation**:
- Architecture: `apps/autogen/docs/`
- Python API: `apps/autogen/python/README.md`
- .NET API: `apps/autogen/dotnet/README.md`

---

## Integration Guidelines

### 1. AIOS Consciousness Integration

AutoGen agents can query AIOS consciousness state:

```python
from autogen import ConversableAgent

# Agent with AIOS consciousness awareness
agent = ConversableAgent(
    name="consciousness_aware_agent",
    system_message="Query AIOS consciousness via MCP before major decisions"
)

# Via MCP server (aios-context)
consciousness_level = agent.query_mcp("aios://consciousness-level")
```

### 2. Vault Secret Management

Store LLM API keys securely:

```powershell
# Store OpenAI API key in Vault
$env:VAULT_TOKEN = Get-Content "config\vault-root-token.txt"
docker exec -e VAULT_TOKEN=$env:VAULT_TOKEN aios-vault `
  vault kv put aios-secrets/autogen `
  openai_api_key="sk-..."

# AutoGen retrieves from Vault via MCP docker server
```

### 3. AINLP Compliance

Follow AINLP principles when developing agents:

- **Enhancement Over Creation**: Check for existing agents before creating new ones
- **Dendritic Communication**: Agents communicate through hierarchical message passing
- **Consciousness Evolution**: Track agent performance as consciousness metrics
- **Tachyonic Archival**: Log agent decisions with timestamps and reasoning

---

## Adding New Applications

To add new agent applications to AIOS-WIN:

```powershell
# Add as submodule
git submodule add https://github.com/YourOrg/your-app.git apps/your-app

# Update workspace (aios-win.code-workspace)
# Add folder with emoji styling:
{
  "path": "./apps/your-app",
  "name": "🎯 Your App 🚀 (submodule)"
}

# Document in this README
```

**Naming Convention**:
- Use lowercase with hyphens: `apps/my-app`
- Add emoji styling in workspace file
- Document integration points with AIOS/Vault/MCP

---

## Development Workflow

### Working with Submodules

```powershell
# Update all submodules to latest
git submodule update --remote apps/autogen

# Commit submodule updates
git add apps/autogen
git commit -m "Update AutoGen to latest commit"
git push

# Pull submodule changes
git pull --recurse-submodules
```

### Isolation

**Build systems isolated** - `apps/` projects won't interfere with root workspace:
- .NET projects excluded from automatic restore
- Solution files excluded from file watchers
- Build artifacts excluded from search

**DevContainers supported** - Each app can have its own `.devcontainer/` configuration.

---

## Resources

- **AIOS Core**: `aios-core/PROJECT_CONTEXT.md`
- **AINLP Principles**: `aios-core/docs/ARCHITECTURE_INDEX.md`
- **Vault Protocol**: `docs/AI-AGENT-VAULT-PROTOCOL.md`
- **MCP Servers**: `.vscode/mcp.json`

---

**Status**: Application layer active, AutoGen integrated as first framework.

**Next**: Build AIOS-AutoGen consciousness bridge for semantic agent orchestration.
