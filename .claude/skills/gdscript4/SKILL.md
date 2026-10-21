---
name: gdscript4
description: Reglas de GDScript 4 con el tipado estricto de este proyecto (Godot 4.7.2) y las diferencias con Python y con Godot 3 que rompen la compilación. Usar antes de escribir o corregir cualquier archivo .gd, o cuando validar.ps1 muestre un Parse Error.
---

# GDScript 4 en este proyecto

Todo lo de abajo se comprobó en Godot 4.7.2 contra este repo; lo demás se busca con Grep en `$env:GODOT_DOCS`
(ruta `tutorials/...`). `project.godot` trata como error solo `untyped_declaration`, `unsafe_property_access`,
`unsafe_method_access` y `unsafe_call_argument`. Lo que no esté aquí se comprueba con `.\herramientas\validar.ps1`
antes de darlo por bueno; no se supone.

## Tipado: qué compila y qué no

| Compila | No compila |
|---|---|
| `var vidas: int = 4` · `var x := 5` (tipo inferido) | `var vidas = 4` |
| `func f(x: float) -> void:` | `func f(x):` · `func f() :` sin `-> tipo` |
| `var h: Node2D = $Hijo as Node2D` y después `h.position` | `$Hijo.position` · `get_node("Hijo").metodo_propio()` |
| `var v: int = d["v"]` · `d["v"] as int` (con `d: Dictionary`) | `int(d["v"])` · pasar `d["v"]` a un parámetro tipado |
| `var d: Dictionary[String, int]` y pasar `d["v"]` a un `int` | `Dictionary[String, Array[int]]` («Nested typed collections are not supported») |
| `var e: PackedScene = load(ruta)` y `e.instantiate()` | `e.instance()` |

- Tipo explícito siempre, aunque `:=` compile: el repo no tiene ningún `:=` y la guía pone la consistencia del
  equipo por encima de ella (`tutorials/scripting/gdscript/gdscript_styleguide.rst:19`).
- Un valor `Variant` (elemento de un `Dictionary` o `Array` sin tipo, resultado de `JSON`, de `Callable.call()`)
  se asigna primero a una variable tipada o se convierte con `as`; solo entonces se pasa a una función.
- Nodos: `@onready var _sprite: Sprite2D = $Sprite as Sprite2D` (convención del repo; ejemplo: `_lista` en `nucleo/configuracion.gd`).
  El acceso a propiedades o métodos de una clase propia exige que la variable tenga ese tipo (`class_name` o
  `preload` del script).
- Colecciones tipadas: `Array[String]`, `Dictionary[String, int]`, `PackedStringArray`. No se anidan
  (`tutorials/scripting/gdscript/static_typing.rst:265`, `gdscript_basics.rst:870`): la de dentro va sin tipo.
- `for i: int in range(3):` lleva el tipo aunque el compilador acepte omitirlo.

## `as` y `$Nodo`: dos formas, dos fallos

| Forma | Si el nodo es de otro tipo o se renombró |
|---|---|
| `@onready var h: Node2D = $Hijo as Node2D` (la del repo) | `h` queda `null` sin error; el fallo sale después o nunca |
| `@onready var h: Node2D = $Hijo` (también compila aquí) | Falla al correr en esa línea: «Trying to assign value of type 'Node' to a variable of type 'Node2D'» |

- `as` devuelve `null` en silencio (`tutorials/scripting/gdscript/static_typing.rst:317`); sin `as` falla antes
  (`static_typing.rst:394`). `validar.ps1` no ejecuta `_ready`: el `null` lo atrapa un guion que pase por ahí.
- Fuera de `@onready`, `as` solo cuando el `null` es posible, y se comprueba: `Banco.descansar()` en `nucleo/banco.gd`.
  O se pregunta antes con `is`.

## Referencias, recursos y archivos

