CERRADO

# Auditoría, paso 4: piezas comunes de bajo riesgo (T2)

Paso 4 de `nucleo-auditoria-codigo.md`, tanda T2. Ids del anexo: J5, J6, J10 (R1), M2 (R2), E14, E15 (R3), P14 (R4) y
W6 (R5). Cada pieza junta código repetido en una función común. El juego no cambia y ningún `.esperado` cambia.

## Qué se hace (una pieza por agente, en este orden)

1. **Lo de los menús y los datos**, sin tocar el jugador:
   - `Tema.fondo_menu` y `Tema.VELO`, para el fondo de los menús, que hoy está repetido siete veces (M2);
   - `Tema.texto_centrado` (E14);
   - `Partida.punto_de_mochila` (E15);
   - `Guardado.entero` (P14);
   - `LineaDialogo.nueva`, con `FichaPregunta.lineas_para` (W6).
2. **Lo del jugador y el escenario:**
   - `Capas.rayo_a_escenario`, para el rayo contra el escenario, que hoy está repetido siete veces (J10);
   - `_velocidad_de_salto` y `_recuperar_aire` en el jugador (J5, J6).

   Es punto crítico porque toca el jugador: lleva revisor.

Cada agente lee primero el hallazgo en el anexo y las copias reales. Si una copia difiere de las demás en algo que
importa, por ejemplo otra máscara u otro orden, no la une a la fuerza: la deja aparte y lo anota.

## Hitos

1. `validar.ps1` → `fallos=0`; `correr-guiones.ps1` → `MALOS=0`; ningún `.esperado` cambia.
2. `git diff --stat` de los archivos tocados con menos líneas que antes, salvo la función nueva.
3. Revisor después de la pieza 2.

## Avance

### Pieza 1 (18-oct-2026): hecha

- **M2.** `Tema.VELO` (0.85) y `Tema.fondo_menu(alfa := VELO)`: `ColorRect` negro, llamado `Fondo`, con `Tema.crear()` y
  `set_anchors_and_offsets_preset(FULL_RECT)`; quien llama hace `add_child`. Unidas 5 copias: `menu_tienda`,
  `menu_estaciones`, `pagina_inventario`, `pantalla_amuletos` (0.85) y la Configuración de `pausa` (`fondo_menu(0.9)`).
  Las copias usaban `set_anchors_preset` o `set_anchors_and_offsets_preset`; antes de `add_child` dan lo mismo, y queda
  la segunda (`docs/errores/2026-10-13-confirmacion-de-ranuras-en-la-esquina.md`). El fondo del inventario y el de los
  amuletos ahora se llaman `Fondo` (antes, nombre automático; nada los busca por nombre). Quedan aparte: `mapa/pantalla_mapa`
  (sin tema y `MOUSE_FILTER_IGNORE`), la confirmación de `ranuras` (0.8, oculta, sin tema), la de `menu_tienda`
  (alfa 0) y los `ColorRect` de `menu.tscn` y `pausa.tscn` (0.7, escritos en la escena). Eran 5 copias, no 7.
- **E14.** `Tema.texto_centrado(lienzo, fuente, cadena, base, letra, color)`: centra a lo ancho sobre la línea base que
  da quien llama. Lo usan `controles_tactiles`, `editor_controles`, `icono_boton` y `aviso_accion` (se quitó su
  `_centrado`). Cada uno conserva su base vertical (`letra * 0.35`, ascent y descent, o ya calculada).
- **E15.** `Partida.punto_de_mochila()`, mismo cuerpo que las copias de `sala.gd` y `mapa/pantalla_mapa.gd`.
  `pagina_inventario.perdido` no era copia: convierte `monto` y `sala`.
- **P14.** `Guardado.entero(valor, por_omision)`, extracción de `Partida.estado_entero` y `Partida.monto_mochila`; no
  cambia qué se guarda ni cómo. Quedan aparte `pagina_inventario.perdido` (redondea con `roundi`, no trunca) y el `fps`
  de `Ajustes` (solo `float` y además `FPS_OPCIONES`).
- **W6.** `LineaDialogo.nueva(quien, texto)` reemplaza los `_linea` de `estacion`, `mochila` y `reto_preguntas`;
  `FichaPregunta.lineas_para(quien, en)` arma la pregunta y su línea de respuesta, y `FichaPregunta.respuesta(acerto, ...)`
  el texto de esa respuesta, con `TEXTO_CORRECTO` y `TEXTO_INCORRECTO` (por omisión también de los `@export` de
  `RetoPreguntas`; ningún `.tscn` ni `.tres` los cambia). `prueba_dialogo._linea` tiene otra forma y queda.
