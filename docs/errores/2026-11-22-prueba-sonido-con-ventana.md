# `prueba_sonido` fallaba con ventana

- **Síntoma:** el guion `nucleo/sonido` corrido con ventana (`& $env:GODOT_PATH --path . --fixed-fps 60 --quit-after 7200
  -- --guion=herramientas/guiones/nucleo/sonido.guion`) fallaba en «un paso (AudioStreamRandomizer) suena por
  play_stream», también en commits viejos. Sin ventana y en el CI pasaba. Issue #62.
- **Causa:** dos, las dos de la prueba; `nucleo/sonido.gd` no cambia.
  - Sin ventana `Sonido` está mudo (`Ajustes.sin_ventana()`) y `_con_pantalla` no corre: el CI nunca toca el
    reproductor real. Con ventana, las partes anteriores de la prueba (golpes y daños reales, y los 14 efectos de la
    ficha completa de `_senales_a_eventos`, que son `AudioStreamWAV` vacíos) se tocaban de verdad y ocupaban las 8 voces
    del `AudioStreamPolyphonic` pocos ticks antes de `_con_pantalla`. Medido con una línea temporal: al llegar ahí ya
    había 9 descartados, y del portón y los cinco pasos solo sonaban el portón y dos pasos (los otros tres, `-1`).
    Muteando solo `_senales_a_eventos` quedaban 4 voces ocupadas por los golpes y daños del principio, y fallaban dos
    casos.
  - El `.esperado` pedía 33 casos: con ventana corrían 36 (los 4 de `_con_pantalla` contra 1 sin pantalla), así que el
    guion con ventana fallaba aunque pasaran todos.
- **Arreglo:** en `herramientas/pruebas/prueba_sonido.gd`, todo lo que va antes de `_con_pantalla` corre con
  `sonido.mudo = true` (solo mira contadores) y se restaura antes de elegir la rama; `_con_pantalla` empieza con las 8
  voces libres. La rama sin pantalla pasa a `_sin_pantalla`, con 4 casos de lo que hace mudo (el portón y un paso
  cuentan sin tocar, nada se descarta, la curación no guarda voz), y el `.esperado` pide 36 en los dos modos.
- **Lo cubre:** el mismo guion, `herramientas/guiones/nucleo/sonido.guion`: sin ventana `RESUMEN total=1 OK=1 MALOS=0`
  y con ventana `GUION OK herramientas/guiones/nucleo/sonido.guion cuadro=360`. `mutar.ps1` corre sin ventana y no
  puede matar el arreglo (sin ventana ya estaba mudo); la prueba de que lo arregla es la corrida con ventana antes
  (falla en «un paso…») y después (OK).
