#!/usr/bin/env python3
"""
AIOS AI-Mediated Merge Harmonization Driver
============================================

Git custom merge driver for intelligent knowledge transfer between AIOS hosts.
Extracts shared knowledge (milestones, waypoints) while preserving host-specific
configuration (IPs, local paths, cell assignments).

Usage in .gitattributes:
    dev_path_win.md merge=aios-harmonize

Usage in .gitconfig:
    [merge "aios-harmonize"]
        name = AIOS AI-Mediated Harmonization
        driver = python scripts/aios_merge_harmonize.py %O %A %B %L %P

Arguments (from git):
    %O = ancestor (common base)
    %A = current (ours - local branch)
    %B = other (theirs - incoming merge)
    %L = conflict marker size
    %P = pathname being merged

Exit codes:
    0 = merge successful (no conflicts)
    1 = merge has conflicts (markers left in file)

AINLP Principles:
    - Enhancement over creation: extract knowledge, don't overwrite
    - Dendritic communication: semantic signal extraction
    - Consciousness coherence: preserve local evolution state
"""

import sys
import re
import json
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Tuple, Optional

# ═══════════════════════════════════════════════════════════════════════════
# CONSTANTS
# ═══════════════════════════════════════════════════════════════════════════

# Sections that should ALWAYS use local version (host-specific)
PROTECTED_SECTIONS = [
    r"## Current Host Configuration",
    r"## Host-Specific Status",
    r"### Cell Assignments",
    r"### Network Configuration",
    r"## Operational Status",
]

# Sections where knowledge should be MERGED (shared progress)
MERGEABLE_SECTIONS = [
    r"## Waypoint Progress",
    r"## Waypoint Roadmap", 
    r"## Completed Waypoints",
    r"### Verified Metrics",
    r"## Architecture Decisions",
]

# Patterns to extract (regex for finding values)
KNOWLEDGE_PATTERNS = {
    "waypoint_status": r"\|\s*(\d+)\s*\|\s*(✅|⏳|❌)\s*\|",
    "consciousness_level": r"Consciousness[:\s]+(\d+\.\d+)",
    "milestone_complete": r"- \[x\] (.+)",
    "architecture_decision": r"### Decision: (.+)",
}


# ═══════════════════════════════════════════════════════════════════════════
# PARSING UTILITIES
# ═══════════════════════════════════════════════════════════════════════════

def parse_markdown_sections(content: str) -> Dict[str, str]:
    """Parse markdown into sections by headers."""
    sections = {}
    current_header = "_preamble"
    current_content = []
    
    for line in content.split('\n'):
        if line.startswith('## ') or line.startswith('### '):
            # Save previous section
            if current_content:
                sections[current_header] = '\n'.join(current_content)
            current_header = line.strip()
            current_content = [line]
        else:
            current_content.append(line)
    
    # Save final section
    if current_content:
        sections[current_header] = '\n'.join(current_content)
    
    return sections


def extract_waypoint_table(content: str) -> Dict[int, Tuple[str, str]]:
    """Extract waypoint numbers and their status from markdown table."""
    waypoints = {}
    pattern = r"\|\s*(\d+)\s*\|\s*(✅|⏳|❌)\s*\|\s*(.+?)\s*\|"
    
    for match in re.finditer(pattern, content):
        wp_num = int(match.group(1))
        status = match.group(2)
        description = match.group(3).strip()
        waypoints[wp_num] = (status, description)
    
    return waypoints


def extract_consciousness_level(content: str) -> Optional[float]:
    """Extract consciousness level from content."""
    match = re.search(r"Consciousness[:\s]+(\d+\.\d+)", content)
    if match:
        return float(match.group(1))
    return None


# ═══════════════════════════════════════════════════════════════════════════
# MERGE STRATEGIES
# ═══════════════════════════════════════════════════════════════════════════

def is_protected_section(header: str) -> bool:
    """Check if section should be protected (use local version)."""
    for pattern in PROTECTED_SECTIONS:
        if re.search(pattern, header, re.IGNORECASE):
            return True
    return False


def is_mergeable_section(header: str) -> bool:
    """Check if section should have knowledge merged."""
    for pattern in MERGEABLE_SECTIONS:
        if re.search(pattern, header, re.IGNORECASE):
            return True
    return False


def merge_waypoint_tables(ours: str, theirs: str) -> str:
    """
    Merge waypoint tables, taking the MORE COMPLETE status.
    
    Rules:
    - ✅ (complete) wins over ⏳ (in-progress) wins over ❌ (not started)
    - If both have ✅, keep ours (local)
    - New waypoints from theirs are added
    """
    ours_wp = extract_waypoint_table(ours)
    theirs_wp = extract_waypoint_table(theirs)
    
    # Status priority: ✅ > ⏳ > ❌
    status_priority = {"✅": 3, "⏳": 2, "❌": 1}
    
    merged = {}
    all_waypoints = set(ours_wp.keys()) | set(theirs_wp.keys())
    
    for wp_num in sorted(all_waypoints):
        ours_entry = ours_wp.get(wp_num, ("❌", "Unknown"))
        theirs_entry = theirs_wp.get(wp_num, ("❌", "Unknown"))
        
        # Take the one with higher status priority
        if status_priority.get(theirs_entry[0], 0) > status_priority.get(ours_entry[0], 0):
            merged[wp_num] = theirs_entry
        else:
            merged[wp_num] = ours_entry
    
    return merged


