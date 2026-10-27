CERRADO

# Animaciones del cuerpo del jugador (hombre)

Primera vuelta: en lugar del rectángulo provisional, el jugador se dibuja con un `AnimatedSprite2D` que usa las 13
hojas aprobadas del personaje. La física, el control y las áreas de choque y de golpe no cambian. Los efectos (arco
del golpe, estocada, parry, aura de curar, bola) siguen siendo los provisionales de `_draw`, dibujados encima.

Decidido por la persona el 21-oct-2026:
- Va en este PR, en un bloque de commit propio (14).
- Solo el cuerpo; los efectos, después.
- Plan aprobado, con la entrada nueva `animacion-cuerpo-jugador` en `nucleo/funciones.json`.
- Mipmaps: se midieron las dos versiones en el S50 (mismo FPS, PSS ±1 MB). Cerrado el 21-oct: sin mipmaps. El
  juego se dibuja a 1280 × 720 y el personaje no se ve más chico que su arte, donde los mipmaps no cambian nada. Si
  en el teléfono los bordes del personaje parpadean al mover la cámara, se reabre (ver «Riesgos»).
- La skill de animación y el resto de la animación (efectos, segunda vuelta) van después de este PR.
- Ataque pegado a la pared: `ataque_lado` hacia `_mirando`, que es hacia el muro, donde de verdad sale el área. El
  dibujo coincide con el juego. Un golpe hacia afuera como el de Hollow Knight sería un cambio de juego: va aparte,
  más adelante, con su propia hoja.

Revisado el 21-oct-2026 contra:
- la documentación de Godot 4.7 y las skills del repo;
- el código de Hollow Knight y Silksong (`HeroAnimationController`, `SpriteFlash`, `InvulnerablePulse`,
  `tk2dSpriteAnimator`).

Lo que cambió por esa revisión va marcado con (rev).

## Qué cambia

**Atlas.** Un script fuera del repo recorta las hojas y escribe al repo `nucleo/arte/jugador_hombre/atlas_0.png`, una
página de 2048×1024 o menos.
- De pie mide 160 px (escala 1x de `docs/contrato.md`, «Recursos»).
- Importación Lossless, como manda el contrato para arte con alfa, con «Fix Alpha Border» activado para el borde de
  las hojas que llegaron en JPG (`tutorials/assets_pipeline/importing_images.rst:177-189,423-433`).
- Cada cuadro es un `AtlasTexture` con `region` justa y `filter_clip`. El desplazamiento dentro del lienzo común va
  en `margin.position`.
- `margin.size` redimensiona el dibujo (`classes/class_atlastexture.rst:102`): la prueba comprueba que cada cuadro
  mide lo mismo que el lienzo. (rev)
- El lienzo es común a todos los cuadros (como el Knight, 590 de 891 cuadros con el mismo lienzo), con el eje del
  cuerpo en su centro horizontal y los pies en una línea fija. (rev)

**`SpriteFrames`.** `nucleo/arte/jugador_hombre/jugador_hombre.tres`, generado con `ResourceSaver` en un guion
headless, para que Godot ponga el formato (`classes/class_resourcesaver.rst:24`); no escribe UID en el `.tres`, como
`mapa/indice_salas.tres`, y la escena lo nombra por ruta. El guion no viaja en el
paquete: va a `herramientas/` con su exclusión en el preset «Publicacion». (rev)

**`nucleo/animacion_jugador.gd`** (nuevo). `elegir(estado) -> StringName` es una función pura con la tabla de
prioridades, en el orden de `HeroAnimationController.UpdateAnimation`. Gana la primera que se cumple:
1. muerte, fundido de peligro, dormir;
2. daño, aterrizaje duro, picada;
3. curar, bola;
4. estocada, ataque (abajo, arriba, lado), voltereta, impulso;
5. pared y salto de pared, aire, carrera, correr, quieto.

El giro en carrera no va en la tabla: es una capa que se aplica después de elegir, solo en el suelo, como el `Turn`
de HK. (rev)

