# Estado

Se sobrescribe (ver `CLAUDE.md`).

## Ahora

- Rama y PR: `feature/nucleo-menu-tactil`, PR #5 a `main`, en borrador con `qa-pending`; `d0ae986` subido y
  `validar` en verde (13-oct-2026). Un solo PR (decisión del 13-oct-2026): trae `1dc03a4`, `d0ae986` y el commit
  del plan cerrado `nucleo-congelado-y-mapa` (planta y niebla congeladas, `Partida.obtener_mapa`), con título y
  descripción nuevos del #5.
- Orden de lo que sigue (13-oct-2026):
  1. APK nuevo de desarrollo (el de `dev-2026-10-13` ya no coincide) para los issues #3 (tableta y control) y #4
     (teléfono y control); con eso el #5 sale de borrador y lo aprueba otro integrante. El preset «Desarrollo» solo
     está en `chore/android-export`: el APK se exporta en una copia del repo con su `export_presets.cfg`. En
     paralelo, la persona corre en el S50 «Solo 2D y limitador» y «Medir antes de optimizar» de `docs/pruebas.md`.
  2. `chore/android-export` (presets de 32 y 64 bits): está sobre la base vieja; rebase ensayado en una copia y
     su propio PR a `main`.
  3. Tras fusionar el #5: la limpieza de código aprobada (abajo), en un PR desde `main`.
  4. Auditoría de cumplimiento: un repaso de `incumplimientos.md` (copia de análisis de `GODOT_DOCS`, fuera del
     repo) contra el código ya limpio y las medidas del S50; no se repite el contraste completo.

## Preparación del repositorio

Pasos 1 a 6 y 8 cumplidos (detalle en git). El 4 cerró el 12-oct-2026: ruleset `main` activo (solo por PR, 1
aprobación, `validar` en verde, solo Squash and merge, sin force push ni borrado y sin excepciones) y un push
directo a `main` rechazado. Abierto:

| # | Paso | Condición de salida | Estado |
|---|---|---|---|
| 7 | Clon limpio y las tres máquinas | Solo con el README pasan `verificar-entorno.ps1` y `validar.ps1` en cada máquina | Pasa en una máquina; las de los otros dos integrantes se comprueban con la revisión del PR #5 |

## Decisiones de la persona (13-oct-2026)

- El botón táctil con «Inventario» se sale un poco de su círculo: se acepta hasta que lleve una figura. Sin
  «sobrecarga» de amuletos en la v1.
- Sin inventario de objetos por ahora (subiría el guardado a la versión 4). Morir otra vez sin recuperar lo perdido:
  se pierde, como en Hollow Knight. El reto recupera lo perdido; en salas, otro con respuestas físicas.
- La sala de arte entra en `herramientas/salas/` para medir rendimiento con arte real; fondos comprimidos en VRAM.
- Pruebas en teléfono: lo funcional en uno (el S50 si da igual); el S50 y el S20 solo para rendimiento o hardware.
  Las comprobaciones `*-telefono` funcionales ya dicen «en el S50 o el S20».
- Dash hacia abajo descartado (le quitaría su papel a la caída en picada).
- La documentación oficial de Godot 4.7 la clona cada integrante fuera del repo y la nombra `GODOT_DOCS`.
- Después: 120 FPS en gama alta (medir en el S20), sala de música, tienda de PejeCoins, palancas y muros, hablar
  con un NPC tocándolo (solo cerca) y un sonido propio para el daño recibido. Logros fuera de la v1.

## Bloqueos y pendientes

- Prueba con control (12-oct-2026): un integrante con tableta y control, el otro con teléfono y control; cada uno
  anota dispositivo, Android, control y qué filas de `docs/pruebas.md` corrió.
- Ícono del proyecto: lo trabaja la persona, para mucho después.
- Esperan hardware o firma: `menu-desarrollo`, `paquete-publicacion` y `recursos-medicion-publicacion` (keystore),
  `entrada-control` (issues #3 y #4) y `sonidos-telefono`.
- Medido en teléfonos (detalle en `docs/pruebas.md`): sin tope de 30 FPS mientras el S50 sostenga ~45 en bajo; el
  S50 reconoce 2 toques y lo avisa. Provisionales: salto, combate, daños y las señales de carrera, brújula y parry.
- Limpieza de código aprobada (13-oct-2026): hallazgos 11, 2, 5, 4, 6 (útil), 3 (`encima_de`), 7 y 8; no 1, 9, 10.
  Un solo PR desde `main` tras fusionar el #5; plan en `planes/activos/` al crear la rama.
- La caja gris sigue de `sala_inicial` hasta que exista la primera sala real (13-oct-2026).
