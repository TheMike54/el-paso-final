CERRADO

# Foco de los menús visible solo con control o teclado

Decisión de la persona (13-oct-2026): con el dedo no se dibuja el recuadro del foco; con control o teclado sí. Hoy
cada menú pone el foco con `grab_focus()` al abrirse (p. ej. `nucleo/menu.gd:62`), y así llamado se dibuja siempre:
en el S50 «Jugar» sale con el recuadro sin ningún control conectado. Godot 4.7 no dibuja el foco que llega por
toque (`classes/class_control.rst:38`) y `grab_focus(hide_focus)` lo pone sin dibujarlo (`class_control.rst:3613`).
El color del foco no es definitivo: nada fija el dorado.

Rama: `feature/nucleo-menu-tactil`, en el #5, después del arreglo de A / Cruz (`aeb186c`) y antes de exportar
el APK nuevo; aprobado por la persona el 14-oct-2026, junto con el arreglo de las puertas de la QA del #3, que va
en el mismo commit. Cambia lo que se ve: no va en `chore/limpieza-codigo`.

## H1. Función común

- `Tema.dar_foco(control: Control) -> void`: `control.grab_focus(Input.get_connected_joypads().is_empty())`. Sin
  control conectado, el foco existe pero no se dibuja; la primera flecha o el primer movimiento del D-pad lo
  muestra (foco que llega por teclado o control). Con control conectado, se ve desde que se abre el menú.
- Las 31 llamadas de los menús (`nucleo/` y `mapa/`, más `zona_pruebas.gd` y la prueba de configuración) pasan a
  `Tema.dar_foco`. Las que reaccionan a una tecla o al control ya presionado se quedan con `grab_focus()`, que lo
  dibuja (revisar cada una).
- Riesgo: con teclado y sin control (PC), Enter pulsa el botón con foco aunque no se vea. Es lo mismo que hoy, solo
  que sin recuadro hasta la primera flecha.
- Comprobación: `validar.ps1`; guiones de menú, ranuras, pausa, configuración, mapa y amuletos con los mismos
  casos; un caso nuevo en `prueba_menu_configuracion.gd` (o la prueba de marco) que lea `has_focus(true)` después de
  `Tema.dar_foco` sin control. `revisor` (contrato y menús).

## H2. Documentos

- Skill `ui-tactil`, texto aprobado por la persona el 13-oct-2026, en lugar de «El dorado marca solo el foco»: «El
  foco se ve solo al navegar con control o teclado (con el dedo, `grab_focus(true)`); su color sale de `Tema.FOCO`
  y ningún estado del botón (presionado o encendido) lo usa, o con el control no se sabe dónde está el foco».
- `docs/contrato.md`: `Tema.dar_foco` en la tabla de `Tema`. `docs/pruebas.md`: en «Interfaz», con el dedo no hay
  recuadro; con control sí.
- Prueba manual: en el S50 con el dedo, el menú principal sin recuadro; en el teléfono de Ian con el DUALSHOCK 4, el
  recuadro desde el inicio.

## Avance

- 13-oct-2026: plan escrito; espera la aprobación de la persona y la rama.
- 14-oct-2026: H1 y H2 hechos. `Tema.dar_foco` en 30 llamadas de `nucleo/`, `mapa/` y la zona de pruebas; la
  prueba de configuración sigue con `grab_focus()` porque necesita el foco tal cual. Ninguna llamada reacciona a
  una tecla sin control conectado, así que ninguna se quedó con `grab_focus()`. Casos nuevos en
  `prueba_menu_configuracion.gd`: sin control el foco existe y no se dibuja, y la primera flecha lo dibuja.
  Fila manual «Foco de los menús» en `docs/pruebas.md` (en lugar de editar «Interfaz», que es del HUD).
- 14-oct-2026, revisor: (1) la regla «control conectado» dibujaba el foco con el dedo si había un control
  emparejado (la tableta y el teléfono de la QA lo tienen) y (2) con Esc en la PC, sin control, el foco quedaba
  oculto. La persona aprobó afinarlo: `UltimaEntrada` (nodo de `Arranque`, también en pausa) anota si lo último fue
  un toque o clic (`false`) o una tecla, un botón o un stick a la mitad (`true`), y `dar_foco` usa
  `grab_focus(not UltimaEntrada.con_control)`. Esc es tecla: el menú que abre ya dibuja el foco. Tres casos más en
  la prueba de configuración (78). Aprobado también: la pastilla «Sí» y lo lleno de las barras dejan el dorado
  (H3). Segunda revisión: «Botones del control» consume en su `_input` el botón que se reasigna antes de que
  `UltimaEntrada` lo vea, y `recibir_boton` ponía el foco con el valor viejo: ahí se anota a mano antes de
  consumirlo. Falta la prueba manual en el S50.
- 14-oct-2026, prueba manual con el APK `dev-2026-10-14` (fila «Foco de los menús» de `docs/pruebas.md`): pasa en
  la Galaxy Tab S9 FE con control Xbox y en el Senwa S50 con DUALSHOCK 4 por Bluetooth. En el A55 con DUALSHOCK 4 se
  reportó el recuadro con el dedo en la pausa; sin reproducir. Plan cerrado; el #5 se fusionó en `main`.
