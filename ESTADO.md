# Estado

Se sobrescribe (ver `CLAUDE.md`).

## Ahora

- Etapa: «Para después» de `planes/cerrados/nucleo-parry-carrera-y-aviso-tactil.md` (13-oct-2026). Cerrados sin
  commit: ranuras, audio y brillo, amuletos, personaje y nombre, diálogo, reto y efectos (`planes/cerrados/`).
  Abierto: 120 FPS en gama alta (decisión de la persona; medir en el S20). Dash hacia abajo descartado el
  13-oct-2026 (le quitaría su papel a la caída en picada); la regla «nunca» sigue.
- Rama en curso: `feature/nucleo-menu-tactil`, rebasada sobre `main` y subida (30 commits); `chore/android-export`
  (presets de 32 y 64 bits) rebasada en local, sin subir. Encima, `fix/nucleo-menu-aviso-y-autoguardado` sin
  commit: se acumula sin commits hasta tener un cambio grande y entonces se decide a qué rama va (12-oct-2026).
- PR en curso: #5, de `feature/nucleo-menu-tactil` a `main`, en borrador con `qa-pending` y `validar` en verde
  (12-oct-2026). Sale de borrador cuando pasen las pruebas de los issues #3 (tableta y control) y #4 (teléfono y
  control), con el APK de la prerelease `dev-2026-10-13`; después lo aprueba uno de los otros dos integrantes. El
  PR #1 se fusionó el 12-oct-2026 (`edfd322`).

## Preparación del repositorio

Pasos 1 a 6 y 8 cumplidos (detalle en git). El 4 cerró el 12-oct-2026: ruleset `main` activo (solo por PR, 1
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

## Decisiones de la persona (13-oct-2026)

- Menús: un marco con páginas Inventario · Amuletos · Mapa (fuera de la pausa). El botón táctil de mapa dice
  «Mapa» de pie y abre en Mapa; sentado dice «Inventario» y abre en Amuletos; el botón «Mochila» se borra y la
  acción `mochila` pasa a `inventario` con migración. Inventario muestra solo lo que ya existe. El juego se
  detiene con el marco abierto; la pausa queda Continuar · Configuración · Salir al menú; sin «sobrecarga» de
  amuletos en la v1. Va en el commit siguiente, con su plan.
- Sin inventario de objetos por ahora (subiría el guardado a la versión 4). Morir otra vez sin recuperar lo perdido:
  se pierde, como en Hollow Knight. El reto recupera lo perdido; en salas, otro con respuestas físicas.
- `docs/licencias.md` se reemplaza por `docs/uso-de-ia.md` (herramientas por tipo, no archivo por archivo).
- La sala de arte entra en `herramientas/salas/` para medir rendimiento con arte real; fondos comprimidos en VRAM.
- Configuración (mockup del 13-oct-2026): sin interruptores, valor en pastilla y Recursos por toques; volumen con
  barra ancha sin «−» ni «+»; brillo en su pantalla, como Hollow Knight, con escena y cuadro de calibración. Después:
  120 FPS, sala de música, tienda de PejeCoins, palancas y muros. Logros fuera de la v1; se sigue con el núcleo.

## Bloqueos y pendientes

- Prueba con control (12-oct-2026): un integrante con tableta y control, el otro con teléfono y control; cada uno
  anota dispositivo, Android, control y qué filas de `docs/pruebas.md` corrió.
- Esperan hardware o firma: `menu-desarrollo`, `paquete-publicacion` y `recursos-medicion-publicacion` (keystore),
  `entrada-control` (issues #3 y #4) y, en el S50 y el S20, las entradas `*-telefono` de `nucleo/funciones.json`.
- Medido en teléfonos (detalle en `docs/pruebas.md`): sin tope de 30 FPS mientras el S50 sostenga ~45 en bajo; el
  S50 reconoce 2 toques y lo avisa. Provisionales: salto, combate, daños y las señales de carrera, brújula y parry.
- Ícono del proyecto: lo trabaja la persona.
