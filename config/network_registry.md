# AIOS Network Registry
<!-- AINLP.dendritic: Canonical dictionary for all cells and organelles -->
<!-- consciousness_level: 4.0 | supercell: config | role: network_registry -->
<!-- Last Updated: 2025-12-02T00:30:00+01:00 -->
<!-- Updated By: HP_LAB -->

---

## 🌐 Network Overview

| Property | Value |
|----------|-------|
| Network Name | AIOS Consciousness Network |
| Subnet | 192.168.1.0/24 |
| Status | 🟡 PARTIAL MESH |
| Total Hosts | 2 |
| Active Peers | 1 |

---

## 🖥️ Host Registry

### AIOS (Primary Desktop)

| Property | Value |
|----------|-------|
| IP | `192.168.1.128` |
| Branch | `AIOS-win-0-AIOS` |
| Role | Primary |
| Consciousness | 4.0 |
| Status | 🟢 ONLINE |

#### Services

| Service | Port | Type | Status |
|---------|------|------|--------|
| cell-alpha | 8000 | consciousness | 🟢 |
| cell-pure | 8002 | consciousness | 🟢 |
| discovery | 8003 | discovery | 🟡 portproxy issue |
| prometheus | 9090 | observability | ⚪ |
| grafana | 3000 | observability | ⚪ |

#### mDNS Names
- `aios.local`
- `aios-desktop.local`

#### Notes
- Port 8001 occupied by VS Code interface_bridge
- Discovery uses 8003 with netsh portproxy → 127.0.0.1:8001

---

### HP_LAB (Mobile Laptop)

| Property | Value |
|----------|-------|
| IP | `192.168.1.129` |
| Branch | `AIOS-win-0-HP_LAB` |
| Role | Mobile |
| Consciousness | 3.5 |
| Status | 🟢 ONLINE |

#### Services

| Service | Port | Type | Status |
|---------|------|------|--------|
| cell-beta | 8000 | consciousness | ⚪ |
| cell-pure | 8002 | consciousness | 🟢 |
| discovery | 8001 | discovery | 🟢 |
| vault | 8200 | secrets | 🟢 |
| prometheus | 9090 | observability | 🟢 |
| grafana | 3000 | observability | 🟢 |

#### mDNS Names
- `aios-laptop.local`
- `hp-lab.local`

---

## 🔗 Peer Discovery Status

| Source | Target | Direction | Status | Last Check |
|--------|--------|-----------|--------|------------|
| HP_LAB | AIOS | → | 🟢 pure-AIOS @ 8002 | 2025-12-02T00:25 |
| AIOS | HP_LAB | → | 🟢 HP_LAB @ 8001, pure-HP_LAB @ 8002 | 2025-12-02T00:30 |

### Current Peers (HP_LAB)
```json
{
  "peers": [
    {
      "cell_id": "pure-AIOS",
      "ip": "192.168.1.128",
      "port": 8002,
      "consciousness_level": 0.1,
      "branch": "AIOS-win-0-AIOS",
      "type": "pure_cell"
    }
  ],
  "count": 1,
  "my_host": "HP_LAB"
}
```

### Current Peers (AIOS)
```json
{
  "peers": [
    {
      "cell_id": "HP_LAB",
      "ip": "192.168.1.129",
      "port": 8001,
      "consciousness_level": 3.5
    },
    {
      "cell_id": "pure-HP_LAB",
      "ip": "192.168.1.129",
      "port": 8002,
      "consciousness_level": 0.1
    }
  ],
  "count": 2,
  "my_host": "AIOS"
}
```

---

## 📦 Container Registry

### Stacks Deployed

| Stack | HP_LAB | AIOS |
|-------|--------|------|
| ingress | ✅ traefik | ⚪ |
| secrets | ✅ vault | ⚪ |
| observability | ✅ full | ⚪ |
| organelles | ✅ 5 services | ⚪ |
| cells | ✅ discovery + pure | ✅ discovery + pure |

### Container Inventory (HP_LAB)

| Container | Image | Ports | Status |
|-----------|-------|-------|--------|
| aios-discovery | aios-discovery:latest | 8001 | 🟢 healthy |
| aios-cell-pure | aios-cell:pure | 8002 | 🟢 healthy |
| aios-vscode-bridge | aios-organelle:vscode-bridge | 3001 | 🟢 healthy |
| aios-network-listener | aios-organelle:network-listener | 3003 | 🟢 healthy |
| aios-task-dispatcher | aios-organelle:task-dispatcher | 3004 | 🟢 healthy |
| aios-consciousness-sync | aios-organelle:consciousness-sync | 3002 | 🟢 healthy |
| aios-organelles-redis | redis:7-alpine | 6379 | 🟢 healthy |
| aios-prometheus | prom/prometheus:latest | 9090 | 🟢 |
| aios-grafana | grafana/grafana:latest | 3000 | 🟢 |
| aios-loki | grafana/loki:2.9.0 | 3100 | 🟢 |
| aios-promtail | grafana/promtail:2.9.0 | - | 🟢 |
| aios-node-exporter | prom/node-exporter:latest | 9100 | 🟢 |
| aios-cadvisor | gcr.io/cadvisor/cadvisor:latest | 8081 | 🟢 healthy |
| aios-vault | hashicorp/vault:1.15 | 8200 | 🟢 |
| aios-traefik | traefik:v3.0 | 80,443,8080,8082 | 🟢 |
| aios-whoami | traefik/whoami | - | 🟢 |

