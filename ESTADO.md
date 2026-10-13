# Estado

Se sobrescribe (ver `CLAUDE.md`).

## Ahora

- Etapa: «Para después» de `planes/cerrados/nucleo-parry-carrera-y-aviso-tactil.md` (13-oct-2026). Cerrados sin
  commit: ranuras, audio y brillo, amuletos, personaje y nombre, diálogo, reto, efectos y marco de menús
  (`planes/cerrados/`). Dash hacia abajo descartado el 13-oct-2026 (le quitaría su papel a la caída en picada).
- Rama del PR #5: `feature/nucleo-menu-tactil`. Decisión del 13-oct-2026: un solo PR. Lo de
  `feature/nucleo-ranuras-dialogo-y-reto` (`1dc03a4` y, en un commit, el marco de menús, la tanda A de la auditoría
  de código, la documentación local de Godot, las skills y los arreglos del contraste) se sube a esa rama y entra
  en el #5; después, en un segundo commit, la decoración congelada en el hit-stop y `Partida.obtener_mapa`.
  `chore/android-export` (presets de 32 y 64 bits) sigue aparte, sobre la base vieja: necesita rebase antes de su PR.
- PR en curso: #5, de `feature/nucleo-menu-tactil` a `main`, en borrador con `qa-pending`. Sale de borrador cuando
  pasen las pruebas de los issues #3 (tableta y control) y #4 (teléfono y control) con un APK nuevo que incluya
  todo (el de `dev-2026-10-13` ya no coincide); su título y descripción se reescriben para cubrirlo todo. Después lo
  aprueba uno de los otros dos integrantes. El PR #1 se fusionó el 12-oct-2026 (`edfd322`).

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
- La documentación oficial de Godot 4.7 la clona cada integrante fuera del repo y la nombra `GODOT_DOCS`.
- Después: 120 FPS en gama alta (medir en el S20), sala de música, tienda de PejeCoins, palancas y muros, hablar
  con un NPC tocándolo (solo cerca) y un sonido propio para el daño recibido. Logros fuera de la v1.

## Bloqueos y pendientes

- Prueba con control (12-oct-2026): un integrante con tableta y control, el otro con teléfono y control; cada uno
  anota dispositivo, Android, control y qué filas de `docs/pruebas.md` corrió.
- Ícono del proyecto: lo trabaja la persona. Esperan hardware o firma: `menu-desarrollo`, `paquete-publicacion` y `recursos-medicion-publicacion` (keystore),
  `entrada-control` (issues #3 y #4) y `sonidos-telefono`.
- Medido en teléfonos (detalle en `docs/pruebas.md`): sin tope de 30 FPS mientras el S50 sostenga ~45 en bajo; el
  S50 reconoce 2 toques y lo avisa. Provisionales: salto, combate, daños y las señales de carrera, brújula y parry.
- Limpieza de código aprobada (13-oct-2026): hallazgos 11, 2, 5, 4, 6 (útil), 3 (`encima_de`), 7 y 8; no 1, 9, 10.
  Un solo PR desde `main` tras fusionar el #5; plan en `planes/activos/` al crear la rama.
- Decisiones de diseño (13-oct-2026): la caja gris sigue de `sala_inicial` hasta que exista la primera sala real;
  la planta y la niebla se detienen en el congelado común; recoger un mapa avisa y autoguarda
  (`Partida.obtener_mapa`). Las dos últimas, en el segundo commit del #5.
- Contraste de la documentación de Godot con el repo (13-oct-2026), cerrado sin commit:
  `herramientas-hallazgos-documentacion` (validador de texturas y de capas translúcidas, `disable_3d`, limitador en
  Master, salir avisando el cierre, reglas escritas) y `herramientas-skills-godot` (`gdscript4` ampliada;
  `ui-tactil`, `fisica-2d` y `rendimiento-gama-baja` nuevas). Pruebas manuales que faltan: FPS del S50 con
  `disable_3d`, oír el limitador y la fila «Medir antes de optimizar (S50)» de `docs/pruebas.md`. La auditoría de
  cumplimiento va después de la limpieza aprobada.
