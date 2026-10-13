# Estado

Se sobrescribe (ver `CLAUDE.md`).

## Ahora

- Etapa: núcleo cerrado antes de la primera sala (plan en `planes/cerrados/nucleo-cierre-antes-de-la-sala.md`; la
  prueba con control real es la entrada `entrada-control`).
- Rama en curso: `feature/nucleo-menu-tactil`, rebasada sobre `main` y subida (30 commits); `chore/android-export`
  (presets de 32 y 64 bits) rebasada en local, sin subir. Sin planes activos: los de esta etapa están en
  `planes/cerrados/`.
- PR en curso: #5, de `feature/nucleo-menu-tactil` a `main`, en borrador con `qa-pending` y `validar` en verde
  (13-oct-2026). Sale de borrador cuando pasen las pruebas de los issues #3 (tableta y control) y #4 (teléfono y
  control), con el APK de la prerelease `dev-2026-10-13`; después lo aprueba uno de los otros dos integrantes. El
  PR #1 se fusionó el 13-oct-2026 (`edfd322`).

## Preparación del repositorio

Pasos 1 a 6 y 8 cumplidos (detalle en git). El 4 cerró el 13-oct-2026: ruleset `main` activo (solo por PR, 1
aprobación, `validar` en verde, solo Squash and merge, sin force push ni borrado y sin excepciones) y un push
directo a `main` rechazado. Abierto:

| # | Paso | Condición de salida | Estado |
|---|---|---|---|
| 7 | Clon limpio y las tres máquinas | Solo con el README pasan `verificar-entorno.ps1` y `validar.ps1` en cada máquina | Pasa en una máquina; las de los otros dos integrantes se comprueban con la revisión del PR #5 |

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

- Prueba con control (confirmada el 12-oct-2026): un integrante con su tableta y control, el otro con su teléfono y
  control, con las filas repartidas entre los dos; cada uno anota modelo exacto del dispositivo, Android, modelo del
  control y qué filas de `docs/pruebas.md` corrió.
- Esperan hardware o firma: `menu-desarrollo` y `paquete-publicacion` (keystore), `entrada-control` (control),
  `autoguardado-segundo-plano` y `recursos-medicion-publicacion` (teléfono).
- Provisionales: salto, combate y daños. Ícono del proyecto: se espera al arte.
- Después del PR: un plan aparte para lo de «Para después» de `planes/cerrados/nucleo-parry-carrera-y-aviso-tactil.md`.