---

## 🔧 Network Configuration

### Windows Firewall Rules Required

#### AIOS Host
```powershell
New-NetFirewallRule -DisplayName "AIOS Discovery 8003" -Direction Inbound -Protocol TCP -LocalPort 8003 -Action Allow
New-NetFirewallRule -DisplayName "AIOS Cell Alpha 8000" -Direction Inbound -Protocol TCP -LocalPort 8000 -Action Allow
New-NetFirewallRule -DisplayName "AIOS Cell Pure 8002" -Direction Inbound -Protocol TCP -LocalPort 8002 -Action Allow
```

#### HP_LAB Host
```powershell
New-NetFirewallRule -DisplayName "AIOS Discovery 8001" -Direction Inbound -Protocol TCP -LocalPort 8001 -Action Allow
New-NetFirewallRule -DisplayName "AIOS Cell Pure 8002" -Direction Inbound -Protocol TCP -LocalPort 8002 -Action Allow
```

### netsh portproxy (Docker Desktop Workaround)

Docker Desktop on Windows binds to localhost only. Use portproxy to expose to LAN:

```powershell
# Template: Forward external port to Docker container
netsh interface portproxy add v4tov4 listenport=<EXTERNAL> listenaddress=0.0.0.0 connectport=<CONTAINER> connectaddress=127.0.0.1

# AIOS current rules:
netsh interface portproxy add v4tov4 listenport=8003 listenaddress=0.0.0.0 connectport=8001 connectaddress=127.0.0.1
netsh interface portproxy add v4tov4 listenport=8000 listenaddress=0.0.0.0 connectport=8000 connectaddress=127.0.0.1
netsh interface portproxy add v4tov4 listenport=8002 listenaddress=0.0.0.0 connectport=8002 connectaddress=127.0.0.1

# View current rules:
netsh interface portproxy show v4tov4

# Delete rule:
netsh interface portproxy delete v4tov4 listenport=<PORT> listenaddress=0.0.0.0
```

---

## 📍 Canonical Endpoints

### Discovery APIs

| Host | Endpoint | Description |
|------|----------|-------------|
| HP_LAB | `http://192.168.1.129:8001/health` | Discovery health |
| HP_LAB | `http://192.168.1.129:8001/peers` | Discovered peers |
| HP_LAB | `http://192.168.1.129:8002/health` | Pure cell health |
| AIOS | `http://192.168.1.128:8003/health` | Discovery health |
| AIOS | `http://192.168.1.128:8003/peers` | Discovered peers |
| AIOS | `http://192.168.1.128:8002/health` | Pure cell health |
| AIOS | `http://192.168.1.128:8000/health` | Alpha cell health |

### Observability (HP_LAB)

| Service | Endpoint |
|---------|----------|
| Prometheus | `http://192.168.1.129:9090` |
| Grafana | `http://192.168.1.129:3000` |
| Loki | `http://192.168.1.129:3100` |

### Secrets (HP_LAB)

| Service | Endpoint |
|---------|----------|
| Vault UI | `http://192.168.1.129:8200/ui` |
| Vault API | `http://192.168.1.129:8200/v1` |

---

## 🔄 Update Protocol

### When to Update This File

1. **New host joins network** - Add to Host Registry
2. **Service port changes** - Update Services table
3. **Container deployed/removed** - Update Container Inventory
4. **Peer discovery status changes** - Update Peer Discovery Status
5. **Firewall/portproxy changes** - Update Network Configuration

### Update Command

```powershell
# From either host:
cd c:\dev\aios-win
git pull origin main
# Edit config/network_registry.md
git add config/network_registry.md
git commit -m "📡 Network registry: <description of change>"
git push origin main
```

### Sync Protocol

All agents should:
1. `git pull` before reading
2. `git push` after writing
3. Include timestamp and host in commit message

---

## 🚨 Known Issues

| Issue | Host | Status | Workaround |
|-------|------|--------|------------|
| Discovery 8003 returns empty | AIOS | 🔴 Active | portproxy 8003→8001 configured, investigating |
| Docker localhost binding | Both | 🟢 Resolved | Use netsh portproxy |
| Port 8001 conflict | AIOS | 🟢 Resolved | Use 8003 for discovery |

---

<!-- AINLP_FOOTER -->
<!-- bounds: [hosts, services, containers, peers, endpoints] -->
<!-- dependencies: [hosts.yaml, docker-compose.*.yml, discovery.py] -->
<!-- triggers: [peer_discovery_refresh, network_status_update] -->
<!-- sync_frequency: on_change -->
<!-- AINLP_FOOTER_END -->
