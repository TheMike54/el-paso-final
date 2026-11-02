# Mecánicas y estado

«Hecho» significa que existe código para la mecánica, no que todo el contenido previsto esté colocado o terminado. Las salas de prueba sirven para ejercitar sistemas y no representan por sí solas contenido de la campaña.

## Hecho en el código

| Mecánica | Estado comprobado y alcance | Archivo principal | Guía o referencia |
|---|---|---|---|
| Movimiento | Caminar, salto de altura variable, tolerancia en bordes y salto en cola; controles por acciones. | `nucleo/jugador.gd` | `docs/jugador.md`, `docs/ajustes-y-entrada.md` |
| Combate | Ataques direccionales, rebote hacia abajo, daño, retroceso y parry; el arma se obtiene como habilidad. | `nucleo/jugador.gd` | `docs/jugador.md`, `docs/enemigos.md` |
| Curar | Mantener la acción consume Inspiración para recuperar vida; puede interrumpirse. | `nucleo/jugador.gd` | `docs/jugador.md` |
| Inspiración | Recurso con capacidad, ganancia al golpear enemigos y gasto en acciones; el HUD muestra su estado. | `nucleo/partida.gd` | `docs/jugador.md`, `docs/interfaz.md` |
| Habilidades | El núcleo declara y aplica habilidades desbloqueables; hay objetos para obtenerlas y salas de prueba. Su existencia no implica que todas estén en la campaña. | `nucleo/habilidades.gd`, `nucleo/objeto_habilidad.gd` | `docs/jugador.md` |
| Amuletos | Catálogo, obtención, equipamiento condicionado por carga y aplicación de efectos; cambios de equipo en banco. | `nucleo/partida.gd`, `nucleo/ficha_amuleto.gd` | `docs/guias/agregar-un-amuleto-o-un-util.md`, `docs/contrato.md` |
| Útiles | Catálogo y una ranura independiente de la carga (hoy `MAX_UTILES` = una); la brújula tiene uso en el mapa. | `nucleo/ficha_util.gd`, `mapa/pantalla_mapa.gd` | `docs/guias/agregar-un-amuleto-o-un-util.md` |
| Enemigos | Base con ficha, daño y comportamientos extensibles; existen comportamientos y salas de prueba. | `nucleo/enemigo.gd`, `nucleo/comportamiento_enemigo.gd` | `docs/enemigos.md`, `docs/guias/agregar-un-enemigo.md` |
| Bancos | Descanso, punto de reaparición y guardado; al descansar se actualiza el progreso de mapa. | `nucleo/banco.gd`, `nucleo/partida.gd` | `docs/sala.md` |
| Tienda | Interacción, menú, compra y recompensas; hay una sala de prueba. | `nucleo/tienda.gd`, `nucleo/menu_tienda.gd` | `docs/componentes.md`, `docs/interfaz.md` |
| Mapa | Índice de salas, seguimiento de visitas, obtención de mapas y pantalla con brújula. | `mapa/pantalla_mapa.gd`, `mapa/datos_mapa.gd` | `docs/interfaz.md`, `docs/sala.md` |
| Coleccionables | Objeto recogible y registro persistente por sala; existe vitrina para consultarlos. | `nucleo/coleccionable.gd`, `nucleo/vitrina_coleccionables.gd` | `docs/componentes.md`, `docs/interfaz.md` |
| Salas | Escenas con entrada, límites, puertas, llegada y transición; existen cinco escenas de La Celda y salas de prueba. | `nucleo/sala.gd`, `contenido/salas/celda/celda_1.tscn` | `docs/sala.md`, `docs/guias/armar-una-sala.md` |
| Muerte y mochila | Al morir se registra una mochila con monedas; puede recuperarse y se autoguarda el cambio. | `nucleo/partida.gd`, `nucleo/mochila.gd` | `docs/componentes.md`, `docs/contrato.md` |
| Viaje entre estaciones | Hay lógica de estaciones y menú de destinos; su presencia en las zonas depende del contenido. | `nucleo/estacion.gd`, `nucleo/menu_estaciones.gd` | `docs/componentes.md`, `docs/interfaz.md` |

## Diseñado sin construir

Estos elementos figuran en el alcance como aplazados; no se presenta como terminado el contenido que dependería de ellos. El núcleo puede incluir piezas reutilizables relacionadas.

| Mecánica o contenido | Estado | Archivo principal | Guía o referencia |
|---|---|---|---|
| Minijuego de apuestas | Aplazado en el diseño; no se identificó una implementación al revisar el código. | Sin archivo principal identificado | `docs/idea.md` |
| Mejoras del arma | Aplazadas en el diseño; no se identificó una implementación al revisar el código. | Sin archivo principal identificado | `docs/idea.md` |
| Final y zonas restantes | Aplazados en el alcance; la existencia del sistema de salas no construye esas zonas. | `nucleo/sala.gd` para el sistema existente | `docs/idea.md`, `docs/guias/armar-una-sala.md` |

## Pendiente

| Mecánica o contenido | Estado | Archivo principal | Guía o referencia |
|---|---|---|---|
| Primera versión de las zonas | El alcance pide dos zonas completas con tres enemigos; en `contenido/salas/` se identificaron escenas de La Celda. Falta construir y comprobar el resto del alcance. | `contenido/salas/celda/` | `docs/idea.md`, `docs/guias/armar-una-sala.md` |
| Habilidades de la campaña | Hay lógica y pruebas, pero la incorporación de las habilidades posteriores se aplaza en el alcance. | `nucleo/habilidades.gd` | `docs/idea.md`, `docs/jugador.md` |
| Viaje rápido en las zonas iniciales | Sistema construido; su colocación en las zonas iniciales queda condicionada al contenido. | `nucleo/estacion.gd` | `docs/idea.md`, `docs/componentes.md` |
