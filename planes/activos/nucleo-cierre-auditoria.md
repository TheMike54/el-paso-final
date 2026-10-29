ACTIVO (escrito el 29-oct-2026; aprobado por la persona el 29-oct-2026 con D1, D2 y D8 como los recomienda Claude.
Las demás decisiones, al empezar su grupo)

# Cierre de la auditoría de código: base de enemigos, amuletos, jefes, mapa por zonas y arquitectura

Toma las fases 3 y 4 de `nucleo-base-auditoria-codigo` (lo que no entró en el PR de La Celda) y las reparte en cinco
grupos, cada uno con su rama, su issue y su PR. Al aprobarse, `nucleo-base-auditoria-codigo` pasa a
`REEMPLAZADO POR nucleo-cierre-auditoria.md` y se mueve a `planes/cerrados/`. La lista completa de hallazgos, con cada
archivo:línea y el arreglo propuesto, está fuera del repo; los `F-xxx` de abajo son sus ids.

Cambio de método respecto del plan anterior (pedido por la persona el 29-oct-2026): Codex (`gpt-6.1-sol`) también
escribe código, siempre bajo `validar.ps1`, los guiones completos y el `revisor` (en Opus desde el 29-oct). Gemini ya no
se usa; las lecturas largas las hace Claude Haiku. Quién construye y quién revisa cada tarea va en su fila; cómo se reparte el trabajo entre modelos está en la
metodología de la persona, fuera del repo. El PR declara cada herramienta y su parte, y `docs/uso-de-ia.md`, fila
«Código y documentación», suma Codex en el primer PR que lleve código suyo.

## Decisiones de la persona (antes de su grupo)
Del plan anterior quedaron aprobadas D5, D7 y D9. Faltan estas, con la recomendación de Claude:

| # | Grupo | Pregunta | Recomendación |
|---|---|---|---|
| D1 | 1, 2, 3 | Botín, amuletos y jefes se construyen sin caso real en el juego: excepción a «no se generaliza hasta tener tres casos» | Aceptarla, con la versión mínima probada en `herramientas/salas/` |
| D2 | 1 | Botín: PejeCoins que saltan y se recogen, o sumadas directo | Que salten, con `MonedasSueltas` |
| D3 | 2 | Amuletos: carga máxima, cuántos equipados y qué efectos entran | Ficha y menú para todos; efectos solo de lo que ya existe (velocidad, invulnerabilidad, alcance, Inspiración, curar, PejeCoins de enemigos, brújula) |
| D4 | 3 | Jefes: sistema genérico (fases, arena con `Porton`, entrega, `jefe_vencido`) con un jefe de caja gris | Sí; el primer jefe real va con su zona |
| D8 | 1 | Cómo prueba un guion a un enemigo si atacar exige la `pluma` | Instrucción nueva de guion que da habilidades, sin tocar la escena |
| D10 | 4 | Jugador e interfaz persistentes entre salas (F-097) | La fase 2 midió 0,6-1,8 s de carga en el S50, por encima del umbral de 0,5 s: entra, junto con la carga en segundo plano (F-098) |

