CERRADO (2-nov-2026)

# Documentación para continuar el juego

Deja el repositorio listo para que cualquier persona entienda y continúe el juego. No cambia el juego: lo que se encuentre y
sea código se anota como hallazgo.

## Pasos

| # | Qué | Se comprueba con |
|---|---|---|
| 1 | Guías de `docs/guias/`: corregir lo que se encuentre y agregar las que falten (cinemáticas como escena e integración, pizarrones; revisar zona nueva, NPC, jefes, tienda, retos, íconos y publicar) | Una receta corregida se repite desde una copia limpia; `validar.ps1` |
| 2 | `docs/manual/`: arquitectura con diagramas, mecánicas con su estado, recorrido del juego, decisiones, glosario, permisos de uso, límites, lo que no está en el repo y cómo suplirlo, y publicar desde cero | Una segunda lectura independiente lo coteja contra el código; hecho, diseño previsto y pendiente van separados |
| 3 | Herramientas: revisión de enlaces de los `.md`, tablas de escenas, autoloads y señales generadas por script, y tabla de PR para `docs/entrega-2.md` | Su entrada en `herramientas/funciones.json` y corrida real |
| 4 | Justificar cada `.md` del repo: quién lo lee y para qué. `docs/errores/` se justifica como carpeta | Tabla con conservar, fusionar o borrar |
| 5 | Cierre: batería completa, `revisor` y bloque de commit | `fallos=0` y `MALOS=0` |

## Reglas de la sesión

- `validar.ps1` no revisa enlaces hoy: esa revisión es trabajo del paso 3.
- Un guion intermitente se repite solo: se anota el resultado y no se arregla código. Si sigue fallando, es un hallazgo y se continúa.
- No se borra nada sin aprobación de la persona.
- Nada se descarga ni se instala: lo que lo necesite queda anotado como pendiente y la sesión sigue.
- Si un modelo se queda sin cuota, otro toma su tarea y se anota el cambio.
- Lo que solo se ve en el teléfono queda como prueba manual, sin darlo por cumplido.

## Avance

Sesión autónoma del 2-nov-2026, con la orden de la persona.

| Paso | Resultado | Medición |
|---|---|---|
| 1 | 8 guías nuevas y 5 corregidas. Una receta de punta a punta (enemigo que se entierra, pizarrón, amuleto) repetida desde una copia limpia sin tocar `nucleo/` | `fallos=0`, 2 `GUION OK`; 2 tropiezos corregidos en `docs/guias/pizarrones.md`, `docs/guias/README.md` y `docs/guiones.md` |
| 2 | `docs/manual/` con 10 archivos. `diseno.md` y `recorrido.md` son un bloque aparte, porque publicar el diseño depende de una decisión de la persona | Segunda lectura contra el código: 7 errores, los 7 corregidos; los diagramas Mermaid son válidos |
| 3 | `revisar-enlaces.ps1`, `generar-tablas.ps1`, `reporte-entrega.ps1` y la línea `amuleto` del puerto de depuración | `ENLACES rotos=0` en 5.1 y 7; 4 entradas nuevas con `"pasa": true` |
| 4 | Tabla de abajo. No se borró nada | Ver tabla |
| 5 | Batería completa; `revisor` antes del PR: 6 fallos de documentación y de `revisar-enlaces.ps1`, corregidos | `OK VALIDACION archivos=410 fallos=0`, `RESUMEN total=209 OK=209 MALOS=0` |

Los casos de fallo de la línea `amuleto` (id desconocido, orden incorrecto, carga insuficiente) se probaron con tres guiones temporales: `GUION FALLA` y salida 1; no quedan en el repo. Las tres herramientas se comprueban con su corrida real, anotada en `herramientas/funciones.json`.

Arreglo de código fuera del plan: `herramientas/arreglar_uids.gd` y su `docs/errores/2026-11-02-uids-crlf.md`. Sin cuota agotada ni
descargas. La opción `--quit-after` en `--import` se descartó: cortaría una importación larga.

### Justificación de los `.md` (paso 4)

| Archivos | Quién lo lee y para qué | Veredicto |
|---|---|---|
| `CLAUDE.md`, `*/CLAUDE.md`, `AGENTS.md`, `.claude/agents/`, `.claude/skills/` | Los asistentes, al trabajar en el repo | Conservar. `CLAUDE.md` pasa de 120 líneas con motivo escrito en su cabecera; falta proponer la fila de `docs/manual/` en su tabla |
| `README.md`, `docs/guias/empezar.md` | Quien clona: instalación y primer día | Conservar |
| `ESTADO.md`, `planes/activos/` | Quien retoma el trabajo | Conservar. `nucleo-auditoria-final` y `nucleo-cierre-auditoria` se cierran con el PR |
| `planes/cerrados/` (75 archivos) | Quien busca por qué se hizo algo | Conservar como carpeta |
| `docs/errores/` (84 archivos) | Quien arregla un fallo parecido | Conservar como carpeta |
| `docs/contrato.md` (329), `docs/jugador.md` (316), `docs/pruebas.md` (368) | Consulta por tema, no lectura seguida | Conservar: son referencia con índice |
| `docs/sala.md`, `componentes.md`, `enemigos.md`, `audio.md`, `ajustes-y-entrada.md`, `interfaz.md`, `arte-y-rendimiento.md`, `validador.md`, `guiones.md`, `salas-de-prueba.md` | Quien toca ese tema; los enlaza `docs/contrato.md` | Conservar |
| `docs/guias/` | Quien crea contenido: recetas paso a paso | Conservar |
| `docs/manual/` | Quien llega sin contexto | Conservar. El glosario del manual remite al de las guías para las piezas de escena; `Ficha` y `Guion` están en los dos |
| `docs/idea.md` y `docs/manual/diseno.md` | Alcance de la v1 y diseño completo | Se solapan. Fusionar solo si se publica `diseno.md`; decisión de la persona |
| `docs/uso-de-ia.md`, `docs/entrega-2.md`, `.github/pull_request_template.md` | Evaluación del curso y PR | Conservar. `docs/entrega-2.md` se regenera con `reporte-entrega.ps1` |
