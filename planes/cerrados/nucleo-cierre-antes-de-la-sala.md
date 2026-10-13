CERRADO

# Núcleo: cierre antes de la primera sala

Hoja de ruta para cerrar el núcleo antes de La Celda 1, de modo que hacer salas sea solo colocar piezas. Aprobado por
la persona el 11-oct-2026, con sus respuestas a la revisión, como tanda autónoma: todas las fases antes de La Celda,
en este orden, más la pantalla del mapa. Cerrado el 12-oct-2026 con las fases 0 a 8 hechas: la 9 (prueba con
control real) es la entrada `entrada-control` y la 10 queda fuera de la tanda. Este documento es el documento vivo de la tanda: cada decisión va aquí con
su porqué. Las entradas nuevas de `funciones.json` salen de este plan aprobado.

## 1. Decidido por la persona (11-oct-2026)

| Tema | Decisión |
|---|---|
| Primera sala | La Celda 1 (zona 0). Nueva partida lleva a ella cuando exista (fase 10, fuera de esta tanda) |
| Arma | La Celda 1 y 2 sin atacar hasta recibir la Pluma (habilidad `pluma`) |
| Enemigos | Enemigo = ficha + script de comportamiento (ver sección 2) |
| Mecánicas chicas | Ataque hacia arriba, cola del ataque, congelado común, morir vacía la Inspiración, estado persistente genérico por sala |
| Guardado | Copiar lo más fiel posible a Hollow Knight y Silksong; donde difieran, lo mejor para el juego. Esquema de la sección 4. El sistema de Silksong queda documentado aparte para consultarlo |
| Autoguardado | Al obtener una habilidad, vencer a un jefe, recoger un amuleto, recoger un coleccionable, morir, salir al menú y pasar la app a segundo plano. Guarda lo obtenido, no la posición: al reabrir se aparece en el último banco. Aviso: ícono abajo a la derecha (diseño del ícono, después). Cambiado el 12-oct-2026: bajo las PejeCoins, porque abajo a la derecha lo tapaba Saltar (`docs/errores/2026-10-12-icono-guardado-bajo-saltar.md`) |
| Peligros | Regla de Silksong: lo fijo regresa al suelo seguro; lo que se mueve solo golpea (sección 7) |
| Impulso | Un solo comportamiento, sin ajuste «mantener / alternar» (sección 6) |
| Dash hacia abajo | Nunca: es el pogo de Silksong y el nuestro es el de Hollow Knight |
| Ataque en carrera | Sí, de una vez: es parte de la mecánica del sprint |
| Parry | En la fase 3, con el muñeco que ataca |
| Mapa | Bloque independiente; dos estados (alejado por zonas, acercado con detalle); Pluma para dibujar; brújula para ver al jugador, activable a mano por ahora; dibujo de cada sala reemplazable sin tocar código (sección 10) |
| Recursos | Modo bajo y modo alto; el juego detecta el teléfono al iniciar; botón en Configuración; elegir alto en un teléfono débil se permite con aviso. Las plantas se quedan quietas en la pausa (sección 8) |
| Cortables | Genéricos (pasto y otras cosas según la zona); en bajos recursos aparecen menos o ninguno (sección 9) |
| Coleccionable | Genérico, sin arte ni tema; tomarlo guarda; sala donde se ven los juntados; recompensas por cantidad (sección 11) |
| Configuración | Controles (táctiles y reasignación del control), Vibración, Temblor, Recursos, Volumen, Modo desarrollador, Borrar partida y Créditos. Vibración y Temblor salen de la pausa |
| Menús | Se manejan con control y teclado |
| Prueba del control | Una sola vez, al final, por otro integrante |
| Regla para lo que no sabe la persona | Si ya se investigó cómo lo hacen Hollow Knight o Silksong, se hace igual; luego se consulta al advisor y se decide. Lo que la persona confirma de haber jugado vale como fuente |

## 2. Decisiones cerradas que se contradecían (resueltas con el advisor, 11-oct-2026)

