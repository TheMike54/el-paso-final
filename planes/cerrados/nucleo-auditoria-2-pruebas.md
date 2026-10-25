CERRADO

# Auditoría, paso 2: la red de pruebas

Paso 2 de `nucleo-auditoria-codigo.md`. Ids del anexo (R6): H4, H14, H15, H16 y H20, más H25 replanteado y aprobado
por la persona el 17-oct-2026: las pruebas de código salen del APK de publicación y las salas jugables se quedan.
Va antes de los refactores, para que las pruebas no se rompan con ellos. El juego no cambia.

## Qué se hace (una pieza por agente, en este orden)

1. **Las pruebas de código, a su carpeta** (H25, H15).
   - Antes, una consulta: cómo mover 32 escenas y sus scripts sin abrir el editor a mano y sin romper `uid` ni rutas
     (`tutorials/scripting/filesystem.rst`).
   - Las escenas `sala_*.tscn` con script `prueba_*.gd`, más `prueba_base.gd` y lo que solo ellas usan, pasan a
     `herramientas/pruebas/`. Las salas de `GRUPOS` y `OCULTAS` que se juegan se quedan en `herramientas/salas/`.
   - Al mover se actualizan:
     - las rutas en los guiones;
     - `OCULTAS`, que se queda solo con lo jugable que no se lista;
     - el validador.
   - Una regla nueva del validador: nada fuera de `herramientas/pruebas/` nombra algo de dentro.
   - El preset «Publicacion» excluye `herramientas/pruebas/*`, `herramientas/validar.*`,
     `herramientas/generar_mapa.*` y `herramientas/puerto_depuracion.*`, además de `*funciones.json`.
   - Se pone al día «Paquete de publicación» en `docs/contrato.md` y `docs/salas-de-prueba.md`.
   - El texto nuevo de los `CLAUDE.md` (raíz y `herramientas/`) lo prepara el agente en el scratchpad, la persona lo
     ve y solo después se escribe.
   - Comprobación: exportar el APK de publicación sin firma, o listar lo que exporta, para ver que no lleva
     `herramientas/pruebas/` y sí la zona; después, la zona en el teléfono por adb.
2. **Correr todos los guiones desde el repo** (H14). `herramientas/correr-guiones.ps1` sustituye al script del
   scratchpad:
   - ASCII y compatible con 5.1 y 7;
   - imprime solo los que fallan y `RESUMEN total=N OK=N MALOS=N`;
   - acepta una lista de guiones sueltos.

   Se nombra en el `CLAUDE.md` raíz («Comandos»): ese texto también se le muestra a la persona.
3. **Leer el estado a mitad del guion** (H4).
   - El `.esperado` acepta una línea opcional `en <cuadro> <clave> ...`, que se lee al empezar ese cuadro; lo procesa
     `puerto_depuracion.gd`.
   - Un guion existente pasa a usarla donde hoy solo se ve el final, por ejemplo uno de curar o de parry.
   - Se pone al día `docs/guiones.md`.
4. **Aislar y restaurar la partida en la base** (H16).
   - `_aislar_partida()` y `_restaurar_partida()` en `prueba_base.gd` sustituyen las seis copias.
   - Las variantes de diálogo y reto, que no borran el `.tmp`, quedan iguales o se corrigen si era un descuido. Si es
     un descuido, se anota.
5. **Pruebas que leen internos** (H20). Primero se consulta qué conviene en cada prueba:
   - `prueba_aterrizaje` (21 accesos con `_`);
   - `menu_configuracion`, `recursos`, `combate_chico`, `guardado`, `mapa` y `muros`.

   Lo que leen pasa a una lectura pública mínima o a un guion. No se agrega API pública al juego solo para una prueba
   si un guion lo mide igual.

## Hitos

1. Cada pieza: `.\herramientas\validar.ps1` → `OK  VALIDACION ... fallos=0`, y todos los guiones en verde. Ningún
   `.esperado` cambia, salvo por rutas (pieza 1) o por la cuenta de `casos`, con el porqué escrito aquí.
2. Pieza 1: lista del APK de publicación sin `herramientas/pruebas/`, y la zona de pruebas abierta en el S50 o el
   S21.
