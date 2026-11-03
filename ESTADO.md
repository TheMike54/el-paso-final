# Estado (se sobrescribe; ver `CLAUDE.md`)

## Ahora (2-nov-2026)

- Rama `feature/nucleo-cierre-auditoria`, solo en local, sale de `9f67615`. Último commit con la auditoría final de
  documentación (`planes/activos/herramientas-auditoria-arranque.md`): 209 de 209 guiones, `fallos=0`, `rotos=0`.
- PR #11 (`feature/contenido-celda`): abierto y aprobado sobre `9f67615`; el push de esta rama le quita la aprobación. Issue
  #10: ya reportó, falta responder (lista abajo). Issue #9 (tablet): sin reporte.
- Auditoría final (`planes/activos/nucleo-auditoria-final.md`): reporte aprobado y pasos 7 y 9 hechos (todos los hallazgos); ver «Avance» del plan.
- Sigue, en orden: (1) subir todo a la rama del #11 (avance rápido), ponerle `Closes #13`, quitarle `Closes #9`, conseguir de nuevo la aprobación y fusionar; (2) AAB firmado y
  prueba cerrada en Play. La cuenta de Play espera la revisión de identidad de Google.
- Ruleset `main`: solo por PR, 1 aprobación, `validar` en verde, Squash and merge. Un push nuevo quita la aprobación.

## Reporte de la issue #10, sin responder
Se citan y se arreglan en el PR siguiente (decisión de la persona). Falta publicar la respuesta en la issue.
- 5.1, «solo suena música en la primera sala»: La Celda es silenciosa a propósito. Se queda así (1-nov).
- 3.3, el elevador deja encima al que aplasta: arreglado en el bloque 56, como `Bone_16` de Silksong. Pasa en el S50 (1-nov).
- 2.2, el disparo enemigo no se ve y sí pega: correcto, aún no tiene arte. La prueba debió pedir «Ver hitbox» encendido.
- 1.9, mancha oscura sobre el piso de la sala 4: casi seguro `pila_examenes_rota` en el primer plano, no un fallo.
- 1.4, las aspas quitan vida sin mandar a un lugar seguro: empujan y no devuelven. Se queda así (1-nov).

## Decidido
- 27-oct: `planes/cerrados/nucleo-piezas-celda.md` y `contenido-celda-salas.md`.
- 28-oct: umbral de 0,5 ms por cuadro; tope de texturas por sala en Recursos bajo, unos 48 MB (F-061). El atlas del
  jugador lo rehace quien tiene las hojas originales (F-012). El salto largo se enseña en la sala 1 y entrar por una
  puerta, con un pizarrón con patas; lo que tiene colisión lleva arte jugable propio.
- 29-oct: D1, D2, D3, D4 y D8 aprobadas; D10 no entra. Hasta terminar el juego las partidas viejas no se conservan. El
  coleccionable es Azulito, a unos 64 px; su animación sigue pendiente. El parry suena (falta el archivo;
  `FichaSonidos.parry` ya lo toca). Espinas de la sala 4 a Las Raíces. Los guiones `celda_*` se reducen a uno de ruta por
  sala más los de `docs/errores/`. El color del foco va con el pulido de las páginas. `chore/android-export` se borra.
- 30-oct, tras probar en el S50: decisiones y porqués en `planes/activos/nucleo-cierre-auditoria.md`, «Tras las pruebas en el S50». Barra de Inspiración sin
  cambios; el pizarrón de curar va en Las Raíces, antes del primer enemigo, y sus salas previas llevan `botones_ocultos`.
- 1-nov: decisiones de la persona en `planes/activos/nucleo-auditoria-final.md`. Patas de Cucaracha cuesta 1 y da 1,25.
- 1-nov, menús: 5 útiles con 4 cupos, solo poner o quitar; Gato de la Suerte pasa de amuleto a útil. Plan: `nucleo-menus-pausa`, por aprobar. El arte de 7 amuletos va en el tablero (Caché no se pinta). 2-nov: el diseño del juego será público, con el manual en `docs/manual/`. Antes del manual: guías completas de todo lo construido, con el método que funcionó, cinemáticas incluidas.
- 2-nov, Las Raíces: 2 amuletos, Patas (`raices_4`) y Caparazón (oculto de `raices_6`, junto a un coleccionable; costo 2 y valor 30 para probar; su ficha entra con #25); Caché fuera de la v1; Suela, Log y Cartera no se consiguen en la v1 y se definen después de publicar; la tienda de `raices_3` vende la brújula. Espinas turquesa, firme. Sin banco donde está el Eterno en La Celda: el único está en `celda_1`.

## Pruebas manuales pendientes

- Las pruebas del APK de cierre de la auditoría pasaron en el S50 (1-nov). Falta ver el arranque (`arranque-sin-logo`).
- S21, sin disponer por ahora: Menús en gis y La Celda en alto (`menus-gis-telefono`, `sala-celda-1-telefono`). Claude,
  con el S21 conectado: `video-reproductor` y `recursos-memoria-android`.
- Con control (Ian, Vic): touchpad, íconos, tienda, estaciones, `aviso-accion-telefono`, Puerta C y cerrar menús con B.
- Claude: `medicion-rendimiento` y 4 entradas por guion. Firma: `paquete-publicacion`, `menu-desarrollo`, `recursos-medicion-publicacion`.

## Planes activos

- `nucleo-auditoria-final`: el plan en curso. `nucleo-cierre-auditoria`: hecho; lo cierra el PR. `nucleo-arreglos-qa-6`: lo
  cierra la prueba del QA de las issues del #11. `herramientas-utilidad-pruebas`: el paso 13 de la auditoría del 17-oct, después de Play. `nucleo-menus-pausa`: por aprobar. `herramientas-auditoria-arranque`: hecho; lo cierra el PR.

## Conocido, sin arreglar

- Dormido en el banco, el jugador animado se ve sentado en el aire. Doble `curacion_empezada` si `curar` se suelta y se pulsa entre dos ticks: leído, sin reproducir.
- En la PC, Espacio es `ui_accept` y `atacar`: cerrar un menú con Espacio también ataca.
- Guiones intermitentes: `habilidad_caida_en_picada_desde_suelo` y `sala_puerta_b_pared`.
- `prueba_sonido` con ventana falla en «un paso suena por play_stream», también en `e4378ca`; sin ventana y en el CI pasa.

## Decisiones abiertas (la persona)

- Lo pendiente de `nucleo-menus-pausa`, en el plan. Arranque sin logo: unos 12 s en negro en el S50 antes del menú; máscara en el arranque decidida el 2-nov-2026, sin construir. Sesión de arte: animación del coleccionable;
  la junta de `pared_bajada_*`; un borde de `boquete_raices_b`; máscara de `hueco_techo` y `hueco_piso`. Ver la cinemática de la Pluma.
