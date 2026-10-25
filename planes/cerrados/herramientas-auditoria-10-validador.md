CERRADO

# Auditoría, paso 10: el resto de T8 (herramientas)

Paso 10 de `planes/activos/nucleo-auditoria-codigo.md`. H4, H14, H15, H16, H20 y H25 se cerraron en el paso 2.

Regla:
- el juego no cambia;
- el validador y los guiones detectan lo mismo, salvo el hueco de H11;
- los hooks de git y `.claude/` no se tocan;
- `ci.yml` se toca con el revisor, porque es un punto crítico.

## Consulta (18-oct, agente investigador) y decisiones de la sesión principal

| Id | Elegido | Por qué |
|---|---|---|
| H5 | **Parcial.** `prueba_validador` hereda de `validar.gd` y prueba con nodos rotos armados en memoria. Cubre `_fallo_de_entrada`, `_id_recordado`, `_revisar_peligros`, `_revisar_avisos`, `_revisar_tiendas`, `_revisar_rutas_de_secretos` y, si caben, `_revisar_sala` y `_revisar_habilidades`. No se parte `validar.gd` | Hoy ninguna prueba automática cubre el validador. Es la red para refactorizarlo (H6-H10). La partición completa son ~500 líneas de alto riesgo, y el paso 13 mide antes qué vale la pena |
| H6, H7, H8, H9, H10 | **Se hacen** después de H5:<br>• H6: tiendas y avisos salen de `_revisar_npcs`;<br>• H7: lista de fichas con `fallos()`;<br>• H8: `_id_reservado`;<br>• H9: lista de clases con id recordado;<br>• H10: `_de_tipo` | Mismos fallos. H10 puede cambiar el orden de las líneas `FALLO` en `_revisar_habilidades`; `validar.ps1` solo las cuenta, y se comparan ordenadas |
| H11 | **Se hace:** con `pasa: true`, el validador exige también el `.esperado` del `.guion` | Hoy no rompe ninguna entrada (151 `.guion` y 151 `.esperado`). El puerto ya fallaba al correr, así que la regla solo adelanta el aviso |
| H12 | **Se hace:** `ci.yml` pasa los mensajes por `herramientas/githooks/commit-msg` | Una sola lista de asistentes, sin tocar el hook. Se pierde el número de línea en el mensaje del CI |
| H13 | **Corregido:** el CI ya corre con `pipefail` (`shell: bash`). El único hueco es que acepta varios resúmenes de `VALIDACION`. Se exige exactamente uno, como `validar.ps1` | Mismo criterio en los dos |
| H17, H18 y las dos mayores de H19 | **Se pasan al final del paso 13** | El paso 13 puede borrar pruebas: partir antes una que después se borre es trabajo perdido |
| H21 | **Descartado** | `%Nombre` exige `unique_name_in_owner` en escenas del juego |
| H22 | **Descartado** | `prueba_vista._caso` tiene otra firma que la de la base. Unificarla gana unas 6 líneas por archivo y obliga a cambiar `docs/guiones.md` |
| H23 | **No se toca** | El preset «Desarrollo» llega con `chore/android-export`, que tiene su propio PR (`ESTADO.md`) |
| H24 | **Al paso 11 y a la persona** | Exige un APK de publicación firmado con su keystore |

## Piezas, una por agente

1. **H5:** `prueba_validador`, su sala, su guion, su `.esperado` y una entrada nueva. Se escribe sobre el validador
   de hoy.
2. **H6-H10.** Comprobación:
   - la prueba de la pieza 1 en verde;
   - el mismo conjunto de `FALLO` ordenado, antes y después, en una copia con 8-10 salas rotas.
3. **H11,** con un caso en `prueba_validador`.
4. **H12 y H13,** con un `.sh` del scratchpad que reproduce los pasos del CI con entradas sintéticas. Después, el
   revisor de todo el paso.

## Hitos

1. `validar.ps1` → `fallos=0`; `correr-guiones.ps1` → `MALOS=0`.
2. El mismo conjunto de fallos en la copia rota, antes y después de la pieza 2.
3. Revisor.

## Avance

- 18-oct, pieza 1 (H5), hecha por un agente.
  - **La prueba:** `herramientas/pruebas/prueba_validador.gd` hereda de `validar.gd` sin correr su `_ready`. La acompañan
    `sala_validador.tscn` y el guion nuevo `herramientas/guiones/herramientas/validador`.
  - **Qué cubre:** 50 casos sobre las ocho reglas previstas, cada forma de fallar con su caso sano.
  - **Cómo se arman los casos:** los nodos rotos se crean en memoria. `_revisar_sala` solo mira los nodos con dueño,
    así que la prueba pone `owner`.
  - **Contraprueba**, en una copia: con dos mutaciones, la prueba dio `fallos=5` y luego `fallos=1`, en los casos que
    correspondían.
  - **Documentación:** la entrada nueva `validador-prueba-en-memoria` quedó en `true`, y hay una fila nueva en
    `docs/pruebas.md`.
  - **Resultados:**
    - el guion → `PRUEBAS validador casos=50 fallos=0`;
    - `validar` → `OK  VALIDACION archivos=259 fallos=0`;
    - `correr-guiones` → `RESUMEN total=152 OK=152 MALOS=0`.
