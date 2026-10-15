CERRADO

# Núcleo: marco Inventario · Amuletos · Mapa, pausa con Configuración y Configuración sin interruptores

La persona lo decidió el 13-oct-2026 (detalle en `ESTADO.md`, «Decisiones de la persona»), después de revisar
videos de Hollow Knight y Silksong y un mockup con propuestas: para Configuración la F, para el volumen la A y para
el brillo la 1 con el cuadro de calibración de la 2. Toca la entrada, la pausa, dos pantallas que ya existen y el
bloque `mapa/`, así que va con el `revisor` al final.

## Decisiones

Lo marcado «(propuesta)» lo propuso Claude; la persona aprobó el plan entero con esas propuestas, las funciones
nuevas y las reescrituras el 13-oct-2026.

### Marco de páginas
- Un marco (`nucleo/marco_menus.gd`) con tres páginas en ciclo: Inventario · Amuletos · Mapa. Lo crea cada sala,
  como hoy crea Amuletos y carga Mapa con `load()`; `nucleo/` nunca hace `preload` de nada de `mapa/`.
  Arriba, el nombre de la página actual y los de sus vecinas a los lados; tocar una vecina o su flecha cambia de
  página. (propuesta) Con control y teclado, acciones nuevas `pagina_anterior` y `pagina_siguiente`: LB y RB, Z y
  C. LB ya es `mapa_rapido`, pero con el marco abierto el juego está detenido y el mapa rápido no responde; Q es
  `curar` y por eso no se usa.
- El juego se detiene mientras el marco está abierto, como hoy el mapa y los amuletos. La pausa no se abre encima.
  `pausa`, Atrás y la misma acción que lo abrió lo cierran.
- Interfaz de página sin depender de clases: cada página está en el grupo `pagina_marco` y ofrece
  `titulo_pagina() -> String`, `mostrar_en_marco()` y `ocultar_de_marco()`. El marco busca las páginas que creó
  la sala. Si `mapa/` no existe, el ciclo queda Inventario · Amuletos y el juego corre igual.
- `PantallaAmuletos` pasa a ser la página Amuletos. Pierde su apertura propia: ya no se abre desde la pausa. La
  regla no cambia: de pie se ven sin responder, con «Siéntate en un banco para cambiarlos.»
- `PantallaMapa` (bloque `mapa/`) implementa la interfaz de página. El mapa rápido (`mapa_rapido` mantenida) no
  cambia y sigue fuera del marco. Los botones + y − del mapa siguen dentro de su página.
- Página Inventario nueva (`nucleo/pagina_inventario.gd`): solo lo que ya existe en `Partida`. Corazones,
  Inspiración, PejeCoins, habilidades, mapas y lo perdido al morir (sala y monto, o «Nada perdido»). Solo se lee.
  No hay objetos: un inventario de objetos subiría el guardado a la versión 4.

### Entrada
- La acción `mochila` se renombra `inventario` en `project.godot`, `Mando.REASIGNABLES` y los nombres de
  Configuración. Migración: al leer los ajustes, si el bloque `mando` trae `mochila`, su botón pasa a
  `inventario`. La versión de los ajustes no cambia. El campo `mochila` del guardado (lo perdido al morir) no se
  toca.
- `mapa` abre el marco en Mapa. `inventario` lo abre en Amuletos sentado en un banco y, (propuesta) de pie, en
  Inventario.
- Botón táctil: el botón «Mochila» se borra. El de mapa dice «Mapa» de pie y manda `mapa`; sentado dice
  «Inventario» y manda `inventario`. Sabe si el jugador está sentado por `Jugador.descansando`, que lee del grupo
  `jugador`. La disposición guardada no necesita migración: la clave `mochila` se ignora al leerla.

### Pausa
- Queda Continuar · Configuración · Salir al menú. Se quitan «Amuletos» (ahora en el marco) y «Controles» (el
  editor de botones táctiles ya está en Configuración).
- Configuración se abre encima de la pausa con la misma escena del menú (`nucleo/configuracion.tscn`), con el
  juego detenido. Volver regresa a la pausa con el foco en «Configuración». (propuesta) «Modo desarrollador» se
  oculta dentro de la partida: lo que cambia es el menú principal, que ahí no se ve.

