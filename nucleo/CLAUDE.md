# Núcleo

Código que se escribe una vez y usa todo el juego: jugador, cámara, sala y cambio de sala, guardado, entrada,
bus de eventos, menús (ranuras, Configuración, pausa, marco de menús) y diálogo. El contenido (zonas, enemigos, NPC) se agrega sin tocar esta carpeta.

## Primero
Leer `funciones.json` de esta carpeta.

## Qué ofrece a los demás bloques
Lo que otro bloque puede usar está en `docs/contrato.md` (autoloads, señales del bus, forma de una sala, ficha y
guardado). Si un cambio aquí altera el contrato, se actualiza en el mismo cambio y se avisa a la persona. Lo que
el contrato todavía no define se propone en un plan antes de programarlo.

## Qué no toca
- No conoce zonas, enemigos ni NPC concretos: trabaja con fichas y señales.
- No depende de ningún otro bloque. Excepciones, todas solo si el archivo existe (`load()` o
  `ResourceLoader.exists`, nunca `preload`): las de `herramientas/`, en `docs/contrato.md`, «Paquete de
  publicación»; la sala carga `interfaz/interfaz.tscn` y `mapa/pantalla_mapa.tscn`; el `MenuEstaciones` lee
  `mapa/indice_salas.tres` con `get()`, sin nombrar `IndiceSalas` (sin él, la lista sola); y de `contenido/`, `Sala.ruta_de`
  (salas), la `Mochila` (`preguntas_mochila.tres`) y `Estacion.tabla_de` (`estaciones.tres`). Una excepción nueva va
  aquí y, si es de `herramientas/`, en el contrato.

## Cómo se comprueba
- Cada entrada de `funciones.json` dice su `comprobacion`: casi siempre un guion de `herramientas/guiones/nucleo/`
  con lo que debe cumplirse al final.

## Trampas
- El guardado se escribe a un archivo temporal y luego se renombra: así un cierre a mitad no deja el archivo dañado.
