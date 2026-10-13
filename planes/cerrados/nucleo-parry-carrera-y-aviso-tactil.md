CERRADO

# Núcleo: parry más visible, voltereta del ataque en carrera, rebote en la pared y aviso de pocos toques

Rama `feature/nucleo-parry-carrera-y-aviso-tactil`, sobre `fix/telefono-fps-y-controles`. Sale de la prueba con el
dedo en el S50 del 12-oct-2026 y de comparar con Silksong y Hollow Knight (videos de la persona y la wiki
`hollowknight.wiki`, páginas `Swift_Step` y `Bench_(Silksong)`). Aprobado el 12-oct-2026.

## Referencia medida
- Parry en Hollow Knight: todo se congela 0,3-0,37 s (`NailClashEffect`: 0,01 / 0,25 / 0,1 s), estallido blanco en
  estrella en el punto de choque y los dos salen empujados. Silksong: 0,2-0,3 s, igual de visible.
- Ataque en carrera de Silksong con el blasón de cazadora: si falla, sigue corriendo; si pega, sale lanzada hacia
  arriba y adelante con una voltereta, pasa por encima y cae caminando (la carrera se corta). Durante la voltereta,
  atacar o un impulso la cancelan. Con un enemigo grande choca y recibe daño.
- Chocar con una pared corriendo: rebota un poco y la carrera se corta.
- Carrera de Silksong: 2,12 veces caminar; la nuestra 2,1 (756 contra 360 px/s). El salto en carrera no cambia.

## Fases

**A. Parry** (`nucleo/jugador.gd`; pasa por el `revisor`)
- `ticks_congelado_parry` de 3 a 20 (0,33 s).
- Estallido de rayos blancos en el punto de choque (entre el ataque del jugador y el del enemigo) mientras dura el
  congelado y `TICKS_DESTELLO_PARRY` más. Provisional hasta el arte.
- El jugador sale empujado hacia atrás (`ticks_retroceso_parry`, `velocidad_retroceso_parry`); el enemigo ya sale
  empujado por su `Golpeable` (el muñeco de la sala de parry tiene el empuje en 0 a propósito).
- `ticks_invulnerable_parry` se queda en 15: el segundo golpe de un enemigo que pega dos veces sigue pegando si no
  se para.
- Hito: guiones `parry` y `parry_ventana` con los tiempos nuevos (el reloj del muñeco se detiene 20 ticks por parry).
  **Hecho el 12-oct-2026**: los dos dan `GUION OK`. El muñeco pega una vez por ciclo: que el segundo golpe de un
  enemigo que pega dos veces llegue tras los 15 ticks sin daño no lo prueba ningún guion (es un parámetro).

**B. Voltereta del ataque en carrera** (`nucleo/jugador.gd`; `revisor`)
- Ataque en carrera que golpea un `Golpeable`: corta la carrera y lanza al jugador hacia arriba
  (`altura_voltereta`) y hacia adelante (`velocidad_voltereta`) con una voltereta (`volteando`). Devuelve el doble
  salto y el impulso en el aire, como el pogo. El joystick la dirige; sin dirección sigue hacia adelante.
- Se acaba al tocar el suelo (camina), al atacar, con un impulso, con daño o contra una pared.
- Sin enemigo, la estocada sigue igual; el rectángulo del ataque en carrera se dibuja como una línea blanca larga.
- Hito: `carrera_ataque_golpe` cambia a propósito (voltereta en vez de seguir de frente); guiones nuevos: cae
  del otro lado del muñeco caminando; atacar en el aire la cancela. **Hecho el 12-oct-2026**: `carrera_ataque_golpe`,
  `carrera_voltereta_cae`, `carrera_voltereta_ataque` y `carrera_voltereta_impulso` dan `GUION OK`. Del `revisor`: el golpe
  corta un impulso en curso; el siguiente ataque sale al terminar el actual (Silksong reinicia la recarga); un impulso
  corta un rebote a medias.

**C. Rebote en la pared** (`nucleo/jugador.gd`; `revisor`)
- Chocar con una pared corriendo corta la carrera (ya lo hace) y da un rebote corto hacia atrás
  (`ticks_rebote_pared`, `velocidad_rebote_pared`). Con un enemigo, el daño ya la corta.
- Hito: `carrera_pared_rebote` (nuevo) comprueba el rebote. **Hecho el 12-oct-2026**: `GUION OK`.

