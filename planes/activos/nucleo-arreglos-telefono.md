ACTIVO

# Núcleo: arreglos tras la prueba en teléfonos

Rama `fix/telefono-fps-y-controles`, sobre `feature/nucleo-cierre-antes-de-la-sala`. Junta los fallos de la prueba
en el S50 y el S20 del 12-oct-2026 (sección de arreglos de `ESTADO.md`) con los hallazgos de la auditoría de
código muerto y optimización del 12-oct-2026 (IDs O-01 a O-15 y M-01 a M-07). Aprobado el 12-oct-2026.

## Medición de partida (12-oct-2026, S50, APK de depuración con partes apagables, dos dedos reales)

| Sala, modo | Configuración | FPS medios jugando |
|---|---|---|
| Sala Movimiento y Sala Recursos, bajo, teléfono frío | todo normal | 59-60 (también quieto) |
| Sala Recursos, alto | todo normal | 55,9 |
| Sala Recursos, alto | controles sin redibujo por arrastre | 56,8 |
| Sala Recursos, alto | HUD oculto | ~58 |
| Sala Recursos, alto | controles sin dibujar | 59,4 |
| Sala Cámara (con `Fondo`), alto | todo normal | 59,1 |

Con las fases B y C (12-oct-2026, mismo APK sin las partes apagables, batería a 34,4 °C): Sala Recursos en alto,
jugando, 58,4 de media (mínimo 51). Se recuperaron ~2,5 de los ~3,5 FPS de los controles.

Lectura: los 35-40 FPS del 11-oct-2026 fueron con el teléfono caliente, no con el código. Los controles cuestan
~3,5 FPS, casi todo por el dibujo intercalado de arcos y letras (O-02), y el redibujo por arrastre (O-01) ~1. El
HUD cuesta ~2 FPS por el mismo patrón. El fondo (O-04) no cuesta nada medible. Todo en depuración (O-06); falta
la medición en publicación.

## Fases

**B. Controles táctiles** (hecha el 12-oct-2026; `revisor` aprobado) (`nucleo/controles_tactiles.gd`, `nucleo/editor_controles.gd`, `docs/contrato.md`;
pasa por el `revisor`)
- M-06: `BOTONES_SIN_USO` (`mochila`): no se dibuja ni responde, ni en el juego ni en el editor. `ACCIONES`,
  `CENTROS`, `ANCLAS`, `RADIOS` y la versión de los ajustes no cambian.
- O-01: la palanca en dos `Node2D` hijos (base y perilla) que se mueven con `position`; `procesar()` ignora el
  ratón emulado y no redibuja; se redibuja al tocar o soltar un botón y con cambios de habilidades, disposición o
  `editando`.
- O-09: sin arreglos nuevos por cuadro; acciones del juego calculadas una vez.
- O-02, paso 1: `_draw` agrupado (presionados, arcos, etiquetas), 24 segmentos, letra fija de 16.
- Hito: `validar.ps1` con `fallos=0`; `controles_tactiles` (con el caso de Mochila) y `controles_configurables`
  dan `GUION OK`.

**C. Detalles menores** (hecha el 12-oct-2026; sin `revisor`)
- O-07: `Planta` y `Niebla` quietas no procesan. O-08: `Recursos.es_debil()` se calcula una vez.
- O-11: `Fundido` no repinta sin transición (sale al empezar el tick; apagar el proceso atrasaba un tick las
  transiciones al reactivarlo, lo detectaron los guiones `fundido_*`).
- O-12 y fallo 5: el ícono de guardado es un nodo propio que gira con `rotation`, bajo los PejeCoins. HUD agrupado:
  ya estaba agrupado (formas y texto al final); su costo viene de los corazones y queda para la D.
- M-01, M-04 y M-07: se quitan. M-02, M-03 y M-05 se quedan: API del contrato reservada para el contenido.
- Hito: `validar.ps1` con `fallos=0`; los guiones `fundido_*`, `recursos_cuentas`, `mapa_cuentas` y los del HUD y
  el guardado dan `GUION OK`.

**D. Según la medición con B y C** (condicional; decidida el 12-oct-2026)
- Si los controles visibles siguen costando: atlas de aro y disco hecho por código (O-02, paso 2). **No se hace**:
  con B y C, alto da 58,4 de media y bajo (lo que el automático elige en el S50) 59-60; quedaría ~1 FPS por ganar
  en un modo que el S50 no usa por omisión. Se retoma si la medición en publicación o en caliente cae en bajo.
- Si con el teléfono caliente (10 min de juego) cae: tope de 30 FPS estables o resolución menor en bajo.
  **Pendiente**: necesita la prueba en caliente con la persona (10 min en la sala de recursos, en bajo y en alto).

**E. Mapa** (hecha el 12-oct-2026): O-03, el marcador como nodo aparte y las texturas cargadas en `dibujar()`, no en
`_draw`, y soltadas al ocultarse; los nombres y centros de zona se calculan al preparar la vista. Hito: `mapa_cuentas`
con 19 casos (nuevo: el marcador sigue al jugador con el mapa rápido).

**F. Fallos 2 a 4 y señales de `ESTADO.md`** (hecha el 12-oct-2026 salvo el multitoque)
- Multitoque: prueba hecha el 12-oct-2026 (`getevent -lt`, 1 a 4 dedos y jugando, 60 s): el S50 reporta 2 toques
  como máximo. **Pendiente**: dos decisiones de la persona (regla «joystick + un
  botón», salto alto + Atacar).
- Zona de pruebas desplazable, con Volver visible y Atrás a Configuración. Volumen con área de toque de 64 px; lista
  de Recursos con letra 30. Visto en el S50 con `adb`: las 31 salas caben en 5 columnas; Volver y Atrás vuelven a
  Configuración con el foco en «Zona de pruebas»; un toque 21 px sobre la barra mueve el volumen; las opciones de
  Recursos miden unos 45 px. Ahí apareció un fallo nuevo, arreglado: Atrás con la lista abierta subía al menú
  (`docs/errores/2026-10-12-atras-con-lista-de-recursos.md`, 2 casos más en `menu_configuracion`, 38).
- Señales, provisionales hasta el arte: el jugador se pinta blanco mientras dura un congelado y 8 ticks más tras un
  parry (`COLOR_DESTELLO`, `TICKS_DESTELLO_PARRY`); la carrera, azul claro (`COLOR_CORRIENDO`); postes cada 200 px
  en la sala de carrera (`franjas.gd`); «Brújula puesta/quitada» sobre el interruptor 2 s. Filas «Carrera y ataque en
  carrera» y «Parry y congelado» en `docs/pruebas.md`. Vistos en el S50: postes, aviso de brújula y el ícono de
  guardado bajo los PejeCoins. Sin ver: el azul y el destello (con `adb` no se simulan joystick y botón a la vez).

## No se hace y por qué
- O-04 (fondo): medido sin costo.
- O-05 (capas de colisión): toca la física del jugador; va con el contenido y el `revisor`.
- O-10: lo reemplaza el sprite del jugador. O-13, O-14 y O-15: costo despreciable; solo si una medición lo pide.
