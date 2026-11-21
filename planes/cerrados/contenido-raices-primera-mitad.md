CERRADO (21-nov-2026, con el PR de `feature/contenido-raices-primera-mitad`. Escrito el 17-nov-2026; aprobado por la persona el 17-nov-2026; el diseño propuesto lo confirma Mike al leerlo)

# Contenido: la primera mitad de Las Raíces (tarjeta #20)

Construye `raices_2` a `raices_4` en cajas grises, con las primeras peleas, el banco con el guía y dos salas verticales, y
suma el enemigo polilla, la conversación del guía (mapa `raices` y habilidad `pluma_mapa`), un lugar reservado para una
tienda y el par de puertas con `raices_5`. Sus dependencias están fusionadas: #18 (`raices_1`), #19 (la Cucaracha) y #22
(`raices_5` y el hongo escupidor, de Vic). Con esta tarjeta la segunda mitad de la zona (`raices_5` a `raices_8`) pasa a
poderse alcanzar jugando.

## Alcance (el de la tarjeta)
- `raices_2`, `raices_3` y `raices_4` en cajas grises: primeras peleas, banco con el guía y dos salas verticales; el guía va
  antes del banco en la ruta.
- El enemigo polilla.
- Una conversación del guía con dos premios: el mapa `raices` y la habilidad `pluma_mapa`, una sola vez. Sin `pluma_mapa`
  el mapa se queda vacío. Su línea se fija en un comentario de la tarjeta antes de cerrarla.
- En `raices_3`, un lugar reservado para una tienda, cerca del banco y aparte del guía, con sus áreas sin tocarse. Vende la
  brújula en 30 PejeCoins (se ajusta jugando) y sin arte se dibuja como un rectángulo. La tienda no bloquea el PR.
