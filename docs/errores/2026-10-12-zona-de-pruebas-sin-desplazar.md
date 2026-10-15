# La zona de pruebas volvía a no caber y no se desplazaba

- **Síntoma**: en el Senwa S50 (pantalla de 960 × 480), unas 33 salas en tres columnas se salían por arriba y por
  abajo: no se veían la primera fila (Banco, Bola, Caída), «Zona Prueba 4» ni «Volver al menú», y la lista no se
  podía arrastrar. Atrás llevaba al menú y no a la Configuración, de donde se llega. Se vio en una captura con `adb`
  el 12-oct-2026.
- **Causa**: el arreglo de `2026-10-06-zona-de-pruebas-desbordada.md` (tres columnas) solo aplazó el problema: la
  lista crece con cada sala y estaba en un `CenterContainer` fijo, sin desplazamiento. Volver era un botón más de la
  lista y la escena no atendía Atrás.
- **Arreglo**: `herramientas/salas/zona_pruebas.tscn` mete la cuadrícula en un `ScrollContainer` y pone «Volver» fijo
  arriba; `zona_pruebas.gd` calcula de 3 a 6 columnas según el ancho, deja pasar el arrastre de los botones a la
  lista (`MOUSE_FILTER_PASS`) y, con Volver, Atrás o `pausa`, vuelve al menú con `Configuracion.abrir_al_volver`, que
  el menú lee para abrir la Configuración.
- **Guion que lo cubre**: `menu_configuracion` comprueba que el menú abre la Configuración al volver de la zona.
  Que la lista quepa y se desplace con el dedo es prueba manual («Menú de desarrollo» en `docs/pruebas.md`).
