# Atrás con la lista de Recursos abierta subía un nivel de más

- **Síntoma**: en el Senwa S50, con la lista de Recursos abierta en la Configuración, Atrás cerraba la lista y además
  salía de la Configuración al menú. Se vio en una captura con `adb` el 12-oct-2026.
- **Causa**: en Android la lista (`PopupMenu` del `OptionButton`) se cierra con la misma tecla Atrás y después llega
  `NOTIFICATION_WM_GO_BACK_REQUEST` al menú, que llamaba a `Configuracion.atras()` como si la lista no existiera.
- **Arreglo**: `nucleo/configuracion.gd` anota el tick en que se cierra la lista (`popup_hide`); `atras()` cierra la
  lista si está abierta y no hace nada más si se cerró en ese tick o en el anterior.
- **Guion que lo cubre**: `menu_configuracion` (Atrás con la lista abierta, y Atrás justo después de cerrarla).
