CERRADO

# Segunda limpieza: mejoras menores de la auditoría y funciones comunes de las pruebas

Aprobado por la persona el 13-oct-2026 (decisión 4 y «funciones comunes»). Segundo commit en
`chore/limpieza-codigo`, después del de `planes/cerrados/nucleo-limpieza.md` (se empieza cuando ese commit exista).
Mismas reglas: ningún cambio de comportamiento; cada `.esperado` fija sus casos; no se generaliza sin tres casos.

## H1. Funciones comunes de las pruebas

- `_esperar(ticks: int)` en `herramientas/salas/prueba_base.gd`: los bucles de `await get_tree().physics_frame` de
  `prueba_dialogo.gd`, `prueba_reto.gd`, `prueba_sonido.gd`, `prueba_menu_configuracion.gd`,
  `prueba_estado_sala.gd` y `prueba_peligro_anti_bucle.gd` (que hoy tiene su propio `_ticks`).
- Ruta del menú principal: una constante en `nucleo/menu.gd` que usan `pausa.gd`, `boton_volver_menu.gd` y
  `herramientas/salas/zona_pruebas.gd` (hoy tres copias del texto).
- Comprobación: `validar.ps1` y los 128 guiones con los mismos casos.

## H2. Mejoras menores de la auditoría (decisión 4)

- Enums con un miembro por línea (`boton_valor.gd`, `ficha_enemigo.gd`, `guardado.gd`, `ranuras.gd`,
  `recompensa.gd`, `toques.gd`).
- Tamaños de letra sobrantes de `caja_dialogo.gd` (comprobar cuáles quedan sin uso).
- `##` en los `@export` que no lo tienen.
- Constante del grupo `jugador` en `Jugador` (6 usos de `&"jugador"`), con un comentario: el grupo lo lleva lo que
  controla la persona, caja gris incluida.
- La frase del proyectil sobre `Area2D` y `StaticBody2D`: comprobar que el contrato y `nucleo/proyectil.gd` dicen
  solo lo medido («movido por posición, no detectó»); si ya lo dicen, nada.
- Comprobación: `validar.ps1`, los 128 guiones; `revisor` (toca `jugador.gd` y el contrato).

## Fuera

- Velo de los menús (5 casos con diferencias) y buscar al jugador con una función: al tocar esos archivos.
- Crear botones y etiquetas, mensajes del validador: no (cada caso es distinto).

## Avance

- 13-oct-2026: plan escrito; espera la aprobación de la persona.
- 14-oct-2026: aprobado por la persona para la tanda de la noche. Hecho en una copia de trabajo aparte (el árbol
  principal tiene el #5 sin commit) y entregado como parche.
  - H1: `_esperar(ticks)` en `prueba_base.gd` (también lo usa `_presionar`); 10 esperas cambiadas en cinco
    pruebas. `prueba_estado_sala.gd` se quedó: su espera se corta al tocar el suelo, no cuenta ticks.
    `prueba_peligro_anti_bucle.gd` perdió su `_ticks`. La ruta del menú es `MenuPrincipal.RUTA` (`nucleo/menu.gd`),
    usada por la pausa, el botón de volver al menú y la zona de pruebas.
  - H2: seis enums con un miembro por línea (`gdscript_styleguide.rst:754-777`); en `caja_dialogo.gd` no quedaban
    constantes de letra sobrantes, pero las dos etiquetas repetían con un override el tamaño que ya les da el tema
    (`Tema.LETRA_CHICA` para `Label`): se quitaron los overrides; `##` en 27 `@export` sin descripción (los que
    comparten el comentario de arriba con otro, como `proporcion_minima` y `proporcion_maxima`, se quedaron);
    `Jugador.GRUPO` en lugar de `&"jugador"` en nueve archivos, incluido el puerto de depuración; la frase del
    proyectil ya decía solo lo medido.
  - `validar.ps1` 191/0 y los 128 guiones en verde.
