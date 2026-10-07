# Curar congelaba el impulso y el rebote, que seguían al terminar

- **Síntoma**: presionar `curar` justo después de un impulso o de golpear algo dejaba al jugador quieto
  curándose, y al terminar la curación el resto del impulso (o del rebote del golpe) lo movía solo, sin entrada.
- **Causa**: mientras se cura, `_physics_process` se salta `_mover_en_horizontal`, que es donde se descuentan los
  contadores del impulso, del despegue de la pared y del rebote. Quedaban detenidos y se reanudaban después.
  `recibir_dano` y `_volver_al_punto_seguro` tampoco limpiaban todos.
- **Arreglo**: `nucleo/jugador.gd` no deja empezar a curar durante un impulso, cancela el despegue y el rebote al
  empezar, y limpia los tres al recibir daño y al volver al punto seguro.
- **Guion que lo cubre**: `herramientas/guiones/nucleo/jugador_curar_tras_impulso.guion`. Sin el arreglo da
  `x obtenido=395.96; curando obtenido=true`. Lo encontró el revisor.
