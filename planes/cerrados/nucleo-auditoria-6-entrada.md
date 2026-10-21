CERRADO

# Auditoría, paso 6: entrada (T6)

Paso 6 de `nucleo-auditoria-codigo.md`, tanda T6. Ids del anexo R3: E1, E2, E5 y E7 a E11.

## Qué se hace

1. **Consulta:** que los hallazgos sigan vigentes después de los pasos 1 a 5, el diseño de cada pieza y lo que puede
   cambiar el juego.
2. Piezas, una por agente:
   - **Un solo origen de «qué dispositivo se usa»** (E7 a E11): un `enum` y `con_control()`, una sola tabla de nombres
     de botón en `Mando` y la señal `dispositivo_cambiado` en lugar del `_process` de cada `IconoBoton`.
   - **Soltar los dedos** al perder el foco la app y cuando se reutiliza un dedo (E1, E2).
   - **Botones táctiles inactivos mientras hay un menú abierto** (E5). Es un cambio aprobado por la persona el 17-oct:
     hoy, tocar el botón de Pausa encima de la Configuración la cierra.

## Hitos

1. `validar.ps1` → `fallos=0`; `correr-guiones.ps1` → `MALOS=0`. Ningún `.esperado` cambia, salvo por E5 y con su
   porqué.
2. Lo que solo se ve en el teléfono queda para el paso 11, por adb. Por ejemplo, soltar el dedo con la app en segundo
   plano.
3. Revisor: toca la entrada, que leen el jugador y todos los menús.

## Consulta (18-oct, agente investigador)

Los ocho hallazgos siguen vigentes tras los pasos 1 a 5. Piezas, en este orden:

1. **E2 + E1** (`controles_tactiles.gd`): `_notification` suelta todo con `WM_WINDOW_FOCUS_OUT`,
   `APPLICATION_FOCUS_OUT` y `APPLICATION_PAUSED`; `_tocar` suelta antes el dedo si su índice ya estaba registrado;
   un `ScreenTouch` con `canceled` suelta. Casos en `prueba_tactil.gd`. No cambia el juego.
2. **E5**: con `get_tree().paused` (lo ponen los cuatro menús y nadie más) se ignora solo el `pressed=true`; soltar
   y arrastrar siguen. Al detenerse el árbol, `_soltar_todo()`. Los botones se siguen dibujando. Línea nueva en el
   contrato. (La consulta proponía bloquear también Pausa y Mapa; la persona lo cambió el 18-oct: ver «Avance».)
3. **E9 + E8**: `enum Mando.Dispositivo`, `UltimaEntrada.con_control()` derivado de `dispositivo`, `clasificar()`
   pura (la usan `anotar` y `ControlesTactiles.procesar`, y desaparecen los literales) y caché de familia por
   `device`, vaciada con `joy_connection_changed`, que se conecta siempre.
4. **E7**: una tabla `Mando.BOTONES` con columnas neutro, xbox y playstation. Los textos visibles no cambian.
5. **E11**: señales `dispositivo_cambiado` y `mando_cambiado` en `Eventos`, sin el `_process` de `IconoBoton`
   (conecta en `_enter_tree`, que también refresca). `mando_cambiado` se emite una vez por operación. Contrato
   «Entrada» al día.
6. **E10**: las dos reglas («tecla marca TECLADO» y «`_es_de_juego`») se extraen con nombre, sin unificarlas.
   Unificarlas cambia el juego (Atrás o el volumen dejarían de mostrar el foco): queda como decisión de la persona.

Solo se comprueba en el teléfono (paso 11): qué manda Android con un dedo apoyado al ir a segundo plano; que con un
menú abierto Saltar y el joystick no hacen nada, que Pausa y Mapa siguen cerrando su menú (Pausa en Configuración
vuelve un nivel) y que tienda y estaciones se cierran también con su Volver en pantalla.

## Avance

