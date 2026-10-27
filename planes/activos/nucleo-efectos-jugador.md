ACTIVO (aprobado por la persona el 25-oct-2026)

# Efectos del jugador: parry, bola de fuego y curar

Elegidos por la persona el 25-oct-2026 tras tres rondas de maquetas en la copia de pruebas: parry A2 (destello chico
en la punta de la espada), la bola de fuego en capas (como una referencia de bola de fuego dibujada, en blanco y
azul) y curar G (el aura del HTML de diseño, sin cambios). Hoy el parry y la chispa del disparo desviado se dibujan
con rayas en `Jugador._draw`, la bola es un rectángulo gris (`Proyectil.COLOR`) y curar solo tiñe al jugador.

## Por qué hojas de cuadros y no dibujo en vivo
Dibujadas en vivo con figuras (círculos, triángulos, óvalos), las partes se veían sueltas y de orilla dura. Calculadas
una vez pixel por pixel, con difuminado y en capas encajadas, salen como una sola pieza; en el juego son una imagen
por cuadro (`AnimatedSprite2D`), lo más barato en el S50. Es el mismo camino del trazo del ataque (`generar_trazo`).
Curar también: la persona pidió dibujarlo igual que la bola y aprobó el resultado.

## Pasos
1. `herramientas/generar_efectos.gd` (como `generar_trazo`): genera `nucleo/arte/efecto_parry.png` (4 cuadros de
   352x208, 0,2 s), `nucleo/arte/efecto_bola.png` (6 cuadros de 224x160 en ciclo, a 20 cuadros/s; segunda fila sin
   las gotas sueltas, para la salida) y las dos de curar (paso 4). El preset «Publicacion» lo excluye como a `generar_trazo` (`export_presets.cfg`
   y la lista de «Decisiones cerradas» del `CLAUDE.md` raíz; texto aprobado el 25-oct).
2. Parry: el destello es una escena chica que se reproduce una vez y se libera, con mezcla aditiva y sin sombreado
   (el velo de la sala, un `CanvasModulate`, no la apaga: como `TrazoAtaque` y `LuzSala`). Va en la punta de la
   espada del golpe (lado, arriba, abajo), medida en los cuadros del atlas y guardada como constantes; la chispa del
   disparo desviado usa la misma escena a la mitad de tamaño. Se quitan `_dibujar_estallido` y sus constantes.
   El cuerpo en blanco baja de 8 ticks a 6 (en la maqueta no tapa al personaje): aprobado el 25-oct.
3. Bola: `proyectil.tscn` lleva un `AnimatedSprite2D` con la hoja, mezcla normal con su opacidad por capa (80 % el
   centro, 65 % y 50 % las de fuera), sin sombreado y volteado con `sentido`. Los primeros 3 cuadros, sin gotas
   (en la maqueta asomaban sobre la cabeza). Se quita el rectángulo gris. La forma de golpe (60x40) no cambia.
4. Curar (cambiado el 25-oct tras una cuarta maqueta, también aprobada): también hojas de cuadros. `efecto_curar.png`
   (6 cuadros de 320x420: la silueta del aura del HTML con picos filosos, 11, 10 y 9 por lado según la capa, y gotas
   y chispas que nacen en el piso), detrás del jugador, opacidad 45/35/25 %; `efecto_curar_frente.png` (solo rayas y
   chispas), delante. Una luz falsa: halo aditivo sin sombreado que crece con `ticks_curados` (como los de `LuzSala`,
   sin `Light2D`). Se quita `TINTE_CURANDO`.
5. Medir en el S50: FPS curando y con la bola en pantalla, contra los de hoy (`docs/pruebas.md`).
6. Documentación: `docs/jugador.md` (cómo se ve cada efecto), `nucleo/CLAUDE.md` si cambia algo de su contrato,
   `docs/pruebas.md` (prueba manual). Entrada nueva `efectos-jugador-telefono` en `nucleo/funciones.json` (texto
   aprobado el 25-oct).
7. `validar.ps1`, todos los guiones y el `revisor` (toca el combate del jugador).
8. Limpieza: nada de lo que reemplazan los efectos se queda en el código (`_dibujar_estallido`, `LARGO_RAYO`,
   `HUECO_RAYO`, `ANCHO_RAYO`, `LARGO_CHISPA`, `HUECO_CHISPA`, `ANCHO_CHISPA`, `Proyectil.COLOR` y su dibujo,
   `TINTE_CURANDO`); Grep de cada nombre sin resultados, también en `docs/`.

## Lo que no cambia
La lógica: el parry, el disparo desviado, la bola y curar golpean, cuestan y duran igual; los guiones que los cubren
(`parry`, `poder_bola`, `jugador_curar*`) deben seguir pasando sin tocar sus `.esperado`.

## Hecho (25-oct-2026, tanda autónoma)

| Paso | Resultado |
|---|---|
| 1 | `herramientas/generar_efectos.gd` genera las 4 hojas en `nucleo/arte/` (35 s; Lossless, sin mipmaps: se ven a su tamaño o a la mitad). Excluido de «Publicacion» en `export_presets.cfg` y en el `CLAUDE.md` raíz |
| 2-4 | Una pieza para los tres: `nucleo/efecto_cuadros.gd` (`EfectoCuadros`, `Sprite2D` con `hframes`, 3 ticks por cuadro, en bucle o una vez). Reusa el material aditivo de `LuzSala` (`material_aditivo()`, ahora público) y el sin luz pasa de `TrazoAtaque` a `EfectoCuadros.material_sin_luz()`: un solo material de cada tipo |
| 2 | Medido en la captura de la PC: el parry llega en el cuadro de preparación (espada atrás) y el congelado lo sostenía así, con el destello lejos de la espada. Arreglo: tras un parry el clip de ataque salta a su cuadro de golpe (`CUADRO_GOLPE`, `AnimacionJugador.es_ataque`), y la espada queda sobre el destello. Cuerpo en blanco: 6 ticks contados también congelado |
| 4 | Con `z_index` −1 el aura quedaba bajo el fondo de la sala; va detrás con `show_behind_parent` y como primer hijo. La luz reusa la textura de `LuzSala` (lineal, sin la parada de 0,4 de la maqueta) |
| 5 | S50: curar 52-55 FPS contra 59-60 quieto, pero un APK sin aura ni halo da lo mismo (53-55): los efectos no cuestan; la caída es de curar en sí. Bola: 57 un segundo. S21: 118-122 curando |
| 6 | `docs/jugador.md` («Dibujo»), `docs/contrato.md` (`EfectoCuadros`, parry, disparo desviado, «Paquete de publicación», el shader), `docs/pruebas.md` (fila «Efectos del jugador» y la del parry). Entrada `efectos-jugador-telefono` en `nucleo/funciones.json` |
| 7 | `validar.ps1` `archivos=288 fallos=0`; `correr-guiones.ps1` `RESUMEN total=165 OK=165 MALOS=0`, sin tocar ningún `.esperado` en este cambio (`parry.guion` y `parry.esperado` difieren de `main` por el disparo desviado, hecho antes en esta rama) |
| 8 | Grep sin restos en código ni docs vivos. Queda el texto de la entrada `parry-visible` de `nucleo/funciones.json` («dibuja un estallido blanco»): Claude no reescribe entradas; propuesta para la persona en el reporte |

Falta la persona: verlos en el teléfono (`efectos-jugador-telefono`).