| Antes | Queda | Por qué |
|---|---|---|
| «Un enemigo nuevo es una ficha `.tres`, no código» | Un enemigo nuevo es una ficha; su comportamiento es un script de `contenido/enemigos/` que la ficha referencia (`comportamiento`). `nucleo/enemigo.gd` lo instancia sin conocer ninguno. Sin script, el enemigo se queda quieto como hoy | Conserva lo que la regla protegía (el núcleo no sabe de enemigos concretos) y permite moverse y atacar. La ficha manda; el script obedece |
| «Pausar no guarda. La partida se guarda solo en los bancos» | La acción `pausa` no guarda. Pasar a segundo plano sí guarda, igual que salir al menú y los demás momentos de autoguardado: lo obtenido, nunca la posición | La pausa ya se abre sola al perder el foco, así que el disparador es la notificación del sistema, no el menú. Sin posición guardada, guardar a mitad de una pelea no deja nada inconsistente |

## 3. Convenciones del contenido

| Qué | Cómo | Por qué |
|---|---|---|
| Carpeta del contenido | Bloque `contenido/`, con su `CLAUDE.md` y su `funciones.json`. Dentro: `contenido/salas/<zona>/<id_sala>.tscn`, `contenido/enemigos/<id>/` (ficha, script y escena), `contenido/objetos/` | Separa lo que se juega del motor (`nucleo/`) y de las pruebas (`herramientas/`) |
| Id de zona | Una palabra sin guion bajo: `celda`, `raices`, `drenajes` | Legible en el guardado y en el mapa; el id de sala se separa sin ambigüedad |
| Id de sala | `<zona>_<número>`: `celda_1`. Es también el nombre del archivo. Propiedad `id` de la sala; el validador comprueba que coincide con el archivo y que no se repite | El guardado y el mapa usan el id: mover una carpeta no rompe partidas |
| De id a escena | `Sala.ruta_de(id)`: `celda_1` → `res://contenido/salas/celda/celda_1.tscn`. Una ruta `res://` pasa tal cual (salas de prueba, sin id). Las puertas siguen apuntando a la ruta y el validador comprueba que exista | `change_scene` necesita una ruta; el guardado guarda el id |
| Id de puerta | Por el lado: `izquierda`, `derecha`, `arriba`, `abajo`; dos del mismo lado: `derecha_2` | Fácil de emparejar |
| Id de banco | `banco_<id_sala>` | Único sin llevar una lista |
| Id de objeto persistente | Corto y único dentro de la sala: `examenes_1`, `palanca`. Clave guardada: sala + objeto | Los dos juegos de referencia usan sala + id |
| Guion de cada sala | Entra por cada puerta y cae al suelo; cruza cada puerta y llega a la sala y puerta destino; descansa en el banco y se guardó | Atrapa una puerta mal conectada o una llegada en el aire |
| Validador de contenido | Ids únicos, puertas de ida y vuelta, banco con su id, sala con `limites`, `Entrada` dentro de `limites`; el índice de salas al día entra con el mapa (fase 8) | Atrapa errores sin correr el juego |

## 4. Guardado versión 3

Nadie tiene partidas que conservar: se fija el esquema de la v1 de una vez, con valores vacíos donde la mecánica
todavía no existe. Modelo: Hollow Knight y Silksong guardan `playerData` (lo del jugador, con listas de ids) y
`sceneData` (lo de cada sala, con clave sala + id); Silksong además guarda copias de seguridad al obtener algo
(`identifier="GAINED_DOUBLE_JUMP"`).

