# Punto seguro sobre una plataforma que se mueve

- **Síntoma:** en una sala con una plataforma que va y viene sobre un peligro (cables pelados), el jugador que caía
  de la plataforma al peligro volvía a un punto en el aire, donde ya no estaba la plataforma, y caía otra vez al
  peligro: perdía una vida tras otra hasta morir. Visto en el S50 el 26-oct-2026.
- **Causa:** el punto seguro se tomaba de cualquier suelo pisado `ticks_suelo_firme` ticks seguidos, sin mirar qué
  era ese suelo. Sobre la plataforma (un `AnimatableBody2D` con `Vaiven`) se juntaban puntos seguros, y al volver a
  ellos la plataforma ya se había ido. Nadie comprobaba al usar el punto si debajo seguía habiendo suelo, así que lo
  mismo pasaba con un `SueloFragil` roto o un `Porton` que se abre.
- **Arreglo:** dos capas en `nucleo/jugador.gd`.
  - Al guardar: un tick cuenta como suelo firme solo si un rayo bajo los pies (`Capas.rayo_a_escenario`, en el
    centro y en cada orilla del cuerpo) encuentra un sólido que no se mueve según `Vaiven.movil_de`, la misma lista
    que usa el validador para los peligros. No se usan los choques de `move_and_slide`: quieto sobre el elevador en
    su pausa no siempre registra uno (`tutorials/physics/using_character_body_2d.rst:160`).
  - Al usar el punto (`ultimo_punto_seguro()`, también para la mochila, y el anti-bucle): el punto seguro más viejo
    que todavía tiene suelo fijo debajo; si ninguno, la llegada a la sala, la `Entrada` o un banco
    (`Sala.puntos_de_respaldo()`) con suelo; si tampoco, el suelo fijo que haya bajo la llegada. Como Silksong, que
    busca el suelo con un rayo al reaparecer (`TryFindGroundPoint`).
  - Ese último rayo (`_suelo_fijo_bajo`) arranca 8 px sobre la llegada y se repite excluyendo cada pieza que se mueve
    hasta dar con un sólido fijo: con un solo rayo, una llegada sobre un elevador devolvía la llegada misma, en el
    aire. Solo sin ningún sólido fijo debajo dentro de la sala devuelve la llegada tal cual.
- **Lo cubre:** `herramientas/guiones/nucleo/plataformas.guion` (`herramientas/pruebas/prueba_plataformas.gd`):
  - tras 120 ticks sobre la plataforma, un peligro vuelve al último suelo fijo (x 700) y no a la plataforma;
  - 40 ticks quieto sobre el elevador en su pausa tampoco dejan punto seguro;
  - roto un suelo frágil sobre los pinchos, el peligro lleva a la `Entrada` y la mochila tampoco queda en el aire;
  - bajo una llegada sobre el elevador en su pausa de arriba, el rayo largo da el suelo fijo (y 680) y no el elevador.
