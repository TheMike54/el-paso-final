---
name: fisica-2d
description: Reglas de física 2D y entrada de este proyecto (Godot 4.7.2). Usar antes de tocar jugador.gd, enemigos, proyectiles, Area2D, rayos o formas de colisión, o al cambiar cómo el jugador lee las acciones.
---

# Física 2D y entrada en este proyecto

Cada cita se abrió en la documentación de Godot 4.7 en la línea citada y cada ejemplo se buscó en este repo;
«Cómo se comprueba aquí» dice cómo revisarlo en adelante, no que ya se haya corrido. Lo demás se busca con Grep en `$env:GODOT_DOCS`
(rutas `tutorials/...`, las mismas que citan las tablas).
Tocar el jugador, su física o su movimiento es punto crítico: el cambio lleva `revisor` antes del bloque de commit.

Los valores (velocidades, ticks, gravedad, tamaños) no están aquí: viven en `docs/jugador.md` y en «Configuración
del proyecto», «Entrada», «Componentes» y «Enemigos» de `docs/contrato.md`. Una regla de aquí nunca manda sobre
esos documentos.

## Tick y movimiento

| Regla | Doc | Cómo se comprueba aquí |
|---|---|---|
| Lógica y movimiento de cuerpos en `_physics_process`; `_process` solo para lo visual (su ritmo depende de los FPS) | `tutorials/scripting/idle_and_physics_processing.rst:18`, `:73` | `validar.ps1` y los guiones (`--fixed-fps 60`); ejemplo `nucleo/proyectil.gd` |
| La física queda a 60 ticks: no se baja para ahorrar CPU ni se sube; las cuentas del juego y los guiones van en ticks | `tutorials/performance/cpu_optimization.rst:268` | Grep de `physics_ticks` en `project.godot` (sin resultado = 60) |
| Un `CharacterBody2D` se mueve con `move_and_slide()`; asignar `global_position` solo al teletransportar (reaparecer, entrar a sala), con `velocity` a cero | `tutorials/physics/physics_introduction.rst:378`, `tutorials/physics/using_character_body_2d.rst:43` | Guiones `jugador_movimiento`, `jugador_reaparecer`, `cambio_de_sala` |
| La gravedad se suma a mano a `velocity` (por `delta`) antes de `move_and_slide()`; la velocidad no se multiplica por `delta` al llamarlo | `tutorials/physics/using_character_body_2d.rst:36`, `tutorials/physics/physics_introduction.rst:473` | Guiones `jugador_caida`, `jugador_salto_corto`, `jugador_coyote`, `jugador_salto_en_cola` |
| `move_and_slide()` cambia `velocity` (la deja en 0 al aterrizar): la velocidad de caída se lee antes de llamarlo | `tutorials/physics/using_character_body_2d.rst:204` | Guiones `aterrizaje`, `jugador_aterrizaje_duro`, `vibracion_aterrizaje` |
| Para reaccionar a cada choque, recorrer `get_slide_collision_count()` / `get_slide_collision(i)` tras moverse; solo cuenta los choques que cambiaron la dirección, no todo contacto | `tutorials/physics/using_character_body_2d.rst:126`, `:160` | Guiones `habilidad_caida_en_picada`, `camara_temblor_picada_fragil` (rompen el `SueloFragil`) |
| `is_on_floor()` / `is_on_wall()` dependen del modo `GROUNDED` y de `up_direction` por omisión: no cambiarlos en el jugador ni en lo que camina. Única excepción: el enemigo sin gravedad (vuela) usa `MOTION_MODE_FLOATING`, sin suelo y con todo choque como pared; lo fija `nucleo/enemigo.gd` según la ficha. Antes de la primera rampa, revisar `floor_max_angle` (45° por omisión) | `tutorials/physics/using_character_body_2d.rst:89`, `:111`, `classes/class_characterbody2d.rst:156-158` | Grep de `motion_mode =` (solo `nucleo/enemigo.gd`; `nucleo/golpeable.gd` solo lo lee) y de `up_direction` (sin resultado); guion `enemigos_moviles` |
| Sin deslizar (rebotar con la normal): `move_and_collide()` y la respuesta a mano | `tutorials/physics/using_character_body_2d.rst:65` | `validar.ps1` y un guion de la pieza nueva |
| Un `RigidBody2D` se controla en `_integrate_forces` (fuerzas, impulsos, velocidad), nunca asignando `position` cada tick | `tutorials/physics/physics_introduction.rst:283` | `validar.ps1` y un guion de la pieza nueva |
| Algo que va hacia un punto se detiene bajo un umbral de distancia, o tiembla al llegar | `tutorials/2d/2d_movement.rst:300` | Guion del comportamiento nuevo |
| Un nodo con `PROCESS_MODE_ALWAYS` procesa en pausa pero su física no: nada de mover cuerpos ni esperar choques en menús | `tutorials/scripting/pausing_games.rst:87` | Grep de `process_mode` en las escenas con cuerpos; guion de la pieza nueva |
| Si importa quién se procesa primero en el mismo tick, fijarlo con `process_priority` (menor va antes), no con el orden del árbol | `tutorials/scripting/scene_tree.rst:126` | Guion que reproduzca el caso |

