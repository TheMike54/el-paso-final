# Estado (se sobrescribe; ver `CLAUDE.md`)

## Ahora (3-nov-2026)

- `main` en `f49a295` (PR #30): workflow `Release` manual a Play y CI endurecido (`planes/activos/herramientas-publicar-play.md`).
  Entorno `firma` con sus 3 secrets, listo. Falta una corrida de `Release` con `subir` apagado (`release-play`). El
  entorno `play` y su cuenta de servicio son la fase B, después del 9-nov. Sin subir por la API mientras haya una
  revisión abierta.
- Rama `docs/ci-checks-guides`: guías con los pasos nuevos del CI, decisiones del 3-nov y planes al día; PR por abrir.
- `creditos-privacidad`: falta confirmar en el S50 que se ven el equipo y la dirección sin navegador. Issue #9: sin
  reporte, sigue abierta; ahí queda la prueba LB/RB de Vic.
- Google Play: prueba cerrada Alpha publicada el 2-nov-2026 a las 22:59 (`versionCode` 1, `0.1.0`, desde `1e2c94c`),
  solo México. Testers: 3 de 12; los 14 días para pedir producción cuentan desde que haya 12 inscritos. La segunda
  entrega (9-nov) es una actualización: `versionCode` 2 o más.
- Ruleset `main`: PR, 1 aprobación, `validar` en verde, Squash and merge; el administrador del repo puede saltárselo.

## Decidido
- 27-oct: `planes/cerrados/nucleo-piezas-celda.md` y `contenido-celda-salas.md`.
- 28-oct: umbral de 0,5 ms por cuadro; tope de texturas por sala en Recursos bajo, unos 48 MB (F-061). El atlas del
  jugador lo rehace quien tiene las hojas originales (F-012). El salto largo se enseña en la sala 1 y entrar por una
  puerta, con un pizarrón con patas; lo que tiene colisión lleva arte jugable propio.
- 29-oct: D1, D2, D3, D4 y D8 aprobadas; D10 no entra. Hasta terminar el juego las partidas viejas no se conservan. El
  coleccionable es Azulito, a unos 64 px. El parry suena (falta el archivo; `FichaSonidos.parry` ya lo toca). Espinas
  de la sala 4 a Las Raíces. Los guiones `celda_*` se reducen a uno de ruta por sala más los de `docs/errores/`. El
  color del foco va con el pulido de las páginas.
- 30-oct, tras probar en el S50: `planes/cerrados/nucleo-cierre-auditoria.md`, «Tras las pruebas en el S50». Barra de
  Inspiración sin cambios; el pizarrón de curar va en Las Raíces, antes del primer enemigo.
- 1-nov: `planes/cerrados/nucleo-auditoria-final.md`. Patas de Cucaracha cuesta 1 y da 1,25. Menús: 5 útiles con 4
  cupos, solo poner o quitar; Gato de la Suerte pasa de amuleto a útil.
- 2-nov, Las Raíces y Play: decisiones en `docs/manual/decisiones.md`, «Del juego». La política y su botón fueron
  directo a `main` por decisión de la persona; Créditos nombra al equipo por sus usuarios de GitHub.
- 3-nov: sin decisiones abiertas. Línea del Eterno escrita (`docs/manual/decisiones.md`). Sin máscara en el arranque y
  sin sesión de arte: se quitan del pendiente. Las piezas jugables y los peligros no llevan un color fijo. El plan
  `nucleo-menus-pausa` queda aprobado y se construye después del 9-nov. `nucleo-arreglos-qa-6` se cierra.

## Pruebas manuales pendientes

- Falta ver el arranque sin logo en el S50 (`arranque-sin-logo`).
- S21, sin disponer por ahora: Menús en gis y La Celda en alto (`menus-gis-telefono`, `sala-celda-1-telefono`). Claude,
  con el S21 conectado: `video-reproductor` y `recursos-memoria-android`.
- Con control (Ian, Vic): touchpad, íconos, tienda, estaciones, `aviso-accion-telefono`, Puerta C y cerrar menús con B.
- Claude: `medicion-rendimiento` y 4 entradas por guion. Firma: `paquete-publicacion`, `menu-desarrollo`, `recursos-medicion-publicacion`.

## Planes activos

- `herramientas-publicar-play`: falta la corrida verde de `Release` y la fase B. `nucleo-menus-pausa`: aprobado, después
  del 9-nov. `herramientas-utilidad-pruebas`: el paso 13 de la auditoría del 17-oct, después del 9-nov.

## Conocido, sin arreglar

- Dormido en el banco, el jugador animado se ve sentado en el aire. Doble `curacion_empezada` si `curar` se suelta y se pulsa entre dos ticks: leído, sin reproducir.
- En la PC, Espacio es `ui_accept` y `atacar`: cerrar un menú con Espacio también ataca.
- Guiones intermitentes: `habilidad_caida_en_picada_desde_suelo` y `sala_puerta_b_pared`.
- `prueba_sonido` con ventana falla en «un paso suena por play_stream», también en `e4378ca`; sin ventana y en el CI pasa.
- En el S50 el arranque pasa unos 12 s en negro antes del menú.

## Decisiones abiertas (la persona)

- Ninguna.
