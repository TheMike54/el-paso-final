# El joystick táctil soltaba el movimiento del teclado

- **Síntoma**: con una tecla de movimiento presionada, levantar el dedo del joystick o la primera tecla que oculta
  los controles dejaban al jugador sin moverse hasta soltar y volver a presionar.
- **Causa**: al soltar el joystick, `nucleo/controles_tactiles.gd` hacía `Input.action_release` de las cuatro
  acciones `mover_*`, aunque las sostuviera el teclado o el control. `Input` marca la acción antes de pasar el
  evento a los controles, así que también se perdía la tecla que los ocultaba.
- **Arreglo**: el joystick recuerda qué acciones presionó él (`_movimientos_propios`) y solo suelta esas.
- **Guion que lo cubre**: `herramientas/guiones/nucleo/controles_tactiles.guion`, casos «soltar el joystick no
  suelta lo que sostiene el teclado» y «ocultar los controles no suelta lo que sostiene el teclado». Sin el
  arreglo, 2 fallos. Lo encontró la revisión final de la rama.
