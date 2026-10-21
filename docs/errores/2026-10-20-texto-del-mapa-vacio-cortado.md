# El texto del mapa vacío se cortaba

- **Síntoma:** al abrir el mapa sin ninguna sala mapeada, el aviso «Aún no hay nada en el mapa» se veía cortado.
  Apareció en las capturas de la auditoría del 18-oct-2026.
- **Causa:** `mapa/lienzo_mapa.gd`, en `_draw`, dibujaba el texto centrado en una caja fija de 320 px (empezaba en
  `size.x / 2 - 160`). Con la letra de la página a 28 px, el texto mide más de 320 px, y `draw_string` recorta lo que
  no cabe en ese ancho.
- **Arreglo:** el texto se centra en todo el ancho del lienzo: empieza en x = 0 con un ancho de `size.x`
  (`mapa/lienzo_mapa.gd:102-103`).
- **Lo cubre:** que el texto se vea completo es dibujo, y por regla no tiene guion (`CLAUDE.md`, «Decisiones
  cerradas»). Lo cubre la prueba manual «Mapa» de `docs/pruebas.md`: antes del banco, el aviso se lee completo. La cuenta que decide si hay
  salas dibujadas (`salas_dibujadas`) sí la cubre `herramientas/guiones/mapa/mapa_cuentas.guion`.
