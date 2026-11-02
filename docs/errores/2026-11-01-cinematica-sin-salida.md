# Una cinemática con sala de destino mala dejaba al jugador en negro

**Síntoma.** Con una `sala_destino` que no carga, la cinemática seguía en pantalla sin salida (`sigue_en_cinematica=true`, reproducido el 1-nov-2026).

**Causa.** `Cinematica._ir` ignoraba el error de `Fundido.ir_a_sala`.

**Arreglo.** Si el cambio falla, vuelve al menú principal.

**Guion.** `nucleo/cinematica_sala_mala`. El error de `Fundido` es lo que se prueba: `Engine.print_error_messages` lo calla durante el cambio.
