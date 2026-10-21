CERRADO

# Muros rompibles, palancas y portones

Pedido por la persona el 17-oct-2026 («palancas y paredes rompibles»). Estaba en la lista de «después» de las
decisiones del 13 al 15-oct. Aprobado por la persona el 17-oct-2026, con lo recomendado en las cuatro decisiones:
4 golpes, la bola cuenta como un golpe, sin Inspiración y con tapas.

Entradas, agregadas al aprobar:

- en `nucleo/funciones.json`: `muro-rompible` (guion), `palanca-porton` (guion) y `muros-palancas-telefono`
  (manual);
- en `herramientas/funciones.json`: `validador-muros-palancas` (manual con una copia, como
  `validador-pared-tras-puerta`).

## Referencia: Hollow Knight y Silksong

Lectura del 17-oct-2026 de las escenas, prefabs y código de los dos juegos (notas en la carpeta de referencia;
casi todo es lectura nueva).

- **Muro.** Los dos juegos usan la misma máquina de estados, `breakable_wall_v2`.
  - Aguanta 4 golpes en Hollow Knight y 3 en el muro de Silksong que se midió. Cada golpe resta uno, sea cual sea
    el daño (la resta de uno es inferencia).
  - Se rompe con el ataque desde cualquier lado. En Hollow Knight un hechizo o una explosión lo rompen de una vez.
    En Silksong, una zona opcional limita desde dónde se puede romper.
  - Con cada golpe:
    - el muro se sacude 0,1 s hacia donde se le pegó y suena;
    - en Silksong además tiembla la cámara;
    - en Hollow Knight el héroe no rebota contra el muro (inferencia).
  - Al romperse: partículas y escombros, temblor, y el muro desaparece. Se guarda por sala más id; al volver ya no
    está.
  - Lo que había detrás se descubre con un evento a unas «máscaras». Que sean capas que se desvanecen es
    inferencia.
- **Palanca.**
  - Hollow Knight: un golpe del aguijón y el congelado; tras 0,75 s, avisa al pilar que tiene por referencia.
  - Silksong (`Lever`): solo el primer golpe del aguijón cuenta, y luego se bloquea. Tras `openGateDelay` (0,5 a
    1,5 s; lo más común 0,5, 0,75 y 1 s) abre cada portón de su lista.
  - Los dos guardan la palanca y el portón por separado. El portón de Silksong (`Gate`) también puede cerrarse y
    puede empezar abierto.
  - Que un atajo abra solo desde un lado es acomodo de la sala, no del código.
- **Cuál se sigue:** Silksong, más simple. La palanca tiene una lista de portones, cada pieza guarda su propio id y
  el muro admite un lado.

## Qué se hace

- **`Golpeable` aprende a no ser un enemigo.**
  - Hoy cada golpe da Inspiración, emite `Eventos.enemigo_golpeado` y empuja al jugador (`nucleo/jugador.gd:970-980`).
  - Campo nuevo `es_enemigo` (por omisión `true`). Con `false`, el golpe no da Inspiración ni emite
    `enemigo_golpeado`. El rebote del jugador, el pogo y la voltereta siguen igual: pegarle a algo sólido se siente.
  - Toca el jugador, así que lleva revisor.
- **`MuroRompible`** (`nucleo/muro_rompible.gd`, `StaticBody2D`).
  - Sólido con su forma y su dibujo, como `SueloFragil`. Sirve igual como pared, techo o suelo.
  - Lleva un `Golpeable` hijo con `es_enemigo = false` y `velocidad_retroceso = 0`, un poco más grande que el
    sólido para que el ataque lo alcance.
  - `golpes` (por omisión 4) y `solo_desde` (`CUALQUIERA`, `IZQUIERDA`, `DERECHA`, `ARRIBA` o `ABAJO`): un golpe
    que llega por otro lado no cuenta y no hace nada.
  - Con cada golpe que cuenta:
    - se sacude 6 ticks hacia donde se le pegó (solo el dibujo; el sólido no se mueve);
    - pide un temblor corto de cámara, como Silksong;
    - emite `golpeado`.
  - Al romperse:
    - partículas con el mismo recurso de `Cortable` y el temblor más fuerte;
    - la colisión se apaga y el muro desaparece;
    - se marca en el estado de su sala con su `id`, emite `roto` y avisa por `Eventos` (para el sonido).
  - Con id marcado, al entrar a la sala ya no aparece, como `SueloFragil`.
  - `tapas` (`Array[NodePath]`): dibujos que tapan lo de detrás y se desvanecen en 20 ticks al romperse. Ya roto,
    no aparecen.
  - La bola (`Proyectil`) cuenta como un golpe, igual que el ataque (decisión 2).
