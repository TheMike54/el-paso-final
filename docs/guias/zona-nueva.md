# Zona nueva

**Para qué sirve:** crear la base y la posición en el mapa de una zona de salas.

**Antes de empezar:** leer `docs/sala.md`, propiedades `ficha_zona` y `posicion_mapa`, y `docs/arte-y-rendimiento.md`, «Arte de zona».

1. Con el editor abierto, crear `contenido/zonas/<zona>/sala_<zona>.tscn` como escena heredada de `contenido/zonas/celda/sala_celda.tscn`. Ajustar en la base luz, música y capas comunes; conservar los contenedores que usan las salas.
2. Crear `contenido/zonas/<zona>/zona_<zona>.tres` como `FichaZona` (`nucleo/ficha_zona.gd`), con `nombre`, `color` y `origen_mapa`. Asignarla a `ficha_zona` en la base; todas las salas de esa zona comparten la misma ficha. Modelo: `contenido/zonas/celda/zona_celda.tres`.
3. Crear cada sala heredando la base y definir `limites` y `posicion_mapa` respecto al origen. El rectángulo en el mapa suma origen, posición y límites; no debe encimarse con otro. Para el orden vertical consultar `docs/sala.md`. Seguir `docs/guias/armar-una-sala.md` para puertas, arte y guion.
4. En consola regenerar el índice con `& $env:GODOT_PATH --headless --path . --quit-after 600 res://herramientas/generar_mapa.tscn` y comprobar `error=0`. Ejecutar `.\herramientas\validar.ps1` y comprobar `fallos=0`; abrir el mapa en el juego y verificar posición y conexiones.
