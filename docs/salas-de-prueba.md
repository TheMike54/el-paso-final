# Salas de prueba

Qué hay en cada sala de la zona de pruebas y para qué sirve, para elegir dónde probar algo sin abrir las escenas.
Las salas viven en `herramientas/salas/`; el menú las agrupa según `GRUPOS` de `herramientas/salas/zona_pruebas.gd`
(una que no esté ahí ni en `OCULTAS` sale sola en «Otras»). Las pruebas de código, sin jugador, están aparte, en
`herramientas/pruebas/` (ver «Fuera del menú»). Al agregar, quitar o cambiar una sala, se actualiza su
fila aquí en el mismo cambio. Inventario del 15-oct-2026; siete categorías desde el 17-oct-2026.

## Cómo se entra

- Menú principal → «Zona de pruebas» (aparece con Configuración → Avanzado → Desarrollador en «Sí») → categoría → sala.
- Cada sala lleva su nombre y, debajo, para qué sirve (`SALAS` de `zona_pruebas.gd`); una de «Otras» lleva el
  nombre del archivo sin `sala_`. Puerta B no se lista: se llega por la puerta de Puerta A.
- Al entrar se reinicia la partida (`Partida.reiniciar()`) y se guarda en el archivo de pruebas. Las habilidades de
  `habilidades_de_prueba` (`nucleo/sala.gd`) se dan en silencio; las de un objeto, al tocarlo.
- Casi todas dan `pluma` (el arma). Pausa → «Salir al menú» vuelve al menú principal.

## Suelo

Igual que en las salas del juego (`docs/contrato.md`, «Sala», cámara): bajo los pies se ven 40 px de suelo, y 120 en
las salas de caída larga (Caída). Los sólidos se dibujan de `Color(0.3, 0.3, 0.32)`. Dos salas muestran más a
propósito: Peligro (el foso de pinchos) e Impulso (los bloques altos). Igualado el 17-oct-2026.

## Movimiento

| Botón | Qué hay | Habilidades | Para probar |
|---|---|---|---|
| Movimiento | 2400×720: suelo largo y una plataforma de 640×80 | pluma | Caminar, salto corto y largo, coyote, salto en cola |
| Caída | 1600×1280: repisa arriba a la izquierda, suelo 1180 px abajo, medidor de cámara | pluma | Caída larga, aterrizaje duro, cámara al caer, vibración |
| Salida abajo | 1600×720: suelo solo en la mitad izquierda | pluma | Salir de la sala por abajo y el fundido |
| Doble salto | 1600×720: plataforma alta (900, 340) y un objeto | pluma; objeto: `doble_salto` | Doble salto |
| Impulso | 2400×940: dos bloques altos con un foso de pinchos entre ellos y un objeto | pluma; objeto: `impulso` | Cruzar el foso con impulso |
| Pared | 1280×1520: torre entre dos paredes, pinchos abajo, banco `banco_pared` y un objeto | pluma; objeto: `salto_en_pared` | Salto en pared y escalar entre dos paredes |
| Carrera | 4000×720: pasillo largo con franjas cada 200 px y un muñeco que no se mueve al golpearlo | pluma, `impulso` | Carrera: giro, voltereta, ataque en carrera, rebote en pared |

## Combate

| Botón | Qué hay | Habilidades | Para probar |
|---|---|---|---|
| Combate | 2000×720: muñeco, bloque que daña al tocarlo, pared; puerta a «Puerta A» | pluma | Ataque, daño recibido, retroceso, invulnerabilidad |
| Combate chico | 2400×720: cinco cortables, un muñeco alto, objeto pluma | objeto: `pluma` | Recoger el arma, cortar, golpear arriba |
| Golpe | 1600×720: muñeco que sí sale empujado al golpearlo, bloque que daña y pared | pluma | Congelado al recibir daño, empuje del enemigo golpeado, golpe contra la pared |
| Parry | 2000×720: muñeco que ataca (`muneco_que_ataca.tres`, vida 99) | pluma | Parry |
| Pogo | 2400×720: muñeco y 800 px de pinchos; objetos de impulso y doble salto | pluma; objetos: `impulso`, `doble_salto` | Rebote al golpear hacia abajo sobre los pinchos |
| Picada | 1600×1280: plataformas altas, suelo frágil, muñeco, enemigo débil abajo, objeto | pluma; objeto: `caida_en_picada` | Caída en picada, romper el suelo frágil, temblor |
| Bola | 1600×720: muñeco cerca, lejos y detrás de una plataforma; objeto; un pasto en el camino de la bola y otro detrás de la plataforma, los dos flotando a la altura de la bola | pluma; objeto: `proyectil` | Poder de bola: alcance, recarga y que corte el pasto sin pararse |
| Curar | 1600×720: muñeco (para cargar Inspiración), bloque que daña (para perder vida), objeto | pluma; objeto: `impulso` | Curar, soltar a medias, curar tras un golpe |

## Enemigos

