# NPC y diálogo

**Para qué sirve:** colocar un personaje con conversaciones y recompensas por etapa.

**Antes de empezar:** leer `docs/componentes.md`, filas `Npc`, `FichaDialogo` y `LineaDialogo`. Modelo: `herramientas/salas/sala_dialogo.tscn` y `contenido/npc/eterno/`.

1. Con el editor abierto, instanciar `nucleo/npc.tscn` en la sala y dar un `id` estable, único en ella y sin prefijos reservados. Para un NPC de varias salas, crear una escena heredada en `contenido/npc/<id>/`.
2. Crear una `FichaDialogo` por etapa en `conversaciones`; llenar sus `lineas` con `LineaDialogo`, texto, opciones y destinos. Las opciones y destinos corresponden por índice; `FIN` termina y `CANCELAR` cierra sin contar. Agregar `Recompensa` a la ficha si corresponde (`nucleo/ficha_dialogo.gd`, `nucleo/linea_dialogo.gd`).
3. Opcional: asignar un `AnimatedSprite2D` hijo a `animacion`, con dibujo mirando a la derecha. `entregar` no debe repetir en bucle (`nucleo/npc.gd`).
4. En consola ejecutar `.\herramientas\validar.ps1` y un guion basado en `herramientas/guiones/nucleo/dialogo_completo.guion`. En el juego comprobar opciones, cancelación, etapas y recompensa única al volver a hablar.
