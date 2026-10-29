# Instrucciones para agentes que no son Claude Code (Codex y otros)

Las reglas de este repositorio están en `CLAUDE.md` (raíz) y en el `CLAUDE.md` de cada bloque (`nucleo/`, `contenido/`,
`interfaz/`, `mapa/`, `herramientas/`). Léelos antes de cambiar nada y síguelos igual que Claude: valen para cualquier
agente.

Lo que más se rompe:
- Godot 4.7.2 con tipado estricto: toda variable con tipo y toda función con tipo de retorno. Las skills de
  `.claude/skills/` (`gdscript4`, `fisica-2d`, `ui-tactil`, `rendimiento-gama-baja`) tienen las reglas.
- `.tscn` y `.tres` escritos a mano conservan `uid` e ids de `ext_resource`, y cada `ext_resource` nuevo lleva el `uid`
  del archivo que nombra. `.godot/` no se toca.
- Ningún agente hace `git commit`, `git push`, `git merge`, `git rebase`, `git tag` ni crea PRs o issues.
- Nada termina sin `.\herramientas\validar.ps1` con `OK  VALIDACION ... fallos=0`.
- No leer ni escribir `.env*`, `*.keystore`, `*.jks`, `*.pem` ni `*.key`.
