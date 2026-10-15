# Interfaz

Lo que se dibuja encima del juego (`interfaz.tscn`, script `hud.gd`). Los menús son de `nucleo/`.

## Primero
Leer `funciones.json` de esta carpeta.

## Reglas
- Se entera de todo por el bus de eventos (`Eventos`) y lee `Partida` solo al entrar a la sala, para el primer
  cuadro. Nunca lee al jugador ni a otro nodo de la sala: así funciona igual con cualquier sala.
- La sala carga `interfaz.tscn` con `load()` si existe: el núcleo no depende de este bloque. Si se mueve o se
  renombra, se cambia `Sala.INTERFAZ` en el mismo cambio.
- Posiciones como en el diseño: centro en fracción de una pantalla 16:9, anclado a su esquina y medido en el lado
  corto, como los botones táctiles. Nada fuera de la pantalla en todo el rango de la vista, de 4:3 a 22:9.
- Todo en gris hasta tener arte.

## Cómo se comprueba
- `.\herramientas\validar.ps1` y los guiones de `herramientas/guiones/interfaz/`, que leen lo que muestra el `Hud`
  (`vidas`, `bloques_llenos`, `aviso_visible`) con la clave `valor`.
- En el teléfono, la fila «Interfaz» de `docs/pruebas.md`.
