# Una luz fija de sala no alumbraba con las luces 2D

- **Síntoma:** en La Celda, con Recursos en alto y Luces 2D en «Sí», la lámpara del elevador (`LuzSala` de tipo
  `FIJA`) no aportaba luz 2D; las que parpadean o pulsan sí. Lo encontró el `revisor` antes del PR, con un guion que
  leía la energía de cada `PointLight2D` (0 en la del elevador).
- **Causa:** la energía de la luz 2D sale de la oscuridad del `Brillo` de la sala, y ese `Brillo` lo crea
  `Sala._ready`, que corre después del `_ready` de sus hijos. Al pintarse por primera vez la luz leía oscuridad 0. Las
  que parpadean o pulsan se volvían a pintar en cada cuadro y se corregían solas; la fija no tiene `_process` y se
  quedaba en 0.
- **Arreglo:** `LuzSala._ready` vuelve a pintarse al final del cuadro (`_pintar.call_deferred()`), cuando el `Brillo`
  ya existe.
- **Lo cubre:** el caso «la luz fija toma la oscuridad del Brillo aunque este llegue despues» de
  `herramientas/pruebas/prueba_piezas_sala.gd` (guion `herramientas/guiones/nucleo/piezas_sala.guion`). Sin el
  arreglo, falla.
