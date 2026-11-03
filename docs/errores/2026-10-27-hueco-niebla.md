# La pieza de niebla dejaba un hueco al avanzar

- **Síntoma:** en `nucleo/piezas/niebla.tscn`, a medida que la `Deriva` avanzaba, se abría a la izquierda de la
  pantalla una franja sin niebla del ancho de lo avanzado (hasta la pantalla entera antes de dar la vuelta). Lo
  encontró la revisión del bloque antes de que una sala usara la pieza; se midió dibujándola con ventana en la PC.
- **Causa:** el `Parallax2D` de la pieza llevaba `repeat_times = 1`. Medido el 27-oct-2026 con la cámara en seis
  posiciones (de x=-700 a x=20000) y el avance en 0, 444, 888, 1332, 1700 y 1775 px: con 1, el motor deja una copia
  hacia un solo lado de la que tiene en pantalla, y como la `Deriva` mueve el dibujo dentro del `Parallax2D`, el lado
  sin copia queda vacío. La documentación solo dice que las copias se reparten desde el original
  (`classes/class_parallax2d.rst:187`). El `NieblaCapa` de `celda_1` usaba 3 y por eso no se veía.
- **Arreglo:** `repeat_times = 2` en la pieza. Con 2, en las 36 combinaciones la racha más larga sin niebla en la fila
  del centro es de 36 px, la misma que con avance 0: son zonas donde el ruido vale casi 0, no huecos.
- **Lo cubre:** `herramientas/guiones/nucleo/piezas_sala.guion` (`prueba_piezas_sala.gd` exige `repeat_times >= 2`
  en la pieza). Que se vea sin hueco se comprueba a ojo con la niebla encendida en la sala que la use.
