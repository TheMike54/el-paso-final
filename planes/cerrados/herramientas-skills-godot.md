CERRADO

# Skills de Godot a partir de la documentación oficial 4.7

## Objetivo

Que una sesión que programa en este repo tenga a mano las reglas de la documentación oficial de Godot 4.7 que
aplican aquí, comprobadas en este proyecto, y que busque lo demás en la copia local (`GODOT_DOCS`).

## Base

Contraste del 13-oct-2026 de unos 110 archivos de `GODOT_DOCS/tutorials/` con el repo: 98 agentes, 729 reglas, 2
refutadas por un verificador. El resultado vive fuera del repo (material de trabajo de una máquina); lo que entra
al repo son las skills y, si hace falta, texto del contrato.

## Alcance

| Skill | Tipo | Se carga | Revisor |
|---|---|---|---|
| `gdscript4` | Ampliar (unas 23 reglas) | Antes de escribir o cambiar un `.gd` | No |
| `ui-tactil` | Nueva | Antes de un menú, una página del marco, el HUD, `Tema`, `ControlesTactiles` o un `Control` dibujado a mano | No |
| `fisica-2d` | Nueva | Antes de tocar el jugador, enemigos, proyectiles, `Area2D`, rayos o formas | Sí |
| `rendimiento-gama-baja` | Nueva | Antes de agregar arte, partículas, parallax, shaders, `_draw` o una sala, y antes de medir | Solo si toca `project.godot` |

Fuera: animación 2D (el juego aún no la usa) y exportar a Android (cabe en el README de `chore/android-export`).

## Reglas de forma

- Cada regla: una línea con la regla, su cita `tutorials/<ruta>:<línea>` y cómo se comprueba aquí (`validar.ps1`,
  un guion, Grep o prueba manual). Sin copiar el `.rst`. Menos de 150 líneas por skill.
- Solo entran reglas comprobadas en este repo: compilando en el scratchpad con el `project.godot` del proyecto o
  con un guion existente. La que no se pueda comprobar se queda en la documentación.
- Lo que choca con el estilo actual no entra como regla hasta que la persona decida (abajo).
- `description` de cada skill con las palabras con que se pide la tarea.

## Decisiones (13-oct-2026, tomadas con el advisor; la persona delega lo técnico)

1. Tipo explícito siempre, como los 96 `.gd`: la guía de estilo misma pone la consistencia del equipo por encima de
   la guía (`scripting/gdscript/gdscript_styleguide.rst`, introducción); la skill cita esa línea.
2. `$Nodo as T` se queda; si la forma sin `as` compila con `unsafe_*` en error, la skill la menciona sin cambiar la
   convención. `as` devuelve `null` en silencio: la skill lo dice (G-55).
3. Cabecera con `#`, como hoy: `##` solo se ve en la ayuda del editor y cambiarlo toca 96 archivos sin efecto.
4. a 6. Interpolación de física, partículas en CPU o GPU y fondos en VRAM o Lossless: medir en el S50 antes de
   decidir; no son reglas de skill todavía.
7. Comprobado (13-oct-2026, en una copia del repo): `@onready var h: Node2D = $Hijo` sin `as` compila y falla en esa
   línea al correr; con `as`, `h` queda `null` en silencio. La convención con `as` se queda (consistencia; cambiarla
   toca todo el repo); `gdscript4` muestra las dos formas y su fallo.
8. «Solo reglas comprobadas» se cumple a la letra en `gdscript4` (cada trampa se corrió). En las tres nuevas, cada
   cita se abrió en su línea y cada ejemplo y guion nombrado se buscó en el repo, pero no se corrió cada regla; su
   primera línea lo dice. Mostrarlas antes de guardarlas lo cubre el `revisor` (la persona delegó lo técnico).

## Pasos

1. Decisiones: hecho.
2. Probar en el scratchpad cada regla de compilación (tipado, `assign`, `as`, avisos): hecho.
3. Escribir las cuatro skills (un agente por skill, citas revisadas en su línea) y guardarlas en `.claude/skills/`:
   hecho; la sesión las lista.
4. `revisor` sobre las cuatro: citas por muestreo (131) correctas; corregidos una frase vieja sobre el validador en
   `ui-tactil`, un ejemplo de `gdscript4`, la frase de los fondos en VRAM y reglas sin comprobación en
   `rendimiento-gama-baja`. Aprobado tras los arreglos.
5. Una línea en el `CLAUDE.md` raíz que nombre las tres nuevas y cuándo se cargan.: hecho. Cerrado el 13-oct-2026.

## Cierre

Las cuatro skills existen, cada regla tiene cita y comprobación, `validar.ps1` en verde, y una sesión nueva lista las
skills al abrir. Los incumplimientos del contraste no se arreglan aquí: los de la limpieza aprobada van a su PR y los
nuevos se proponen aparte.
