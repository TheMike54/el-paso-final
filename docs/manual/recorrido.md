# Recorrido del juego

> Contiene la historia completa del juego, incluido el final.

El juego de principio a fin tal como está el 2-nov-2026 (Las Raíces, la pausa con sus menús y la mochila, revisados el 21-nov-2026), y lo previsto por separado. Lo hecho se leyó en las escenas, en `contenido/funciones.json` y en sus guiones; para esta revisión no se jugó. Los términos están en [glosario.md](glosario.md).

## Hecho: lo que se juega hoy

Hoy la campaña tiene dos zonas: La Celda, con cinco salas y sin enemigos, y Las Raíces, con ocho salas en caja gris (puesto al día el 21-nov-2026). Termina en la salida de `raices_8`, que lleva a la pantalla de cierre.

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
| `raices_1` | Primera sala de Las Raíces: caída libre desde celda_4, PejeCoins sueltas y pizarrón que enseña la curación | Enseña a curar | Hueco del techo desde celda_4, puerta derecha a raices_2 |
| `raices_2` | Primeras peleas: dos Cucarachas, un foso y un bloque que se saltan | El primer combate | Izquierda a raices_1, derecha a raices_3 |
| `raices_3` | Sala vertical con el Eterno, que da los mapas de Las Raíces y de La Celda y la pluma del mapa; banco `banco_raices_3` y una tienda que vende la Brújula en 30 PejeCoins. Se sube por tres bloques sólidos a la cornisa | Guardar, el mapa y la tienda | Izquierda a raices_2, derecha (en la cornisa) a raices_4 |
| `raices_4` | Sala vertical con una Cucaracha y dos Polillas; se sube por dos bloques al saliente. Sobre el saliente, un techo que se rompe con golpes hacia arriba esconde una repisa con Patas de Cucaracha | Pelear con la Polilla | Izquierda a raices_3, derecha (en el saliente) a raices_5 |
| `raices_5` a `raices_8` | Segunda mitad de la zona: Hongos escupidores, raíces con espinas y plataforma de vaivén; Caparazón de Cucaracha oculto en `raices_6`; el impulso y un banco en `raices_7`, y dos huecos que lo exigen | Usar el impulso | Encadenadas por sus puertas; la salida de `raices_8` lleva a `contenido/cierre/pantalla_cierre.tscn` |

### El Eterno y la Pluma

En `celda_3`, la primera conversación son cinco líneas y entrega la habilidad `pluma`. Se ve la entrega, corre una cinemática de 10 s y se vuelve a la Entrada de la sala, junto a él. Después repite una línea: «Sigue subiendo». Antes de la Pluma, el botón de atacar no se dibuja.

Hablar con él no parece obligatorio: en la escena no hay nada que cierre el paso hacia `celda_4`. Sin comprobar jugando.

### Pausa y menús

- La pausa (botón de pausa o Atrás) detiene el juego y ofrece Continuar, la configuración con el editor de botones y salir al menú; pausar no guarda (`nucleo/pausa.gd`).
- El marco de menús muestra cuatro páginas en ciclo, Inventario, Amuletos, Útiles y Mapa, con una barra arriba que nombra la actual y sus vecinas y una flecha a cada lado (`nucleo/marco_menus.gd`). El botón del mapa lo abre en Mapa; el de inventario, en Amuletos si el jugador está sentado en un banco y en Inventario si no.
- Inventario solo se lee: vida, Inspiración, PejeCoins, el arma, lo perdido al morir, las habilidades y los mapas (`nucleo/pagina_inventario.gd`).
- Amuletos y Útiles se eligen en cualquier lugar, pero se ponen o se quitan solo sentado en un banco; los útiles van en los 4 cupos de una mochila de gis (`nucleo/pantalla_amuletos.gd`, `nucleo/pantalla_utiles.gd`).
- Mapa tiene un botón de vista que alterna entre la zona acercada y el mapa completo (`mapa/pantalla_mapa.gd`).

### Dónde termina hoy