- 18-oct, pieza 1 (E2 + E1), hecha por un agente:
  - `controles_tactiles.gd`:
    - nuevo `_notification`, que suelta todo con las tres notificaciones;
    - `_tocar` empieza con `_soltar(dedo)`;
    - `procesar` suelta también con `canceled`.
  - `prueba_tactil.gd` pasa de 36 a 45 casos (`controles_tactiles.esperado`); `docs/pruebas.md` y el contrato,
    «Entrada», al día.
  - Archivos nuevos: `docs/errores/2026-10-18-dedos-colgados.md` y la entrada `soltar-dedos-al-perder-foco`.
  - Mutaciones, en la copia:
    - sin el `_soltar` previo: fallan 4 casos;
    - sin `_notification`: fallan 3.
  - `not toque.canceled` se queda como defensa, aunque hoy no haga falta. Una sonda en 4.7.2 mostró que
    `canceled = true` deja `pressed = false`, así que sin esa condición la prueba también pasa. Lo dicen el
    comentario y el archivo de error.
  - Resultados: `validar.ps1` → `OK  VALIDACION archivos=248 fallos=0`; `correr-guiones.ps1` → `RESUMEN total=151
    OK=151 MALOS=0`. La sesión principal lo comprobó otra vez con `controles_tactiles`: `OK=1`.
- 18-oct, pieza 2 (E5), primera versión, hecha por un agente: con el árbol pausado, ningún toque nuevo presiona nada.
  Al abrir un menú se suelta todo. `prueba_tactil` pasa de 45 a 50 casos y `controles_tactiles.guion` va con `fin 40`.
  Resultados: `validar` → `fallos=0`; `correr-guiones` → `151 OK`.
- **18-oct, decisión de la persona:** con un menú abierto, Pausa y Mapa siguen cerrando su menú, como hoy, y Pausa
  encima de Configuración vuelve un nivel. Solo Saltar, Atacar, Curar, Impulso y el joystick quedan sin responder.
  Así nadie queda atrapado en un menú, y lo que se ve casi no cambia: esos botones hoy no hacen nada visible encima
  de un menú. Se ajusta la primera versión.
- 18-oct, ajuste de E5 por un agente:
  - `BOTONES_DE_MENU = [&"pausa", &"mapa"]` filtra por botón y no por acción. Por eso el botón Mapa sentado, que
    manda `inventario`, también cierra.
  - Con menú abierto, el joystick no toma dedos.
  - `_soltar_todo` al abrir un menú se queda: los menús solo leen `just_pressed`, así que soltar no abre ni cierra
    nada. Lo único visible es que se apaga el círculo de «presionado» bajo el dedo que abrió el menú.
  - `prueba_tactil` pasa a 53 casos. La fila manual de `docs/pruebas.md` y «Conversación» del contrato vuelven al
    texto de `HEAD`.
  - Mutaciones:
    - sin el filtro, falla el caso de Saltar;
    - Pausa fuera de la lista, falla el caso de Pausa;
    - sin `_soltar_todo`, fallan 2.
  - Resultados: `validar` → `OK  VALIDACION archivos=248 fallos=0`; `correr-guiones` → `RESUMEN total=151 OK=151
    MALOS=0`. La sesión principal lo comprobó otra vez con `controles_tactiles`, `pausa` y `marco`: `OK=3`.
