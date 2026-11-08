# Recorrido del juego

> Contiene la historia completa del juego, incluido el final.

El juego de principio a fin tal como está el 2-nov-2026, y lo previsto por separado. Lo hecho se leyó en las escenas, en `contenido/funciones.json` y en sus guiones; para esta revisión no se jugó. Los términos están en [glosario.md](glosario.md).

## Hecho: lo que se juega hoy

Hoy la campaña es una sola zona, La Celda, con cinco salas y sin enemigos. No tiene final: la última salida devuelve a una sala anterior.

### Entrada

| Paso | Qué pasa | Dónde |
|---|---|---|
| Arranque | Sin logo del motor: negro mientras carga y después el menú | `nucleo/arranque.gd` |
| Menú | Fondo en video de ESCOM de noche, con Jugar, Configuración y, con el modo desarrollador, Zona de pruebas | `nucleo/menu.tscn` |
| Ranuras | Cuatro. Una con partida continúa en su último banco; una dañada o de otra versión no se abre | `nucleo/ranuras.gd`, `nucleo/menu.gd` |
| Partida nueva | Pide un nombre de hasta 12 caracteres, con letras, números y espacios. La elección de personaje está apagada: solo el hombre tiene arte | `nucleo/nueva_partida.gd` |
| Cinemática | Dura 2 min 9 s. Empieza con el aviso «Presentación TT2» en el celular y termina con el protagonista enmascarado frente al elevador. Solo se salta con el modo desarrollador | `contenido/cinematicas/cinematica_celda.tscn` |

La partida no se escribe en disco hasta su primer guardado: cerrar durante la cinemática deja la ranura vacía.

### Las salas

El orden natural es 1, 2, 3 y 4; la sala 5 es opcional y cuelga de la 2.

| Sala | Qué hay | Qué enseña | Salidas |
|---|---|---|---|
| `celda_1` | Foso de varillas y grieta, que quitan una vida y devuelven al suelo firme; banco `banco_celda_1`, donde suena el tema del menú; aviso de salto largo | Moverse, saltar, guardar | Puerta derecha a la sala 2, con pizarrón «Entrar» |
| `celda_2` | Dos fosos de varillas y cables pelados, que no se cruzan por el piso. La ruta va por escombros, columna rota, lámpara de una vía, plataforma que va y viene y elevador. PejeCoins sueltas | Plataformas y lectura del peligro | Izquierda a la 1, derecha a la 3, hueco del techo a la 5 |
| `celda_5` | Pasillo de arriba: foso de varillas y aspas, que golpean con retroceso y no devuelven a un punto seguro. PejeCoins en repisa y un Azulito junto a la pared izquierda | Premio por explorar | Hueco del piso, cae sobre el elevador de la 2 |
| `celda_3` | El Eterno, pilas y raíces que se cortan, aviso de atacar. Nicho escondido con un Azulito: se sube por caja, estante, lámpara y ducto, y el plafón se rompe desde abajo con la Pluma | Atacar | Izquierda a la 2, boquete derecho a la 4 |
| `celda_4` | Tiro hacia abajo junto a una raíz móvil sólida, cuyo aplastamiento quita una vida y devuelve al último punto seguro; cornisa con PejeCoins | La bajada | Boquete izquierdo a la 3, hueco del piso a raices_1 |
| `raices_1` | Primera sala de Las Raíces: caída libre desde celda_4, PejeCoins sueltas y pizarrón que enseña la curación. Al final, hueco provisional de andamio en el piso que regresa a celda_3 | Enseña a curar | Hueco del techo desde celda_4, hueco del piso a celda_3 |

### El Eterno y la Pluma

En `celda_3`, la primera conversación son cinco líneas y entrega la habilidad `pluma`. Se ve la entrega, corre una cinemática de 10 s y se vuelve a la Entrada de la sala, junto a él. Después repite una línea: «Sigue subiendo». Antes de la Pluma, el botón de atacar no se dibuja.

Hablar con él no parece obligatorio: en la escena no hay nada que cierre el paso hacia `celda_4`. Sin comprobar jugando.