- **`Porton`** (`nucleo/porton.gd`, `AnimatableBody2D`).
  - Sólido con `id`, `recorrido` (por omisión, su alto hacia arriba) y `ticks_apertura` (30).
  - `abrir()`: se desliza el `recorrido` en esos ticks y queda abierto; se marca en su sala. Abierto al entrar,
    aparece ya abierto.
  - `cerrar()`: para las arenas de jefe del contrato («la arena se cierra con una pared que se quita al vencerlo»);
    no se guarda.
  - `abierto_al_empezar` para un portón que una arena cierra.
- **`Palanca`** (`nucleo/palanca.gd`, `Node2D` con un `Golpeable` hijo con `es_enemigo = false`).
  - Solo el ataque del jugador la mueve (la bola no, como Silksong), con el primer golpe; luego queda activada.
  - Con cada golpe a una palanca activada: el rebote, sin nada más.
  - `portones` (`Array[NodePath]`) y `ticks_retraso` (45 = 0,75 s, el de Hollow Knight). Al activarse:
    - congelado corto (`Congelado`, como el `FreezeMoment` de Hollow Knight; los ticks se fijan al probarlo) y
      temblor;
    - el dibujo cambia de lado;
    - se marca en su sala y, tras el retraso, llama `abrir()` en cada portón.
  - Con id marcado aparece activada. Sus portones guardan lo suyo.
  - Dibujo provisional de caja gris: base y palanca inclinada.
- **Eventos nuevos** en `nucleo/eventos.gd` y en la tabla del contrato: `muro_roto` y `porton_abierto`, para sonido
  y vibración. Sin sonido nuevo por ahora: los pide `Sonido` y, sin efecto en la ficha, no suena, como hoy.
- **Validador**, en las salas con id:
  - cada muro, palanca y portón lleva un `id` único en su sala;
  - cada ruta de `portones` lleva a un `Porton` y cada ruta de `tapas` a un `CanvasItem` de la misma sala;
  - un portón sin palanca ni dueño es válido (una arena lo abre desde código).
- **Sala de prueba «Secretos»** (`herramientas/salas/sala_secretos.tscn`), en la zona de pruebas, categoría Salas.
  Lleva:
  - un muro normal con un cuarto escondido y su tapa;
  - un muro que solo se rompe desde la derecha (atajo de regreso);
  - un techo rompible para probar el golpe hacia arriba;
  - una palanca que abre un portón;
  - una palanca al otro lado de un portón cerrado (atajo de un solo sentido).

  Su fila va a `docs/salas-de-prueba.md`.

## Hitos

1. H1 · `Golpeable.es_enemigo` y su uso en `jugador.gd` y en la onda de la picada.
   - Casos en una prueba nueva `prueba_muros.gd`: golpear algo con `es_enemigo = false` no da Inspiración ni
     emite `enemigo_golpeado` y sí rebota.
   - Además, los guiones del jugador y de combate siguen pasando.
2. H2 · `MuroRompible`. Casos:
   - con 4 golpes se rompe y no antes;
   - el golpe desde el lado que no toca no cuenta;
   - un muro roto se marca, y al volver a crear la sala ya no está;
   - la bola cuenta como un golpe;
   - la tapa desaparece;
   - el pogo sobre un suelo rompible rebota.

   Guion `muro_rompible` y uno que camina y lo rompe en la sala de secretos.