El hueco del piso de `celda_4` baja a `raices_1`; de ahí las puertas encadenan `raices_1` a `raices_8`, y la salida de `raices_8` lleva a la pantalla de cierre («Continuará»). No hay vuelta a La Celda: el hueco provisional de `raices_1` se quitó. Lo cubren `herramientas/guiones/contenido/celda_4_tiro.guion` y un guion de recorrido por sala de Las Raíces (de ruta o de puertas, según la sala) (`herramientas/guiones/contenido/raices_*`).

### Reglas que se viven en este tramo

- Empiezas con 4 vidas. Un peligro quita una y devuelve al último suelo firme; un golpe normal empuja y da invulnerabilidad.
- Al morir reapareces en el banco. Tus PejeCoins quedan en una mochila en el último punto seguro. Interactúas con ella y abre un reto de 3 preguntas al azar de `contenido/preguntas_mochila.tres` (12 en total): con 2 aciertos recuperas las monedas; si no, se pierden. Es una sola oportunidad y la mochila desaparece en los dos casos (`nucleo/mochila.gd`).
- El banco guarda; también autoguardan determinados progresos, la muerte y el paso a segundo plano. Recoger PejeCoins no autoguarda.
- La Celda no tiene música, a propósito, salvo el tramo del banco.
- El botón de curar está oculto en toda La Celda (`botones_ocultos` de `contenido/zonas/celda/sala_celda.tscn`). En Las Raíces se ve: `raices_1` lo enseña con un pizarrón (`botones_por_ensenar` de `contenido/salas/raices/raices_1.tscn`).

### Lo que existe en código y no aparece en la campaña

Viven en el núcleo y se prueban en la zona de pruebas, pero ninguna sala de `contenido/` los usa hoy:

- Bola, doble salto, salto en pared y caída en picada: no se obtienen. Curar no es una habilidad: está desde el principio y solo La Celda oculta su botón.
- Útiles: la Brújula se compra en la tienda de `raices_3`; los otros cuatro solo los da la sala «Equipo» de la zona de pruebas.
- Estaciones, retos de preguntas colocados en una sala (el de la mochila sí corre al morir) y jefes.

## Previsto: el resto del camino

Nada de esta parte está construido, salvo Las Raíces y su pantalla de cierre, que ya se juegan en caja gris (arriba); de Las Raíces falta el arte.

| Tramo | Qué se espera |
|---|---|
| Las Raíces | Ya se juega en caja gris (tabla de salas, arriba); falta el arte de sus salas (solo el banco tiene dibujo) y el de sus tres enemigos |
| Salir de Las Raíces | La primera versión cierra con una pantalla propia: «Continuará» y, en chico, «Fin de la primera versión» |
| Zonas 2 a 5 | Los Drenajes, El Barrio Otaku, La Ciudad Perdida y El Metro: cada una da una habilidad al vencer a su jefe |
| El Estacionamiento | Sin enemigos: suena el teléfono, tus compañeros te esperan |
| ESCOM y el salón | Recorrido sin enemigos y pelea final contra los tres sinodales, primero uno por uno y luego juntos |
| Final | «TT APROBADO» en el pizarrón, firmas el acta con la Pluma, la máscara se rompe. Un solo final |

El detalle de cada zona está en `diseno.md`.

## Pendiente en este recorrido

| Tema | Estado |
|---|---|
| La Celda con arte en el teléfono de gama baja y en el de pantalla alta | Falta la prueba manual `sala-celda-1-telefono` |

## Diferencias entre lo diseñado y lo construido

| Tema | Diseño original | Hoy |
|---|---|---|
| Salas de La Celda | Cuatro | Cinco: se agregó el pasillo opcional `celda_5` |
| Primer banco | En la sala 3, junto al Eterno | En la sala 1 |
| La bajada | Sin regreso hasta tener habilidades | `celda_4` se puede volver a subir en la raíz móvil |
| Cinemáticas | Intro y La Celda por separado | Un solo video de 2 min 9 s |
