# La cinemática podía quedarse sin salida si el video H.264 fallaba

- **Síntoma:** no se vio en un teléfono; lo encontró la auditoría del 25-oct-2026 leyendo `ReproductorVideo`. Sin el
  modo desarrollador la cinemática solo sale con la señal `terminado`, y había tres caminos en los que nunca llegaba:
  la espera del id de la `ExternalTexture` no tenía tope (sin la extensión que pide,
  `classes/class_externaltexture.rst:24`, no llega), no se revisaba la excepción de `start` ni de las llamadas
  intermedias (`setSurface`, `setLooping`, `setVolume`), y un error de decodificación a mitad no tenía quien lo
  oyera. Además, un `detener()` o un `pausar(true)` durante esa espera no frenaban el arranque: el video podía sonar
  en una escena que ya se iba, o detrás de Configuración.
- **Causa:** `reproducir()` esperaba en un `while` sin tope y, al volver del `await`, no miraba si alguien lo había
  detenido; solo `OnCompletionListener` avisaba el fin.
- **Arreglo:** tope de `ESPERA_TEXTURA` (120) cuadros y después el respaldo; cada llamada a `MediaPlayer` pasa por
  `_llamar`, que revisa `get_exception` (`classes/class_javaclasswrapper.rst:36`); el mismo proxy implementa
  `OnErrorListener` (`onError` → respaldo); un vigilante lee la posición cada segundo y termina el video sin bucle si
  no avanza en 5 s de reproducción (la primera versión comparaba con `getDuration()` + 2 s y en el S50 cortó el
  final de la cinemática: se descartó); un contador de generación cancela un `reproducir()` que vuelve de su espera si
  hubo un `detener()` o un `reproducir()` nuevo, y con Configuración abierta no arranca hasta que se cierra.
- **Lo cubre:** `herramientas/pruebas/prueba_video.gd` (guion `herramientas/guiones/nucleo/video.guion`): el respaldo
  sin archivos termina la cinemática, un `onError` también, y un `detener()` antes del fin no la termina (sin el
  contador de generación, falla). La ruta de Android (tope, excepciones y vigilante) solo se prueba en el teléfono:
  el 25-oct-2026 en el S50 con `adb`, la cinemática completa llegó a La Celda sin aviso (fin de `MediaPlayer` a los
  ~129,6 s de un video de 129,4 s) y con una copia dañada del mismo tamaño en `user://video/` falló `prepare` y pasó
  directo a La Celda.
