CERRADO

# Núcleo: auditoría de lo construido frente a Hollow Knight y Silksong

Pedida por la persona el 07-oct-2026, que autorizó decidir esa noche con un porqué. Documento vivo: tras cada fila
se anota el avance. De las notas de referencia del código de los dos juegos (privadas, no se enlazan) se toman
mecanismos, nunca números: los de Hollow Knight (HK) y Silksong (SS) son unidades de Unity y casi todos viven en los
recursos del juego, no en su código. Lo nuestro se verificó leyendo el código el 07-oct-2026.

Principio de la persona: tomar casi igual lo que hace HK cuando se conoce el mecanismo; no se aplica a lo que probó
y aprobó en el S20, salvo que el código de HK contradiga la lógica (no un valor) y el cambio sea barato de deshacer.

Evidencia: **hecho** (está en el código del juego), **inferencia**, **recursos** (el valor o la lógica está en los
recursos del juego, no en su código).

## Nivel 1: aplicado el 07-oct-2026

| # | Qué hace HK | Qué hacemos | Evidencia | Quién decidió lo nuestro | Costo | Recomendación | Advisor | Decisión |
|---|---|---|---|---|---|---|---|---|
| 1 | La cámara persigue un punto; recorta su destino a los límites **antes** de suavizar (`SmoothDamp`, segundo orden, por eje) y después un recorte duro de seguridad | Antes: `Camera2D` con `position_smoothing` (primer orden) y `limit_*` recortando después; 280 px bajo el suelo. Ahora: `nucleo/jugador.gd` `_seguir_con_camara`: recorta antes, X con el mismo cálculo que `Camera2D`, Y amortiguado crítico (`tiempo_camara_y` 0,15 s); 40 px bajo el suelo | hecho | El margen de 280: Claude, por medición (07-oct). En el S20 la persona: quita el «imán» pero se ve demasiado suelo | ~80 líneas en `jugador.gd`, un guion nuevo; se deshace volviendo a `position_smoothing` y 280 px | Adoptar el mecanismo | Recortar antes con `lerp` es lo que `limit_smoothed` ya hacía (unos 140 px/s por tick, medido antes; el `revisor` emuló 136; falla); hace falta segundo orden y T ≥ 0,15 s | Aplicado (Claude). Medido con 40 px: T 0,08 → 175; 0,10 → 141; 0,12 → 116; **0,15 → 90**; 0,20 → 63 (umbral 100). Falta el S20 |
| 2 | Si la vista es mayor que la escena: no aplica (sus límites son media vista desde cada borde) | La sala más baja o más angosta que la vista: `Camera2D` ya la centraba con sus límites (medido el 07-oct-2026: centro en y=380 en `sala_movimiento` con vista de 1280×1280; en el S20, franjas iguales a los dos lados de `sala_pared`); el seguimiento a mano centra su objetivo igual | hecho en Godot (medido) | Comportamiento de Godot; Claude lo conservó | Incluido en 1 | Mantener; el gris que sobra lo resuelve el plan de pantalla completa | El advisor sugería abrir los límites en ese eje; la medición mostró que no hace falta y se quitó | Aplicado, `camara_centrada.guion` |
| 3 | Temblor al aterrizar duro: lo dispara el **tiempo** cayendo (SS: tiempo a velocidad máxima); amplitud y duración en recursos. SS: temblor reducido al 20 % | Disparo por velocidad (≥ 1000 px/s, `_temblar_al_aterrizar`); 8 px y 12 ticks; interruptor en la pausa | hecho / recursos | Claude propuso, la persona aprobó (plan del temblor, 07-oct); en el S20: «casi no se ve» | Valores: 2 líneas | Disparo: mantener. Valores: subir, provisionales y sin fuente | Mantener la velocidad: con gravedad fija equivale al tiempo, y el tiempo pide reinicios en pared e impulso y regla aparte para la picada; la queja es de visibilidad | Aplicado: 20 px y 24 ticks (0,4 s). Después, en el S20 temblaba en caídas cortas y la persona pidió el disparo por tiempo de Hollow Knight: aplicado el 07-oct-2026 con 18 ticks y temblor horizontal (`planes/cerrados/nucleo-aterrizaje-duro.md`). El 20 % de SS: lo cubre el interruptor; un tercer estado «reducido», a decidir |

