# Aviso de guardado fallido al entrar a otra ranura

**Síntoma.** Si falla un guardado en la ranura 1 y se entra después a la ranura 2, el HUD dice «No se pudo guardar» de una ranura que no falló, hasta el siguiente guardado bueno.

**Causa.** `Partida.ultimo_guardado_fallo` solo lo apagaban un guardado bueno y `reiniciar()`; abrir una ranura con partida pasa por `desde_diccionario`, que no lo toca.

**Arreglo.** `MenuPrincipal.preparar_ranura` lo apaga tras cargar la partida: lo que acaba de leer es lo que hay en disco.

**Guion.** `herramientas/guiones/nucleo/ranuras.guion`, caso «abrir una ranura olvida el fallo de la anterior».
