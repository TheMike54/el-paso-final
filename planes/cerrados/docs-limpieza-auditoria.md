CERRADO

# Documentación: limpieza tras las auditorías de código y de documentación

Rama `docs/limpieza-auditoria`, sobre `feature/nucleo-parry-carrera-y-aviso-tactil` (`d174953`). Sale de dos
auditorías de solo lectura del 12-oct-2026: una de código muerto y optimización (sobre `c253734`) y una de deriva
de la documentación (sobre `d174953`). Cada hallazgo se volvió a comprobar contra el código actual antes de este
plan: de los 37 de documentación, 36 se comprobaron (26 reales, 10 parciales, ninguno falso) y E2 se revisa celda
por celda al cerrar el plan del núcleo. De los 22 de código, 12 ya estaban
arreglados en `e2e61b0`, `f9c51f8` y `35f1e83`. Aprobado por la persona el 12-oct-2026, con las decisiones de la
sección 3 y los textos de la sección 2.

Fuera de este plan, y pendiente: la prueba con el dedo de las filas «Carrera, voltereta y pared» y «Parry y
congelado» de `docs/pruebas.md` (sin teléfono a mano el 12-oct-2026).

## 1. Lo hace Claude (sin decisión)

| ID | Cambio | Archivos |
|---|---|---|
| D5 | Las 5 señales que faltan en el guion del bus (`parry`, `amuleto_obtenido`, `coleccionable_obtenido`, `monedas_cambiadas`, `fundido_pedido`), con la cuenta medida en una corrida; «trece» → «dieciocho»; `pruebas.md:30` igual | `herramientas/guiones/nucleo/bus_eventos.esperado`, `docs/pruebas.md` |
| D7 | «Recursos (automático, bajo o alto)» en la lista de opciones de la Configuración | `docs/contrato.md:656-659` |
| D9 | «los 4 ticks del congelado al vencer» (`congelado.gd:11`, `pedir` cuenta el tick actual) | `docs/pruebas.md:98` |
| D10 | El HUD también tiene las PejeCoins y el ícono de guardado | `interfaz/CLAUDE.md:3` |
| R3 | La referencia a «Fundido» apunta a la viñeta «Fundido a negro» de «Sala» | `docs/contrato.md:357` |
| R2 | El preset «Desarrollo» y el permiso `VIBRATE` se anotan como «en `chore/android-export` hasta fusionarla» (si la persona no decide fusionarla antes; ver 3) | `docs/pruebas.md:202`, `docs/contrato.md:130` |
| C1 | «falta ver los guiones en verde en un PR (el paso existe en `ci.yml`)» | `ESTADO.md` |
| C2, L3 | Cada fila de `docs/pruebas.md` deja solo su última ejecución (regla de `:154`): filas 165, 167, 178, 181, 182, 183, 185, 186 y 201. El historial queda en git | `docs/pruebas.md` |
| C5, E1, E2 | Cerrar `nucleo-cierre-antes-de-la-sala.md`: «Falta» al día (ícono, detección, FPS y Mapa ya probados), la fase 9 la cubre `entrada-control`; primera línea `CERRADO` y a `planes/cerrados/` | el plan, `ESTADO.md` (cita su ruta) |
| E4 | Quitar de «Preparación» el paso 8, ya cumplido | `ESTADO.md` |
| E5 | Pasar «rango 4 a 6» de `ticks_soltar_carrera` a la tabla del jugador y «plantas y niebla no se paran en el congelado» a «Recursos»; después quitar la línea de `ESTADO.md` | `docs/contrato.md`, `ESTADO.md` |
| U1 | Una sola fuente para el paquete de publicación (`contrato.md` § Paquete de publicación, con la frase del puerto de `:164`); las demás copias quedan en una línea con enlace | `nucleo/CLAUDE.md`, `herramientas/CLAUDE.md`, `docs/idea.md`, `docs/contrato.md` |
| U2, L4 | El formato de guion vive en `docs/guiones.md` (ver L2); `herramientas/CLAUDE.md:15` y `:23-25` quedan en una línea con enlace | `herramientas/CLAUDE.md` |
| U3 | `herramientas/CLAUDE.md` § Reglas se reescribe completa contra `validar.gd:160-255` (hoy las cuatro listas son parciales); `contrato.md:453-456` y `contenido/CLAUDE.md:17` enlazan | los tres |
| U4 | Fuente única de los momentos de autoguardado: `contrato.md:150` (incluye la entrega de recompensas); `:30-32` enlaza | `docs/contrato.md` |
| U5 | Presupuesto de decoración: fuente en `contrato.md` § Recursos; `herramientas/CLAUDE.md` enlaza | `herramientas/CLAUDE.md` |
| U7 | `ESTADO.md:3` se reduce a «Se sobrescribe (ver `CLAUDE.md`)» | `ESTADO.md` |
| L2 | Partir `docs/contrato.md`: `:271-411` (jugador) a `docs/jugador.md`; la tabla de componentes (`:413-424`) se queda como sección «Componentes»; `:600-641` a `docs/guiones.md`; la evidencia fechada (`:341`, `:436`, `:458`, `:463`, `:614`, `:672-673`) a `docs/pruebas.md`. Actualizar los 3 enlaces a «§ Jugador» (`pruebas.md:160`, `docs/errores/2026-10-06-retroceso-dejaba-saltar.md:10`, el interno `:243`) y el comentario de `nucleo/vibracion.gd:4`, que cita una sección «Vibracion» que no existe. Se hace al final | `docs/`, `nucleo/vibracion.gd`, `nucleo/jugador.gd:4,149` |