## Ramas y PRs
- Orden: 1 → 2 → 3 → 5 → 4. El grupo 1 desbloquea a los demás integrantes; el 4 es el de más riesgo y va al final.
- Una rama por grupo: `feature/nucleo-enemigos-base`, `feature/nucleo-amuletos`, `feature/nucleo-jefes`,
  `feature/mapa-zonas`, `feature/nucleo-arquitectura`. Mientras el PR de La Celda (#11) no se fusione, la del grupo 1
  sale de `feature/contenido-celda` (`9f67615`) y cada una de las siguientes sale de la anterior.
- Al fusionarse el #11 (Squash and merge), la persona mueve la primera rama encima de `main`:
  `git rebase --onto main 9f67615 feature/nucleo-enemigos-base`. Cada rama siguiente se mueve igual cuando se fusiona
  la anterior, con el último commit de la anterior en lugar de `9f67615`; Claude da el comando exacto en su momento.
- Cada grupo abre su PR solo cuando el anterior ya está en `main`, con su issue (`Closes #n`). Lo que el QA del #11
  encuentre se cita en su issue y se arregla en el PR siguiente.

## Cómo se ejecuta cada grupo
- Claude (Opus) define primero las interfaces que tocan el contrato: firmas, señales, campos de ficha. Codex construye
  lo que cuelga de ellas (comportamientos, salas de prueba, guiones, pruebas) en un worktree aparte, sincronizado con el
  árbol de trabajo antes de cada tarea; Claude integra su diff en el árbol principal. Un archivo tiene un solo escritor
  a la vez.
- Cada tarea cierra con `validar.ps1` (`fallos=0`); cada grupo, con `correr-guiones.ps1` completo (`MALOS=0`), el
  `revisor` y una segunda lectura del diff por otro modelo. Lo que solo se ve en el teléfono se pide a la persona.
- Un bloque de commit por tarea terminada, numerado en el archivo que indica `CLAUDE.local.md`.

## Grupo 1 · Base de enemigos (`feature/nucleo-enemigos-base`)
Deja todo lo que necesita una mecánica de enemigo nueva sin tocar el núcleo después: arte, botín, datos por ejemplar,
sonidos propios, guiones que dan habilidades y la categoría «Enemigos» que se llena sola. Referencia de Hollow Knight
para el botín (geo que salta) y la reaparición (ya en `FichaEnemigo.reaparicion`).

| # | Tarea | Hallazgo | Construye | Revisa | Archivos | Comprobación |
|---|---|---|---|---|---|---|
| 1.1 | Arte: un `AnimatedSprite2D` hijo apaga la caja gris en `Enemigo` y en `Palanca`, como ya hacen `Puerta` y `MuroRompible` | F-091 | Claude | `revisor` | `nucleo/enemigo.gd`, `nucleo/palanca.gd`, `docs/contrato.md` | `sala_enemigos` con un enemigo con arte provisional; guion |
| 1.2 | Botín: campo en `FichaEnemigo`; al vencer salta `MonedasSueltas` una sola vez por ejemplar | F-085, D2 | Claude | `revisor` | `nucleo/ficha_enemigo.gd`, `nucleo/enemigo.gd`, contrato | Guion: vencer da las PejeCoins una vez y no al volver a entrar |
| 1.3 | Datos por ejemplar: el comportamiento lee sus números de un recurso exportado por enemigo, no de constantes | F-092 | Claude (interfaz), Codex (pasar los 4 comportamientos de prueba) | Terra + `revisor` | `nucleo/comportamiento_enemigo.gd`, `nucleo/enemigo.gd`, `herramientas/salas/comportamientos/*` | Dos enemigos del mismo tipo con radio distinto; guiones de enemigos sin cambio de `.esperado` |
| 1.4 | Puntos de enganche para las mecánicas: ignorar un golpe (escudo, cerrarse), apagar la gravedad (trepar, enterrarse), saber hacia dónde mira el jugador | Nuevo | Claude | `revisor` | `nucleo/enemigo.gd`, `nucleo/comportamiento_enemigo.gd`, contrato | Prueba de código por enganche |
| 1.5 | Sonidos por ficha: una ficha de enemigo o de zona trae sus sonidos sin tocar la ficha global | F-093 | Codex | Terra + `revisor` | `nucleo/sonido.gd`, `nucleo/ficha_sonidos.gd`, `nucleo/ficha_enemigo.gd` | Guion de evento de enemigo |
| 1.6 | Guion que da habilidades | D8 | Codex | `revisor` | `herramientas/puerto_depuracion.gd`, `docs/guiones.md` | Un guion de enemigo que ataca sin la `pluma` |
| 1.7 | La categoría «Enemigos» de la zona de pruebas lista sola las salas de su carpeta | Nuevo | Codex | Terra | `herramientas/salas/zona_pruebas.gd`, salas de enemigos movidas por la persona en el editor | `prueba_zona_pruebas` |
| 1.8 | Guía corta «cómo se hace un comportamiento de enemigo» con un ejemplo | Nuevo | Claude | Haiku (lee) | `docs/guias/` | Que el ejemplo pase `validar` |

Cierre: `revisor` (toca contrato y física de enemigos), segunda lectura de Terra, APK de desarrollo y prueba en el S50 de
la sala de enemigos con arte y botín.

## Grupo 2 · Amuletos (`feature/nucleo-amuletos`)
- F-087: `FichaAmuleto` (nombre, descripción, costo, efecto como dato); el menú y el inventario la leen; el efecto de la
  brújula sale del mapa.
- F-042: lista oficial de amuletos y regla del validador para ids mal escritos en tienda, NPC y retos.
- D3: los efectos que entran. Cada efecto con su guion de equipar.

## Grupo 3 · Jefes (`feature/nucleo-jefes`)
- F-086 y F-035: vida por fases, arena que cierra un `Porton`, entrega de habilidad y `jefe_vencido` con emisor, probado
  con un jefe de caja gris en una arena de la zona de pruebas (D4).

## Grupo 5 · Mapa por zonas (`feature/mapa-zonas`)
- F-094 (nombre visible y color de zona como dato), F-095 (franja de la zona calculada), F-100 (la zona deja de ser el
  prefijo del id), F-102 (índice del mapa sin conflictos al fusionar), F-096 (tabla de estaciones y bolsa de preguntas
  reales en `contenido/`), F-073 (el inicio del juego como ficha de `contenido/`).

## Grupo 4 · Arquitectura (`feature/nucleo-arquitectura`)
- F-099 y F-103 (partir `jugador.gd` y los archivos largos), F-097 y F-098 (D10), F-016, F-024, F-101, F-104, F-105,
  F-106, F-015, F-011, F-023, F-089, F-090.
- Como pedía el plan anterior: antes de empezar, la tabla «actual → nuevo» de cada fila, aprobada por la persona. Cada
  pieza con el `revisor` y prueba en el S50; la física del jugador, con prueba de sensación.

## Fuera de este plan
F-088 (espera el arte de la mujer), F-047 (cuando el CI pase de 10 min), la tabla de conversión de F-010 (con el primer
cambio de forma del guardado) y F-063 a F-065 (con la segunda zona).
