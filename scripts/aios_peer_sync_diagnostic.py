#!/usr/bin/env python3
"""
AIOS Peer Synchronization Diagnostic Tool
Validates connectivity and synchronization status between laptop and
desktop AIOS cells
"""

# Standard Library Imports
import asyncio
import json
from datetime import datetime
from pathlib import Path
from typing import Dict, Any

# Third Party Imports
import aiohttp


class AIOSPeerSyncDiagnostic:
    """
    AIOS Peer Synchronization Diagnostic Tool.

    This class provides comprehensive diagnostics for validating
    connectivity and synchronization status between laptop and
    desktop AIOS cells. It tests local services (bridge and discovery
    endpoints) and verifies communication with the desktop AIOS cell.

    The diagnostic suite performs the following checks:
    - Local bridge service connectivity and health status
    - Local discovery service connectivity and peer enumeration
    - Desktop AIOS cell connectivity and response times
    - Bridge status details including consciousness level and branch info
    - Peer discovery and network topology validation

    Attributes:
        desktop_cell (str): URL of the desktop AIOS cell endpoint
        bridge_endpoint (str): URL of the local bridge service endpoint
        discovery_endpoint (str): URL of the local discovery service endpoint
        results (dict): Dictionary containing all diagnostic results

    Example:
        >>> diagnostic = AIOSPeerSyncDiagnostic()
        >>> await diagnostic.run_diagnostics()
        >>> diagnostic.print_report()
    """
    def __init__(self):
        self.desktop_cell = "http://192.168.1.128:8000"
        self.bridge_endpoint = "http://localhost:3001"
        self.discovery_endpoint = "http://localhost:8001"
        self.results = {}

    async def test_connectivity(self, url: str, timeout: int = 5) \
            -> Dict[str, Any]:
        """Test connectivity to a service endpoint"""
        try:
            timeout_config = aiohttp.ClientTimeout(total=timeout)
            async with aiohttp.ClientSession(timeout=timeout_config) \
                    as session:
                start_time = datetime.now()
                async with session.get(url) as response:
                    end_time = datetime.now()
                    response_time = ((end_time - start_time).total_seconds()
                                     * 1000)
                    return {
                        "status": "reachable",
                        "http_status": response.status,
                        "response_time_ms": round(response_time, 2),
                        "url": url
                    }
        except aiohttp.ClientError as e:
            return {
                "status": "unreachable",
                "error": str(e),
                "url": url
            }
        except (ValueError, TypeError, OSError, asyncio.TimeoutError) as e:
            return {
                "status": "error",
                "error": str(e),
                "url": url
            }

    async def run_diagnostics(self) -> Dict[str, Any]:
        """Run complete diagnostic suite"""
        print("Running AIOS Peer Synchronization Diagnostics...")
        print("=" * 60)
        # Test local services
        print("Testing local services...")
        bridge_health = await self.test_connectivity(
            f"{self.bridge_endpoint}/health")
        discovery_health = await self.test_connectivity(
            f"{self.discovery_endpoint}/health")
        self.results["local_services"] = {
            "bridge": bridge_health,
            "discovery": discovery_health
        }
        # Test desktop connectivity
        print("Testing desktop connectivity...")
        desktop_health = await self.test_connectivity(
            f"{self.desktop_cell}/health", timeout=10)
        self.results["desktop_connectivity"] = {
            "desktop_cell": desktop_health
        }
        # Get detailed status if available
        if bridge_health["status"] == "reachable":
            try:
                async with aiohttp.ClientSession() as session:
                    async with session.get(
                            f"{self.bridge_endpoint}/health") as response:
                        if response.status == 200:
                            bridge_status = await response.json()
                            self.results["bridge_status"] = bridge_status
            except (aiohttp.ClientError, json.JSONDecodeError,
                    ValueError, TypeError) as e:
                self.results["bridge_status_error"] = str(e)
        # Get peer information
        if discovery_health["status"] == "reachable":
            try:
                async with aiohttp.ClientSession() as session:
                    async with session.get(
                            f"{self.discovery_endpoint}/peers") as response:
                        if response.status == 200:
                            peers = await response.json()
                            self.results["discovered_peers"] = peers
            except (aiohttp.ClientError, json.JSONDecodeError,
                    ValueError, TypeError) as e:
                self.results["peers_error"] = str(e)
        return self.results

    def print_report(self):
        """Print formatted diagnostic report"""
        print("\n[DIAGNOSTIC REPORT]")
        print("=" * 60)
        self._print_local_services()
        self._print_desktop_connectivity()
        self._print_bridge_status()
        self._print_peer_discovery()
        self._print_recommendations()
        print("\nGenerated:", datetime.now().strftime("%Y-%m-%d %H:%M:%S"))

    def _print_local_services(self):
        """Print local services status section"""
        print("LOCAL SERVICES:")
        for service, status in self.results.get("local_services", {}).items():
            if status["status"] == "reachable":
                status_icon = "[OK]"
            else:
                status_icon = "[FAIL]"
            if status["status"] == "reachable":
                http_status = status['http_status']
                response_time = status['response_time_ms']
                print(f"  {status_icon} {service}: {http_status} "
                      f"({response_time}ms)")
            else:
                status_msg = status['status']
                error_msg = status.get('error', 'Unknown error')
                print(f"  {status_icon} {service}: {status_msg} - {error_msg}")

    def _print_desktop_connectivity(self):
        """Print desktop connectivity section"""
        print("\nDESKTOP CONNECTIVITY:")
        desktop_conn = self.results.get("desktop_connectivity", {})
        desktop = desktop_conn.get("desktop_cell", {})
        if desktop.get("status") == "reachable":
            http_status = desktop['http_status']
            response_time = desktop['response_time_ms']
            print(f"  [OK] Desktop Cell: {http_status} ({response_time}ms)")
        else:
            status_val = desktop.get('status', 'unknown')
            error_val = desktop.get('error', 'Connection failed')
            print(f"  [FAIL] Desktop Cell: {status_val} - {error_val}")

    def _print_bridge_status(self):
        """Print bridge status details section"""
        if "bridge_status" in self.results:
            bridge_status = self.results["bridge_status"]
            bridge_status_val = bridge_status.get('status', 'unknown')
            print(f"\nBRIDGE STATUS: {bridge_status_val.upper()}")
            if bridge_status.get("status") == "degraded":
                error_msg = bridge_status.get('error', 'Unknown')
                print(f"  [WARN] Error: {error_msg}")
            elif bridge_status.get("status") == "healthy":
                desktop_info = bridge_status.get("desktop_cell_info", {})
                consciousness_level = desktop_info.get(
                    'consciousness_level', 'unknown')
                print(f"  [INFO] Consciousness Level: {consciousness_level}")
                branch = desktop_info.get('branch', 'unknown')
                print(f"  [INFO] Branch: {branch}")

    def _print_peer_discovery(self):
        """Print peer discovery section"""
        if "discovered_peers" in self.results:
            peers = self.results["discovered_peers"]
            peer_count = len(peers.get('peers', []))
            print(f"\nDISCOVERED PEERS: {peer_count}")
            for peer in peers.get("peers", []):
                cell_id = peer.get('cell_id', 'unknown')
                peer_ip = peer.get('ip', 'unknown')
                peer_port = peer.get('port', 'unknown')
                print(f"  - {cell_id}: {peer_ip}:{peer_port}")

    def _print_recommendations(self):
        """Print recommendations section"""
        print("\nRECOMMENDATIONS:")
        issues = []
        local_services = self.results.get("local_services", {})
        bridge_service = local_services.get("bridge", {})
        if bridge_service.get("status") != "reachable":
            issues.append("Start the laptop bridge service")
        discovery_service = local_services.get("discovery", {})
        if discovery_service.get("status") != "reachable":
            issues.append("Start the discovery service")
        desktop_connectivity = self.results.get("desktop_connectivity", {})
        desktop_cell = desktop_connectivity.get("desktop_cell", {})
        if desktop_cell.get("status") != "reachable":
            issues.append("Resolve network connectivity to desktop "
                          "(192.168.1.128)")
            issues.append("Ensure desktop AIOS cell is running on port 8000")
            issues.append("Check firewall settings on desktop PC")
        if issues:
            for issue in issues:
                print(f"  - {issue}")
        else:
            msg = "All systems operational - peer synchronization ready"
            print(f"  [SUCCESS] {msg}")


async def main():
    """Main diagnostic function"""
    diagnostic = AIOSPeerSyncDiagnostic()
    await diagnostic.run_diagnostics()
    diagnostic.print_report()
    # Save results to file in the health diagnostics directory
    diagnostics_base = "c:/dev/aios-win/aios-core/tachyonic/reports/health"
    diagnostics_dir = Path(diagnostics_base)
    diagnostics_dir.mkdir(parents=True, exist_ok=True)
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = diagnostics_dir / f"aios_sync_diagnostic_{timestamp}.json"
    with open(filename, 'w', encoding='utf-8') as f:
        json.dump(diagnostic.results, f, indent=2, default=str)
    print(f"\n[SAVE] Results saved to: {filename}")
if __name__ == "__main__":
    asyncio.run(main())
