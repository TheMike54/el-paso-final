# Avisos y pizarrones

**Para qué sirve:** enseñar acciones y sus botones dentro de una sala.

**Antes de empezar:** leer `docs/componentes.md`, fila `AvisoAccion`; modelo: `herramientas/salas/sala_pizarrones.tscn` y `contenido/salas/celda/celda_1.tscn`.

1. En el editor, o escribiendo el `.tscn` según `docs/sala.md`, agregar un `Area2D` con `nucleo/aviso_accion.gd` a la sala. Ajustar `tamano` y `punto` en el inspector; el área se apoya en el suelo.
2. En `acciones` poner una o dos acciones existentes del InputMap. Ajustar `texto` y `nota` si hacen falta; `pizarron = false` quita la caja gris para un aviso sobre un objeto.
3. Elegir `modo`: `UNA_VEZ` recuerda la acción en la partida y requiere `id` único en la sala; `POR_VISITA` vuelve en cada visita y no lleva id; `SIEMPRE` aparece al entrar en la zona, con id opcional para recordar si el botón ya dejó de latir. Evitar prefijos reservados (`docs/componentes.md`).
4. En consola correr `.\herramientas\validar.ps1`. En el juego comprobar aparición, acción, salida y regreso; verificar el botón táctil y el de control en la sala Pizarrones (`docs/salas-de-prueba.md`).
