# Menús que se salían de la pantalla o se cortaban

Fecha: 2026-10-12. Rama `feature/nucleo-menu-tactil`.

## Síntoma
- En el Senwa S50 la primera columna de Configuración se veía cortada unos píxeles a la izquierda (captura de la
  persona con `adb`).
- En la vista de 1280 (ventanas 4:3 y 16:9), Configuración salía en 3 columnas y la tercera se salía por la derecha.
- En la vista de 1280, el panel «Botones del control» medía 1298 px de alto en una vista de 720: «Restablecer»
  quedaba fuera de la pantalla.

## Causa
- S50: tres celdas de 420 con 24 px entre ellas suman 1308 de los 1312 px útiles; sin holgura, el
  `ScrollContainer` corría la cuadrícula.
- 1280: con `horizontal_scroll_mode = 0` (desactivado), el `ScrollContainer` pasa hacia arriba el ancho mínimo de su
  cuadrícula; el panel crecía a lo ancho de tres columnas y el cálculo de columnas leía ese ancho inflado.
- Panel del control: al armarse, las etiquetas con ajuste de línea lo inflan un momento (ancho casi cero, una letra
  por línea). Un `Control` que no es contenedor no se encoge solo cuando su mínimo baja.

## Arreglo
- `Tema.SEPARACION` de 24 a 16: tres columnas miden 1292 de 1312.
- `horizontal_scroll_mode = 3` (permitido, sin barra) en las listas de Configuración, del control y de la zona.
- `Tema.ajustar` reacomoda el panel también con `minimum_size_changed`.
- Además, el dorado del estado encendido se confundía con el foco: presionado y encendido se ven más claros y el
  dorado queda solo para el foco. Desde el 14-oct-2026 lo encendido es verde (`Tema.ENCENDIDO`).

## Qué lo cubre ahora
Las columnas por ancho, los casos de `menu_configuracion.guion` (`Configuracion.columnas_para`). Lo visual no lo
cubre un guion: `--resolution` no cambia la vista en headless. Lo cubre la fila «Menús en cada ancho» de
`docs/pruebas.md` (capturas en ventana de los cinco anchos).