3. H3 · `Porton` y `Palanca`. Casos:
   - la palanca abre su portón tras el retraso, y no antes;
   - el segundo golpe no hace nada;
   - la bola no la mueve;
   - las dos piezas se guardan y vuelven abiertas;
   - `cerrar()` deja el sólido otra vez.

   Guion `palanca_porton`.
4. H4 · Validador, con una copia en el scratchpad que rompa cada regla (como con la pared tras puerta), y
   `docs/contrato.md` («Componentes», «Eventos», «Sala»), `docs/pruebas.md` y `docs/salas-de-prueba.md`.
5. H5 · `validar.ps1`, todos los guiones y el revisor (toca el jugador y el estado guardado de las salas).
6. H6 · Prueba manual de la persona en un teléfono, en la sala de secretos:
   - ¿cuatro golpes se sienten bien o sobran?
   - ¿se nota de dónde sale el muro?
   - ¿el retraso de la palanca se entiende?
   - ¿el portón se ve abrir?

## Decisiones (tomadas el 17-oct-2026: lo recomendado)

1. **Golpes del muro:** 4, como Hollow Knight (recomendado; se ajusta por muro), o 3, como el de Silksong.
2. **La bola contra el muro:** cuenta como un golpe (recomendado: es la única que tienes a distancia), o lo rompe
   de una vez, como el hechizo de Hollow Knight.
3. **Golpear el muro da Inspiración:** no (recomendado; ninguno de los dos juegos la da), o sí.
4. **Las «tapas» que esconden el cuarto de detrás:** dentro de este plan (recomendado: sin ellas el secreto se ve
   antes de romper), o después, con el arte.

## Avance (17-oct-2026)

- H1 a H4 programados. `validar.ps1` en verde; `muro_rompible` (22 casos) y `muro_rompible_caminando` pasan. Con
  una copia en el scratchpad, quitar la revisión de `es_enemigo`, el golpe de la bola al muro o la condición de
  que la palanca solo la mueve el `Jugador` hace fallar la prueba; el validador dio 3 `FALLO` con un muro sin id,
  una tapa a un nodo que no existe y una palanca que apunta a un muro.
- Cambios frente a lo planeado:
  - Evento extra `objeto_golpeado`: un `Golpeable` sin `es_enemigo` lo emite en lugar de `enemigo_golpeado`, para
    que `Sonido` y `Vibracion` traten el golpe igual sin contarlo como enemigo.
  - Un golpe del lado que no cuenta sí rebota al jugador (no «no hace nada»): el rebote es del jugador, no del
    muro, y sin él el muro se sentiría hueco.
  - La onda de la picada también cuenta un golpe al muro y, como viene del `Jugador`, también activa la palanca (sale del código; ningún guion lo cubre).
  - `Jugador.temblar(ticks, px)`: método público para que el muro y la palanca pidan temblor; si ya hay uno más
    fuerte, se queda el que hay.
  - No se hizo la segunda palanca (atajo de un solo sentido): el muro que solo cuenta desde la derecha ya prueba
    ese caso. El guion `palanca_porton` quedó dentro de `muro_rompible` (misma prueba, misma sala).
- H5 hecho el 17-oct: los 143 guiones pasan; el revisor aprobó el código y marcó 6 fallos de documentos, ya
  corregidos. Sin guion: que el portón al cerrarse no atrape al jugador parado debajo.
- Falta H6 (prueba manual en un teléfono).

## Riesgos

- El muro rompible es un sólido nuevo en salas con id. Una sala vieja no cambia: nadie lo usa todavía.
- `es_enemigo` cambia una pieza que usan todos los enemigos. Por omisión queda `true`, y los guiones de combate lo
  cuidan.
- Al deslizarse, el `AnimatableBody2D` empuja lo que tiene encima. Con el portón subiendo, no debería atrapar al
  jugador; si lo atrapa, lo atrapa un guion y se ajusta antes de cerrar.
- 17-oct-2026, la persona en el S50, sala Secretos: los dos muros y la palanca funcionan bien. Del techo frágil y de
  si cuatro golpes son muchos no dijo nada en particular.

- 17-oct-2026: la persona confirma en el S50 que el techo frágil, los muros y la palanca funcionan bien y que cuatro golpes están bien. Plan cerrado.