**`nucleo/jugador.gd`.**
- Al final de `_physics_process`, después de mover y solo leyendo, llena el estado y fija animación y cuadro. Los
  estados con tiempo propio toman el cuadro de sus contadores de ticks; los bucles los corre el sprite. Con la
  interpolación de física apagada, el cuadro va a la par del tick y no se repite a 120 FPS. (rev)
- Volteo con `Dibujo.scale.x = ±1`, como HK voltea el objeto raíz, y no con `flip_h`. Así no hay riesgo con
  `margin`, y los efectos que más adelante sean hijos de `Dibujo` giran solos. (rev)
- Congelado: `speed_scale = 0`.
- Invulnerable: parpadeo con `modulate`, como el `InvulnerablePulse` de HK. Curando: tinte con `modulate`.
- Destello: un shader mínimo `mix(color, blanco, cantidad)` con un solo material. `Color(2, 2, 2)` no sirve en
  Compatibility, que es de rango bajo y satura en 1 (`tutorials/rendering/renderers.rst:352,377`); además `modulate`
  multiplica y no aclara el contorno negro. HK hace lo mismo con `_FlashAmount`. El costo se mide en el S50. (rev)
- `_draw` conserva solo los efectos.

**`nucleo/jugador.tscn`.** Nodo `Dibujo` (`AnimatedSprite2D`, `centered = false`, `offset` fijo a los pies,
`show_behind_parent`). (rev)

## Segunda vuelta (no en este PR)

Transiciones (frenar, aterrizar, despertar, doble salto, impacto de la picada, soltar curar):
- viven en una memoria propia del dibujo;
- se disparan al cambiar el estado leído y terminan con `animation_finished`;
- solo tapan a quieto y correr, como el `Land` y el `Run To Idle` de HK;
- `elegir()` recibirá además el clip en curso y si ya terminó;
- la lógica nunca espera a un clip.

## Comprobación

- Línea base del trazador antes de tocar nada; después, `TRAZA IDENTICA n=36`.
- `herramientas/pruebas/prueba_animacion_jugador.gd`:
  - unos 15 casos de prioridad, más el giro como capa;
  - cada nombre existe en el `.tres`;
  - cada cuadro mide lo mismo que el lienzo;
  - en muerte y despertar, la duración del clip en el `.tres` es igual a su constante en ticks, para que el dibujo
    no se desfase sin mandar sobre la lógica. (rev)
- `validar.ps1`, `correr-guiones.ps1` y el `revisor` (jugador).
- APK de desarrollo en el S50: FPS en la sala de recursos y en la zona de pruebas, más `dumpsys meminfo` antes y
  después. VRAM: 8 MiB sin mipmaps, 10,7 con ellos (`importing_images.rst:244`). El tope medido se escribe en
  `docs/contrato.md`, «Recursos».

## Documentos

- `docs/jugador.md` (dibujo).
- `docs/contrato.md` («Recursos» y, si cambia, «Paquete de publicación»).
- `docs/uso-de-ia.md` (Gemini: imágenes del personaje).
- Una entrada nueva en `nucleo/funciones.json`, `animacion-cuerpo-jugador`, con `"pasa": false` hasta tener la
  evidencia.

## Prueba manual (la persona)

- Que cada acción se lea con su animación.
- Que el destello en blanco se note.
- Que no se vea el borde sucio de las hojas en JPG.
- Que la katana se lea a tamaño de juego.
- Hacia dónde mira en la pared.
- Dormir en el banco. Conocido: se ve sentado en el aire, sin arreglar (posible causa en «Riesgos»: `dormir` se dibujó sobre otro banco; sin comprobar).
- Que los bordes del personaje no parpadeen al correr o saltar con la cámara en movimiento (va sin mipmaps).
- Caso «Cuerpo animado del jugador» de `docs/pruebas.md`.

## Avance