- «Recursos» cambiado desde la pausa vale al entrar a la siguiente sala: `Prescindible`, `Niebla` y `Planta`
  leen `Recursos.bajos()` al entrar. Configuración lo dice bajo la opción cuando se abre desde la pausa.

### Ajustes tras consultar al advisor (13-oct-2026)
- `pagina_anterior` y `pagina_siguiente` no entran en `Mando.REASIGNABLES` en esta versión. Si alguien reasigna
  `mapa_rapido` a RB, RB hará las dos cosas: el mapa rápido con el juego andando y el cambio de página con el
  marco abierto. No chocan porque `mapa_rapido` solo responde con el árbol sin pausa (`pantalla_mapa.gd`).
- La foto de la sala se guarda como `Image` al abrir la pausa. El `ImageTexture` se arma solo al abrir la
  pantalla de brillo. Si la copia sale vacía o nula, se usa la escena de muestra, igual que en el menú. La foto
  incluye el HUD y los botones táctiles, como la vista previa de Hollow Knight. En el hito 5 se mide en el S50
  si abrir la pausa da un tirón.
- El botón táctil del mapa con «Inventario» (16 px) es más ancho que su círculo (radio 0,05): se queda así y lo
  juzga la persona en el teléfono. La letra de un solo tamaño no se cambia (fue un arreglo de FPS medido).
- `Fundido` (capa 15) queda debajo de las páginas: no estorba porque el marco detiene el árbol.
- `mapa-telefono` sigue siendo verdadera de pie y no dice nada de sentado: no se reescribe.

### Capas de dibujo (propuesta)
| Capa | Qué |
|---|---|
| 20 | `Pausa` y las páginas (Inventario, Amuletos, Mapa); la pausa y el marco nunca están abiertos a la vez |
| 21 | La barra de arriba del marco (nombres de las páginas y flechas) |
| 22 | Configuración abierta desde la pausa |
| 23 | `EditorControles`, que debe quedar encima de Configuración |
| 100 | `Brillo`, sin cambio |

### Configuración (propuesta F) y volumen (propuesta A)
- Sin interruptores. Cada opción de sí o no es un botón con su nombre a la izquierda y una pastilla a la derecha:
  «Sí» dorada y «No» gris. Tocar el botón cambia el valor. «Recursos» deja de ser lista desplegable y cambia con
  cada toque: Auto, Bajo, Alto. Su aviso para teléfonos débiles se queda igual. Los que abren otra pantalla
  llevan «›».
- El brillo deja la cuadrícula: queda un botón «Brillo 100 % ›» que abre su pantalla.
- Volumen: barra ancha que salta al toque y se arrastra, con pomo grande y un altavoz que silencia y vuelve al
  valor anterior. Sin «−» ni «+». Con control y teclado, izquierda y derecha cambian de 10 en 10. Sigue
  guardando al soltar (`docs/errores/2026-10-13-barras-que-guardaban-en-cada-paso.md`).

### Pantalla de brillo (propuesta 1 con el cuadro de la 2)
- Arriba, una escena en una ventana; detrás, la misma escena tenue, como en Hollow Knight. Debajo, «Ajusta el
  brillo hasta que el cuadro de la esquina apenas se vea.», la barra A y Volver. El cuadro casi negro de
  calibración va siempre en la esquina de la ventana.
- (propuesta) Qué escena se ve: desde la pausa, una foto de la sala donde estás, tomada una sola vez al abrir la
  pausa (una copia de la pantalla, no un shader de cada cuadro). Desde el menú no hay sala: una escena de muestra
  armada con rectángulos de color (cielo, edificios, suelo, banco y el jugador), sin texturas, para no pesar en el
  S50 ni depender de `herramientas/`.
- La capa de `Brillo` (capa 100) sigue tapando todo: la escena se ve con el brillo elegido. De 50 % a 150 %, en
  pasos de 5.

## Hitos

1. Entrada: renombrar `mochila` a `inventario` con la migración de `mando`; acciones `pagina_anterior` y
   `pagina_siguiente`; el botón táctil doble y el de Mochila borrado. Casos en `prueba_tactil.gd` (sentado manda
   `inventario`) y en `prueba_menu_configuracion.gd` o `prueba_guardado.gd` (ajustes viejos con `mochila`).
