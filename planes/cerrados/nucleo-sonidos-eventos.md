CERRADO

# Núcleo: efectos conectados a los eventos

La persona lo pidió el 13-oct-2026 («sonidos conectados a eventos»), después de los sonidos de prueba del panel
Audio. Base: la propuesta de diseño hecha esa noche con los créditos de la API, recortada. Toca el bus de eventos y el
jugador (puntos críticos): pasa por el `revisor`.

## Decisiones (13-oct-2026, provisionales hasta que la persona las vea)

- `Sonido` (`nucleo/sonido.gd`) lo crea `Arranque`, no la sala: así nada se corta al cruzar una puerta o salir al
  menú, sin autoload nuevo. Escucha el bus como `Vibracion`.
- Datos en `FichaSonidos`: un `AudioStream` por evento, su tono y una variación al azar. Por ahora solo
  `nucleo/sonidos/sonidos_prueba.tres` (los dos sonidos sintetizados de prueba, distinguidos por tono). Cargar una de
  `contenido/` sería una excepción nueva de `nucleo/CLAUDE.md`: lo decide la persona (el `revisor` lo marcó cuando
  el código ya la buscaba ahí, y se quitó).
- Señal nueva `jugador_salto`, emitida en el único lugar donde el jugador despega (cubre suelo, coyote, pared y
  doble salto).
- 4 voces en el bus `Efectos`, cada efecto en la siguiente; el mismo evento no repite antes de 3 ticks, salvo daño y
  parry. Sin pantalla cuenta y no toca.
- Fuera: la música por zona, el sonido de los botones, abrir el mapa y la moneda (no hay señal ni pieza de moneda).

## Hitos

1. `FichaSonidos`, `Sonido`, `jugador_salto`, `Arranque`; ficha de prueba.
2. `prueba_sonido.gd` y `sonido.guion`; `bus_eventos.esperado` con la señal nueva.
3. `validar.ps1` y todos los guiones; `revisor`; documentos; APK en el S50.

## Cierre (13-oct-2026)

- Hitos 1 a 3 hechos. `sonido.guion` (9 casos) y `bus_eventos.guion` con 19 señales; `validar.ps1` y todos los
  guiones en verde.
- `revisor`: 1 fallo: el código buscaba primero una ficha en `contenido/`, que sería una excepción nueva de
  `nucleo/CLAUDE.md`. Se quitó; queda solo la ficha de prueba y la decisión, para la persona.
- APK en el S50 instalado; cómo suenan (tono, volumen, si cansan al repetirse) solo lo juzga la persona:
  `sonidos-telefono` de `nucleo/funciones.json`.
