# La bola atravesaba las paredes

- **Síntoma**: el proyectil del botón de poderes cruzaba una pared y golpeaba al muñeco de detrás.
- **Causa**: el proyectil es un `Area2D` y esperaba `body_entered` para deshacerse contra un sólido. Las paredes
  de las salas son `StaticBody2D`, y en Godot 4.7.2 un `Area2D` que se mueve cambiando su posición no los
  detecta: `get_overlapping_bodies()` dio 0 en cada tick dentro de la pared, aunque sí detectaba al jugador
  (`CharacterBody2D`) y a los `Golpeable` (`Area2D`). La causa en el motor no se comprobó en su código fuente.
- **Arreglo**: `nucleo/proyectil.gd` lanza un rayo en cada tick desde su centro hasta su frente después del paso
  (`PhysicsRayQueryParameters2D`, sin contar a quien lo lanzó) y desaparece si toca algo. De paso, un sólido más
  delgado que el paso de un tick ya no se salta.
- **Guion que lo cubre**: `herramientas/guiones/nucleo/poder_bola.guion`. Sin el rayo da
  `MunecoTras/Golpeable golpes obtenido=1.00`.
- **Para lo que venga**: cualquier `Area2D` que deba chocar con el escenario (otros proyectiles, enemigos que
  vuelan) necesita un rayo o una consulta de forma, no `body_entered`.
