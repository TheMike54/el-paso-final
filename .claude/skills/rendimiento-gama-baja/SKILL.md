---
name: rendimiento-gama-baja
description: Rendimiento en teléfonos de gama baja (S50, S20) con el renderer Compatibility. Usar antes de agregar arte, texturas, partículas, capas translúcidas, shaders, dibujo con _draw o una sala nueva, y antes de medir FPS o proponer una optimización.
---

# Rendimiento en gama baja

Citas a `$env:GODOT_DOCS` como `archivo:línea`; «Cómo se comprueba aquí» dice cómo revisar la regla. Lo que no esté
aquí se busca con Grep ahí (ruta `tutorials/...`) antes de suponerlo. El presupuesto por sala y el límite de texturas
viven en `docs/contrato.md` («Configuración del proyecto») y `docs/arte-y-rendimiento.md` («Recursos»): esta skill remite a él, no lo repite.

## Primero: medir en el S50 antes de optimizar

- Ningún cambio por rendimiento sin una medida antes y otra después en el teléfono; el que no sube los FPS se
  quita. `tutorials/performance/cpu_optimization.rst:16`, `tutorials/performance/general_optimization.rst:240`.
- Cómo: APK del preset «Desarrollo», que arranca con `--print-fps`, y `adb logcat -s godot`
  (`tutorials/scripting/logging.rst:33`). Los pasos y dónde anotar están en `docs/pruebas.md`, filas
  «Rendimiento en el teléfono», «Recursos (sala de medición)» y «Sala de arte (rendimiento)», y la sección
  «Medición de rendimiento» (la herramienta que mide una sala con y sin cada capa).
- No suponer que «el límite es el relleno»: hay mediciones en contra en `docs/componentes.md` (fila de
  `MonedasSueltas`) y `docs/arte-y-rendimiento.md` («Mediciones»).
- Decir qué tipo de lentitud es: FPS bajos constantes, picos (tirones) o carga lenta
  (`tutorials/performance/general_optimization.rst:39`).
- Decir si limita la CPU o la GPU: el cuadro dura lo que tarda el más lento, y optimizar el otro no sube nada
  (`tutorials/performance/general_optimization.rst:289`). Aquí se prueba apagando capas una por una en la sala
  de arte (`herramientas/salas/sala_arte.gd`); las mediciones registradas están en
  `docs/arte-y-rendimiento.md`, «Mediciones».
- Rendimiento se mide en el S50 y en el S20; lo funcional, en uno
  (`tutorials/performance/general_optimization.rst:74`).

### Protocolo A/B

Una cifra solo se compara con otra tomada en las mismas condiciones. Si algo de esto cambió entre A y B, no vale y
se repite.

1. Fijo, y escrito junto al resultado: el teléfono por su serie (`adb devices -l`), el preset del APK, la sala y la
   posición, Recursos efectivo (no el guardado: un «alto» guardado a mano hizo que el S50 midiera 10 FPS en La Celda),
   luces 2D y «Ver hitbox» apagado (`medir-fps.ps1` falla si está encendido). El APK se instala con
   `.\herramientas\instalar-apk.ps1 -Telefono <serie>`, que pasa solo si imprime `INSTALAR-APK OK` y la línea
   `INSTALADO ... lastUpdateTime=...`.
2. Tasa de refresco fija. Si la pantalla la adapta (el S21 saltó entre 50 y 94 FPS de una vuelta a otra), esas
   vueltas no sirven.
3. A y B salen del mismo APK, con un interruptor: un eje de `herramientas/pruebas/medicion.gd` (`--recursos`,
   `--luces`, `--niebla`), o los botones de la sala de arte para sus capas. Si lo que se prueba no tiene eje, se
   agrega uno en `medicion.gd`. No se edita un script del juego para exportar otro APK sin el efecto: así quedó
   `jugador.gd` modificado mientras el teléfono se desconectaba. Una mutación para ver si un caso la detecta va con
   `.\herramientas\mutar.ps1`, que restaura el archivo siempre, no con `sed` sobre el archivo real.
4. Cada vuelta es una corrida de
   `.\herramientas\medir-fps.ps1 -Telefono <serie> -Etiqueta <a|b> -Segundos <n> -Recursos <auto|bajo|alto> -Abrir`,
   repetida en este orden: A, B, A, B, A, B (al menos tres de cada una), con la misma serie, los mismos `-Segundos` y
   el mismo `-Recursos`. `-Recursos` no cambia el ajuste: comprueba que el teléfono tiene el pedido y falla si no.
   `-Abrir` cierra y abre el juego de cero, así que mide lo que sale al arrancar; para medir una sala se quita
   `-Abrir` y se deja el juego en esa sala antes de cada corrida (cabecera de `medir-fps.ps1`, paso 3).
5. Antes de contar, comprobar con una captura o con el log que pasó lo que se mide (que curó, que la capa está
   encendida). Si no, la vuelta se descarta.
6. `medir-fps.ps1` guarda el log mientras corre y falla si la app pierde el primer plano; no se rearma un script de
   medición en el scratchpad. Cada corrida deja `build\fps-<serie>-<fecha>.txt`.
7. De cada corrida se toma la `mediana=` de su línea `FPS ...`. Se reporta la mediana de esas medianas por variante,
   el `minimo=` más bajo y el ruido (cuánto varían las medianas de A entre sus corridas). Una diferencia menor que el
   ruido no es resultado. `medir-fps.ps1` no da el peor cuadro (`--print-fps` no lo imprime); si hace falta
   `peor_ms`, se mide con `medicion.tscn` (`MEDICION_DATO ... peor_ms=`), con la misma duración en todas las vueltas
   (`--calentar` y `--muestra`), tres corridas y los resultados leídos de `adb logcat -s godot` mientras corre, no
   con `logcat -d` al final: el búfer del S50 solo guarda las últimas líneas.