| Campo | Qué guarda | Ejemplo |
|---|---|---|
| `banco` | `{sala, id}` del último banco; vacío si no se ha descansado | `{"sala": "celda_3", "id": "banco_celda_3"}` |
| `vidas_maximas` | Vidas máximas | `4` |
| `habilidades` | Ids, incluida el arma | `["pluma", "impulso"]` |
| `jefes` | Ids de jefes vencidos | `["reina_cucaracha"]` |
| `amuletos_tenidos`, `amuletos_equipados` | Ids | `[]` |
| `monedas` | PejeCoins | `0` |
| `mochila` | Lo que se perdió al morir: `{sala, x, y, monto}`, o vacío | `{}` |
| `mapas` | Zonas cuyo mapa se tiene | `["celda"]` |
| `salas_visitadas`, `salas_mapeadas` | Ids (o rutas, en las salas de prueba) | `["celda_1"]` |
| `salas` | Estado por sala: `{sala: {objeto: true o número}}` | `{"celda_3": {"examenes_1": true}}` |
| `personaje`, `nombre` | Elegidos en Nueva partida | `""` |
| `tiempo_jugado` | Segundos | `512` |

- Los enemigos que reaparecen no se escriben; los fuertes vencidos siguen en memoria y se borran al descansar o morir.
- Sin cifrado ni suma de control: la detección de dañado (JSON, versión, campos y tipos) basta.
- Una partida de versión 2 es `INCOMPATIBLE`, sin migración (nadie tiene partidas que conservar).
- Continuar sin banco (autoguardado antes del primer descanso): lleva a la sala inicial, por su `Entrada`, como en
  Hollow Knight, donde sin banco se reaparece en el inicio de la partida.

## 5. Orden de trabajo

Cada fase: `validar.ps1` en verde, sus guiones, el `revisor` (dos pasadas como máximo; lo abierto se anota) y su
bloque de commit en su propia rama. Nunca se empieza una fase con algo en rojo.

| # | Fase | Qué incluye | Rama del bloque |
|---|---|---|---|
| 0 | Contrato del contenido | Sección 3 en `docs/contrato.md`; `id` en la sala; `Sala.ruta_de`; bloque `contenido/` con su `CLAUDE.md`; reglas nuevas del validador | `feature/contenido-contrato` |
| 1 | Guardado y autoguardado | Esquema v3; estado por sala (absorbe `nucleo-suelo-fragil-guardado.md`); siete momentos de autoguardado; ícono provisional; salas visitadas; coleccionable con su sala y sus recompensas | `feature/nucleo-guardado-v3` |
| 2 | Combate chico | Cola del ataque; ataque hacia arriba; morir vacía la Inspiración; la Pluma habilita el ataque; congelado común; `Cortable` | `feature/nucleo-combate-chico` |
| 3 | Enemigos y parry | Comportamiento por script; ataque separado del cuerpo con la marca «se puede parar»; disparos enemigos; muñeco que ataca; parry | `feature/nucleo-enemigos-parry` |
| 4 | Impulso | Dash, sprint, giro y ataque en carrera (sección 6) | `feature/nucleo-impulso-sprint` |
| 5 | Peligros | Regla fijo / móvil (sección 7) | `feature/nucleo-peligros` |
| 6 | Menú y Configuración | Pantallas, reasignación del control, Volumen, Recursos, Borrar partida, Créditos, modo desarrollador (absorbe `nucleo-modo-desarrollador.md`), foco con control y teclado | `feature/nucleo-menu-configuracion` |
| 7 | Capas y recursos | Modo bajo y alto, detección, plantas, niebla, emisores, sala de medición (sección 8) | `feature/nucleo-capas-recursos` |
| 8 | Pantalla del mapa | Bloque `mapa/` (sección 10) | `feature/mapa-pantalla` |
| 9 | Prueba del control | Una sola prueba con control real, por otro integrante | — |
| 10 | La Celda 1 | Primera sala en `contenido/` (fuera de esta tanda) | — |

Las salas de prueba se reorganizan en cada fase para que lo nuevo se pruebe en ventana y en el teléfono.
Las ramas de la tabla no se crearon: las fases 0 a 3 y 4 a 8 entraron en dos commits en
`feature/nucleo-cierre-antes-de-la-sala` (12-oct-2026).

## 6. Impulso (decidido por la persona, 11-oct-2026)

