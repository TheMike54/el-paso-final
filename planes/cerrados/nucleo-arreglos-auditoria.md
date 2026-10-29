CERRADO (29-oct-2026, con el PR de `feature/contenido-celda`)

# Arreglos de la auditoría del 25-oct-2026

Aprobado por la persona el 25-oct-2026 («arreglar todos los hallazgos factibles, por prioridad, antes del PR»). Los
hallazgos y su factibilidad salen de la auditoría de esa fecha (tres revisiones: redundancia, rendimiento y Godot,
documentación). Va en el mismo PR que `contenido-celda`.

## Decidido por la persona

- El ataque del jugador solo se ve con el trazo blanco (`TrazoAtaque`): fuera el rectángulo amarillo y la línea de
  la estocada; el área se ve con «Ver hitbox». Lo mismo en el ataque enemigo: fuera los rectángulos blanco y rojo.
- La zona de pruebas, con fondo negro (era verde oscuro).

## Orden

| Paso | Qué | Hallazgo |
|---|---|---|
| 1 | Cinemática sin salida si H.264 falla: tope a la espera del id de la `ExternalTexture`, `get_exception` tras cada llamada Java (también `start`), `OnErrorListener` que termina el video y vigilante que lo termina si deja de avanzar (ver «Hecho») | R1, R12 |
| 2 | `reproducir()` respeta `detener()` y `pausar()` llamados durante su `await` (contador de generación) | R2 |
| 3 | `desenfocar` sin nada que desenfocar no hace nada | R14 |
| 4 | `PanelPruebas` al encender un grupo lo deja como estaba (visible y `process_mode` guardados) | R3 |
| 5 | Ataque: solo el trazo (jugador y enemigo) | D1, D2 |
| 6 | Limpiezas: `Mochila` sin proceso al irse y quieta en el congelado; HUD redibuja las monedas solo si cambian; `FigurasVector` con alto 0; `"\n"` en `recursos.gd`; `_figuras` tipado; comentario de `ContadorFps`; `_alternar.bind` en Configuración; `Ajustes.MODO_DESARROLLADOR`; un solo armado de `TextureRect` en `ReproductorVideo`; comentario de `Colgante`; `_physics_process` de `Cinematica` solo con el modo desarrollador | R6, R7, R15, R17, R18, R19, D5, D6, D7, D9, R16 |
| 7 | Sala de arte sin su medidor de FPS propio (ya lo da `ContadorFps`) ni sus botones de partículas y niebla (los da el panel de pruebas); la capa 11 queda solo para «Frente» y «Anim», que el panel no tiene | D4 |
| 8 | Fuera `contenido/salas/celda/arte/m_tuberia.png`: ninguna escena ni script la nombra, así que quitarla fuera del editor no rompe rutas | D3 |
| 9 | Fondo negro en la zona de pruebas | Pedido de la persona |
| 10 | Documentación, `docs/errores/`, validar, guiones, APK en los dos teléfonos, revisor | — |

## Lo que no se hace, y por qué

- **R4** (capas bajo el video): en el menú los FPS están topados a 60 y el S50 ya da 57-59; la ganancia no se puede
  medir, y la regla del repo es no tocar por rendimiento lo que no sube los FPS.
- **R5** (copia del video por bloques): una vez por instalación, 122 ms en el S50.
- **R8** (`LuzSala` por cuadro), **R11** (niebla generada al cargar), **R9** (panel y hitbox siempre creados): sin
  medida que muestre costo; la niebla está apagada por omisión.
- **R10** (`updateTexImage` por cuadro): pediría `OnFrameAvailableListener` con hilos; funciona en los dos teléfonos.
- **D8** (`&"Master"`), **D10** (`LuzSala.textura`), **D11** (`VerHitbox._formas`), **D13** (peso del `.jpg`),
  **D14** (esqueleto de ajuste común): dos casos o menos, o sin ganancia.
- **D12** (degradados repetidos en `celda_1.tscn`): se comparte el recurso en el editor; queda para la persona.
- **R13** (volver del segundo plano): se prueba en el teléfono con `adb`; si falla, se arregla.

## Hecho (25-oct-2026)

Pasos 1 a 9 hechos. `validar.ps1` → `OK  VALIDACION archivos=286 fallos=0`; `correr-guiones.ps1` →
`RESUMEN total=165 OK=165 MALOS=0` (guion nuevo `nucleo/video`, 6 casos; `piezas_sala`, 26). Cada prueba nueva se
comprobó por mutación: sin el arreglo, falla.

- **Vigilante, cambiado al medirlo:** la primera versión terminaba el video a los `getDuration()` + 2 s de
  reproducción contados con `delta`. En el S50 se disparó 2 ms antes del aviso de fin de `MediaPlayer` y cortó el
  final de la cinemática. Quedó por avance: lee `getCurrentPosition` cada segundo y termina solo si no avanza en 5 s.
- **Medido en el S50 con `adb`** (APK de desarrollo de las 13:50; el S21 se desconectó a media tanda):
  - Partida nueva en la ranura 4: la cinemática completa llega a La Celda sin aviso; `MediaPlayer` avisa el fin a los
    ~129,6 s de un video de 129,4 s.
  - Con `celda.mp4` reemplazado por basura del mismo tamaño: «prepare fallo (Prepare failed.: status=0x1)» y pasa
    directo a La Celda. Después se borró la copia, que se rehace sola.
  - Al mandar la app al fondo y volver (R13), el video del menú sigue: capturas distintas, 58-60 FPS.
- **Encontrado al medir:** una copia dañada del mismo tamaño no se vuelve a copiar, porque solo se compara el tamaño.
  Es parte de R5 y sigue fuera de este plan: no pasa sin tocar `user://` a mano.
- **Tras la prueba de la persona en el S50 (25-oct, noche), decidido por ella:** un disparo enemigo se desvía y no
  se para (desaparece con una chispa chica, sin congelado, destello, retroceso, invulnerabilidad ni Inspiración; suena
  como pegarle a un objeto), como la versión ligera del choque de Silksong (`noClashFreeze`); el banco sienta al
  jugador mirando hacia su silla (`Banco.mirando`; el de La Celda, a la derecha). La pantalla de carga blanca es la
  del sistema Android y se queda así. Guiones `parry` (1 parada y 1 desvío), `enemigos_moviles` y `aterrizaje` (11
  casos); `correr-guiones.ps1` → `RESUMEN total=165 OK=165 MALOS=0`.
- Sin probar en la PC con ventana: que la sala de arte y la zona de pruebas se vean bien. Es una prueba manual de la
  persona (fila «Sala de arte (rendimiento)»).
