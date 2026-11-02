# Agregar un enemigo

**Para qué sirve:** crear un tipo de enemigo nuevo (ficha y comportamiento) y ponerlo en una sala, sin tocar `nucleo/`.

**Antes de empezar:** haber hecho `docs/guias/empezar.md` y `docs/guias/como-trabajamos.md`; leer en `docs/enemigos.md` la sección «Enemigos» (tabla de `FichaEnemigo`, `ComportamientoEnemigo`, parry, débil y fuerte) y
el `contenido/CLAUDE.md`. Antes de escribir el `.gd`, las skills `gdscript4` y `fisica-2d`.

1. Elegir un id estable para el tipo (`StringName`): es el que emite `Eventos.enemigo_vencido`. Cada ejemplar en la
   sala lleva además su propio `id`, único dentro de la sala.
2. Carpeta del tipo: `contenido/enemigos/<id>/`, con la ficha y el script juntos (`contenido/CLAUDE.md`, «Dónde va
   cada cosa»), no dentro de la carpeta de la zona. La carpeta se crea con el primer enemigo del juego; los de prueba
   viven en `herramientas/salas/`.
3. Escribir el comportamiento: un script que hereda de `ComportamientoEnemigo` (`nucleo/comportamiento_enemigo.gd`)
   y sobrescribe `actuar()`, que corre cada tick fuera del congelado. Para moverse y atacar usa las ayudas de la
   base (`caer`, `mover`, `pared_delante`, `orilla_delante`, `ve_al_jugador`, `atacar`, `disparar`, `lanzar_en_arco`;
   lista y contrato en `docs/enemigos.md`, «Enemigos»). Sus números de ajuste (radio, esperas) van como `@export` en un
   `datos_<comportamiento>.gd` que el comportamiento lee de `datos` (`docs/guias/comportamiento-de-enemigo.md`). Modelos:
   `herramientas/salas/comportamientos/caminante.gd` (camina), `volador.gd`, `escupidor.gd`, `muneco_que_ataca.gd`.
   Empieza con 3 o 4 líneas de comentario: qué hace y por qué (`CLAUDE.md`, «Cómo se trabaja»). Mínimo, con las
   ayudas de `caminante.gd`:

   ```
   extends ComportamientoEnemigo
   # Va y viene a la velocidad de su ficha y se voltea ante una pared o una orilla.

   func actuar() -> void:
   	caer()
   	if pared_delante(enemigo.mirando) or orilla_delante(enemigo.mirando):
   		girar()
   	else:
   		enemigo.velocity.x = enemigo.mirando * enemigo.ficha.velocidad
   	mover()
   ```
4. Crear la ficha: un `.tres` de tipo `FichaEnemigo` (`nucleo/ficha_enemigo.gd`) cuyos campos, con su tipo y su
   sentido, están en la tabla de «Enemigos» y en `nucleo/ficha_enemigo.gd`. Modelo: `herramientas/salas/fichas/caminante.tres`. Una ficha es de solo lectura al
   correr: la vida que le queda a cada ejemplar vive en su `Enemigo`. Fuera de `herramientas/`, la cabecera y cada
   `ext_resource` de la ficha llevan `uid` (`docs/validador.md`, «uid de escenas y recursos»): se importa antes para que el
   script tenga su `.gd.uid`.
5. Elegir la reaparición: `AL_VOLVER_A_ENTRAR` (débil) o `AL_DESCANSAR` (fuerte: queda vencido hasta descansar en un
   banco o morir). Ejemplos: `enemigo_debil.tres` y `enemigo_fuerte.tres` en `herramientas/salas/fichas/`.
6. Ponerlo en la sala: una instancia de `nucleo/enemigo.tscn`, hija directa de la raíz, con `ficha` e `id`
   asignados (modelo: nodos `Debil` y `Fuerte` de `herramientas/salas/sala_enemigos.tscn`). Sin ficha o sin id, el
   enemigo imprime un `push_error` al aparecer. Sin comportamiento, se queda quieto. Nodo, de `sala_enemigos.tscn`:

   ```
   [node name="Debil" parent="." instance=ExtResource("6_enemigo")]
   position = Vector2(700, 680)
   ficha = ExtResource("7_debil")
   id = &"debil"
   ```

   Y la ficha, de `herramientas/salas/fichas/caminante.tres` (la parte `[resource]`):

   ```
   [resource]
   script = ExtResource("1_ficha")
   id = &"caminante"
   vida = 3
   tamano = Vector2(100, 70)
   comportamiento = ExtResource("2_comportamiento")
   velocidad = 175.0
   gravedad = 3000.0
   ```
7. Validar con `.\herramientas\validar.ps1`. No ejecuta `_ready`: un error que solo ocurre al correr lo atrapa un
   guion (`CLAUDE.md`, «Entorno y trampas»).
8. Escribir un guion corto que lo venza y compruebe el estado. Atacar exige `pluma`: añadir `habilidad pluma`
   al `.guion`, antes de las entradas por cuadro. Funciona también en guiones de `contenido/`, sin modificar
   la sala ni su `habilidades_de_prueba`: el puerto la da en silencio mediante `Partida`, antes de las entradas
   en cuanto hay jugador, y se conserva al cambiar de sala. Para otras habilidades, una línea `habilidad <id>`
   por cada una (formato: `docs/guiones.md`). Modelo de combate:
   `herramientas/guiones/nucleo/enemigo_base.guion`; de entrega por guion:
   `herramientas/guiones/nucleo/habilidad_por_guion.guion`. El `.esperado` comprueba la vida del enemigo o la
   señal `/root/Eventos enemigo_vencido`. Se corre con
   `.\herramientas\correr-guiones.ps1 -Guiones <bloque>/<nombre>` (ruta bajo `herramientas/guiones/`, sin
   extensión). Si se agrega una sala de prueba, su fila va en `docs/salas-de-prueba.md` en el mismo cambio.
9. Lo que se ve y se siente (sprites, golpe, FPS en el teléfono) se prueba a mano con una fila de `docs/pruebas.md`.
   Arte nuevo: `docs/arte-y-rendimiento.md`, «Arte de zona»; animación con `AnimatedSprite2D` (viñeta «Enemigos nuevos»).
10. Entregar el bloque de commit como indica `docs/guias/como-trabajamos.md`.

## Portones al vencer a un enemigo

Un enemigo común no abre portones automáticamente; un jefe asociado a `ArenaJefe` sí los abre al ser vencido.
La arena cierra los portones al entrar, los abre al vencer y entrega la recompensa una sola vez
(`docs/enemigos.md`, sección «Jefes»). El armado y el comportamiento se describen en
`docs/guias/comportamiento-de-enemigo.md`, «Un jefe con fases y arena»; ejemplo:
`herramientas/salas/sala_jefe.tscn`.
Un `Porton` también puede abrirse con una `Palanca` o con código que llame a `abrir()` (`nucleo/porton.gd`).

## Si algo falla

- Un enemigo que no se mueve: revisar que la ficha tenga el `comportamiento` y, si camina, `gravedad` mayor que 0
  (con 0 vuela y no tiene suelo; tabla de «Enemigos»).
- Un fallo parecido a uno anterior: `docs/errores/` (por ejemplo `2026-10-17-escupidor-inalcanzable.md` y
  `2026-10-25-hueco-sin-salida-moviles.md`); y `docs/guias/cuando-algo-falla.md`.
