# Estado

Se sobrescribe; máximo 60 líneas. Rama y PR en curso, bloqueos y decisiones abiertas. El historial está en git.

## Ahora

- Etapa: núcleo programado y probado en el teléfono; ajustes tras esa prueba, vibración y primer bloque de
  interfaz. Esperan prueba manual las entradas con `"pasa": false` de `nucleo/` e `interfaz/`. La preparación del
  repositorio sigue abierta en los pasos 4, 7 y 8.
- Rama en curso: `feature/nucleo-movimiento-camara-sala`, que sale de `f302dc6`
  (`feature/nucleo-entrada-acciones`) y lleva también el hook al compactar. Planes cerrados:
  `planes/cerrados/nucleo-movimiento-camara-sala.md`, `nucleo-partida-y-habilidades.md`,
  `nucleo-poderes-y-enemigo.md` y `nucleo-ajustes-interfaz-vibracion.md`.
- Debajo, sin subir hasta que el PR #1 esté fusionado: `feature/herramientas-puerto-guion` (sobre `chore/setup`),
  `chore/android-export` y `feature/nucleo-entrada-acciones`, que salen de ella.
- PR en curso: #1, de `chore/setup` a `main`, con los checks en verde.
- Bloqueos: el PR #1 necesita la aprobación de un integrante distinto de quien lo abre.

## Preparación del repositorio

Pasos 1, 2, 3, 5 y 6 cumplidos (06-oct-2026; detalle en git). Abiertos:

| # | Paso | Condición de salida | Estado |
|---|---|---|---|
| 4 | GitHub: etiqueta, plantillas, CODEOWNERS, workflows, ajustes y primer PR | El PR sale en rojo con un `.gd` roto y en verde al quitarlo; `qa-pending` se pone al abrir y se quita al aprobar; después, ruleset activo y push directo a `main` rechazado | En curso: rojo y verde vistos; `qa-pending` puesta al abrir. Falta: aprobación, fusión, ruleset y push directo rechazado. Falta ver los guiones en el CI de Linux |
| 7 | Clon limpio y las tres máquinas | Solo con el README pasan `verificar-entorno.ps1` y `validar.ps1` en cada máquina | Pasa en una máquina; faltan las de los otros dos integrantes, con el PR #1 fusionado |
| 8 | Android: preset, APK de depuración, instalación con `adb` | La caja gris corre en el teléfono de prueba; modelo, Android, RAM y FPS en `docs/pruebas.md` | Medido el 06-oct-2026 en un Galaxy S20 (SM-G980F, Android 13, 7,3 GB): la caja gris y las salas de prueba a 60 FPS (`docs/pruebas.md`). El preset «Desarrollo» sigue solo en `chore/android-export` |

## Decisiones técnicas

- `.gitattributes` con `* text=auto eol=lf`: los hooks de git son scripts de `sh` y el CI corre en Linux.
- `LICENSE` lleva solo el texto MIT estándar para que GitHub lo reconozca; el arte queda fuera (README).
- `ci.yml` usa `chickensoft-games/setup-godot@v2` sin plantillas; el check obligatorio del ruleset se llama `validar`.
- Paso 8: dos presets de Android con el id `com.themike54.elpasofinal`. «Publicacion» excluye `herramientas/*` y
  `*funciones.json`; «Desarrollo» lleva todo y arranca con `--print-fps`.
- La escena principal es el menú (`nucleo/menu.tscn`); la caja gris queda como destino de Nueva partida hasta que
  exista la primera sala del juego.
- Guiones: línea `escena` y claves `valor` y `senal`; las pruebas sin jugador son escenas de `herramientas/salas/`
  que dejan `casos` y `fallos`. Lo que responde a un guion lee la acción, no el evento.
- La sala crea al jugador, los controles, la pausa, la vibración y la interfaz. Al morir, el jugador reaparece en
  el último banco o en la `Entrada`; un peligro lo devuelve a su último suelo firme (aceptado el 06-oct-2026).
- Autoloads `Eventos` (doce señales del contrato) y `Partida` (vidas, habilidades y enemigos fuertes vencidos,
  que sobreviven al cambio de sala; avisa cada cambio de vidas e Inspiración), los dos antes de `Arranque`.
- Interfaz en su bloque (`interfaz/`): escucha el bus y lee `Partida` al entrar; la sala la carga con `load()`.
- Ajustes del teléfono (vibración) en `user://ajustes.json`, aparte de la partida; sin pantalla de Opciones.
- `curar` es el botón de poderes: tocar lanza la bola, mantener cura, abajo en el aire es la caída en picada;
  abajo + atacar en el aire es el pogo. Enemigos débiles reaparecen al volver a entrar; fuertes, al descansar.
- Guardado: funciones estáticas, sin autoload; esquema versión 2 (`banco`, `sala`, `vidas_maximas`, `habilidades`);
  cualquier otra versión es incompatible, sin migración. El banco guarda al descansar.

## Decisiones abiertas

- Valores iniciales del salto y del combate: los afina la persona en la zona de pruebas.
- Plataformas atravesables desde abajo: solo en la sala de prueba de la cámara; sin decidir para el juego.
- Qué es la bola en el mundo y dónde se obtiene (hoy, habilidad `proyectil` en la sala de prueba).
- Si morir hace reaparecer a los fuertes (hoy no; sin fuente de Hollow Knight) y si un suelo frágil roto se guarda.
- Vibración activada por omisión, y sus patrones; el preset de Android de `chore/android-export` todavía no pide el
  permiso `VIBRATE`.
- Valores nuevos sin fuente de Hollow Knight: caída en dos tramos, recarga de la bola, onda de la picada.
- Ícono del proyecto: abierta hasta tener arte (sin ícono, la exportación imprime un `ERROR:` y genera el APK).
