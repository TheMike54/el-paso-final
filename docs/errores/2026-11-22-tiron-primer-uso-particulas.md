# Tirón la primera vez que se dibujan partículas (#57)

**Síntoma.** Con el APK recién instalado, el juego daba un tirón la primera vez que aparecía un efecto: en el S21 los
FPS cayeron a 13-35 en los primeros minutos con la Cucaracha (13-nov-2026) y después no volvió a pasar.

**Causa.** El renderer Compatibility compila cada variante de shader la primera vez que se dibuja y la guarda en la
caché de disco (`classes/class_projectsettings.rst:13577`). Las partículas (`CPUParticles2D`) usan dos variantes:
sin material y sin luz (`nucleo/arte/sin_luz.tres` y `aditivo.tres` comparten la misma, los dos con `light_mode` sin
luz). Medido con `herramientas/pruebas/medicion_primer_uso.tscn` y la caché vacía: en el S50, 190 y 145 ms el primer
cuadro con escombros y 264 y 252 ms el primero con el polvo de la Cucaracha; la segunda vez, 18-21 ms. En el S20,
39 y 55-58 ms.

**Arreglo.** `nucleo/calentador_shaders.gd`: el menú lo pone como primer hijo, bajo su `Fondo` opaco, y dibuja al
menos dos cuadros una partícula de cada variante. La compilación pasa en el menú (342-371 ms una vez en el S50, sin
nada que se mueva en pantalla) y queda en la caché. En la escena de medición, con el calentador puesto antes, el
primer uso de cada efecto no pasó de 25,3 ms en el S50 ni de 21,6 en el S20.

**Qué lo cubre.** La medición A/B de `docs/pruebas.md`, «Medición del primer uso» (entrada `calentar-shaders-particulas`
de `nucleo/funciones.json`). No hay guion: el tirón solo se ve en el teléfono con la caché vacía. En el juego real, la
prueba manual `calentar-shaders-raices-telefono` (22-nov-2026, S50 con la caché vacía): partida nueva de La Celda a
`raices_2` y pelea con las Cucarachas, sin tirón visible; esa vuelta se juzgó a ojo, sin medir cuadros. Los destellos
no se calientan: el del jugador lleva su material desde que la sala carga.
