# El jugador se movía solo después de morir

- **Síntoma**: en el teléfono, en la sala de golpe, después de morir el jugador reapareció y caminó solo hacia la
  izquierda sin que nadie tocara la pantalla; se detuvo al volver a usar el joystick.
- **Causa**: cada sala crea sus propios controles táctiles, y al morir la sala se recarga. Si un dedo seguía en
  el joystick (o en un botón) en ese momento, los controles viejos se borraban con su acción presionada en
  `Input`, que es global y sobrevive al cambio de escena. Los controles nuevos no conocían ese dedo: al levantarlo
  no soltaban nada, y la acción quedaba presionada hasta que el joystick nuevo presionara y soltara esa misma
  dirección. Pasaba igual al cruzar una puerta con el dedo puesto.
- **Arreglo**: `nucleo/controles_tactiles.gd` guarda los dedos en variables estáticas, así los controles de la
  sala nueva siguen el mismo dedo y lo sueltan al levantarlo. Si entre una sala y otra pasan más de
  `CUADROS_CAMBIO_DE_SALA` cuadros (se pasó por el menú, que no tiene controles), al llegar se suelta todo.
- **Guion que lo cubre**: `herramientas/guiones/nucleo/controles_tactiles.guion`, casos «soltar ese dedo en los
  controles nuevos suelta el movimiento», «soltar un botón en los controles nuevos lo suelta» y «tras pasar por el
  menú no queda movimiento presionado». Sin el arreglo, 3 fallos. Un `.guion` de entradas no lo reproduce: presiona
  las acciones directo en `Input`, como el teclado, que sí suelta la tecla en cualquier sala.
