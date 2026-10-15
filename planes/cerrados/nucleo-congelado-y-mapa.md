CERRADO

# Decoración congelada en el hit-stop y mapas que se guardan

Aprobado por la persona el 13-oct-2026 (decisiones B y C de las preguntas de diseño de la auditoría de código; la A,
la caja gris como `sala_inicial`, se queda hasta la primera sala real). Rama: `feature/nucleo-menu-tactil` (PR #5),
como segundo commit encima de `d0ae986`.

## B. `congelado-decoracion`

- Hoy `Planta` y `Niebla` (`nucleo/planta.gd`, `nucleo/niebla.gd`) avanzan en `_process` con su propio tiempo y no
  preguntan `Congelado.activo()`: en el parry (`ticks_congelado_parry` = 20, 0,33 s) la planta gira hasta ~5° y la
  niebla avanza ~8 px mientras todo lo demás está quieto. Hollow Knight congela todo.
- Cambio: al empezar su `_process`, si `Congelado.activo()`, no avanzan. `Congelado` cuenta cuadros de física; en
  `_process` puede haber más de un cuadro de dibujo por tick, y eso es lo esperado.
- Cambiar también la cabecera de `nucleo/congelado.gd` (hoy dice que lo que corre por tiempo no se congela; las
  partículas siguen sin congelarse) y `docs/contrato.md` (congelado común, ~línea 180).
- Prueba: caso nuevo en `herramientas/salas/prueba_recursos.gd` (ya crea `Planta` y `Niebla`): con
  `Congelado.pedir(20)`, `Planta.tiempo` y la posición de la niebla no cambian; al terminar, avanzan.

## C. `mapa-obtener`

- Hoy `mapa/objeto_mapa.gd:_al_entrar` hace `Partida.mapas.append` sin aviso ni autoguardado, y
  `Partida.dar_recompensa` con `Recompensa.Tipo.MAPA` (`nucleo/partida.gd`, ~línea 217) hace lo mismo; el arreglo H14
  quedó a medias. La entrega del NPC sí autoguarda al final (`entrega_recompensas.gd`).
- Cambio: `Partida.obtener_mapa(zona: String)` como `obtener_amuleto`: si ya lo tiene no hace nada; si no, lo suma y
  lo avisa por el mismo camino que habilidades y amuletos (el aviso autoguarda). La usan `ObjetoMapa` y
  `dar_recompensa`. Revisar que el NPC no autoguarde dos veces seguidas de forma que cambie un `.esperado` sin querer.
- Antes de tocar: Grep de `autoguardados` en `herramientas/guiones/**/*.esperado` y en las pruebas
  (`zona_prueba_coleccionable.esperado`, `prueba_dialogo.gd`, `prueba_guardado.gd`…). Si un número cambia por
  este cambio, se actualiza a propósito y se dice.
- Contrato: agregar el mapa a la lista de momentos de autoguardado (`docs/contrato.md`, fuente única de los momentos)
  y a `nucleo/CLAUDE.md` / `mapa/CLAUDE.md` si lo nombran.
- Prueba: caso nuevo en `herramientas/salas/prueba_guardado.gd`: recoger el mapa sube `autoguardados` en 1, una
  segunda vez no sube, y el mapa sigue al recargar.

## Cierre

`validar.ps1` 189+/0, todos los guiones (el CI los corre; en local, ciclo aparte), `revisor` (toca guardado y
contrato), `"pasa": true` en las dos entradas, bloque de commit en `commits-pendientes.md` (el archivo que dice
`CLAUDE.local.md`) y, con él, el título y la descripción nuevos del PR #5 (What changed? · Why? · QA evidence ·
Risk / rollback; cubre #5 + `1dc03a4` + `d0ae986` + este commit; declaración de IA: Claude Code escribió el código,
las pruebas y los documentos). El plan pasa a `planes/cerrados/`.

## Avance

- 13-oct-2026: entradas agregadas a `nucleo/funciones.json` con `"pasa": false`.
- 13-oct-2026: hecho. B como se planeó. C con una señal nueva, `Eventos.mapa_obtenido(zona: String)`, que
  `Partida` oye para autoguardar; el bus pasa de 19 a 20 señales. Con una recompensa de mapa, el NPC, la
  entrega y el reto guardan dos veces, como ya pasaba con amuletos y habilidades; ningún `.esperado` cambió por
  eso. Registro: `docs/errores/2026-10-13-mapa-sin-autoguardar.md`. `validar.ps1` 189/0, los 128 guiones en
  verde, `revisor` sin fallos de código (dos cuentas de `docs/pruebas.md` corregidas). Las dos entradas pasan.
