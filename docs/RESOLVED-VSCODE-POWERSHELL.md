# VS Code PowerShell Version Resolution

**Issue:** VS Code settings synced from architect machine expected PowerShell 7 (`PowerShell (x64)`) but clean Windows 11 only had Windows PowerShell 5.1.

**Resolution Date:** November 16, 2025

---

## Problem

```
The 'powerShellDefaultVersion' setting was 'PowerShell (x64)' 
but this was not found! Instead using first available installation 
'Windows PowerShell (x64)' at 'C:\WINDOWS\System32\WindowsPowerShell\v1.0\powershell.exe'
```

---

## Root Cause

- VS Code Settings Sync carried `"powershell.powerShellDefaultVersion": "PowerShell (x64)"` from architect machine
- Clean Windows 11 install only has Windows PowerShell 5.1 by default
- PowerShell 7 is installed in Phase 1 of AIOS bootstrap, but VS Code opened before bootstrap ran

---

## Solution Applied

Installed PowerShell 7 immediately to align with synced settings:

```powershell
winget install --id Microsoft.PowerShell --source winget --silent
```

**Result:**
- PowerShell 7.5.4 installed at `C:\Program Files\PowerShell\7\pwsh.exe`
- VS Code can now use expected default PowerShell version
- No settings changes needed (synced settings are correct)

---

## Verification

```powershell
PS> Get-Command pwsh | Select-Object Source, Version

Source                                 Version
------                                 -------
C:\Program Files\PowerShell\7\pwsh.exe 7.5.4.0
```

---

## Recommendation for Future Clean Installs

**Order of Operations:**
1. Install PowerShell 7 first (before opening VS Code)
2. Open VS Code (settings sync will match installed version)
3. Run AIOS bootstrap

**OR**

Keep current order but add to bootstrap script:
- Check if VS Code is installed
- If yes, temporarily update settings to use Windows PowerShell 5.1
- After PowerShell 7 installs, restore settings

---

## Status

✅ **RESOLVED** — PowerShell 7 installed, VS Code now uses correct version

**Next:** Proceed with AIOS Docker Compose stack creation

---

*Resolution completed: November 16, 2025 21:53*