3. Pieza 5: con un renombre de prueba de una variable interna del jugador en la copia del scratchpad, no se rompe
   ninguna prueba que no debería.
4. Revisor al final del paso: toca el CI o los hooks solo si cambia `ci.yml`.

## Riesgos

- Mover escenas fuera del editor rompe rutas que no estén por `uid`. Lo atrapan el validador y los guiones, pero
  hay que mirar también `.godot/` (caché) y `export_presets.cfg`.
- El CI corre los guiones con su propio bucle (`ci.yml`): si cambian las rutas, se revisa también.

## Avance

- **17-oct, consulta H20 (pruebas que leen internos), con la decisión de la sesión principal.**
  - Hay 43 accesos privados en 9 pruebas, más `prueba_moviles:86` y `_ticks_atacando` en 2 `.esperado`.
  - **Lote A** (antes del paso 9): `prueba_aterrizaje` y `prueba_peligro_anti_bucle`.
    - Se quedan `_empezar_aterrizaje_duro`, `_aterrizar`, `_en_suelo_antes` y `_ticks_a_tope`: son la pieza bajo
      prueba, y T7 no las mueve.
    - Lo demás pasa a lo público: un `Jugador` nuevo por caso, esperas con las constantes de `Fundido` y
      `velocity.y` para el retroceso.
    - Se borra el reinicio del temblor.
  - **Lote B:**
    - `prueba_muros` usa `cuenta_desde`;
    - `prueba_combate_chico` mide `Congelado.activo()` en el tiempo;
    - `prueba_estado_sala` emite `body_entered`;
    - `prueba_mapa` deja de repetir la fórmula: comprueba que el punto cae dentro del lienzo.
  - **Lote C:**
    - `prueba_menu_configuracion` toca la fila por su `IconoBoton`;
    - `prueba_recursos` espera `process_frame`;
    - `Volador.despertar()` en `herramientas/salas/comportamientos/`.
  - **Lecturas públicas nuevas en el juego:** `IconoBoton.dibujo_actual` y `Jugador.atacando` (`bool`, como
    `aterrizando`). La segunda sustituye a `_ticks_atacando` en los dos `.esperado`, que sí cambian: es la única
    excepción, y se debe al cambio de nombre.
  - **Se deja:** `Ajustes._cargados` en `prueba_guardado`, con un comentario.
  - **`temblor_x` y `temblor_y`:** los leen 8 guiones de cámara. Se decide en el paso 9; lo recomendado es que el
    `Jugador` los conserve y los pida a la cámara.

- **17-oct, consulta para mover las pruebas** (agente investigador).
  - **Qué se mueve:** 32 escenas, que son `OCULTAS` sin `zona_pruebas.tscn` ni `sala_puerta_b.tscn`; sus 32
    `prueba_*.gd` con su `.uid`; y `prueba_base.gd`. Nada jugable las usa.
  - **Se quedan:** `vida_menos_prueba.gd`, `medidor_camara.gd`, `franjas.gd`, `interruptor_brujula.gd`,
    `comportamientos/`, `fichas/`, `zonas/` y `arte/`, porque las usan salas jugables.
  - **Los uid no protegen las rutas.**
    - 28 de las 32 escenas nombran su script solo por ruta.
    - Las 4 con `uid` cargarían con la ruta vieja sin avisar.
    - Por eso las rutas se reescriben con un script, y la verificación es un Grep de rutas viejas, no el validador.
  - **`exclude_filter`:** patrones separados por coma, sin `res://`, y `*` cruza `/`. Viene del código del motor
    resumido por WebFetch; la documentación 4.7 no lo define.
  - **Cómo comprobar el paquete:** `--export-pack "Publicacion" x.zip` y listar el zip. Los scripts salen como `.gdc`
    y las escenas como `.remap`, así que se compara por carpeta.
  - **Dato nuevo:** en esta rama `export_presets.cfg` solo tiene «Publicacion». «Desarrollo» vive en
    `chore/android-export`, que aún no se fusiona. El filtro nuevo se pone aquí. Al hacer el rebase de esa rama, el
    `exclude_filter` de «Publicacion» va a chocar: se resuelve quedándose con el nuevo. Excluir
    `puerto_depuracion.*` solo de «Publicacion» no afecta a «Desarrollo».
