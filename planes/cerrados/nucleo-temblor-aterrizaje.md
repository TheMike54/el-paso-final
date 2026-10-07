CERRADO

# Núcleo: temblor de cámara al aterrizar tras una caída

Pedido por la persona el 07-oct-2026: al aterrizar tras una caída, que la cámara tiemble un poco, como recuerda de
Hollow Knight. Los valores no tienen fuente (los de Hollow Knight están en los recursos del juego, no en su código):
son propiedades exportadas para afinarlas en el teléfono. Aprobado por la persona el 07-oct-2026; la picada también
tiembla. Aplicado y revisado por el `revisor`; lo que queda es del teléfono (entrada `temblor-al-aterrizar`). Se
cerró el 07-oct-2026; el aterrizaje duro que lo acompaña sigue en `planes/cerrados/nucleo-aterrizaje-duro.md`.

## Decisiones

1. **Cuándo tiembla.** Primero por velocidad (≥ 1000 px/s al aterrizar). En el S20 temblaba en caídas cortas (sala de
   pared, sin llegar a la mitad), así que la persona pidió el mecanismo de Hollow Knight: **tiempo cayendo a
   velocidad máxima**. Tiembla el aterrizaje tras `ticks_caida_dura` (18, 0,3 s) ticks seguidos a
   `velocidad_caida_max`: unos 794 px con la caída de hoy y 650 con `distancia_caida_inicial` en 0. Pared, pogo,
   impulso o retroceso reinician la cuenta. **La picada tiembla siempre** al aterrizar, a cualquier altura; romper un
   `SueloFragil` no es aterrizar.
2. **Cuánto.** 8 px y 12 ticks casi no se veían en el S20; después 20 px y 24 ticks. Ahora **20 px en vertical y un
   tercio en horizontal, 18 ticks (0,3 s)**, bajando en línea recta hasta 0. Provisional.
3. **Cómo.** Solo el `offset` de la `Camara`, con un patrón fijo y sin azar: el vertical cambia de signo cada 2 ticks
   y el horizontal cada 3, para que el punto no dé vueltas en círculo. `temblor_x` y `temblor_y` son públicas.
4. **Límites, pausa y repetición.** Los `limit_*` no recortan el `offset` en ningún eje (medido el 07-oct-2026); en el
   borde de la sala asoma hasta 20 px de fuera durante 0,3 s. Un jugador muerto también tiembla (aceptado). En pausa
   queda congelado. Aterrizar otra vez durante un temblor lo reinicia, no lo suma.
5. **Apagarlo.** Clave `temblor` en `user://ajustes.json`, encendida por omisión, con su interruptor en la pausa.
6. **Bus de eventos.** El temblor vive en el jugador. La vibración al aterrizar llegó después, con la señal
   `jugador_aterrizo` (plan del aterrizaje duro).

## Cómo se comprueba

- Guiones (leen `temblor_x` y `temblor_y`, no el `offset`, que depende del ajuste de cada equipo): `camara_temblor`,
  `camara_temblor_termina`, `camara_temblor_salto`, `camara_temblor_corta`, `camara_temblor_picada`,
  `camara_temblor_picada_baja`, `camara_temblor_picada_ras` y `camara_temblor_picada_fragil`. La clave `temblor`, en
  `guardado.guion`.
- En el S20: el paso al `offset`, el interruptor de la pausa, el mareo y si 20 px y 0,3 s se sienten bien.
