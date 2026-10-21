# El escupidor de la sala Enemigos Moviles no se alcanzaba

- **Síntoma:** en el S50, el jugador no puede llegar al escupidor. Un pilar le cierra el paso y con solo la `pluma`
  no hay doble salto ni agarre a la pared.
- **Causa:**
  - El pilar del volador, en x 2000, mide 480 px y llega al suelo. El salto llega a 230 px.
  - El guion `enemigos_moviles` no lo atrapaba porque pone al jugador directo junto a cada enemigo.
- **Arreglo:**
  - Dos escalones a la izquierda del pilar, en `herramientas/salas/sala_enemigos_moviles.tscn`.
  - El pilar no se movió: un hueco abajo dejaría al volador ver por debajo.
- **Lo cubre:** `herramientas/guiones/nucleo/moviles_cruzar_pilar.guion`. Cruza el pilar con tres saltos y queda del
  otro lado con las vidas completas.
