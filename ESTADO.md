# Estado (se sobrescribe; ver `CLAUDE.md`)

## Ahora (29-oct-2026)

- PR #11 (`feature/contenido-celda`, La Celda salas 1 a 5 y los arreglos de las auditorías del 28-oct): abierto, CI en
  verde, espera la aprobación de uno de los otros dos integrantes (issues de prueba #9 y #10, APK en la release
  `dev-2026-10-29`). Lo que encuentren se cita en su issue y se arregla en el PR de la auditoría.
- Al cerrar la auditoría sigue preparar la publicación en la Play Store.
- Rama `feature/nucleo-enemigos-base` (pasa a `feature/nucleo-cierre-auditoria`), sale de `feature/contenido-celda`
  (`9f67615`): los seis grupos de `planes/activos/nucleo-cierre-auditoria.md` en un solo PR, que se abre al
  terminar el grupo 4, con el #11 ya en `main` y la rama movida encima (comando en el plan, «Ramas y PRs»).
- Desde el 29-oct Codex (ChatGPT) también escribe código, aislado y bajo `validar.ps1` y el `revisor`: `AGENTS.md`.
- Ruleset `main`: solo por PR, 1 aprobación, `validar` en verde, Squash and merge. Un push nuevo quita la aprobación.

## Decidido

- Las decisiones del 27-oct (una vía, puertas por tipo, un solo coleccionable, parry mudo, luces, música por sala, sin
  atlas, `.tscn` como texto) están en `planes/cerrados/nucleo-piezas-celda.md` y `contenido-celda-salas.md`.
- 28-oct: umbral de 0,5 ms por cuadro; tope de texturas por sala en Recursos bajo, unos 48 MB (F-061). El atlas del
  jugador lo rehace quien tiene las hojas originales (F-012, en `docs/arte-y-rendimiento.md`).
- 28-oct, tras la prueba con jugadores nuevos: el salto largo se enseña en la sala 1 y entrar por una puerta, con un
  pizarrón con patas; lo que tiene colisión lleva arte jugable propio (regla en `docs/arte-y-rendimiento.md`, «Arte de zona»).
- 29-oct: lo que queda de la auditoría va en seis grupos (1 → 2 → 6 → 3 → 5 → 4) y un solo PR; D1, D2, D3, D4 y D8
  aprobadas; D10 no entra (la carga entre salas se queda como está). Grupo 6: el contrato en un núcleo corto y siete archivos por tema (propuesta de Sonnet aprobada).
- 29-oct: hasta terminar el juego las partidas viejas no se conservan (sin conversión de versión; cada APK de
  desarrollo nuevo se instala sin ellas). Un solo coleccionable para todo el juego, con arte nuevo por definir.
- 29-oct: el parry suena (falta elegir el archivo; `FichaSonidos.parry` ya lo toca); SALIDA 2↔3 del lado de la sala 2;
  aspas a 65 (ya en `aspas.tscn`); espinas de la sala 4 a Las Raíces; los guiones `celda_*` se reducen a uno de ruta
  por sala más los de `docs/errores/`; el color del foco va con el pulido de las páginas; `chore/android-export` se borra.
- 29-oct, grupos 5 y 4 en sesión autónoma: decisiones y lo que no se construye, con su porqué, en el plan (tablas de
  los grupos 5 y 4); la persona las revisa al probar.

## Pruebas manuales pendientes

- En el teléfono: las entradas con `"pasa": false` de cada `funciones.json`, con su fila en `docs/pruebas.md`. Lo
  visual lo confirma la persona.
- FPS en el S50 en Recursos bajo de `celda_1` (junto a la puerta se vieron 50), `celda_3` y `celda_4`: lo pide la
  regla de 60 FPS antes de marcar sus entradas `-telefono`.
- Repeticiones del QA del 25-oct (fila 7; 7.4, 1.2 y 1.3): en las issues de prueba del #11.
- Esperan firma: `paquete-publicacion` y `recursos-medicion-publicacion` (keystore).

## Planes activos

- `nucleo-cierre-auditoria` (los siete grupos hechos y revisados, un bloque de commit; faltan las pruebas en el S50 y
  pasar el plan a `cerrados/` con el PR),
  `nucleo-arreglos-qa-6` (falta la prueba del QA) y `nucleo-auditoria-codigo` (paso 13 diferido, 18-oct).

## Conocido, sin arreglar

- Dormido en el banco, el jugador animado se ve sentado en el aire.
- En el teclado de la PC, Espacio es `ui_accept` y `atacar`: cerrar un menú con Espacio también ataca.
- Guiones intermitentes por `--quit-after`, sin causa: `habilidad_caida_en_picada_desde_suelo` y `sala_puerta_b_pared`.
- Un ataque enemigo que no se puede parar no se ve sin «Ver hitbox» hasta que el enemigo tenga arte.

## Decisiones abiertas (la persona)

- Sesión de arte: el objeto del coleccionable (hoy la credencial) y su animación al recogerlo; nombres y costos de
  los amuletos; sus iconos y el de la brújula (en vector); la junta en y ≈ 720 entre `pared_bajada_*` y
  `piso_bajada_*`; un borde de `boquete_raices_b`; una máscara única para `hueco_techo` y `hueco_piso`.
- Ver la cinemática de la Pluma. Generar el keystore de publicación (la persona) antes de la Play Store.
- Tras la v1: sala de música, NPC al tocarlo.
