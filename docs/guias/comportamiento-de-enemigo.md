# Cómo se hace un comportamiento de enemigo

**Para qué sirve:** escribir la mecánica de un enemigo (caminar, volar, escudo, enterrarse, embestir, disparar) como
un script que hereda de `ComportamientoEnemigo`, usando las piezas del núcleo y sin cambiar `nucleo/`.

**Antes de empezar:** `docs/guias/agregar-un-enemigo.md` (ficha, sala, guion) y, en `docs/enemigos.md`, la sección «Enemigos» completa. Antes de escribir el `.gd`, las skills `gdscript4` y `fisica-2d`. Si la mecánica viene de un
enemigo de Hollow Knight o Silksong, la skill `referencia-hollow-knight` dice cómo lo hacen ellos.

## La regla
El núcleo no sabe qué enemigo es. El comportamiento sí, y solo habla con el núcleo por lo que ofrece la base:

| Para | Se usa | No se hace |
|---|---|---|
| Moverse | `caer()`, `mover()`, `enemigo.velocity` | `move_and_slide` ni gravedad propia |
| Mirar el mundo | `en_suelo()`, `pared_delante(sentido)`, `orilla_delante(sentido)`, `ve_al_jugador(radio)`, `lado_de(nodo)` | Rayos ni `Area2D` propios para lo mismo |
| Voltearse | `girar()` o `enemigo.mirando = ±1` (el dibujo se refleja solo) | Tocar `scale.x` del dibujo |
| Atacar | `atacar(...)`, `disparar(...)`, `lanzar_en_arco(...)` | Crear `DanoContacto` o proyectiles a mano |
| Escudo, caparazón | Sobrescribir `bloquea_golpe(atacante) -> bool` | Cambiar la vida en el comportamiento |
| Trepar, enterrarse | `flotar(true)` y luego `flotar(false)` | Cambiar `motion_mode` a mano |
| Reaccionar a la mirada | `jugador_lo_mira()` | Leer variables privadas del `Jugador` |
| Animar | `enemigo.animar(&"nombre")` (solo si su `SpriteFrames` la tiene) | `play()` directo sobre el dibujo |
| Botín | El campo `botin` de la ficha | Crear monedas en el comportamiento |
| Sonar | `sonar(&"ataque")`; los efectos propios, en el campo `sonidos` de la ficha (`vencido` y `golpe` suenan solos) | `AudioStreamPlayer` propio |

Además:
- Toda la lógica va en `actuar()`, que la base llama cada tick de física y no llama durante el congelado.
- Los estados, con un `enum` mientras sean pocos. Los números que se ajustan (radio, esperas, rapidez) no son `const`:
  van como `@export` en un `datos_<comportamiento>.gd` que hereda de `DatosComportamiento`, el comportamiento lo
  devuelve en `datos_por_omision()` y los lee de `datos`. Así un ejemplar o una ficha pueden traer los suyos. Los del
  ejemplar reemplazan **todos** los de la ficha: para cambiar un solo número en una sala, se copia el `.tres` de datos
  de la ficha (*Make Unique*) y se cambia solo ese
  (`docs/enemigos.md`, «Datos del comportamiento»; modelo: `volador.gd` y `datos_volador.gd`).
- El arte se dibuja **mirando a la derecha**: el núcleo lo refleja cuando el enemigo mira a la izquierda. Un dibujo
  hecho mirando a la izquierda se ve caminando de espaldas, y ningún guion lo detecta.
- Lo que un guion necesita leer (cuántas veces giró, cuántos disparos) va en una variable pública, como `giros` en
  `caminante.gd`.

## Ejemplo: un enemigo con escudo
Bloquea los golpes que le llegan de frente; por la espalda recibe el daño. Es
`herramientas/pruebas/comportamiento_escudo_prueba.gd`, que pasa `validar.ps1` y lo prueba
`herramientas/guiones/nucleo/enemigo_enganches.guion`:

```
extends ComportamientoEnemigo
# Comportamiento de prueba de los ganchos de ComportamientoEnemigo: bloquea los golpes que le llegan de frente
# (escudo) y no se mueve. Solo lo usa prueba_enemigo_enganches.gd; no es jugable.


func bloquea_golpe(atacante: Node2D) -> bool:
	return lado_de(atacante) == enemigo.mirando
```

Un golpe bloqueado no le quita vida, no lo empuja ni le da Inspiración al jugador, que rebota igual. Suena y vibra
como pegarle a un objeto, como el `Invincible` del `HealthManager` de Hollow Knight. Para que además camine, se juntan
las dos ideas: `actuar()` como en `herramientas/salas/comportamientos/caminante.gd` y `bloquea_golpe` como arriba.

## Cómo se prueba
- Una sala por comportamiento en `herramientas/salas/enemigos/sala_<comportamiento>.tscn`: la zona de pruebas la
  agrega sola a «Enemigos» (modelo: `sala_caminante.tscn`). Su fila va en `docs/salas-de-prueba.md`.
- Un guion corto en `herramientas/guiones/nucleo/` que compruebe lo que demuestra la mecánica (que giró, que disparó,
  que un golpe de frente no restó vida), con tolerancia. Un guion de `contenido/` da la `pluma` con la línea
  `habilidad pluma` (`docs/guiones.md`).
- Lo que se ve y se siente (animación, golpe, FPS en el teléfono) se pide a mano con su fila en `docs/pruebas.md`.

## Si algo falla
- No se mueve: la ficha no tiene `comportamiento` o, si camina, le falta `gravedad` (con 0 vuela).
- Se ve de espaldas: el dibujo no está hecho mirando a la derecha.
- Un error que solo sale al correr no lo atrapa `validar.ps1`: corre el guion de su sala.

## Un jefe con fases y arena

Usa el mismo `Enemigo` con `jefe = true` en su ficha. Pon `umbrales_fase` de mayor a menor (por ejemplo, `[6]`
con vida 12): empieza en fase 0 y a 6 de vida pasa a fase 1. El comportamiento puede leer `enemigo.fase` en
`actuar()` o sobrescribir `al_cambiar_fase(fase: int) -> void` para reiniciar un estado o un contador. Un golpe que
salta varios umbrales llama al gancho una vez por fase; no modifiques la ficha ni la vida desde ese gancho.

En la sala, agrega una `ArenaJefe` con una `CollisionShape2D` hija directa que cubra el interior del combate.
Asigna `jefe`, un `id_jefe` estable, los `portones` con `abierto_al_empezar = true` y la `recompensa`.
La arena duerme el comportamiento hasta entrar, lo despierta y cierra los portones. Al vencer abre y entrega;
`Eventos.jefe_vencido(id_jefe)` deja el combate recordado en `Partida`. Al volver ya vencido no aparece el jefe
ni se repite el premio. No emitas esa señal desde el comportamiento ni entregues la recompensa allí.

Ejemplo completo: `herramientas/salas/sala_jefe.tscn` y `comportamientos/jefe_prueba.gd`, con sus números en
`datos_jefe_prueba.gd`: camina y, en la segunda fase, acelera y embiste después de una pausa de aviso.
Su guion `herramientas/guiones/nucleo/sala_jefe.guion` comprueba umbrales, portones, premio único, regreso sin jefe
y muerte sin recompensa. En el teléfono prueba también que el aviso de la embestida se entiende y se puede esquivar
con los controles táctiles (fila Jefe en `docs/pruebas.md`).
