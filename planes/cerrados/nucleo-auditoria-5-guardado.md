CERRADO

# Auditoría, paso 5: guardado y bus (T3)

Paso 5 de `nucleo-auditoria-codigo.md`, tanda T3. Ids del anexo R4: P2 a P7. Es punto crítico (guardado): lleva
revisor. El juego no cambia.

## Consulta (18-oct, agente investigador)

| Id | Qué es | Clase | Por qué |
|---|---|---|---|
| P2 | `guardar()` con `Guardado.RUTA` por omisión | Hacer | Nadie la llama sin ruta. Quitar el valor por omisión hace que olvidar la ruta no compile |
| P5 | Ninguna prueba compara lo que se guarda con el esquema | Hacer | Prueba nueva en `prueba_guardado.gd`: las claves de `a_diccionario()` en los dos sentidos contra `ESQUEMA` + `NUEVOS`, y un recorrido completo con cada campo distinto del de `reiniciar`. Atrapa «lo guardé pero no lo cargo» |
| P3 | Hay muchas formas de autoguardar | Descartar (pendiente de la persona) | Unirlas cambia cuántas veces se escribe, no cuándo. Hay cambios sin evento (monedas, vida máxima, equipar), así que el bus solo no alcanza. Se anota en el contrato que hay dos formas |
| P4 | Sondeo de amuletos y botones enseñados | Descartar (pendiente de la persona) | El sondeo es barato y solo corre con el mapa rápido abierto o en los controles táctiles. Una señal no cubre todos los caminos y cambia el orden de los ticks |
| P6 | Gancho `_convertir` para subir `VERSION` | Descartar (pendiente de la persona) | Hoy no hay ninguna conversión que escribir. El contrato ya obliga a escribirla en el mismo cambio que sube `VERSION`. Sería generalizar sin ningún caso |
| P7 | Respaldar también al descansar | Decisión de la persona | Cambia lo que hace «Restaurar»: hoy vuelve al inicio de la sesión, y con esto volvería al último banco. El guardado atómico ya cubre un cierre a la mitad |

## Qué se hace

1. Una pieza, de un agente, con P2 y P5:
   - P2: quitar el valor por omisión de la ruta en `Partida.guardar` y `Guardado.guardar`, y poner al día
     `docs/contrato.md`;
   - P5: los casos nuevos en `prueba_guardado.gd`;
   - una línea en el contrato sobre las dos formas de autoguardar: el bus para lo que tiene evento y la llamada
     directa para lo demás.
2. P3, P4 y P6 se cierran si la persona acepta descartarlos. P7 espera su decisión.

## Hitos

1. Los casos nuevos de P5 se comprueban en una copia: si se quita un campo de `desde_diccionario`, o se agrega uno a
   `a_diccionario` sin ponerlo en el esquema, la prueba falla.
2. `validar.ps1` → `fallos=0`; `correr-guiones.ps1` → `MALOS=0`. Solo cambia la cuenta de `casos` de `guardado.esperado`.
3. Revisor.

## Avance

- 18-oct, pieza P2 + P5 (agente):
  - P2: `Partida.guardar(ruta: String)` y `Guardado.guardar(partida, ruta: String)` sin valor por omisión. Grep: todas
    las llamadas ya pasaban ruta (`banco.gd`, `menu.gd`, `Partida.autoguardar` y las pruebas). `Guardado.RUTA` se queda
    (`migrar`, `Banco`); `cargar` y `borrar` conservan la suya. Firma al día en `docs/contrato.md` («Guardado» y
    `partida_guardada`).
  - Contrato, fila `autoguardar()`: las dos formas (bus para lo que tiene evento, llamada directa para lo demás).
  - P5: tres casos en `prueba_guardado.gd` (63 → 66, `guardado.esperado` y `docs/pruebas.md`). (a) claves de
    `a_diccionario()` contra `ESQUEMA` + `NUEVOS`, con lo que sobra o falta en el nombre. (b) recorrido completo en
    dos casos: llenar cada campo del esquema con un valor distinto del de `reiniciar` (tabla por tipo: número,
    texto, lista; los objetos `banco`, `mochila` y `salas` llevan su forma en `FORMAS` porque se leen por clave; un
    tipo o un objeto sin valor de prueba hace fallar) y comprobar que quedó distinto; después guardar, cargar,
    reiniciar, `desde_diccionario` y comparar campo por campo, normalizado por JSON.
  - Hito 1, en la copia (`mutar-p5.ps1` del scratchpad): (i) sin leer `monedas` en `desde_diccionario` → falla
    «llenar Partida ... como en reiniciar: [monedas]» (y uno viejo); (ii) `clave_extra` en `a_diccionario` → falla
    (a) «sobran: [clave_extra]»; (iii) `ESQUEMA` sin `monedas` → falla (a) «sobran: [monedas]» y el recorrido
    (con un `SCRIPT ERROR` al leer el campo que ya no se llena).
  - Hito 2: `validar.ps1` → `OK  VALIDACION archivos=248 fallos=0`; `correr-guiones.ps1` → `RESUMEN total=151 OK=151
    MALOS=0` (en la primera corrida completa `sala_puerta_b_pared` no terminó antes de `--quit-after`; solo y en la
    segunda corrida completa pasó). Falta el revisor.
- **18-oct, revisor: aprobado.** `validar` da `fallos=0` y los guiones 151 de 151. Corrió de nuevo las tres mutaciones,
  y no quedan archivos de prueba en `user://`.
  - Dos frases del contrato ya se corrigieron: «lo que `Partida` no escucha» y «`ESQUEMA` y `NUEVOS`».
  - Límite que se acepta: el recorrido revisa campo por campo. Una subclave olvidada dentro de `banco`, `mochila`
    o `salas` no la atrapa.
- **18-oct, decisión de la persona:** se descartan P3, P4 y P6, y P7 queda como hoy («Restaurar» vuelve a la copia
  del inicio de la sesión, `Guardado.respaldar` desde `menu.gd`). Comprobado en el código: la escritura es atómica
  (`nucleo/archivo.gd`, temporal y renombre). Además de esto, un respaldo en cada banco copiaría un archivo que ya
  se dañó durante la sesión.
- Falta una lectura de comprobación por un agente aparte, pedida por la persona. Tiene tres preguntas:
  - P3: ¿todo cambio de `Partida` acaba en un autoguardado? Si alguno no, es un fallo que hay que arreglar.
  - P4: ¿el sondeo de amuletos corre solo con el mapa rápido abierto?
  - P7: confirmar los dos datos anteriores.

  El plan se cierra cuando termine esa lectura.
- **18-oct, lectura de comprobación (agente investigador):** de acuerdo con las cuatro decisiones y sin fallos.
  - P3: cada cambio de `Partida` que el contrato pide guardar acaba en un autoguardado, por el bus o por una llamada
    directa. Lo que espera al siguiente guardado (marcas de muro, palanca, portón, suelo frágil y aviso,
    `salas_visitadas` y `botones_ensenados`) se agregó a la fila `autoguardar()` del contrato. Un cierre brusco que
    no pase por `APPLICATION_PAUSED` ni por `FOCUS_OUT` los pierde; eso no se comprobó en ejecución.
  - P4: el sondeo de la brújula corre en el tick solo con el mapa rápido abierto, y es un `has` sobre 3 elementos
    como máximo.
  - P7:
    - la escritura es atómica;
    - el respaldo se hace solo en `menu.gd:142`, al entrar a una ranura válida;
    - «Restaurar» copia ese `.bak`.

    Queda sin comprobar que `rename_absolute` reemplace un destino que ya existe en Android: va al paso 11.
