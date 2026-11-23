# Cerrar un menú con Espacio también atacaba

- **Síntoma:** en la PC, cerrar la pausa (Continuar), el marco (Volver) o el cobro de una estación con Espacio hacía
  que el jugador atacara en el primer tick con el juego andando. Sentado en un banco, la misma pulsación lo levantaba.
  Estaba anotado como fallo conocido en `ESTADO.md`; issue #54.
- **Causa:**
  - Espacio está en `ui_accept` (por `keycode`) y en `atacar` (por `physical_keycode`) en el `InputMap`.
  - Es el mismo mecanismo que `docs/errores/2026-10-20-salto-al-cerrar-un-menu.md`: el `Button` con foco se pulsa con
    `ui_accept` al despachar el evento, antes del tick y fuera de la física, y quita la pausa ahí. En el tick
    siguiente `Input.is_action_just_pressed(&"atacar")` es verdadero.
  - El arreglo de octubre solo filtraba `saltar`: la marca `_saltar_del_menu` no se miraba al leer `atacar`, ni al
    levantarse del banco con `atacar`.
- **Arreglo:** en `nucleo/jugador.gd` la marca pasa a llamarse `_pulsacion_del_menu` y vale para las dos acciones:
  `_atacar_pulsado()` reemplaza a `Input.is_action_just_pressed(&"atacar")` en `_avanzar_contadores` y en el congelado,
  y `_seguir_descansando` no se levanta con `saltar` ni con `atacar` mientras está puesta. La marca sigue durando un
  tick: una pulsación nueva en el siguiente sí ataca.
- **Lo cubre:** `herramientas/guiones/nucleo/salto_tras_menu.guion` (`prueba_salto_tras_menu.gd`), con eventos de
  teclado de verdad (`InputEventKey` con `keycode` y `physical_keycode` en `KEY_SPACE`, apretado y soltado en el mismo
  cuadro), contando `Eventos.jugador_ataco`:
  - «Espacio en Continuar cierra la pausa sin atacar»;
  - «atacar pulsado despues del cierre si ataca»;
  - «Espacio en Volver del marco lo cierra sin atacar»;
  - «Espacio al cerrar la pausa sentado no lo levanta».

  El cobro de una estación, la tienda y las estaciones (`modal_pausa.gd`) también quitan la pausa fuera del tick y
  pasan por la misma marca; con Espacio no tienen caso propio (el cobro sí lo tiene con A).

  Mutaciones con `mutar.ps1`: quitar `and not _pulsacion_del_menu` de `_atacar_pulsado()` hace fallar «Espacio en
  Continuar…» (1 ataque); quitar `atacar` de la condición del banco hace fallar «Espacio al cerrar la pausa sentado…».
