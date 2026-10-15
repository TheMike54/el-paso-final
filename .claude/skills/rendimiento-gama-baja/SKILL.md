---
name: rendimiento-gama-baja
description: Rendimiento en teléfonos de gama baja (S50, S20) con el renderer Compatibility. Usar antes de agregar arte, texturas, partículas, capas translúcidas, shaders, dibujo con _draw o una sala nueva, y antes de medir FPS o proponer una optimización.
---

# Rendimiento en gama baja

Cada cita se abrió en la documentación de Godot 4.7 en la línea citada y cada ejemplo se buscó en este repo;
«Cómo se comprueba aquí» dice cómo revisarlo en adelante, no que ya se haya corrido. Lo que no esté aquí se busca con Grep en
`$env:GODOT_DOCS` (ruta `tutorials/...`) antes de suponerlo. El presupuesto por sala y el límite de texturas
viven en `docs/contrato.md` («Configuración del proyecto» y «Recursos»): esta skill remite a él, no lo repite.

## Primero: medir en el S50 antes de optimizar

- Ningún cambio por rendimiento sin una medida antes y otra después en el teléfono; el que no sube los FPS se
  quita. `tutorials/performance/cpu_optimization.rst:16`, `tutorials/performance/general_optimization.rst:240`.
- Cómo: APK del preset «Desarrollo», que arranca con `--print-fps`, y `adb logcat -s godot`
  (`tutorials/scripting/logging.rst:33`). Los pasos y dónde anotar están en `docs/pruebas.md`, filas
  «Rendimiento en el teléfono», «Recursos (sala de medición)» y «Sala de arte (rendimiento)».
- Decir qué tipo de lentitud es: FPS bajos constantes, picos (tirones) o carga lenta
  (`tutorials/performance/general_optimization.rst:39`).
- Decir si limita la CPU o la GPU: el cuadro dura lo que tarda el más lento, y optimizar el otro no sube nada
  (`tutorials/performance/general_optimization.rst:289`). Aquí se prueba apagando capas una por una en la sala
  de arte (`herramientas/salas/sala_arte.gd`); así se vio que una niebla translúcida grande costaba ~11 FPS.
- Rendimiento se mide en el S50 y en el S20; lo funcional, en uno
  (`tutorials/performance/general_optimization.rst:74`).

## Convenciones que el repo ya sigue

Dibujo y GPU (Compatibility: costo base bajo, pero cada efecto extra cuesta mucho,
`tutorials/rendering/renderers.rst:184`):

| Regla | Doc | Cómo se comprueba aquí |
|---|---|---|
| Respetar el presupuesto por sala del contrato (emisores, partículas, plantas, sin `Light2D`) | `tutorials/rendering/renderers.rst:184` | `validar.ps1` |
| A lo más 2 capas translúcidas grandes por sala: el sobredibujo es caro en móvil | `tutorials/performance/gpu_optimization.rst:260` | `validar.ps1` (entrada `validador-capas-translucidas`) |
| Un material compartido por todos los nodos que lo usan, creado una vez y nunca dentro de un bucle (ejemplo: `sala_arte.gd`, el aditivo de los emisores) | `tutorials/performance/gpu_optimization.rst:85` | Grep de `Material.new`: ninguno dentro de un `for` |
| Shaders mínimos, con las menos lecturas de textura posibles | `tutorials/performance/gpu_optimization.rst:187` | Leer el shader; medir en el S50 |
| No contar con MSAA 2D, glow HDR ni estelas de partículas: Compatibility no los tiene | `tutorials/rendering/renderers.rst:298` | Grep de `msaa`, `hdr_2d`, `trail` |
| Brillos y chispas con `CanvasItemMaterial` en modo Add, no con luces 2D | `tutorials/2d/2d_lights_and_shadows.rst:372` | `validar.ps1` (falla con `Light2D`) |

Texturas (memoria por tamaño: tabla en `tutorials/assets_pipeline/importing_images.rst:241`):

- Ninguna de más de 2048 px por lado (límite del contrato; el móvil no muestra más de 4096,
  `tutorials/assets_pipeline/importing_images.rst:498`). Lo revisa `validar.ps1` (entrada `validador-texturas`).
- Mipmaps en el arte del mundo (`contenido/` y `herramientas/salas/arte/`), que la cámara puede ver más chico que
  su tamaño; no en el HUD ni en los menús. Suben la memoria ~33 % (`tutorials/assets_pipeline/importing_images.rst:390`,
  `tutorials/rendering/multiple_resolutions.rst:605`); el filtro por omisión es lineal con mipmaps
  (`project.godot`, `default_texture_filter=2`). `validar.ps1` exige los mipmaps en el arte del mundo
  (`CARPETAS_ARTE_MUNDO` en `herramientas/validar.gd`); que el HUD y los menús no los lleven no lo revisa.
- Sprites y piezas con alfa en Lossless (`compress/mode=0`); VRAM Compressed da artefactos en 2D
  (`tutorials/assets_pipeline/importing_images.rst:187`). `validar.ps1` falla con una imagen
  del arte del mundo con transparencia en VRAM. Excepción: los fondos translúcidos de la sala de arte (`ALFA_EN_VRAM` en
  `herramientas/validar.gd`), mientras se mide (tabla de abajo); una excepción nueva va ahí y en `docs/contrato.md`,
  «Recursos».

