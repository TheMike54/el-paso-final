# La música de prueba deja recursos vivos al salir sin pantalla

- **Síntoma:** el guion `menu_configuracion.guion` pasaba (`GUION OK`), pero 1 de cada 6 corridas terminaba con
  `ERROR: 2 resources still in use at exit`, una línea que hace fallar la revisión de los guiones.
- **Causa:** al abrir el panel «Audio», la Configuración toca la música de prueba (`musica_prueba.ogg`). Sin pantalla,
  Godot usa un controlador de audio de mentira y, a veces, la reproducción del `ogg` sigue registrada al cerrar,
  aunque el panel ya la había detenido. Con la música sin tocar, 0 de 6 corridas lo mostraron.
- **Arreglo:** `nucleo/configuracion.gd`, `_mostrar`: la música solo se toca si `DisplayServer.get_name()` no es
  `headless`. Sin pantalla nadie la oye; con pantalla (ventana y teléfono) suena igual que antes. Tras el arreglo,
  0 de 10 corridas.
- **Lo cubre:** `herramientas/guiones/nucleo/menu_configuracion.guion` y `herramientas/guiones/nucleo/musica.guion`
  (la revisión de todos los guiones falla con cualquier línea `ERROR`). Desde el 27-oct-2026 el panel ya no tiene
  reproductor ni `musica_prueba.ogg`: le pide el tema a `Musica` (`nucleo/musica.gd`), que es la única que reproduce
  música, y la guarda vive ahí (`Musica.mudo`, con `Ajustes.sin_ventana()`): sin pantalla cuenta los pedidos pero no
  llama a `play()`.
