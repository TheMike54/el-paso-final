---
name: funcionalidad
description: Flujo para hacer una funcionalidad de El Paso Final de principio a fin, desde tomarla de funciones.json hasta entregar el bloque de commit con su evidencia: pruebas vistas fallar con el código roto, recorrido de cada sala tocada, APK nuevo instalado antes de pedir la prueba en el teléfono y cierre en tres niveles. Usar cuando se pida la siguiente funcionalidad de un bloque, continuar el núcleo o las herramientas, o implementar una entrada de funciones.json. No usar para las reglas de GDScript, física, interfaz táctil o rendimiento (eso es gdscript4, fisica-2d, ui-tactil y rendimiento-gama-baja, que este flujo manda cargar), ni para consultar cómo lo resuelve Hollow Knight (eso es referencia-hollow-knight).
---

# Hacer una funcionalidad

Una a la vez. No se empieza la siguiente hasta que esta tiene su evidencia y su bloque de commit. Una prueba en
verde solo cuenta como evidencia si antes se la vio fallar con el código roto (paso 6b).

1. **Elegir.** Leer el `CLAUDE.md` del bloque y su `funciones.json`. Se toma la primera entrada con
   `"pasa": false`, salvo que la persona nombre otra o que espere hardware o firma (se anota en `ESTADO.md` como
   bloqueo y se toma la siguiente). Decir cuál es y cuál es su `"comprobacion"`. Si lo pedido no tiene entrada,
   se agrega al final de ese `funciones.json` con `"pasa": false` y su `"comprobacion"` (`CLAUDE.md` raíz, «Cómo
   se trabaja»). Una entrada que la persona no pidió se le muestra antes y se escribe solo con su OK.
2. **Contexto.** Si usa o cambia algo que otro bloque ve (autoloads, señales, forma de una sala, guardado),
   leer `docs/contrato.md` (y el archivo del tema que toque, según su tabla inicial).
3. **Rama.** `git branch --show-current`. Si es `main`, dar a la persona el comando para crear la rama
   (`git switch -c feature/<bloque>-<desc>`) y esperar a que la cree.
4. **Plan.** Cambio chico: el plan en pocas líneas en la conversación. Más de un archivo o más de una sesión:
   `planes/activos/<bloque>-<tema>.md` con `ACTIVO` en la primera línea, hitos que se puedan comprobar con un
   comando, y la aprobación de la persona antes de programar. Si el plan toca GDScript, física, interfaz o
   rendimiento, antes de pedir la aprobación se contrasta con la skill de ese tema. Si choca con una de sus
   reglas, el plan lo dice y propone el cambio a la skill, con su diff, para que la persona decida.
5. **Programar.** Antes del primer `.gd`, usar la skill `gdscript4` (incluye la cabecera de cada `.gd` nuevo), y
   las otras que pide el `CLAUDE.md` raíz («Entorno y trampas») según lo que se toque. Los `.gd`, `.tscn`,
   `.tres`, `.json` y `.md` se editan con Edit o Write, no con `-replace`, `Set-Content` ni `sed`: Edit avisa si el
   texto no está o se repite, y un reemplazo desde la terminal falla sin avisar. Las escenas heredan; no se copian
   archivos con UID.
6. **Comprobar.** Desde la raíz: `.\herramientas\validar.ps1` (también importa y genera los `.gd.uid`). Después,
   la `"comprobacion"` de la entrada: el guion (o los guiones, separados por `;`), la prueba o, si es `manual:`,
   el paso 6c. Una corrida a la vez. Antes de lanzar `validar.ps1` o `correr-guiones.ps1`, `Get-Process Godot*`
   tiene que salir vacío; si quedan procesos colgados de una corrida que ya terminó, se paran. Si
   `correr-guiones.ps1` sale con 3, otra corrida tiene su candado: no es aprobado ni fallo; se espera a que termine
   y se repite. Mientras corre, no se edita ningún archivo del repo (la única excepción es `mutar.ps1`, que
   restaura lo que cambia); si se editó, esa corrida no vale y se repite. Si la funcionalidad toca un punto crítico
   de «Modelos y revisión» del `CLAUDE.md` raíz, después del validador y la comprobación, el subagente `revisor`.
   En el encargo se le pasa el bloque «Ya verificado / Alcance» de `.claude/agents/revisor.md`, lleno, con la
   huella del árbol calculada con el comando de ese archivo; se lanza con el árbol quieto, o la huella no coincide
   y repite todo. Corre en segundo plano: su `aprobado` o su lista llega como aviso en un turno posterior, y hasta
   recibirlo no se marca `"pasa"` ni se entrega el bloque.
6b. **Comprobar la prueba.** Antes de tomar un verde como evidencia:
   - Mutación: por cada caso nuevo o cambiado, `.\herramientas\mutar.ps1 -Archivo <ruta> -Buscar '<texto>'
     -Poner '<otro>'` con `-Guiones <lista>` (o `-Validar`), que quita o rompe justo lo que el caso dice probar (no
     la constante con la que el caso compara). Vale solo `MUTACION resultado=MATADA restaurado=SI arbol=IGUAL`. Si
     es un arreglo, la mutación quita el arreglo. `SOBREVIVE` es un caso que no prueba lo que dice: se rehace.
     `INVALIDA`, `NO_APLICA` o `BLOQUEADA` no son evidencia: se corrige la causa que da `mutar:` y se repite.
   - Orden real: si la funcionalidad depende de una transición (muerte, cambio de sala, fundido, compra,
     guardado), el caso sigue las señales en el orden en que el juego las emite, leído en el código que las emite.
   - Recorrido: cada sala nueva o tocada lleva un guion en el que el jugador, con las habilidades iniciales y el
     salto normal, va de la entrada a cada enemigo u objeto relevante y a cada salida, también de bajada (modelo:
     `herramientas/guiones/contenido/celda_salto.guion`).