| Regla | Referencia | Se comprueba con |
|---|---|---|
| `Array`, `Dictionary`, objetos y packed arrays se comparten: `duplicate()` (o `duplicate(true)` con anidados) antes de guardar, entregar o modificar algo ajeno (`Partida.a_diccionario()` en `nucleo/partida.gd`) | `tutorials/scripting/gdscript/gdscript_basics.rst:693` | guiones `estado_partida` y `guardado` |
| Un recurso cargado es la copia de la caché, la misma para todos: no modificar en ejecución una ficha `.tres`, un `StyleBox` ni una forma de colisión compartida; para uno propio, `duplicate()` o `new()` | `tutorials/scripting/resources.rst:30` | revisión del diff: ningún campo de una ficha cargada se asigna fuera de `duplicate()`/`new()` |
| `FileAccess` solo para lo que Godot no importa (`user://`, JSON, `.guion`); un asset importado se lee con `load()`, porque en el APK solo está la versión importada | `tutorials/assets_pipeline/import_process.rst:23` | Grep de `FileAccess.open` |

## Colecciones, números y JSON

- `Array` tipado desde uno sin tipo: `a.assign(datos)` (convierte `1.0` a `int`), nunca `=`, que compila y al correr
  da «SCRIPT ERROR: Trying to assign an array of type "Array"...» y lo deja vacío (`gdscript_basics.rst:889`).
- Floats calculados se comparan con `is_equal_approx` / `is_zero_approx`: `0.1 + 0.2 == 0.3` da `false`
  (`gdscript_basics.rst:330`). `!= 0.0` solo con valores puestos a mano, no calculados.
- `absf`, `clampf`, `lerpf`, `roundi`, `signf`: `abs(-1.0)` a un `float` compila sin aviso porque da `Variant`
  (`static_typing.rst:559`). Grep de `(^|[^.\w])(abs|clamp|round|sign|lerp)\(` sin resultados.
- `match` no iguala `int` 1 con `float` 1.0 en ningún sentido, y `JSON.parse_string("[1]")[0]` es `float`:
  convertir con `as int` antes del `match` (`gdscript_basics.rst:1900`). Guion `guardado`.
- `%` con un valor por marcador: `"%d %d" % [1]` compila y, si la línea corre, imprime «ERROR: String formatting
  error: not enough arguments», que hace fallar validador y guiones (`gdscript_format_string.rst:66`).

## Ciclo de vida de nodos y estáticas

| Regla | Referencia | Se comprueba con |
|---|---|---|
| `static var` es de la clase y sobrevive al cambio de escena: reiniciarla a mano al empezar partida o guion (`Ajustes.cargar()` las vuelve a su valor por omisión antes de leer). No usar `@static_unload`: por un error del motor no libera nada | `tutorials/scripting/gdscript/gdscript_basics.rst:1164`, `:1261` | guion `ranuras` |
| Un `Node` no se libera solo: `queue_free()` al terminar e `is_instance_valid()` antes de usar una referencia guardada (`_physics_process` de `nucleo/npc.gd`); `free()` inmediato solo si nadie más la tiene y no se está dentro de una señal de ese nodo | `tutorials/scripting/gdscript/gdscript_basics.rst:2623`, `tutorials/scripting/nodes_and_scene_instances.rst:173` | guiones `dialogo` y `reto` |
| Inicializar en `_ready` (una vez), no en `_enter_tree`, que corre cada vez que el nodo vuelve al árbol | `tutorials/scripting/overridable_functions.rst:20` | Grep de `_enter_tree` |
| Un ajuste de `project.godot` con override por etiqueta (`.mobile`) se lee con `ProjectSettings.get_setting_with_override()`; `get_setting()` lo ignora | `tutorials/export/feature_tags.rst:213` | Grep de `ProjectSettings.get` |

## Avisos y validador

- Solo los cuatro avisos de `project.godot:26-29` son error. Cualquier otro sale como `WARNING` y `validar.ps1`
  pasa igual (`herramientas/validar.ps1:24` solo atrapa `SCRIPT ERROR`, `ERROR:` y `FALLO`;
  `tutorials/scripting/gdscript/warning_system.rst:47`). Los avisos no se desactivan.
