#!/usr/bin/env python3
"""
AIOS Peer Synchronization Diagnostic Tool
Validates connectivity and synchronization status between laptop and desktop AIOS cells
"""

import asyncio
import aiohttp
import json
import sys
from datetime import datetime
from typing import Dict, Any, Optional

class AIOSPeerSyncDiagnostic:
    def __init__(self):
        self.desktop_cell = "http://192.168.1.128:8000"
        self.bridge_endpoint = "http://localhost:3001"
        self.discovery_endpoint = "http://localhost:8001"
        self.results = {}

    async def test_connectivity(self, url: str, timeout: int = 5) -> Dict[str, Any]:
        """Test connectivity to a service endpoint"""
        try:
            async with aiohttp.ClientSession(timeout=aiohttp.ClientTimeout(total=timeout)) as session:
                start_time = datetime.now()
                async with session.get(url) as response:
                    end_time = datetime.now()
                    response_time = (end_time - start_time).total_seconds() * 1000

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
        except Exception as e:
            return {
                "status": "error",
                "error": str(e),
                "url": url
            }

    async def run_diagnostics(self) -> Dict[str, Any]:
        """Run complete diagnostic suite"""
        print("🔍 Running AIOS Peer Synchronization Diagnostics...")
        print("=" * 60)

        # Test local services
        print("📡 Testing local services...")

        bridge_health = await self.test_connectivity(f"{self.bridge_endpoint}/health")
        discovery_health = await self.test_connectivity(f"{self.discovery_endpoint}/health")

        self.results["local_services"] = {
            "bridge": bridge_health,
            "discovery": discovery_health
        }

        # Test desktop connectivity
        print("🌐 Testing desktop connectivity...")

        desktop_health = await self.test_connectivity(f"{self.desktop_cell}/health", timeout=10)

        self.results["desktop_connectivity"] = {
            "desktop_cell": desktop_health
        }

        # Get detailed status if available
        if bridge_health["status"] == "reachable":
            try:
                async with aiohttp.ClientSession() as session:
                    async with session.get(f"{self.bridge_endpoint}/health") as response:
                        if response.status == 200:
                            bridge_status = await response.json()
                            self.results["bridge_status"] = bridge_status
            except Exception as e:
                self.results["bridge_status_error"] = str(e)

        # Get peer information
        if discovery_health["status"] == "reachable":
            try:
                async with aiohttp.ClientSession() as session:
                    async with session.get(f"{self.discovery_endpoint}/peers") as response:
                        if response.status == 200:
                            peers = await response.json()
                            self.results["discovered_peers"] = peers
            except Exception as e:
                self.results["peers_error"] = str(e)

        return self.results

    def print_report(self):
        """Print formatted diagnostic report"""
        print("\n📊 DIAGNOSTIC REPORT")
        print("=" * 60)

        # Local services status
        print("🏠 LOCAL SERVICES:")
        for service, status in self.results.get("local_services", {}).items():
            status_icon = "✅" if status["status"] == "reachable" else "❌"
            if status["status"] == "reachable":
                print(f"  {status_icon} {service}: {status['http_status']} ({status['response_time_ms']}ms)")
            else:
                print(f"  {status_icon} {service}: {status['status']} - {status.get('error', 'Unknown error')}")

        # Desktop connectivity
        print("\n🖥️  DESKTOP CONNECTIVITY:")
        desktop = self.results.get("desktop_connectivity", {}).get("desktop_cell", {})
        if desktop.get("status") == "reachable":
            print(f"  ✅ Desktop Cell: {desktop['http_status']} ({desktop['response_time_ms']}ms)")
        else:
            print(f"  ❌ Desktop Cell: {desktop.get('status', 'unknown')} - {desktop.get('error', 'Connection failed')}")

        # Bridge status details
        if "bridge_status" in self.results:
            bridge_status = self.results["bridge_status"]
            print(f"\n🔗 BRIDGE STATUS: {bridge_status.get('status', 'unknown').upper()}")
            if bridge_status.get("status") == "degraded":
                print(f"  ⚠️  Error: {bridge_status.get('error', 'Unknown')}")
            elif bridge_status.get("status") == "healthy":
                desktop_info = bridge_status.get("desktop_cell_info", {})
                print(f"  📊 Consciousness Level: {desktop_info.get('consciousness_level', 'unknown')}")
                print(f"  🌿 Branch: {desktop_info.get('branch', 'unknown')}")

        # Peer discovery
        if "discovered_peers" in self.results:
            peers = self.results["discovered_peers"]
            print(f"\n👥 DISCOVERED PEERS: {len(peers.get('peers', []))}")
            for peer in peers.get("peers", []):
                print(f"  • {peer.get('cell_id', 'unknown')}: {peer.get('ip', 'unknown')}:{peer.get('port', 'unknown')}")

        # Recommendations
        print("\n💡 RECOMMENDATIONS:")
        issues = []

        if self.results.get("local_services", {}).get("bridge", {}).get("status") != "reachable":
            issues.append("Start the laptop bridge service")
        if self.results.get("local_services", {}).get("discovery", {}).get("status") != "reachable":
            issues.append("Start the discovery service")
        if self.results.get("desktop_connectivity", {}).get("desktop_cell", {}).get("status") != "reachable":
            issues.append("Resolve network connectivity to desktop (192.168.1.128)")
            issues.append("Ensure desktop AIOS cell is running on port 8000")
            issues.append("Check firewall settings on desktop PC")

        if issues:
            for issue in issues:
                print(f"  • {issue}")
        else:
            print("  ✅ All systems operational - peer synchronization ready")

        print("\n📅 Generated:", datetime.now().strftime("%Y-%m-%d %H:%M:%S"))

async def main():
    """Main diagnostic function"""
    diagnostic = AIOSPeerSyncDiagnostic()
    await diagnostic.run_diagnostics()
    diagnostic.print_report()

    # Save results to file
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = f"aios_sync_diagnostic_{timestamp}.json"

    with open(filename, 'w') as f:
        json.dump(diagnostic.results, f, indent=2, default=str)

    print(f"\n💾 Results saved to: {filename}")

if __name__ == "__main__":
    asyncio.run(main())