- 18-oct, pieza 2 (H6-H10), hecha por un agente. `validar.gd` pasa de 732 a 724 líneas.
  - **H6:** tiendas y avisos se llaman desde `_revisar`.
  - **H7:** `_es_ficha_con_fallos` y una lista de fichas.
  - **H8:** `_id_reservado`.
  - **H9:** lista de clases con id recordado; `AvisoAccion` queda aparte.
  - **H10:** `_de_tipo(raiz, clase, con_raiz)`.
  - **Desvíos:**
    - Las listas son variables y no `const`: Godot rechaza una `const` con nombres de clase («isn't a constant
      expression»).
    - En npc, retos y tiendas, la raíz va ahora al principio, como en habilidades. Solo cambiaría el orden si una
      raíz tuviera dentro otro nodo de su misma clase, y hoy ninguna lo tiene.
  - **Equivalencia:** en una copia con 13 roturas salen los mismos 25 `FALLO` antes y después, y en el mismo orden.
    - La palanca que apunta a sí misma en `sala_secretos` no da fallo con ninguna de las dos versiones, porque esa sala
      no está en una carpeta con id. No se cuenta como cobertura.
  - **Resultados:**
    - `validar` → `OK  VALIDACION archivos=259 fallos=0`;
    - el guion del validador → `casos=50 fallos=0`;
    - `correr-guiones` → `RESUMEN total=152 OK=152 MALOS=0`.
- 18-oct, pieza 3 (H11), hecha por un agente.
  - **Antes de cambiar:** de 191 entradas, 127 con `pasa: true` nombran 224 `.guion`, y todos tienen su `.esperado`. La
    regla nueva no rompe nada.
  - **La regla:** `_fallo_de_entrada` recibe `raiz` opcional para que la prueba arme un caso en `user://`, y exige el
    `.esperado` de cada `.guion`.
  - **Casos nuevos:** 2 en `prueba_validador`, y el `.esperado` pasa de 50 a 52. Un archivo llamado `con.guion` no se
    puede crear en Windows, porque `CON` es un nombre reservado.
  - **Contraprueba:** con la regla quitada, `casos=52 fallos=1`.
  - **Para la persona:** la fila de `validar.ps1` en `herramientas/CLAUDE.md` no menciona la regla nueva. Queda
    propuesta en el reporte, porque ese archivo no se edita sin su visto bueno.
  - **Resultados:**
    - `validar` → `OK  VALIDACION archivos=259 fallos=0`;
    - el guion del validador → `casos=52 fallos=0`;
    - `correr-guiones` → `RESUMEN total=152 OK=152 MALOS=0`.
- 18-oct, pieza 4 (H12 y H13), hecha por un agente.
  - **H12:** el CI escribe los mensajes en `$RUNNER_TEMP/mensajes.txt` y los pasa por `herramientas/githooks/commit-msg`,
    que no se tocó.
  - **H13:** el CI exige exactamente una línea `^VALIDACION archivos=N fallos=N$` y que termine en `fallos=0`.
  - **Comprobación local:** `p10-ci-prueba.sh`, en el scratchpad.
    - Saca los dos `run:` del yml y los corre con un `git` y un `godot` falsos en 20 casos sintéticos. Resultado:
      `CI PRUEBA OK`.
    - Contra el `ci.yml` viejo, la misma prueba falla en 8 casos: copilot, codex, gemini, cursor, dos resúmenes, texto
      extra al final y `fallos=0x`.
    - El YAML carga con python `yaml`.
  - **Sin comprobar:** cómo corre en GitHub Actions y qué dice actionlint.
- 18-oct, cierre: el revisor aprobó el paso sin fallos.
  - **Comprobaciones que repitió:**
    - los mismos 25 `FALLO`, en el mismo orden, en la copia rota;
    - la contraprueba de H11;
    - `CI PRUEBA OK`.
  - **Que la raíz vaya primero no cambia nada hoy:** las únicas raíces `Npc` o `RetoPreguntas` solo tienen la `Forma`
    como hija.
  - **Observaciones heredadas, sin cambiar:**
    - `Generated with Claude` sin ancla rechazaría también una línea de prosa;
    - si la escena del validador sale con 1, el `tee` corta el paso antes de los `::error::`.
  - **Sin comprobar:** `$RUNNER_TEMP` en Actions, actionlint, y la exclusión del APK, deducida de `exclude_filter`.
  - **Resultados:**
    - `validar` → `OK  VALIDACION archivos=259 fallos=0`;
    - `correr-guiones` → `RESUMEN total=152 OK=152 MALOS=0`.
