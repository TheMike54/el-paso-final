ACTIVO

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

## Falta
- Prueba con el dedo de la persona: sensación del parry, de la voltereta y del rebote (filas de `docs/pruebas.md`).
- Entradas de `funciones.json` para lo nuevo: las aprueba la persona.

## Sin cambio, y por qué
- Impulso repetido en carrera: los «pasitos» de Silksong salen de soltar el botón que mantiene la carrera; aquí la
  carrera se mantiene con el joystick. La recarga (0,6 s) ya está cerca de los ~0,5 s medidos.
- Tope de 30 FPS: no se pone. No medido en caliente; se reabre si una medición sostenida baja de ~45 en bajo.

## Para después (cada una con su plan)
Selección de perfil con 4 ranuras; brillo; música y efectos por separado; 120 FPS en gama alta (medir en el S20);
impulso hacia abajo en el aire; qué se equipa solo sentado en el banco.
