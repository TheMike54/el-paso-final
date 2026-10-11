# Caída sin fin al salir por la derecha de `sala_puerta_b`

**Síntoma** (Galaxy S20, 07-oct-2026): en `sala_puerta_b` el jugador camina a la derecha, sale de la sala y cae
sin fin. Nada lo devuelve: ni muere ni vuelve a un punto seguro.

**Causa**: dos cosas juntas. La sala mide 1280 de ancho, su piso acaba en x=1280 y no tenía pared derecha. Y
salir de los límites de una sala no tenía ninguna regla: el jugador seguía cayendo. Antes del fondo extendido
(`planes/activos/nucleo-pantalla-completa.md`) el borde gris dejaba ver dónde acababa la sala; con el fondo
extendido ya no se nota.

**Arreglo**:
1. `herramientas/salas/sala_puerta_b.tscn`: pared derecha (`ParedDerecha`, 40×720, de x=1240 a 1280).
2. Regla general en `nucleo/jugador.gd` (`_revisar_salida_por_abajo`): si los pies pasan más de
   `margen_fuera_de_sala` (160 px, el alto del cuerpo) del borde de abajo de `limites`, cuenta como un peligro:
   `recibir_dano(1, x, true)`, pierde una vida y vuelve al último suelo firme. Solo por abajo (`docs/contrato.md`).

**Guiones que lo cubren**: `herramientas/guiones/nucleo/jugador_salida_abajo.guion` (sala nueva
`herramientas/salas/sala_salida_abajo.tscn`, piso hasta x=800 y sin pared: sin la regla el jugador acaba en y=2114)
y `herramientas/guiones/nucleo/sala_puerta_b_pared.guion` (sin la pared, el jugador cae, pierde una vida y vuelve a
x=1234 en lugar de quedar contra la pared en x=1200).
