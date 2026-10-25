# Al morir, el contador de PejeCoins no llegaba a 0

- **Síntoma:** en el S21, en la sala Lo Perdido, al morir con 120 PejeCoins aparece «120 -120». Después la sala se
  recarga y el contador desaparece: el conteo hasta 0 no se ve.
- **Causa:**
  - El contador espera `TICKS_ESPERA_CONTEO` (60 ticks) antes de contar y tarda unos 34 en contar. Tras 6 ticks de
    aparecer, son unos 100 ticks.
  - La sala reaparece al jugador a los 90 ticks (`Sala.TICKS_PARA_REAPARECER`), y los últimos 9 van a oscuras.
  - La prueba ponía las monedas en 0 sin la muerte y esperaba lo que hiciera falta, así que no medía contra ese
    plazo.
- **Arreglo:** el `Hud` oye `Eventos.jugador_muerto`, que llega después de `monedas_cambiadas`. Si hay un -N pendiente,
  acorta la espera a `TICKS_ESPERA_MUERTE` (20). Así el conteo termina hacia el tick 60 y el 0 se ve hasta que la
  pantalla oscurece.
- **Lo cubre:** `herramientas/guiones/interfaz/monedas_conteo.guion`, caso «y cuenta hasta 0 antes del fundido».
  Emite la muerte en el orden del jugador y exige el 0 a la vista antes de `TICKS_PARA_REAPARECER - TICKS_OSCURECER`.
