# Armar una sala (y una zona nueva) sin tocar `nucleo/`

**Para qué sirve:** crear una sala jugable en `contenido/`, con puertas, banco y peligros, usando solo piezas del
núcleo, y dejarla validada y probada con un guion.

**Antes de empezar:** haber hecho `docs/guias/empezar.md` y `docs/guias/como-trabajamos.md`; leer el
`contenido/CLAUDE.md` y su `funciones.json`, `docs/sala.md` (tabla, viñetas de ids y «Cambio de sala»), `docs/validador.md` (lista de lo que revisa y «uid de escenas
y recursos») y, en `docs/arte-y-rendimiento.md`, «Arte de zona». Modelo real: las salas de
`contenido/salas/celda/` y la base `contenido/zonas/celda/sala_celda.tscn`.

1. Decidir el id y el archivo de la sala: forma, numeración y ruta en `docs/sala.md`, «Dónde
   vive cada sala», y en `contenido/CLAUDE.md`, «Dónde va cada cosa». La numeración de una zona empieza en 1 y cada
   sala nueva toma el siguiente número libre (`celda_6`; los ids no se renumeran). La zona es una palabra sola, sin
   guion bajo ni acentos. `raices` ya aparece en el contrato como nombre de zona (la de «Las Raíces»): no se usa para
   otra cosa.
2. Zona nueva: crear antes su base en `contenido/zonas/<zona>/sala_<zona>.tscn`, como escena heredada de
   `contenido/zonas/celda/sala_celda.tscn` (no hay base común en el núcleo). Lleva los nodos contenedores de la
   sala (en esta guía `Entrada`, `Terreno` y `Peligros` son nodos del árbol, no grupos de Godot); cuáles son y qué
   no va en la base: `docs/arte-y-rendimiento.md`, «Arte de zona», viñeta «Base de la zona». Zona existente: se usa su base.
   En el editor: Escena → Nueva escena heredada…, elegir la base y guardar en la carpeta de destino. Heredar de la de
   La Celda trae su oscuridad (`oscuridad = 0.58`), su tema de música (`silencio.tres`), el material `sin_luz.tres` del
   `Frente` y los contenedores `Juego`, `SueloPintado`, `Terreno`, `Peligros`, `Encima`, `Luces` y `Frente`: una zona
   con otra luz o música cambia esos valores en su base (`docs/arte-y-rendimiento.md`, «Arte de zona»). Cada PNG nuevo se
   importa con mipmaps a mano (`project.godot` no tiene un preset de importación para `contenido/`).
3. Crear la sala como escena heredada de la base (no copiar un `.tscn` con `cp`: duplica el UID; `CLAUDE.md`,
   «Entorno y trampas»). Modelo: `contenido/salas/celda/celda_1.tscn`. La raíz es la `Sala`: se le pone `id`.
4. Darle `uid` a la cabecera de la escena nueva: el validador falla una escena de `contenido/` sin él (mensaje en
   `herramientas/validar.gd`). Guardarla en el editor lo genera solo. Si la escena se escribió como texto, se corre
   `.\herramientas\arreglar-uids.ps1 -Rutas res://contenido/salas/celda/celda_6.tscn`: importa, pone el uid de la
   cabecera si falta y el `uid=` de cada `ext_resource` desde el disco (nunca inventado; `docs/validador.md`,
   «uid de escenas y recursos»). Repara primero los recursos nuevos referenciados y después las escenas que los usan; vuelve a
   importar para registrar sus UID. Una sala mínima que hereda de la base:

   ```
   [gd_scene format=3 uid="uid://<lo pone arreglar-uids.ps1>"]

   [ext_resource type="PackedScene" uid="uid://dkg1tgmycc1sr" path="res://contenido/zonas/celda/sala_celda.tscn" id="0_base"]

   [node name="Celda6" instance=ExtResource("0_base")]
   id = "celda_6"
   limites = Rect2(0, 0, 3040, 1240)
   posicion_mapa = Vector2(0, 3900)
   ```

   El `uid` del `ext_resource` es el de la cabecera de `sala_celda.tscn`. La raíz hereda el script `sala.gd` de la
   base; `script = ExtResource(...)` se agrega solo si la sala lleva uno propio, como `celda_1.gd`.
