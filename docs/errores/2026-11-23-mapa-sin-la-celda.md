# El mapa no mostraba La Celda (#63)

**Síntoma.** En una partida nueva, tras recibir la pluma del mapa del Eterno de `raices_3` y descansar en un banco, el
mapa solo mostraba Las Raíces; La Celda, ya recorrida, no aparecía ni en la vista alejada (22-nov-2026, S50).

**Causa.** Una sala visitada se marca al descansar solo si la partida tiene el mapa de su zona
(`Partida._al_descansar` en `nucleo/partida.gd`), y nada en el juego entregaba el mapa de La Celda: el Eterno de
`raices_3` daba la pluma y el mapa `raices`. El índice del mapa ya tenía las salas de las dos zonas.

**Arreglo.** La ficha del Eterno de `raices_3` (`contenido/npc/guia_raices/guia_raices_1.tres`) entrega también el mapa
`celda`. Una partida que ya habló con él no lo recibe: el Eterno no repite sus premios.

**Qué lo cubre.** `herramientas/guiones/contenido/raices_3_guia.guion` (dos avisos `mapa_obtenido`) y
`herramientas/guiones/mapa/mapa_cuentas.guion`: con las recompensas de esa ficha, el banco marca `celda_1` y
`raices_3`, y el mapa alejado dibuja las dos zonas con su nombre.
