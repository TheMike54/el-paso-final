CERRADO

# Núcleo: aterrizaje duro, temblor por tiempo, vibración, suelo y poda de pruebas

Pedido por la persona el 07-oct-2026 tras probar el APK de la mañana. Toca el movimiento del jugador y el bus de
eventos: pasa por el `revisor`. Valores sin fuente salvo que se diga; el mecanismo es el de Hollow Knight. Base: 69
de 69 guiones y `validar` con 73 archivos y 0 fallos, con los cambios sin commit de la noche anterior.

| # | Cambio | Mejora esperada | Cómo se mide | Éxito | Riesgo | Resultado medido | Decisión |
|---|---|---|---|---|---|---|---|
| 2.1 | Disparo por tiempo a velocidad máxima | Caídas cortas no tiemblan | Guiones con caída corta, cornisa, picada baja y salto | ~300 px no; 860 px sí; picada sí; salto no | Umbral mal calculado | 18 ticks al tope = 794 px (simulado; 650 con `distancia_caida_inicial` 0). Cornisa (860 px): 21 ticks al tope, tiembla. Caída de ~400 px en `sala_movimiento` (llega a ~1100 px/s): no tiembla. Picada desde ~100 px: tiembla. Salto: no | Aplicado: `ticks_caida_dura` 18; sale `velocidad_temblor` |
| 2.2 | Temblor 18 ticks y horizontal | Se nota sin marear | `temblor_x` y `temblor_y` en guiones; offset x sin recorte | Patrón fijo, no circular | Mareo | Y cada 2 ticks, X (1/3) cada 3: (6,67, 20), (6,3, 18,89), (5,93, −17,78), (−5,56, −16,67)… El límite no recorta el offset en X (centro recortado 800 → 806,67 con 6,67) | Aplicado: 18 ticks, `temblor_x` y `temblor_fraccion_x` |
| 2.3 | Aterrizaje duro | Peso en las caídas altas | Guion: sin control 21 ticks, gravedad y golpes siguen | Guiones de movimiento intactos | Atrapar en un peligro | Cornisa: sin control del cuadro 122 al 142 aunque mantenga caminar; lo mantenido vuelve en el 143; un salto tocado en el 140 se pierde (sin descartarlo saltaría: y=1084). Lo cortan golpe, peligro (también invulnerable), sentarse y morir; el banco no sienta durante el bloqueo. La picada no bloquea. Los 69 guiones de antes, sin cambios. El `revisor` encontró que un golpe, un banco o una picada del mismo tick del aterrizaje lo rompían (el golpe y el banco se procesan antes que el jugador): ahora el bloqueo no empieza si ya hay retroceso o está sentado, y la picada tiembla en `_seguir_picada` (romper un frágil no tiembla; una picada a 16 px del suelo, sí) | Aplicado: `ticks_aterrizaje_duro` 21, `aterrizando` pública |
| 2.4 | Vibración al aterrizar | Se siente el golpe | `bus_eventos` y `vibracion` | 13 señales; apagada no vibra | Molesta | `jugador_aterrizo` una vez por aterrizaje duro y en la picada (antes de la onda: gana a la vibración del golpe); 80 ms, 0,9. No se emite si el jugador está muerto | Aplicado |
| 2.5 | Suelo de 120 px | Más suelo visible (~16 %) | Medidor: tirón y atraso | Tirón ≤ 100; atraso no empeora | Salto distinto si la cámara se mueve | Ver tabla abajo: el margen casi no cambia el tirón; con 120 px el menor `tiempo_camara_y` que pasa sigue siendo 0,15 (93,1). Atraso máximo al caer: 262 → 209 px. En un salto sobre el piso de `sala_caida` la cámara se mueve 38 px (antes 0). Suelo visible 5,6 % → 16,7 % | Aplicado a `sala_caida`, `sala_pared` y `sala_picada` (1280, 1520, 1280 de alto); las de 720 no crecen; `tiempo_camara_y` se queda en 0,15 |
| 2.6 | Poda de pruebas | 6 guiones menos | Mutaciones por causa; corrida completa | Mismos resultados, 6 guiones menos que antes de la poda | Perder una causa | En una copia, cada fusionado pasa y falla por cada causa de los que absorbió (8 mutaciones; la de `interfaz/curacion` es «la interfaz solo oye el daño»: quitar la conexión entera no falla ni en el original). 75 guiones antes, 69 después de quitar los 6, todos OK; con `camara_temblor_picada_ras`, 70 | Aplicado; plan de poda cerrado en `planes/cerrados/` |

Reglas del bloqueo: golpes y gravedad siguen; las pulsaciones de saltar, atacar y curar hechas durante él se pierden;
lo mantenido (caminar) cuenta al terminar; pausa y cambio de sala no lo tocan (el árbol se detiene; la sala nueva crea
un jugador nuevo); los controles táctiles no cambian (el bloqueo no toca `Input`). Un peligro siempre lo corta: todo
peligro pasa por `recibir_dano(peligro)`, que vuelve al punto seguro.

Tirón en `sala_caida` (px/s por tick, umbral 100), por `tiempo_camara_y` y margen bajo el suelo:

| T (s) | 40 px | 80 px | 120 px |
|---|---|---|---|
| 0,08 | 175,3 | 176,2 | 176,7 |
| 0,10 | 141,3 | 142,6 | 143,4 |
| 0,12 | 115,6 | 117,1 | 118,2 |
| 0,15 | 89,8 | 91,7 | 93,1 |