No se tocan los planes cerrados (R4): son historial.

## 2. Texto que aprueba la persona (`funciones.json`)

Claude no reescribe entradas; propone el texto y lo aplica solo con el sí.

| Entrada | Hoy dice | Propuesta |
|---|---|---|
| `nucleo` · `parry` (D1) | «congela 3 ticks» | «congela 20 ticks y empuja al jugador hacia atrás» |
| `nucleo` · `temblor-al-aterrizar` (D2) | «el interruptor de la pausa» | «el interruptor Temblor de cámara de la Configuración del menú» |
| `interfaz` · `aviso-partida-guardada` (D3) | texto «Partida guardada» bajo la barra | «muestra el ícono de guardado bajo las PejeCoins durante 2 s» |
| `interfaz` · `icono-guardado-y-monedas` (D4) | «abajo a la derecha» | «bajo las PejeCoins, alineado a la izquierda del grupo» |
| `nucleo` · `entrada-acciones` (D6) | `controles_tactiles.gd` es el único que lee toques o teclas | «… el único que lee toques durante el juego; el Editor de controles lee el ratón y la Configuración lee botones del control para reasignar» (y lo mismo en `contrato.md:245`) |
| `nucleo` · autoguardado (U4, `:238`) | sin la entrega de recompensas | agregar «y al entregar recompensas» |
| `herramientas` · validador de salas (U3, `:70`) | lista parcial | la lista completa de `validar.gd` |

Entradas nuevas, también pendientes del sí: `parry-visible`, `carrera-voltereta`, `carrera-rebote-pared` y
`aviso-pocos-toques` (texto en el plan `nucleo-parry-carrera-y-aviso-tactil.md`), que se marcan con sus guiones.

## 3. Decidido por la persona (12-oct-2026)

Se tomó la recomendación en los cuatro casos.

| ID | Pregunta | Decisión |
|---|---|---|
| C3 | `recursos-medicion` ya tiene la medición en depuración (S20 60, S50 en bajo 59-60) | Marcarla `true` y abrir una entrada `recursos-medicion-publicacion` para el paquete de publicación |
| E3 | `mapa-telefono` pasa en los dos teléfonos con el dedo; la parte con control no se probó | Marcarla `true`: el control ya lo cubre `entrada-control` |
| R2 | El preset «Desarrollo» solo existe en `chore/android-export` | Anotarlo (fila R2 de la sección 1); la rama entra con el PR de la pila |
| M-05 | `IndiceSalas.rutas` se escribe y no se lee | Dejarlo: usarlo en `Sala.ruta_de` va con la primera sala real; quitarlo obliga a regenerar el índice |

## 4. Configuración de Claude (se muestra el cambio antes)

