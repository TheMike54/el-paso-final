# Mecánicas y estado

«Hecho» significa que existe código para la mecánica, no que todo el contenido previsto esté colocado o terminado. Las salas de prueba sirven para ejercitar sistemas y no representan por sí solas contenido de la campaña.

## Hecho en el código

| Mecánica | Estado comprobado y alcance | Archivo principal | Guía o referencia |
|---|---|---|---|
| Movimiento | Caminar, salto de altura variable, tolerancia en bordes y salto en cola; controles por acciones. | `nucleo/jugador.gd` | `docs/jugador.md`, `docs/ajustes-y-entrada.md` |
| Combate | Ataques direccionales, rebote hacia abajo, daño, retroceso y parry; el arma se obtiene como habilidad. | `nucleo/jugador.gd` | `docs/jugador.md`, `docs/enemigos.md` |
| Curar | Mantener la acción consume Inspiración para recuperar vida; puede interrumpirse. | `nucleo/jugador.gd` | `docs/jugador.md` |
| Inspiración | Recurso con capacidad, ganancia al golpear enemigos y gasto en acciones; el HUD muestra su estado. | `nucleo/partida.gd` | `docs/jugador.md`, `docs/interfaz.md` |
| Habilidades | El núcleo declara y aplica habilidades desbloqueables; hay objetos para obtenerlas y salas de prueba. En la campaña se obtienen la Pluma (`celda_3`), la pluma del mapa (`raices_3`) y el impulso (`raices_7`); las demás no están colocadas. | `nucleo/habilidades.gd`, `nucleo/objeto_habilidad.gd` | `docs/jugador.md` |
| Amuletos | Catálogo, obtención, equipamiento condicionado por carga y aplicación de efectos; cambios de equipo en banco. | `nucleo/partida.gd`, `nucleo/ficha_amuleto.gd` | `docs/guias/agregar-un-amuleto-o-un-util.md`, `docs/contrato.md` |
| Útiles | Catálogo de 5 útiles con ícono y 4 cupos independientes de la carga (`MAX_UTILES`); los cinco tienen efecto: Brújula (mapa), Gato (botín ×1,5), Log de Errores (Inspiración por golpe de enemigo), Cartera (al morir conservas la mitad) y Suela (mitad de retroceso). | `nucleo/ficha_util.gd`, `nucleo/utiles.gd`, `mapa/pantalla_mapa.gd`, `nucleo/enemigo.gd`, `nucleo/jugador.gd`, `nucleo/partida.gd` | `docs/guias/agregar-un-amuleto-o-un-util.md` |
| Enemigos | Base con ficha, daño y comportamientos extensibles; existen comportamientos y salas de prueba. En la campaña, la Cucaracha (`raices_2`, `raices_4` a `raices_6`), la Polilla (`raices_4`) y el Hongo escupidor (`raices_5` y `raices_6`). | `nucleo/enemigo.gd`, `nucleo/comportamiento_enemigo.gd`, `contenido/enemigos/` | `docs/enemigos.md`, `docs/guias/agregar-un-enemigo.md` |
| Bancos | Descanso, punto de reaparición y guardado; al descansar se actualiza el progreso de mapa. | `nucleo/banco.gd`, `nucleo/partida.gd` | `docs/sala.md` |
| Tienda | Interacción, menú, compra y recompensas; hay una sala de prueba y, en la campaña, la tienda de `raices_3`, que vende la Brújula. | `nucleo/tienda.gd`, `nucleo/menu_tienda.gd` | `docs/componentes.md`, `docs/interfaz.md` |
| Mapa | Índice de salas, seguimiento de visitas, obtención de mapas y pantalla con brújula. | `mapa/pantalla_mapa.gd`, `mapa/datos_mapa.gd` | `docs/interfaz.md`, `docs/sala.md` |
| Coleccionables | Objeto recogible y registro persistente por sala; existe vitrina para consultarlos. | `nucleo/coleccionable.gd`, `nucleo/vitrina_coleccionables.gd` | `docs/componentes.md`, `docs/interfaz.md` |
| Salas | Escenas con entrada, límites, puertas, llegada y transición; existen cinco escenas de La Celda, ocho de Las Raíces (en caja gris) y salas de prueba. | `nucleo/sala.gd`, `contenido/salas/celda/celda_1.tscn` | `docs/sala.md`, `docs/guias/armar-una-sala.md` |
| Muerte y mochila | Al morir se registra una mochila con monedas; al interactuar abre un reto de 3 preguntas de la bolsa del juego: con 2 aciertos se recuperan y, si no, se pierden. Se autoguarda el cambio. | `nucleo/partida.gd`, `nucleo/mochila.gd`, `nucleo/bolsa_preguntas.gd` | `docs/componentes.md`, `docs/contrato.md` |
| Viaje entre estaciones | Hay lógica de estaciones y menú de destinos; la primera versión no coloca ninguna en sus zonas. | `nucleo/estacion.gd`, `nucleo/menu_estaciones.gd` | `docs/componentes.md`, `docs/interfaz.md` |
| Menús de pausa | Pausa con continuar, configuración y salir; marco de páginas en ciclo con flechas: Inventario (solo lectura), Amuletos, Útiles (mochila de 4 cupos) y Mapa (con botón de vista). Poner o quitar equipo, solo en un banco. | `nucleo/pausa.gd`, `nucleo/marco_menus.gd`, `nucleo/pagina_inventario.gd`, `nucleo/pantalla_amuletos.gd`, `nucleo/pantalla_utiles.gd` | `docs/interfaz.md` |
| Pantalla de cierre | Fin de la primera versión tras la salida de `raices_8`: «Continuará», autoguardado y vuelta al menú. | `contenido/cierre/pantalla_cierre.tscn`, `contenido/objetos/raices/salida_cierre.gd` | `docs/componentes.md` |

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
| Primera versión de las zonas | El alcance pide dos zonas completas con tres enemigos. La Celda (`celda_1` a `celda_5`) y Las Raíces (`raices_1` a `raices_8`, en caja gris, con la Cucaracha, la Polilla y el Hongo escupidor) existen y se recorren seguidas. Falta el arte de Las Raíces y comprobarlas en el teléfono. | `contenido/salas/` | `docs/idea.md`, `docs/guias/armar-una-sala.md` |
| Habilidades de la campaña | La Pluma, la pluma del mapa y el impulso ya se obtienen en la campaña; las habilidades posteriores tienen lógica y pruebas, pero su incorporación se aplaza en el alcance. | `nucleo/habilidades.gd` | `docs/idea.md`, `docs/jugador.md` |
| Viaje rápido en las zonas iniciales | Sistema construido; sin estaciones en la primera versión. | `nucleo/estacion.gd` | `docs/idea.md`, `docs/componentes.md` |
