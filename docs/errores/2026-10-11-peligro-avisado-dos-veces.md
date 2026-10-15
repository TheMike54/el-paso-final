# Un peligro avisaba dos veces y rompía el anti-bucle

**Síntoma** (guiones, 11-oct-2026, al programar el anti-bucle): `jugador_peligro` dejaba al jugador en la `Entrada`
(x=200) en lugar de en el suelo firme (x=752), y `boton_poderes_peligro` terminaba con una vida de menos y un toque
del botón de poderes que no debía contar. La prueba que llama a `recibir_dano` directamente pasaba.

**Causa**: `nucleo/dano_contacto.gd` revisa en cada tick `get_overlapping_bodies()`, que es la lista del tick de
física anterior. Cuando un peligro teletransporta al jugador, en el tick siguiente el pincho todavía lo ve dentro y
vuelve a llamar a `recibir_dano`. Antes era inofensivo, porque el jugador ya era invulnerable y el segundo aviso solo
lo devolvía otra vez al mismo punto. Con las reglas nuevas, el segundo aviso caía dentro del anti-bucle (lo llevaba a
la llegada) o, tras el anti-bucle, le quitaba otra vida.

**Arreglo**: `nucleo/jugador.gd`: mientras el jugador está quieto tras reaparecer por un peligro
(`_reapareciendo`, los `ticks_reaparicion_peligro` ticks), ningún peligro cuenta. El contador del anti-bucle empieza
a correr cuando el jugador recupera el control.

**Guiones que lo cubren**: `herramientas/guiones/nucleo/jugador_peligro_anti_bucle_contacto.guion` (contacto real
en la sala del pogo: sin el arreglo, 2 vidas perdidas y 2 avisos de daño en lugar de 1), además de
`jugador_peligro.guion` y `boton_poderes_peligro.guion`, que vuelven a pasar sin cambiar los valores de su
`.esperado` (en el segundo solo cambió el comentario).
