ACTIVO

# Trazo blanco del ataque

Pedido por la persona el 25-oct-2026: el arco blanco que deja el golpe, como en el mockup de La Celda, que vaya acorde
al área de golpe y que lo puedan usar también los ataques enemigos con parry. Va en el mismo PR que `contenido-celda`
(v2), `nucleo-ajustes-avanzados` y `nucleo-video-hardware`. Aprobado por la persona el 25-oct-2026; lo ejecuta una tanda autónoma autorizada por
ella.

## Referencias

- **Mockup:** una media luna blanca dibujada una vez (disco de radio 112 en 256 px con un halo de `shadowBlur 14`, menos
  otro disco de radio 112 corrido 36 px), mezcla normal, 190 px de lado. Aparece 70 ms después de empezar el golpe,
  dura 140 ms, crece de 0,9 a 1,05 y se desvanece con 0,95·(1-p²). Al lado, arriba (girada −90°) y abajo (+90°);
  espejada al mirar a la izquierda.
- **Hollow Knight** (ingeniería inversa): el `SlashEffect` del caballero es un clip de 6 cuadros a 40 fps (~0,15 s, los
  dos primeros vacíos como retraso), blanco, encima del cuerpo, un poco más grande que su área de golpe (~3,97×2,78 u
  contra ~3,3×2,65 u). Al desviar un ataque enemigo sale otro efecto («Nail Clash», 4 cuadros a 20 fps).
- **Godot:** un `Sprite2D` con una textura fija, escala y `modulate` por tick es lo más barato en relleno
  (`tutorials/performance/gpu_optimization.rst:250-263`, translúcido lo más chico posible); `Line2D` haría una estela
  que sigue la punta, que no es lo del mockup; las estelas de partículas no existen en Compatibility
  (`tutorials/rendering/renderers.rst:368`).
- **Medido** en la demo (25-oct, S50): un trazo cada 0,3 s no cuesta FPS (dentro del ruido).

## Decidido por la persona (25-oct-2026)

- El tamaño del mockup se queda: llega al mismo alcance que el área de golpe (~140 px desde los pies), y es más alto
  (166 contra 100 px), como en Hollow Knight el dibujo es algo más grande que el área.

## Diseño

- `nucleo/trazo_ataque.gd` (`class_name TrazoAtaque`, `Sprite2D`): `mostrar(direccion, mirando)` lo coloca, gira y
  espeja, y lo anima por ticks de física (no por tiempo de pantalla), así sigue al ataque, se congela en la pausa y
  en el congelado común. Sin luz (`LIGHT_MODE_UNSHADED`) para que la oscuridad de la sala no lo apague. `modulate`
  para teñirlo (mejoras, amuletos).
- La posición sale del área de golpe del que ataca (`Ataque/Forma` del jugador, con `posicion_ataque_arriba` y
  `posicion_pogo`), no de números sueltos: si el área se mueve, el trazo la sigue.
- El jugador lo dispara en el mismo tick en que se enciende el área; se ve desde `TICKS_RETRASO` (4 ticks, ~70 ms
  como el mockup; Hollow Knight deja ~50 ms vacíos) y dura `TICKS_DURA` (8, ~140 ms). Todo `AtaqueEnemigo` con
  `se_puede_parar` crea el suyo al empezar, para que el jugador reconozca qué se puede desviar; un
  `ProyectilEnemigo` no (`con_trazo` en falso): el trazo es de un golpe, y pegado a algo que vuela lo seguiría por la sala.
- La textura (`nucleo/arte/trazo_ataque.png`, 256×256, blanca con alfa) la genera una vez `herramientas/generar_trazo.gd`
  con la misma cuenta del mockup, para que se pueda rehacer. Generarla en el juego serían 65 536 píxeles en GDScript
  (un tirón al primer golpe en el S50). No viaja en el paquete de publicación.
- Sin luz, medido en la PC: bajo un `CanvasModulate` a 0,3, un sprite normal queda en 0,298 y uno con
  `LIGHT_MODE_UNSHADED` en 1,0. Por eso tampoco sigue al ajuste de brillo, igual que el estallido del parry.

## Hecho (tanda del 25-oct-2026)

| Paso | Resultado |
|---|---|
| T1 | `TrazoAtaque` y su textura; prueba `nucleo/trazo_ataque` (11 casos: colocación por dirección y lado, ticks, congelado, enemigo parable o no, proyectil sin trazo) |
| T2 | En el jugador, desde el área de golpe ya colocada (`DESDE_AREA`, −30 y −5 px: lo que el mockup separaba el dibujo del centro del área); guion `nucleo/trazo_jugador` (se ve en el cuadro 16 en x=60 y se apaga solo) |
| T3 | En `AtaqueEnemigo` con `se_puede_parar`; cubierto por la prueba de T1 |

## Pasos

| Paso | Qué | Se comprueba con |
|---|---|---|
| T1 | Textura y `TrazoAtaque` | Prueba de la colocación por dirección y espejo (función pura) |
| T2 | En el jugador (lado, arriba, pogo, ataque en carrera) | Guion de ataque; captura a 1280×720 |
| T3 | En `AtaqueEnemigo` con parry | Guion de parry |

## Lo que solo la persona puede confirmar

- Cómo se ve y se siente al pegar en el S50, de lado, arriba y abajo.