| Botón | Qué hay | Habilidades | Para probar |
|---|---|---|---|
| Enemigos | 2400×720: enemigo débil (`enemigo_debil.tres`, vida 2) y fuerte (`enemigo_fuerte.tres`, vida 3); puerta a «Enemigos Banco» | pluma | Pelear contra enemigos con retroceso, congelado al vencer |
| Enemigos banco | 1600×720: banco `banco_enemigos` y puerta de vuelta | pluma | Descansar y volver: los enemigos reaparecen |
| Peligro | 2000×940: dos suelos con pinchos en el hueco | pluma | Caer en un peligro y volver al punto seguro |
| Peligro móvil | 2000×720: sierra que va y viene y pinchos fijos | pluma | Peligro que se mueve |
| Enemigos móviles | 3600×1080: un caminante sobre una plataforma de 600 px y otro en el suelo junto a un tope; un volador junto a un pilar que tapa la vista, con dos escalones a su izquierda para subirlo (de ida: de vuelta no se sube); un escupidor al fondo a la derecha | pluma | Enemigos que caminan, vuelan y lanzan en arco; FPS con los tres a la vez |

## Mundo

| Botón | Qué hay | Habilidades | Para probar |
|---|---|---|---|
| Banco | 1600×720: banco `banco_prueba`, bloque que daña y pared | pluma | Sentarse, guardar, el aviso de guardado |
| Puerta A | 2400×720: puerta derecha a «Puerta B» | pluma | Cambio de sala, fundido, saltar junto a la puerta |
| Puerta B | No se lista (`OCULTAS`): se llega por la puerta de Puerta A. 1280×720: puerta izquierda a «Puerta A» | pluma | Lo mismo desde el otro lado |
| Puerta C | 2400×720: dos puertas de tipo `PUERTA` (en x 800 y x 1800) que llevan una a la otra en la misma sala | pluma | Cruzar con `interactuar` (aviso, voltearse de espaldas, salir de espaldas), que pasar por enfrente no cruce, el toque en el teléfono |
| Cámara | 3200×1440: escalera de seis escalones | pluma | Seguimiento de cámara, límites, adelanto de cámara |
| Capas | La de Cámara con tres capas `Parallax2D` de franjas | pluma | Paralaje |
| Secretos | 3200×1200: muro de 4 golpes que destapa un cuarto con premio y 10 PejeCoins encerradas (al romperse aparece la orilla del hueco, `descubre`), muro que solo se rompe desde la derecha, techo rompible con premio arriba, palanca que abre un portón con premio detrás | pluma, `proyectil` | Muros rompibles, tapas, lo que descubre el muro y que las monedas no se tomen antes de romperlo, golpe por lado, bola contra el muro, palanca y portón; volver a entrar y que siga roto y abierto |
| Pizarrones | 3600×720, en el orden de King's Pass, y se entra con una vida menos (`vida_menos_prueba.gd`) para poder curar aunque el caminante no pegue, y sin los botones de saltar, atacar ni curar, que aparecen al llegar a su pizarrón: saltar en x 1000 ante un bloque (x 1300); atacar en x 1600, dentro de un corral que cierra otro bloque en x 2500, con un caminante que va y viene y pega al tocarlo; curar en x 2850, con la nota «Golpea enemigos para ganar Inspiración»; «Sentarse» sobre el banco `banco_pizarrones` (x 3300), sin pizarrón | pluma | Que cada aviso salga poco después de entrar, con su botón y su palabra (con el control, el del control en uso; tras un toque, el de la pantalla, que late); que se vaya al hacer la acción y no vuelva al regresar a la sala en la misma partida; que cada botón de la pantalla aparezca al llegar a su pizarrón; y que el caminante deje con ganas de curarse |
| Plataformas | 2400×720: lámpara de una vía (`PlataformaDelgada`, cara a 180 px del suelo) a la izquierda, barra que gira (`Giro`, golpe) arriba y a su derecha (centro en x=650, y=230; barre x 550-750), 800 px de pinchos con una plataforma que va y viene encima (`Vaiven` en el `AnimatableBody2D`, con espera en cada extremo), y un elevador que sube del suelo a una cornisa a la derecha; suelo de 120 px de grueso (regla del contrato bajo una pieza sólida que baja) | pluma | Que la plataforma y el elevador lleven al jugador; caer a los pinchos desde la plataforma y volver al suelo fijo, no al aire; quedarse debajo del elevador cuando baja (no daña, lo deja encima); saltar del elevador mientras baja (sube como desde el suelo); cruzar la lámpara caminando y subirse de un salto |
| Música | 2000×720: sala callada (`tema_musica` = `Musica.SILENCIO`) con una `RegionMusica` del tema del menú de 700×400 sobre el banco `banco_musica` (a la derecha; una franja morada en el suelo marca la región) y la `Entrada` fuera de ella, a la izquierda | ninguna | Que el tema suba al acercarse al banco (3 s) y se apague al alejarse (6 s) sin volver a empezar; sentarse, morir o salir y continuar, y que al reaparecer en el banco el tema siga donde iba; en la pausa, lejos del banco, abrir Configuración → Audio: suena el tema del menú y se calla al cerrarlo |

## Partida

