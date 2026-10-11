CERRADO

# Núcleo: Configuración en el menú principal

Pedido por la persona el 11-oct-2026: una sección «Configuración» en el menú principal que por ahora solo tenga
«Controles» (el mismo editor de la pausa) y que después reciba otras opciones. El acceso desde la pausa se queda.
Aprobado el 11-oct-2026. Rama propia, `feature/nucleo-configuracion-menu`, que sale de
`feature/nucleo-controles-configurables` cuando se apruebe.

## 1. Lo que hay (leído el 11-oct-2026)

- `nucleo/menu.tscn` es la escena principal: Nueva partida, Continuar, Zona de pruebas (solo en depuración), un
  texto con el estado del guardado y la confirmación «¿Salir del juego?», que reemplaza al panel central
  (`Centro`) mientras está abierta. Atrás y la acción `pausa` piden esa confirmación.
- El editor (`nucleo/editor_controles.tscn`, `EditorControles`) no depende de la pausa: se instancia, edita una
  copia de `Ajustes.disposicion`, emite `cerrado` y se libera solo. Hoy lo abre `Pausa.abrir_editor()`.
- `menu-desarrollo` sigue en `"pasa": false` en `nucleo/funciones.json` (espera al modo desarrollador); este plan
  no la toca.

## 2. Propuesta

| Qué | Cómo |
|---|---|
| Entrada | Botón «Configuración» en el menú, entre Continuar y Zona de pruebas |
| Panel | Un panel `Configuracion` en la misma escena del menú, como la confirmación de salida: reemplaza a `Centro` y tiene «Controles» y «Volver». Sin escena nueva mientras tenga una sola opción |
| Controles | Abre el mismo editor, encima del fondo del menú; al cerrarlo vuelve al panel. Listo guarda en `user://ajustes.json` igual que desde la pausa |
| Atrás y `pausa` | Un nivel a la vez: con el editor abierto, Cancelar; en el panel, volver al menú; en el menú, la confirmación de salida, como hoy |
| Después | Las opciones nuevas se agregan como botones del panel. Pasar ahí Vibración y Temblor (hoy en la pausa) se decide aparte |

Sin cambios en el editor ni en `Ajustes`. Abrir el editor queda repetido en `Pausa` y en el menú (cinco líneas);
no se generaliza hasta tener tres casos.

## 3. Cómo se comprueba

- Guion (la navegación es una pequeña máquina de estados): una escena de prueba instancia el menú y comprueba que
  «Configuración» abre el panel; «Controles», el editor; Atrás con el editor abierto cancela y vuelve al panel; Atrás
  en el panel vuelve al menú y otra vez Atrás pide salir; con el editor abierto la acción `pausa` no pide salir.
- Manual, en el teléfono: menú → Configuración → Controles → mover un botón → Listo; entrar a una sala y ver el botón
  movido; desde la pausa, el editor sigue igual.

Entrada nueva para `nucleo/funciones.json` (la aprueba la persona):

- `id`: `configuracion-menu`
- `que`: «El menu principal tiene Configuracion con Controles, que abre el mismo editor de botones que la pausa;
  Atras vuelve un nivel a la vez»
- `comprobacion`: `herramientas/guiones/nucleo/menu_configuracion.guion`

## 4. Archivos

`nucleo/menu.gd` y `menu.tscn`; guion, `.esperado` y sala de prueba en `herramientas/` (excluida de la zona de
pruebas); `docs/contrato.md` (menú); `docs/pruebas.md` (guion y caso manual); `ESTADO.md`.

## Avance

- [x] Plan aprobado por la persona, con la entrada nueva de `funciones.json` (11-oct-2026).
- [x] Rama `feature/nucleo-configuracion-menu` creada desde `feature/nucleo-controles-configurables` (`8649c73`).
- [x] Panel, editor desde el menú y guion (`menu_configuracion.guion`: 13 de 13; 75 de 75 guiones; 11-oct-2026). En el
  S50 con `adb`: Configuración → Controles → mover Saltar → Listo; Atrás vuelve al menú y luego pide salir; en la sala
  de movimiento Saltar está donde se dejó; sin errores en el log.
- [x] Prueba en el teléfono (persona, 11-oct-2026, Senwa S50, con los pulgares): pasa. Con eso se cierra el plan.
