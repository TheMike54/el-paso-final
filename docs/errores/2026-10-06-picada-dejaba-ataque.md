# La caída en picada dejaba un ataque a medias para después

- **Síntoma**: atacar justo antes de la caída en picada dejaba el área de ataque encendida toda la caída, y el
  ataque seguía al aterrizar.
- **Causa**: durante la picada `_physics_process` no llama a `_atacar`, que es donde se descuenta el ataque, y
  `_empezar_picada` no lo cortaba.
- **Arreglo**: `nucleo/jugador.gd` corta el ataque al empezar la picada (contador, pogo y `monitoring` del área).
- **Guion que lo cubre**: `herramientas/guiones/nucleo/habilidad_caida_en_picada_ataque.guion`. Sin el arreglo da
  `_ticks_atacando obtenido=5.00; Jugador/Ataque monitoring obtenido=true`. Lo encontró el revisor.
