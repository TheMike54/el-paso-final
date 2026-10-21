# Estado (se sobrescribe; ver `CLAUDE.md`)

## Ahora (21-oct-2026)

- Rama de trabajo: `feature/nucleo-enemigos-moviles`, sin PR abierto. Lleva `b31c08e` (nunca subido; decidido el
  21-oct que va en este PR), las tandas del 13 al 17-oct, la auditoría, los arreglos del 20-oct y el cuerpo animado.
  - Sigue: Miguel corre el commit y abre el PR con `qa-pending`, un issue de QA por compañero (tableta con Xbox,
    teléfono con DUALSHOCK 4) y el APK `dev-2026-10-21`.
- `chore/android-export` (presets de 32 y 64 bits, con «Desarrollo»): falta su rebase y su propio PR a `main`.
  Hasta entonces, `export_presets.cfg` de esta rama solo tiene «Publicacion» (H23 de la auditoría).
- Ruleset `main` (12-oct): solo por PR, 1 aprobación, `validar` en verde, Squash and merge, sin force push ni borrado.
- Al 21-oct: `validar.ps1` → `OK  VALIDACION archivos=267 fallos=0`; `correr-guiones.ps1` → `RESUMEN total=157
  OK=157 MALOS=0`; trazador del jugador → `TRAZA IDENTICA n=36`; `animacion_jugador` 48 casos, 0 fallos.

## Pruebas manuales pendientes en el S50

- **Animaciones** (APK de desarrollo sin mipmaps, instalado): cada acción con su animación, el destello en blanco,
  el borde de las hojas, la katana a tamaño de juego y dormir en el banco (se ve sentado en el aire: conocido).
  Va sin mipmaps (decidido 21-oct): que los bordes no parpadeen al moverse la cámara. Caso «Cuerpo animado del
  jugador» de `docs/pruebas.md`.
- **Control:** cerrar con A la pausa, el cobro y el marco sin que el jugador salte, también sentado en el banco.
- **Mapa:** los botones + / – y el texto del mapa vacío.
- **Con el dedo:** Pizarrones, menús en gis, tienda, estaciones, amuletos con más de 5, y Pausa y Mapa cerrando
  menús por toque.
- **Rendimiento en el S20:** no se midió; el S50 se midió el 18 y el 21-oct.
- **Con control, de los compañeros:** B vuelve en cada menú; L1 / R1 en la zona; los íconos con Xbox y DUALSHOCK 4;
  el touchpad del DUALSHOCK 4 en Android; los pizarrones con control.
- **Esperan hardware o firma:** `menu-desarrollo`, `paquete-publicacion` y `recursos-medicion-publicacion`
  (keystore). `sonidos-telefono` falla hasta que el golpe recibido tenga su propio sonido.

## Planes activos

- `nucleo-animacion-jugador`: primera vuelta hecha y revisada (`"pasa": true`); falta la prueba manual en el S50.
- `nucleo-aviso-accion`: falta H10, la prueba del dedo en la sala Pizarrones.
- `nucleo-menus-gis`: falta H6, la prueba en los teléfonos.
- `nucleo-tienda-gis`: hechos H1 a H4. Falta H5, la prueba con el dedo en el teléfono.
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
- Decidido el 21-oct, para después de este PR: la skill de animación; La Celda en `feature/contenido-celda`; los
  ajustes medianos a las instrucciones de Claude en un PR aparte.
- Sin decidir: sonidos, keystore, el color definitivo del foco y la caja gris de `sala_inicial`.