6c. **Prueba en el teléfono** (`manual:`, o lo que no se comprueba sin ventana). Antes de dar la lista:
   - Exportar en ese momento el APK de desarrollo e instalarlo con
     `.\herramientas\instalar-apk.ps1 -Telefono <serie>`, con las series de los teléfonos que `CLAUDE.local.md`
     deja a Claude, elegidas entre las que muestra `adb devices` (varias, separadas por coma). Copiar en la
     entrega, tal como las imprime, cada línea `INSTALADO telefono=... lastUpdateTime=...` y la final
     `INSTALAR-APK OK telefonos=<n>`. Si sale `INSTALAR-APK FALLA`, o falta la línea de un teléfono, a ese
     teléfono no se le piden pruebas.
   - Correr antes la misma secuencia en la PC (guion o juego con ventana). El paso que no se ejecutó se marca
     «no comprobado».
   - Cada paso dice sala (`docs/salas-de-prueba.md`), precondición (vida, partida nueva o continuada, marcas),
     qué hacer y qué observar, y avisa qué acciones reinician la partida, como entrar a la zona de pruebas.
   - Se espera la respuesta de la persona.
7. **Evidencia.** Pegar la salida real del validador y de la comprobación y, por cada caso nuevo, el comando de
   `mutar.ps1` y sus líneas `mutar:` y `MUTACION`. Cerrar en tres niveles: **Automático** (validador, guiones,
   mutaciones), **Visto en PC** (corrida con ventana o capturas) y **En el teléfono** (lo que confirmó la persona,
   o «pendiente»). Lo pendiente en el teléfono no se llama terminado. Si algo falla, se corrige la causa; no se
   cambia la comprobación para que pase.
8. **Marcar.** Solo con la evidencia a la vista (si es `manual:`, con la respuesta de la persona), cambiar
   `"pasa"` a `true` en esa entrada. En `funciones.json` no se borran, reordenan ni reescriben entradas
   (`CLAUDE.md` raíz, «Cómo se trabaja»).
9. **Documentos.** Si cambió lo que el bloque ofrece: `docs/contrato.md` o el archivo de su tema (tabla
   al inicio del contrato) en el mismo cambio; una regla nueva del validador, en `docs/validador.md`. Casos de QA
   ejecutados: `docs/pruebas.md`. Herramienta de IA nueva o recurso ajeno: `docs/uso-de-ia.md`. `ESTADO.md` solo
   si cambió la rama, el PR, un bloqueo o una decisión abierta. Plan terminado: `CERRADO` y a `planes/cerrados/`.
   Si cambió un comportamiento, un nombre o una ruta, Grep de la frase vieja en `docs/`, `planes/`, los
   `funciones.json` y los `CLAUDE.md`, y cada aparición se corrige en el mismo cambio.
10. **Releer.** Cada `.md` tocado, completo: sin texto dirigido a una persona ni avisos de trabajo sin terminar
    fuera de `ESTADO.md`, `funciones.json`, los planes y los estados de `docs/manual/`.
11. **Entregar.** Con la funcionalidad terminada y probada, el bloque exacto para la persona: `git add` de rutas
    concretas (con los `.gd.uid` y los documentos cambiados desde el último commit, como `ESTADO.md`) y
    `git commit -m "feat: ..."` en inglés, sin líneas de atribución. Si cierra el PR, también el título y la
    descripción en inglés con What changed? · Why? · QA evidence · Risk / rollback, y dentro de What changed?
    qué herramienta de IA se usó y en qué parte. El bloque se da solo al cerrar algo relevante: una funcionalidad
    terminada y probada, un arreglo completo o un plan aprobado. Pocos commits y grandes, nunca varios chicos
    seguidos ni uno solo al final. Los cambios de documentos (`ESTADO.md`, `docs/`, `funciones.json`, planes en
    curso) no van solos, salvo un plan recién aprobado. En una sesión autónoma, los bloques se dejan numerados al
    final del archivo que indique `CLAUDE.local.md`; si no hay uno, en el chat.
    - Forma: `## N. Título` y un bloque de código `powershell` cuya primera línea es `cd <raíz del repo>` y la
      segunda `# rama: <rama>`, la rama en la que debe caer el commit. Un bloque es un solo repo: no lleva otro `cd`.
    - El bloque se escribe con Edit o Write: el hook `sin-commit` frena todo comando de terminal que contenga
      `git commit`. Hay un solo bloque vigente por cambio: al sustituir uno, el anterior se borra del archivo.
    - Antes de entregarlo, la lista de `git add` se compara con `git status --short --untracked-files=all`. Lo
      que quede fuera se dice por qué.
    - Si el bloque tiene varios comandos que dependen uno del otro, tras las dos primeras líneas van dentro de
      `& { ... }` con `if ($LASTEXITCODE -ne 0) { throw '<paso> falló' }` tras cada `git` o `gh`, para que un fallo
      pare el resto.

## Trampas

- Un caso puede pasar porque otra operación borra lo que mide: «el arco parado ya no avanza» pasaba siempre
  porque `parar()` borra el proyectil.
- Mutar la constante con la que compara la prueba no rompe nada: hay que mutar el código que se prueba.
- Al morir con PejeCoins, `monedas_cambiadas` sale antes que `jugador_muerto`: `Jugador._morir()` llama a
  `Partida.dejar_mochila()`, que pone las monedas en 0, y después emite la muerte. Un caso que las emite al revés
  prueba un orden que el juego no tiene: puede pasar mientras el juego falla.
- Entrar a la zona de pruebas reinicia la partida: lo recogido antes vuelve a aparecer.