## Nivel 2: un valor, el inicial se queda

| # | Qué hace HK | Qué hacemos | Evidencia | Quién decidió lo nuestro | Costo | Recomendación | Advisor | Decisión |
|---|---|---|---|---|---|---|---|---|
| 4 | Un solo tope de caída (HK y SS); SS reduce la gravedad en la cima del salto, no en la caída | Dos tramos: 700 px/s los primeros 240 px y luego 1200 (`_caer`) | hecho | La persona lo pidió («al principio caes más lento», plan cerrado de ajustes) y lo aprobó en el S20 el 06-oct | 0 líneas: con `distancia_caida_inicial = 0` la condición de `_caer` nunca vale y el tope es único desde el primer tick (leído en el código) | Probar en el S20 un APK con `distancia_caida_inicial = 0` frente al actual | Confirmar leyendo `_caer`; si basta el valor, cero código | Sin cambio de código. El valor queda en 240 hasta que la persona compare los dos APK |

## Nivel 3: decidido sin programar

| # | Qué hace HK | Qué hacemos | Evidencia | Quién decidió lo nuestro | Costo | Recomendación | Advisor | Decisión |
|---|---|---|---|---|---|---|---|---|
| 5 | Pinchos: devuelven al punto de peligro, que fijan zonas colocadas a mano y la puerta de entrada; nunca el último suelo firme. SS: si toca un peligro antes de 0,5 s de reaparecer, va a la puerta sin perder vida | Último suelo firme automático (`_recordar_punto_seguro`, `_volver_al_punto_seguro`) | hecho | La persona: «última posición segura en suelo firme» (plan cerrado de partida y habilidades); pasa en el S20 el 06-oct | Mantener: 0. Punto medio (anti-bucle): ~10 líneas y un guion. Adoptar HK: un nodo marcador, colocarlo en cada sala y su guion | **Punto medio**: automático + anti-bucle de SS; marcador opcional por sala solo cuando una sala real lo pida | Mantener: deja el fallo conocido del automático, el bucle. Punto medio: lógica, barato de deshacer, cierra ese fallo. Adoptar: pide colocar contenido que aún no existe y va contra «tres casos» | La persona eligió el punto medio el 07-oct-2026: último suelo firme automático + anti-bucle de SS (si toca un peligro antes de 0,5 s de reaparecer, va a la puerta de entrada sin perder vida). Marcador por sala solo cuando una sala real lo pida. Sin programar |
| 6 | Enemigos: los semipersistentes vuelven al **morir** el jugador (hecho); al descansar, en recursos; los persistentes (jefes) nunca | Los fuertes vuelven solo al descansar (`Partida._al_descansar`); al morir, no | hecho | Decisión abierta en `ESTADO.md`, que dice «sin fuente de HK»: ya hay fuente | Una conexión a `jugador_muerto` en `Partida` y un guion | Que morir los reponga igual que descansar | Igual: reponer al morir | La persona, 07-oct-2026: morir repone a los fuertes, igual que descansar. Sin programar |
| 7 | Vibración por evento: aterrizaje suave, dash, salto en pared, doble salto, daño (formas en recursos) | Vibran pegar, recibir daño, curar y descansar (`nucleo/vibracion.gd`) | hecho / recursos | Nota del 06-oct: no vibrar al saltar ni aterrizar (teléfono, no control) | Una señal nueva en el bus (`jugador_aterrizo`) y una línea en `vibracion.gd` | Esperar al S20 con el temblor nuevo; si se agrega, solo en el aterrizaje duro, junto al temblor | Igual | La persona, 07-oct-2026: queda como está (vibra en el aterrizaje duro, probado en el S20) |
| 8 | Ninguno pausa al perder el foco | Se pausa al perder el foco o al ir al fondo (`nucleo/pausa.gd`) | hecho | Claude por plataforma; pasa en el S20 (Apps recientes) | 0 | Mantener: en un teléfono la app se interrumpe | Mantener: diferencia de plataforma | La persona, 07-oct-2026: se mantiene, también en PC |

