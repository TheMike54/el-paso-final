# La ventana mostraba la vista anterior al maximizarla o al hacerla muy larga

- **Síntoma**: en la ventana de la PC, al maximizar desde una ventana muy larga quedaban barras negras arriba y
  abajo y la zona de juego en 22:9, aunque la ventana maximizada (~1,87:1) está dentro del rango y no lleva barras.
  En una ventana muy larga, con la pausa abierta, no salían barras y el texto se veía ensanchado.
- **Causa** (compatible con lo medido, no demostrada dentro del motor): `nucleo/arranque.gd` cambiaba
  `content_scale_aspect` y `content_scale_size` dentro de la señal `size_changed`. La ventana guardaba el valor
  nuevo (su zona visible era la correcta), pero la imagen se seguía dibujando con la vista anterior hasta el
  siguiente cambio de tamaño. El fallo es intermitente: en otras corridas la misma secuencia salió bien. Medido
  con una ventana real manejada por la API de Windows (maximizar, restaurar, cambios de tamaño seguidos, con y sin
  pausa): con el ajuste inmediato
  fallaban la ventana larga (sin barras), larga → maximizada (barras de 22:9), vertical → maximizada (zona de 4:3)
  y larga → 1280×720 (barras arriba); restaurar desde maximizada no falló y el arrastre con el ratón no se simuló.
- **Arreglo**: el ajuste se hace diferido, al final del cuadro (`call_deferred` desde `size_changed`). Con eso las
  mismas secuencias dan la vista y las barras esperadas.
- **Prueba que lo cubre**: ninguna automática: sin pantalla la D está apagada y no hay ventana que redimensionar. Lo
  cubre el caso manual «Ventana en la PC» de `docs/pruebas.md`; la cuenta de la vista, `vista.guion`.
