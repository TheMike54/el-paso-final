# Contrato del proyecto

Lo que un bloque puede dar por hecho de los demás: la configuración del proyecto, el ciclo de vida, los autoloads,
la entrada y la interfaz de los guiones. Si un cambio altera algo de aquí, este documento se actualiza en el
mismo cambio. Las señales del bus de eventos, la forma de una sala, la ficha de una entidad y el esquema del
guardado entran a este documento en el mismo cambio que los implementa, con su plan aprobado antes.

## Configuración del proyecto

Valores de `project.godot`. No se cambian sin actualizar esta tabla.

| Tema | Valor | Por qué |
|---|---|---|
| Motor | Godot 4.7.2 estable, edición estándar | Un proyecto guardado con una versión más nueva no abre en una anterior |
| Renderer | Compatibility en `rendering_method` y en `rendering_method.mobile` | Teléfonos de gama baja |
| Resolución base | 1280×720 | Proporción 16:9; el arte se mide contra esta base |
| Estiramiento | `canvas_items` con aspecto `expand` | La base se escala a la pantalla; en pantallas más anchas se ve más escenario, sin barras |
| Escala | Cuadro de 40 px; el personaje mide 160 px de alto | Medida común para salas, colisiones y arte |
| Orientación | Horizontal con giro (`window/handheld/orientation=4`, `SCREEN_SENSOR_LANDSCAPE`) | Se juega acostado, hacia cualquiera de los dos lados |
| Botón Atrás | `quit_on_go_back=false` | Atrás no cierra la app: en el juego abre la pausa y en el menú pide confirmación |
| Tipado | `untyped_declaration`, `unsafe_property_access`, `unsafe_method_access` y `unsafe_call_argument` como error | Un error de tipos se ve al validar, no al jugar |
| Texturas | Ninguna de más de 2048 px por lado | Memoria en gama baja |
| Compresión de texturas | `textures/vram_compression/import_etc2_astc=true` | Godot no exporta a Android sin ella |
| Id del paquete Android | `com.themike54.elpasofinal` | Identidad estable de la app instalada |

## Ciclo de vida

- Arranque: Godot carga los autoloads y después la escena principal (`application/run/main_scene`).
- La lógica del juego corre en `_physics_process`, a 60 ticks por segundo. `_process` queda para lo visual.
- Pausar no guarda. La partida se guarda solo en los bancos.
- El guardado se escribe en un archivo temporal y después se renombra: un cierre a la mitad no daña la partida.
- El guardado es JSON con número de versión. Al cargar se distinguen tres casos: partida válida, archivo dañado
  y partida de una versión incompatible.
- Todo lo persistente (puerta abierta, objeto recogido, jefe vencido) se identifica con un ID de texto estable.
- Las fichas `.tres` son de solo lectura en ejecución: un recurso cargado es la misma copia para todos.

## Autoloads

| Nombre | Script | Qué hace |
|---|---|---|
| `Arranque` | `nucleo/arranque.gd` | Imprime `ARRANQUE depuracion=<bool> puerto=<bool>` y, solo en un build de depuración y si el archivo viaja en el paquete, carga con `load()` el puerto de depuración como hijo suyo (`PuertoDepuracion`) |

- Un autoload nuevo se agrega a esta tabla en el mismo cambio.
- Nada de `herramientas/` es autoload ni se carga con `preload`: el preset de publicación excluye esa carpeta y el
  juego publicado debe arrancar sin ella.

## Entrada

La lógica lee acciones con nombre (`Input.is_action_pressed(&"saltar")`), nunca la tecla ni el toque.

| Acción | Teclado inicial |
|---|---|
| `mover_izquierda` | A |
| `mover_derecha` | D |
| `saltar` | W |

Las teclas se guardan como tecla física (`physical_keycode`): valen por su posición en el teclado, no por la
letra de la distribución. Una acción nueva se agrega a `project.godot` y a esta tabla en el mismo cambio.

## Grupos

| Grupo | Quién lo lleva | Quién lo usa |
|---|---|---|
| `jugador` | El cuerpo que controla la persona (hoy, la caja gris) | El puerto de depuración lee de su primer nodo la posición y si está en el suelo |

## Guiones de entrada

Un guion reproduce entradas por cuadro de física y compara el estado con un archivo de valores esperados. Lo
corre el puerto de depuración (`herramientas/puerto_depuracion.gd`), en local y en el CI:

```powershell
& $env:GODOT_PATH --headless --path . --fixed-fps 60 --quit-after 7200 -- --guion=herramientas/guiones/<bloque>/<nombre>.guion
```

- `<nombre>.guion`: líneas `<cuadro> <acción> press|release` y una línea `fin <cuadro>`. Los cuadros de las
  entradas van de 1 a `fin` menos 1.
- `<nombre>.esperado`, junto al guion: líneas `<clave> <valor> [tolerancia]`.

  | Clave | Valor | Se compara |
  |---|---|---|
  | `x`, `y` | Posición global del nodo del grupo `jugador`, en píxeles | Con tolerancia; 0,5 si no se indica |
  | `en_suelo` | `true` o `false` | Exacto |
  | `escena` | Ruta `res://` de la escena actual | Exacto |

- En los dos archivos se ignoran las líneas vacías y las que empiezan con `#`.
- El estado se lee al empezar el cuadro `fin`.
- Resultado: una línea `GUION OK <ruta> cuadro=<n>` y salida 0, o `GUION FALLA <ruta>: <motivo>` y salida 1.
  Falla si el guion o su `.esperado` no existen, si una línea no es válida, si una acción no está en el
  `InputMap` o si el estado no coincide.
- Un guion comprueba lo que importa (llegó, está en el suelo, cambió de sala) con tolerancia; no todos los
  decimales.

## Paquete de publicación

El preset «Publicacion» de `export_presets.cfg` deja fuera `herramientas/` con su `exclude_filter`. El núcleo no
depende de `herramientas/`: la única referencia es la carga condicional de `Arranque`.
