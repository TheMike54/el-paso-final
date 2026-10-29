# Un efecto nuevo cortaba a uno largo que todavia sonaba

- **Síntoma:** `Sonido` tocaba cada efecto en la voz siguiente de una rueda de cuatro `AudioStreamPlayer`, aunque
  otra estuviera libre. El quinto efecto caía sobre la voz del primero y lo cortaba: con pasos (unos cuatro por
  segundo), caminar mientras se abre un portón (2,6 s) o justo después de curarse cortaba el sonido largo en menos de
  un segundo. Antes de los pasos ya podía pasar (salto, golpes y daño seguidos), pero era raro.
- **Causa:** asignar `stream` a un `AudioStreamPlayer` que suena detiene lo que sonaba
  (`classes/class_audiostreamplayer.rst:301`), y la rueda no miraba si la voz estaba libre.
- **Arreglo:** `nucleo/sonido.gd` usa un solo `AudioStreamPlayer` con un `AudioStreamPolyphonic` de `voces` (8) y
  toca con `play_stream`: un efecto nuevo nunca corta a uno que suena; con todas las voces ocupadas `play_stream`
  devuelve `INVALID_ID` y se descarta el nuevo (`classes/class_audiostreamplaybackpolyphonic.rst:94`), que se cuenta
  en `descartados`. El bus `Efectos` va explícito en cada llamada (por omisión sería `Master`, `:86`). Al salir del
  árbol se callan las voces: con efectos sonando al cerrar, la corrida con ventana terminaba con
  `ERROR: 3 resources still in use at exit` (con el arreglo, 13 de 14 corridas salen limpias; la primera, en frío,
  todavía lo dio, sin causa encontrada).
- **Lo cubre:** `herramientas/guiones/nucleo/sonido.guion` (`prueba_sonido.gd`). Sin pantalla (CI), la estructura:
  un reproductor polifónico de `voces` en `Efectos`. Con ventana (comando en la fila de `sonido.guion` de
  `docs/pruebas.md`): un portón y cinco pasos en el mismo tick, y el portón sigue sonando; con las voces llenas se
  descarta el nuevo y el primero sigue. Con la rueda de cuatro voces, el quinto paso cortaba el portón.
