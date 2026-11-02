# Cómo se hace un comportamiento de enemigo

**Para qué sirve:** escribir la mecánica de un enemigo (caminar, volar, escudo, enterrarse, embestir, disparar) como
un script que hereda de `ComportamientoEnemigo`, usando las piezas del núcleo y sin cambiar `nucleo/`.

**Antes de empezar:** `docs/guias/agregar-un-enemigo.md` (ficha, sala, guion) y, en `docs/enemigos.md`, la sección «Enemigos» completa. Antes de escribir el `.gd`, las skills `gdscript4` y `fisica-2d`.

## La regla
El núcleo no sabe qué enemigo es. El comportamiento sí, y solo habla con el núcleo por lo que ofrece la base:

| Para | Se usa | No se hace |
|---|---|---|
| Moverse | `caer()`, `mover()`, `enemigo.velocity` | `move_and_slide` ni gravedad propia |
| Mirar el mundo | `en_suelo()`, `pared_delante(sentido)`, `orilla_delante(sentido)`, `ve_al_jugador(radio)`, `lado_de(nodo)` | Rayos ni `Area2D` propios para lo mismo |
| Voltearse | `girar()` o `enemigo.mirando = ±1` (el dibujo se refleja solo) | Tocar `scale.x` del dibujo |
| Atacar | `atacar(...)`, `disparar(...)`, `lanzar_en_arco(...)` | Crear `DanoContacto` o proyectiles a mano |
| Escudo, caparazón | Sobrescribir `bloquea_golpe(atacante) -> bool` | Cambiar la vida en el comportamiento |
| Suspender gravedad | `flotar(true)` y luego `flotar(false)` | Suponer que oculta o desactiva golpes y contacto |
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

## Ejemplo: datos por omisión y acceso tipado

En `herramientas/salas/comportamientos/volador.gd`, el script de datos se precarga y `_ready()` convierte
`datos` al tipo propio. El núcleo ya eligió y asignó ese recurso antes de agregar el comportamiento.
Si ni el ejemplar ni la ficha aportan datos, `datos_por_omision()` devuelve una instancia con los valores
por omisión de `datos_volador.gd`:

```gdscript
extends ComportamientoEnemigo

const DatosVolador = preload("datos_volador.gd")

var persiguiendo: bool = false

var _d: DatosVolador = null


func _ready() -> void:
	_d = datos as DatosVolador


func datos_por_omision() -> DatosComportamiento:
	return DatosVolador.new()


func actuar() -> void:
	var ve: bool = ve_al_jugador(_d.radio_alerta)
	if ve:
		persiguiendo = true
```

`_d.radio_alerta` muestra el acceso tipado a los números del recurso; el estado que cambia al actuar sigue
en el comportamiento.

## Ejemplo: un enemigo con escudo
Bloquea los golpes que le llegan de frente; por la espalda recibe el daño. Es
`herramientas/pruebas/comportamiento_escudo_prueba.gd`, que pasa `validar.ps1` y lo prueba
`herramientas/guiones/nucleo/enemigo_enganches.guion`:

```gdscript
extends ComportamientoEnemigo
# Escudo inmovil para comprobar el gancho bloquea_golpe de ComportamientoEnemigo con golpes frontales.
# Mantiene fijo al enemigo para aislar el bloqueo de su movimiento y de otros comportamientos.
# Solo lo usa prueba_enemigo_enganches.gd; no es un comportamiento jugable.


func bloquea_golpe(atacante: Node2D) -> bool:
	return lado_de(atacante) == enemigo.mirando
```

Un golpe bloqueado no le quita vida, no lo empuja ni le da Inspiración al jugador, que rebota igual. Suena y vibra
como pegarle a un objeto, con el efecto de un golpe bloqueado. Para que además camine, se juntan
las dos ideas: `actuar()` como en `herramientas/salas/comportamientos/caminante.gd` y `bloquea_golpe` como arriba.

## Enterrarse sin cambiar el núcleo

`flotar(true)` suspende la gravedad y cambia el modo de movimiento a flotante; no oculta ni desactiva contacto o golpes (`nucleo/comportamiento_enemigo.gd`, `nucleo/enemigo.gd`). En el comportamiento, al entrar al estado enterrado, detener la velocidad,
ocultar el dibujo con `enemigo.modulate.a = 0.0` (incluye hijos; guardar el alfa anterior), obtener `DanoContacto` desde el enemigo y apagar su
`set_physics_process(false)` y, con `set_deferred`, su `monitoring`. Desactivar también con `set_deferred` el
`monitorable` de `enemigo.golpeable`. Sobrescribir `bloquea_golpe()` para devolver `true` mientras esté enterrado
o en el aviso de salida. Al salir, colocar el enemigo en un destino con suelo y espacio para su cuerpo, detener la
velocidad, llamar `flotar(false)`, restaurar el alfa anterior, proceso y `monitoring` del contacto y `monitorable` del
área de golpes. Mantener un estado de recuperación visible antes de repetir.

La recepción de golpes y el contacto están en `nucleo/enemigo.gd` y `nucleo/dano_contacto.gd`; las consultas de
escenario pueden usar `Capas.rayo_a_escenario` (`nucleo/capas.gd`) durante `actuar()`. Probar que enterrado no
recibe ni causa daño y que ambas funciones vuelven al salir.

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
El gancho puede ejecutarse dentro de una señal de física: no crear ataques ni disparos con `atacar()`,
`disparar()` o `lanzar_en_arco()` allí; hacerlo en `actuar()` según `enemigo.fase`.

En la sala, agrega una `ArenaJefe` con una `CollisionShape2D` hija directa que cubra el interior del combate.
Asigna `jefe`, un `id_jefe` estable, los `portones` con `abierto_al_empezar = true` y la `recompensa`.
La arena duerme el comportamiento hasta entrar, lo despierta y cierra los portones. Al vencer abre y entrega;
`Eventos.jefe_vencido(id_jefe)` deja el combate recordado en `Partida`. Al volver ya vencido no aparece el jefe
ni se repite el premio. No emitas esa señal desde el comportamiento ni entregues la recompensa allí.

Ejemplo completo: `herramientas/salas/sala_jefe.tscn` y `herramientas/salas/comportamientos/jefe_prueba.gd`, con sus números en
`datos_jefe_prueba.gd`: camina y, en la segunda fase, acelera y embiste después de una pausa de aviso.
Su guion `herramientas/guiones/nucleo/sala_jefe.guion` comprueba umbrales, portones, premio único, regreso sin jefe
y muerte sin recompensa. En el teléfono prueba también que el aviso de la embestida se entiende y se puede esquivar
con los controles táctiles (fila Jefe en `docs/pruebas.md`).