- **17-oct, pieza 1 hecha** (falta la prueba en el teléfono).
  - Se movieron 98 archivos a `herramientas/pruebas/`: 32 escenas, 33 scripts y sus `.uid`. Un script reescribió 161
    líneas de rutas: lo movido, los guiones, `docs/pruebas.md`, `docs/guiones.md` y un error del 17-oct.
  - `OCULTAS` quedó con la zona y Puerta B. En los `.esperado` solo cambiaron rutas: la línea `escena` y los
    comentarios.
  - Regla nueva `validador-pruebas-aparte`: atrapa la ruta y también el `uid://` de lo de dentro, y revisa
    `project.godot`. Probada en una copia: fallos 0 → 2 → 0.
  - `--export-pack "Publicacion"`: las entradas bajo `herramientas/` bajan de 195 a 89. No quedan `pruebas/`,
    `validar`, `generar_mapa` ni puerto. Siguen las 38 salas de `GRUPOS`, Puerta B, `zonas/`, `fichas/`,
    `comportamientos/` y `arte/`.
  - Validador 248/0 y 151/151 guiones, antes y después.
  - Texto de los `CLAUDE.md` y de `Explore.md`: propuesto en el scratchpad, sin escribir.
- **17-oct, pieza 2 hecha.**
  - `herramientas/correr-guiones.ps1`, entrada `correr-guiones-local`, y `docs/guiones.md` al día.
  - **Criterio del CI:** cuenta como bien la salida con `GUION OK` y sin `SCRIPT ERROR` ni `ERROR:`, comparando
    con mayúsculas como `grep`. El script viejo del scratchpad pedía salida 0 y no miraba los `SCRIPT ERROR`: un
    error después del resumen pasaba por bueno.
  - **En serie:** las pruebas comparten `user://`, por ejemplo `Partida.RUTA_PRUEBAS` y `ajustes.json`. Los 151
    tardan 157 s.
  - 151/151 en 5.1 y en 7. En una copia, un `.esperado` roto y un `SCRIPT ERROR` salen como MALO y la salida es 1.
  - Texto de los `CLAUDE.md`: propuesto en el scratchpad, sin escribir.
- **17-oct, pieza 3 hecha.**
  - `puerto_depuracion.gd`: línea `en <cuadro> <línea>` en el `.esperado`, leída al empezar ese cuadro. Va en el
    `.esperado` y no en el `.guion`: el `.guion` solo describe entradas y el `.esperado`, estado. Ninguna línea
    existente cambia de significado.
- **17-oct, pieza 4 hecha.**
  - `prueba_base.gd`: `_aislar_partida(ruta = Partida.RUTA_PRUEBAS)` y `_restaurar_partida()`. El orden de las
    copias se conserva: partida nueva con la ruta de prueba puesta, después la ruta de antes, después borrar el
    archivo y su `.tmp`.
  - **No eran seis copias, eran trece.** Nueve guardaban la ruta de antes: `amuletos`, `dialogo`, `estaciones`,
    `lo_perdido`, `marco`, `moviles`, `muros`, `reto` y `tienda`. `combate_chico` y `estado_sala` devolvían siempre
    `Partida.RUTA_PRUEBAS`, y `mapa` no devolvía la ruta. `guardado` aísla solo un tramo; su `_borrar()` del
    principio y del final se queda, porque escribe `RUTA` directo con `Guardado`. Las trece usan ahora los ayudantes.
  - Fuera: `ranuras` (sus archivos con `FORMATO` y `VIEJA`, y `Guardado.borrar` por la copia) y `recursos` (ajustes).
  - **El `.tmp` de diálogo y reto era un descuido.** `amuletos`, `moviles` y `muros` tampoco lo borraban.
    `Archivo.escribir_atomico` escribe `<ruta>.tmp` y lo renombra, así que solo queda si una escritura se corta. La
    versión común lo borra.
  - El arreglo de `mapa` no se notaba porque cada guion es un proceso nuevo.
  - Validador 248/0 y 151/151 guiones; ningún `.esperado` cambió.
  - En `user://` quedan, después de una corrida completa, los mismos archivos antes y después del cambio:
    `ajustes.json` (sin tocar), `prueba_banco.json` y `prueba_zona.json`.
  - Un cuadro fuera de 1..fin-1 o una línea que no se entiende hacen fallar el guion al cargar. El fallo lleva
    delante `en <cuadro>`.
  - Las líneas `senal` de la misma señal comparten una conexión y una cuenta. Antes, dos líneas de la misma señal
    imprimían `ERROR: ... already connected`, que hace malo al guion; con `en` ese caso se vuelve normal. Está en
    `docs/errores/2026-10-17-senal-repetida-en-esperado.md`.
  - `jugador_curar_atacar.esperado`: en 171 el ataque está encendido y aún no cura; en 172 cura y el ataque se
    apagó. Medido con una corrida. Las dos líneas finales siguen iguales; ningún otro `.esperado` cambia.
  - Entrada `guion-estado-intermedio`. Fila de `puerto_depuracion.gd` en `herramientas/CLAUDE.md` («al final»):
    texto propuesto en el scratchpad, sin escribir.
