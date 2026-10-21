CERRADO

# Círculo / B vuelve un nivel en los menús

Aprobado por la persona el 16-oct-2026.

Decidido por la persona el 15-oct-2026: Círculo / B vuelve un nivel en los menús, y en la partida sigue curando.
Entrada `circulo-atras-menus` de `nucleo/funciones.json`.

## Por qué

Hoy solo Start (`pausa`) y el Atrás de Android vuelven un nivel (`nucleo/menu.gd:155-163`,
`nucleo/pausa.gd:43-68`, `nucleo/marco_menus.gd:86`, `herramientas/salas/zona_pruebas.gd:59-69`). Círculo / B está
solo en `curar` (`project.godot:76-78`). En Hollow Knight y en Silksong, el botón de la derecha es «volver» en todos
los menús. En el video de referencia del 14-oct, «Zoom Out ○».

## Qué se hace

- **Acción nueva `volver`** en `project.godot`, solo con B / Círculo (`JOY_BUTTON_B`, 1).
  - Sin tecla (cambio del 16-oct al programar). Una acción cuenta aunque el `LineEdit` se coma la tecla, así que
    Retroceso, al borrar una letra del nombre en Nueva partida, también volvería. En el teclado vuelve Esc.
  - No se reasigna, igual que `ui_accept` (`docs/contrato.md`, «Entrada»). Si el jugador mueve `curar` a otro
    botón, B sigue volviendo en los menús.
  - Fila nueva en la tabla de `docs/contrato.md`.
- **Dónde se lee: donde hoy se lee `pausa` para volver.**
  - Lo hace igual que Start en el menú principal, las ranuras, nueva partida, Configuración y la pausa.
  - En la pausa, en el nivel de arriba, cierra la pausa (como Start).
  - En el marco de menús, cierra el marco.
  - En la zona de pruebas, regresa al menú.
- **Excepción: la espera de un botón en «Botones del control»** (`nucleo/configuracion.gd:649-666`). Ahí B es un
  botón más que se puede asignar, así que no vuelve. Solo Start cancela, como hoy.
- **En la partida no cambia nada:** con el juego andando, `volver` no se lee y B cura.
- **B mantenido al cerrar la pausa no empieza a curar.** Curar arranca con `is_action_just_pressed(&"curar")`
  (`nucleo/jugador.gd:732`), y ese cuadro pasa con el árbol en pausa. Se comprueba con un guion, no se supone.

## Hitos

1. H1 · `project.godot` y `docs/contrato.md` con la acción `volver`.
2. H2 · Menú, ranuras, nueva partida, Configuración, pausa, marco y zona de pruebas leen `volver`.
   - Pruebas en `prueba_control.gd` (B emite `curar` y `volver`).
   - Pruebas en el menú o la pausa: B vuelve un nivel y, en la espera de un botón, B se asigna y no vuelve.
3. H3 · Guion `pausa_volver`: la pausa se abre con Start, B la cierra, B mantenido 30 ticks después y la
   Inspiración no baja.
4. H4 · `validar.ps1` y los guiones de menú, pausa, marco y control. Después, el revisor, porque toca la entrada y
   `project.godot`.
5. H5 · Prueba manual con control, en el teléfono o en Windows: B vuelve en cada menú y cura en la partida.

## Riesgos

- Si la persona reasigna `pausa` a B, B hace las dos cosas en los menús. Es el mismo resultado, así que se acepta.

## Avance (16-oct-2026)

- H1 a H4 hechos.
- Guiones de comprobación:
  - `pausa_volver`, que falla si `curar` se presiona después de cerrar;
  - `zona_pruebas_volver`, que falla sin la lectura de `volver`;
  - casos en control, menú y marco.
- El revisor aprobó el código. Pidió que la comprobación de la entrada nombrara `marco.guion` y la zona, y ya los
  nombra.
- Falta H5: la prueba manual con control.

- 17-oct-2026: plan cerrado por decisión de la persona. El código y la prueba con el dedo están; la prueba con un control la harán compañeros del equipo y sigue como entrada `manual` con `"pasa": false` en `funciones.json`.
