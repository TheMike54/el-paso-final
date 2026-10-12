# El dedo no le atinaba al volumen ni a las opciones de Recursos

- **Síntoma**: en el Senwa S50, la barra de volumen de la Configuración costaba agarrarla con el dedo, y cada opción
  de la lista de Recursos medía unos 18 px de alto en la captura. Con `adb` la barra sí se movía: el problema era el
  tamaño, no la lógica. Prueba en teléfonos del 12-oct-2026.
- **Causa**: el `HSlider` de `nucleo/configuracion.tscn` estaba centrado verticalmente (`size_flags_vertical = 4`)
  y sin tamaño mínimo, así que su área de toque era su propia altura (unos 10 px físicos); la lista del
  `OptionButton` usaba la letra y la separación por omisión del tema.
- **Arreglo**: la barra ocupa toda la fila (64 px de alto mínimo, `size_flags_vertical = 3`) y responde en toda esa
  área; `configuracion.gd` agranda la letra (30) y la separación (28) de la lista de Recursos.
- **Guion que lo cubre**: `menu_configuracion` sigue comprobando que el volumen se guarda; que el dedo atine es
  prueba manual («Configuración en el menú» en `docs/pruebas.md`).
