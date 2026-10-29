# Saltar justo antes de una puerta la pasaba por encima

- **Síntoma:** en la prueba manual «Fundido a negro» (14-oct-2026, Galaxy Tab S9 FE, APK de `5d377b4`), al saltar
  justo antes de la puerta de la sala de puertas A o B, la pantalla fundía a negro pero la sala no cambiaba, en
  las dos direcciones. En la misma QA, en la sala A caminar a la izquierda parecía «atorarse con algo invisible».
- **Causa:** el área de la puerta mide 160 px de alto (`nucleo/puerta.tscn`) y el salto subía 200 px
  entonces (`altura_salto`; hoy 230 px): un salto a tiempo pasa por encima del área sin tocarla. Detrás de la puerta no había nada
  sólido, así que el jugador salía por el borde, caía por debajo de los límites y eso cuenta como un peligro: quita
  una vida, funde a negro y lo devuelve al último suelo firme de la misma sala. La sala A tampoco tenía pared
  izquierda (caer por esa orilla era lo mismo); lo «invisible» no era un choque: la sala es negra, sin
  referencias, y con la cámara siguiendo al jugador parecía que no avanzaba (en el video los corazones no bajan y
  no hay fundidos).
- **Arreglo:** una pared invisible detrás de cada puerta en el borde, fuera de los límites (`ParedTrasPuerta`):
  quien salta por encima la choca y cae dentro del área. Va en las nueve salas de prueba con puertas en el borde
  que no tenían nada sólido detrás: las dos de puertas, la de combate, las cuatro de la zona de prueba y las dos
  de la zona del mapa (las de enemigos ya tenían paredes). La sala A lleva además una pared izquierda y tres
  columnas oscuras de referencia. La regla para las salas nuevas está en el contrato («Cambio de sala»).
- **Lo cubre:** `herramientas/guiones/nucleo/puerta_salto_a.guion`, `puerta_salto_b.guion` y
  `sala_puerta_a_pared.guion` (los tres fallan sin el arreglo).
