# El banco de raices_3 llegó sin mesa con sillas

- **Síntoma:** al descansar en `banco_raices_3`, el jugador quedaría sentado con los brazos recargados en el aire sobre
  el rectángulo provisional del banco, el mismo síntoma de `docs/errores/2026-11-17-banco-sin-mesa.md`. Lo encontró la
  auditoría de documentación del 21-nov-2026: `docs/sala.md` decía que todo banco de una sala del juego lleva las dos
  cosas, y el de `raices_3` no las llevaba.
- **Causa:** la sala se armó desde el modelo de `nucleo/banco.tscn`, que es el rectángulo de las salas de prueba, sin
  copiar lo que el arreglo del 17-nov pide a los bancos del juego: el hijo `Silla` y `mirando = 1`. Ningún guion lo
  comprobaba en esa sala.
- **Arreglo:** el banco de `raices_3` lleva su `Silla` (`contenido/salas/raices/arte/banco.png`, colocada igual que en
  `raices_7`) y `mirando = 1`.
- **Lo cubre:** `herramientas/guiones/contenido/raices_3_banco.guion` comprueba que `Banco/Silla` existe y se ve y que
  el banco mira a la derecha; con la escena de antes falla («no existe el nodo 'Banco/Silla'», `mirando` 0). Que el
  jugador se vea sentado sobre la silla se revisa a ojo: `docs/pruebas.md`, «Banco de Las Raíces».