2. Marco y páginas: `marco_menus.gd`, la interfaz de página, Amuletos y Mapa como páginas, y la página
   Inventario. Guion nuevo `marco.guion`: abre en la página correcta de pie y sentado, el ciclo en los dos
   sentidos, sin `mapa/` quedan dos páginas, cierra con pausa, Atrás y la misma acción, y el juego detenido.
   `amuletos.guion` y `mapa_cuentas.guion` se adaptan.
3. Pausa con Configuración encima. Casos en `prueba_menu.gd` o en una prueba de la pausa: abrir, volver con el
   foco y ningún desarrollador dentro de la partida.
4. Configuración F, barra A y pantalla de brillo. `prueba_menu_configuracion.gd` cambia los casos de «−» y «+»
   por la barra, el altavoz y las teclas; se agregan casos de pastillas, Recursos por toques y la pantalla de
   brillo (el valor, el guardado al soltar y Volver).
5. `validar.ps1` y todos los guiones; `revisor`; documentos (`docs/contrato.md`: «Entrada», «Capas de dibujo»,
   «Pausa», «Pantalla», `mapa/CLAUDE.md`, `docs/pruebas.md`); APK y prueba en el S50 y el S20.

## Funciones nuevas (las aprueba la persona)

En `nucleo/funciones.json`:
- `marco-menus`: el marco con Inventario · Amuletos · Mapa, cómo se abre de pie y sentado, el ciclo y cómo se
  cierra, con el juego detenido. Comprobación: `herramientas/guiones/nucleo/marco.guion`.
- `pausa-configuracion`: la pausa con Continuar · Configuración · Salir al menú y Configuración encima.
  Comprobación: el guion de la pausa o del menú que lleve los casos.
- `configuracion-tactil`: pastillas sin interruptores, Recursos por toques, barra A y pantalla de brillo.
  Comprobación: `herramientas/guiones/nucleo/menu_configuracion.guion`.
- `marco-menus-telefono`: manual, en el S50 y el S20, con la fila nueva de `docs/pruebas.md`.

Entradas que este plan deja falsas y se reescriben, sin tocar su `pasa` (también las aprueba la persona):
- `nucleo/funciones.json`:
  - `controles-configurables`: el editor se abre desde Configuración, no desde la pausa.
  - `configuracion-menu`: ya no dice «el mismo editor que la pausa».
  - `configuracion-opciones`: Brillo como pantalla propia y las opciones de sí o no sin interruptores.
  - `temblor-al-aterrizar`: «el interruptor Temblor» pasa a ser «la opción Temblor».
  - `amuletos-banco`: se abren en el marco (acción `inventario` o el botón sentado), no desde la pausa.
  - `amuletos-telefono`: la página Amuletos del marco en lugar de la pantalla de la pausa. Hoy pasa en el S50 por el
    camino viejo; se vuelve a probar.
- `mapa/funciones.json`, `mapa-pantalla`: la acción `mapa` abre el marco en la página Mapa.

## Fuera de este plan
- Inventario de objetos, la «sobrecarga» de amuletos, el diario de Hollow Knight y el arte de los menús.
- Interactuable (hablar tocando al NPC) y el sonido propio del daño recibido: planes o cambios aparte.

## Cierre (13-oct-2026)
- Hitos 1 a 5 hechos; `revisor` aprobado tras corregir 6 fallos (la textura de la foto que no se soltaba, el editor
  sobre el fondo negro de Configuración, `amuletos-telefono` y tres filas de `docs/pruebas.md` y `mapa/CLAUDE.md`).
- Cambios sobre el mockup: «Volver» de la pantalla de brillo arriba a la izquierda; el altavoz de un volumen bajado a
  0 con la barra lo sube a 50; la letra de la pastilla baja si no cabe junto al nombre; la foto de la pausa trae el
  brillo aplicado y un shader lo deshace al mostrarla.
- Teléfonos (S50 y S20): pasan `marco-menus-telefono` y `amuletos-telefono`; sin tirón al abrir la pausa en el S50.