| Momento | Qué pasa |
|---|---|
| Tocar Impulso | Dash como el de Hollow Knight (en el suelo o en el aire, uno por estancia en el aire) y al terminar, si hay dirección en el joystick, empieza el sprint |
| Sprint | Unas 2,1 veces la velocidad de correr (Silksong: «112 % más rápido»). Sigue hasta soltar el joystick, chocar con una pared, curarse o recibir daño |
| Saltar en sprint | Conserva la velocidad en el aire (salto largo) |
| Girar en sprint | No lo apaga: unos ticks de cambio de sentido (frenado) y sigue hacia el otro lado, como Hornet en Silksong (confirmado por la persona). Animación de prueba mientras no haya arte |
| Atacar en sprint | Ataque en carrera: el golpe sale con el impulso y empuja hacia adelante |
| Joystick solo | Nunca hace un dash: si fuera automático, habría uno cada vez que se cambia de dirección |
| Dash hacia abajo | Nunca |

Todos los valores son nuestros y se ajustan en el teléfono.

Soltar frente a cruzar el centro (decidido en la tanda, 11-oct-2026, a medir en el teléfono): la carrera aguanta
`ticks_soltar_carrera` (4) ticks sin dirección a velocidad completa; más que eso es soltar. Sin esa ventana, todo
giro con el joystick táctil o con un stick la apagaba al pasar por la zona muerta.

## 7. Peligros (decidido por la persona, 11-oct-2026)

- Fijo (pinchos, varillas, ácido, lava, vacío): quita vida y regresa al último suelo seguro. Confirmado por la
  persona: la lava de Far Fields en Silksong regresa a donde estaba antes de caer.
- Que se mueve (sierras que viajan, trampas que caen, pinchos que lanza un jefe): golpe de enemigo, con retroceso e
  invulnerabilidad. Confirmado por la persona: los pinchos que lanza la Radiance solo dañan.
- En el núcleo: `DanoContacto` ya hace las dos cosas (`peligro` sí o no). La pieza que se mueve fija `peligro` en
  falso por regla (se valida), no por decisión de quien hace la sala.

## 8. Capas y recursos

- Modo bajo: sin partículas decorativas (o un emisor), plantas quietas, niebla quieta, sin capas lejanas
  decorativas, sin parpadeos y menos cortables. Modo alto: todo, dentro del presupuesto (3 emisores, 60 partículas,
  30 plantas con vaivén, 2 capas translúcidas grandes, ninguna luz 2D). Nunca se apagan los avisos de peligro.
- Detección al iniciar (`auto`): teléfono de 32 bits o con poca memoria → bajo; si no, alto. El ajuste tiene tres
  valores (`auto`, `bajo`, `alto`); elegir alto en un teléfono que la detección marca como débil muestra un aviso.
- Las plantas se quedan quietas en la pausa: el vaivén usa un tiempo propio que no avanza en pausa (`TIME` del
  shader sí avanza).

## 9. Cortables

- Pieza común `Cortable` (`Area2D`, distinta de `Golpeable`): el ataque del jugador la corta (cambia a su versión
  cortada, suelta unos trozos) y emite `cortado`. No da Inspiración, no rebota al jugador, no hace pogo, no cuenta
  como enemigo. Se agita al pasar el jugador. Vuelve al entrar de nuevo a la sala.
- Genérica: el dibujo entero y el cortado son nodos de la escena que la usa; el núcleo solo cambia cuál se ve.
- Modo bajo: los marcados como prescindibles no aparecen. La cantidad por sala se fija al medir en el S50.

## 10. Mapa

Bloque independiente `mapa/`: no conoce ninguna zona; dibuja lo que existe y, si no hay nada, no dibuja. Dos vistas,
como en Hollow Knight y Silksong: el mapa completo (acción `mapa`, detiene el juego) y el mapa rápido (`mapa_rapido`
mantenida, encima mientras se camina). El completo tiene dos estados: alejado (cada zona como la silueta de sus
salas, con su nombre) y acercado (las salas de la zona actual con borde); abre acercado y «−»/«+» cambian. Los dos
estados se tomaron de la descripción de la persona: la wiki no los describe y no hubo capturas (queda para
investigar con capturas reales).

