# El volumen del teléfono cambiaba los íconos del control a las teclas

- **Síntoma:** con un control de Xbox, en la zona de pruebas, junto a «Categoría» salían las teclas Z y C en lugar
  de LB y RB. Lo vio el QA del #6 (issue #7, Galaxy Tab S9 FE, fila 7) en la captura de esa pantalla.
- **Causa:** `UltimaEntrada.marca_teclado` (`nucleo/ultima_entrada.gd`) daba `TECLADO` con cualquier tecla pulsada, y
  en Android el volumen llega como tecla. La captura de la tableta se toma con encendido + bajar volumen: en ese
  momento `IconoBoton` pasaba a dibujar las teclas de `pagina_anterior` y `pagina_siguiente`. Que esa fuera la causa
  de lo que vio el QA es probable, no está comprobado: se confirma repitiendo la fila sin capturar.
- **Arreglo:** `marca_teclado` ignora las teclas de volumen (`UltimaEntrada.TECLAS_DE_VOLUMEN`: `KEY_VOLUMEUP`,
  `KEY_VOLUMEDOWN` y `KEY_VOLUMEMUTE`, `classes/class_@globalscope.rst:1466-1482`). Atrás sigue marcando el teclado,
  para que un menú muestre el foco. Decidido por la persona el 24-oct-2026.
- **Lo cubre:** los casos «el volumen no marca el teclado» y «bajar el volumen no cambia nada en clasificar» de
  `herramientas/pruebas/prueba_icono_boton.gd` (guion `herramientas/guiones/nucleo/icono_boton.guion`).
