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
  `ResourceLoader.exists`): `Arranque` carga el puerto de depuración, solo en builds de depuración; el menú
  principal muestra la zona de pruebas con el modo desarrollador encendido, en depuración y en publicación
  (`docs/contrato.md`, «Paquete de publicación»); la sala carga `interfaz/interfaz.tscn` y
  `mapa/pantalla_mapa.tscn`, y `Sala.ruta_de` busca el id en `contenido/salas/` y después en
  `herramientas/salas/zonas/`.

## Cómo se comprueba
- Movimiento, salto, cámara y cambio de sala: un guion en `herramientas/guiones/nucleo/` con lo que debe
  cumplirse al final.

## Trampas
- El guardado se escribe a un archivo temporal y luego se renombra: así un cierre a mitad no deja el archivo dañado.
