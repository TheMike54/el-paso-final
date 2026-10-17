# Salas de prueba

Qué hay en cada sala de la zona de pruebas y para qué sirve, para elegir dónde probar algo sin abrir las escenas.
Las salas viven en `herramientas/salas/`; el menú las agrupa según `GRUPOS` de `herramientas/salas/zona_pruebas.gd`
(una que no esté ahí ni en `OCULTAS` sale sola en «Otras»). Al agregar, quitar o cambiar una sala, se actualiza su
fila aquí en el mismo cambio. Inventario del 15-oct-2026.

## Cómo se entra

- Menú principal → «Zona de pruebas» (aparece con Configuración → Desarrollador en «Sí») → categoría → sala.
- El botón es el nombre del archivo sin `sala_` (`sala_doble_salto` → «Doble Salto»).
- Al entrar se reinicia la partida (`Partida.reiniciar()`) y se guarda en el archivo de pruebas. Las habilidades de
  `habilidades_de_prueba` (`nucleo/sala.gd`) se dan en silencio; las de un objeto, al tocarlo.
- Casi todas dan `pluma` (el arma). Pausa → «Salir al menú» vuelve al menú principal.

## Movimiento

| Botón | Qué hay | Habilidades | Para probar |
|---|---|---|---|
| Movimiento | 2400×760: suelo largo y una plataforma de 640×80 | pluma | Caminar, salto corto y largo, coyote, salto en cola |
| Caida | 1600×1280: repisa arriba a la izquierda, suelo 1180 px abajo, medidor de cámara | pluma | Caída larga, aterrizaje duro, cámara al caer, vibración |
| Salida Abajo | 1600×720: suelo solo en la mitad izquierda | pluma | Salir de la sala por abajo y el fundido |
| Doble Salto | 1600×720: plataforma alta (900, 340) y un objeto | objeto: `doble_salto` | Doble salto |
| Impulso | 2400×940: dos bloques altos con un foso de pinchos entre ellos y un objeto | objeto: `impulso` | Cruzar el foso con impulso |
| Pared | 1280×1520: torre entre dos paredes, pinchos abajo, banco `banco_pared` y un objeto | objeto: `salto_en_pared` | Salto en pared y escalar entre dos paredes |
| Carrera | 4000×720: pasillo largo con franjas cada 200 px y un muñeco que no se mueve al golpearlo | pluma, `impulso` | Carrera: giro, voltereta, ataque en carrera, rebote en pared |

## Combate

| Botón | Qué hay | Habilidades | Para probar |
|---|---|---|---|
| Combate | 2000×720: muñeco, bloque que daña al tocarlo, pared; puerta a «Puerta A» | pluma | Ataque, daño recibido, retroceso, invulnerabilidad |
| Combate Chico | 2400×720: cinco cortables, un muñeco alto, objeto pluma | objeto: `pluma` | Recoger el arma, cortar, golpear arriba |
| Golpe | 1600×720: muñeco que sí sale empujado al golpearlo, bloque que daña y pared | pluma | Congelado al recibir daño, empuje del enemigo golpeado, golpe contra la pared |
| Parry | 2000×720: muñeco que ataca (`muneco_que_ataca.tres`, vida 99) | pluma | Parry |
| Pogo | 2400×720: muñeco y 800 px de pinchos; objetos de impulso y doble salto | objetos: `impulso`, `doble_salto` | Rebote al golpear hacia abajo sobre los pinchos |
| Picada | 1600×1280: plataformas altas, suelo frágil, muñeco, enemigo débil abajo, objeto | objeto: `caida_en_picada` | Caída en picada, romper el suelo frágil, temblor |
| Bola | 1600×720: muñeco cerca, lejos y detrás de una plataforma; objeto | objeto: `proyectil` | Poder de bola: alcance y recarga |
| Curar | 1600×720: muñeco (para cargar Inspiración), bloque que daña (para perder vida), objeto | objeto: `impulso` | Curar, soltar a medias, curar tras un golpe |

