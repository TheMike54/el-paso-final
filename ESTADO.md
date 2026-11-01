# Estado (se sobrescribe; ver `CLAUDE.md`)

## Ahora (1-nov-2026)

- PR #11 (`feature/contenido-celda`): abierto, CI en verde, sin conflictos, 0 aprobaciones: lo bloquea el ruleset. Issue
  #10: la persona de pruebas del teléfono ya reportó (lista abajo). Issue #9 (tablet): sin reporte.
- Rama `feature/nucleo-cierre-auditoria`, solo en local, sale de `9f67615`. Último commit `e4378ca` (los siete grupos de
  la auditoría). Sin commit: el bloque 56 (ataque con sonido, sonido de curar, botón de curar oculto, Eterno, aplastar).
- Sigue, en orden: (1) correr el bloque 56; (2) con el #11 en `main`, mover la rama (`git rebase --onto main 9f67615
  feature/nucleo-cierre-auditoria`), subirla y abrir el PR, con el plan pasado a `cerrados/`; (3) preparar la publicación en
  la Play Store.
- Ruleset `main`: solo por PR, 1 aprobación, `validar` en verde, Squash and merge. Un push nuevo quita la aprobación.

## Reporte de la issue #10, sin responder
Se citan y se arreglan en el PR siguiente (decisión de la persona). Falta publicar la respuesta en la issue.
- 5.1, «solo suena música en la primera sala»: La Celda es silenciosa a propósito y el tema del menú solo suena junto al
  banco de `celda_1`; el texto de la issue decía otra cosa. La persona confirma si se queda así.
- 3.3, el elevador deja encima al que aplasta: arreglado sin commit, como `Bone_16` de Silksong (plan, «Aplastar»). Probado
  en el S50 el 1-nov: pasa.
- 2.2, el disparo enemigo no se ve y sí pega: correcto, aún no tiene arte. La prueba debió pedir «Ver hitbox» encendido.
- 1.9, mancha oscura sobre el piso de la sala 4: casi seguro `pila_examenes_rota` en el primer plano, no un fallo.
- 1.4, las aspas quitan vida sin mandar a un lugar seguro: la persona decide si se queda.

## Decidido
- 27-oct: `planes/cerrados/nucleo-piezas-celda.md` y `contenido-celda-salas.md`.
- 28-oct: umbral de 0,5 ms por cuadro; tope de texturas por sala en Recursos bajo, unos 48 MB (F-061). El atlas del
  jugador lo rehace quien tiene las hojas originales (F-012). El salto largo se enseña en la sala 1 y entrar por una
  puerta, con un pizarrón con patas; lo que tiene colisión lleva arte jugable propio.
- 29-oct: D1, D2, D3, D4 y D8 aprobadas; D10 no entra. Hasta terminar el juego las partidas viejas no se conservan. Un
  solo coleccionable, con arte nuevo por definir. El parry suena (falta el archivo; `FichaSonidos.parry` ya lo toca).
  Espinas de la sala 4 a Las Raíces. Los guiones `celda_*` se reducen a uno de ruta por sala más los de `docs/errores/`.
  El color del foco va con el pulido de las páginas. `chore/android-export` se borra.
- 30-oct, tras probar en el S50: decisiones y porqués en el plan, «Tras las pruebas en el S50». Barra de Inspiración sin
  cambios; el pizarrón de curar va en Las Raíces, antes del primer enemigo, y sus salas previas llevan `botones_ocultos`.

## Pruebas manuales pendientes

- S21 con el APK del bloque 56: Menús en gis y La Celda en alto (`menus-gis-telefono`, `sala-celda-1-telefono`); Claude,
  `video-reproductor` y `recursos-memoria-android`. El S50 pasó el 1-nov (`docs/pruebas.md`).
- Con control (Ian, Vic): touchpad, íconos, tienda, estaciones, `aviso-accion-telefono`, Puerta C y cerrar menús con B.
- Claude: `medicion-rendimiento` y 4 entradas por guion. Firma: `paquete-publicacion`, `menu-desarrollo`, `recursos-medicion-publicacion`.

## Planes activos

- `nucleo-cierre-auditoria`: hecho; lo cierra el PR. `nucleo-arreglos-qa-6`: lo cierra la prueba del QA de las issues del
  #11. `nucleo-auditoria-codigo`: solo le queda el paso 13, diferido el 18-oct, con agentes pagados.

## Conocido, sin arreglar

- Dormido en el banco, el jugador animado se ve sentado en el aire. Doble `curacion_empezada` si `curar` se suelta y se pulsa entre dos ticks: leído, sin reproducir.
- En la PC, Espacio es `ui_accept` y `atacar`: cerrar un menú con Espacio también ataca.
- Guiones intermitentes: `habilidad_caida_en_picada_desde_suelo` y `sala_puerta_b_pared`.
- `prueba_sonido` con ventana falla en «un paso suena por play_stream», también en `e4378ca`; sin ventana y en el CI pasa.

## Decisiones abiertas (la persona)

- Sesión de arte: el coleccionable y su animación; nombres, costos e iconos de los amuletos y la brújula; la junta en
  y ≈ 720 de `pared_bajada_*`; un borde de `boquete_raices_b`; una máscara para `hueco_techo` y `hueco_piso`.
- 5.1 y 1.4 de la lista de arriba. Ver la cinemática de la Pluma. Generar el keystore antes de la Play Store.