8. Si el criterio del plan no se cumple, se reportan la mediana y los bajones y decide Miguel; el umbral no se cambia
   sin su aceptación escrita.

## Convenciones que el repo ya sigue

Dibujo y GPU (Compatibility: costo base bajo, pero cada efecto extra cuesta mucho; regla y medidas del proyecto en
`docs/arte-y-rendimiento.md`, «Recursos»):

| Regla | Doc | Cómo se comprueba aquí |
|---|---|---|
| Respetar el presupuesto por sala del contrato (emisores, partículas, plantas, sin `Light2D`) | `docs/arte-y-rendimiento.md`, «Recursos» | `validar.ps1` |
| A lo más 2 capas translúcidas grandes por sala: el sobredibujo es caro en móvil | `tutorials/performance/gpu_optimization.rst:260` | `validar.ps1` (entrada `validador-capas-translucidas`) |
| Un material compartido por todos los nodos que lo usan: `nucleo/arte/sin_luz.tres` y `nucleo/arte/aditivo.tres` (`EfectoCuadros.material_sin_luz()`, `LuzSala.material_aditivo()`), como `ext_resource`, nunca `sub_resource` ni `Material.new()` | `tutorials/performance/gpu_optimization.rst:85` | Grep de `Material.new` y de `CanvasItemMaterial` en `sub_resource`: ninguno en el mundo |
| En el mundo no se dibuja con `FigurasVector` ni con `_draw` lo que se repite: se hornea a PNG con `herramientas/generar_efectos.gd`. Ningún `queue_redraw()` en `_process` sin una guarda que lo haga solo cuando algo cambió | `tutorials/2d/custom_drawing_in_2d.rst:60-66` (`_draw` se guarda y solo se repite con `queue_redraw`); el costo se midió: `docs/componentes.md`, fila de `MonedasSueltas` | `validar.ps1` avisa (`AVISO`) del `queue_redraw` sin guarda; medir A/B en el S50 |
| Shaders mínimos, con las menos lecturas de textura posibles | `tutorials/performance/gpu_optimization.rst:187` | Leer el shader; medir en el S50 |
| No contar con MSAA 2D, glow HDR ni estelas de partículas: Compatibility no los tiene | `tutorials/rendering/renderers.rst:298` | Grep de `msaa`, `hdr_2d`, `trail` |
| Brillos y chispas con `CanvasItemMaterial` en modo Add, no con luces 2D en la escena; la única excepción es la `PointLight2D` que `LuzSala` crea en código con `luces_avanzadas` | `tutorials/2d/2d_lights_and_shadows.rst:372` | `validar.ps1` (falla con `Light2D`) |

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
  del arte del mundo con transparencia en VRAM. Excepción decidida con medida: los fondos translúcidos de la sala de
  arte (`ALFA_EN_VRAM` en `herramientas/validar.gd`; razón y medida en `docs/arte-y-rendimiento.md`, «Recursos» y «Mediciones»). Una excepción
  nueva se mide igual (artefactos y `dumpsys meminfo`) y va en los dos lugares.

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
  entrar a la sala (`docs/arte-y-rendimiento.md`, «Recursos»). Guion `nucleo/recursos_cuentas`.

## Medir en el S50 antes de decidir

Ninguno de estos se cambia sin una medida en el teléfono; la decisión queda escrita en el plan activo o en
`ESTADO.md`. Ya decididos con medida, en `docs/contrato.md`: la interpolación de física, apagada («Configuración
del proyecto»; si se reabre, solo `CPUParticles2D` se interpola,
`tutorials/physics/interpolation/2d_and_3d_physics_interpolation.rst:12`; revisar `reset_physics_interpolation()` al
teletransportar, `tutorials/physics/interpolation/using_physics_interpolation.rst:136`, y la cámara,
`tutorials/physics/interpolation/advanced_physics_interpolation.rst:48`), y Lossless o VRAM por imagen (`docs/arte-y-rendimiento.md`, «Recursos»).

| Tema | Qué medir | Doc |
|---|---|---|
| Partículas CPU o GPU | FPS con cada una en el S50; la razón de la elección, escrita | `tutorials/2d/particle_systems_2d.rst:28` |
| Calentar shaders y partículas | Tirón al primer uso de un efecto con el APK recién instalado; si lo hay, dibujarlo unos cuadros en el menú con `CalentadorShaders` (`nucleo/calentador_shaders.gd`), como se midió en el #57 (`docs/arte-y-rendimiento.md`, «Mediciones»); un efecto con otro material se agrega a su lista `MATERIALES` y se mide igual. Una variante con Light2D (`luces_avanzadas`) no está cubierta ni medida: pide cambiar el calentador (Compatibility no tiene ubershaders) | `tutorials/performance/pipeline_compilations.rst:15`, `tutorials/rendering/jitter_stutter.rst:93` |
| Cambio de sala | Tiempo en negro de `change_scene_to_file`: el APK de desarrollo imprime `SALA <clave> carga_ms=<n>` (`adb logcat`); carga en segundo plano solo si se nota | `tutorials/scripting/scene_tree.rst:189`, `tutorials/io/background_loading.rst:14`; guion `nucleo/cambio_de_sala` |
