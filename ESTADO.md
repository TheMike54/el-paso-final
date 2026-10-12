# Estado

Se sobrescribe; máximo 60 líneas. Rama y PR en curso, bloqueos y decisiones abiertas. El historial está en git.

## Ahora

- Etapa: núcleo programado y probado en el teléfono, con botones táctiles configurables y Configuración en el menú.
  Con `"pasa": false` quedan `menu-desarrollo` (cambia con el modo desarrollador), `entrada-control` (la prueba otro
  integrante) y `autoguardado-segundo-plano` (en el teléfono). Reglas pendientes de la auditoría: hechas y probadas (`planes/cerrados/nucleo-reglas-pendientes.md`).
- Rama en curso: `feature/nucleo-reglas-pendientes`, que sale de `b096585` (`feature/nucleo-configuracion-menu`).
  Debajo, en línea: `feature/nucleo-controles-configurables`, `feature/nucleo-movimiento-camara-sala` y
  `feature/nucleo-entrada-acciones`, sobre `feature/herramientas-puerto-guion` (sobre `chore/setup`); de esta sale
  también `chore/android-export`. Nada de eso está subido. Los planes terminados están en `planes/cerrados/`.
- PR en curso: #1, de `chore/setup` a `main`: aprobado el 11-oct-2026 por otro integrante, checks en verde,
  `qa-pending` quitada sola. Falta fusionarlo (squash); después, el rebase de la pila (ensayado de nuevo el
  11-oct-2026), el ruleset y el segundo PR.

## Preparación del repositorio

Pasos 1, 2, 3, 5 y 6 cumplidos (06-oct-2026; detalle en git). Abiertos:

| # | Paso | Condición de salida | Estado |
|---|---|---|---|
| 4 | GitHub: etiqueta, plantillas, CODEOWNERS, workflows, ajustes y primer PR | El PR sale en rojo con un `.gd` roto y en verde al quitarlo; `qa-pending` se pone al abrir y se quita al aprobar; después, ruleset activo y push directo a `main` rechazado | Rojo y verde vistos; `qa-pending` puesta al abrir y quitada al aprobar (11-oct-2026). Falta: fusión, ruleset, push directo rechazado y ver los guiones en el CI de Linux |
| 7 | Clon limpio y las tres máquinas | Solo con el README pasan `verificar-entorno.ps1` y `validar.ps1` en cada máquina | Pasa en una máquina; faltan las de los otros dos integrantes, con el PR #1 fusionado |
| 8 | Android: preset, APK de depuración, instalación con `adb` | La caja gris corre en el teléfono de prueba; modelo, Android, RAM y FPS en `docs/pruebas.md` | Galaxy S20 (06-oct-2026) a 60 FPS. Senwa S50 (Android 13 Go, solo 32 bits, 1,9 GB): salas jugadas a 59-60 FPS (11-oct-2026). Los dos presets con 32 y 64 bits, sin commit en `chore/android-export` |

## Decisiones técnicas

- `.gitattributes` con `eol=lf` (hooks de `sh`, CI en Linux); `LICENSE` solo MIT, el arte queda fuera (README).
- `ci.yml` usa `chickensoft-games/setup-godot@v2` sin plantillas; el check obligatorio del ruleset se llama `validar`.
- Paso 8: dos presets de Android con el id `com.themike54.elpasofinal`, los dos para ARM de 32 y 64 bits (11-oct-2026).
  «Publicacion» excluye `herramientas/*` y `*funciones.json`; «Desarrollo» lleva todo y arranca con `--print-fps`.
- La escena principal es el menú (`nucleo/menu.tscn`), con Configuración (hoy, Controles); la caja gris queda como
  destino de Nueva partida hasta que exista la primera sala del juego.
- La sala crea al jugador, los controles, la pausa, la vibración y la interfaz. Al morir, el jugador reaparece en
  el último banco o en la `Entrada`; un peligro lo devuelve a su último suelo firme.
- Autoloads `Eventos` (dieciocho señales del contrato) y `Partida` (vidas, habilidades y enemigos fuertes vencidos),
  los dos antes de `Arranque`. Interfaz en su bloque (`interfaz/`), cargada con `load()`.
- Ajustes del teléfono (vibración, temblor y disposición de los botones) en `user://ajustes.json`, aparte de la partida.
- `curar` es el botón de poderes: tocar lanza la bola, mantener cura, abajo en el aire es la caída en picada;
  abajo + atacar en el aire es el pogo. Débiles reaparecen al volver a entrar; fuertes, al descansar o morir.
- Guardado: funciones estáticas, sin autoload; esquema versión 3, como Hollow Knight y Silksong (tabla en
  `docs/contrato.md`); cualquier otra versión es incompatible, sin migración. Guarda el banco y se autoguarda lo obtenido.

## Decisiones abiertas

- Tanda en curso (aprobada por la persona el 11-oct-2026): `planes/activos/nucleo-cierre-antes-de-la-sala.md`, fases
  0 a 8 antes de La Celda 1, con todas las decisiones y su porqué. Cambia dos decisiones cerradas (enemigo = ficha +
  script; mandar la app al fondo guarda), resueltas en su sección 2.
- Modo desarrollador: lo absorbe la fase 6 de esa tanda (sale a producción con el interruptor en Configuración).
- Provisionales: salto, combate, onda de la picada y demás daños. Sin probar: control y paquete firmado (sin keystore).
  Ícono: se espera al arte (sin él, la exportación imprime un `ERROR:`).
