# Cinemáticas

**Para qué sirve:** reproducir un video antes de entrar a una sala.

**Antes de empezar:** leer `docs/interfaz.md`, «Componentes de menú», y `docs/contrato.md`, «Paquete de publicación». Modelo: `contenido/cinematicas/cinematica_celda.tscn` y `nucleo/cinematica.gd`.

1. Colocar en `contenido/cinematicas/` los dos archivos con el mismo nombre: `.mp4` H.264 para Android y `.ogv` Theora para PC. El preset incluye los MP4 y excluye los OGV en Android.
2. Con el editor abierto, crear una escena `Control` de pantalla completa con `nucleo/cinematica.gd`. Guardarla como `contenido/cinematicas/cinematica_<nombre>.tscn`. En el inspector poner `video` como ruta `res://` sin extensión y `sala_destino` como id de sala existente.
3. Conectar el inicio desde el lugar correspondiente: `nucleo/menu.tscn` usa `inicio_partida_nueva`; `contenido/salas/celda/celda_3.gd` muestra el cambio desde una conversación mediante `Fundido`.
4. En consola ejecutar `.\herramientas\validar.ps1` y un guion que compruebe el paso a la sala; modelo: `herramientas/guiones/contenido/cinematica_celda.guion`, con `.\herramientas\correr-guiones.ps1 -Guiones contenido/cinematica_celda`.
5. Reproducir en PC y en Android: comprobar imagen, audio y llegada. Con modo desarrollador se puede saltar; sin él se reproduce completa. Si el video no se reproduce, pasa a la sala (`nucleo/cinematica.gd`).
