# El aviso de recursos se dibujaba encima del de pocos toques

- **Síntoma:** en el S50, con «Recursos: alto», la línea «Este teléfono parece de gama baja...» de Configuración
  salía sobre la línea «Tu celular reconoce pocos toques a la vez...» y las dos se leían encimadas.
- **Causa:** el menú reservaba la franja del aviso de pocos toques para sus opciones, las ranuras y la nueva partida,
  pero no para Configuración: su lista ocupa toda el área útil y el aviso de recursos, su última fila, caía en esa
  franja.
- **Arreglo:** `Configuracion.reservado_abajo`, que deja un hueco al final de la lista; el menú lo pone igual que en
  las ranuras.
- **Lo cubre:** `herramientas/guiones/nucleo/menu_configuracion.guion`, caso «el aviso de recursos queda arriba del
  de pocos toques» (falla sin la línea del menú).