- 18-oct, pieza 3 (E8 + E9), hecha por un agente.
  - **Invariante:** antes de cambiar nada se leyó que `con_control == (dispositivo != TOQUE)` se cumple en todas
    las rutas.
  - **`Mando`:**
    - `enum Dispositivo`, puesto en `Mando` y no en `UltimaEntrada` porque la dependencia va de `UltimaEntrada`
      a `Mando`;
    - `familia()` devuelve ese enum.
  - **`UltimaEntrada`:**
    - `con_control()` se deriva de `dispositivo`;
    - `clasificar()` es pura y devuelve `SIN_CAMBIO = -1` cuando el evento no cambia nada;
    - caché `_familias` por `device`, que `joy_connection_changed` vacía. Esa señal ahora se conecta siempre; lo de
      depuración sigue igual.
  - **`ControlesTactiles.procesar`:** usa `clasificar` en lugar de los literales. `_es_dedo` cuenta `TOQUE` y
    `SIN_CAMBIO`, así que levantar un dedo sigue mostrando los controles, como hoy.
  - **E10:** no se unificó.
  - **Pruebas:** `icono_boton` pasa de 20 a 30 casos (`clasificar` y la caché) y `controles_tactiles` de 53 a 54.
  - **Mutaciones:**
    - sin vaciar la caché, falla 1;
    - `clasificar` con TECLADO para un botón, fallan 2;
    - `_es_dedo` sin `SIN_CAMBIO`, falla 1.
  - **Resultados:**
    - `validar` → `OK  VALIDACION archivos=248 fallos=0`;
    - `correr-guiones` → `RESUMEN total=151 OK=151 MALOS=0`;
    - la sesión principal corrió otra vez `icono_boton`, `controles_tactiles`, `menu_configuracion` y `pausa_foco`:
      `OK=4`.
  - La persona aprobó el 18-oct el cambio de `.claude/skills/ui-tactil/SKILL.md:26`: `UltimaEntrada.con_control`
    pasa a `con_control()`. Ya está escrito.
- 18-oct, pieza 4 (E7), hecha por un agente.
  - **`Mando.BOTONES`** (`Array[Array]`): 15 filas con columnas neutro, Xbox y PlayStation. En los cuatro botones
    de la cara (`CARA`), la columna Xbox es la letra y la de PlayStation el símbolo.
  - **Funciones nuevas:** `nombre_en(boton, familia)` y `nombre_de_eje(eje, familia)`, que se mudó desde
    `IconoBoton`. Se borran las tablas de `IconoBoton`.
  - **Pruebas:** `prueba_icono_boton` pasa de 30 a 54 casos. Compara contra los textos capturados antes del cambio
    (scratchpad `e7\antes.txt`).
  - **Trampa del motor:** una constante `Array[PackedStringArray]` no compila. Si las filas van sin tipo, leerlas
    como `PackedStringArray` da `""` sin error. Se dejó un comentario sobre la constante.
  - **Mutaciones:**
    - Share → Select: falla 1;
    - L2 → LT: falla 1;
    - cruz → equis: fallan 2.
  - **Resultados:**
    - `validar` → `OK  VALIDACION archivos=248 fallos=0`;
    - `correr-guiones` → `RESUMEN total=151 OK=151 MALOS=0`;
    - la sesión principal corrió otra vez `icono_boton`, `menu_configuracion` y `controles_configurables`: `OK=3`.
- 18-oct, pieza 5 (E11), hecha por un agente.
  - **Señales:**
    - el bus gana `dispositivo_cambiado` y `mando_cambiado`;
    - `UltimaEntrada.dispositivo` tiene un setter que emite solo si el valor cambia;
    - `Mando.asignar`, `aplicar` y `por_omision` avisan una sola vez y solo si `cambios` subió.
  - **`IconoBoton`:** sin `_process` ni `PROCESS_MODE_ALWAYS`. Conecta en `_enter_tree` y desconecta en `_exit_tree`.
  - **Decisión de la sesión principal: emitir con `Mando.bus()`** (busca `Eventos` en el árbol, o `null`) y
    `emit_signal`, no con `Eventos.x.emit()`.
    - Por qué: un script estático que nombra el autoload no compila sin autoloads (sonda con `-s`) y arrastra a
      `Ajustes`.
    - Lo que se pierde: la emisión con tipo, que queda dicho en el contrato.
  - **Decisión de la sesión principal: los dos refrescos se quedan**, el de `_enter_tree` y el de `THEME_CHANGED`.
    - Por qué: `THEME_CHANGED` ya llega al entrar al árbol (`class_control.rst:1351`, `:1355`), así que quitar uno
      solo no hace fallar nada. Dejar los dos no depende de ese detalle del motor y cuesta un refresco.
  - **Pruebas:** `prueba_icono_boton` pasa de 54 a 64 casos y `bus_eventos.esperado` cuenta las dos señales en 0. Si
    alguien corre ese guion con un control conectado y mueve un stick, `dispositivo_cambiado` daría más de 0. En el
    CI no pasa.
  - **Mutaciones:**
    - sin los dos refrescos: falla 1;
    - `mando_cambiado` en cada `_poner`: fallan 4;
    - sin conectar: fallan 5.
  - **Resultados:** `validar` → `OK  VALIDACION archivos=248 fallos=0`; `correr-guiones` → `RESUMEN total=151 OK=151
    MALOS=0`. Falta el revisor, que se hace al cerrar el paso, porque toca el bus.