- Que algo compile no dice que corra: `=` de arrays, `%` con valores de menos y `as` que da `null` solo fallan al
  ejecutar. Para eso, un guion (`docs/guiones.md`).

## Estilo para código nuevo

- Cabecera de cada `.gd` nuevo: 3 o 4 líneas con `#` tras `class_name`/`extends` (la de `nucleo/ranuras.gd`).
  `##` solo para documentar miembros públicos; lo privado lleva `_` y `#`, y así no sale en la ayuda del editor
  (`tutorials/scripting/gdscript/gdscript_documentation_comments.rst:136`, `gdscript_styleguide.rst:715`). Grep de
  `^##` en el `.gd`: solo sobre `const`, `var`, `func` y `signal` sin `_` (`nucleo/tema.gd` es el ejemplo).
- Grep de `:=` en los `.gd` del cambio: `validar.ps1` no lo atrapa, porque compila.
- Orden: `class_name`, `extends`, comentario; señales, enums, constantes, `@export`, variables, `@onready`;
  `_init`, `_ready`, `_process`, `_physics_process` y demás virtuales; públicas; privadas
  (`gdscript_styleguide.rst:822`).
- Una línea larga se parte con paréntesis, no con `\`, y `and`/`or` al inicio de la línea siguiente
  (`gdscript_styleguide.rst:345`). Grep de `\\$` en los `.gd` nuevos.

## No es Python

| Python | GDScript 4 |
|---|---|
| `None` | `null` |
| `f"vidas {n}"` | `"vidas %d" % n` · `"a=%d b=%s" % [a, b]` · `str(n)` |
| `a[0:2]` | `a.slice(0, 2)` |
| `[x * 2 for x in a]` | bucle `for` con `append`, o `a.map(func(x: int) -> int: return x * 2)` |
| `try` / `except` | No existe: se revisa el valor devuelto (`null`, código `Error`) |
| `import` | `class_name` en el script, o `preload("res://...")` |
| `lambda x: x * 2` | `func(x: int) -> int: return x * 2` |

`7 / 2` da `3` (división entera entre enteros); `7 / 2.0` da `3.5`. Existen igual que en Python: `and`, `or`,
`not`, `elif`, `pass`, `x in lista`, `a if cond else b`, `len(a)` (lo habitual es `a.size()`). En lugar de
`switch` se usa `match`.

## No es Godot 3

| Godot 3 | Godot 4 |
|---|---|
| `export var` · `onready var` | `@export var` · `@onready var` |
| `yield(obj, "senal")` | `await obj.senal` · `await get_tree().create_timer(0.5).timeout` |
| `connect("senal", self, "metodo")` | `senal.connect(metodo)` · `senal.emit(valor)` |
| `KinematicBody2D` · `move_and_slide(velocidad)` | `CharacterBody2D`: se asigna `velocity` y se llama `move_and_slide()` sin argumentos |
| `File.new()` | `FileAccess.open(ruta, FileAccess.READ)`; si devuelve `null`, `FileAccess.get_open_error()` |
| `Tween.new()` + `add_child` | `create_tween()` |
| `.instance()` | `.instantiate()` |

## Trampas comprobadas

- `JSON.parse_string()` devuelve los enteros como `float` (`3` vuelve como `3.0`): al leer un guardado,
  `var vidas: int = d["vidas"] as int`.
- `JSON.parse_string()` con texto inválido devuelve `null` y además imprime una línea `ERROR:`, que hace fallar
  al validador y a los guiones. Para un archivo que puede venir dañado: `var j: JSON = JSON.new()`, revisar
  `j.parse(texto) == OK` y leer `j.data`.
- `super()` dentro de `_ready()` no compila si la clase padre es del motor y no define ese método en GDScript.
- Acciones de entrada con `StringName`: `Input.is_action_pressed(&"saltar")`.
- La física del jugador va en `_physics_process(delta: float) -> void`.
- Indentación con tabuladores, como la escribe el editor.
