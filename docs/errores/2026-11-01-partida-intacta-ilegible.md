# Una partida intacta que no se podía abrir contaba como dañada

**Síntoma.** Un archivo de partida que existe y no se puede abrir (reproducido el 1-nov-2026 bloqueándolo desde otro proceso en Windows: `get_open_error` da 12, `ERR_FILE_CANT_OPEN`) cargaba como `DANADA`. La ficha decía «Dañada» y ofrecía Borrar sobre una partida buena.

**Causa.** `FileAccess.get_file_as_string` devuelve `""` si no puede abrir el archivo (`classes/class_fileaccess.rst`, `get_file_as_string`) y `Guardado.cargar` parseaba ese texto vacío sin mirar el error.

**Arreglo.** Estado nuevo `ILEGIBLE` en `nucleo/guardado.gd` y en `docs/contrato.md`: `cargar` mira `FileAccess.get_open_error()`. La ficha dice «No se puede leer», no se abre y no ofrece Borrar ni Restaurar; el foco va a Volver. `Guardado.Resultado.cerrada()` agrupa los estados que no se abren. Con el mismo bloqueo real, `cargar` da `ILEGIBLE`.

**Guion.** `nucleo/guardado`, casos «un archivo intacto que no se puede abrir da ILEGIBLE y no DANADA» y «un error de abrir otro archivo no vuelve ILEGIBLE una partida buena»; `nucleo/ranuras`, «la que no se puede abrir lo dice y no ofrece Borrar ni Restaurar». El fallo se finge con `Guardado.fingir_fallo`: un archivo que existe y no se abre no se monta igual en Windows, Linux y Android.