5. Importar para que el proyecto registre la escena y sus recursos nuevos:
   `& $env:GODOT_PATH --headless --path . --import`.
6. Fijar `limites` y `posicion_mapa`, a mano, con las reglas de las filas `limites` y `posicion_mapa` de la tabla de
   `docs/sala.md`. La `Entrada` queda dentro de `limites`. Zona nueva: crear su `FichaZona` en
   `contenido/zonas/<zona>/zona_<zona>.tres`, con nombre visible, color y `origen_mapa` elegido a mano. La Celda
   baja una vez a Las Raíces, el punto más bajo del juego; desde ahí todo sube hasta ESCOM. Después de Las Raíces,
   cada zona nueva va más arriba que la anterior. Asignar la ficha a `ficha_zona` en la base de la zona, reemplazando
   la heredada. Cada sala cuenta `posicion_mapa` desde ese origen; mover el origen solo cambia la ficha.
   El validador falla si dos salas se enciman o si una misma zona usa fichas con rutas distintas.
7. Terreno: `StaticBody2D` sólidos con su `CollisionShape2D` como hijos del nodo `Terreno` (ejemplo: `Terreno` de
   `celda_2.tscn`). Colisión con formas invisibles; el arte no colisiona (`CLAUDE.md`, «Decisiones cerradas»).
   Una vía solo con `nucleo/piezas/plataforma_delgada.tscn` (`docs/sala.md`, «Suelos y plataformas»).
8. Peligros: un `Area2D` con el script `nucleo/dano_contacto.gd` y `peligro = true`, forma como `CollisionShape2D`
   hija, dentro de `Peligros` y nunca dentro de algo que se mueve (ejemplo: `contenido/objetos/celda/foso_varillas.tscn`;
   regla: `docs/sala.md`, y `docs/componentes.md`, «Componentes»). Coordenadas: la sala empieza en (0, 0) arriba a la izquierda y
   la `position` de un `StaticBody2D` es el centro de su forma. Medidas de la pieza base (`nucleo/piezas/foso.tscn`,
   de la que hereda `foso_varillas.tscn`): el
   `Area2D` del peligro mide 140 × 180, su `Fondo` (el suelo que lo cierra por debajo) 230 × 80 y el dibujo se
   acomoda con `position` negativa para centrarlo sobre ellos.
9. Puertas: instancias de `nucleo/puerta.tscn` (o una escena heredada con arte, en `contenido/objetos/<zona>/`),
   hijas directas de la raíz. Se llenan `id`, `sala_destino` (id de sala), `puerta_destino`, `llegada` y `tipo`
   (tabla de «Cambio de sala»). El destino debe existir y la puerta de vuelta apunta a esta, salvo una `ABAJO`.
   Ejemplo, de `celda_2.tscn` (`llegada` es relativa a la puerta; el cuerpo del jugador, de 80 × 160, no puede tocar
   el área de la puerta, de 40 × 160, al llegar, así que se aleja de ella en el sentido en que entra):

   ```
   [node name="PuertaDerecha" parent="." instance=ExtResource("44_puerta_salida")]
   position = Vector2(4250, 774)
   id = &"derecha"
   sala_destino = "celda_3"
   puerta_destino = &"izquierda"
   llegada = Vector2(-64, 0)
   ```
10. Detrás de cada puerta pegada al borde izquierdo o derecho de `limites`, un `StaticBody2D` invisible, hijo de `Terreno` (el
    validador lo exige por su posición, sin mirar su padre ni su nombre; el contrato lo llama `ParedTrasPuerta`; ejemplo en `celda_3.tscn`; porqué:
    `docs/errores/2026-10-14-salto-sobre-puerta.md`). La pared pega por fuera del borde y es tan alta como la sala. En
    `celda_3` (`limites` de 3040 × 1240) cada pared tiene una forma de 80 × 1240: la izquierda en
    `position = Vector2(-40, 620)` y la derecha en `Vector2(3080, 620)`.
11. Banco, si la sala tiene uno: instancia de `nucleo/banco.tscn`, hija de la raíz o dentro de una pieza, con `id` igual a
    `banco_<id de la sala>` (ejemplo: nodo `Banco` de `celda_1.tscn`). El `id` es único en todo el juego.