- **17-oct, pieza 5, lote A hecho** (`prueba_aterrizaje` y `prueba_peligro_anti_bucle`; el juego no cambió).
  - Quedan solo `_empezar_aterrizaje_duro`, `_aterrizar`, `_en_suelo_antes` y `_ticks_a_tope` (Grep de `\._[a-z]`),
    con un comentario de por qué. Fuera el reinicio del temblor.
  - `prueba_aterrizaje`: un `Jugador` nuevo por caso (`_jugador_nuevo`, con `Partida.llenar_vidas()` y
    `Congelado.reiniciar()`); salvo los dos casos del anti-bucle, que siguen al peligro anterior y esperan
    `ticks_reaparicion_peligro + 2`. El golpe del mismo tick se ve con `velocity.y < 0.0`: `recibir_dano` lo pone a
    `-retroceso.y` junto con el retroceso y `_aterrizar` no toca `velocity`.
  - Las dos pruebas esperan el fundido con `Fundido.TICKS_OSCURECER + Fundido.TICKS_EN_NEGRO_PELIGRO` (27), sin +1.
    Medido con una sonda: desde una espera, el contador del jugador queda en 0. Desde `_ready`, que corre fuera de
    un tick, quedaba en 1. Por eso `prueba_aterrizaje` empieza con una espera de un tick.
  - Durante las esperas: en el fundido y en la reaparición el jugador no se mueve; en los 2 ticks con control cae
    0,67 px. No afecta a ningún caso: tras cada fundido la posición es exactamente `PUNTO`.
  - `_ready` pasa a corrutina y termina hacia el cuadro 78 (77 medido sin la espera inicial): en `aterrizaje.guion` solo cambió `fin 2` → `fin 120`.
    Ningún `.esperado` cambió.
  - Cinco mutaciones de `nucleo/jugador.gd` en la copia: la prueba vieja y la nueva fallan en el mismo caso con
    cada una. Las mutaciones: el golpe, el banco o la reaparición no cortan el bloqueo; `_aterrizar` sin
    `_ticks_retrocediendo == 0`; el anti-bucle no cambia el punto seguro.
  - Hito 3, para este lote: en la copia se renombraron `_ticks_sin_dano`, `_ticks_retrocediendo`,
    `_ticks_congelado`, `_reapareciendo`, `_ticks_hasta_reaparecer` y `_ticks_temblando`. Las pruebas viejas ya
    no compilan (`Parse Error`); las nuevas dan 10/0 y 11/0.
  - Validador 248/0 y 151/151 guiones.
