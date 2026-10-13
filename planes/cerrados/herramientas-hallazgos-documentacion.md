CERRADO

# Arreglos del contraste con la documentación oficial de Godot 4.7

## Objetivo

Resolver los 14 hallazgos del contraste del 13-oct-2026 que tienen efecto real y cuestan poco. Los demás quedan
fuera con su razón: ya cubiertos por la limpieza aprobada (6), por la fusión de `chore/android-export` (4), por
medir en el S50 antes de actuar (10) o sin efecto (17). Decidido por Claude con el advisor; la persona aprobó las
dos entradas nuevas de `herramientas/funciones.json`.

## Hitos

| # | Hallazgo | Cambio | Comprobación |
|---|---|---|---|
| H1 | Límite de 2048 px sin control | `validar.gd`: falla una imagen (`png`, `jpg`, `webp`, `svg`) de más de 2048 px de ancho o alto. Entrada `validador-texturas` | En una copia, un PNG de 4096 px da `FALLO`; en el repo, `fallos=0` |
| H2 | Límite de 2 capas translúcidas sin control | `validar.gd`: en una escena cuya raíz es una `Sala`, más de 2 capas translúcidas grandes fallan. Capa translúcida grande: un `Sprite2D`, `TextureRect`, `ColorRect`, `NinePatchRect` o `Polygon2D` visible, con alfa efectivo (`modulate` de él y de sus padres por `self_modulate`) menor que 1 y que cubre al menos un cuarto de la vista base (1280×720). Entrada `validador-capas-translucidas` | En una copia, una sala con 3 capas así da `FALLO`; con 2, no |
| H3 | 3D sin desactivar | `Arranque` pone `disable_3d` en la vista raíz (`rendering/viewports.rst:208`) | `validar.ps1`, todos los guiones y una línea en el contrato; FPS en el S50 (prueba manual) |
| H4 | Master sin limitador | `AudioEffectHardLimiter` como último efecto de Master en `default_bus_layout.tres` (`audio/audio_effects.rst:203`) | `validar.ps1`; guion `sonido`; oírlo en el S50 (prueba manual) |
| H5 | Salir desde el menú no avisaba el cierre | Antes de `quit()`, `propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)` (`inputs/handling_quit_requests.rst:88`), así Configuración guarda lo pendiente | Un caso en la prueba del menú; error en `docs/errores/` |
| H6 | Pantallas que toman al jugador como hermano | `PantallaAmuletos` y `PantallaMapa` lo buscan por el grupo `jugador` | Guiones `amuletos` y `mapa_cuentas` |
| H7 | Textos que no dicen lo que hace el código | Comentario de voces de `Sonido`; «un Area2D no detecta un StaticBody2D», acotado a lo medido | Lectura |
| H8 | Reglas sin escribir | En el contrato: por qué los menús se arman en código, por qué `ControlesTactiles` usa `_input`, accesibilidad fuera de la v1; en el `CLAUDE.md`: mover `.tscn`, `.tres` o imágenes fuera de Godot; en `docs/pruebas.md`: instalar un APK firmado en otra máquina obliga a desinstalar y borra las partidas | Lectura |
| H9 | `adb` sin revisar | `verificar-entorno.ps1` avisa (sin fallar) si `adb` no está | Correrlo en 5.1 y 7 |
| H10 | Medir antes de actuar | Una fila en `docs/pruebas.md` con lo que se mide en el S50: primer corte (tirón de partículas), cambio de sala, CPU frente a GPU con el monitor de FPS | Lectura |

## Avance (13-oct-2026)

- H1 a H10 hechos. `validar` 189/0; guiones `menu_configuracion` 73/0, `amuletos`, `marco`, `mapa_cuentas` y
  `sonido` en verde; `verificar-entorno.ps1` en 5.1 y 7, con y sin `adb`.
- `revisor` (primera pasada): H2 no contaba el alfa del `color` de `ColorRect` y `Polygon2D` (la forma en que el
  repo hace sus nieblas) ni el tamaño por anclas de un `Control` fuera del árbol (un `PRESET_FULL_RECT` medía 0×0).
  Decisión: se corrige el código, no el texto, porque la regla existe para esas capas. Ahora cuentan los dos y un
  `CanvasLayer` invisible excluye a sus hijos; en una copia, 3 capas por color, 3 ancladas a pantalla completa y
  `sala_recursos` con 2 más dan `FALLO`, y las salas del repo, 0. Faltaba la fila manual de H3 y H4 en
  `docs/pruebas.md`: agregada («Solo 2D y limitador (S50)»).
- `revisor` (segunda pasada): un `Control` anclado bajo un `Node2D` se medía como la vista entera (el motor ancla
  contra 0×0) y un `TextureRect` sin offsets como 0×0 (fuera del árbol no toma el tamaño de su textura).
  Corregidos con el mínimo combinado y el padre real; en la copia, los dos casos dan lo esperado y los anteriores
  siguen igual. `validar` 189/0 y 128 de 128 guiones en verde. `revisor`: aprobado.
- Cerrado el 13-oct-2026. Pruebas manuales pendientes: «Solo 2D y limitador (S50)» y «Medir antes de optimizar
  (S50)» de `docs/pruebas.md`.

## Fuera

- `chore/android-export` resuelve el permiso de vibrar, `--print-fps` y la guía de exportación al fusionarse.
- Las 17 que no se hacen y su razón están en el material del contraste (fuera del repo).

## Riesgo

`Arranque` es autoload y `validar.gd` es el validador: pasan por el `revisor`. El limitador cambia cómo suena todo
el juego: si recorta de más, se ajusta su techo, no se quita.

## Cierre

Las dos entradas nuevas en `"pasa": true` con su evidencia, `validar.ps1` en verde, los 128 guiones en verde y el
`revisor` aprobado. Quedan como prueba manual: FPS con `disable_3d` y el limitador, en el S50.