12. Muro que se rompe: `nucleo/muro_rompible.gd` en un `StaticBody2D` con `id` único en la sala, `golpes`, `tapas`
    y `descubre` (ejemplo: `Plafon` en `celda_3.tscn`). Romperlo exige atacar y atacar exige la habilidad `pluma`
    (`docs/jugador.md`, tabla de habilidades). La sala no puede darla (el validador exige `habilidades_de_prueba`
    vacío en `contenido/`), pero el guion sí: una línea `habilidad pluma` antes de las entradas (`docs/guiones.md`).
    También se puede repetir la ruta que consigue la habilidad (`herramientas/guiones/contenido/celda_3_nicho.guion`
    repite la de `celda_3_pluma`).
13. Arte y luz: capas, color, frente y piezas de la zona siguen «Arte de zona»; los presupuestos, «Recursos».
14. Regenerar el índice del mapa:
    `& $env:GODOT_PATH --headless --path . --quit-after 600 res://herramientas/generar_mapa.tscn`. Es lo que escribe
    `mapa/indice_salas.tres`; no se edita a mano y el validador falla si no está al día (`mapa/CLAUDE.md`, «Reglas»).
    Al terminar imprime `MAPA salas=<N> error=0 franja_libre_y=<Y>`, con N igual al número de salas con id (las del
    juego y las de la zona de pruebas) y Y, el borde inferior más bajo de sus rectángulos, redondeado hacia arriba
    a píxeles enteros. Sin salas es 0. Y es solo un dato: dónde va cada zona lo fija `origen_mapa` con la regla de
    subida (`docs/sala.md`, propiedad `posicion_mapa`). Si sale un `error=` distinto de 0, o N no sube con la sala nueva, la escena no carga o
    no tiene `id`: correr `validar.ps1` y leer su primer fallo.
15. Validar con `.\herramientas\validar.ps1` (debe imprimir `fallos=0`). Los `AVISO` no fallan; uno dice si a la
    sala le falta su guion (paso 16).
16. Escribir el guion de la sala en `herramientas/guiones/contenido/<id>_puertas.guion` con su `.esperado`: entra por
    la `Entrada`, llega a la puerta, la cruza y comprueba `escena` y `senal /root/Eventos cambio_de_sala`. Modelo:
    `celda_1_puertas`. Los cuadros se miden con una corrida, no se calculan (`docs/guiones.md`). Correrlo:
    `.\herramientas\correr-guiones.ps1 -Guiones contenido/<id>_puertas`. Un guion que cruza una puerta atrapa el
    `ERROR:` de una llegada que no existe, que el validador no ve (`docs/sala.md`, «Cambio de sala»).
17. Agregar la entrada de la sala en `contenido/funciones.json` apuntando a ese guion, con `"pasa": false` (la
    escribe quien hace la sala; el asistente solo cambia `pasa` a `true`, con la evidencia a la vista). Forma:

    ```
    {
      "id": "sala-celda-1",
      "que": "La Celda (celda_1) es la primera sala del juego: ...",
      "comprobacion": "herramientas/guiones/contenido/celda_salto.guion;herramientas/guiones/contenido/celda_hueco.guion",
      "pasa": false
    }
    ```

    Un guion (con su `.esperado` al lado) empieza así, como `celda_1_puertas.guion`; los números de cuadro se miden:

    ```
    escena res://contenido/salas/celda/celda_1.tscn
    2 mover_derecha press
    690 interactuar press
    692 interactuar release
    fin 830
    ```

    Entregar el bloque de commit como indica `docs/guias/como-trabajamos.md`.

La primera estación real y la bolsa de preguntas de la mochila se crean con su zona: la tabla en
`contenido/estaciones.tres` y la bolsa en `contenido/preguntas_mochila.tres`, con un guion que cruce la estación.
Sin bolsa, la mochila se recupera enseguida; las preguntas reales son contenido de la zona.

## Si algo falla

- `validar.ps1` nombra la regla rota: buscarla en la lista de `docs/validador.md` y su entrada
  `validador-*` en `herramientas/funciones.json`.
- Un guion con `ERROR:` al cruzar: la puerta de destino no existe en la sala destino (`docs/sala.md`, «Cambio de
  sala»).
- Errores previos de salas, puertas y mapa: `docs/errores/`.
