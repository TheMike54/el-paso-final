# Estado

Se sobrescribe; máximo 60 líneas. Rama y PR en curso, bloqueos y decisiones abiertas. El historial está en git.

## Ahora

- Etapa: núcleo cerrado antes de la primera sala (`planes/activos/nucleo-cierre-antes-de-la-sala.md`, fases 0 a 8
  hechas; la 9, la prueba con control real, la hace otro integrante). Probado en el S50 y el S20 el 12-oct-2026: los
  fallos y lo que falta están abajo, en «Tras la prueba en teléfonos».
- Rama en curso: `feature/nucleo-parry-carrera-y-aviso-tactil` (plan
  `planes/activos/nucleo-parry-carrera-y-aviso-tactil.md`), sobre `fix/telefono-fps-y-controles` (arreglos tras la
  prueba en teléfonos, tres commits; plan en `planes/cerrados/`), sobre `feature/nucleo-cierre-antes-de-la-sala`,
  y debajo las ramas del núcleo hasta `chore/setup`; de `feature/herramientas-puerto-guion` sale también
  `chore/android-export` (presets de 32 y 64 bits y zona de pruebas en «Publicacion»). Solo `chore/setup` está subido.
- PR en curso: #1, de `chore/setup` a `main`: aprobado el 11-oct-2026, checks en verde. La persona decidió el
  12-oct-2026 no fusionarlo por ahora; propuesta abierta: dejarlo abierto y, con el núcleo y la primera sala listos,
  cerrarlo y abrir un solo PR desde la punta de la pila (evita el rebase de la pila).

## Preparación del repositorio

Pasos 1, 2, 3, 5 y 6 cumplidos (06-oct-2026; detalle en git). Abiertos:

| # | Paso | Condición de salida | Estado |
|---|---|---|---|
| 4 | GitHub: etiqueta, plantillas, CODEOWNERS, workflows, ajustes y primer PR | El PR sale en rojo con un `.gd` roto y en verde al quitarlo; `qa-pending` se pone al abrir y se quita al aprobar; después, ruleset activo y push directo a `main` rechazado | Rojo y verde vistos; `qa-pending` puesta y quitada (11-oct-2026). Falta: fusión, ruleset, push directo rechazado y los guiones en el CI de Linux |
| 7 | Clon limpio y las tres máquinas | Solo con el README pasan `verificar-entorno.ps1` y `validar.ps1` en cada máquina | Pasa en una máquina; faltan las de los otros dos integrantes, con el PR #1 fusionado |
| 8 | Android: preset, APK de depuración, instalación con `adb` | La caja gris corre en el teléfono de prueba; modelo, Android, RAM y FPS en `docs/pruebas.md` | Galaxy S20 a 60 FPS (06-oct-2026); Senwa S50 (Android 13 Go, 32 bits, 1,9 GB) a 59-60 FPS en la caja gris (11-oct-2026); en las salas, ver abajo |

## Decisiones técnicas

- `.gitattributes` con `eol=lf` (hooks de `sh`, CI en Linux); `LICENSE` solo MIT, el arte queda fuera (README).
- `ci.yml` usa `chickensoft-games/setup-godot@v2` sin plantillas; el check obligatorio del ruleset se llama `validar`.
- Dos presets de Android con el id `com.themike54.elpasofinal`, ARM de 32 y 64 bits, en `chore/android-export`.
  «Publicacion» excluye solo `*funciones.json`; «Desarrollo» lleva todo y arranca con `--print-fps`.
- Lo demás que ya está decidido (menú, sala, autoloads, guardado, ajustes) vive en `docs/contrato.md`.

## Tras la prueba en teléfonos (12-oct-2026)

- FPS en el S50: frío, 59-60 en bajo y 58,4 en alto con los arreglos. Sin tope de 30 FPS (decidido el
  12-oct-2026): la prueba en caliente no se hizo; se reabre si una medición sostenida baja de ~45 en bajo. Falta la
  medición en publicación (`recursos-medicion`).
- Multitoque: el S50 reporta 2 toques como máximo. Decidido: el juego no cambia por el teléfono; se avisa con una
  línea discreta si Android no declara 5 o más toques (fase D del plan en curso).
- Parry, ataque en carrera y choque con la pared se ajustan a Silksong y Hollow Knight (fases A a C).
- Señales provisionales hasta el arte: carrera azul claro, postes en la sala de carrera, aviso de brújula y el
  destello del parry.

## Decisiones abiertas

- Siguiente, en este orden: (1) prueba con el dedo de las filas «Carrera, voltereta y pared» y «Parry y congelado» de
  `docs/pruebas.md` (APK de esta rama ya instalado en el S50 y el S20); (2) aprobar las entradas propuestas de
  `nucleo/funciones.json`: `parry-visible`, `carrera-voltereta`, `carrera-rebote-pared` y `aviso-pocos-toques`, con
  los guiones del plan en curso; (3) decidir la propuesta del PR #1 (arriba). Después, un plan aparte para lo de
  «Para después» del plan en curso.

- `ticks_soltar_carrera = 4` (rango 4 a 6): sin queja en la prueba. Plantas y niebla no se paran en el congelado.
- Provisionales: salto, combate y daños. Sin probar: control y paquete firmado. Ícono: se espera al arte.