## Formas de colisión

| Regla | Doc | Cómo se comprueba aquí |
|---|---|---|
| Cada `CollisionShape2D` es hija directa del cuerpo o del área: las nietas se ignoran | `tutorials/physics/collision_shapes_2d.rst:18` | Grep en el `.tscn`; ejemplo `nucleo/jugador.tscn` |
| Formas primitivas, sobre todo caja (`RectangleShape2D`), pocas por objeto; las cóncavas solo sirven en un `StaticBody2D` | `tutorials/physics/collision_shapes_2d.rst:43`, `:75`, `tutorials/physics/troubleshooting_physics_issues.rst:115` | Grep de `ConcavePolygon\|ConvexPolygon\|CollisionPolygon2D` (sin resultado) |
| Nunca escalar una forma ni un cuerpo: se cambia `size` en el recurso y se escala solo el dibujo, sin colgar la forma del dibujo | `tutorials/physics/troubleshooting_physics_issues.rst:60`, `tutorials/physics/kinematic_character_2d.rst:96` | Grep de `scale =` en los `.tscn` con cuerpos; ejemplo `nucleo/enemigo.gd` (forma creada con `tamano`) |
| Contra el tunelado: sólidos gruesos y, en lo rápido, un rayo que cubra todo el paso del tick. Una velocidad nueva se revisa en px por tick frente al grosor de los sólidos (contrato, «Escala») | `tutorials/physics/troubleshooting_physics_issues.rst:23`, `:27` | Guiones `poder_bola`, `golpe_contra_pared`, `carrera_pared` |

El arte no colisiona (decisión cerrada en `CLAUDE.md`): las formas son invisibles y aparte.

## Áreas

| Regla | Doc | Cómo se comprueba aquí |
|---|---|---|
| Capa y máscara de cada cuerpo y área con `Capas.poner(self, capa, mascara)` en su `_ready`, nunca en el `.tscn`; una pieza nueva usa una capa de la tabla de `docs/contrato.md`, «Capas de física», y una capa nueva va ahí, en `nucleo/capas.gd` y en `[layer_names]` de `project.godot` | `tutorials/physics/physics_introduction.rst:115` | Guion `capas_fisica`; Grep de `collision_layer` y `collision_mask` en los `.tscn`: sin resultados |
| `Area2D` para detectar y para lo que golpea sin más física; `StaticBody2D` para el entorno (`docs/contrato.md`, «Sala») | `tutorials/physics/using_area_2d.rst:95`, `tutorials/physics/physics_introduction.rst:55` | `validar.ps1`; ejemplo `nucleo/coleccionable.gd` |
| `body_entered` si lo que llega es un cuerpo (el jugador), `area_entered` si es un área (un `Golpeable`) | `tutorials/physics/using_area_2d.rst:63` | Guiones `combate_chico`, `poder_bola`; ejemplo `nucleo/proyectil.gd` |
| Apagar lo que no debe detectar o ser detectado con `monitoring` / `monitorable`. Convención del repo: dentro del tick, con `set_deferred(&"monitoring", ...)` (`nucleo/jugador.gd`, `nucleo/ataque_enemigo.gd`) | `tutorials/physics/using_area_2d.rst:37` | Guiones `jugador_ataque_y_vida`, `parry` |
| Agregar nodos desde un callback de física con `add_child.call_deferred(...)` (así nace la bola en `nucleo/jugador.gd`) | `tutorials/performance/thread_safe_apis.rst:41` | Guiones `poder_bola`, `poder_bola_recarga` |
| Visión de un enemigo: `ComportamientoEnemigo.ve_al_jugador(radio)`, distancia más un rayo contra `escenario`, para que una pared tape la vista. Un `Area2D` circular solo detecta cercanía: ve a través de las paredes | `tutorials/physics/ray-casting.rst:103`, `:113` | Guion `enemigos_moviles` (quieto con el jugador tras una pared) |

Medido en este repo (`docs/errores/2026-10-06-bola-atravesaba-paredes.md`): un `Area2D` movido con `position` dio 0
cuerpos estáticos en `get_overlapping_bodies()`, y la causa en el motor no se comprobó. Por eso un `Area2D` que deba
chocar con el escenario (proyectiles, enemigos que vuelan) usa un rayo o una consulta de forma, no `body_entered`;
lo cubre el guion `poder_bola`. La documentación dice que un `Area2D` detecta cualquier `CollisionObject2D`
(`tutorials/physics/using_area_2d.rst:21`): no generalizar la medición más allá de ese caso.

## Rayos y consultas

