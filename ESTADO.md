# Estado

Se sobrescribe (ver `CLAUDE.md`).

## Ahora (14-oct-2026)

- Rama y PR: `feature/nucleo-menu-tactil`, PR #5 a `main` (`qa-pending`). Un solo PR (decisión del 14-oct-2026):
  además del núcleo lleva las paredes detrás de las puertas del borde, el foco que solo se ve tras usar control o
  teclado, las dos limpiezas (`planes/cerrados/nucleo-limpieza.md`, `nucleo-limpieza-2.md`) y el pulido
  (`planes/cerrados/nucleo-pulido.md`). Se fusiona con la aprobación de otro integrante, después de su prueba con
  el APK de desarrollo.
- `chore/android-export` (presets de 32 y 64 bits) sigue sobre la base vieja: rebase y su propio PR a `main`.
- `planes/activos/nucleo-foco-visible.md`: abierto hasta ver el foco con control en el S50.

## Preparación del repositorio

Pasos 1 a 8 cumplidos (detalle en git). El 7 cerró el 14-oct-2026: la tercera máquina pasó
`verificar-entorno.ps1` y `validar.ps1` desde un clon limpio. Ruleset `main` activo desde el 12-oct-2026: solo por PR,
1 aprobación, `validar` en verde, solo Squash and merge, sin force push ni borrado.

## QA de los integrantes (14-oct-2026)

- Pogo: funciona como debe (dos fundidos rápidos parecen uno).
- Sala de puerta A: caminar con la sala a oscuras parecía estar atorado; ahora tiene marcas.
- Salto en pared: dos integrantes lo encuentran difícil con el dedo; la dificultad se queda (decisión de la persona).
- Pendiente: que prueben el APK nuevo (foco con control y con el dedo, puertas, combate) en #3 y #4.

## Decisiones abiertas

- Capas translúcidas de la sala de arte en VRAM (`fondo1`, `fondo2`, `lejana1`, `suelo`): compararlas en el S50
  contra Lossless; hasta entonces son excepción del validador.

## Decisiones de la persona (13 y 14-oct-2026)

- Sin inventario de objetos ni «sobrecarga» de amuletos en la v1. Morir otra vez sin recuperar lo perdido: se pierde.
- Pruebas en teléfono: lo funcional en uno; el S50 y el S20 juntos solo para rendimiento o hardware.
- Dash hacia abajo descartado. Logros fuera de la v1.
- Después: 120 FPS en gama alta, sala de música, tienda de PejeCoins, palancas y muros, hablar con un NPC tocándolo y
  un sonido propio para el daño recibido.
- La dificultad del salto en pared se queda. El color del foco no es definitivo. Un `Fondo` opaco solo donde haga
  falta. La skill de animación se escribe con el primer sprite animado.
- 14-oct: el agarre a la pared se queda con cualquier contacto (`altura_agarre_pared` = 0), como Hollow Knight.
- 14-oct: arte a 1x con mipmaps; puertas por id; campos nuevos del guardado con valor por omisión; ids de
  habilidades en una lista; las reglas de salas, enemigos, jefes, audio, exportación e idioma en `docs/contrato.md`.

## Bloqueos y pendientes

- Prueba con control: un integrante con tableta y control (#3), el otro con teléfono y control (#4).
- Esperan hardware o firma: `menu-desarrollo`, `paquete-publicacion` y `recursos-medicion-publicacion` (keystore) y
  `entrada-control` (#3 y #4). `sonidos-telefono` falla hasta que el golpe recibido tenga su propio sonido.
- Que el validador exija la pared detrás de cada puerta en el borde.
- La caja gris sigue de `sala_inicial` hasta que exista la primera sala real.
- Ícono del proyecto: después.
