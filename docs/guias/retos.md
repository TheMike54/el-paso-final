# Retos de preguntas

**Para qué sirve:** crear una ronda de preguntas con recompensa opcional.

**Antes de empezar:** leer `docs/componentes.md`, filas `RetoPreguntas`, `FichaPregunta` y `Recompensa`. Modelo: `herramientas/salas/sala_reto.tscn`.

1. Con el editor abierto, instanciar `nucleo/reto_preguntas.tscn` como hijo directo de la sala. Dar `id` estable y único, sin prefijos reservados, y `quien`.
2. Llenar `preguntas` con `FichaPregunta`: texto, dos o tres opciones y el índice `correcta`. Fijar `meta` entre 1 y el número de preguntas; asignar `recompensa` si corresponde (`nucleo/reto_preguntas.gd`).
3. En consola ejecutar `.\herramientas\validar.ps1` y un guion basado en `herramientas/guiones/nucleo/reto.guion`. En el juego comprobar aciertos, ronda fallida, interrupción y premio único al ganar.
