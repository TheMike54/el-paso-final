# Un guardado con el disco lleno dejaba la partida en 0 bytes

**Síntoma.** Con el disco lleno, guardar una partida que cabe en el búfer de escritura devolvía `OK` y dejaba el archivo
de la partida vacío. Reproducido el 1-nov-2026 con Godot 4.7.2 para Linux en un tmpfs de 1 MB lleno: textos de 2000 y
3900 bytes dieron `err=0` y `tam_final=0`; uno de 20 000 bytes sí dio error y conservó la partida.

**Causa.** `store_string` deja el texto en el búfer, `get_error` todavía da `OK` y `close()` lo vacía sin informar si
falla (`classes/class_fileaccess.rst`, `close`). `Archivo.escribir_atomico` miraba el error antes de cerrar y renombraba
un temporal vacío sobre la partida buena.

**Arreglo.** `escribir_atomico` relee el temporal antes de renombrar y `copiar_atomico` compara la copia: si no
coinciden, borra el temporal y devuelve `ERR_FILE_CANT_WRITE`. En el mismo tmpfs, los tres tamaños dan `err=13` y la
partida conserva sus 500 bytes. `DirAccess.copy_absolute` hace lo mismo: en ese tmpfs devuelve `OK` con una copia cortada, y
la comparación la rechaza y conserva la copia anterior.

El mismo cambio hace visible el fallo: `Partida.guardar` emite `Eventos.guardado_fallido` y el HUD dice «No se pudo
guardar». Antes solo quedaba un error en el registro.

**Qué lo cubre.** `herramientas/guiones/nucleo/guardado.guion`: un texto que no se relee igual (falla con el código
viejo), la señal, el aviso del Hud y que se repite al entrar a otra escena. El disco lleno de verdad no se monta en el
CI: si se toca `Archivo`, se repite la prueba en un tmpfs.
