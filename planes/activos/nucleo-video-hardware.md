ACTIVO

# Video del menú y cinemáticas por el decodificador del teléfono (H.264)

Probado en la demo de La Celda (copia de pruebas, 24 y 25-oct-2026). Va en el mismo PR que `contenido-celda` (v2),
`nucleo-ajustes-avanzados` y `nucleo-trazo-ataque`. Aprobado por la persona el 25-oct-2026; lo ejecuta una tanda autónoma autorizada por
ella.

## Por qué

- Godot solo trae Theora y lo decodifica en el procesador (`tutorials/animation/playing_videos.rst:11-16`). En el S50,
  Theora a 720p da 11-16 FPS y obliga a 480p.
- Con el decodificador del teléfono (Android `MediaPlayer` → `SurfaceTexture` → `ExternalTexture` de Godot,
  `classes/class_externaltexture.rst:22-26`, solo Android y Compatibility; la ruta del PR godotengine/godot#96982), el
  S50 pasa la cinemática a 1080 a 58,7 FPS, completa, y el menú a 52-53. Búsqueda de errores en el S50 y el S21:
  botones encima, HOME y volver, 20 cambios rápidos, pausa, costura del bucle: 0 fallos tras 4 arreglos.
- Peso: un solo `.mp4` a 1080 por video (cinemática 18,4 MB, menú 13 MB) para todos los teléfonos.

## Decidido por la persona (24 y 25-oct-2026)

- H.264 a 1080 desde el escalado con IA, receta `veryslow`, `tune animation`, `crf 25`, perfil `main`, audio copiado.
- **Sin elegir resolución**: un solo archivo. Theora solo para la PC y los guiones; no viaja en el APK (25-oct-2026,
  para no cargar el APK con un segundo video). Si la ruta de Android falla, el menú muestra una imagen fija y la
  cinemática pasa directo a La Celda.
- Cinemática a lo ancho, sin franjas; «Saltar» solo con el modo desarrollador.
- Desenfoque detrás de Configuración en el menú: opción A. La persona vio la versión final y le gustó (25-oct).
- Dejar la ruta del video lo más simple y mantenible posible (al final, sin plugin: V0).

## V0: la ruta sin plugin funciona (25-oct-2026, decidido)

La persona eligió probarla con una hora de límite. Prueba en la copia de pruebas, en el S50 y el S21:
- `JavaClassWrapper` (desde GDScript, `tutorials/platform/android/javaclasswrapper_and_androidruntimeplugin.rst`) arma `SurfaceTexture(id de la
  ExternalTexture)`, `Surface`, `MediaPlayer`, `setDataSource`, `prepare`, `start`. `updateTexImage()` se llama en
  cada `_process`: el bucle de Godot corre en el hilo de dibujo en Compatibility, así que funciona.
- El aviso de fin llega por `JavaClassWrapper.create_proxy(objeto, ["android.media.MediaPlayer$OnCompletionListener"])`.
- Con un export **sin Gradle**, el `.mp4` se copia del paquete a `user://` con `FileAccess`: 13 MB en 122 ms en el
  S50 y 18 ms en el S21, una sola vez.
- Video a 1080 en el menú: 59-60 FPS en el S50 y 117-121 en el S21. La imagen se ve bien con el ajuste por omisión
  `(1, -1, 0, 1)`, sin leer `getTransformMatrix`. Al salir al inicio y volver (`NOTIFICATION_APPLICATION_PAUSED` y
  `RESUMED`), el video se pausa fuera y sigue al volver.
- Errores: `JavaClassWrapper.get_exception()` después de cada llamada (`classes/class_javaclasswrapper.rst:36`).

**Decisión:** sin plugin, sin Kotlin, sin AAR ni Gradle. Por qué: hace lo mismo que el plugin en las mismas pruebas,
y todo queda en GDScript, que el equipo ya mantiene. La exportación sigue siendo la plantilla normal de Godot. El
costo, ~31 MB copiados a `user://` (menú y cinemática), se mide como aceptable: un arranque de 140 ms más la primera
vez en el S50. El plugin recortado que se había diseñado (auditoría del 25-oct, ~120 líneas de Kotlin con su AAR) no
se hizo; si una versión de Android rompe esta ruta, se retoma desde la copia de pruebas.

## Diseño (hecho)

### Un solo nodo para el juego

- `ReproductorVideo` (`nucleo/reproductor_video.gd`, un `AspectRatioContainer`): `crear(ruta_base, bucle, modo)`,
  `reproducir()`, `detener()`, `pausar(si)`, `desenfocar(si)`, señal `terminado`. Usa H.264 si es Android y existe
  `AndroidRuntime` (`usa_h264()`); si no, o si una llamada de Java falla, el respaldo: el `.ogv` con Theora si está
  (PC), si no la imagen `<ruta>.jpg` (menú: `nucleo/video/menu.jpg`, su primer cuadro, 148 KB importada) o negro, y un
  video sin bucle termina al momento. El resto del juego no sabe cuál usa.
- Volumen: Theora va por el bus `Musica`. `MediaPlayer` suena fuera de los buses de Godot, así que H.264 toma
  `Master × Musica` (`AudioServer`), 0 si alguno está en silencio, al arrancar y al seguir tras una pausa, que es
  cuando pudo cambiar (al cerrar Configuración). Antes Theora también lo multiplicaba y sonaba atenuado dos veces
  (lo vio el `revisor`).
- Desenfoque (`desenfocar(true)`), la versión medida en el S50: el video a media pantalla (una sola lectura de la
  textura del decodificador), reducido a 1/8 y desenfocado en una pasada (4×4 muestras con pesos de campana), estirado
  con filtro lineal y **congelado**: se dibuja una vez y el video se pausa mientras Configuración está abierta.
- Sin ventana (guiones), un video sin bucle termina a los 0,5 s: el puerto de guiones cuenta cuadros desde que la
  escena de su línea `escena` está activa, y una escena que cambia en el mismo cuadro no la ve nunca.
- `Cinematica` (`nucleo/cinematica.gd`): video a lo ancho sobre negro; al terminar pasa a `sala_destino`
  (`Sala.ruta_de`). Con el modo desarrollador, «Saltar», Atrás, pausa, B o A la saltan.

### Theora a 480p, solo en la PC

- Cada video lleva su `.ogv` a 480p (menú 3,2 MB, cinemática 9,2 MB): en la PC y en los guiones basta. Desde el
  25-oct-2026 los dos presets lo dejan fuera (`exclude_filter`): el APK de desarrollo bajó de 113 MB a 96 MB
  (100,8 millones de bytes). Decidido por la persona: en el teléfono el respaldo es una imagen, no un segundo video.

### Exportación

- Sin Gradle: la plantilla normal. Godot no importa `.mp4`, así que los dos presets llevan `include_filter="*.mp4"`;
  `ReproductorVideo` copia cada uno a `user://video/` la primera vez (y otra vez solo si cambió de tamaño), porque
  `MediaPlayer` no abre un archivo dentro del paquete.
- Los presets «Publicacion» y «Desarrollo» (32 y 64 bits; «Desarrollo» con `--print-fps`) se pusieron a mano en esta
  rama (decisión 1b de la persona, 25-oct): `chore/android-export` ya no hace falta.
- `.gitattributes`: `*.mp4` y `*.ogv` como binarios.

## Pasos

| Paso | Qué | Resultado |
|---|---|---|
| V0 | Prueba de la ruta sin plugin (`JavaClassWrapper`) en la copia de pruebas | Hecho: sin plugin |
| V1 | `ReproductorVideo` | Hecho: `validar.ps1` (en la PC usa Theora) |
| V2 | Menú con video y desenfoque congelado en Configuración | Hecho: S50 menú 57-58 FPS, Configuración 59-60 (APK de desarrollo, 25-oct) |
| V3 | Cinemática de La Celda antes de la sala | Hecho: guion `contenido/cinematica_celda`; S50 completa a 60 FPS |
| V4 | Presets y los `.mp4` | Hecho: APK de desarrollo instalado en el S50 y el S21; sin `.ogv`, 96 MB (25-oct). El de publicación falta (keystore) |
| V5 | Respaldo en imagen y sin Theora en el APK | Hecho: `validar.ps1` y guiones en verde; en el S50 y el S21 el menú abre sin avisos, 58-60 FPS (25-oct) |

## Lo que solo la persona puede confirmar

- Que audio e imagen vayan juntos y que la costura del bucle del menú no se note.
- Que el volumen del video siga a Música al cambiarlo en Configuración.