- Contrato: tabla de `Guardado`, fila de la mochila de `Partida`, `LineaDialogo`, `FichaPregunta` y párrafo de `Tema`.
- `validar.ps1`: `OK  VALIDACION archivos=248 fallos=0`. `correr-guiones.ps1`: `RESUMEN total=151 OK=151 MALOS=0`. Ningún
  `.esperado` cambió. Líneas de la pieza: código +87 −100 (19 archivos), contrato +5 −4.
- Lo que el agente dejó abierto lo decidió la sesión principal con la regla «el juego no cambia», y todo queda
  como está:
  - la Configuración de la pausa sigue en 0.9: pasarla a 0.85 cambia lo que se ve. Si se quieren iguales, lo
    decide la persona en el paso 7, con los menús;
  - el mapa y la confirmación de ranuras siguen aparte: su fondo no es el mismo, porque uno ignora los toques y el
    otro tiene 0.8 y empieza oculto;
  - `perdido` sigue con `roundi`.
- Verificado por la sesión principal: `validar` da `fallos=0`; 8 guiones de lo tocado dan `MALOS=0`; no hay ningún
  `:=` en `nucleo/`.

### Pieza 2 (18-oct-2026): hecha, falta el revisor

- **J10.** `Capas.rayo_a_escenario(quien: Node2D, desde, hasta) -> Dictionary`: crea la consulta, fija
  `collision_mask = ESCENARIO` y devuelve lo de `intersect_ray` (vacío si no choca). Las siete copias eran iguales en
  lo que importa: máscara `ESCENARIO`, `collide_with_areas` y `hit_from_inside` por omisión (false), sin `exclude`,
  extremos globales, llamadas dentro del tick. Unidas las siete: `golpeable._paso_libre` (las dos; la primera lee
  `position`), `proyectil` (lee `collider`), `proyectil_enemigo`, `comportamiento_enemigo._choca` (queda como envoltura
  de una línea para sus tres llamadores) y en el jugador `_pared_a_la_altura` y `_lanzar_poder`. Ninguna quedó
  aparte. La onda de la picada (`intersect_shape`, `GOLPEABLE`, con áreas) no es copia de este rayo y queda igual.
- **J5.** `_velocidad_de_salto(altura)` devuelve `-sqrt(2.0 * gravedad * altura)`, la misma expresión de los cinco
  sitios: salto, rebote contra la pared corriendo, saltito de la picada (sigue en `Vector2(0.0, ...)`), voltereta y pogo.
- **J6.** `_recuperar_aire()` pone `_impulso_en_el_aire` y después `_doble_salto_disponible` en true, en el mismo
  orden que los cuatro sitios: suelo, pared, voltereta y pogo. Nada se reordenó: cada llamada está donde estaba el par.
- Contrato: la viñeta de rayos de «Capas de física» nombra `Capas.rayo_a_escenario` y suma el agarre a la pared, que
  faltaba. `docs/jugador.md` no describe estos detalles y no cambia.
- `validar.ps1`: `OK  VALIDACION archivos=248 fallos=0`. `correr-guiones.ps1`: `RESUMEN total=151 OK=151 MALOS=0`. Ningún
  `.esperado` cambió y no hay ningún `:=` en los `.gd`. Líneas de la pieza: código +35 −35 (6 archivos; sin las tres
  funciones nuevas, +17 −35), contrato +3 −1.
- Mutaciones en la copia del scratchpad. En esa copia `zona_pruebas_categorias` falla también sin mutar, porque
  conserva salas de sonda viejas que ya no están en el repo; no cuenta.
  - Rayo con máscara `GOLPEABLE`: fallan 5 guiones, `agarre_pared`, `enemigos_moviles` (4 casos), `golpe_contra_pared`,
    `poder_bola` y `poder_bola_pegado_a_pared`.
  - `_recuperar_aire` sin el doble salto: falla solo `jugador_pogo_recupera`. Hueco: ningún guion gasta el doble salto,
    lo recupera en el suelo, en la pared o con la voltereta y lo vuelve a usar (`habilidad_doble_salto` usa el primero,
    que empieza en true).
- Pendiente: revisor (hito 3), lo lanza la sesión principal.
- **18-oct, revisor: aprobado.** `validar` da `fallos=0` y los guiones `RESUMEN total=151 OK=151 MALOS=0`. Comprobó cada extracción contra las copias de antes; la diferencia entre `set_anchors_preset` y `set_anchors_and_offsets_preset` antes de `add_child` la probó en Godot. Paso cerrado el 18-oct-2026.
