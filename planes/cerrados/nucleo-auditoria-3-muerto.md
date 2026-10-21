CERRADO

# Auditoría, paso 3: código muerto

Paso 3 de `nucleo-auditoria-codigo.md`. Ids del anexo: J13 (R1), M17 y M18 (R2), W10 (R5), y los símbolos sin uso de la
medición automática (`scratchpad\auditoria\medicion.md`) que sigan sin uso hoy. El juego no cambia.

## Qué se hace

1. **Consulta e inventario.** Un agente investigador:
   - vuelve a medir los símbolos sin uso sobre el código de hoy, porque los pasos 1 y 2 cambiaron cosas;
   - descarta los falsos positivos conocidos: `editor_pedido` se conecta como `Callable` y el `grab_focus` está dentro
     de `Tema.dar_foco`;
   - da su opinión sobre `hacia_donde_mira` (J13).
2. **Quitar lo muerto,** según lo decidido el 17-oct:
   - `Tema.FOCO`, si sigue sin uso;
   - `_volver_brillo` y `Ranuras._volver`, que se asignan y nunca se leen;
   - `hacia_donde_mira`, según la consulta;
   - las señales sin oyente `Cortable.cortado`, `Palanca.portones_abiertos` y `RetoPreguntas.respondida`;
   - lo demás que el inventario confirme.

   Cada símbolo se busca con Grep en todo el repo, también en `.tscn`, guiones, docs y `.claude/`, antes de borrarlo.
3. **Señales que se quedan.** `Porton.abierto` y `MuroRompible.se_rompio` tienen cada una su comprobación en un
   guion (`senal` en el `.esperado`) o en su prueba.
4. **Documentos.** `docs/contrato.md` deja de nombrar lo que se quita (por ejemplo `hacia_donde_mira`, en «Enemigos»).

## Hitos

1. Grep de cada símbolo quitado: cero apariciones fuera de `planes/` y de `docs/errores/` viejos.
2. `validar.ps1` → `fallos=0`; `correr-guiones.ps1` → `MALOS=0`. Ningún `.esperado` cambia, salvo las líneas `senal`
   nuevas.
3. Sin revisor: no toca ningún punto crítico. Si la consulta propone cambiar `atacar()` del enemigo, lo cubre un guion
   de enemigos.

## Avance

- **17-oct, consulta e inventario** (agente investigador, solo con Grep).
  - **Muertos confirmados:**
    - `Tema.FOCO`;
    - `Configuracion._volver_brillo` y `Ranuras._volver`: el ícono de volver lo pone `Tema.barra_arriba`, así que
      borrarlos es seguro;
    - `hacia_donde_mira`;
    - una señal que no estaba en el índice, `MuroRompible.golpeado`. La medición la tapó porque `Golpeable.golpeado`
      sí tiene oyentes.
  - **Señales sin oyente:** `cortado`, `portones_abiertos` y `respondida` se confirman sin oyente. `se_rompio` ya
    tiene su línea `senal` en `muro_rompible_caminando.esperado`. `Porton.abierto` no tiene ninguna comprobación.
  - **Vivo solo por las pruebas y se queda:** `Toques.forzar` y `olvidar`, `ListaElegir.con_foco` y `elegir`,
    `brillo_con_foto`, `dibujo_actual`, `Sonido.EVENTOS`, `Palanca.activada`, `RetoPreguntas.ganado` y
    `Npc.conversacion_terminada`.
  - **Sin comprobar:** variables privadas nunca leídas, parámetros ignorados y ramas inalcanzables. Los mide la pieza
    con los avisos `UNUSED_*` del motor en `.godot/validar.log`, o con un script.
- **Decisión de la sesión principal sobre J13, delegada por la persona: se borra `hacia_donde_mira`** (opción a).
  - No cambia el juego.
  - Reflejar el ataque según `mirando` añadiría comportamiento que ningún enemigo de hoy pide; el único que ataca es
    el muñeco, que mira siempre a la izquierda.
  - Dejarla por estar prometida en el contrato es código sin uso. Un enemigo que gire refleja su propio rectángulo.
  - Se quita también de `docs/contrato.md:580`.
