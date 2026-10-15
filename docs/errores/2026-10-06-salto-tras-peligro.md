# Una pulsación de saltar antes de un peligro hacía saltar al reaparecer

- **Síntoma**: si se presionaba `saltar` uno o dos ticks antes de caer en los pinchos, el jugador reaparecía en
  su punto seguro y saltaba solo al terminar el congelado, sin que nadie tocara nada.
- **Causa**: `_volver_al_punto_seguro` no limpiaba el contador del salto en cola (`_ticks_desde_pulsar`) ni el del
  tiempo coyote. Al reaparecer en el suelo, la pulsación vieja seguía dentro de la ventana del salto en cola.
- **Arreglo**: `nucleo/jugador.gd` gasta los dos contadores al volver al punto seguro, igual que hace `_saltar()`.
- **Guion que lo cubre**: `herramientas/guiones/nucleo/jugador_peligro.guion`, que presiona `saltar` en los cuadros
  128 y 129 y revisa el cuadro 158. Sin el arreglo da `y obtenido=608.34; en_suelo obtenido=false`. Lo encontró el
  revisor.