| Regla | Doc | Cómo se comprueba aquí |
|---|---|---|
| `intersect_ray` / `intersect_shape` solo dentro de `_physics_process` o lo que este llama; si nace de una entrada, se guarda la intención y se consulta en el tick | `tutorials/physics/ray-casting.rst:42`, `:319` | `validar.ps1` y el guion de la pieza |
| Extremos en coordenadas globales (`global_position`) | `tutorials/physics/ray-casting.rst:111` | Ejemplo `nucleo/proyectil.gd` (pasa `global_position` a `Capas.rayo_a_escenario`) |
| El resultado es un `Dictionary` vacío si no choca: comprobar `is_empty()` antes de leer `collider`, `normal`, `position`; leerlo con cast tipado | `tutorials/physics/ray-casting.rst:125` | `validar.ps1` (tipado); ejemplo `nucleo/golpeable.gd` |
| Cada rayo fija su `collision_mask` con `Capas` (los de sólidos, `Capas.ESCENARIO`): así no choca con quien lo lanza. `exclude = [x.get_rid()]` solo si quien lanza está en una capa que el rayo sí busca | `tutorials/physics/ray-casting.rst:204`, `tutorials/physics/physics_introduction.rst:115` | Guiones `capas_fisica` y `poder_bola` (la bola sale del jugador sin chocar consigo); un rayo contra sólidos usa `Capas.rayo_a_escenario` (`nucleo/capas.gd`), que ya fija la máscara |
| Las áreas solo cuentan con `collide_with_areas = true` (por omisión no): se fija cuando el rayo busca áreas; el que solo busca sólidos lo deja en false | `tutorials/physics/ray-casting.rst:156` | Ejemplos `nucleo/jugador.gd` (la picada, true y máscara `GOLPEABLE`) y `Capas.rayo_a_escenario` en `nucleo/capas.gd` (solo `ESCENARIO`) |
| Para un rayo fijo que se revisa cada tick basta un nodo `RayCast2D` | `tutorials/physics/ray-casting.rst:16` | `validar.ps1` y el guion de la pieza |

## Entrada del jugador

La entrada se sondea en el tick (decisión cerrada, `docs/contrato.md`, «Ciclo de vida» y «Entrada»): el jugador
no usa `_input` ni `_unhandled_input`. Los guiones dependen de eso (`docs/guiones.md`: `Input.action_press` no
genera evento).

| Regla | Doc | Cómo se comprueba aquí |
|---|---|---|
| Leer acciones con nombre del InputMap, nunca la tecla ni el botón; acción nueva en `project.godot` y en la tabla del contrato | `tutorials/inputs/controllers_gamepads_joysticks.rst:40`, `tutorials/inputs/input_examples.rst:157` | Guiones `entrada_control`, `controles_configurables` |
| Nombres de acción en snake_case (`mover_izquierda`, `mapa_rapido`) | `tutorials/inputs/input_examples.rst:170` | Grep en la sección `[input]` de `project.godot` |
| Lo que dura mientras se mantiene (moverse) se consulta en el singleton `Input` en el tick | `tutorials/inputs/input_examples.rst:26` | Guion `jugador_movimiento` |
| Un eje de dos lados con `Input.get_axis(&"mover_izquierda", &"mover_derecha")`, no restando a mano | `tutorials/inputs/controllers_gamepads_joysticks.rst:91` | Guiones `controles_tactiles` (fuerza del joystick), `jugador_movimiento` |
| Si entra apuntar libre (dos ejes como una entrada), `Input.get_vector`, que da zona muerta circular | `tutorials/inputs/controllers_gamepads_joysticks.rst:57` | Guion de la pieza nueva |
| Saltar, atacar e impulso con `is_action_just_pressed` (verdadero un solo tick); `is_action_pressed` para lo que se mantiene | `tutorials/inputs/controllers_gamepads_joysticks.rst:147` | Guiones `jugador_salto_en_cola`, `parry_ventana` |
| La zona muerta se fija por acción en el InputMap (la de omisión es 0,5; la del proyecto está en «Entrada» del contrato) | `tutorials/inputs/controllers_gamepads_joysticks.rst:202` | Grep de `deadzone` en `project.godot`; guion `entrada_control` |
| En Android el control no usa SDL: un cambio de mapeo del control se prueba también en el teléfono | `tutorials/inputs/controllers_gamepads_joysticks.rst:361` | Prueba manual en el teléfono con un control conectado |

## Medir en el S50 antes de cambiar

- Interpolación de física: apagada, decidido con medida (`docs/contrato.md`, «Configuración del proyecto»). Si
  algún día se activa, revisar `reset_physics_interpolation()` al teletransportar
  (`tutorials/physics/interpolation/using_physics_interpolation.rst:136`) y la cámara
  (`tutorials/physics/interpolation/advanced_physics_interpolation.rst:48`).
- Mezclar fuentes de tiempo (algo en `_process` junto a la cámara en física) puede temblar
  (`tutorials/rendering/jitter_stutter.rst:46`-`47`); `nucleo/niebla.gd` y `nucleo/planta.gd` van en `_process`.
  Lo nuevo que se mueve en el mundo va en el tick.
- Formas trasladadas o muchas formas en un `StaticBody2D` cuestan en la fase amplia
  (`tutorials/physics/collision_shapes_2d.rst:119`-`121`, `:126`); la forma del jugador está trasladada por «pies en el
  origen» (contrato) y se queda.
- Sacar de la física lo que está fuera de vista, solo si salas largas con muchos enemigos bajan los FPS
  (`tutorials/performance/cpu_optimization.rst:256`).
