# Audio y Brillo abrían sin porcentaje

**Síntoma.** Con el volumen en 0 o el brillo en su mínimo, la etiqueta de porcentaje abría vacía hasta mover la barra.

**Causa.** La etiqueta solo se escribía en la señal de cambio de la barra, y poner el valor que la barra ya tiene no la emite.

**Arreglo.** `nucleo/panel_audio.gd` y `nucleo/pantalla_brillo.gd` escriben el porcentaje al abrir.

**Guion.** `nucleo/menu_configuracion`, casos «al abrir Audio…» y «al abrir Brillo…».