- `CLAUDE.md` raíz: `interfaz/` en la lista de bloques y fila en «Dónde está lo demás» (R1); filas para
  `docs/jugador.md` y `docs/guiones.md` (L2); «salvo las bloqueadas por hardware o firma, que se anotan en
  `ESTADO.md` como bloqueos» en «la primera con `pasa: false`» (C4, U7); «la lista de `planes/activos/`» en «Al
  compactar» (D11); el párrafo de publicación en una línea con enlace y sin fecha (U1, L1). El comentario de la
  línea 6 se queda: lo pide el estándar de los `CLAUDE.md`.
- El IMPORTANT de commits no queda en una línea: las prohibiciones y la cláusula de prioridad se quedan en la raíz
  (lo que nunca debe pasar no vive solo en una skill, que carga al invocarse) y el procedimiento (bloque exacto, pocos
  commits grandes, un plan aprobado puede ir solo) pasa a la skill `funcionalidad`, paso «Entregar» (L1, U6).
- «Sesión autónoma» se queda en la raíz, comprimida: sus condiciones de parada deben valer sin invocar nada.
- Largo resultante: unas 135 líneas. Se pasa de la meta de 120 porque cada línea restante es comando, trampa,
  decisión cerrada o prohibición; bajar más pide una skill de PR que no existe.
- `.claude/agents/Explore.md:11`: el código vive en `nucleo/`, `interfaz/`, `mapa/` y `herramientas/` (D8).

## 5. No se hace (ya decidido)

- O-04, O-05, O-10, O-13, O-14 y O-15: decididos como «no» en `planes/cerrados/nucleo-arreglos-telefono.md`
  (O-04 sin costo medible; O-05 va con el contenido porque toca la física del jugador; O-10 lo reemplaza el sprite;
  los demás, costo despreciable). M-02 y M-03 se quedan como interfaz reservada en el mismo plan. Se reabren solo
  si la persona lo pide.
- O-06 no es un arreglo: es la medición en publicación (C3).

## Al ejecutar (12-oct-2026)

- Las 8 decisiones se consultaron con el advisor antes de ejecutar (pedido de la persona); sin objeciones, con tres
  guardas que se cumplieron: la fila 182 de `docs/pruebas.md` conserva los FPS de los dos teléfonos; `mapa-telefono`
  pasa a `true` porque su texto es solo táctil y el control del mapa (Y, LB) está en la tabla de entrada del contrato;
  la configuración de Claude se mostró completa antes de editarla.
- U3: la lista completa de lo que el validador revisa en las salas quedó en `docs/contrato.md`, «Sala», y no en
  `herramientas/CLAUDE.md`: la leen quienes hacen salas. `herramientas/CLAUDE.md` y `contenido/CLAUDE.md` enlazan.
- L2: las notas cortas de procedencia con fecha («medido el 07-oct-2026») se quedan junto al valor que explican; solo
  salió del contrato la evidencia de QA del aviso de toques, que ya estaba en `docs/pruebas.md`.
- `fundido_pedido` medido en `bus_eventos`: 2 (una por puerta).
- Propuesta aparte, sin decidir: `.claude/settings.json` fija `attribution` pero no `includeGitInstructions`. Sin
  comprobar si esa clave también quita el `git status` del inicio de sesión; probarla antes de activarla.

## Orden y comprobación

1. Sección 1 sin L2 → `validar.ps1` (`fallos=0`) y el guion `bus_eventos`.
2. Secciones 2 a 4, según lo que apruebe la persona → `validar.ps1` y los guiones de las entradas que pasen a `true`.
3. L2 al final → Grep de «contrato.md § Jugador» y «§ Guiones» sin resultados viejos; `validar.ps1`.
4. `revisor` (toca `.claude/` y el `CLAUDE.md` raíz) y un solo bloque de commit. Hecho el 12-oct-2026: `validar`
   147/0, 115 guiones OK; `revisor` aprobado tras corregir 3 filas de `docs/pruebas.md` que perdían o inventaban un
   resultado y una frase de «Sesión autónoma».

`ESTADO.md` queda en 60 líneas o menos y conserva como pendientes las dos pruebas con el dedo.