- **17-oct, pieza 5, lotes B y C hechos.** El juego solo gana tres lecturas: `Jugador.atacando`,
  `IconoBoton.dibujo_actual` (una copia de `_dibujo`) y `despertar()` del volador de pruebas.
  - `prueba_muros`: el techo de la sala cuenta desde cualquier lado, así que `cuenta_desde` daría siempre `true`. El
    caso lo limita un momento a `ABAJO`: cuenta desde (2400, 1160) y no desde (2400, 760). Después lo vuelve a
    `CUALQUIERA` para el pogo.
  - `prueba_combate_chico`: `pedir(10); pedir(2)`, activo a los 5 ticks e inactivo a los 12, en un solo caso.
  - `prueba_recursos`: `await get_tree().process_frame` en lugar de llamar a `_process`. Con `--fixed-fps 60` basta
    uno: con dos y con uno pasa igual, medido. Tras un `await` la prueba sigue antes del `_process` de ese cuadro.
  - **Cambian dos `fin`:** `combate_chico_cuentas.guion` y `recursos_cuentas.guion` pasan de `fin 2` a `fin 30`,
    porque `_ready` pasa a corrutina.
  - **Cambian dos `.esperado`:** `carrera_ataque_recarga` y `habilidad_caida_en_picada_ataque` cambian
    `_ticks_atacando 0` por `atacando false`. Ningún `casos N` cambió.
  - `prueba_mapa`: la mochila cae dentro de `Rect2(0, 0, lienzo.size)` y en su mitad derecha, porque mapa_2 está a la
    derecha de mapa_1. Medido: `lienzo.size` vale (1280, 1140) y el punto (843, 535).
  - `prueba_estado_sala` emite `body_entered`. `prueba_menu_configuracion` toca la fila con `_tocar_fila`.
  - `Ajustes._cargados` se queda en `prueba_guardado`, con un comentario.
  - **Mutaciones en la copia** (`h20bc/mutar.py` del scratchpad). La vieja y la nueva fallan en el mismo caso con:
    `_lado_de` con arriba y abajo cambiados; `pedir` sin `maxi`; `IconoBoton` sin recalcular al cambiar `Mando`;
    `Planta` sin mirar el congelado; `_cortar_ataque` sin apagar el ataque, que en el `.esperado` nuevo sale como
    `atacando esperado=false obtenido=true`.
  - Dos mutaciones solo las atrapa la nueva: el coleccionable sin conectar `body_entered` (8 fallos) y la fila del
    control sin conectar `pressed` (10 fallos).
  - **Hito 3 de este lote:** en la copia se renombraron los nueve internos que leían las pruebas viejas. Las viejas
    fallan: cinco por `Parse Error` o `Invalid call`, `moviles` en el tope y los dos `.esperado` en `<null>`. Las
    nuevas pasan.
  - Quedan con `_` en `herramientas/pruebas/` (Grep de `\._[a-z]`): los cuatro del lote A y `Ajustes._cargados`. En
    los `.esperado` no queda ninguna clave privada.
  - Validador 248/0 y 151/151 guiones.
  - `atacando` va también en `docs/jugador.md` y `docs/pruebas.md`; `dibujo_actual`, en `docs/contrato.md`.

- **17-oct, revisor del paso 2: aprobado con un fallo de evidencia, ya corregido.**
  - La comprobación de `validador-pruebas-aparte` no aislaba la rama del uid. El revisor la probó aparte con un
    script que nombra solo el uid: da `fallos=2`. La comprobación ya lo dice.
  - Se cubrió el arreglo de la señal repetida: `nucleo/banco.esperado` suma dos líneas `en 300`, y el guion pasa.
  - La sesión principal verificó: `validar` da `fallos=0` y los guiones `RESUMEN total=151 OK=151 MALOS=0`.
  - El APK de publicación se exportó en modo depuración (`--export-debug "Publicacion"`):
    - no lleva `herramientas/pruebas/`, validar, puerto ni generar_mapa;
    - sí lleva la zona (4 entradas) y 33 `salas/sala_*.tscn`.
  - **Queda pendiente:** abrir la zona en un teléfono. Ninguno estaba conectado por adb. Pasa al paso 11, junto con
    las demás pruebas por adb.
  - La fila de los guiones en `herramientas/CLAUDE.md` todavía no menciona las líneas `en`. Espera el OK de la
    persona.
- Paso cerrado el 17-oct-2026.