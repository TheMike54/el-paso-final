ACTIVO (1-nov-2026, sale del paso 13 de `planes/cerrados/nucleo-auditoria-codigo.md`. Se ejecuta después de la primera subida a Play; no se empieza sin la orden de la persona)

# Utilidad de las pruebas

Comprobar que las pruebas atrapan fallos reales y quitar las que no. Nada de esto cambia lo que ve el jugador, por eso no
frena la publicación.

## Pasos

1. Mutaciones: en una copia del proyecto, unas 60 roturas del núcleo; se anota qué prueba atrapa cada una. Se borran las
   pruebas que no atrapan nada ni cubren lógica que pueda romperse, y se agregan las que falten. Con los créditos de la API
   hace falta el trabajo commiteado (solo ven lo commiteado); también lo puede hacer Sol en un worktree.
2. H17 a H19: partir los `_ready` largos. Medidos el 1-nov: `prueba_menu_configuracion` 447 líneas, `prueba_guardado` 259,
   `prueba_tactil` 235, `prueba_piezas_sala` 204, `prueba_icono_boton` 193.
3. Guion `doble_salto_recupera`: hoy solo el pogo detecta que `_recuperar_aire` deje de devolver el doble salto. Antes, ver
   si `habilidad_doble_salto` ya lo cubre.
4. Ver si `nucleo/sala_puerta_b_pared` es intermitente: no terminó una vez antes de `--quit-after` (18-oct) y sigue en
   «Conocido» de `ESTADO.md`, junto con `habilidad_caida_en_picada_desde_suelo`.
5. Un caso que cambie el dispositivo con el árbol pausado y compruebe que el `IconoBoton` de un menú se pone al día.
6. `MenuTienda`, `MenuEstaciones` y `CobroEstacion` liberados sin `cerrar()` quedan en `paused` y el HUD en ALWAYS. Hoy nada
   lo dispara; una salida en `_exit_tree` lo cerraría. Es código del juego: lleva su guion.
7. El borrado de `Partida.RUTA_PRUEBAS` (`user://prueba_partida.json`) en cada corrida: lo hace `_restaurar_partida` en las diez
   pruebas que llaman a `_aislar_partida()` sin ruta. Ver si hace falta en todas.

Cada fallo de una prueba durante el trabajo se anota en este plan.

## Comprobación

`validar.ps1` con `fallos=0`, `correr-guiones.ps1` con `MALOS=0` y la tabla de mutaciones en este plan.
