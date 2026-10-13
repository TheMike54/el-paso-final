CERRADO

# Núcleo: base de diálogo y un NPC guía

La persona lo pidió el 13-oct-2026 («base de diálogo y NPC guía que te entrega, adelante»). Base: la propuesta de
diseño hecha esa noche con los créditos de la API sobre el commit `09a7943`, ajustada al árbol actual. Toca el
jugador (punto crítico): pasa por el `revisor`.

## Decisiones (13-oct-2026, provisionales hasta que la persona las vea)

- Datos: `LineaDialogo` (quién, texto, hasta 3 opciones con su destino: otra línea, `FIN` o `CANCELAR`) y
  `FichaDialogo` (líneas y recompensas). `Recompensa.Tipo` gana `MAPA` al final (no cambia los enteros guardados):
  el guía de `docs/idea.md` entrega arma y mapa.
- Jugador: estado `hablando`, como `descansando`: quieto con gravedad; un golpe o un peligro lo cortan. El tick
  después de cerrar no salta ni ataca. El banco y la entrega de recompensas no responden mientras se habla. Sin
  `get_tree().paused`: chocaría con la pausa y el mapa.
- `CajaDialogo` (`CanvasLayer` capa 12, armada en código): letra por letra en ticks (2 por letra); `interactuar`,
  `saltar`, `atacar` o tocar la caja completan la línea y después la pasan; las opciones van en fila y se eligen con
  izquierda y derecha o tocándolas. La crea el `Npc` al hablar y la libera al terminar. Corre con el juego (se
  detiene con la pausa).
- `ControlesTactiles.hablando` (estático, como `editando`): mientras se habla, solo Pausa se dibuja y responde.
- `Npc` (`Area2D`, con `id` y una ficha por etapa): con el jugador encima y en el suelo, `interactuar` habla; un
  triángulo arriba avisa que se puede. La etapa es un número en `Partida.salas` (sin cambio de formato): terminada
  contando entrega las recompensas una sola vez y autoguarda; la última conversación se repite sin entregar.
- El validador exige `id` único a los `Npc` de las salas con id, y revisa cada `FichaDialogo`: opciones y destinos
  del mismo tamaño, a lo más 3, destinos válidos y texto no vacío. Un `id` de `Npc` no empieza con `coleccionable`
  ni `entregado_`.
- El guía de prueba vive en una sala de la zona de pruebas (`herramientas/salas/sala_dialogo.tscn`, grupo «Salas»):
  saluda, pregunta «¿Quieres el mapa?» (Sí / No) y con Sí entrega la pluma y el mapa de la zona de prueba. Su ficha
  del juego (en `contenido/`) espera a la primera sala real.

## Hitos

1. Datos, `Recompensa.Tipo.MAPA`, `Jugador.hablando`, banco y entrega.
2. `CajaDialogo`, `ControlesTactiles.hablando`, `Npc` (`nucleo/npc.tscn`).
3. Validador; sala, fichas, `prueba_dialogo.gd` y guiones (`dialogo_completo`, `dialogo_quieto`, `dialogo_no`).
4. `validar.ps1` y todos los guiones; `revisor`; documentos (`docs/contrato.md`, `docs/jugador.md`,
   `docs/pruebas.md`, `herramientas/CLAUDE.md`); APK en el S50.

## Cierre (13-oct-2026)

- Hitos 1 a 4 hechos. `dialogo.guion` (22 casos, con el que se agregó tras el `revisor`) y los guiones `dialogo_completo`, `dialogo_quieto` y `dialogo_no`;
  `validar.ps1` y todos los guiones en verde. Mutaciones comprobadas: sin el tope de etapa la prueba falla, y sin
  que un golpe quite `hablando` también.
- En el S50 (adb): el triángulo al acercarse; con la caja solo queda Pausa; un toque pasa la línea; «No» cierra sin
  dar nada; «Sí» llega a «Toma, y suerte.»; la tercera vez dice la segunda conversación; la pausa abre después.
- `revisor`: 1 fallo de un tick (un golpe en el mismo tick que cierra la última línea podía contarla): `_cerrar`
  ahora le quita la ficha a la caja antes de liberarla, con un caso en `prueba_dialogo.gd`. Ese caso no reproduce la
  carrera (sin el arreglo también pasa): el arreglo queda como defensa. `herramientas/CLAUDE.md` no se tocó (es
  instrucción de Claude y su regla remite a `docs/contrato.md`, «Sala», que sí se actualizó); el comentario de
  cabecera de `validar.gd` sí.
- Para la persona: el guía de prueba entrega la pluma del mapa y el mapa; el guía del juego (`docs/idea.md`) entrega
  el arma (`pluma`) y el mapa. Su ficha en `contenido/` espera a la primera sala real.