| Botón | Qué hay | Habilidades | Para probar |
|---|---|---|---|
| Diálogo | 1600×720: NPC «Guia» con dos conversaciones; la primera ofrece el mapa | la conversación da `pluma_mapa` | Diálogo con opciones y recompensas |
| Reto | 1600×720: «Sinodal», 3 preguntas, meta 2, premio 50 PejeCoins | ninguna | Reto de preguntas |
| Lo perdido | 2400×720: da 120 PejeCoins al entrar sin monedas ni mochila y deja una vida; pinchos a la derecha | pluma | Morir con monedas, volver por la mochila y recuperarla con el reto de la bolsa de prueba (6 preguntas, 3 por intento, meta 2) |
| Tienda | 2000×720: da 300 PejeCoins la primera vez; el impulso a la izquierda y la tienda a la derecha, con cuatro artículos: pluma del mapa (50), vida máxima (500, no alcanza), doble salto (100, solo con el impulso) y un amuleto (120) | pluma | Comprar: el precio, lo gris, confirmar con Sí / No con el pulgar y con el control, y que lo comprado no vuelva |

## Rendimiento

| Botón | Qué hay | Habilidades | Para probar |
|---|---|---|---|
| Recursos | 2560×720: 30 plantas, 2 nieblas, 3 emisores, 6 cortables | pluma | Qué se apaga en Recursos «bajo» y su costo |
| Arte | 6400×1080: capas de arte generado con IA, adornos, animaciones y partículas; botones Frente y Anim para apagar cada grupo (partículas y niebla, con el panel de pruebas; los FPS, con «Mostrar FPS») | pluma | FPS en el teléfono (fila «Sala de arte» de `docs/pruebas.md`) |

## Zonas

Salas con id, unidas por puertas, como en el juego real. Todas dan `pluma`, salvo La Celda, que es del juego.

| Botón | Qué hay | Para probar |
|---|---|---|
| La Celda | Va primero. La cinemática (`contenido/cinematicas/cinematica_celda.tscn`, heredada en `herramientas/salas/la_celda.tscn`) y después la sala `celda_1` del juego (`contenido/salas/celda/`): foso de varillas (1571-1757), banco `banco_celda_1` (x ≈ 2966), grieta con raíces como foso (3685-3875), un pizarrón sobre el foso de varillas que enseña el salto largo y, antes de la puerta, un pizarrón con patas que enseña «Entrar»; con su arte, luces, cables, partículas y niebla. Por la puerta del salón (x 4300, con acción) sigue `celda_2`: dos fosos de varillas (1407-1593 y 3474-3660), cables pelados (3038-3388) que solo se cruzan por arriba (escombros, columna rota, lámpara de una vía, plataforma que va y viene y elevador), hueco del techo (3760-4126) a `celda_5` y la puerta SALIDA (x 4250, caminando), que sigue a `celda_3` (el Eterno, que entrega la pluma, y el coleccionable `coleccionable_nicho`) y, por su boquete de raíces, a `celda_4` (tiro, raíz móvil y cornisa con `monedas_cornisa`). `celda_5`, el pasillo de arriba: foso, aspas, coleccionable `coleccionable_pasillo` (x 130) y el hueco del piso (1469-1707) que baja al elevador | Cinemática (con el modo desarrollador se salta), la sala con su arte, FPS en el teléfono, panel de pruebas con grupos reales |
| Mapa 1 | Mapa de la zona, mapa de «prueba», pluma del mapa, banco `banco_mapa_1`, brújula; puertas a «Prueba 4» y «Mapa 2» | Mapas, pluma del mapa, brújula, pantalla del mapa |
| Mapa 2 | Sala alta, puerta a «Mapa 1»; pinchos en x 1300 | Sala de dos pantallas de alto en el mapa; morir con monedas y ver la mochila en el mapa |
| Prueba 1 | Banco `banco_prueba_1`, estación gratis `estacion_prueba_1` (x 1100), puerta a «Prueba 2» | Puertas por id, banco de zona y viaje rápido |
| Prueba 2 | Un coleccionable, puertas a 1 y 3 | Coleccionable recordado |
| Prueba 3 | Dos coleccionables, puertas a 2 y 4 | Juntar coleccionables |
| Prueba 4 | Vitrina y entrega: 1 coleccionable = 100 PejeCoins, 2 = `amuleto_prueba`, 3 = vida máxima +1; estación `estacion_prueba_4` de 50 PejeCoins (x 800); puertas a 3 y «Mapa 1» | Recompensas por coleccionables; pagar una estación y viajar a «Prueba 1» y de vuelta |

## Fuera del menú

- `OCULTAS` solo lleva la propia zona y Puerta B: son de `herramientas/salas/` y se juegan, pero no se listan.
- Las pruebas de código (`sala_*.tscn` con su `prueba_*.gd` y `prueba_base.gd`) viven en `herramientas/pruebas/`
  desde el 17-oct-2026. No tienen jugador para jugar ni salen en el menú: solo las corre su guion de
  `herramientas/guiones/` (`sala_guardado` → `guardado.guion`, `sala_tactil` → `controles_tactiles.guion`, etc.). No
  viajan en el paquete de publicación (`docs/contrato.md`, «Paquete de publicación»).
