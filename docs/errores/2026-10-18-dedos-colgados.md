# Una acción táctil quedaba presionada si se perdía el soltar del dedo

- **Síntoma:** si la app perdía el foco o Android la pausaba con un dedo en la pantalla (una llamada, el botón de
  inicio, la cortina de notificaciones), al volver el botón o el joystick seguían presionados: el jugador saltaba,
  atacaba o caminaba solo hasta volver a tocar ese botón. Lo mismo si un dedo llegaba con un índice que ya estaba
  registrado (se perdió su soltar): el botón de antes no se soltaba nunca, y en el joystick el toque nuevo se
  ignoraba y el arrastre seguía midiéndose desde el origen viejo. Lo encontró la auditoría del código (E1 y E2), no
  una partida; en el teléfono no se ha reproducido.
- **Causa:** `ControlesTactiles` solo soltaba un dedo al recibir su `InputEventScreenTouch` con `pressed` en
  false. No escuchaba la pérdida de foco ni la pausa de la app, y `_tocar` sobrescribía `_dedos_en_botones[dedo]`
  sin soltar la acción que ese dedo ya presionaba.
- **Arreglo:** `_notification` llama a `_soltar_todo()` con `NOTIFICATION_WM_WINDOW_FOCUS_OUT`,
  `NOTIFICATION_APPLICATION_FOCUS_OUT` y `NOTIFICATION_APPLICATION_PAUSED` (`classes/class_node.rst:1001-1005`,
  `:1151-1155`, `:1173-1177`); `_tocar` empieza con `_soltar(dedo)`, que no hace nada si el dedo no estaba; y en
  `procesar` un toque con `canceled` suelta como uno sin `pressed` (`classes/class_inputeventscreentouch.rst:60-71`;
  en 4.7.2 `canceled` ya deja `pressed` en false, así que esa comprobación no cambia nada hoy). En el camino normal
  el juego no cambia.
- **Lo cubre:** `herramientas/guiones/nucleo/controles_tactiles.guion` (`herramientas/pruebas/prueba_tactil.gd`,
  casos «un dedo que vuelve a tocar sin soltarse...», «el dedo del joystick que vuelve a tocar sin soltarse...»,
  «la notificacion <n> suelta botones y joystick» y «un toque cancelado suelta el boton»). Sin el `_soltar` de
  `_tocar`, 4 fallos; sin `_notification`, 3. Qué manda Android de verdad con un dedo apoyado al ir a segundo plano
  solo se ve en el teléfono.