- **Decisión sobre `Porton.abierto`:** un contador dentro de la condición del caso «abierto, subio su alto» de
  `prueba_muros`, para que la cuenta de casos no cambie. No se usa una línea `senal`, porque la prueba recrea la sala
  y la ruta del nodo cambia.
- **`MuroRompible.golpeado`:** se quita. Lo mismo ya sale por `Eventos.objeto_golpeado`.
- **17-oct, ejecución** (agente).
  - **Quitado**, cada uno tras un Grep en todo el repo, incluidos `.tscn`, `.guion`, `.esperado`, `docs/` y `.claude/`;
    sin llamadas por nombre:
    - `Tema.FOCO`, con su comentario;
    - `Configuracion._volver_brillo` y `Ranuras._volver`, con su asignación;
    - `ComportamientoEnemigo.hacia_donde_mira`;
    - las señales `Cortable.cortado`, `Palanca.portones_abiertos`, `RetoPreguntas.respondida` y
      `MuroRompible.golpeado`, con su `emit`. También se ajustaron los comentarios de `cortable.gd`, `palanca.gd`
      y `muro_rompible.gd` que las nombraban.
  - **`docs/contrato.md`:** ya no nombra `hacia_donde_mira` («Enemigos»), `cortado` (fila `Cortable`) ni
    `portones_abiertos` (fila `Palanca`). Las otras señales no salían en el contrato.
  - **`Porton.abierto`:** en `prueba_muros.gd` un contador `aperturas` exige exactamente 1 emisión dentro del caso
    «abierto, subio su alto». La cuenta sigue en 22 casos y `muro_rompible.esperado` no cambia; `docs/pruebas.md`
    lo dice en su fila.
    - Mutación en la copia del scratchpad, sin `abierto.emit()`: `FALLO muros: abierto, subio su alto` y
      `PRUEBAS muros casos=22 fallos=1`.
  - **Lo que no cubría el inventario:**
    - Godot no da esos avisos: `validar.log` no tiene ningún `WARNING`, y una corrida headless con `--check-only`
      de un script con una variable sin uso, un parámetro sin uso y código inalcanzable tampoco imprime ninguno.
      `project.godot` no los ignora; es que la corrida headless no los imprime.
    - Lo midió el script `scratchpad\auditoria\buscar_muerto.py` (se probó antes con un archivo sembrado: encontró
      los cuatro tipos). Revisó las variables privadas de clase con cero lecturas, los parámetros sin `_` ausentes
      del cuerpo (también en lambdas) y las líneas tras `return`, `break` o `continue` al mismo nivel.
    - Encontró un solo candidato, confirmado y quitado: `PantallaMapa._mas` (el botón «+» sigue, solo no se guarda
      la referencia).
    - Ningún parámetro sin uso ni código inalcanzable. No se miraron las variables de las clases internas
      (`class` dentro de un `.gd`) ni las variables locales.
    - `_boton("+", acercar)` descarta lo que devuelve sin aviso: `return_value_discarded` está en «ignorar» por
      omisión y `project.godot` no lo cambia.
  - **Hitos:**
    - el Grep de cada símbolo quitado da cero fuera de `planes/`; el único resultado de `_mas` es un APK viejo en
      `build/`;
    - `OK  VALIDACION archivos=248 fallos=0`;
    - `RESUMEN total=151 OK=151 MALOS=0`.
    - Esta pieza no cambió ningún `.esperado`. Los que salen modificados en la rama ya lo estaban antes de esta pieza.
    - `.godot/correr-guiones.log` solo guarda el resumen, así que no sirve para buscar `WARNING` en todos los guiones.
- Verificado por la sesión principal: `validar` da `fallos=0` y 7 guiones del paso dan `MALOS=0`. Paso cerrado el 17-oct-2026.
