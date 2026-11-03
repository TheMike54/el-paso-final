# El video en Theora sonaba más bajo de lo elegido

- **Síntoma:** en la PC (y en el respaldo Theora), el video del menú y de la cinemática sonaban más bajo que la
  música: con Música al 50 %, al 12,5 %. Lo encontró el `revisor` leyendo el código, antes del PR.
- **Causa:** `ReproductorVideo` mandaba el `VideoStreamPlayer` al bus `Musica`, que ya aplica Master y Música, y
  además le ponía `volume = Master × Musica`: la atenuación se aplicaba dos veces. En H.264 está bien, porque
  `MediaPlayer` suena fuera de los buses de Godot y necesita ese volumen.
- **Arreglo:** Theora ya no fija `volume`; solo el bus. `volumen()` queda para `MediaPlayer`.
- **Lo cubre:** ninguna prueba automática: sin ventana no se reproduce video. Se comprueba a oído en la PC, en la fila
  «Video del menú y cinemática» de `docs/pruebas.md` (el volumen sigue a Música).
