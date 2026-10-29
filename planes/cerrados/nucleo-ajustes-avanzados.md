CERRADO (29-oct-2026, con el PR de `feature/contenido-celda`)

# Ajustes avanzados, panel de desarrollo, FPS en pantalla y límite en los menús

Pedido por la persona el 25-oct-2026 a partir de la demo de La Celda (copia de pruebas). Va en el mismo PR que
`contenido-celda` (v2), `nucleo-video-hardware` y `nucleo-trazo-ataque`. Aprobado por la persona el 25-oct-2026, con la maqueta de
Avanzado (paso A0); lo ejecuta una tanda autónoma autorizada por ella.

## Decidido por la persona (25-oct-2026)

- Configuración → **Avanzado ›**, también desde la pausa.
- Luces avanzadas (luces 2D): no se ofrecen en Recursos bajo; en alto, encendidas por omisión.
- Niebla: apagada por omisión en bajo y en alto; quien quiera, la enciende.
- Mostrar FPS: interruptor para cualquier jugador.
- Fondos a baja resolución: fijo, no es opción.
- Con el modo desarrollador: el panel de interruptores por pantalla (el botón «Demo» de la demo, pero bien integrado:
  en la demo se veía mal y era difícil de manejar) y «Ver hitbox».
- **Menús a 60 FPS como máximo**, aunque el jugador elija 120 (no tiene sentido más en un menú).
- Todo sin código repetido y para que las salas nuevas lo tengan sin trabajo extra.
- **Maqueta aprobada** (25-oct-2026, con la revisión de experiencia de uso):
  - Configuración queda con Audio, Brillo, Vibración, Temblor (se queda: es de comodidad), Botones táctiles,
    Botones del control, **Avanzado ›** y Créditos.
  - Avanzado, grupo **Rendimiento**: Recursos, FPS (60/120), Luces 2D, Niebla, Mostrar FPS. Grupo **Desarrollo**:
    Desarrollador; con él en Sí, además Pruebas y Ver hitbox. Encabezados de grupo en `Tema.TENUE`.
  - Luces 2D en Recursos bajo **no desaparece**: se ve bloqueada (`BotonValor.bloqueado`). El aviso de abajo sale
    solo al tocar una opción bloqueada, como el de Recursos de hoy («Luces 2D pide Recursos en alto, y Recursos se
    cambia desde el menú principal»).
  - Contador arriba al centro, tenue. Con el modo desarrollador suma el monitor en la misma línea (peor cuadro, draw
    calls, VRAM, nodos) y se ve aunque el panel esté oculto.
  - Panel de pruebas **ocultable**: cerrado, una pestaña «‹ Pruebas» a media altura a la derecha; abierto, una
    tarjeta a la derecha con «Ocultar ›» y un botón por grupo en 2 columnas (encendido en gis subrayado, apagado
    gastado con «·»). Por comprobar en el teléfono que la pestaña no choca con los botones táctiles.

## Diseño

### Ajustes

- Claves nuevas en `Ajustes` (guardadas como las demás, con su valor por omisión y la validación de tipo):
  `luces_avanzadas` (sí o no, true por omisión; valen solo con Recursos en alto: la maqueta aprobada la muestra Sí/No
  y bloqueada en bajo, así que un «auto» repetiría lo que ya decide Recursos), `niebla` (false), `mostrar_fps`
  (false), `panel_pruebas` y `ver_hitbox` (false; valen solo con el modo desarrollador, `Ajustes.desarrollo`).
- Una función pura por opción derivada, para probarla: `Ajustes.luces_avanzadas_activas(valor, recursos_bajos)`.
- Se aplican **al momento**, también desde la pausa: el bus gana `signal ajuste_grafico_cambiado(clave: StringName)`
  y lo escuchan `LuzSala`, `Niebla` y el contador de FPS. Recursos sigue igual (vale desde la sala siguiente) porque
  cambia lo que existe en la sala, no si se ve. (Bus y autoloads: pasa por el `revisor`.)

### Límite de FPS en los menús

- `Ajustes.limite_fps(elegidos, recursos_altos, refresco)` gana `en_menu: bool`: con `en_menu`, 60 siempre. Sigue
  siendo una función pura con su prueba.
- Un solo `Ajustes.aplicar_fps(en_menu)`, el único lugar que calcula el límite. Lo llama `ContadorFps` (lo crean la
  `Sala` y el menú principal) cuando cambia `get_tree().paused`, que mira en cada cuadro: Godot no tiene señal de
  cambio de pausa (`classes/class_scenetree.rst:140-243`) y hay cinco menús que pausan; así ninguno tiene que
  acordarse de llamarlo y uno nuevo lo tiene gratis. Además lo llaman `Ajustes.cargar` (al arrancar) y Configuración
  al tocar FPS, con `en_menu` (cambiado el 25-oct-2026 al implementarlo).

### Contador de FPS

- `nucleo/contador_fps.gd` (`CanvasLayer` + `Label`): lee `Performance.TIME_FPS` cada 0,5 s (no en cada cuadro), en
  una esquina que no tape el HUD ni los botones táctiles (se elige en la maqueta). Lo crean la `Sala` y el menú, como
  ya crean la pausa y el brillo.
- Con el modo desarrollador y el panel abierto, muestra además peor cuadro, draw calls, VRAM y nodos (lo que medía el
  monitor de la demo).

### Panel de desarrollo

