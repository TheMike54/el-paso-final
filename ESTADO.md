# Estado

Se sobrescribe (ver `CLAUDE.md`).

## Ahora (16-oct-2026)

- PR #5 fusionado en `main` (`1ddd8a0`); issues de QA #3 y #4 cerrados. No hay PR abierto.
- Rama de trabajo: `feature/nucleo-mando-menus`, sobre `main`, todo en local y sin commits hasta el domingo
  18-oct-2026, cuando se abre el PR (decisión del 16-oct).
- `chore/android-export` (presets de 32 y 64 bits) sigue sobre la base vieja: rebase y su propio PR a `main`, el
  18-oct.
- Ruleset `main` (12-oct): solo por PR, 1 aprobación, `validar` en verde, Squash and merge, sin force push ni borrado.
- Sensación del jugador cerrada el 15-oct (revisor aprobado; plan en `planes/cerrados/nucleo-sensacion.md`).
- Brillo con `CanvasModulate` (`planes/cerrados/nucleo-brillo.md`): 56 FPS en el S50, visto bien el 15-oct.

## QA con control (14-oct-2026)

- Tableta con Xbox: pasa. A55 con DUALSHOCK 4: Cruz no pulsa en la pausa; no se reproduce en Windows ni en el S50
  (`docs/errores/2026-10-13-control-no-acepta-en-menus.md`). Salto junto a las puertas: pasa en los tres equipos.
  Nombres y GUID reales de los controles, sin medir.

## En curso (17-oct-2026)

- Seis planes en `planes/activos/`, programados, con revisor aprobado y 143 guiones en verde: Círculo / B, L1 / R1
  en la zona, cursor del touchpad, 60 / 120 FPS, botones del control y muros, palancas y portones (17-oct; revisor
  con 6 fallos de documentos, corregidos). Se cierran tras las pruebas manuales.
- Pruebas manuales pendientes (las de control, con compañeros del equipo): B vuelve en cada menú y cura; L1 / R1
  en la zona; íconos con Xbox y DUALSHOCK 4 (y reasignar Saltar); touchpad del DUALSHOCK 4 en Android; FPS 60 / 120
  en el S21; la sala Secretos en un teléfono. El S20 no aparece en `adb` (pantalla dañada).
- Aprobados el 17-oct, sin empezar, en orden: enemigos que se mueven, lo perdido, tienda y viaje rápido
  (`planes/activos/`). Sin historia ni zonas por ahora. Rama nueva para esta tanda tras el commit (6).

## Decisiones de la persona (13 a 16-oct-2026)

- Sin inventario de objetos ni «sobrecarga» de amuletos en la v1. Morir otra vez sin recuperar lo perdido: se pierde.
- Pruebas en teléfono: lo funcional en uno; dos solo para rendimiento o hardware: el S50 y el S20, o el Galaxy S21
  (SM-G991B, 120 Hz) cuando el S20 falle (pantalla dañada) y el S21 esté disponible.
- Dash hacia abajo descartado; logros fuera de la v1. Después: sala de música, tienda de PejeCoins, hablar con un NPC tocándolo y un sonido propio para el daño recibido.
- La dificultad del salto en pared se queda. El color del foco no es definitivo. Un `Fondo` opaco solo donde haga
  falta. La skill de animación se escribe con el primer sprite animado.
- 14-oct: el agarre a la pared se queda con cualquier contacto (`altura_agarre_pared` = 0), como Hollow Knight.
- 14-oct: arte a 1x con mipmaps; puertas por id; campos nuevos del guardado con valor por omisión; ids de
  habilidades en una lista; las reglas de salas, enemigos, jefes, audio, exportación e idioma en `docs/contrato.md`.
- 15-oct: los fondos translúcidos de la sala de arte se quedan en VRAM, como ya están (mismo FPS que Lossless en el
  S50 y el S21; 18 MB menos de memoria de gráficos en el S21).
- 15-oct: sin interpolación (S21 a 120, sin saltos). Recursos, bloqueado desde la pausa. El límite de FPS lo da
  la opción 60 / 120 (16-oct), que arranca en 60.
- 15-oct, probadas en el S21 y aceptadas (en el código): congelado al recibir daño 4 → 10 ticks,
  empuje del enemigo golpeado 24 → 60 px (`Golpeable.velocidad_retroceso` 240 → 600), salto 200 → 230 px, y
  soltar Curar antes de 27 ticks devuelve la Inspiración gastada (con prueba de que nunca deja más que al empezar),
  adelanto de cámara de 43 px hacia donde mira y coyote 3 → 4 ticks (5 se sintió fácil). Plan:
  `planes/cerrados/nucleo-sensacion.md`.
- 16-oct: el validador exige pared detrás de cada puerta en el borde; `entrada-control` aprobada; sonidos,
  keystore y la caja gris de `sala_inicial`, pendientes.

## Bloqueos y pendientes

- Esperan hardware o firma: `menu-desarrollo`, `paquete-publicacion` y `recursos-medicion-publicacion` (keystore).
  `sonidos-telefono` falla hasta que el golpe recibido tenga su propio sonido.
- Caja gris de `sala_inicial` hasta la primera sala real. Ícono del proyecto: después.
