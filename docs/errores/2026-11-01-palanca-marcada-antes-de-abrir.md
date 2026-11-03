# Salir antes del retraso dejaba la palanca movida y el portón cerrado para siempre

**Síntoma.** Golpear la palanca y salir de la sala antes de `ticks_retraso` dejaba, al volver, `palanca_activada=true` y `porton_abierto=false` (reproducido el 1-nov-2026 en `sala_secretos`).

**Causa.** La palanca se marcaba al recibir el golpe y los portones se abrían después: la marca sobrevivía a la salida y el retraso no.

**Arreglo.** `nucleo/palanca.gd` marca al abrir los portones. Salir antes del retraso deja la palanca como estaba.

**Guion.** `nucleo/muro_rompible`, caso «salir antes del retraso deja la palanca sin activar».