- Quitar el hueco temporal del piso de `raices_1` (lo puso #18). Esta versión no tiene vuelta a La Celda: se quedan
  `raices_1.arriba` y la llegada del hueco de `celda_4`.
- El par de puertas `raices_4`↔`raices_5`, juntas en un solo cambio, quitando la pared que `raices_5` tiene en su lugar.

## Aceptación (la de la tarjeta)
- Cada sala tiene un guion de ruta que cruza cada puerta.
- Descansar en el banco guarda en esa sala y restaura la vida.
- El guía da el mapa y `pluma_mapa` una sola vez.
- `validar.ps1` pasa sin avisos nuevos.
- Los FPS en el teléfono de gama baja van en #29: no son criterio de este PR.

## Lo que ya existe (leído del repo, 17-nov-2026)
- `contenido/salas/raices/` tiene `raices_1`, `raices_5`, `raices_6`, `raices_7` y `raices_8`. Faltan `raices_2` a `raices_4`.
- `raices_5` (3600×720) hereda `contenido/zonas/raices/sala_raices.tscn`; su `Entrada` está en (134, 560) y tiene una
  `ParedIzquierda` (nodo bajo `Terreno`, en x=40) que este PR quita para poner `PuertaIzquierda`. Su puerta derecha es el
  modelo: `nucleo/puerta.tscn` con `id`, `sala_destino`, `puerta_destino` y `llegada`, y una `ParedTrasPuerta…` detrás.
- Piezas listas: `nucleo/piezas/foso.tscn`, `nucleo/piezas/plataforma_delgada.tscn`, `nucleo/monedas_sueltas.tscn`.
- Enemigos: la Cucaracha (`contenido/enemigos/cucaracha/`) y el hongo (`contenido/enemigos/hongo_escupidor/`). La polilla no
  existe.
- `mapa/indice_salas.tres` se genera con `herramientas/generar_mapa.gd`; la posición de cada sala sale de su
  `posicion_mapa` y el validador no deja que se encimen. No se editan a mano.

## Cómo se arma (recetas ya escritas, sin repetirlas aquí)
- Sala: `docs/guias/armar-una-sala.md`, heredando `sala_raices.tscn`. Modelos reales: `raices_1.tscn` y `raices_5.tscn`.
- Enemigo: `docs/guias/agregar-un-enemigo.md`, carpeta `contenido/enemigos/polilla/`; modelo: la Cucaracha.
- Guía: `docs/guias/npc-y-dialogo.md` (NPC en `contenido/npc/<id>/`, una `FichaDialogo` con `Recompensa`; modelo: el Eterno).
- Tienda: `docs/guias/tienda.md` (`Area2D` con `nucleo/tienda.gd` y un `ArticuloTienda`).

## Propuesta de diseño (SIN CONFIRMAR con Mike: se ajusta si él dice otra cosa)
La tarjeta no fija estas cuatro cosas; se propone lo mínimo para poder armar y se corrige al leer este plan.
1. Salas: `raices_2` horizontal con las primeras peleas; `raices_3` y `raices_4` verticales. El banco, el guía y el lugar de
   la tienda van en `raices_3`, con el guía antes del banco.
2. Primeras peleas: la Cucaracha y la polilla, pocas y separadas, sin hongo (el hongo ya aparece en `raices_5`).
3. Polilla: un enemigo volador que detecta al jugador y lo persigue por el aire, hecho desde la idea de
   `herramientas/salas/comportamientos/volador.gd` (copiar el texto, nunca su `.uid`; nada de `contenido/` referencia
   `herramientas/`). Vida, daño, velocidad y si reaparece se miden y se ajustan en su sala de prueba; no se fijan aquí.
4. Guía: `id` y nombre provisionales; la línea definitiva se publica en un comentario de la tarjeta antes de cerrarla.

## Bloques (cada uno termina con validar y su guion; un bloque a la vez)
| # | Qué | Comprobación |
|---|---|---|
| R1 | `raices_2`: primeras peleas y puertas; `raices_1` pierde el hueco del piso y gana su puerta hacia `raices_2` (se quedan `arriba` y la llegada de `celda_4`); `raices_1_puertas` se reescribe porque cruzaba el hueco quitado | guion de ruta de `raices_2` y `raices_1_puertas` reescrito |
| R2 | Polilla: ficha, comportamiento y datos en `contenido/enemigos/polilla/`, y su sala de prueba en `herramientas/salas/enemigos/` | guion que la vence (`enemigo_vencido`); fila manual en `docs/pruebas.md` |
| R3 | `raices_3`: sala vertical con banco, guía y lugar de la tienda sin tocarse | guion de ruta; descansar guarda y cura |
| R4 | Guía: conversación con el mapa `raices` y `pluma_mapa`, una sola vez | guion de la conversación y de la recompensa única |
| R5 | Tienda reservada: rectángulo con la brújula a 30 PejeCoins | guion de compra (modelo: `herramientas/guiones/nucleo/tienda.guion`) |
| R6 | `raices_4`: segunda sala vertical, con su llegada desde `raices_3` | guion de ruta de `raices_4` |
| R7 | Par `raices_4`↔`raices_5`: puerta nueva en cada una y se quita la `ParedIzquierda` de `raices_5` | guion de ruta que cruza el par |
| R8 | Cierre: `mapa/indice_salas.tres` regenerado, entradas en `contenido/funciones.json` (`"pasa": false` hasta tener evidencia), filas de `docs/pruebas.md` y `docs/salas-de-prueba.md`, la fila de Claude (chat) en `docs/uso-de-ia.md`, `generar-tablas.ps1`, `revisar-enlaces.ps1`, suite completa y este plan en `planes/cerrados/` | `validar.ps1` sin avisos nuevos; `correr-guiones.ps1` con `MALOS=0` |

## Por verificar leyendo el código (no se supone)
- Cómo entrega una `Recompensa` el mapa `raices` y la habilidad `pluma_mapa`, y cómo se ve el mapa vacío sin ella
  (`docs/componentes.md` y `nucleo/`), antes de R4.
- La puerta de `raices_1` hacia `raices_2`: lado, tipo y llegada; `raices_1` hoy solo tiene `arriba` y el hueco `abajo`.
- La `posicion_mapa` de `raices_2` a `raices_4` para que `raices_4` quede junto a `raices_5` sin encimar nada: el espacio se
  mide con `generar_mapa`, no a ojo.

## Decisiones tomadas al construir (20-nov-2026)
Se tomaron sin esperar respuesta y se avisan en un comentario de la tarjeta; si Mike dice otra cosa, se ajusta.
- `raices_3`: la subida a la puerta derecha usa 3 bloques sólidos (alturas 173, 346 y 520 sobre el piso), no plataformas delgadas, porque
  `docs/sala.md` prohíbe una plataforma de una vía como única salida. `raices_3_ruta` se remidió con prueba negativa.
  Mide 2400×1240 (puerta derecha en (2330, 560)) para quedar pegada a `raices_4` en el mapa, sin hueco.
- Guía: una sola línea, la fijada en el comentario de la tarjeta, con las dos recompensas (mapa `raices` y `pluma_mapa`), una sola vez.
- `raices_4`: 3000×1240, `posicion_mapa` (8400, -520) y puerta derecha en (2930, 560); sigue terminando en x 11400, junto a `raices_5`.
  La subida es de 2 bloques y el saliente (3 saltos de unos 173 px).
- Primeras peleas de `raices_4`: `CucarachaA` en x 600 (piso 1080), `PolillaA` en x 1300 y `PolillaB` en x 2000 (vuelan a y 800). Son
  valores de partida: se ajustan jugando.

## Riesgos
- Quitar el hueco de `raices_1` rompe `raices_1_puertas` y deja a `raices_1` sin salida hasta que exista la puerta de R1.
- Vic pondrá las polillas en `raices_6` y `raices_8` después de que este PR se fusione: la ficha de la polilla debe
  quedar lista para instanciarse en otra sala sin tocar la ficha.
- Choca con #26 y #25 de Vic en `mapa/indice_salas.tres` y en las tablas de docs: el segundo PR en fusionarse rebasea y
  regenera.
