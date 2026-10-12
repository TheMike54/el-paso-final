# Estado

Se sobrescribe; máximo 60 líneas. Rama y PR en curso, bloqueos y decisiones abiertas. El historial está en git.

## Ahora

- Etapa: núcleo cerrado antes de la primera sala (`planes/activos/nucleo-cierre-antes-de-la-sala.md`, fases 0 a 8
  hechas; la 9, la prueba con control real, la hace otro integrante). Probado en el S50 y el S20 el 12-oct-2026: los
  fallos y lo que falta están abajo, en «Arreglos tras la prueba en teléfonos».
- Rama en curso: `fix/telefono-fps-y-controles` (plan `planes/activos/nucleo-arreglos-telefono.md`), sobre
  `feature/nucleo-cierre-antes-de-la-sala` (fases 0 a 8 en dos commits), sobre
  `feature/nucleo-reglas-pendientes`, y debajo las ramas del núcleo hasta `chore/setup`; de
  `feature/herramientas-puerto-guion` sale también `chore/android-export` (presets de 32 y 64 bits y zona de pruebas
  en «Publicacion»). Solo `chore/setup` está subido.
- PR en curso: #1, de `chore/setup` a `main`: aprobado el 11-oct-2026, checks en verde, `qa-pending` quitada sola.
  Falta fusionarlo (squash); después, el rebase de la pila (ensayado el 11-oct-2026), el ruleset y el segundo PR.

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

## Arreglos tras la prueba en teléfonos (12-oct-2026; plan `nucleo-arreglos-telefono.md`, aprobado)

Fallos, por importancia:
1. FPS en el S50 (SC7731E, Mali-T820, 68 MB libres). Los 35-40 jugando del 11-oct-2026 fueron con el teléfono
   caliente: frío, todo va a 59-60 en bajo. En Sala Recursos en alto, jugando (APK de diagnóstico, depuración):
   55,9 normal; 59,4 sin dibujar los controles; 56,8 sin redibujo por arrastre; ~58 sin HUD; Sala Cámara 59,1.
   Controles (~3,5 FPS) y HUD (~2) cuestan por su `_draw`, no por la lógica. Fases B y C del plan; después, medir
   otra vez, también en caliente y en publicación.
2. Multitoque: el panel del S50 (`tlsc6x_touch`, protocolo A) no declara su máximo; por la prueba, 2 toques.
   Falta confirmarlo con `getevent -lt` y 1 a 4 dedos. Regla a escribir en el contrato: ninguna mecánica pide más
   que joystick + un botón. Choca: salto alto (Saltar mantenido) + Atacar, e Impulso + Saltar sin levantar el dedo.
3. Zona de pruebas: unos 33 botones en 3 columnas no caben en 480 px y no se desplazan; quedan fuera la primera
   fila, «Zona Prueba 4» y «Volver al menú». Atrás lleva al menú y no a Configuración.
4. Volumen: el `HSlider` no tiene tamaño mínimo (unos 10 px físicos de alto en el S50); el dedo no le atina.
5. Ícono de guardado en (0.94, 0.9): lo tapaba Saltar. Ya va bajo las PejeCoins (fase C); falta verlo en el S50.

Señales: destello en el parry (hoy solo vibración, 3 ticks de congelado y el golpe); el congelado de daño y de
vencer (4 ticks) no se ve a 45 FPS; marcas en la sala de carrera y color de carrera más fuerte; aviso de brújula;
el caso de QA del ataque en carrera dice qué debe verse. Diseño: banco con Mochila y Mapa grandes; Configuración
táctil en una columna con filas de 72 px; estados del mapa con capturas de Hollow Knight y Silksong.

## Decisiones abiertas

- `ticks_soltar_carrera = 4` (rango 4 a 6): sin queja en la prueba. Plantas y niebla no se paran en el congelado.
- Provisionales: salto, combate y daños. Sin probar: control y paquete firmado. Ícono: se espera al arte.
