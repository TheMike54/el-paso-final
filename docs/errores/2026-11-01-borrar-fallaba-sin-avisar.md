# Si Borrar o Restaurar fallaban, la ficha no decía nada

**Síntoma.** Con un borrado que falla (reproducido el 1-nov-2026 con un archivo bloqueado: `DirAccess.remove_absolute` da 1), la confirmación se cerraba y la ficha seguía igual, sin decir por qué: parecía que el botón no hacía nada.

**Causa.** `Ranuras.confirmar` solo escribía el error en el registro.

**Arreglo.** Una línea `Aviso` encima de las fichas dice «No se pudo borrar la partida N.» o «No se pudo restaurar la partida N.». Se quita al abrir las ranuras o al pedir otra acción.

**Guion.** `nucleo/ranuras`, casos «si Borrar falla lo dice y la partida sigue» y «pedir otra cosa quita el aviso».