Escena y proceso:

- Salas y recursos que se cargan a demanda, como texto (ruta con `@export_file`, o el id de la sala que
  `Sala.ruta_de` convierte en ruta, como `sala_destino` en `nucleo/puerta.gd`) y `load()` o
  `change_scene_to_file()`, no como `@export` de un recurso, que carga la sala vecina en cadena.
  `tutorials/scripting/gdscript/gdscript_exports.rst:373`. Grep de `@export var .*: PackedScene` en salas y puertas.
- Lo que se instancia en juego, con `const ESCENA_X: PackedScene = preload(...)` e `instantiate()`; nunca
  `load()` dentro de `_physics_process` (`nucleo/jugador.gd`, `ESCENA_PROYECTIL`).
  `tutorials/scripting/resources.rst:144`. Grep de `load(` dentro de `_physics_process`.
- Una sola sala en el árbol; no se guardan salas ocultas
  (`tutorials/scripting/change_scenes_manually.rst:86`). Guion `nucleo/cambio_de_sala`.
- Un nodo sin nada que hacer se apaga con `set_process(false)`, no con un `return` temprano cada cuadro
  (`nucleo/niebla.gd`, `nucleo/planta.gd`). `tutorials/scripting/idle_and_physics_processing.rst:22`. Se revisa leyendo el script.
- Cada nodo cuesta: muchos objetos simples se dibujan en un solo `_draw` (`mapa/lienzo_mapa.gd`), no un nodo por objeto
  (`tutorials/performance/cpu_optimization.rst:223`, `tutorials/2d/custom_drawing_in_2d.rst:20`). Se revisa leyendo la escena.
- `_draw` se cachea: en un nodo nuevo, `queue_redraw()` solo cuando cambia lo que se dibuja, con guarda
  (`nucleo/controles_tactiles.gd`). `tutorials/2d/custom_drawing_in_2d.rst:61`, `:933`. Lo que cambia casi cada
  cuadro, como el jugador, redibuja siempre (`:122`). Se revisa leyendo el script.
- No pedir valores a `RenderingServer` ni `PhysicsServer2D` cada cuadro: los detiene
  (`tutorials/performance/using_servers.rst:335`). Grep de esos nombres.

Partículas:

- Estallidos con `one_shot = true` y `explosiveness = 1.0` (`nucleo/cortable.gd`).
  `tutorials/2d/particle_systems_2d.rst:159` y `:182`. Se revisa leyendo la escena.
- En una sala de juego, los emisores ambientales (niebla, esporas) llevan `preprocess`, para que la sala no
  arranque vacía (`sala_arte.gd`; la sala de recursos es de medición). `tutorials/2d/particle_systems_2d.rst:168`. Se revisa leyendo la escena.

Hechos del proyecto:

- `Arranque` pone `disable_3d` en la vista raíz: el juego no dibuja 3D
  (`tutorials/rendering/viewports.rst:210`). Un `SubViewport` nuevo también lo lleva. Grep de `disable_3d`.
- El bus Master lleva un limitador como último efecto, contra el recorte
  (`tutorials/audio/audio_effects.rst:203`). Guion `nucleo/sonido`; oírlo en el teléfono.
- Los adornos que sobran en gama baja llevan un hijo `Prescindible`, y lo animado lee `Recursos.bajos()` al
  entrar a la sala (contrato, «Recursos»). Guion `nucleo/recursos_cuentas`.

## Medir en el S50 antes de decidir

Ninguno de estos se cambia sin una medida en el teléfono; la decisión queda escrita en el plan activo o en
`ESTADO.md`.

| Tema | Qué medir | Doc |
|---|---|---|
| Interpolación de física | Si a 60 ticks se nota saltón en un teléfono de 90 o 120 Hz. Si se activa, solo `CPUParticles2D` se interpola | `tutorials/physics/interpolation/physics_interpolation_introduction.rst:56`, `tutorials/physics/interpolation/2d_and_3d_physics_interpolation.rst:12` |
| Partículas CPU o GPU | FPS con cada una en el S50; la razón de la elección, escrita | `tutorials/2d/particle_systems_2d.rst:28` |
| Fondo en VRAM o Lossless | Artefactos visibles y memoria (`dumpsys meminfo`) | `tutorials/assets_pipeline/importing_images.rst:187`, `:260` |
| Calentar shaders y partículas | Tirón al primer uso de un efecto con el APK recién instalado; si lo hay, mostrarlo un cuadro durante el fundido de entrada (Compatibility no tiene ubershaders) | `tutorials/performance/pipeline_compilations.rst:15`, `tutorials/rendering/jitter_stutter.rst:93` |
| Cambio de sala | Tiempo en negro de `change_scene_to_file`: el APK de desarrollo imprime `SALA <clave> carga_ms=<n>` (`adb logcat`); carga en segundo plano solo si se nota | `tutorials/scripting/scene_tree.rst:189`, `tutorials/io/background_loading.rst:14`; guion `nucleo/cambio_de_sala` |
