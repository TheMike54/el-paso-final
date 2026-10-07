# Atacar y Saltar se enciman en una pantalla 20:9

- **Síntoma**: en el teléfono de prueba (2400 × 1080), los círculos de Atacar y Saltar se tocaban y Curar casi
  tocaba a Impulso. Se vio en una captura de pantalla con `adb`.
- **Causa**: los centros de la distribución inicial dejan a Atacar y Saltar a 0,18 del lado corto de la pantalla,
  y los radios elegidos (0,08 y 0,10) sumaban justo eso. En 16:9 se nota menos.
- **Arreglo**: `nucleo/controles_tactiles.gd` baja los radios a 0,07 (Atacar, Curar, Impulso) y 0,085 (Saltar),
  con un comentario que dice por qué.
- **Guion que lo cubre**: ninguno; que se vea bien es prueba manual (`docs/pruebas.md`, «Controles táctiles»).
  `controles_tactiles.guion` sigue comprobando que cada botón responde en su centro.
