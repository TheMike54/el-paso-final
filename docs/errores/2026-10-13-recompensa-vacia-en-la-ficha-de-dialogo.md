# Una recompensa vacía en una ficha de diálogo pasaba el validador

- **Síntoma:** encontrado leyendo el código (auditoría del 13-oct-2026), sin verse en el juego. Una `FichaDialogo` con
  una recompensa vacía, o una habilidad, amuleto o mapa sin id, pasaba `fallos()` y el validador.
- **Causa:** `fallos()` revisaba las líneas, no las recompensas. Con una vacía, `Npc.terminar` subía la etapa y se
  cortaba al entregarla: la caja quedaba abierta y la etapa contada sin premio.
- **Arreglo:** `fallos()` también marca una recompensa vacía, una de amuleto, habilidad o mapa sin id y una opción sin
  texto.
- **Lo cubre:** `herramientas/guiones/nucleo/dialogo.guion`, caso «una opcion sin texto, una recompensa vacia y una
  habilidad sin id dan un fallo cada uno» (falla sin el arreglo).
