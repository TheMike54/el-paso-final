# Estado (se sobrescribe; ver `CLAUDE.md`)

## Ahora (22-nov-2026)

- `main` en `45e906c`: #41 a #43 y #59 fusionados; Las Raíces se recorre en caja gris de `raices_1` a la pantalla de
  cierre. Rama `fix/sprint-4-miguel`: issues de Miguel del Sprint 4 (#54 a #58 y #62), sin PR todavía. #57: calentador
  medido en S50 y S20 (`docs/arte-y-rendimiento.md`, «Mediciones») y probado por Miguel en `raices_2` (S50).
- Sprint 4 (23 al 29-nov): #44 a #58 y #60 a #62 en el tablero. Ian #44 a #47, Vic #48 a #52 y #60, Miguel (lo hace Claude) #53 a #58 y #61 a #63.
- Workflow `Release` sin corridas (`release-play`); el entorno `play` (fase B) y subir por la API esperan.
- Google Play: prueba cerrada Alpha desde el 2-nov-2026 (`versionCode` 1, `1e2c94c`); el update (#16) espera; índice: #17.

## Decidido
- Las cerradas (27-oct al 3-nov) están en `docs/manual/decisiones.md`; una nueva va aquí y al cerrarse pasa allá.
- 15-nov: los cambios de la auditoría entran a `main` con el bypass, sin PR. «va a ser con bypass, no voy a abrir un PR».
- 17-nov, #27 («y con lo del issue número 27»): Las Raíces lleva arte propio de banco. «3»; la imagen, «vamos a usar esa».
- 17-nov: la limpieza de riesgo bajo de la auditoría va en el PR del #27; la ejecuta otra sesión. «con el PR del issue número 27».
- 17-nov: poner al día el tablero; #12 queda como borrador. «y también con el tablero», «únicamente un draft».
- 21-nov 21:00, #12: README del tablero y Sprint 3 con #20, #21, #25 a #27; #28 al Sprint 2 por su fecha. «adelante, y sí abre el Sprint 3».
- 22-nov 01:39, arte del Sprint 4: cada quien sube todo su arte en un solo PR y Miguel lo integra. «todo el arte que va a generar Ian, todo el arte que va a generar Vic, lo suben en un solo issue, o sea, en un solo pull request», «ellos me van a generar el arte y yo lo integro».
- 22-nov 01:39: Miguel aprueba solo el arte de las capas de Las Raíces; el de los enemigos lo decide quien lo genera. «yo voy a revisar esta vez el arte, pero nada más de las capas».
- 22-nov 01:39: issues de música para Ian y Vic, que los aprueban ellos. «también asignales issues de música. Ese no lo voy a revisar yo, que los aprueben ellos».
- 22-nov 01:39: lo asignado a Miguel lo hace Claude. «todo lo que me asignes a mí lo vas a hacer tú».
- 22-nov, Sprint 4, «adelante, hazlo así»: las piezas jugables y peligros de Las Raíces van a Ian dentro del #44 (pasa a 13 puntos).
- 22-nov, mismo «adelante»: dormir en los bancos de `raices_3` y `raices_7` se suma al #46.
- 22-nov, mismo «adelante»: issues nuevos, las 4 pruebas en teléfono (Vic), `Release` en verde y `prueba_sonido` con ventana (Miguel); el manual, tras el #53.
- 22-nov 01:39: Sprint 4 y guías en la bóveda. «abre el sprint 4 y pásame los comandos para abrir todos los issues y de una vez dejarles todo en la bóveda privada».
- 22-nov, tanda autónoma en `fix/sprint-4-miguel` (#54, #55, #62, #56, #58, #57; sin #53 ni #61): «otra sesión va a ser la que va a ejecutar mis issues... que avance todo lo que pueda». Corre en bypassPermissions por excepción: «Sigue en bypass, arranca».
- 22-nov, #57 en la misma tanda, medido en S20 y S50 por adb: «s20 conectado, haz las pruebas q necesites», «s50 conectado tambien».
- 22-nov, issue nuevo para Miguel (#63, Sprint 4): el mapa no muestra La Celda (nadie da su mapa); la solución, después. «sí eso es, la solucion ya la vere despues d emoemnto solo asigana el issue».

## Pruebas manuales pendientes
- Hechas: `enemigo-cucaracha-telefono` (S21, 13-nov) y `enemigo-hongo-escupidor-telefono` (S20, 15-nov), video en #34 y #35.
- Falta ver el arranque sin logo en el S50 (`arranque-sin-logo`) y, en el S50, el equipo y la dirección de privacidad
  sin navegador (`creditos-privacidad`).
- S21: Menús en gis y La Celda en alto (`menus-gis-telefono`, `sala-celda-1-telefono`). Claude, con el S21
  conectado: `video-reproductor` y `recursos-memoria-android`.
- Dormir en los bancos de `raices_3` y `raices_7` (`docs/pruebas.md`, «Banco de Las Raíces»).
- Menús de pausa (plan cerrado `nucleo-menus-pausa`): flechas del marco, letra de Amuletos, cupos de la mochila, símbolos
  del Inventario y botón de vista del mapa. Las Raíces: «primera mitad», tienda, Polilla y zona oculta de `raices_4`.
- Con control (Ian, Vic): touchpad, íconos, tienda, estaciones, `aviso-accion-telefono`, Puerta C y cerrar menús con B.
- Claude: `medicion-rendimiento`. `mutar-local` sigue en false: su comprobación nombra `nucleo/sala_equipo`, que no cubre
  `entregar()` (con `nucleo/estado_sala` da MATADA); cambiar el texto lo decide Miguel (#58). Firma: `paquete-publicacion`, `menu-desarrollo`, `recursos-medicion-publicacion`.

## Planes activos
- `herramientas-publicar-play`: falta la corrida verde de `Release` y la fase B. `herramientas-utilidad-pruebas`: el paso
  13 de la auditoría del 17-oct.

## Siguiente
- Medición de base (auditoría de nov-2026, pendiente 11): preguntas de si el APK ya está instalado. Meta: 0. Al 15-nov:
  2 instalaciones con `instalar-apk.ps1` (S21 el 13-nov, S20 el 15-nov), cada una con su línea `INSTALADO`, y 0 preguntas.

## Conocido, sin arreglar

- Guiones intermitentes: `habilidad_caida_en_picada_desde_suelo` y `sala_puerta_b_pared` (#56, atorado). 22-nov: 20 de 20
  solos, 20 de 20 con la CPU cargada y 241 de 241 en la batería; sin causa. Si fallan, el log queda en `.godot/guiones-fallidos/`.

## Decisiones abiertas (la persona)

- Ninguna. La del #21 (repisa en lugar de cuarto) se cerró al fusionar el #42: `docs/manual/decisiones.md`.
