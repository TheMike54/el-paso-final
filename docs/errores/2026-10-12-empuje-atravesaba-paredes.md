# El empuje de un golpe sacaba al enemigo de la sala

**Síntoma** (Senwa S50, 12-oct-2026, prueba «Parry y congelado»): en la sala de combate, golpeando al muñeco verde
una y otra vez, se le empujaba hasta la puerta de la izquierda y desaparecía de la pantalla.

**Causa**: `nucleo/golpeable.gd` empujaba a su padre cambiando `position.x` unos ticks, sin mirar qué había
adelante. El muñeco y los enemigos son `Node2D`, no cuerpos de física, así que nada los detenía: atravesaban las
paredes y, donde no había pared (la puerta de la sala de combate), salían de los límites de la sala. Le pasaba a
todo lo que lleva un `Golpeable`, no solo al muñeco.

**Arreglo**: `nucleo/golpeable.gd`: antes de mover, un rayo a media altura de su forma busca un `StaticBody2D`
adelante (pared, escalón, plataforma móvil) y el paso se recorta para que la forma quede pegada a él; también se
recorta para que no salga de los `limites` de su `Sala`. Al topar, el empuje se acaba. Los demás cuerpos (el
jugador) no lo detienen.

**Guiones que lo cubren**: `herramientas/guiones/nucleo/golpe_contra_pared.guion` (sala de golpe, empujado a la
derecha: queda en x=1120, contra la pared; sin el arreglo, x=1204) y `golpe_borde_sala.guion` (sala de combate,
empujado a la izquierda hacia la puerta: queda en x=40; sin el arreglo, x=-100).