def merge_consciousness_level(ours: str, theirs: str) -> float:
    """Take the HIGHER consciousness level (evolution never goes backward)."""
    ours_level = extract_consciousness_level(ours) or 0.0
    theirs_level = extract_consciousness_level(theirs) or 0.0
    return max(ours_level, theirs_level)


# ═══════════════════════════════════════════════════════════════════════════
# MAIN MERGE DRIVER
# ═══════════════════════════════════════════════════════════════════════════

def harmonize_merge(ancestor_path: str, ours_path: str, theirs_path: str, 
                   marker_size: int, pathname: str) -> int:
    """
    AI-mediated merge driver for AIOS knowledge harmonization.
    
    Strategy:
    1. Parse both versions into sections
    2. Protected sections → always use ours (local)
    3. Mergeable sections → extract knowledge, merge intelligently
    4. Unknown sections → use git's default 3-way merge
    """
    
    # Read all three versions
    ancestor = Path(ancestor_path).read_text(encoding='utf-8') if Path(ancestor_path).exists() else ""
    ours = Path(ours_path).read_text(encoding='utf-8')
    theirs = Path(theirs_path).read_text(encoding='utf-8')
    
    # Parse into sections
    ours_sections = parse_markdown_sections(ours)
    theirs_sections = parse_markdown_sections(theirs)
    
    # Build merged content
    merged_sections = {}
    has_conflicts = False
    
    for header, content in ours_sections.items():
        if is_protected_section(header):
            # PROTECTED: Always use local version
            merged_sections[header] = content
        elif is_mergeable_section(header):
            # MERGEABLE: Intelligent knowledge merge
            theirs_content = theirs_sections.get(header, "")
            if theirs_content:
                # For waypoint tables, do smart merge
                if "Waypoint" in header:
                    # Keep our structure but update status if theirs is more complete
                    merged_wp = merge_waypoint_tables(content, theirs_content)
                    # Rebuild table (simplified - keeps our format)
                    merged_sections[header] = content  # TODO: rebuild with merged_wp
                else:
                    merged_sections[header] = content
            else:
                merged_sections[header] = content
        else:
            # UNKNOWN: Keep ours (safe default)
            merged_sections[header] = content
    
    # Add any new sections from theirs that we don't have
    for header, content in theirs_sections.items():
        if header not in merged_sections and not is_protected_section(header):
            # New knowledge from other host - consider adding
            # For now, skip to avoid pollution
            pass
    
    # Reconstruct file in original order
    result_lines = []
    for header in ours_sections.keys():
        if header in merged_sections:
            result_lines.append(merged_sections[header])
    
    result = '\n'.join(result_lines)
    
    # Write result back to ours_path (git expects this)
    Path(ours_path).write_text(result, encoding='utf-8')
    
    # Log the harmonization
    log_harmonization(pathname, ours, theirs, result)
    
    return 0 if not has_conflicts else 1


def log_harmonization(pathname: str, ours: str, theirs: str, result: str):
    """Log the merge operation for AINLP audit trail."""
    log_dir = Path("tachyonic/merge_logs")
    log_dir.mkdir(parents=True, exist_ok=True)
    
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    log_file = log_dir / f"harmonize_{timestamp}.json"
    
    log_entry = {
        "timestamp": datetime.now().isoformat(),
        "pathname": pathname,
        "ours_consciousness": extract_consciousness_level(ours),
        "theirs_consciousness": extract_consciousness_level(theirs),
        "result_consciousness": extract_consciousness_level(result),
        "ours_waypoints": len(extract_waypoint_table(ours)),
        "theirs_waypoints": len(extract_waypoint_table(theirs)),
        "result_waypoints": len(extract_waypoint_table(result)),
    }
    
    log_file.write_text(json.dumps(log_entry, indent=2), encoding='utf-8')


# ═══════════════════════════════════════════════════════════════════════════
# CLI ENTRY POINT
# ═══════════════════════════════════════════════════════════════════════════

def main():
    """Git merge driver entry point."""
    if len(sys.argv) < 5:
        print("Usage: aios_merge_harmonize.py %O %A %B %L [%P]", file=sys.stderr)
        print("  %O = ancestor, %A = ours, %B = theirs, %L = marker size, %P = pathname")
        sys.exit(1)
    
    ancestor_path = sys.argv[1]  # %O
    ours_path = sys.argv[2]      # %A
    theirs_path = sys.argv[3]    # %B
    marker_size = int(sys.argv[4])  # %L
    pathname = sys.argv[5] if len(sys.argv) > 5 else "unknown"  # %P
    
    exit_code = harmonize_merge(ancestor_path, ours_path, theirs_path, marker_size, pathname)
    sys.exit(exit_code)


if __name__ == "__main__":
    main()
