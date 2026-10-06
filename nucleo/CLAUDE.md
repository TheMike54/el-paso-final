# Núcleo

Código que se escribe una vez y usa todo el juego: jugador, cámara, sala y cambio de sala, guardado, entrada y
bus de eventos. El contenido (zonas, enemigos, NPC) se agrega sin tocar esta carpeta.

## Primero
Leer `funciones.json` de esta carpeta: la primera funcionalidad con `"pasa": false` es la que sigue.

## Qué ofrece a los demás bloques
Lo que otro bloque puede usar está en `docs/contrato.md` (autoloads, señales del bus, forma de una sala, ficha y
guardado). Si un cambio aquí altera el contrato, se actualiza en el mismo cambio y se avisa a la persona. Lo que
el contrato todavía no define se propone en un plan antes de programarlo.

## Qué no toca
- No conoce zonas, enemigos ni NPC concretos: trabaja con fichas y señales.
- No depende de ningún otro bloque. Única excepción: el autoload de arranque carga con `load()` las herramientas
  de depuración si existen (ver `herramientas/CLAUDE.md`).

## Cómo se comprueba
- Después de cada cambio: `.\herramientas\validar.ps1`, desde la raíz del repo.
- Movimiento, salto, cámara y cambio de sala: un guion en `herramientas/guiones/nucleo/` con lo que debe
  cumplirse al final.
- La sensación (salto, aceleración, cámara) la juzga la persona en una ventana; Claude dice qué observar.

## Trampas
- El jugador se mueve en `_physics_process`; nada de lógica de movimiento en `_process`.
- El guardado se escribe a un archivo temporal y luego se renombra: así un cierre a mitad no deja el archivo dañado.
