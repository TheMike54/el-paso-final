# Estado

Se sobrescribe (ver `CLAUDE.md`).

## Ahora

- Etapa: núcleo cerrado antes de la primera sala (plan en `planes/cerrados/nucleo-cierre-antes-de-la-sala.md`; la
  prueba con control real es la entrada `entrada-control`).
- Rama en curso: `docs/limpieza-auditoria` (plan cerrado en `planes/cerrados/docs-limpieza-auditoria.md`), sobre
  `feature/nucleo-parry-carrera-y-aviso-tactil` (plan `planes/activos/nucleo-parry-carrera-y-aviso-tactil.md`), sobre
  `fix/telefono-fps-y-controles`, `feature/nucleo-cierre-antes-de-la-sala` y las ramas del núcleo hasta
  `chore/setup`; de `feature/herramientas-puerto-guion` sale también `chore/android-export` (presets de 32 y 64 bits
  y zona de pruebas en «Publicacion»). Solo `chore/setup` está subido.
- PR en curso: #1, de `chore/setup` a `main`: aprobado el 11-oct-2026, checks en verde. Decidido el 12-oct-2026
  (noche), antes de cerrarlo se terminan los pendientes: fusionarlo con Squash and merge (sin `--delete-branch`:
  `chore/setup` es la frontera del rebase), rebasar la pila sobre `main` (ensayar antes en un clon), ruleset, y un
  PR con la pila. La prueba con control la hacen los otros dos integrantes en el teléfono, con un APK fuera del repo
  y un issue en inglés; la guía para su Claude va en la bóveda.

## Preparación del repositorio

Pasos 1, 2, 3, 5, 6 y 8 cumplidos (detalle en git). Abiertos:

| # | Paso | Condición de salida | Estado |
|---|---|---|---|
| 4 | GitHub: etiqueta, plantillas, CODEOWNERS, workflows, ajustes y primer PR | El PR sale en rojo con un `.gd` roto y en verde al quitarlo; `qa-pending` se pone al abrir y se quita al aprobar; después, ruleset activo y push directo a `main` rechazado | Rojo y verde vistos; `qa-pending` puesta y quitada (11-oct-2026). Falta: fusión, ruleset, push directo rechazado y ver los guiones en verde en un PR (el paso «Input scripts» ya está en `ci.yml`) |
| 7 | Clon limpio y las tres máquinas | Solo con el README pasan `verificar-entorno.ps1` y `validar.ps1` en cada máquina | Pasa en una máquina; faltan las de los otros dos integrantes, con el PR #1 fusionado |

## Decisiones técnicas

- `.gitattributes` con `eol=lf` (hooks de `sh`, CI en Linux); `LICENSE` solo MIT, el arte queda fuera (README).
- `ci.yml` usa `chickensoft-games/setup-godot@v2` sin plantillas; el check obligatorio del ruleset se llama `validar`.
- Dos presets de Android con el id `com.themike54.elpasofinal`, ARM de 32 y 64 bits, en `chore/android-export`.
  «Publicacion» excluye solo `*funciones.json`; «Desarrollo» lleva todo y arranca con `--print-fps`.
- Lo demás que ya está decidido (menú, sala, autoloads, guardado, ajustes) vive en `docs/contrato.md`.

## Tras la prueba en teléfonos (12-oct-2026)

- FPS en el S50 en depuración, frío: 59-60 en bajo y 58,4 en alto. Sin tope de 30 FPS: se reabre si una medición
  sostenida baja de ~45 en bajo (`recursos-medicion-publicacion`).
- Multitoque: el S50 reporta 2 toques como máximo; el juego no cambia y avisa con una línea (`aviso-pocos-toques`).
- Señales provisionales hasta el arte: carrera azul claro, postes en la sala de carrera, aviso de brújula y el
  destello del parry.

## Bloqueos y pendientes

- Pruebas con el dedo del 12-oct-2026 (S50) anotadas en `docs/pruebas.md`. Arreglados la estocada repetible y el
  empuje que sacaba al enemigo de la sala (fase E del plan del parry); falta repetir eso y el congelado con el APK
  nuevo. El plan del parry se cierra tras esa prueba.
- Planes sin aprobar para código (12-oct-2026): `planes/activos/nucleo-menu-tactil.md` (menús a 48 dp, reglas para
  4:3 a 22:9, zona de pruebas en el menú de inicio, aviso «Conecta un control») y
  `planes/activos/herramientas-zona-pruebas-categorias.md`. La persona aprobó la maqueta y tomó las recomendaciones
  (zona de pruebas en el menú de inicio, sin grupo «Habilidades»). Van antes del PR (12-oct-2026).
- Prueba con control (decisión del 12-oct-2026): un integrante con su tableta y control, el otro con su teléfono y
  control; cada uno anota modelo exacto del dispositivo, Android, modelo del control y qué filas de
  `docs/pruebas.md` corrió, para comparar.
- Esperan hardware o firma: `menu-desarrollo` y `paquete-publicacion` (keystore), `entrada-control` (control),
  `autoguardado-segundo-plano` y `recursos-medicion-publicacion` (teléfono).
- Provisionales: salto, combate y daños. Ícono del proyecto: se espera al arte.
- Después de esta rama: un plan aparte para lo de «Para después» del plan del parry.
