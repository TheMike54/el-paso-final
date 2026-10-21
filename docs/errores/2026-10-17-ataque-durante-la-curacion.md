# Atacar justo antes de curar dejaba el ataque encendido durante la curación

- **Síntoma:** si el jugador atacaba mientras mantenía `curar`, en los `ticks_mantener_poder` ticks antes de que
  empezara la curación, el área de ataque seguía encendida (`Ataque.monitoring` en true) al empezar a curarse y se
  quedaba así mientras durara la curación. Con ella seguían aceptándose paradas (`intentar_parar`) y se seguía
  dibujando el golpe. Lo encontró la auditoría del código (J1), no una partida.
- **Causa:**
  - `_empezar_curacion` no cortaba el ataque: solo la carrera, el despegue de la pared y el rebote.
  - Mientras cura, `_mover` sale por `_boton_poderes` antes de llegar a `_atacar()`, que es lo único que descuenta
    `_ticks_atacando` y apaga el área. El ataque quedaba congelado a medias hasta soltar `curar`.
  - De fondo (J8): cada salida que deja al jugador quieto (aterrizaje duro, picada, daño, peligro, sentarse, hablar)
    repetía a mano su lista de «qué se corta», y la de la curación se quedó sin el ataque.
- **Arreglo:** `_cortar_lo_que_empuja` se partió en `_cortar_empujes()` (subida, impulso, despegue, rebote, carrera,
  voltereta) y `_cortar_ataque()` (ataque a medias, el que está en cola y el área). `_empezar_curacion` llama a
  `_cortar_ataque()`. El aterrizaje duro, la picada, el peligro, sentarse y hablar llaman a las dos; el daño y la
  colocación tras un peligro, solo a `_cortar_empujes()`, como antes. Fuera de la curación nada cambia de
  comportamiento.
- **Lo cubre:** `herramientas/guiones/nucleo/jugador_curar_atacar.guion`: ataca manteniendo `curar` y, ya curando,
  `Jugador/Ataque monitoring` debe estar en false.
