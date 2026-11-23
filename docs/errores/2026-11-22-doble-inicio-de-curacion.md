# Curar soltado y vuelto a pulsar entre dos ticks empezaba otra curación encima

- **Síntoma:** si `curar` se soltaba y se volvía a pulsar sin un tick de física entre las dos (dos eventos en el mismo
  cuadro, o el dedo que se levanta y vuelve a tocar rápido), la curación en curso no se cortaba. Con la Inspiración
  máxima subida por un Módulo de RAM (66 o 99), a los `ticks_mantener_poder` de la pulsación nueva salía otra
  `curacion_empezada` sin un `curacion_cortada` en medio: la cuenta de la curación volvía a empezar con la Inspiración
  a medio gastar y la vida costaba 44 en vez de 33. Con la máxima inicial (33) la segunda no tiene con qué empezar y
  solo se perdía la soltada: la curación seguía como si nunca se hubiera soltado. Encontrado leyendo el código; issue #55.
- **Causa:** en `nucleo/jugador.gd`, `_boton_poderes` lee `curar` en el tick. Una soltada y una pulsación entre dos
  ticks llegan al tick como `is_action_just_pressed` verdadero e `is_action_pressed` verdadero: `_seguir_curando` no
  ve nunca `mantiene` en falso y no corta, y `_ticks_poder` vuelve a 0 y cuenta hasta `_empezar_curacion`, que no
  miraba si ya estaba curando. Medido con una sonda (`Input.action_release` y `Input.action_press` en el mismo tick):
  en ese tick `is_action_just_pressed` es falso y en el siguiente verdadero, igual que una pulsación sola.
- **Arreglo:** en `_boton_poderes`, una pulsación nueva con `curando` primero suelta la curación en curso
  (`_seguir_curando(en_suelo, false)`: corta, emite `curacion_cortada` y, antes de `ticks_devolver_curacion`, devuelve lo
  gastado) y después cuenta la pulsación nueva como cualquier otra.
- **Lo cubre:** `herramientas/guiones/nucleo/curar_repulsar.guion` (`prueba_curar_repulsar.gd`), con la máxima en 66:
  «soltar y pulsar entre dos ticks corta la curacion», «la curacion cortada devuelve lo gastado», «ninguna
  curacion_empezada sale con otra en curso» y «la pulsacion nueva cura una vida con su costo». Sin el arreglo fallan
  los cuatro (0 cortadas, Inspiración 60, 1 encimada, Inspiración final 22); la mutación que quita el arreglo con
  `mutar.ps1` da `MATADA`.
