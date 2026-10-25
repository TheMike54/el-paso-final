CERRADO

# Brillo sin rectángulo encima de la pantalla

Aprobado por la persona el 15-oct-2026 («punto medio»: más simple que Hollow Knight, pero que se note).

## Por qué

Con cualquier brillo distinto de 1,0, `nucleo/brillo.gd` dibuja un `ColorRect` sobre toda la pantalla. En el Senwa S50
cuesta ~6 ms por cuadro: la sala de arte en bajo baja de 56 a 42 FPS con el brillo en 0,95 (`docs/pruebas.md`,
«Sala de arte»).

Hollow Knight y Silksong aplican el brillo como un efecto de la cámara del juego, de 0,1 a 2,0. Afecta solo al
mundo: el HUD va en otra cámara. Silksong lo apaga en gama baja. A ellos les sale casi gratis porque ya pagan un pase
de pantalla completa (bloom, corrección de color); aquí no existe ese pase.

## Qué se hace

- Cada `Sala` crea un `CanvasModulate` con `Color(v, v, v)`, donde `v` es `Ajustes.brillo`.
  - Godot multiplica el color de cada cosa del mundo al dibujarla: no hay pase extra ni nada dibujado encima
    (`classes/class_canvasmodulate.rst:25`).
  - Afecta solo al canvas del mundo: el HUD, los controles táctiles, la pausa y los menús son `CanvasLayer` y no
    cambian.
  - Comprobado en Windows con Compatibility el 15-oct: con 1,5, un gris de 0,4 se ve 0,6, y una `CanvasLayer`
    queda igual. En Android, sin comprobar.
- `Brillo` deja de ser una capa con rectángulo.
  - `Brillo.color_para(v)` pasa a devolver el color del modulado.
  - Al mover la barra, `Ajustes.aplicar_brillo()` cambia el color del modulado de la sala viva (`Brillo.instancia`).
- La pantalla de brillo de Configuración ya no la tapa la capa 100: su escena aplica el brillo con `modulate`.
  - La foto de la pausa trae el brillo con que se tomó: el shader de la foto la divide entre ese valor.
  - El cuadro de calibración también se modula.
- El rango sigue de 0,5 a 1,5.
- Sin contraste, sin efectos de destello y sin apagarlo en gama baja.
- Fuera de una sala (menú principal, ranuras) no hay modulado: como en Silksong, el brillo vale solo en el juego.

## Hitos

1. H1 · Código.
   - `brillo.gd`, `sala.gd`, `ajustes.gd`, `arranque.gd` y `configuracion.gd`.
   - Las pruebas de `prueba_guardado.gd` y `prueba_menu_configuracion.gd` ajustadas a la cuenta nueva.
   - Se comprueba con `validar.ps1`.
2. H2 · Comprobaciones.
   - Guion `herramientas/guiones/nucleo/brillo_sala.guion`: la sala crea su `Brillo` (alfa 1). El gris no va ahí
     porque depende del brillo guardado en el equipo.
   - `prueba_guardado.gd`: el modulado toma el brillo al crearse, sigue a `Ajustes.aplicar_brillo()` y se suelta al
     salir; el color recorta fuera de rango y 1 es blanco.
   - `prueba_menu_configuracion.gd`: el cuadro de calibración se modula con el brillo de la barra.
   - Se comprueba con esos guiones y con todos los demás, en serie.
3. H3 · Documentos: `docs/contrato.md` (Brillo, capa 100, ajuste `brillo`, pantalla de brillo), `docs/pruebas.md` y
   las entradas `brillo-sin-capa` y `brillo-sin-capa-telefono` en `nucleo/funciones.json`.
4. H4 · Teléfono.
   - S50, sala de arte en bajo, brillo 0,95: antes 42 FPS, se espera ~56.
   - La persona juzga a ojo 50 % y 150 % en la partida y en la pantalla de brillo.

## Riesgos

- Con un multiplicado, el negro sigue negro: al 150 % el cuadro de calibración casi no cambia (0,05 → 0,075). Lo
  juzga la persona en H4.
- Contrato y autoloads: lleva `revisor`.