- 18-oct, pieza 6 (E10), hecha por un agente: dos funciones con nombre en `UltimaEntrada`, `marca_teclado` y
  `es_de_juego`, sin unificarlas. `_es_de_juego` y su caché se mudan desde `ControlesTactiles`.
  - **Medición, en una sonda:** en un eje, `is_pressed()` da true solo desde 0,5, así que el desacuerdo entre 0,2 y
    0,5 que suponía la consulta no existe.
  - **Desacuerdo real:** hay entradas que cambian el dispositivo pero no ocultan los controles táctiles:
    - volumen, Atrás y Enter;
    - L3, R3 y Guía;
    - LT y el stick derecho a 0,5 o más.
  - **Pruebas:** `prueba_icono_boton` pasa de 64 a 68 casos.
  - **Mutaciones:**
    - `es_de_juego` acepta `ui_*`: falla 1;
    - las dos reglas unificadas: fallan 7, lo que muestra que unificarlas sí se nota.
  - **Resultados:** `validar` → `OK  VALIDACION archivos=248 fallos=0`; `correr-guiones` → `RESUMEN total=151 OK=151
    MALOS=0`.
  - **Abierto para la persona:** si se unifican las dos reglas, y si LT o el stick derecho sin acción deberían ocultar
    los controles táctiles.
- **18-oct, revisor del paso: un fallo, de documentación.** Lo demás está comprobado sin hallazgos:
  - no queda ningún texto viejo ni `con_control` sin paréntesis;
  - `BOTONES` es igual a `HEAD`, celda por celda;
  - E5 sigue la decisión;
  - el bus tiene 28 señales.

  Resultados: `validar` → `fallos=0`; `correr-guiones` → `151 OK`.
  - **El fallo:** el contrato, `mando.gd` y `funciones.json` decían que `mando_cambiado` sale «si cambió algún
    botón», pero sale si se *puso* alguno, aunque sea el mismo.
    - **Decisión de la sesión principal:** corregir el texto y no el código.
    - **Por qué:** el sondeo de antes refrescaba con el mismo contador, así que el juego no cambia, y una emisión de
      más solo cuesta un refresco.
    - Después de corregirlo: `validar` → `fallos=0`; `icono_boton` y `bus_eventos` → `OK=2`.
  - **Al paso 13:** ninguna prueba cambia el dispositivo con el árbol pausado. Por lectura, `IconoBoton` se refresca
    igual, porque la señal llama al método directamente.
  - **A confirmar con la persona:** como se mantiene `_soltar_todo` al abrir un menú, un dedo que se queda apoyado en
    Saltar mientras se abre un menú ya no sigue presionado al cerrarlo. En `HEAD` sí seguía.
  - **Se dejan con el nombre viejo, como registro:**
    - el `que` de una entrada antigua de `nucleo/funciones.json`;
    - `docs/errores/2026-10-17-controles-tactiles-con-control.md`.
