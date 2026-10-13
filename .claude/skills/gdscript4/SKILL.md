---
name: gdscript4
description: Reglas de GDScript 4 con el tipado estricto de este proyecto (Godot 4.7.2) y las diferencias con Python y con Godot 3 que rompen la compilación. Usar antes de escribir o corregir cualquier archivo .gd, o cuando validar.ps1 muestre un Parse Error.
---

# GDScript 4 en este proyecto

Todo lo de abajo se comprobó compilando en Godot 4.7.2 con la configuración de `project.godot`, que trata como
error las declaraciones sin tipo y los accesos inseguros. Lo que no esté aquí se comprueba con
`.\herramientas\validar.ps1` antes de darlo por bueno; no se supone.

## Tipado: qué compila y qué no

| Compila | No compila |
|---|---|
| `var vidas: int = 4` · `var x := 5` (tipo inferido) | `var vidas = 4` |
| `func f(x: float) -> void:` | `func f(x):` · `func f() :` sin `-> tipo` |
| `var h: Node2D = $Hijo as Node2D` y después `h.position` | `$Hijo.position` · `get_node("Hijo").metodo_propio()` |
| `var v: int = d["v"]` · `d["v"] as int` (con `d: Dictionary`) | `int(d["v"])` · pasar `d["v"]` a un parámetro tipado |
| `var d: Dictionary[String, int]` y pasar `d["v"]` a un `int` | |
| `var e: PackedScene = load(ruta)` y `e.instantiate()` | `e.instance()` |

- Un valor `Variant` (elemento de un `Dictionary` o `Array` sin tipo, resultado de `JSON`, de `Callable.call()`)
  se asigna primero a una variable tipada o se convierte con `as`; solo entonces se pasa a una función.
- Nodos: `@onready var _sprite: Sprite2D = $Sprite as Sprite2D`. El acceso a propiedades o métodos de una clase
  propia exige que la variable tenga ese tipo (`class_name` o `preload` del script).
- Colecciones tipadas: `Array[String]`, `Dictionary[String, int]`, `PackedStringArray`.
- `for i: int in range(3):` lleva el tipo aunque el compilador acepte omitirlo.

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
