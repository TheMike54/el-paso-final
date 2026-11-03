# Continuar el juego

Qué no viene en el repositorio y cómo suplirlo, qué límites ya se conocen y cómo publicar desde cero. Comprobado el 2-nov-2026 leyendo el repositorio; lo que no se ejecutó dice «sin comprobar».

## Lo que no está en el repositorio

| Qué falta | Por qué | Cómo suplirlo |
|---|---|---|
| Originales del arte: hojas, imágenes sin recortar y descartes | El repo solo guarda el resultado procesado | Partir del PNG procesado o generar de nuevo; ver «Arte nuevo» |
| Textos con que se generó cada imagen o video | No se versionan (`docs/guias/arte.md`, paso 1) | Escribirlos otra vez. El PNG del repo sirve de referencia visual |
| Hojas y atlas fuente del jugador | Ver «Atlas del jugador» | Ver «Atlas del jugador» |
| Arte de la protagonista mujer | Nunca se hizo; `ELEGIR_PERSONAJE` está en `false` (`nucleo/nueva_partida.gd`) | Atlas completo nuevo; después encender esa constante |
| Scripts de recorte, escalado y ajuste de tono | Quedaron fuera; `docs/uso-de-ia.md` solo los menciona | Escribir uno propio: ver «Arte nuevo» |
| Generador de los efectos de sonido | Script externo con numpy | Usar cualquier WAV propio, con `docs/guias/sonido-y-musica.md` |
| Montaje y sonido de las cinemáticas, y el escalado con Real-ESRGAN | Trabajo externo | Exportar `.mp4` H.264 y `.ogv` Theora con el mismo nombre (`docs/guias/cinematicas.md`) |
| Clave de firma y credenciales | Nunca entran al repo (`.gitignore`) | Crear una propia: ver «Publicar desde cero» |
| Plantilla Gradle (`android/`) y caché `.godot/` | Se regeneran | Paso 3 de «Publicar desde cero» y `--import` |
| `contenido/preguntas_mochila.tres` | No existe todavía | Es opcional: sin él la mochila se recupera enseguida (tarjeta #28) |
| `contenido/estaciones.tres` | No existe todavía | Opcional hasta colocar estaciones |
| `contenido/enemigos/` | No existe todavía | Lo crea el primer enemigo (`docs/guias/agregar-un-enemigo.md`) |
| Música de sala | Solo existe el tema del menú | `docs/guias/sonido-y-musica.md` |

Las herramientas que sí vienen: `herramientas/generar_efectos.gd` (hojas de efectos, niebla y monedas), `herramientas/generar_trazo.gd` (trazo del ataque), `herramientas/generar_mapa.gd` (índice del mapa) y `herramientas/generar_sprites.gd` (animaciones del jugador).

## Atlas del jugador

**Hecho.** En el repo están el atlas (`nucleo/arte/jugador_hombre/atlas_0.png`) y su `SpriteFrames` (`nucleo/arte/jugador_hombre/jugador_hombre.tres`), y funcionan. Reempacar el atlas desde las hojas originales no se puede hacer desde un clon: el script que lo empaca lee esas hojas y no está en el repo. Sí se pueden modificar animaciones en el `SpriteFrames` del editor y agregar cuadros de otra imagen; `generar_sprites.gd` también permite fijar velocidad, bucle y duración desde un JSON propio.

**Qué sí se puede hacer.** `herramientas/generar_sprites.gd` escribe el `.tres` desde un JSON externo, con `--atlas=<json>`. El JSON no se versiona, pero su forma se lee en ese script:

| Clave | Contenido |
|---|---|
| `lienzo` | `[ancho, alto]` común de todos los cuadros |
| `paginas` | Nombres de las imágenes del atlas, dentro de `nucleo/arte/jugador_hombre/` |
| `animaciones` | Lista de `{nombre, fps, bucle, cuadros}`; `bucle` es `no`, `lineal` o `vaiven` |
| `cuadros` | Lista de `{pagina, region, margen, duracion}`; `region` son 4 números y `margen` 2 |

Para rehacerlo, hay que escribir un empacador que recorte cada hoja, coloque los cuadros y produzca imagen y JSON. Debe conservar los nombres de animación de `nucleo/animacion_jugador.gd`. El metadato `pasos` se copia solo del `.tres` anterior. Reglas de importación: `docs/arte-y-rendimiento.md`, «Recursos». Sin comprobar: nadie ha hecho este camino desde un clon limpio.

Alternativa sin empacador: abrir el `SpriteFrames` en el editor y sumar cuadros sueltos en una imagen aparte.

## Arte nuevo

- **Herramienta.** Todo el arte nuevo se genera en Google Flow: imágenes con Nano Banana Pro y video con Veo 3.1 Lite. Flow cambia seguido, así que hay que revisar la interfaz en pantalla. Sin comprobar: cómo se ve con una cuenta sin plan de pago.
- **Se generan primero las imágenes y después el video,** con imagen de inicio y de fin.
- **Procesar.** Las imágenes llegan en JPG. Hay que recortarlas, escalarlas y pasarlas a PNG con transparencia. Escala y capas: `docs/arte-y-rendimiento.md`, «Recursos».
- **Tamaños.** Personaje de 160 px en la vista de 1280×720; ninguna imagen de más de 2048 px. El único ícono de amuleto en el repo mide 112×112 y se ve a 56 px (`LADO_ICONO_FILA` en `nucleo/tema.gd`).
- **Entrar al juego.** `docs/guias/arte.md`, y su línea en `docs/uso-de-ia.md`. Para íconos, su sección «Iconos de amuleto o útil».
- **Mipmaps.** Todo PNG de `contenido/` los necesita o el validador falla; se ajustan en el panel Import del editor.

## Límites conocidos

**Del juego**

- La campaña termina en un hueco provisional de `celda_4`, y no hay enemigos en `contenido/`.
- Solo español y solo Android; la PC sirve para desarrollar.
- Dormido en el banco, el jugador animado se ve sentado en el aire.
- En la PC, Espacio es `ui_accept` y `atacar`: cerrar un menú con Espacio también ataca.
- Corazones y barra del HUD siguen en gris, sin arte final.
- Hasta terminar el juego las partidas viejas no se conservan al cambiar la versión de guardado.
- Si se cambia un ID ya guardado, las partidas existentes pierden esa referencia.

**Del proyecto**

- Doble `curacion_empezada` si `curar` se suelta y se pulsa entre dos ticks: leído, sin reproducir.
- Guiones intermitentes: `habilidad_caida_en_picada_desde_suelo` y `sala_puerta_b_pared`. Si fallan, se repiten antes de investigar.
- `prueba_sonido` con ventana falla en «un paso suena por play_stream»; sin ventana y en el CI pasa.
- El código de salida de Godot no sirve: hay que usar `.\herramientas\validar.ps1` y `.\herramientas\correr-guiones.ps1`.
- Mover o renombrar una escena fuera del editor rompe rutas (`CLAUDE.md`, «Entorno y trampas»).
- Las pruebas de sensación, táctil y FPS son manuales: ver `docs/pruebas.md`. Varias filas siguen sin marcar en los `funciones.json`.
- Un APK firmado en otra máquina no se instala encima del que ya está, y desinstalar borra partidas.

## Publicar desde cero

Estado: el 2-nov-2026 se exportó a mano el AAB firmado (105 MB) y se subió a la prueba cerrada de Play. **Sin comprobar: el workflow `Release`, que exporta en GitHub (`docs/guias/publicar.md`).** Tampoco está cerrada la prueba manual `paquete-publicacion`.

1. **Herramientas.** JDK 17 y Android SDK, según `tutorials/export/exporting_for_android.rst`, y las plantillas de exportación de Godot 4.7.2. En Ajustes del editor, poner `Java SDK Path` y `Android SDK Path`.
2. **Identidad.** En `export_presets.cfg`, cambiar `package/unique_name` en los dos presets por un id propio. Play no deja reutilizar el de otra publicación. Ajustar nombre e ícono si el juego cambia de autor.
3. **Plantilla Gradle.** El preset «Publicacion» usa Gradle y formato AAB. Instalarla desde el menú Proyecto (`tutorials/export/android_gradle_build.rst`). Crea `android/`, que git ignora.
4. **Clave.** Crearla con `keytool` (`tutorials/export/exporting_for_android.rst:149`), fuera del repositorio y con respaldo: sin ella no se puede actualizar el juego publicado. Pasarla al editor o por las variables `GODOT_ANDROID_KEYSTORE_RELEASE_PATH`, `_USER` y `_PASSWORD`.
5. **Versión.** Cada subida pide un `version/code` mayor. El workflow `Release` lo recibe al lanzarlo; a mano, se cambia en `export_presets.cfg` sin hacer commit.
6. **Validar.** `.\herramientas\validar.ps1` debe imprimir `fallos=0`, y `.\herramientas\correr-guiones.ps1`, `MALOS=0`.
7. **Exportar.**

   ```powershell
   & $env:GODOT_PATH --headless --path . --export-release "Publicacion" build\el-paso-final.aab
   ```

8. **Revisar el paquete.** Con `--export-pack`, según `docs/contrato.md`, «Paquete de publicación»: nada de `herramientas/pruebas/` ni del validador.
9. **Play Console.** Seguir `docs/guias/publicar.md`: prueba cerrada, grupo, instalación desde el enlace y revisión de arranque, controles, guardado, audio y recorrido. Una cuenta nueva pasa por la revisión de identidad de Google. Sin comprobar: cuánto tarda y qué más pida la consola hoy.

Ni el AAB, ni la clave, ni `export_credentials.cfg` entran al repositorio.

## Qué sigue

La lista viva está en `ESTADO.md` y en los `funciones.json` de cada bloque. Los planes abiertos, en `planes/activos/`. Lo que falta decidir, en [decisiones.md](decisiones.md).