- Lo que la demo hacía con `interruptores_demo()` y `alternar_demo()` en cada pantalla se vuelve automático: el panel
  lista los **grupos** de la escena actual (`luces`, `halos`, `niebla`, `particulas`, `fondos`, `frente`,
  `colgantes`, …) y cada interruptor enciende o apaga todos los nodos de su grupo. Las piezas de
  `contenido-celda` se agregan solas a su grupo, así que **una sala nueva tiene su panel sin código**. Una pantalla
  puede sumar interruptores propios con un método opcional, como en la demo.
- «Ver hitbox»: dibuja encima de cada forma de colisión (rojo daño, verde sólido, azul jugador), en ejecución
  (`SceneTree.debug_collisions_hint` no cambia en ejecución, `classes/class_scenetree.rst:360`).
- **Diferido** (decidido el 25-oct-2026 en la tanda autónoma): el modo automático de medición (rondas por archivo,
  recorrido) y los interruptores propios de una pantalla. Por qué: las mediciones de este PR se hacen con el panel
  (apagar un grupo y mirar el contador de FPS) y con `--print-fps` del APK de desarrollo, como `docs/pruebas.md`; el
  modo automático solo ahorra tiempo cuando haya varias salas que medir, y sin un segundo caso sería generalizar
  antes de tiempo (decisión cerrada del `CLAUDE.md` raíz). Cuando se haga, va en `herramientas/` y el panel lo carga
  con `load()` solo si existe (`docs/contrato.md`, «Paquete de publicación»).

### Recursos

- Arreglo: en Android `OS.get_memory_info()` da -1 (medido en el S50, el S20 y el S21), así que hoy solo cuenta el
  procesador de 32 bits y un teléfono barato de 64 bits cae en alto.
- **Comprobado el 25-oct-2026** en la demo, en el S50 y el S21:
  - `FileAccess.open("/proc/meminfo")` falla (error 1).
  - `OS.execute("cat", ["/proc/meminfo"])` sí lee `MemTotal` (S50 1 978 704 kB, S21 7 373 820 kB).
  - Por `AndroidRuntime` + `getSystemService("activity")`, `ActivityManager.isLowRamDevice()` da 1 en el S50 y 0
    en el S21.
  - `ActivityManager$MemoryInfo` no se puede construir por `JavaClassWrapper` («Nonexistent function»).
- Regla: bajo si `isLowRamDevice()`, si `MemTotal` < 3 GB o si el procesador es de 32 bits; cada lectura que falle
  no cuenta. Solo en Android (`OS.get_name()`); en la PC sigue `OS.get_memory_info()`.

## Pasos

| Paso | Qué | Se comprueba con |
|---|---|---|
| A0 | **Maqueta** de Avanzado (desde el menú y desde la pausa), del contador de FPS y del panel de desarrollo, a 1280×720, 1920×1080 y 2560×1440, hecha con los componentes reales (`BotonValor`, `Tema`) | Aprobada el 25-oct-2026 |
| A1 | Ajustes nuevos, señal del bus, `limite_fps` con `en_menu` | Pruebas de las funciones puras; guion de guardado |
| A2 | Avanzado en Configuración | Guion de menú de configuración |
| A3 | Contador de FPS | Manual (se ve y no tapa nada) |
| A4 | Panel de desarrollo y ver hitbox (el modo automático, diferido) | Guion: un interruptor de grupo apaga sus nodos; validador del paquete |
| A5 | Recursos con la memoria de Android | Manual en el S50 y el S21 (registro) |

## Hecho (tanda del 25-oct-2026)

| Paso | Resultado |
|---|---|
| A1 | Claves nuevas; las de sí o no se reinician, leen y guardan en un bucle (`CLAVES_SI_NO`): eran tres bloques copiados y pasaban a ocho. `Eventos.ajuste_grafico_cambiado`, que emite Configuración. Pruebas de las funciones puras y guion `nucleo/guardado` |
| A2 | `PanelAvanzado` en `configuracion.tscn` (la escena ya armaba así sus paneles): Recursos, FPS y Desarrollador se movieron dentro, sin duplicarse, y la lógica sigue en `Configuracion`. Desarrollador ahora se ve también en la pausa (enciende el panel y ver hitbox al momento): las pruebas que exigían ocultarlo se cambiaron a propósito. Guiones `menu_configuracion` y `marco` |
| A3 | `ContadorFps` (capa 24), cada 0,5 s; lo crean la `Sala`, el menú y la zona de pruebas (`siempre_en_menu`). Capturas a 1280×720, 1920×1080 y 2560×1440. A 720 de alto Avanzado no cabe entero: Ver hitbox queda abajo, con desplazamiento, como las demás listas |
| A4 | `PanelPruebas` (capa 13) busca por grupo (luces, niebla, cables, fondos) y por clase (todo `CPUParticles2D`): una sala nueva tiene su panel sin código; sin grupos dice «Esta sala no tiene grupos.». `VerHitbox` dibuja cada forma (rojo daño, verde escenario, azul cuerpos, amarillo áreas) y no dibuja un área apagada |
| A5 | `Recursos` lee `MemTotal` con `cat /proc/meminfo` y `isLowRamDevice()` por `AndroidRuntime`, con prueba de la función pura. En el S50 el automático da bajo (59,4 FPS en La Celda). Falta ver en el S21 qué dice el automático con este APK: la lectura en el teléfono solo se comprobó en la demo |

## Lo que solo la persona puede confirmar

- La maqueta, y después cómo se ve y se maneja en el teléfono (con el dedo y con control).
- Que la pestaña «‹ Pruebas» no choque con los botones táctiles.
