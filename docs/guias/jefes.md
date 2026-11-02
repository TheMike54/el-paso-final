# Jefes

**Para qué sirve:** armar una arena con un enemigo de fases y recompensa única.

**Antes de empezar:** leer `docs/enemigos.md`, «Jefes», y `docs/guias/comportamiento-de-enemigo.md`, «Un jefe con fases y arena». Modelo: `herramientas/salas/sala_jefe.tscn`.

1. Con el editor abierto, colocar un `nucleo/enemigo.tscn` con ficha `FichaEnemigo`, `jefe = true` y `umbrales_fase` de mayor a menor. El comportamiento lee `enemigo.fase` o usa `al_cambiar_fase`; crear ataques en `actuar()`.
2. Agregar un `Area2D` con `nucleo/arena_jefe.gd` y una `CollisionShape2D` hija directa que cubra el combate. Asignar `jefe`, `id_jefe` estable, `portones` abiertos al empezar y `recompensa`. La arena cierra al entrar y abre al vencer; registra la victoria y entrega una sola vez.
3. En consola ejecutar `.\herramientas\validar.ps1` y un guion basado en `herramientas/guiones/nucleo/sala_jefe.guion`. En el juego comprobar aviso de cada fase, cierre y apertura, muerte y regreso tras la victoria.
