# La lista de la zona de pruebas no cabía en la pantalla

- **Síntoma**: en el teléfono de prueba, con 12 salas más «Volver al menú», la lista se salía por arriba y por
  abajo: no se veían «Sala Banco», «Sala Cámara», «Sala Puerta B» ni «Volver al menú». Se vio en una captura con
  `adb`.
- **Causa**: `herramientas/salas/zona_pruebas.tscn` usaba una sola columna (`VBoxContainer`) centrada; 13 botones de
  64 px más su separación suman unos 990 px contra 720 de alto.
- **Arreglo**: la lista es un `GridContainer` de tres columnas (`zona_pruebas.gd` y `.tscn`).
- **Guion que lo cubre**: ninguno, es diseño de pantalla; se revisa en la prueba manual «Menú de desarrollo» de
  `docs/pruebas.md` y con una captura en el teléfono.
