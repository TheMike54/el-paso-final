---
paths:
  - "**/*.ps1"
---

# Scripts de PowerShell (`.ps1`)

- Solo ASCII, y que corran igual en `powershell.exe` 5.1 y en `pwsh` 7: los hooks de `.claude/settings.json` los lanza
  el 5.1, que lee un `.ps1` sin BOM como ANSI.