**D. Aviso de pocos toques** (`nucleo/toques.gd` nuevo y `nucleo/menu.gd`; Configuración no tiene fondo propio y la línea del menú se ve debajo)
- En Android se pregunta al sistema si la pantalla declara 5 o más toques
  (`android.hardware.touchscreen.multitouch.jazzhand`, con el singleton `AndroidRuntime`). Si no, una línea discreta
  abajo en el menú principal y en Configuración. En PC no se muestra. El juego no cambia.
- Hito: casos en `menu_configuracion` con la detección forzada; en el teléfono, visible en el S50 y oculta en el S20.
  **Hecho el 12-oct-2026**: 41 casos sin fallos; con `adb` y capturas, el S50 avisa (menú y Configuración, sin tapar
  nada) y el S20 no. Godot 4.7.2 entrega el boolean de Java como entero: `Toques` acepta los dos.

**E. Tras la prueba con el dedo del 12-oct-2026 (Senwa S50)** (`nucleo/jugador.gd`, `nucleo/golpeable.gd`; `revisor`)
- Pasan: carrera, estocada, voltereta («como Silksong»), rebote en la pared, giro, parry y Volumen con el dedo.
- Estocada repetida: se podía repetir sin límite. En el video de referencia de la persona
  (`2026-10-12_silksong_ataque-en-carrera-repetido`) salen cada 0,65-0,85 s, cada una es un empujón de ~0,13 s
  (el que ya había) y sin golpe no hay voltereta (confirmado por la persona). Decidido: recarga propia
  `ticks_entre_ataques_carrera` = 42 (provisional); lo pedido antes se pierde y la carrera sigue, sin ataque normal.
  Hito: `carrera_ataque_recarga` (falla sin el cambio) y `carrera_ataque_recarga_fin`. **Hecho**: los dos `GUION OK`.
- El muñeco de la sala de combate, empujado a golpes, salía de la sala por la puerta: el empuje de `Golpeable` no
  miraba paredes ni límites (`docs/errores/2026-10-12-empuje-atravesaba-paredes.md`). Hito: `golpe_contra_pared` y
  `golpe_borde_sala` (fallan sin el arreglo). **Hecho**: `GUION OK`; `validar` 147/0 y 119 guiones OK.
- Segunda prueba en el S50 (APK de las 22:05): la recarga, el empuje contra pared y borde y el congelado pasan. La
  persona pidió que la estocada avance más: `velocidad_ataque_carrera` de 900 a 1150 px/s (provisional), por debajo
  del impulso (1200), unos 52 px más que corriendo en vez de 19. Tercera prueba (APK de las 22:50): «hay que subir
  un poco más», a 1250, por encima del impulso; el tope bajo el impulso era una guarda de Claude, no de la persona. Cuarta prueba (APK de las 23:05): a 1500; después, a 2000. `revisor`: código aprobado; corregidos la
  descripción en `docs/jugador.md` (arriba, pogo y giro no cuentan) y el `.esperado` de `carrera_ataque_recarga`
  (comprueba también que no salga un ataque normal). Decidido con su observación: la voltereta reinicia también la
  recarga del ataque en carrera, como ya reiniciaba la del ataque (fase B); ningún guion lo cubre.
- El paso del congelado pedía «vencer al muñeco» de la sala de combate, que no tiene vida: pasa a la sala de
  enemigos (`docs/pruebas.md`).

## Cierre (12-oct-2026)
- Con el dedo en el S50 (APK de las 22:05): pasan la recarga de la estocada, el empuje contra la pared y el borde y
  el congelado. Entradas `parry-visible`, `carrera-voltereta`, `carrera-rebote-pared` y `aviso-pocos-toques` en
  `true` con sus guiones.
- La estocada quedó en 2000 px/s, probada por la persona en el S50 (APK de las 23:18): «2000 quedó bien».
  Provisional; ajustarla es cambiar `velocidad_ataque_carrera` y sus dos `.esperado`, sin plan.

## Sin cambio, y por qué
- Impulso repetido en carrera: los «pasitos» de Silksong salen de soltar el botón que mantiene la carrera; aquí la
  carrera se mantiene con el joystick. La recarga (0,6 s) ya está cerca de los ~0,5 s medidos.
- Tope de 30 FPS: no se pone. No medido en caliente; se reabre si una medición sostenida baja de ~45 en bajo.

## Para después (cada una con su plan)
Selección de perfil con 4 ranuras; brillo; música y efectos por separado; 120 FPS en gama alta (medir en el S20);
impulso hacia abajo en el aire; qué se equipa solo sentado en el banco.
