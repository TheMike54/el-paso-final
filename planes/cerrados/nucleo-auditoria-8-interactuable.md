CERRADO

# Auditoría, paso 8: base `Interactuable` (T4)

Paso 8 de `nucleo-auditoria-codigo.md`, tanda T4. Ids: W4, W5, W7, m1, m3.

La idea es una base común para `Npc`, `RetoPreguntas`, `Mochila`, `Banco` y `EntregaRecompensas`. `Tienda` y
`Estacion` se suman ahora que `nucleo-tienda-gis` dejó su interfaz. Se conservan los nombres que leen los guiones:
`cerca`, `caja`, `menu`, `etapa`, `indice`, `sorteadas`, `destino` y `bolsa`.

Regla: el juego no cambia. W4 (la regla de congelado que falta en el banco y en la entrega) y W5 (la caja gris doble
del NPC y del reto) cambian algo que se ve. Se arreglan solo si la consulta los confirma como fallos, y en ese caso
llevan su `docs/errores/`, como los fallos del paso 1. Si no, se quedan como están y pasan al reporte.

## Qué se hace

1. **Consulta:**
   - que los ids sigan vigentes;
   - el diseño de la base;
   - si W4 y W5 son fallos;
   - el orden de las piezas.
2. **Piezas, una por agente.**
3. **Revisor**, porque toca el contrato («Componentes»).

## Hitos

1. `validar.ps1` → `fallos=0`; `correr-guiones.ps1` → `MALOS=0`. Los guiones de diálogo, reto, mochila, banco,
   entrega, tienda y estaciones no cambian, salvo por W4 o W5 con su porqué.
2. `git diff --stat` con menos líneas en los cinco o siete scripts.
3. Revisor.

## Consulta (18-oct, agente investigador) y decisiones de la sesión principal

Los cinco ids siguen vigentes; el anexo cita líneas viejas. W6 ya está hecho.

| Decisión | Elegido | Por qué |
|---|---|---|
| W4 (Banco y Entrega sin el guard de `Congelado`) | Se arregla como fallo, con su `docs/errores/` y un caso en `prueba_estado_sala` | Si un golpe llega sobre un banco y se pulsa interactuar dentro del hit-stop (10 ticks), se cancela el retroceso y se cura al instante. Pasa lo mismo con la Entrega. Es un fallo de ventana chica, como el LB del paso 1, y el arreglo solo hace que esa pulsación se pierda, como ya pasa en el Npc. Se puede revertir con una línea por archivo |
| W5 (la caja gris del Npc y del Reto) | Se unifica: el rectángulo provisional no se dibuja si hay un `CanvasItem` hijo (los `CanvasLayer` no cuentan), y el triángulo de aviso se dibuja siempre que `cerca` | Hoy no cambia nada a la vista, porque ninguna escena tiene arte en esos nodos. Con arte, la regla de hoy taparía también el aviso |
| Base | `class_name Interactuable extends Area2D`, con el gancho `_al_interactuar(jugador)` | Los siete se crean también con `.new()` y la `Sala` crea `Mochila.new()`. Los `.tscn` con `type="Area2D"` no cambian. `interactuar` ya es un método público de `Estacion` |
| Banco y Entrega | Usan la base con el aviso apagado y sin seguir `cerca` | Hoy no tienen aviso, y seguir `cerca` agrega una consulta de solape por tick |
| `hablando` / `sentarse` / pausa | La base no impone ninguna forma de congelar | Hay tres formas distintas y cada una es correcta para su caso |

Piezas, una por agente:
1. La base, migrando `Npc`, `RetoPreguntas` y `Mochila`, con `_cerrar_caja()` (m1), `dibujar_aviso()` (m3) y W5.
2. `Tienda` y `Estacion`.
3. `Banco` y `EntregaRecompensas`, con W4.
4. Contrato y revisor.

## Avance

