ACTIVO

# Tienda, pago de estación y viaje rápido como Hollow Knight y Silksong

Pedido por la persona el 17-oct-2026: rehacer la interfaz de la tienda tomando la de Hollow Knight y Silksong, y
con ella cómo se cobra una estación y cómo se elige el destino del viaje rápido. Las capturas de referencia las tomó
la persona de los dos juegos (tiendas, cobro de un asiento en Silksong, viaje del Ciervo en Hollow Knight). Va
después de `nucleo-menus-gis.md` y usa su tema. Aprobado el 17-oct-2026 con lo recomendado en «Por decidir»; se
programa en el paso 7 de `nucleo-auditoria-codigo.md`, junto con los arreglos de menús de esa auditoría. La
confirmación compartida lleva el foco inicial como parámetro: en Sí para comprar y pagar, y en No para Borrar,
Restaurar y Salir.

## Menú de pausa (pedido el 17-oct-2026)

La persona pidió que el menú de pausa (`nucleo/pausa.gd`) siga a Silksong, con una captura de referencia del menú de
pausa. Hoy las opciones están cargadas a la izquierda. En la referencia:
- las opciones van centradas en la pantalla, en columna, una debajo de otra y con aire entre ellas;
- no hay panel: el juego queda visible y oscurecido detrás;
- arriba de la lista va un adorno ancho, y abajo otro más chico;
- la opción con el foco lleva un adorno a cada lado; las demás, nada.

Va en el paso 7 de la auditoría, junto con esta tienda, y usa los mismos adornos de gis. Es la misma pieza que las
flechitas de la confirmación compartida. Se comprueba con capturas a 1280×720 y 1600×720 y con los guiones `pausa`
y `pausa_foco`, sin cambiar su `.esperado`.

## Avance

- 18-oct: H1 a H4 hechos en el paso 7 de la auditoría (`planes/cerrados/nucleo-auditoria-7-menus.md`, piezas 2-6),
  junto con el menú de pausa. Falta H5: la prueba de la persona en el teléfono. El plan se cierra con ella.
- Diferencias con lo que dice este plan, para que decida la persona:
  - La tienda no tiene «la franja fija con la lista corriendo por debajo». Hay `follow_focus` con la franja en la
    fila elegida, porque desplazar la lista al dar el foco movería la fila bajo el dedo.
  - El cobro de la estación ahora pausa el juego.
  - El viaje rápido muestra las ayudas Viajar y Cancelar también cuando sale solo la lista.

## Lo que muestran las referencias

- **Tienda** (las de los dos juegos son casi iguales):
  - un panel en la mitad derecha, con el juego visible a la izquierda;
  - a la izquierda del panel, la lista: ícono, moneda y precio de cada artículo;
  - la fila elegida queda fija en una franja más clara, con adornos arriba y abajo, y la lista corre por debajo de
    ella;
  - a la derecha, el detalle del elegido: nombre y descripción;
  - abajo, las ayudas de Comprar y Cancelar;
  - el dinero se ve en el HUD, no en el panel.
- **Cobro** (asiento de Silksong):
  - una caja centrada con la pregunta, la moneda y la cantidad;
  - debajo, Sí y No lado a lado, la elegida con punteros a los lados;
  - el foco empieza en Sí.
- **Viaje rápido** (Ciervo de Hollow Knight):
  - a la izquierda, la lista de estaciones con un título;
  - a la derecha, un mapa de círculos unidos por líneas, con la estación elegida marcada;
  - abajo, Viajar y Cancelar.

## Qué se hace

1. **Tienda** (`MenuTienda`):
   - el panel en la mitad derecha del área útil, con el juego detenido y visible a la izquierda;
   - la lista a la izquierda del panel, con la moneda y el precio de cada artículo;
   - la fila con el foco en una franja de gis, con un adorno arriba y otro abajo;
   - el detalle a la derecha: nombre en gis grueso y descripción;
   - lo que no alcanza, en gris como hoy (`Tema.FILA_APAGADA`);
   - las PejeCoins: según lo que se decida abajo, el HUD encima del menú o el contador dentro del panel. Si es el
     HUD, se revisa la capa (`docs/contrato.md`, «Capas de dibujo»).
2. **Confirmación compartida**, una pieza para la tienda y para el cobro de una estación:
   - caja centrada con la pregunta, la moneda y la cantidad;
   - Sí y No lado a lado, con el foco en Sí;
   - la elegida con flechitas de gis a los lados.

   Hoy la tienda tiene su propia caja Sí / No y la estación pregunta con la caja de diálogo («Pagar» / «No»); las
   dos pasan a esta pieza.
3. **Viaje rápido** (`MenuEstaciones`):
   - a la izquierda, la lista de estaciones abiertas bajo el título «Viajar»;
   - a la derecha, un mapa de gis: un círculo por estación en la posición de su sala y líneas entre ellas, con la
     elegida marcada.

   El índice de salas del mapa ya tiene el rectángulo de cada sala (`mapa/lienzo_mapa.gd` lo usa). Falta confirmar
   que sirve para una estación de la zona de pruebas, que no tiene mapa, y cómo se ve sin el bloque `mapa/`.

## Hitos

1. H1 · Confirmación compartida.
   - Casos: el foco empieza en Sí; No y Volver cancelan sin cobrar; Sí cobra una vez. Hoy los cubren `tienda` y
     `estaciones`, que se ajustan a la pieza nueva.
   - El cobro de la estación pasa a la pieza; `estaciones` en verde.
2. H2 · Tienda en el panel derecho, con la franja fija y el detalle a la derecha.
   - Casos de la tienda en verde.
   - Capturas a 1280×720 y 1600×720.
3. H3 · Viaje rápido con el mapa de gis.
   - Un caso: un círculo por estación abierta, y la actual marcada.
   - Capturas.
4. H4 · Contrato (filas `Tienda`, `MenuTienda`, `Estacion` y `MenuEstaciones` de «Componentes»), `docs/pruebas.md`, todos los guiones y el revisor.
5. H5 · Prueba de la persona en el teléfono con el dedo. La del control la hacen los compañeros.

## Por decidir (lo recomendado va primero)

- **Íconos de los artículos:** por ahora un dibujo de gis por tipo (vida, mapa, amuleto), hecho en código como los
  adornos. La otra opción es esperar el arte.
- **El HUD sobre la tienda:** mostrarlo encima mientras está abierta, como los dos juegos, o dejar el contador dentro
  del panel.
- **Sin mapa** (sin el bloque `mapa/` o en la zona de pruebas): la lista sola, a lo ancho. La otra opción es poner las
  estaciones en fila, sin posiciones.

## Riesgos

- **Ancho del panel en 4:3:** en la vista de 1280, la mitad derecha son unos 576 px para la lista y el detalle juntos.
  Si no caben, el detalle va debajo de la lista. Se mide antes de decidir.
- **El HUD encima del menú** puede chocar con la capa de la pausa o con el aviso de guardado: se revisa la tabla de
  capas.
