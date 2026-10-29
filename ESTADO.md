# Estado (se sobrescribe; ver `CLAUDE.md`)

## Ahora (29-oct-2026)

- Rama `feature/contenido-celda`: el PR se abre con este último commit. Un solo PR (decisión de la persona, 27-oct)
  con las salas 1 a 5 de La Celda, sus piezas del núcleo, los ajustes avanzados, el video por hardware, los efectos
  del jugador y los arreglos de las dos auditorías del 28-oct (planes cerrados en `planes/cerrados/`).
- La prueba del PR la hacen los otros dos integrantes, una issue de prueba cada uno (como en el #6), con el APK de una
  release de desarrollo; el PR las cierra.
- Ruleset `main`: solo por PR, 1 aprobación, `validar` en verde, Squash and merge. Un push nuevo quita la aprobación.

## Decidido

- Las decisiones del 27-oct (una vía, puertas por tipo, un solo coleccionable, parry mudo, luces, música por sala, sin
  atlas, `.tscn` como texto) están en `planes/cerrados/nucleo-piezas-celda.md` y `contenido-celda-salas.md`.
- 28-oct: umbral de 0,5 ms por cuadro; tope de texturas por sala en Recursos bajo, unos 48 MB (F-061). El atlas del
  jugador lo rehace quien tiene las hojas originales (F-012, en `docs/contrato.md`).
- 28-oct, tras la prueba con jugadores nuevos: el salto largo se enseña en la sala 1 y entrar por una puerta, con un
  pizarrón con patas; lo que tiene colisión lleva arte jugable propio (regla en `docs/contrato.md`, «Arte de zona»).
- Lo que sigue de la auditoría de código (fase 3: F-098 carga de sala, enemigos, arquitectura) va en PRs siguientes:
  `planes/activos/nucleo-base-auditoria-codigo.md`.

## Pruebas manuales pendientes

- En el teléfono: las entradas con `"pasa": false` de cada `funciones.json`, con su fila en `docs/pruebas.md`. Lo
  visual lo confirma la persona.
- FPS en el S50 en Recursos bajo de `celda_1` (junto a la puerta se vieron 50), `celda_3` y `celda_4`: lo pide la
  regla de 60 FPS antes de marcar sus entradas `-telefono`.
- Repeticiones del QA del 25-oct (fila 7; 7.4, 1.2 y 1.3): en las issues de prueba de este PR.
- Esperan firma: `paquete-publicacion` y `recursos-medicion-publicacion` (keystore).

## Planes activos

- `nucleo-base-auditoria-codigo` (fase 3 y siguientes), `nucleo-arreglos-qa-6` (falta la prueba del QA) y
  `nucleo-auditoria-codigo` (paso 13 diferido, 18-oct).

## Conocido, sin arreglar

- Dormido en el banco, el jugador animado se ve sentado en el aire.
- En el teclado de la PC, Espacio es `ui_accept` y `atacar`: cerrar un menú con Espacio también ataca.
- Guiones intermitentes por `--quit-after`, sin causa: `habilidad_caida_en_picada_desde_suelo` y `sala_puerta_b_pared`.
- Un ataque enemigo que no se puede parar no se ve sin «Ver hitbox» hasta que el enemigo tenga arte.

## Decisiones abiertas (la persona)

- Qué coleccionable es el del nicho (hoy la credencial, id `coleccionable_nicho`) y el id `coleccionable_pasillo`:
  fijos desde el primer APK compartido. Ver la cinemática de la Pluma.
- Si el parry suena. Qué lado de la puerta 2↔3 lleva SALIDA (hoy el de la sala 2). Radio de daño de las aspas (55).
- Las espinas de la sala 4: sin arte ni uso claro; se retoman con Las Raíces o un rediseño del tiro.
- Sesión de arte: una pieza que tape la junta en y ≈ 720 entre `pared_bajada_*` y `piso_bajada_*`; un borde de
  `boquete_raices_b` sobre el azulejo viejo de `celda_4`; una máscara única para las bocas de `hueco_techo` y
  `hueco_piso`.
- Si entra en la sala 2 un hueco que solo se cruce con impulso. Si los guiones `celda_*` de regla de la sala se
  quedan todos o se reducen a uno de ruta por sala más los que tienen archivo en `docs/errores/`.
- Cita de la skill `rendimiento-gama-baja` (`SKILL.md:39`): citar `docs/contrato.md`, «Recursos», en vez de
  `renderers.rst:184`.
- Borrar `chore/android-export`. Sin decidir: keystore, color del foco. Tras la v1 base: sala de música, NPC al
  tocarlo.
