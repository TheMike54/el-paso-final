# Interfaz

Lo que se dibuja encima del juego: hoy los corazones de vida, la barra de Inspiración, las PejeCoins y el ícono
de guardado (`interfaz.tscn`, script `hud.gd`). Los menús todavía viven en `nucleo/`.

## Primero
Leer `funciones.json` de esta carpeta: la primera funcionalidad con `"pasa": false` es la que sigue.

## Reglas
- Se entera de todo por el bus de eventos (`Eventos`) y lee `Partida` solo al entrar a la sala, para el primer
  cuadro. Nunca lee al jugador ni a otro nodo de la sala: así funciona igual con cualquier sala.
- La sala carga `interfaz.tscn` con `load()` si existe: el núcleo no depende de este bloque. Si se mueve o se
  renombra, se cambia `Sala.INTERFAZ` en el mismo cambio.
- Posiciones como en el diseño: centro en fracción de una pantalla 16:9, anclado a su esquina y medido en el lado
  corto, como los botones táctiles. Nada fuera de la pantalla en 16:9, 20:9 ni 4:3.
- Todo en gris hasta tener arte; cada herramienta de IA nueva o recurso ajeno, en `docs/uso-de-ia.md`.

## Cómo se comprueba
- `.\herramientas\validar.ps1` y los guiones de `herramientas/guiones/interfaz/`, que leen lo que muestra el `Hud`
  (`vidas`, `bloques_llenos`, `aviso_visible`) con la clave `valor`.
- Si se ve bien y no estorba lo juzga la persona en el teléfono.