21-oct-2026, primera vuelta hecha y revisada; falta la prueba manual en el teléfono.
- Atlas: un script fuera del repo recorta las 13 hojas con el mismo recorte de la escena HTML y escribe
  `nucleo/arte/jugador_hombre/atlas_0.png`: 1976 × 636, 61 cuadros (solo los que usa alguna animación; los demás
  esperan a la segunda vuelta), 8 px entre cuadros, Lossless, sin mipmaps, «Fix Alpha Border» encendido. Lienzo común
  de 316 × 180 con los pies en (158, 176). Revisado a ojo y con una cuenta: 13 píxeles verdosos de 392 876 visibles,
  sin cortes; un halo claro muy fino en el borde.
- `SpriteFrames`: `herramientas/generar_sprites.gd` (+ `.tscn`), 22 animaciones y 61 `AtlasTexture`; lee el JSON
  intermedio por argumento (`--atlas=`), que se queda fuera del repo. Excluido del preset «Publicacion».
- `nucleo/animacion_jugador.gd`: `elegir()`, `con_giro()`, `cuadro()` y `repartir()`, puras. `quieto` usa
  `LOOP_PINGPONG` (1-2-3-2) (`classes/class_spriteframes.rst:105-113`). Dormir: `sentarse` (una vez) y después
  `dormir` en bucle. La muerte dura 90 ticks, como `Sala.TICKS_PARA_REAPARECER`.
- Ataque pegado a la pared: `ataque_lado` hacia `_mirando` (decidido por la persona, ver arriba).
- `nucleo/jugador.gd`: `_animar()` al final de `_physics_process`, después de la cámara; el destello con
  `nucleo/arte/destello.gdshader`; `_draw` solo con los efectos. Se quitaron `COLOR`, `COLOR_INVULNERABLE`,
  `COLOR_MUERTO`, `COLOR_CURANDO`, `COLOR_DESCANSANDO`, `ALTO_SENTADO`, `COLOR_CORRIENDO` y `ANCHO_GIRANDO`;
  `COLOR_DESTELLO` queda solo para la estocada y el estallido.
- Comprobado: `validar.ps1` `OK  VALIDACION archivos=267 fallos=0`; `correr-guiones.ps1`
  `RESUMEN total=155 OK=155 MALOS=0`; trazador `TRAZA IDENTICA n=36` (la base vigente sirvió: antes de tocar nada
  ya daba idéntica); `animacion_jugador.guion` 38 casos, y con curar detrás de la bola, 1 fallo.
- Capturas en ventana (1280 × 720, sala de movimiento): pies sobre el suelo, volteo sin corrimiento, el rectángulo
  del ataque encima del cuerpo, voltereta girada en el aire, destello blanco y muerte tendida sobre el suelo.
- Medición en el S50, 21-oct-2026 (APK de desarrollo con el guion de medición fijo; 60 muestras de `--print-fps`
  tras 5 s; PSS de `dumpsys meminfo` al final; jugador quieto, sin tocar la pantalla):

  | Escena | Sin mipmaps: media / mín. / PSS | Con mipmaps: media / mín. / PSS |
  |---|---|---|
  | Sala de recursos | 59,6 / 58 / 146,7 MB | 59,6 / 58 / 146,9 MB |
  | Zona de pruebas (menú, sin jugador) | 59,6 / 59 / 141,9 MB | 59,6 / 59 / 141,2 MB |
  | Sala de movimiento | 59,6 / 59 / 146,0 MB (repetida; la primera, 57,7 / 42, con un tirón de 8 s al empezar y después 59-60) | 59,6 / 58 / 147,0 MB |

  Atlas importado: 0,99 MB sin mipmaps y 1,48 MB con ellos; APK +0,27 MB. Antes del cambio (18-oct-2026, otro
  estado del código): recursos 59,6 / 58 / 144,0 MB y zona 59,6 / 59 / 142,1 MB. Lo medido no separa las dos
  versiones; queda por mirar la captura en el teléfono con los dos APK de desarrollo.
