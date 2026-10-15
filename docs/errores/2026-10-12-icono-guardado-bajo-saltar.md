# El ícono de guardado quedaba debajo del botón Saltar

- **Síntoma**: en el Senwa S50, al guardar (banco, coleccionable) el rombo que gira salía abajo a la derecha,
  justo bajo el círculo de Saltar: no se veía. Se vio en la prueba en teléfonos del 12-oct-2026.
- **Causa**: `interfaz/hud.gd` lo ponía en (94 %, 90 %) de una pantalla 16:9, la misma esquina que la distribución
  inicial de los botones táctiles (Saltar en (91 %, 81 %)).
- **Arreglo**: el ícono va bajo las PejeCoins, alineado a la izquierda del grupo de la interfaz, y es un nodo propio
  que gira con `rotation` (además, ya no redibuja corazones, barra y texto en cada tick durante 2 s).
- **Guion que lo cubre**: `banco_sentarse`, `aviso_guardado_se_quita` y `zona_prueba_coleccionable` siguen
  comprobando que el aviso aparece y se quita; dónde se ve es prueba manual (pasó en el S50 el 12-oct-2026).
