# Estado

Se sobrescribe; máximo 60 líneas. Rama y PR en curso, bloqueos y decisiones abiertas. El historial está en git.

## Ahora

- Etapa: núcleo programado y probado en el teléfono, con botones táctiles configurables y Configuración en el menú.
  Con `"pasa": false` quedan `menu-desarrollo` (cambia con el modo desarrollador) y `entrada-control` (la prueba otro
  integrante). Reglas pendientes de la auditoría: hechas y probadas (`planes/cerrados/nucleo-reglas-pendientes.md`).
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
- Autoloads `Eventos` (catorce señales del contrato) y `Partida` (vidas, habilidades y enemigos fuertes vencidos),
  los dos antes de `Arranque`. Interfaz en su bloque (`interfaz/`), cargada con `load()`.
- Ajustes del teléfono (vibración, temblor y disposición de los botones) en `user://ajustes.json`, aparte de la partida.
- `curar` es el botón de poderes: tocar lanza la bola, mantener cura, abajo en el aire es la caída en picada;
  abajo + atacar en el aire es el pogo. Débiles reaparecen al volver a entrar; fuertes, al descansar o morir.
- Guardado: funciones estáticas, sin autoload; esquema versión 2 (`banco`, `sala`, `vidas_maximas`, `habilidades`);
  cualquier otra versión es incompatible, sin migración. El banco guarda al descansar.

## Decisiones abiertas

- Decidido por la persona (11-oct-2026), para cerrar el núcleo antes de la primera sala (La Celda 1): ataque
  hacia arriba, cola del ataque, congelado común, morir vacía la Inspiración, estado persistente por sala (cubre el
  suelo frágil), autoguardado (habilidad, jefe, amuleto, morir, salir al menú, app en segundo plano; guarda lo
  obtenido y se reaparece en el banco; ícono abajo a la derecha), enemigo = ficha + script, sin ataque hasta la
  Pluma, Configuración (Controles con reasignación del control, Vibración, Temblor, Bajo detalle, Volumen, Modo
  desarrollador, Borrar partida, Créditos) y menús con control y teclado. El control se prueba al final.
- Parry (choque con ataques enemigos de rastro blanco): abierto; falta decidir si va antes de la primera sala.
- Abiertos con investigación en curso: impulso como el de Silksong (con sprint; táctil con «mantener / alternar»)
  y qué peligros devuelven al suelo firme y cuáles solo quitan vida.
- Modo desarrollador (plan sin aprobar; espera): sale a producción con el modo disponible; el interruptor va en
  Configuración y muestra las opciones de desarrollador (persona, 11-oct-2026). Cambia una decisión cerrada.
- Provisionales: salto, combate, onda de la picada y demás daños. Sin probar: control y paquete firmado (sin keystore).
  Ícono: se espera al arte (sin él, la exportación imprime un `ERROR:`).
