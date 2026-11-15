# Estado (se sobrescribe; ver `CLAUDE.md`)

## Ahora (15-nov-2026)

- `main` en `c52c165`, CI en verde. Desde el 3-nov entraron #31 (base de Las Raíces y `raices_1`), #32 (íconos de
  amuletos), #33 (preguntas de la mochila), #34 (Cucaracha) y #35 (Hongo escupidor y `raices_5`).
- Auditoría de nov-2026: sus cambios van directo a `main`, en 4 commits con el bypass del administrador y sin PR.
- Siguen: Vic, #26 (`raices_7`, impulso y pantalla de cierre) y después #25; Ian, #20 (`raices_2` a `raices_4`) y #21.
- Workflow `Release`: sin ninguna corrida todavía (`release-play`). El entorno `play` y su cuenta de servicio son la
  fase B. Sin subir por la API mientras haya una revisión abierta.
- Google Play: prueba cerrada Alpha desde el 2-nov-2026 (`versionCode` 1, `0.1.0`, `1e2c94c`), solo México; 3 de 12
  testers al 3-nov. La actualización (#16) lleva `versionCode` 2 o más; el índice de la segunda entrega es #17.
- Issue #9 cerrada el 15-nov: LB/RB en la zona de pruebas pasa en la tableta de Vic con control Xbox.
- Ruleset `main`: PR, 1 aprobación, `validar` en verde, Squash and merge; el administrador del repo puede saltárselo.

## Decidido
- Las decisiones cerradas (27-oct al 3-nov) están en `docs/manual/decisiones.md`. Una nueva va al plan activo o aquí;
  al cerrarse pasa a `decisiones.md`.
- `nucleo-menus-pausa` queda aprobado y se construye después del 9-nov (ver «Planes activos»).
- 12-nov, Cucaracha: el punto de salida se lee al aparecer el polvo, no al enterrarse. «hay q hacerlo como dices, por
  q sino seria muy facil».
- 13-nov, Cucaracha: quieto sobre ella mientras se recupera, el contacto sigue dañando cada vez que acaba la
  invulnerabilidad (sin límite por salida). «asi se queda megusto».
- 15-nov: los cambios de la auditoría entran a `main` con el bypass, sin PR. «va a ser con bypass, no voy a abrir un PR».

## Pruebas manuales pendientes

- Hechas: `enemigo-cucaracha-telefono` (S21, 13-nov) y `enemigo-hongo-escupidor-telefono` (S20 como control táctil con
  la imagen en la PC, 15-nov), con video en #34 y #35.
- Falta ver el arranque sin logo en el S50 (`arranque-sin-logo`) y, en el S50, el equipo y la dirección de privacidad
  sin navegador (`creditos-privacidad`).
- S21: Menús en gis y La Celda en alto (`menus-gis-telefono`, `sala-celda-1-telefono`). Claude, con el S21
  conectado: `video-reproductor` y `recursos-memoria-android`.
- Con control (Ian, Vic): touchpad, íconos, tienda, estaciones, `aviso-accion-telefono`, Puerta C y cerrar menús con B.
- Claude: `medicion-rendimiento` y 4 entradas por guion. Firma: `paquete-publicacion`, `menu-desarrollo`, `recursos-medicion-publicacion`.

## Planes activos

- `herramientas-publicar-play`: falta la corrida verde de `Release` y la fase B. `nucleo-menus-pausa`: aprobado, después
  del 9-nov. `herramientas-utilidad-pruebas`: el paso 13 de la auditoría del 17-oct, después del 9-nov.

## Siguiente

- Medición de base (auditoría de nov-2026, pendiente 11): preguntas de si el APK ya está instalado. Meta: 0. Al 15-nov:
  2 instalaciones con `instalar-apk.ps1` (S21 el 13-nov, S20 el 15-nov), cada una con su línea `INSTALADO`, y 0 preguntas.

## Conocido, sin arreglar

- Tirón la primera vez: en el S21, recién instalado (13-nov), los FPS cayeron a 13-35 durante los primeros minutos con la
  Cucaracha; después, 40 s con la Cucaracha saliendo dieron 120 FPS sin un cuadro de más de 9,5 ms. Probable compilación
  de shaders al primer uso (polvo, destellos): sin medir en el S50.
- Dormido en el banco, el jugador animado se ve sentado en el aire. Doble `curacion_empezada` si `curar` se suelta y se pulsa entre dos ticks: leído, sin reproducir.
- En la PC, Espacio es `ui_accept` y `atacar`: cerrar un menú con Espacio también ataca.
- Guiones intermitentes: `habilidad_caida_en_picada_desde_suelo` y `sala_puerta_b_pared`.
- `prueba_sonido` con ventana falla en «un paso suena por play_stream», también en `e4378ca`; sin ventana y en el CI pasa.

## Decisiones abiertas (la persona)

- Ninguna.
