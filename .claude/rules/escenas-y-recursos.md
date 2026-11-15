---
paths:
  - "**/*.tscn"
  - "**/*.tres"
---

# Escenas y recursos (`.tscn`, `.tres`)

- Los escribe el editor. Al editarlos a mano, conservar `uid` e ids de `ext_resource`, y todo `ext_resource` nuevo
  lleva el `uid` del archivo que nombra, tomado del disco; nunca se inventa uno. Regla y porqué: `docs/validador.md`,
  «uid de escenas y recursos». En `contenido/`, `nucleo/`, `mapa/` e `interfaz/`, `validar.ps1` falla si falta o no coincide.
- No usar las herramientas `mcp__godot__*` para crear ni editar escenas (las que escriben están en el deny de
  `.claude/settings.json`).
- Mover, renombrar o borrar una escena, un recurso o una imagen se hace en el panel FileSystem del editor: fuera de
  Godot, las rutas que la nombran se rompen (`tutorials/scripting/filesystem.rst` en `GODOT_DOCS`). Si ya se movió
  fuera: con su `.import` o `.uid`, abrir el editor para que repare las rutas y correr `validar.ps1`.