- Sin la Pluma no se dibuja nada; con ella, lo visitado se dibuja al descansar en un banco, solo en las zonas cuyo
  mapa se tiene.
- El jugador se ve solo con la brújula, que es un amuleto equipado (`brujula` en `amuletos_equipados`, como el Wayward
  Compass; decidido con el advisor en la tanda); por ahora se activa a mano (interruptor de la zona de prueba), sin
  tienda.
- Dibujo de cada sala: una pieza reemplazable al lado de la sala; sin ella, un rectángulo generado de sus `limites`.
- Índice de salas generado y comprobado por el validador: el paquete exportado no deja listar escenas con fiabilidad.

## 11. Coleccionable

- Pieza común `Coleccionable` con `id`: al tocarla se marca en el estado de su sala, emite `coleccionable_obtenido`,
  autoguarda y desaparece; si ya está marcada, no aparece. El total sale de contar las marcas.
- Recomendado: 12 en la v1 (la persona dijo de 10 a 15 como máximo), recompensas a los 4, 8 y 12: PejeCoins, un
  amuleto y una vida máxima más. Las entrega una pieza común en la sala de los coleccionables, marcadas en el estado
  de su sala (`entregado_4`...).
- Sala donde se ven todos los juntados: la mecánica (uno visible por cada marca) se prueba en `herramientas/`; la
  sala del juego es contenido, sin tema todavía.

## 12. Riesgos

- Fase 3 cambia una regla del contrato: se actualiza en el mismo cambio.
- Fase 4 toca el movimiento ya aprobado en el teléfono: se vuelve a probar en el S50 y el S20.
- Volumen y Recursos se agregan como ajustes con poco efecto visible hasta que haya audio y arte.

## 13. Avance

