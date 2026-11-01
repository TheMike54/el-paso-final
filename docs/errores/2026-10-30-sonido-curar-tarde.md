# El sonido de curar llegaba tarde

**Síntoma.** En el S50, en la sala de curar: el jugador se cura y el sonido se oye mucho después.

**Causa.** `Sonido` tocaba `curar` con `jugador_curado`, al terminar los 60 ticks de la curación, y `curar.wav` no es un
golpe seco: sube durante 1,9 s, con el pico a los 1,2 s (medido por tramos de 100 ms). El pico llegaba unos 2,2 s
después de apretar el botón.

**Arreglo.** `curacion_empezada` toca el efecto al empezar y `curacion_cortada` lo calla si la curación no termina.
`jugador_curado` ya no suena: sigue siendo la señal de la vibración y de `AvisoAccion`. El jugador corta la curación
también en el peligro anti-bucle, que no pasaba por `_cortar_curacion`, y en `_exit_tree`, para salir al menú a medio
curar.

**Qué lo cubre.** `herramientas/guiones/nucleo/sonido.guion`: el efecto suena con `curacion_empezada` y no con
`jugador_curado`; con ventana, que el corte lo calla. `jugador_curar_soltar.guion` y `jugador_curar_golpe.guion` cuentan
`curacion_cortada`; `jugador_curar.guion` comprueba que terminar no la emite. Sin guion: el corte del peligro
anti-bucle y el de `_exit_tree`, que se revisaron leyendo el código.
