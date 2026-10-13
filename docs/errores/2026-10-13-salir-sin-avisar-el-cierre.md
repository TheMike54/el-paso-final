# Salir desde el menú no avisaba el cierre

- **Síntoma:** encontrado al contrastar el código con la documentación oficial, sin verse en juego. «Sí» en la
  confirmación de salir cerraba con `get_tree().quit()`, que no manda `NOTIFICATION_WM_CLOSE_REQUEST`; lo que se
  guarda con ese aviso (las barras de Configuración sin soltar) no se habría guardado. Hoy no se nota: la
  confirmación solo aparece con Configuración ya cerrada, y cerrarla guarda.
- **Causa:** `quit()` termina sin avisar a los nodos (`inputs/handling_quit_requests.rst`, «Sending your own quit
  notification»).
- **Arreglo:** `Menu.salir()` manda el aviso a todo el árbol con `propagate_notification` y después sale.
- **Lo cubre:** `herramientas/guiones/nucleo/menu_configuracion.guion`, caso «el aviso de cierre guarda las barras
  que no se soltaron» (cubre lo que hace Configuración con el aviso; que `Menu.salir()` lo mande se revisa leyendo,
  porque una prueba que llama a `quit()` cierra la corrida).
