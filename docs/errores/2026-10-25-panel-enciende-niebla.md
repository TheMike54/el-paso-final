# El panel de pruebas mostraba la niebla aunque su ajuste estuviera apagado

- **Síntoma:** con «Niebla» apagada en Avanzado, apagar y volver a encender el grupo «Niebla» del panel de pruebas
  la dejaba visible: se medía un sobredibujo que el jugador nunca ve. Lo encontró la auditoría del 25-oct-2026.
- **Causa:** `PanelPruebas.apagar(grupo, false)` ponía `visible = true` y `PROCESS_MODE_INHERIT` a cada nodo, sin
  importar cómo estaba antes de apagarlo.
- **Arreglo:** al apagar se guarda el `visible` y el `process_mode` de cada nodo; al encender se devuelven esos.
- **Lo cubre:** el caso «encender Niebla con su ajuste apagado la deja oculta» de
  `herramientas/pruebas/prueba_piezas_sala.gd` (guion `herramientas/guiones/nucleo/piezas_sala.guion`). Sin el
  arreglo, falla.
