# Hueco sin salida en la sala Enemigos Moviles

- **Síntoma:** en el S50 (25-oct-2026), el jugador cae al hueco entre el escalón bajo y el pilar del volador y no
  puede salir. Solo sale de la sala por el menú.
- **Causa:** los escalones de `docs/errores/2026-10-17-escupidor-inalcanzable.md`. El jugador mide 80 × 160 y salta
  230 px.
  - Bajo el escalón bajo (x 1500-1650, cara de abajo en y 900) quedan 140 px: el jugador no pasa por debajo.
  - Para subir encima de él hay que saltar 180 px. Pero entre el escalón bajo y el alto (x 1700-1820, cara de abajo en
    y 720) solo había 50 px. Cualquier lugar del hueco junto al escalón bajo tenía el escalón alto encima, y el salto
    chocaba con él a los 160 px.
  - El pilar (480 px) no se salta desde el suelo.
- **Arreglo:**
  - El escalón alto pasa a x 1840 (x 1780-1900), en `herramientas/salas/sala_enemigos_moviles.tscn`.
  - Entre los dos escalones quedan 130 px sin techo: pegado a la cara derecha del escalón bajo, el salto sube encima.
  - La subida al pilar (escalón bajo, alto y pilar) sigue igual. `moviles_cruzar_pilar.esperado` se midió de nuevo:
    el jugador cae 66 px más a la derecha.
- **Lo cubre:** `herramientas/guiones/nucleo/moviles_salir_del_hueco.guion`.
  - El jugador sube al escalón bajo, cae al hueco y vuelve a subir.
  - Con el escalón alto en x 1760 falla: ni siquiera llega al hueco, porque el escalón alto le tapa el paso sobre el
    bajo.
