CERRADO

# Limpieza de código aprobada

Hallazgos aprobados por la persona el 13-oct-2026 (11, 2, 5, 4, la parte útil del 6, del 3 solo `encima_de`, 7 y 8;
no 1, 9 ni 10). La persona ordenó ejecutarla el 13-oct-2026 en una sesión autónoma, antes de que se fusione el #5:
rama `chore/limpieza-codigo` encima de `feature/nucleo-menu-tactil`; al fusionarse el #5 se rebasa a `main` con
`--onto` y se abre su PR. Regla que manda: no generalizar hasta tener tres casos. Ningún cambio de comportamiento:
cada `.esperado` fija el número de casos, así que un caso perdido hace fallar su guion.

## H1. Base común de las pruebas (hallazgo 11)

- `herramientas/salas/prueba_base.gd`, sin `class_name` (nada fuera de `herramientas/` depende de ella), heredada
  por ruta: `casos`, `fallos`, `_caso(nombre, bien)`, `_resumen()` y `_nombre()` (el del archivo sin `prueba_`;
  `prueba_tactil` la sobrescribe con `controles_tactiles`, lo que imprime hoy). Ayudantes con tres o más casos:
  `_presionar(accion)` (dialogo, marco, reto), `_escribir(ruta, texto)` (guardado, ranuras, controles
  configurables, que pasa a dos argumentos) y `_vale(valor, esperado)` si hay tres; los de dos casos se quedan.
- Fuera: `prueba_vista.gd` (otra firma de `_caso`) y las pruebas sin `_caso`.
- Comprobación: `validar.ps1` y los guiones de cada prueba tocada con el mismo `casos`.

## H2. Constantes repetidas, la parte útil (hallazgo 6)

- 16/9: `Vista.PROPORCION_BASE` en `hud.gd`, `controles_tactiles.gd` y `disposicion_controles.gd`.
- Color de botón: `editor_controles.gd` usa `ControlesTactiles.COLOR_BOTON`.
- Bus: se borra `Sonido.BUS` y se usa `Ajustes.BUS_EFECTOS`.
- Dorado: `Tema.DORADO`, del que toman `FOCO`, `BotonValor.COLOR_SI` y `CajaDialogo.COLOR_QUIEN`.
- `"entregado_"`: `EntregaRecompensas.PREFIJO_ENTREGADO`, también en `herramientas/validar.gd`.
- Inspiración por golpe: `Partida.INSPIRACION_POR_GOLPE`; la variable exportada del jugador la toma por omisión y el
  HUD la lee de `Partida` (el contrato prohíbe que la interfaz lea al jugador).
- No entran (marginales): la ruta del menú y la capa 20.

## H3. Piezas de menú en `Tema` (hallazgos 2, 7 y 8)

- `Tema.boton(texto, tamano)`, `Tema.barra_arriba(titulo, al_volver)` y `Tema.area_menu(vista, reservado_abajo)`,
  usadas por `ranuras.gd`, `nueva_partida.gd` y `configuracion.gd` (pantalla de brillo); `ANCHO_VOLVER` y
  `SEPARACION_ARRIBA` en `Tema` (también `marco_menus.gd`).
- Los `.tscn` conservan sus números (vista previa del editor); un comentario en `tema.gd` dice qué escenas los repiten.
- Rangos de los deslizadores de `editor_controles.tscn`: se borran del `.tscn`; la fuente es `DisposicionControles`.

## H4. Consultas comunes (hallazgos 3 y 4)

- `Jugador.encima_de(area) -> Jugador`: el bucle de cuerpos encima que pueden interactuar, hoy en banco, entrega,
  NPC y reto.
- `Partida.contar_coleccionables(salas)` (la usan `total_coleccionables` y `Ranuras.pasos`) y
  `Partida.estado_entero(sala, objeto, por_omision)` (NPC, reto y sus dos pruebas). Contrato: tabla de `Partida`.
- Crítico (jugador, autoload, contrato): `revisor`.

## H5. Escritura atómica (hallazgo 5)

- `nucleo/archivo.gd` (`class_name Archivo`): `escribir_atomico(ruta, texto)` y `copiar_atomico(desde, hacia)`, con
  los mismos temporales de hoy (`ruta.tmp`, `ruta.bak.tmp`). Los usan `guardado.gd` y `ajustes.gd`. Contrato.
- Crítico (guardado): `revisor`.

## Cierre

`validar.ps1` y los 128 guiones en verde después de cada hito; `revisor` sobre H4 y H5 y sobre el diff completo;
bloque de commit en `commits-pendientes.md`. Entrega: dos commits (H1 a H3 y H4 a H5) y un PR tras el #5.

## Avance

- 13-oct-2026: plan escrito; rama creada.
- 13-oct-2026: H1 a H5 hechos; tras cada uno `OK  VALIDACION ... fallos=0` y `guiones=128 mal=0` (tras H5,
  `archivos=191`). `_vale` y `_borrar` se quedan en sus dos pruebas (dos casos, no tres). `SEPARACION_ARRIBA` no
  se usa en la caja de confirmación de `ranuras.gd`: es otra separación con el mismo número.
- Fuera del plan, en el mismo cambio: lo que cuesta un `Fondo` opaco en el S50, en `docs/contrato.md`
  («Recursos»; una primera versión pedía usar el color de borrado, que hoy es negro fijo para todo el juego en
  `nucleo/arranque.gd`, y se corrigió); las 21 escenas de pruebas y el menú que tienen un `ColorRect` «Fondo» no se tocan aquí. La tabla
  «Grupos» del contrato nombra a todos los que usan el grupo `jugador`.
- 13-oct-2026: `revisor` en contexto nuevo sobre el diff completo: un fallo (el comentario de `Tema` nombraba dos
  escenas que no repiten los números), corregido. `default_bus_layout.tres` solo cambia su encabezado (tiene la forma
  de un reguardado del editor con `uid`; el origen no se comprobó); entra en el commit.
- Entrega en un solo commit y no en dos: `partida.gd`, `jugador.gd` y `docs/contrato.md` mezclan cambios de H2 y
  H4, y separarlos pediría elegir partes de cada archivo a mano. Tras la corrección, `OK  VALIDACION archivos=191 fallos=0`; el
  revisor corrió los 128 guiones con `mal=0`. Plan cerrado.