- Revisión del `revisor` (21-oct-2026), arreglada sin tocar la física:
  - El bucle de la escena (`quieto`) no arrancaba al aparecer: `_animar` solo llamaba a `play` al cambiar de nombre.
    Ahora también arranca un bucle que no corre; `muerte` y `sentarse` no se repiten. Guion nuevo
    `animacion_bucles.guion` (antes del arreglo, cuadro 0 a los 90 ticks; ahora 1).
  - En la pausa tras un peligro salía `aire`: `_colocar_tras_peligro` mueve al jugador sin `move_and_slide` e
    `is_on_floor()` sigue con el valor de la caída. El dibujo cuenta como en el suelo mientras `_reapareciendo`.
    Guion nuevo `animacion_reaparicion.guion` (antes daba `aire` en el cuadro 170).
  - Las duraciones y si cada clip se repite se leen una vez en `_ready` (`_leer_clips`); `repartir` acepta un
    cuadro de inicio y la bola ya no copia el arreglo con `slice`.
  - La cola del ataque (de que acaba el golpe hasta `ticks_entre_ataques`) volvía después de curar, hablar o un
    peligro, porque `_ticks_hasta_ataque` solo baja dentro de `_atacar()`. `AnimacionJugador.actualizar_cola_ataque`
    la corta para siempre si algo la interrumpe; un golpe nuevo la abre. 8 casos nuevos en
    `prueba_animacion_jugador` (46 en total; 7 de la cola y 1 del reparto desde un cuadro).
  - El `.tres` no lleva UID (`ResourceSaver` no lo escribe, igual que `mapa/indice_salas.tres`): corregido el texto
    de arriba.
  - Comprobado: `validar.ps1` `OK  VALIDACION archivos=267 fallos=0`; `correr-guiones.ps1`
    `RESUMEN total=157 OK=157 MALOS=0`; trazador `TRAZA IDENTICA n=36`. Contrapruebas en una copia: sin el arranque
    del bucle, `animacion_bucles` falla (cuadro 0); sin la reaparición, `animacion_reaparicion` falla (`aire` en
    170); sin cortar la cola, 3 fallos en `animacion_jugador`.
  - APK de desarrollo sin mipmaps instalado en el S50 y otro con mipmaps exportado aparte; el repo sigue sin
    mipmaps. No se volvió a medir el FPS.
- Segunda revisión del `revisor` (21-oct-2026): aprobado. Su observación quedó arreglada: tras una estocada, la cola
  del ataque se veía como `ataque_lado` sobre la carrera unos 12 ticks; ahora la estocada deja la cola cortada.
  - 2 casos nuevos en `prueba_animacion_jugador` (48 en total).
  - `validar.ps1` `OK  VALIDACION archivos=267 fallos=0`.
  - `animacion_jugador`, `animacion_bucles` y `carrera_ataque_recarga` OK.
  - Sin el arreglo, el caso nuevo daría `ataque_lado`. Eso sale de leer el código, no de correr una contraprueba.
  - `"pasa": true`.
- Sigue abierto, y con eso se cierra el plan:
  - la prueba manual en el teléfono (lista en «Prueba manual»), con su resultado anotado en `docs/pruebas.md`;
  - mipmaps: cerrado el 21-oct, sin ellos (ver «Decidido por la persona»).

## Riesgos

- Sangrado entre cuadros si se usan mipmaps: el relleno de 4 px alcanza para unos 2 niveles.
- `dormir` se dibujó sobre otro banco: puede quedar desfasado del banco provisional.
- Costo del shader de destello en el S50.

## Cierre (24-oct-2026)

Primera vuelta probada: la persona en el Senwa S50 el 21-oct (pasa, con la pared y el blanco solo en el parry arreglados) y el QA del #6 en un Galaxy A55 5G con DUALSHOCK 4 (issue #8, pasa con observaciones). Fusionado en `main` con el #6. Lo que observó el QA (caminar con la carrera lenta, el aplastado al atacar arriba o abajo, el hueco al morir) sigue en `planes/activos/nucleo-arreglos-qa-6.md`; la segunda vuelta, en su propio plan cuando se pida.