- 18-oct, pieza 1, hecha por un agente.
  - **`Interactuable`** (`nucleo/interactuable.gd`, 114 líneas):
    - pone las capas, sigue `cerca` y tiene el disparador con `Congelado`;
    - el interruptor `con_aviso` apaga `cerca` y el aviso;
    - funciones de dibujo: `sin_arte()`, `dibujar_provisional()` y `dibujar_aviso()`;
    - ganchos: `_al_interactuar`, `_puede_interactuar` y `_al_terminar`;
    - utilidades: `_abrir_caja` y `_cerrar_caja`, que pone `ficha = null` antes de `queue_free()`.
  - **Npc, RetoPreguntas y Mochila** heredan de ella:
    - quitan 53, 50 y 59 líneas, y suman 13, 6 y 18;
    - los nombres públicos y el hijo `Caja` se quedan;
    - ningún `.tscn` cambió.
  - **Las constantes de tamaño quedan en cada clase,** porque un `const` de la base no se redefine.
  - **Capturas de `sala_dialogo` y `sala_reto`, con el jugador cerca:** idénticas.
  - **W5,** comprobado con un `ColorRect` hijo: no hay caja gris y el triángulo se dibuja encima.
  - **Resultados:** `validar` → `OK  VALIDACION archivos=256 fallos=0`; `correr-guiones` → `RESUMEN total=151 OK=151
    MALOS=0`. Ningún `.esperado` cambió.
  - **Para la pieza 2:** `Estacion` no anula `_jugador` al cerrar, y su cuenta atrás del viaje va antes de vigilar la
    caja. Hay que sobrescribir las dos cosas.
- 18-oct, pieza 2, hecha por un agente: `Tienda` (103 → 89 líneas) y `Estacion` (187 → 169) heredan de
  `Interactuable`.
  - **Tienda:** solo usa la base. Su `_puede_interactuar` es `menu == null`.
  - **Estación:**
    - su `_physics_process` hace la cuenta del viaje y después `super()`;
    - su `_cerrar_caja` propio no anula `_jugador`;
    - su `_puede_interactuar` es `menu == null and cobro == null`.
  - La base no cambia, salvo su cabecera.
  - **Capturas** de `sala_tienda` y `prueba_1` con el jugador cerca: idénticas.
  - **Resultados:** `validar` → `OK  VALIDACION archivos=256 fallos=0`; `correr-guiones` → `RESUMEN total=151 OK=151
    MALOS=0`. Ningún `.esperado` cambió.
- 18-oct, pieza 3, hecha por un agente: `Banco` (38 → 35 líneas) y `EntregaRecompensas` (45 → 42) heredan de
  `Interactuable`.
  - **Aviso apagado:** `con_aviso = false`, puesto en `_init`.
  - **W4 arreglado:** la base ya no deja interactuar durante `Congelado`.
  - **Pruebas:** 4 casos nuevos en `prueba_estado_sala`:
    - con el código viejo fallan 2 (`casos=30 fallos=2`): interactuar en el congelado sobre el banco descansa, y
      sobre la entrega, entrega;
    - con el nuevo pasan.
  - **Documentación:** `docs/errores/2026-10-18-banco-durante-hit-stop.md`.
  - **Guion:** `estado_sala.guion` pasa de `fin 2` a `fin 60` y su `.esperado` de 26 a 30 casos.
  - **Capturas** de `sala_banco` y `prueba_4`: idénticas.
  - **Resultados:** `validar` → `OK  VALIDACION archivos=256 fallos=0`; `correr-guiones` → `RESUMEN total=151 OK=151
    MALOS=0`.
- 18-oct, pieza 4: el revisor aprobó todo el paso, sin fallos.
  - Comparó el orden dentro del tick de los siete con sus versiones anteriores: es el mismo.
  - Repitió la contraprueba de W4 en una copia: con el código viejo, `casos=30 fallos=2`.
  - Revisó el contrato (`docs/contrato.md`, «Componentes») contra el código: coincide.
  - **Diferencia sin efecto:** el `_al_pagar` de `Estacion` ahora pone `cerca = false`, que ya era falso.
  - **Sus resultados:** `validar` → `fallos=0`; `correr-guiones` → `OK=151 MALOS=0`.
  - **No comprobó** las capturas idénticas; esas las tomaron los agentes de cada pieza.
