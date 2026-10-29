# Callar un tema que estaba a -60 dB lo subía a -12 dB por el camino

- **Síntoma:** en la sala Música de la zona de pruebas, acercarse al banco y alejarse deja el tema a -60 dB (sonando,
  pero callado); al volver a la lista de la zona, que pide `Musica.SILENCIO` con `DB_NORMAL` en 1 s, el tema subía
  hasta -12 dB y después se iba. Lo mismo con un tema nuevo pedido a `Musica.DB_SILENCIO` desde otro a volumen normal:
  el que entraba llegaba a -12 dB en vez de quedar callado, contra lo que promete el contrato («Sala»,
  `volumen_musica_db`: callado hasta llegar a una `RegionMusica`). Medido sin pantalla leyendo `volume_db` de los
  reproductores cada tick: pico de -12,0 dB en los dos casos.
- **Causa:** `Musica` llevaba dos tweens a la vez y los multiplicaba: la mezcla de cada reproductor (1 → 0 para el
  que se va, 0 → 1 para el que entra) y el volumen de región (0,001 → 1 o al revés, porque cada pedido trae su
  volumen; la sala manda `DB_NORMAL` por omisión). El producto de una rampa que baja y otra que sube pasa por 0,25
  (-12 dB) a la mitad del fundido. Las pruebas no lo veían porque leían `actual`, `volumen_db`, `arranques` y
  `se_oye()`, nunca el `volume_db` de los reproductores durante el fundido.
- **Arreglo:** `nucleo/musica.gd` tiene un solo tween por reproductor, sobre su volumen final (el del tema por el de
  región, ya multiplicado): va en línea recta del que tiene al destino (1 × región para el que suena, 0 para los
  demás), así nunca pasa del mayor de los dos. Se fueron la mezcla separada, el tween de región y la propiedad
  pública `region`. Si cambia el tema, todos los reproductores usan los segundos del tema; si no, solo el que suena se
  funde al volumen nuevo con los segundos del volumen.
- **Lo cubre:** `herramientas/guiones/nucleo/musica.guion` (`prueba_musica.gd`, `_sin_picos`): con el tema a
  `DB_SILENCIO`, pedir `SILENCIO` con `DB_NORMAL`; y desde un tema a volumen normal, pedir otro a `DB_SILENCIO`. En los
  dos, ningún reproductor pasa, tick a tick, del mayor entre su volumen al pedir y el final. Con el código anterior
  fallaban los dos casos («el reproductor 0 subió a -12.0 dB (al pedir -60.0, al final -100.0)»).