### Dónde termina hoy

El hueco del piso de `celda_4` baja a `raices_1`. La campaña termina provisionalmente en el hueco del piso de `raices_1`, que lleva de vuelta a `celda_3` por su boquete derecho mediante un andamio. Lo cubren los guiones `herramientas/guiones/contenido/celda_4_tiro.guion` y `herramientas/guiones/contenido/raices_1_puertas.guion`.

### Reglas que se viven en este tramo

- Empiezas con 4 vidas. Un peligro quita una y devuelve al último suelo firme; un golpe normal empuja y da invulnerabilidad.
- Al morir reapareces en el banco. Tus PejeCoins quedan en una mochila en el último punto seguro. Interactúas con ella y recuperas las monedas enseguida, porque el juego todavía no tiene preguntas para ella.
- El banco guarda; también autoguardan determinados progresos, la muerte y el paso a segundo plano. Recoger PejeCoins no autoguarda.
- La Celda no tiene música, a propósito, salvo el tramo del banco.
- El botón de curar está oculto en toda la zona (`botones_ocultos` de `contenido/zonas/celda/sala_celda.tscn`).

### Lo que existe en código y no aparece en la campaña

Viven en el núcleo y se prueban en la zona de pruebas, pero ninguna sala de `contenido/` los usa hoy:

- Enemigos: la carpeta `contenido/enemigos/` no existe. Sin enemigos no se gana Inspiración, porque cortar pilas y raíces no da.
- Curación, bola, impulso, doble salto, salto en pared y caída en picada: no se obtienen.
- Amuletos y útiles: el catálogo trae solo Patas de Cucaracha y la Brújula, y ninguna sala los entrega.
- Mapa: sin el objeto de mapa y sin `pluma_mapa`, no se dibuja nada.
- Tienda, estaciones, retos de preguntas y jefes. Las PejeCoins se juntan, pero hoy no hay en qué gastarlas.

## Previsto: el resto del camino

Nada de esta parte está construido.

| Tramo | Qué se espera |
|---|---|
| Las Raíces | La Celda baja a esta zona, el punto más bajo del mundo. Plan de ocho salas, tres enemigos, raíces con espinas, pizarrón de curar antes del primer enemigo, sin jefe. Dos amuletos: Patas de Cucaracha en `raices_4` y Caparazón de Cucaracha, oculto en `raices_6` junto a un coleccionable. Tienda en `raices_3`, que vende la brújula. El impulso se obtiene con un objeto cerca del final, y un hueco obliga a usarlo |
| Salir de Las Raíces | La primera versión cierra con una pantalla propia: «Continuará» y, en chico, «Fin de la primera versión» |
| Zonas 2 a 5 | Los Drenajes, El Barrio Otaku, La Ciudad Perdida y El Metro: cada una da una habilidad al vencer a su jefe |
| El Estacionamiento | Sin enemigos: suena el teléfono, tus compañeros te esperan |
| ESCOM y el salón | Recorrido sin enemigos y pelea final contra los tres sinodales, primero uno por uno y luego juntos |
| Final | «TT APROBADO» en el pizarrón, firmas el acta con la Pluma, la máscara se rompe. Un solo final |

El detalle de cada zona está en `diseno.md`.

## Pendiente en este recorrido

| Tema | Estado |
|---|---|
| Preguntas de la mochila: falta `contenido/preguntas_mochila.tres` | Tarjeta #28 |
| La Celda con arte en el teléfono de gama baja y en el de pantalla alta | Falta la prueba manual `sala-celda-1-telefono` |

## Diferencias entre lo diseñado y lo construido

| Tema | Diseño original | Hoy |
|---|---|---|
| Salas de La Celda | Cuatro | Cinco: se agregó el pasillo opcional `celda_5` |
| Primer banco | En la sala 3, junto al Eterno | En la sala 1 |
| La bajada | Sin regreso hasta tener habilidades | `celda_4` se puede volver a subir en la raíz móvil |
| Cinemáticas | Intro y La Celda por separado | Un solo video de 2 min 9 s |
