# Estado (se sobrescribe; ver `CLAUDE.md`)

## Ahora (21-oct-2026)

- Rama `feature/nucleo-enemigos-moviles`, **PR #6** abierto el 21-oct con `qa-pending` y `validar` en verde. Lleva
  `b31c08e` (nunca subido; decidido que va aquí), las tandas del 13 al 17-oct, la auditoría y el cuerpo animado.
  - QA en dos issues con el APK `dev-2026-10-21`: #7 (tableta con control Xbox) y #8 (teléfono con DUALSHOCK 4).
    Cada uno aprueba el #6 cuando su issue pasa; un fallo se arregla en esta rama con un APK nuevo.
  - Al fusionar (Squash and merge): #7 y #8 se cierran solos; se cierran los cuatro planes de abajo, con su
    resultado en `docs/pruebas.md`, y se borra la rama local `feature/nucleo-mando-menus` (ya va en el #6).
- `chore/android-export` (presets de 32 y 64 bits, con «Desarrollo»): falta su rebase y su propio PR a `main`.
  Hasta entonces, `export_presets.cfg` de esta rama solo tiene «Publicacion» (H23 de la auditoría).
- Ruleset `main` (12-oct): solo por PR, 1 aprobación, `validar` en verde, Squash and merge, sin force push ni borrado.
- Al 21-oct: `validar.ps1` → `OK  VALIDACION archivos=267 fallos=0`; `correr-guiones.ps1` → `RESUMEN total=157
  OK=157 MALOS=0`; trazador del jugador → `TRAZA IDENTICA n=36`; `animacion_jugador` 48 casos, 0 fallos.

## Pruebas manuales pendientes

- **#7 y #8:** la lista de cada uno está en su issue.
- **S50, la persona** (APK `dev-2026-10-21` instalado): el cuerpo animado, caso «Cuerpo animado del jugador» de
  `docs/pruebas.md` (va sin mipmaps, decidido el 21-oct: que los bordes no parpadeen al moverse la cámara). También
  cerrar con A sin saltar, con un control, y el mapa (+ / – y el texto vacío).
- **Rendimiento en el S20:** no se midió; el S50 se midió el 18 y el 21-oct.
- **Esperan hardware o firma:** `menu-desarrollo`, `paquete-publicacion` y `recursos-medicion-publicacion`
  (keystore). `sonidos-telefono` falla hasta que el golpe recibido tenga su propio sonido.

## Planes activos

- `nucleo-animacion-jugador`: primera vuelta hecha y revisada (`"pasa": true`); falta la prueba manual (#8 y S50).
- `nucleo-aviso-accion`: falta H10, la sala Pizarrones con el dedo (#8).
- `nucleo-menus-gis`: falta H6, la prueba en los teléfonos (#7).
- `nucleo-tienda-gis`: hechos H1 a H4. Falta H5, la tienda y las estaciones con el dedo (#7).
- `nucleo-auditoria-codigo`: el índice de la auditoría; se cierra con el paso 13.

## Auditoría del código: paso 13 diferido

- Pasos 1 a 12 cerrados; las 11 decisiones abiertas se cerraron el 20-oct (sección «Decidido por la persona el
  20-oct» del plan).
- Paso 13 diferido por decisión de la persona del 18-oct: auditoría de pruebas con mutaciones, en otra tanda y con el
  trabajo ya commiteado. Incluye partir los `_ready` largos de las pruebas (H17-H19).

## Conocido, sin arreglar

- Dormido en el banco, el jugador animado se ve sentado en el aire.
- En el teclado de la PC, Espacio es `ui_accept` y `atacar`: cerrar un menú con Espacio también ataca. Ya pasaba.
- Guiones intermitentes por `--quit-after`, sin causa encontrada: `habilidad_caida_en_picada_desde_suelo` (una vez
  el 20-oct) y `sala_puerta_b_pared` (una vez el 18-oct).
- El export del APK imprime «No project icon specified»; sin investigar.

## Decisiones abiertas (la persona)

- Para después de la v1 base: sala de música, hablar con un NPC tocándolo y un sonido propio para el daño recibido.
- Decidido el 21-oct, para después del #6 (el orden, sin decidir): rebase y PR de `chore/android-export`; los ajustes
  medianos a las instrucciones de Claude en un PR `chore/`; el paso 13; La Celda en `feature/contenido-celda`; la
  skill de animación.
- Sin decidir: sonidos, keystore, el color definitivo del foco y la caja gris de `sala_inicial`.