| Fase | Estado | Evidencia |
|---|---|---|
| 0 | Hecha | `validar` 97/0; 85 guiones previos más 3 de `contenido/`; cuatro roturas del validador dan `FALLO`; mutación de `cambio_de_sala` hace fallar `sala_id`. `revisor`: dos fallos (una línea del contrato, comprobación de `sala-id`), corregidos |
| 1 | Hecha | `validar` 105/0; 90 guiones (guardado 40 casos, estado_sala 25, coleccionable, vitrina, banco de la zona). `revisor`: el banco guardaba antes de dibujar el mapa (corregido, con caso que falla si se invierte el orden), Continuar con una sala que ya no existe, validador solo con hijos directos, comprobaciones y documentos viejos; corregidos. Falta en el teléfono: `autoguardado-segundo-plano` y el ícono (al cerrar, 12-oct-2026: el ícono, visto en el S50; queda `autoguardado-segundo-plano`) |
| 2 | Hecha | `validar` 111/0; 93 guiones (`combate_chico`, `combate_chico_cuentas` 5 casos, `congelado_pulsacion`); `camara_temblor_picada` pasa a `fin 300` por el congelado al vencer (misma fase del temblor). Mutaciones: sin cola, sin pluma y sin guardar la pulsación en el congelado, el guion falla. `revisor`: pulsaciones perdidas en el congelado (corregido), el pasto se sacudía congelado, `ESTADO.md` y la comprobación de la Inspiración; corregidos. `pedir` cuenta el tick actual (como el contador que reemplaza) |
| 3 | Hecha | `validar` 117/0; 95 guiones (`parry`: golpe parable, disparo y golpe no parable; `parry_ventana`: invulnerable, congelado y vibración tras la parada). Mutaciones: sin la marca, sin el congelado del parry y sin la excepción de la vibración, falla. El muñeco de prueba no retrocede (si no, se sale del alcance de su golpe). `revisor`, dos pasadas: la vibración de pegar tapaba la del parry (`al_parar` salta el límite, como el daño), faltaba medir la ventana y el congelado, y la comprobación de `parry`; corregidos. Falta en el teléfono: si la ventana del parry se siente justa |
| 4 | Hecha | `validar` 118/0; 108 guiones (13 de `carrera_*` en `sala_carrera`, con muñeco); `jugador_pogo_recupera` cambia a propósito (el impulso del aire arranca la carrera: x=80, sin recuperar x=251; la izquierda se suelta en el 24). Mutaciones: sin parada en la pared, giro que apaga, ventana en 0, impulso hacia el lado viejo, giro pegado tras el impulso (dos caminos) y rebote en el ataque en carrera, falla. `revisor`, dos pasadas: el giro con el joystick apagaba la carrera al cruzar la zona muerta (ventana `ticks_soltar_carrera`, decidida en la tanda, sección 6), el impulso a mitad del giro salía al lado viejo y dejaba el giro pegado, el ataque en carrera sin probar contra algo; corregidos. Falta en el teléfono: reprobar el movimiento en S50 y S20 (sección 12) y la ventana de 4 ticks |
| 5 | Hecha | `validar` 120/0; 109 guiones (`peligro_movil`: la sierra llega al jugador quieto, golpe sin fundido; con la sierra quieta falla). Regla del validador en cualquier escena (entrada `validador-peligro-movil`): en copias, peligro dentro de un `Vaiven`, como raíz y en una escena instanciada da `FALLO`; los peligros fijos actuales no. `revisor`, dos pasadas: la comprobación no cubría la regla, el guion pasaba con la sierra quieta y la sala no tenía el tipo fijo; corregidos |
| 6 | Hecha | `validar` 123/0; 109 guiones (`menu_configuracion` 34 casos). Mutaciones: sin la guarda del Start y `aplicar` sin intercambio, falla. `revisor`, dos pasadas: impulso e interactuar (ejes) se quedaban sin botón al reasignar (fuera de los reasignables), valores inválidos del archivo pasaban al InputMap, asignar Start cerraba el panel, la prueba dependía del `ajustes.json` real, y textos que decían que `herramientas/` no viaja; corregidos. Los tres `CLAUDE.md` y la entrada, ya `paquete-publicacion` con `"pasa": false` hasta probarla con el keystore, los aprobó la persona y entraron en esta fase; el bloque del preset en `chore/android-export` va aparte. Falta: Configuración completa en el teléfono y con control; paquete de publicación con el modo desarrollador |
| 7 | Hecha | `validar` 130/0; 110 guiones (`recursos_cuentas` 15 casos; `menu_configuracion` 35 con la opción Recursos). Mutaciones: detección sin la regla de memoria falla; en una copia, planta 31 y una luz 2D dan dos `FALLO`. `revisor`, dos pasadas: la sala de cuentas aparecía como botón en la zona de pruebas y la fila de medición prometía quitar todas las partículas; corregidos. Plantas y niebla siguen moviéndose en el congelado (decoración por tiempo). Falta en el teléfono: la detección real (paréntesis del automático) y los FPS de la sala de recursos en bajo y alto (al cerrar, 12-oct-2026: medidos en depuración, `recursos-medicion`; queda `recursos-medicion-publicacion`); la cantidad de cortables se decide con esa medición |
| 8 | Hecha | `validar` 146/0; 111 guiones (`mapa_cuentas` 18 casos). Mutaciones: la pausa sin el grupo `pantalla_encima` y la pantalla sin exigir la pluma fallan; en una copia, mover `mapa_2` sin regenerar da `FALLO` del índice y, sin el bloque `mapa/`, el validador corre (solo falla la puerta a la zona quitada). `revisor`, dos pasadas: el caso de la pluma no probaba la pantalla, el validador nombraba `IndiceSalas` y no corría sin el bloque, `nucleo/CLAUDE.md` no nombraba el mapa; corregidos. Falta en el teléfono: la fila «Mapa» de `docs/pruebas.md` (al cerrar, 12-oct-2026: pasa en el S50 y el S20); el dibujo `<id>_mapa.png` no tiene prueba (no hay ninguno) |

