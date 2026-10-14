# Estado

Se sobrescribe (ver `CLAUDE.md`).

## Ahora

- Rama y PR: `feature/nucleo-menu-tactil`, PR #5 a `main`, en borrador con `qa-pending`; `d0ae986` subido y
  `validar` en verde (13-oct-2026). Un solo PR (decisión del 13-oct-2026): trae `1dc03a4`, `d0ae986` y el commit
  del plan cerrado `nucleo-congelado-y-mapa` (planta y niebla congeladas, `Partida.obtener_mapa`), con título y
  descripción nuevos del #5.
- Orden de lo que sigue (13-oct-2026):
  1. Issues #3 (tableta y control) y #4 (teléfono y control). El #4 respondió el 13-oct-2026 con el APK viejo
     (`114908b`): movimiento bien; con el control, A / Cruz no pulsaba los botones de los menús
     (`docs/errores/2026-10-13-control-no-acepta-en-menus.md`, arreglo para el #5); repite todo con el APK nuevo.
     El #3 respondió el 14-oct-2026 (tableta, APK `5d377b4`): un fallo real, saltar justo antes de una puerta la
     pasa por encima y cae fuera de la sala (reproducido con un guion; arreglo para el #5); la parte del control de
     la fila 12 y la fila 18 faltan. Si pasan, el #5 sale de borrador y lo aprueba otro integrante. Un APK nuevo se exporta en una copia del repo con el `export_presets.cfg` de
     `chore/android-export` (único lugar del preset «Desarrollo»).
  2. `chore/android-export` (presets de 32 y 64 bits): está sobre la base vieja; rebase ensayado en una copia y
     su propio PR a `main`.
  3. Limpieza de código hecha (plan cerrado `planes/cerrados/nucleo-limpieza.md`) en `chore/limpieza-codigo`,
     encima del #5; un segundo commit con las mejoras menores de la auditoría (enums, tamaños de letra sobrantes,
     `##` en los `@export`, constante del grupo `jugador`, la frase de `Area2D` en el proyectil). Tras fusionar el
     #5, rebase `--onto` a `main` y su PR.
  4. Antes de la primera sala real: plan de capas de física con nombre (escenario, jugador, enemigos,
     recogibles, proyectiles) y repaso de lo que ya existe; el foco de los menús visible solo con control o
     teclado. Salas con rectángulos `StaticBody2D`, sin tiles, un rectángulo por superficie continua (decidido el
     13-oct-2026). Decidido el 14-oct-2026: arte pintado a 1x (personaje de 160 px), sin encoger en la escena;
     compresión VRAM solo en fondos opacos grandes, sin pérdida en lo demás; mipmaps y filtro «Linear Mipmap» en
     el arte del mundo (no en el HUD); Claude escribe cada sala completa como `.tscn`; las puertas apuntan al id
     de la sala; sin carga en segundo plano. Por decidir: guardado ante una versión nueva, catálogo de ids,
     enemigos, jefes, audio, exportación e idioma.

## Preparación del repositorio

Pasos 1 a 8 cumplidos (detalle en git). El 7 cerró el 14-oct-2026: la tercera máquina pasó
`verificar-entorno.ps1` y `validar.ps1` desde un clon limpio (en el #5). Ruleset `main` activo desde el
12-oct-2026: solo por PR, 1 aprobación, `validar` en verde, solo Squash and merge, sin force push ni borrado.

## Decisiones de la persona (13 y 14-oct-2026)

- El botón táctil con «Inventario» se sale un poco de su círculo: se acepta hasta que lleve una figura. Sin
  «sobrecarga» de amuletos en la v1. Sin inventario de objetos por ahora (subiría el guardado a la versión 4).
- Morir otra vez sin recuperar lo perdido: se pierde. El reto recupera lo perdido; en salas, otro con respuestas físicas.
- La sala de arte entra en `herramientas/salas/` para medir rendimiento con arte real; fondos comprimidos en VRAM.
- Pruebas en teléfono: lo funcional en uno (el S50 si da igual); el S50 y el S20 solo para rendimiento o hardware.
- Dash hacia abajo descartado. La documentación de Godot 4.7 la clona cada integrante y la nombra `GODOT_DOCS`.
- La dificultad del salto en pared se queda. El color del foco no es definitivo. Un `Fondo` opaco solo donde haga
  falta. La skill de animación se escribe con el primer sprite animado.
- Después: 120 FPS en gama alta (medir en el S20), sala de música, tienda de PejeCoins, palancas y muros, hablar
  con un NPC tocándolo (solo cerca) y un sonido propio para el daño recibido. Logros fuera de la v1.

## Bloqueos y pendientes

- Ícono del proyecto: lo trabaja la persona, para mucho después.
- Esperan hardware o firma: `menu-desarrollo`, `paquete-publicacion` y `recursos-medicion-publicacion` (keystore),
  `entrada-control` (issues #3 y #4) y `sonidos-telefono`.
- Medido en teléfonos (detalle en `docs/pruebas.md`): sin tope de 30 FPS mientras el S50 sostenga ~45 en bajo; el
  S50 reconoce 2 toques y lo avisa. Provisionales: salto, combate, daños y las señales de carrera, brújula y parry.
- La caja gris sigue de `sala_inicial` hasta que exista la primera sala real (13-oct-2026).
