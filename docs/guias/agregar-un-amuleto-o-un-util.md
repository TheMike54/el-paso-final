# Agregar un amuleto o un útil

**Para qué sirve:** sumar al juego un amuleto (gasta carga y cambia números del jugador o del botín) o un útil (va
en su propia ranura y lo lee una pieza concreta, como la brújula), y darlo en una sala.

**Antes de empezar:** haber hecho `docs/guias/empezar.md` y `docs/guias/como-trabajamos.md`; leer en `docs/contrato.md` la sección «Amuletos y útiles» y, en «Estado de la partida», las filas de carga y útiles; las pantallas, en `docs/interfaz.md`, «Pantallas de amuletos y útiles».

## Amuleto

1. Elegir un id estable (`StringName`, minúsculas y `_`). No se renombra después: lo guarda la partida.
2. Agregar su ficha al catálogo del juego, `contenido/equipo.tres` (`CatalogoEquipo`, lista `amuletos`), como un
   `FichaAmuleto`: `id`, `nombre`, `descripcion`, `costo` (1 a 3) y, en «Efectos», solo los campos que cambia. Los
   valores por omisión no hacen nada. Modelo, un amuleto por efecto: `herramientas/salas/fichas/equipo_prueba.tres`.
   La parte de una ficha, de ese archivo:

   ```
   [sub_resource type="Resource" id="amuleto_velocidad"]
   script = ExtResource("2_amuleto")
   id = &"amuleto_velocidad"
   nombre = "Tenis de prueba"
   descripcion = "Caminas más rápido."
   costo = 1
   velocidad_factor = 1.25
   ```

   Lo más seguro es editarlo en el editor: doble clic en `contenido/equipo.tres` en el panel FileSystem y, en el
   inspector, la lista `Amuletos`. A mano: el primer amuleto del juego necesita además, arriba del archivo, el
   `ext_resource` del script (copiar la línea `2_amuleto` de `equipo_prueba.tres`, con su `uid`) y la lista
   `amuletos = Array[ExtResource("2_amuleto")]([...])` en `[resource]`, como en ese archivo; la cabecera y cada
   `ext_resource` llevan `uid` (`docs/contrato.md`, «Sala», viñeta «uid»).
3. Validar enseguida: `.\herramientas\validar.ps1` tiene que imprimir `OK  VALIDACION ... fallos=0`.
4. Los efectos que hay son los cuatro de la ficha. Un efecto nuevo (alcance, curar más rápido) no es una ficha: es
   un campo nuevo en `nucleo/ficha_amuleto.gd`, su suma en `Partida.efectos_amuletos()` y quien lo aplica; es un
   cambio de más de un archivo y lleva plan (`docs/guias/como-trabajamos.md`).
5. Icono: una imagen importada en el campo `icono` (cómo entra una imagen al juego: `docs/guias/arte.md`). Sin él,
   la página dibuja el amuleto de gis.

## Útil

1. Id estable, como el amuleto.
2. Su ficha en `contenido/equipo.tres`, lista `utiles`, como `FichaUtil`: `id`, `nombre`, `descripcion` e `icono`.
   Modelo: la brújula, en ese mismo archivo.
3. Un útil no tiene números: lo que hace lo programa la pieza que lo usa, preguntando `Partida.util_equipado(id)`
   (la brújula: `mapa/pantalla_mapa.gd`). Eso es código nuevo y lleva plan.

## Darlo en una sala

- Como recompensa de una entrega, un reto, un NPC o un artículo de tienda: una `Recompensa` con `tipo` `AMULETO` o
  `UTIL` e `id` el de la ficha (tabla de `Recompensa` en `docs/componentes.md`). Modelo de tienda:
  `herramientas/salas/sala_tienda.tscn`. Cómo se pone cada una de esas piezas en una sala: `docs/guias/armar-una-sala.md`.
- `.\herramientas\validar.ps1` falla si el id no está en un catálogo, o si una sala de `contenido/` usa uno que solo
  está en el de pruebas (`validador-equipo`): así se atrapa un id mal escrito antes de jugar.
- Probarlo: la sala «Equipo» de la zona de pruebas (categoría Partida) da los amuletos de prueba; uno del juego se
  prueba en su sala. La fila «Amuletos y útiles en el banco» de `docs/pruebas.md` dice qué mirar en el teléfono.

## Si algo falla

- No aparece en la página: revisar que la partida lo tenga (`Partida.amuletos_tenidos` o `utiles_tenidos`; lo da la
  recompensa) y que el id de la ficha sea idéntico al de la recompensa.
- Aparece con su id y no responde: no está en ningún catálogo.
- No se puede poner: de pie no se cambian (hay que sentarse en un banco); un amuleto que no cabe en la carga o un
  útil con la ranura llena tampoco responden.