## Enemigos

| Botón | Qué hay | Habilidades | Para probar |
|---|---|---|---|
| Enemigos | 2400×720: enemigo débil (`enemigo_debil.tres`, vida 2) y fuerte (`enemigo_fuerte.tres`, vida 3); puerta a «Enemigos Banco» | pluma | Pelear contra enemigos con retroceso, congelado al vencer |
| Enemigos Banco | 1600×720: banco `banco_enemigos` y puerta de vuelta | pluma | Descansar y volver: los enemigos reaparecen |
| Peligro | 2000×940: dos suelos con pinchos en el hueco | pluma | Caer en un peligro y volver al punto seguro |
| Peligro Movil | 2000×720: sierra que va y viene y pinchos fijos | pluma | Peligro que se mueve |

## Salas

| Botón | Qué hay | Habilidades | Para probar |
|---|---|---|---|
| Banco | 1600×720: banco `banco_prueba`, bloque que daña y pared | pluma | Sentarse, guardar, el aviso de guardado |
| Dialogo | 1600×720: NPC «Guia» con dos conversaciones; la primera ofrece el mapa | la conversación da `pluma_mapa` | Diálogo con opciones y recompensas |
| Reto | 1600×720: «Sinodal», 3 preguntas, meta 2, premio 50 PejeCoins | ninguna | Reto de preguntas |
| Secretos | 3200×1280: muro de 4 golpes que destapa un cuarto con premio, muro que solo se rompe desde la derecha, techo rompible con premio arriba, palanca que abre un portón con premio detrás | pluma, `proyectil` | Muros rompibles, tapas, golpe por lado, bola contra el muro, palanca y portón; volver a entrar y que siga roto y abierto |
| Puerta A | 2400×720: puerta derecha a «Puerta B» | pluma | Cambio de sala, fundido, saltar junto a la puerta |
| Puerta B | 1280×720: puerta izquierda a «Puerta A» | pluma | Lo mismo desde el otro lado |
| Camara | 3200×1440: escalera de seis escalones | pluma | Seguimiento de cámara, límites, adelanto de cámara |
| Capas | La de Cámara con tres capas `Parallax2D` de franjas | pluma | Paralaje |
| Recursos | 2560×720: 30 plantas, 2 nieblas, 3 emisores, 6 cortables | pluma | Qué se apaga en Recursos «bajo» y su costo |
| Arte | 6400×1080: capas de arte generado con IA, adornos, animaciones y partículas; botones Part, Frente, Niebla y Anim para apagar cada grupo | pluma | FPS en el teléfono (fila «Sala de arte» de `docs/pruebas.md`) |

## Zonas

Salas con id, unidas por puertas, como en el juego real. Todas dan `pluma`.

| Botón | Qué hay | Para probar |
|---|---|---|
| Mapa 1 | Mapa de la zona, mapa de «prueba», pluma del mapa, banco `banco_mapa_1`, brújula; puertas a «Prueba 4» y «Mapa 2» | Mapas, pluma del mapa, brújula, pantalla del mapa |
| Mapa 2 | Sala alta, puerta a «Mapa 1» | Sala de dos pantallas de alto en el mapa |
| Prueba 1 | Banco `banco_prueba_1`, puerta a «Prueba 2» | Puertas por id y banco de zona |
| Prueba 2 | Un coleccionable, puertas a 1 y 3 | Coleccionable recordado |
| Prueba 3 | Dos coleccionables, puertas a 2 y 4 | Juntar coleccionables |
| Prueba 4 | Vitrina y entrega: 1 coleccionable = 100 PejeCoins, 2 = `amuleto_prueba`, 3 = vida máxima +1; puertas a 3 y «Mapa 1» | Recompensas por coleccionables |

## Fuera del menú

Las escenas de `OCULTAS` no tienen jugador para jugar: solo las corre su guion de `herramientas/guiones/`
(`sala_guardado` → `guardado.guion`, `sala_tactil` → `controles_tactiles.guion`, etc.; la misma base de nombre).
