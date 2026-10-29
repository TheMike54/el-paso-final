# Morir durante el retraso de un cambio de sala dejaba la pantalla en negro

## Síntoma

Encontrado leyendo el código en la revisión de cierre; no se vio jugando. Si el jugador muere mientras corre el
retraso de un `Fundido.cambiar_sala` con jugador (la entrega de la Pluma en `celda_3` espera 72 ticks), no reaparece:
la pantalla queda en negro y no cambia de escena. Hoy no se alcanza en ninguna sala, porque `celda_3` no tiene
peligros ni enemigos y las puertas usan un retraso corto con el jugador inmune.

## Causa

`Sala._reaparecer_en_el_banco` pedía el cambio una sola vez, en el tick fijo antes del final de la muerte. El
`Fundido` lo rechazaba porque el cambio anterior seguía en curso: ese cambio solo se aborta, porque su jugador murió,
al llegar al negro, que con un retraso largo llega después. Nadie volvía a pedirlo.

## Arreglo

`_reaparecer_en_el_banco` devuelve si el `Fundido` aceptó el cambio. Si no lo aceptó, la sala lo vuelve a pedir en cada
tick hasta que el cambio anterior se aborta y el suyo entra. De paso, `Fundido.cambiar_sala` rechaza una ruta vacía,
que antes dejaba la pantalla en negro sin cambio y sin `cambio_fallido`.

## Guion que lo cubre

`herramientas/guiones/nucleo/transicion` (caso «con otro cambio en curso la sala reintenta reaparecer» de
`herramientas/pruebas/prueba_transicion.gd`).
