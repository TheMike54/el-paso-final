CERRADO

# PejeCoins en el HUD como Silksong

Pedido por la persona el 17-oct-2026 («vamos a hacerlo como Silksong»): el contador aparece al ganar o gastar y
luego desaparece; para ver el total hay que ir al inventario. Aprobado por la persona el 17-oct-2026 con lo recomendado en todas las decisiones.

## Referencia

Notas del juego descompilado (`interfaz.md`, «Moneda», hecho), leídas por un subagente el 17-oct-2026.

- **Silksong** (`CurrencyCounterBase`):
  - al ganar o gastar aparece un «+N» o «−N» aparte, y las ganancias seguidas se suman;
  - espera 1 s y el contador rueda hasta el valor nuevo, un paso cada 0,0125 s, en unos 0,57 s;
  - si ganas mientras pierde, cancela el otro conteo y corrige;
  - aparece en 0,1 s y se funde en 0,3 s, 1,5 s después de terminar de contar.
- **Hollow Knight** (`GeoCounter`): cuenta igual (espera de 1,5 s), pero el Geo se ve siempre. Va debajo de las
  máscaras, alineado a la izquierda, con su ícono (`_GameCameras.prefab`, lectura nueva).
- La posición exacta en Silksong no está en las notas, así que se toma la de Hollow Knight: debajo de las vidas.
- **Diferencia:** ninguno de los dos tiene una barra entre las vidas y la moneda. Aquí la barra de Inspiración se
  queda donde está.

## Qué se hace

- **`interfaz/hud.gd`:**
  - debajo de la barra va un ícono provisional (un círculo gris del alto de la letra) con el número a su derecha,
    sin la palabra «PejeCoins»;
  - el ícono de guardado sigue debajo, en el mismo lugar.
- **Al oír `Eventos.monedas_cambiadas`:**
  - el delta se suma a `pendiente`;
  - se muestra «+N» o «−N» junto al número;
  - el grupo aparece en 6 ticks (0,1 s);
  - si ya estaba contando, la espera vuelve a empezar.
- **En `_physics_process`:**
  - espera 60 ticks (1 s) y luego `mostradas` avanza hacia `monedas` con un paso de
    `maxi(1, ceili(absf(pendiente) / 34.0))` por tick, unos 34 ticks;
  - al llegar se vacía `pendiente`;
  - pasados 90 ticks (1,5 s) se funde en 18 ticks (0,3 s).
- **Cuándo se ve:** al cambiar las monedas, al sentarse en un banco y con el menú de la tienda abierto, aunque la
  tienda ya muestra su propio total. El total siempre está en el inventario (`PaginaInventario`, «PejeCoins»).
- **Redibujo:** solo mientras cuenta o se funde, como el rombo de guardado (nodo propio). Sin nodos nuevos por
  cuadro.
- **Públicas para los guiones:** `monedas_mostradas`, `monedas_pendientes` y `monedas_visibles` (alfa > 0).
- **Contrato:** `docs/contrato.md`, la línea del HUD («PejeCoins bajo la barra»), más la entrada
  `icono-guardado-y-monedas` de `interfaz/funciones.json` (su `que` lo cambia la persona o Claude con su permiso)
  y una entrada nueva para el conteo.

## Hitos

1. H1 · Conteo y fundido. Guion `interfaz/monedas_conteo.guion` con una sala de prueba:
   - al entrar, oculto, aunque haya monedas;
   - ganar 100: se ve, «+100», 60 ticks sin cambiar y llega a 100 en unos 34;
   - ganar dos veces seguidas suma el «+N» y reinicia la espera;
   - gastar durante el conteo corrige al valor final;
   - 90 ticks después se funde y queda oculto;
   - sentarse en un banco lo muestra.
2. H2 · Contrato, `docs/pruebas.md` y la fila «Interfaz»; `validar.ps1` y todos los guiones.
3. H3 · Prueba en el S50. Qué observar:
   - si se nota cuánto ganaste;
   - si el conteo se lee;
   - si al desaparecer se echa de menos el total.

## Decisiones (para la persona)

1. **Al morir** (las monedas pasan a la mochila): Silksong rueda a 0 y lo rompe con un efecto. Aquí: «−N» y
   rueda a 0, sin efecto hasta tener arte (recomendado).
2. **Al entrar a una sala:** oculto (recomendado, como Silksong) o visible un momento.

## Avance

- 17-oct-2026, sesión autónoma: H1 y H2 programados.
  - `monedas_conteo` da 13 casos y 0 fallos. En una copia, seis mutaciones lo hacen fallar.
  - `validar.ps1` y los 149 guiones pasan.
- Precisión: no se muestra con la tienda abierta. El HUD solo oye el bus y no hay aviso de «tienda abierta»; el
  menú de la tienda ya tiene su total, y comprar lo muestra por `monedas_cambiadas`.
- Entradas nuevas en `interfaz/funciones.json`: `monedas-como-silksong` (pasa) y `monedas-telefono` (manual).
- 17-oct-2026, S21 con `adb`, sala Lo Perdido: al morir aparece «● 120 -120», pero la sala se recargaba antes de que
  el conteo llegara a 0 (unos 100 ticks contra 90 de reaparecer). Así no se cumplía la decisión 1.
  - Arreglo: con `jugador_muerto` y un «−N» pendiente, la espera baja a 20 ticks (`TICKS_ESPERA_MUERTE`).
  - El caso de morir de la prueba ahora sigue el orden real (monedas y después la muerte) y exige el 0 antes del
    fundido. Sin el arreglo falla; con él, 13 casos y 0 fallos.
  - Detalle en `docs/errores/2026-10-17-conteo-de-monedas-al-morir.md`.
  - Con el APK corregido, en el mismo S21: al morir el contador se ve en «0» antes de que la sala se recargue.
- Visto en el S21: al entrar a Lo Perdido no aparece el «+120» que da la sala. Es lo esperado: las monedas llegan en
  el `_ready` de la sala, antes de que exista el HUD, y al entrar el contador está oculto.
- H3, prueba de la persona en el teléfono (17-oct-2026), aprobada («funciona increíble»):
  - en la Tienda, comprar el mapa muestra 300 −50 y cuenta;
  - en Lo Perdido, al morir sale −120 y llega a 0 antes del negro;
  - en Prueba 4, entregar un coleccionable muestra +100 y el conteo.
  - Sentarse en un banco no se probó: esa sala no tiene banco.

## Riesgos

- Los guiones `zona_prueba_coleccionable` y `zona_prueba_vitrina` leen las monedas del HUD: siguen leyendo
  `monedas` (el valor real), no `monedas_mostradas`.
- 17-oct-2026, la persona en el S50: sentarse en un banco muestra el contador. Con eso H3 queda completo.
