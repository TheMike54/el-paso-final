# Estado

Se sobrescribe; máximo 60 líneas. Rama y PR en curso, bloqueos y decisiones abiertas. El historial está en git.

## Ahora

- Etapa: núcleo programado y probado en el teléfono; ajustes tras esa prueba, vibración y primer bloque de
  interfaz. Con `"pasa": false` quedan `menu-desarrollo` (cambia con el modo desarrollador) y `entrada-control`
  (la prueba otro integrante: la persona no tiene control) en `nucleo/`, y `etiqueta-qa-pending` en `herramientas/`. La preparación del repositorio sigue abierta en los pasos 4, 7 y 8.
- Rama en curso: `feature/nucleo-configuracion-menu`, que sale de `8649c73` (`feature/nucleo-controles-configurables`,
  sobre `feature/nucleo-movimiento-camara-sala`, que sale de `f302dc6`, `feature/nucleo-entrada-acciones`). Los planes terminados están en `planes/cerrados/`.
- Debajo, sin subir hasta que el PR #1 esté fusionado: `feature/herramientas-puerto-guion` (sobre `chore/setup`),
  `chore/android-export` y `feature/nucleo-entrada-acciones`, que salen de ella, y `feature/nucleo-movimiento-camara-sala` y `feature/nucleo-controles-configurables`.
- PR en curso: #1, de `chore/setup` a `main`, checks en verde. Bloqueo: necesita la aprobación de otro integrante.

## Preparación del repositorio

Pasos 1, 2, 3, 5 y 6 cumplidos (06-oct-2026; detalle en git). Abiertos:

| # | Paso | Condición de salida | Estado |
|---|---|---|---|
| 4 | GitHub: etiqueta, plantillas, CODEOWNERS, workflows, ajustes y primer PR | El PR sale en rojo con un `.gd` roto y en verde al quitarlo; `qa-pending` se pone al abrir y se quita al aprobar; después, ruleset activo y push directo a `main` rechazado | En curso: rojo y verde vistos; `qa-pending` puesta al abrir. Falta: aprobación, fusión, ruleset y push directo rechazado. Falta ver los guiones en el CI de Linux |
| 7 | Clon limpio y las tres máquinas | Solo con el README pasan `verificar-entorno.ps1` y `validar.ps1` en cada máquina | Pasa en una máquina; faltan las de los otros dos integrantes, con el PR #1 fusionado |
| 8 | Android: preset, APK de depuración, instalación con `adb` | La caja gris corre en el teléfono de prueba; modelo, Android, RAM y FPS en `docs/pruebas.md` | Medido el 06-oct-2026 en un Galaxy S20 (SM-G980F, Android 13, 7,3 GB): la caja gris y las salas de prueba a 60 FPS (`docs/pruebas.md`). El 09-oct-2026, en un Senwa S50 (Android 13 Go, solo 32 bits, 1,9 GB, Mali-T820), el APK de «Desarrollo» para 32 y 64 bits se instala y arranca a 59-60 FPS los primeros 6 s; falta jugar una sala. El preset «Desarrollo» sigue solo en `chore/android-export`, y el cambio de 32 bits, sin commit |

## Decisiones técnicas

- `.gitattributes` con `* text=auto eol=lf`: los hooks de git son scripts de `sh` y el CI corre en Linux.
- `LICENSE` lleva solo el texto MIT estándar para que GitHub lo reconozca; el arte queda fuera (README).
- `ci.yml` usa `chickensoft-games/setup-godot@v2` sin plantillas; el check obligatorio del ruleset se llama `validar`.
- Paso 8: dos presets de Android con el id `com.themike54.elpasofinal`. «Publicacion» excluye `herramientas/*` y
  `*funciones.json`; «Desarrollo» lleva todo, arranca con `--print-fps` y compila para ARM de 32 y 64 bits.
- La escena principal es el menú (`nucleo/menu.tscn`); la caja gris queda como destino de Nueva partida hasta que
  exista la primera sala del juego; tiene un botón para volver al menú (decidido el 06-oct-2026).
- Guiones: línea `escena` y claves `valor` y `senal`; las pruebas sin jugador son escenas de `herramientas/salas/`
  que dejan `casos` y `fallos`. Lo que responde a un guion lee la acción, no el evento.
- La sala crea al jugador, los controles, la pausa, la vibración y la interfaz. Al morir, el jugador reaparece en
  el último banco o en la `Entrada`; un peligro lo devuelve a su último suelo firme (aceptado el 06-oct-2026).
- Autoloads `Eventos` (trece señales del contrato) y `Partida` (vidas, habilidades y enemigos fuertes vencidos,
  que sobreviven al cambio de sala; avisa cada cambio de vidas e Inspiración), los dos antes de `Arranque`.
- Interfaz en su bloque (`interfaz/`): escucha el bus y lee `Partida` al entrar; la sala la carga con `load()`.
- Ajustes del teléfono (vibración y temblor) en `user://ajustes.json`, aparte de la partida; sin pantalla de Opciones.
- `curar` es el botón de poderes: tocar lanza la bola, mantener cura, abajo en el aire es la caída en picada;
  abajo + atacar en el aire es el pogo. Enemigos débiles reaparecen al volver a entrar; fuertes, al descansar.
- Guardado: funciones estáticas, sin autoload; esquema versión 2 (`banco`, `sala`, `vidas_maximas`, `habilidades`);
  cualquier otra versión es incompatible, sin migración. El banco guarda al descansar.

## Decisiones abiertas

- Decidido por la persona el 07-oct-2026, sin programar: plataformas todas sólidas (las 5 atravesables de
  `sala_camara`/`sala_capas`); pinchos con suelo firme + anti-bucle de Silksong (peligro antes de 0,5 s: a la
  puerta, sin perder vida); morir repone a los fuertes; vibración y pausa al perder el foco, como están (filas 5 a 8
  de la auditoría). Inspiración máxima 99, cerrada. Zona de pruebas en publicación tras «Modo desarrollador» (cambia
  una decisión cerrada; plan sin aprobar). Botones táctiles configurables: hechos (11-oct-2026). Configuración en el menú principal, con Controles: hecha. Suelo frágil roto que se
  guarda: pide ID estable y subir el esquema. Provisionales: salto, combate, onda de la picada y demás daños.
- Pruebas: en el S20 pasan temblor, aterrizaje duro, vibración, puerta, morir, pausa y el fondo hasta los bordes;
  en ventana, cámara, capas y pausa. Sin probar: control (otro integrante), paquete de publicación y maximizar la
  ventana a mano. Fallo del S20 (caída sin fin en `sala_puerta_b`): arreglado, falta verlo en el S20. Botones
  configurables: pasan en el S50 con los pulgares (11-oct-2026). Configuración del menú: pasa en el S50.
- Ícono: se espera al arte (sin él, la exportación imprime un `ERROR:`). ¿«Publicacion» también con 32 bits?
