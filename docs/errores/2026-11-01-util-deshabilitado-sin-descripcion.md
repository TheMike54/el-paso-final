# Un útil deshabilitado no se podía consultar con el dedo

**Síntoma.** De pie o sin ranura, tocar un útil no mostraba su descripción. Amuletos sí lo hacía.

**Causa.** La descripción solo se actualizaba con `focus_entered` y `mouse_entered`; ninguna fila respondía al toque.

**Arreglo.** `nucleo/pantalla_utiles.gd` conecta `gui_input` de cada fila a `_al_tocar`, como Amuletos.

**Guion.** `nucleo/utiles`, caso «de pie, tocar un util deshabilitado lo describe».
