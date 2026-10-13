CERRADO

# Núcleo: elegir personaje y nombre al empezar una partida

La persona lo pidió el 13-oct-2026 («elegir el personaje hombre o mujer perfecto»), como parte de la tanda de la
noche. `Partida` y el guardado ya tienen `personaje` y `nombre` (texto, vacíos por omisión), así que el formato no
cambia y una partida de antes carga con los dos vacíos.

## Decisiones (13-oct-2026, provisionales hasta que la persona las vea)

- Al tocar una ranura vacía no se entra directo: se abre «Nueva partida» (`nucleo/nueva_partida.gd`, armada en
  código como las ranuras): «Volver», dos botones para elegir «Hombre» o «Mujer» (`personaje` = `hombre` o `mujer`),
  el nombre en un `LineEdit` (teclado del teléfono) y «Empezar». «Empezar» no responde hasta elegir personaje.
- Nombre: se recortan los espacios de las orillas y los repetidos, quedan solo letras (con acentos y ñ), números y
  espacios, máximo 12 caracteres. Vacío: «Alumno» o «Alumna» según el personaje.
- La ficha de una ranura ocupada lleva el nombre en lugar de «Partida N»; sin nombre (partidas de antes), sigue
  «Partida N».
- Atrás y la acción `pausa` vuelven de «Nueva partida» a las ranuras, un nivel a la vez, como el resto del menú.
- El sprite según el personaje queda para cuando haya arte: el jugador hoy es una forma provisional. `Partida`
  ya guarda la elección.

## Hitos

1. `NuevaPartida` con su limpieza del nombre (estática) y el menú: ranura vacía → «Nueva partida» → `preparar_ranura`
   con personaje y nombre.
2. Casos en `prueba_ranuras.gd`: nombre limpio, vacío según personaje, Empezar bloqueado sin personaje, la ranura
   queda con personaje y nombre, la ficha muestra el nombre, Atrás vuelve a las ranuras.
3. `validar.ps1` y todos los guiones; capturas en ventana de 1280 y 1440; APK en el S50 (el teclado lo prueba la
   persona).
4. Documentos: `docs/contrato.md` «Menú», `docs/pruebas.md`.

## Cierre (13-oct-2026)

- Hitos 1 a 4 hechos: `nucleo/nueva_partida.gd` (personaje, nombre limpio, «Alumno» o «Alumna» si queda vacío), el
  menú la abre al tocar una ranura vacía y `preparar_ranura` guarda los dos; la ficha muestra el nombre. Casos en
  `prueba_ranuras.gd` (56 en total); `validar.ps1` y todos los guiones en verde; capturas en 1280 y 1440.
- En el S50 (adb): el teclado tapaba el campo; ahora el formulario sube mientras el teclado está abierto. Con eso se
  escribió un nombre, ✓ empezó la partida y la ficha mostró el nombre (la partida de prueba se borró después).
- Ahí mismo apareció que las ranuras medían 0×0 y la confirmación de Borrar salía en la esquina:
  `docs/errores/2026-10-13-confirmacion-de-ranuras-en-la-esquina.md`, con un caso que mide la confirmación.
- `revisor`: el código cumple el plan; 1 fallo de documento corregido (`ESTADO.md` no listaba
  `personaje-y-nombre-telefono` ni `amuletos-telefono` entre lo que espera teléfono). De su observación: la consulta
  del teclado ahora solo se hace con el campo enfocado y si la plataforma tiene teclado virtual (en PC imprimía un
  aviso cada vez).
- El sprite según el personaje espera al arte; la prueba con el teclado de cada teléfono es de la persona
  (`personaje-y-nombre-telefono`).
