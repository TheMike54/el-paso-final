# Validador

Parte del contrato (`docs/contrato.md`): lo que revisa `herramientas/validar.gd` en las salas, las escenas y las fichas, y que `validar.ps1` corre antes de dar algo por terminado. Cada regla tiene una entrada `validador-*` en `herramientas/funciones.json`; una regla nueva entra a este archivo y a su entrada en el mismo cambio. Los avisos (que no cuentan como fallo) están en `docs/contrato.md`, «Avisos del validador».

## Salas y escenas
- Cada sala con id bajo `contenido/` tiene `ficha_zona`; las de `herramientas/` pueden dejarla vacía. Dos salas
  de una misma zona con ficha usan el mismo `resource_path`; fichas con rutas distintas fallan
  (`validador-ficha-zona`).
- El validador revisa cada sala con id: id `<zona>_<número>` igual al archivo, en la carpeta de su zona y sin
  repetir; `limites` con área y que empieza en `(0, 0)`; `Entrada` dentro de `limites`; cada puerta con id único y destino existente, nombrado por id; puertas
  de ida y vuelta (si A lleva a la puerta P de B, P lleva de vuelta a la misma puerta de A), salvo una puerta `ABAJO`,
  que es de ida sola: basta que P exista en B (la sala de abajo la usa como llegada). Exigir la vuelta obligaría a poner
  abajo una puerta `ARRIBA` a la que no se llega, con su llegada sobre el hueco, que devolvería al jugador a la caída; y
  una puerta de caída provisional puede llegar a una puerta que ya existe sin un nodo de más; cada `FondoTapado` deja ver
  algo (`fin_pared`, en coordenadas de la sala, antes de `limites.end.x`); bancos con id
  `banco_<id>`; la raíz de cada escena de esas carpetas es una `Sala`; suelos frágiles, muros rompibles, palancas, portones,
  recogibles que se recuerdan por id (`Coleccionable`, `MonedasSueltas`), `Npc`, `RetoPreguntas` y `Tienda` con id (sin él, falla) único en la sala, también
  dentro de una pieza instanciada; en `contenido/`, `habilidades_de_prueba` vacío e `inspiracion_maxima_de_prueba`
  en 0. En cualquier escena, toda ruta de nodo que la escena guarda para una variable de script resuelve (`tapas`, `descubre`,
  `portones`, `encendida`, `destello`; un export en null a propósito no guarda ruta); las `tapas` y lo que `descubre` un
  `MuroRompible` van fuera del muro y ninguno en las dos listas, y lo que descubre no tiene física (ni un
  `CollisionObject2D` dentro); la animación `entregar` de un `Npc` no va en bucle. En cualquier escena, además, el id de cada `Coleccionable` empieza con `coleccionable` y el de cualquier otro
  recogible no empieza con `coleccionable` ni `entregado_`; cada `Npc` tiene conversaciones, ninguna vacía, un id que no empieza con `coleccionable` ni
  `entregado_` y fichas sin fallos (`FichaDialogo.fallos()`, que también revisa cada `.tres` de ficha suelto); cada
  `RetoPreguntas`, un id igual de libre, `meta` entre 1 y el número de preguntas y preguntas sin fallos
  (`FichaPregunta.fallos()`, también en cada `.tres` suelto); cada puerta lleva a un id de sala o a una ruta `res://`
  que existen, y nunca a la ruta de una sala con id (una puerta en `contenido/` o en una zona de prueba nombra su
  destino por id, así una sala se puede mover de carpeta); cada `Tienda` vende algo y cada artículo tiene id sin repetir
  en su tienda, precio mayor que 0 y una `Recompensa`; cada `Estacion` va sola en su sala, es hija directa de una sala con id, se llama
  `estacion_<id de la sala>`, cuesta 0 o más y está en la tabla de su sala (`Estacion.tabla_de`) con esa sala, y cada
  `FichaEstaciones` no tiene ids repetidos ni mal nombrados (`FichaEstaciones.fallos()`); cada habilidad de un
  `ObjetoHabilidad`, de una recompensa, del requisito de un artículo y de `habilidades_de_prueba` está en
  `Habilidades.TODAS`; cada `AvisoAccion` enseña 1 o 2 acciones del InputMap, lleva id en `UNA_VEZ` y no lo lleva en `POR_VISITA`, y su id, si lo tiene, no se repite en la
  escena ni con otro objeto que se recuerda en la sala, ni usa un prefijo reservado; cada acción de
  `botones_por_ensenar` es un botón de la pantalla y algún aviso de la sala la enseña; cada acción de `botones_ocultos`
  es un botón de la pantalla; cada puerta en el borde izquierdo
  o derecho de `limites` lleva detrás su pared, y la llegada de cada puerta cae dentro de `limites` y, salvo en una
  `PUERTA`, deja el cuerpo del jugador fuera de su área (`docs/contrato.md`, «Cambio de sala»). En cualquier escena, también: ninguna forma
  de una vía salvo la de una `PlataformaDelgada`, que no va dentro de algo que se mueve (`docs/contrato.md`, «Suelos y plataformas»);
  ningún cuerpo de física dentro de un `Vaiven` o un `Giro` salvo el nodo mismo, y ningún `DanoContacto` con `peligro`
  dentro de algo que se mueve (`docs/componentes.md`, «Componentes»); cada `ZonaCamara` y cada `RegionMusica` llevan su forma como
  `CollisionShape2D` hija directa, con forma y encendida, y una `ZonaCamara` en una sala tiene `limites` con área dentro
  de los de la sala; el tema de cada sala (`tema_musica`), el de cada `RegionMusica` y `Musica.TEMA_MENU` se repiten
  (Ogg o MP3 con `loop`, WAV con `loop_mode`; otro tipo falla; vacío y `Musica.SILENCIO` no se revisan): un tema que
  se apaga deja la sala callada sin que nadie lo pida. Esta es la lista completa de lo que revisa en las
  salas (`herramientas/validar.gd`); lo de recursos, presupuesto e importación está en `docs/arte-y-rendimiento.md`, «Recursos», y el mapa, en
  `posicion_mapa`.

- Cada `ArenaJefe`, también como raíz de una pieza, tiene `id_jefe`, referencia a `jefe` y una
  `CollisionShape2D` hija directa con forma y encendida. Sus recompensas pasan las reglas de habilidades y equipo
  de las demás entregas (`validador-arena-jefe`).
