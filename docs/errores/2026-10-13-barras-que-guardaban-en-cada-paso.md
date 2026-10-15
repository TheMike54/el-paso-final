# Arrastrar el volumen o el brillo escribía los ajustes en cada paso

- **Síntoma:** encontrado leyendo el código (auditoría del 13-oct-2026). Un arrastre completo de una barra de
  volumen o de brillo escribía `ajustes.json` unas 20 veces, en el almacenamiento lento de un teléfono de gama baja.
- **Causa:** cada `value_changed` llamaba a guardar.
- **Arreglo:** la barra aplica al momento y guarda al soltarla, con «−» y «+», al cambiar de panel, al cerrar la
  Configuración y al perder el foco la app.
- **Lo cubre:** `herramientas/guiones/nucleo/menu_configuracion.guion`, casos «mover una barra aplica pero no escribe
  el archivo hasta soltarla» (falla sin el arreglo), «salir del panel guarda la barra que no se solto» y los de brillo
  y volumen, que ahora releen el archivo.
