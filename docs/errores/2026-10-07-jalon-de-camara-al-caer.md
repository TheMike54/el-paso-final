# La cámara jalaba al jugador justo antes de tocar el suelo

- **Síntoma**: en el teléfono, en la sala de caída, el cubo se sentía «jalado», «como un imán», justo antes de
  tocar el suelo en caída libre. En los saltos normales no pasaba.
- **Causa**: la cámara sigue al jugador con suavizado y, a 1200 px/s, va entre 150 y 230 px por detrás. En la sala
  de caída el suelo estaba a 40 px del límite inferior: medido sin ventana con la pantalla del S20 (1600×720), la
  cámara se frenaba de golpe en su límite (centro en y=840) en el tick 112 y el cubo seguía cayendo unos 100 px más:
  según el medidor del guion, su velocidad en pantalla subía 776 px/s de un tick al siguiente. En una sala de 720 de alto la
  cámara no se mueve en vertical y no pasa.
- **Arreglo**: primero, 280 px bajo el suelo (quitó el jalón en el S20, pero dejaba demasiado suelo a la vista).
  Después, como en Hollow Knight: el jugador mueve la cámara a mano, recorta su objetivo a los límites antes de
  suavizar y en vertical usa un suavizado de segundo orden (`tiempo_camara_y`, 0,15 s), cuya velocidad no cambia de
  golpe; con eso basta el margen de siempre (40 px). Recortar antes con el suavizado de primer orden de `Camera2D`
  (`limit_smoothed`) no alcanza: unos 140 px/s por tick. Después, 120 px bajo el suelo de las salas de caída larga,
  por el suelo visible: el margen casi no cambia el jalón (93,1 px/s por tick con 120 px) y baja el atraso máximo de
  la cámara al caer de 262 a 209 px.
- **Guion que lo cubre**: `herramientas/guiones/nucleo/camara_caida.guion`, con el medidor
  `herramientas/salas/medidor_camara.gd` y 120 px bajo el suelo: sube 93,1 px/s por tick (umbral 100). Sin recortar el
  objetivo antes del suavizado falla con 874.