## Registro sin cambios (lo que la persona aprobó en el S20)

| # | Qué hace HK | Qué hacemos | Evidencia | Recomendación | Advisor |
|---|---|---|---|---|---|
| 9 | Salto: sube a velocidad fija `JUMP_STEPS` pasos; al soltar, velocidad a 0 (SS: a la mitad) | Impulso con gravedad; al soltar, × `corte_salto` (0,4) tras `ticks_minimos_salto` | hecho | Mantener: el corte es un valor y la subida fija cambia la sensación aprobada | Mantener: la subida a velocidad fija cambia una sensación aprobada |
| 10 | Coyote 2 pasos (SS 4); cola 2 pasos **solo con el botón mantenido** | Coyote 3; cola 3 ticks desde la pulsación, sin pedir que se mantenga (`_saltos`) | hecho | La cola sin botón mantenido es una diferencia de lógica, barata (una condición): a decidir por la persona, sin tocarla esta noche | Lógica, barata y evita saltos no queridos tras soltar: cumple el principio de la persona; decide ella, esta noche no |
| 11 | Pared: soltar el bloqueo del despegue al presionar hacia la pared; repone dash y doble salto | Igual (`ticks_despegue_pared`, repone impulso y doble salto) | hecho | Mantener | Mantener |
| 12 | Pogo: abajo + atacar en el aire; repone dash y doble salto | Igual (`rebotes_pogo`, repone impulso y doble salto) | hecho | Mantener | Mantener |
| 13 | Dash: uno por estancia en el aire; lo reponen suelo, pared y pogo | Igual con el impulso | hecho | Mantener | Mantener |
| 14 | Al recibir daño: congela y **después** retroceso | Igual: `ticks_hit_stop` al recibir daño y luego retroceso (`recibir_dano`) | hecho | Mantener. El congelado de HK al matar o al pegar a algo que bloquea es una **adición** posible, cuando haya muertes de enemigos con efecto | Mantener; el congelado al matar, como adición |
| 15 | Pinchos quitan vida aunque el héroe sea invulnerable | Invulnerable no pierde vida, pero igual vuelve al punto seguro (`docs/contrato.md`, «Jugador») | hecho | Diferencia de lógica, barata: a decidir por la persona junto con la fila 5 | Adoptar junto con la fila 5: es lógica y evita cruzar pinchos a costa de la invulnerabilidad; barato |
| 16 | Curar cuesta 33 de 99; cada golpe da 11 | Igual: `costo_curacion` 33, `inspiracion_por_golpe` 11 | hecho | Mantener | Mantener |
| 17 | Espera al morir: 2,85 s (SS 4 s) | 1,5 s (`nucleo/sala.gd`) | hecho | Valor: sin cambio; anotar si en el S20 se siente corta | Mantener; anotar si en el S20 se siente corta |

## Avance

- [x] Cámara (filas 1 y 2): aplicada, guiones `camara_caida` y `camara_centrada`; pasa en el S20 (07-oct-2026, caso «Caída»).
- [x] Temblor (fila 3): aplicado; pasa en el S20 (07-oct-2026, caso «Temblor al aterrizar»).
- [x] Caída (fila 4): sin código; comparada en el S20 (07-oct-2026, caso «Caída»: «el punto perfecto»).
- [x] Pinchos, enemigos, vibración y pausa (filas 5 a 8): decididas por la persona el 07-oct-2026. Por programar:
  el anti-bucle de la fila 5 y reponer a los fuertes al morir (fila 6). Observación del `revisor` (07-oct-2026)
  para el anti-bucle: si un punto seguro quedara más de `margen_fuera_de_sala` bajo los límites, salir por abajo
  congelaría al jugador sin fin (invulnerable → punto seguro → congelado otra vez); ninguna sala de hoy lo permite.
- [x] Registro (filas 9 a 17).
- [x] Fila 10: se queda lo nuestro; fila 15: como Hollow Knight (persona, 11-oct-2026).

Cerrado el 11-oct-2026: lo decidido y sin programar (filas 5, 6 y 15 y plataformas sólidas) pasa a
`planes/activos/nucleo-reglas-pendientes.md`.
