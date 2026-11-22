# Estado (se sobrescribe; ver `CLAUDE.md`)

## Ahora (21-nov-2026)

- `main` en `36ed07d`: entró #41 (`raices_2` a `raices_4`, Polilla, El Eterno en `raices_3`, tienda), con los arreglos de
  la revisión hechos sobre la rama de Ian. Las Raíces se recorre jugando de `raices_1` a la pantalla de cierre.
- Rama `feature/contenido-raices-cuarto-oculto` (PR #42, #21): `main` mezclado, arreglos de la revisión y la auditoría
  del 21-nov (plan `contenido-auditoria-21-nov`), sin commit.
- Workflow `Release` sin corridas (`release-play`); el entorno `play` (fase B) y subir por la API esperan.
- Google Play: prueba cerrada Alpha desde el 2-nov-2026 (`versionCode` 1, `1e2c94c`); el update (#16) espera; índice: #17.
- Tablero (#12) completo el 21-nov: README con Sprints 1 a 3 (meta, fechas, tareas y resultado); falta cerrar el issue.

## Decidido
- Las decisiones cerradas (27-oct al 3-nov) están en `docs/manual/decisiones.md`. Una nueva va al plan activo o aquí;
  al cerrarse pasa a `decisiones.md`.
- 12-nov, Cucaracha: el punto de salida se lee al aparecer el polvo, no al enterrarse. «hay q hacerlo como dices, por
  q sino seria muy facil».
- 13-nov, Cucaracha: quieto sobre ella mientras se recupera, el contacto sigue dañando cada vez que acaba la
  invulnerabilidad (sin límite por salida). «asi se queda megusto».
- 15-nov: los cambios de la auditoría entran a `main` con el bypass, sin PR. «va a ser con bypass, no voy a abrir un PR».
- 17-nov, #27 («y con lo del issue número 27»): Las Raíces lleva arte propio de banco. «3»; la imagen, «vamos a usar esa».
- 17-nov: la limpieza de riesgo bajo de la auditoría va en el PR del #27; la ejecuta otra sesión. «con el PR del issue número 27».
- 17-nov: poner al día el tablero; #12 queda como borrador. «y también con el tablero», «únicamente un draft».
- 21-nov 21:00, #12: README del tablero y Sprint 3 con #20, #21, #25 a #27; #28 al Sprint 2 por su fecha. «adelante, y sí abre el Sprint 3».
- 21-nov 21:00, #42: los arreglos de su revisión los hace el dueño del repo sobre la rama de Ian, tras mezclar `main`.
  «ya quedo merge el pr revisa para q comienzes con las correciones del otro pr».

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
- Claude: `medicion-rendimiento` y 4 entradas por guion. Firma: `paquete-publicacion`, `menu-desarrollo`, `recursos-medicion-publicacion`.

## Planes activos
- `herramientas-publicar-play`: falta la corrida verde de `Release` y la fase B. `herramientas-utilidad-pruebas`: el paso
  13 de la auditoría del 17-oct. `contenido-auditoria-21-nov`: hecho y revisado; falta el commit y cerrarlo.

## Siguiente
- Medición de base (auditoría de nov-2026, pendiente 11): preguntas de si el APK ya está instalado. Meta: 0. Al 15-nov:
  2 instalaciones con `instalar-apk.ps1` (S21 el 13-nov, S20 el 15-nov), cada una con su línea `INSTALADO`, y 0 preguntas.

## Conocido, sin arreglar

- Tirón la primera vez: en el S21, recién instalado (13-nov), los FPS cayeron a 13-35 durante los primeros minutos con la
  Cucaracha; después, 40 s con la Cucaracha saliendo dieron 120 FPS sin un cuadro de más de 9,5 ms. Probable compilación
  de shaders al primer uso (polvo, destellos): sin medir en el S50.
- Doble `curacion_empezada` si `curar` se suelta y se pulsa entre dos ticks: leído, sin reproducir.
- En la PC, Espacio es `ui_accept` y `atacar`: cerrar un menú con Espacio también ataca.
- Guiones intermitentes: `habilidad_caida_en_picada_desde_suelo` y `sala_puerta_b_pared`.
- `prueba_sonido` con ventana falla en «un paso suena por play_stream», también en `e4378ca`; sin ventana y en el CI pasa.

## Decisiones abiertas (la persona)

- #21 pide un cuarto tras un muro rompible; el PR #42 hace una repisa tras un techo rompible, como `raices_6`. «lo tengo q revisar».
