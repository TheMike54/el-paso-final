CERRADO

# Núcleo: reto de preguntas (sin cambiar el guardado)

La persona pidió el 13-oct-2026 «mochila + reto de preguntas». La propuesta de diseño pagada esa noche suma un
inventario (`Partida.objetos`) que obliga a subir el guardado de la versión 3 a la 4: todas las partidas guardadas
quedarían incompatibles. Esa parte y el nombre «mochila» (la acción ya abre los amuletos) quedan como decisión de la
persona (`ESTADO.md`). Este plan hace solo el reto, con lo que ya existe.

## Decisiones (13-oct-2026, provisionales hasta que la persona las vea)

- `FichaPregunta` (`Resource`): `pregunta`, de 2 a 3 `opciones` (las que caben en la fila de `CajaDialogo`) y
  `correcta`. `fallos()` como `FichaDialogo`.
- `RetoPreguntas` (`Area2D`, `nucleo/reto_preguntas.tscn`), aparte del `Npc` (otro ciclo: rondas, no etapas):
  `id`, `quien`, `preguntas`, `meta` (aciertos para ganar), `recompensa` y los textos de acierto, fallo y ganado.
  Con el jugador encima y en el suelo, `interactuar` abre una `CajaDialogo` con las preguntas que faltan de la ronda,
  cada una seguida de «¡Correcto!» o de la respuesta correcta. El jugador queda quieto con
  `Jugador.empezar_a_hablar()` (sin cambios en `jugador.gd`).
- Estado como números en el estado de su sala, igual que la etapa del `Npc`: `<id>_indice`, `<id>_aciertos` y
  `<id>` (`true` al ganar). Sin barajar: van en el orden de la lista; «sin repetir» vale dentro de la ronda. Cada
  respuesta cuenta y autoguarda (cerrar la app no la deshace); un golpe o salir corta la ronda donde iba.
- Al acabar la ronda: con `meta` aciertos o más se gana, se entrega la recompensa una sola vez y desde entonces dice
  el texto de ganado; si no, la ronda vuelve a empezar en cero (sin otro castigo).
- `CajaDialogo` gana la señal `opcion_elegida(linea, opcion)`, emitida antes de pasar a la línea de destino.
- El validador revisa cada `FichaPregunta` y cada `RetoPreguntas` (id único y no reservado, preguntas sin fallos,
  `meta` entre 1 y el número de preguntas).
- Prueba en `herramientas/salas/sala_reto.tscn` (grupo «Salas») con tres preguntas escolares y 50 PejeCoins.

## Hitos

1. `FichaPregunta`, `opcion_elegida`, `RetoPreguntas` y validador.
2. Sala, fichas, `prueba_reto.gd` y guiones.
3. `validar.ps1` y todos los guiones; documentos (`docs/contrato.md`, `docs/pruebas.md`); APK en el S50.

## Cierre (13-oct-2026)

- Hitos 1 a 3 hechos. `reto.guion` (17 casos); `validar.ps1` y todos los guiones en verde. Mutaciones comprobadas:
  sin revisar que ya se ganó, la prueba falla (después de agregar el caso de recargar la sala, que la primera vez no
  la atrapaba), y con `meta` 4 en la sala de prueba el validador la rechaza.
- En el S50 (adb): sale la pregunta con sus opciones; tocar la caja no elige (fallo encontrado ahí, en
  `docs/errores/2026-10-13-toque-en-la-caja-elegia-la-opcion.md`); la opción correcta dice «¡Correcto!»; tres aciertos
  dan «¡Lo logré! Toma.» y 50 PejeCoins. El triángulo quedaba detrás del jugador: subió a 184 px y ya se ve encima.
- `revisor`: sin fallos.
- Para la persona: si el reto es la forma de recuperar lo perdido al morir (`docs/idea.md`) o un premio aparte, y el
  inventario con su versión 4 del guardado (`ESTADO.md`).
