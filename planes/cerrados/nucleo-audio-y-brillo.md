CERRADO

# Núcleo: volumen de música y efectos, y brillo

La persona los pidió el 12-oct-2026 tras ver las opciones de audio y video de Silksong, y aprobó la propuesta el
13-oct-2026 con las opciones recomendadas. Van juntos porque los dos cambian `Ajustes` y Configuración.

## Decisiones (13-oct-2026)

- Configuración: la celda «Volumen» pasa a ser un botón «Audio» que abre un panel (como «Botones del control») con
  tres barras con «−» y «+»: General (bus `Master`, clave `volumen` de siempre), Música y Efectos (buses `Musica` y
  `Efectos`, claves nuevas `volumen_musica` y `volumen_efectos`). Sin voz.
- Los buses van en `res://default_bus_layout.tres`, escrito a mano (no tiene recursos externos ni ids) y comprobado
  por la prueba (`AudioServer.get_bus_index` no es -1). `Musica` y `Efectos` envían a `Master`. Si un bus faltara, el
  volumen no se aplica a ese bus y se avisa con `push_warning`.
- `Ajustes.VERSION` no cambia: un `ajustes.json` sin las claves nuevas las deja en 1, como cualquier clave que falta.
- Brillo: una fila más en la lista, de 50 a 150 % (por omisión 100), con «−» y «+» de 10 en 10. Una capa
  (`CanvasLayer` 100, encima de todo) con un `ColorRect` que oscurece (negro con alfa `1 − v`) o aclara (blanco con
  alfa `(v − 1) · 0,5`, tope 0,25) y se oculta en 100 %. La crea `Arranque`, sin autoload nuevo; no en headless.
  La curva es provisional: la juzga la persona en el teléfono.
- Con brillo alto el fundido a negro se ve gris; se decide al verlo.

## Hitos

1. `default_bus_layout.tres`; `Ajustes` con las claves nuevas y `aplicar_volumen` por bus; `nucleo/brillo.gd`.
2. Configuración: botón «Audio» con su panel y fila «Brillo»; Atrás un nivel a la vez.
3. Casos en `prueba_menu_configuracion.gd` (barras, «−» y «+», guardado) y en `prueba_guardado.gd` (claves que
   faltan, recorte, volumen a dB, buses presentes, color del brillo).
4. `validar.ps1` y todos los guiones; medición en ventana de 1280×720 y 1440×720.
5. Documentos (`docs/contrato.md` «Ajustes» y «Menú», `docs/pruebas.md`); prueba en el S50 y el S20.

## Cierre (13-oct-2026)

- Hitos 1 a 3 hechos. Sonidos de prueba sintetizados con un script (sin bancos ni grabaciones): `nucleo/sonidos/`
  `efecto_salto.wav`, `efecto_golpe.wav` y `musica_prueba.ogg` (17 s en bucle). Viven en el núcleo porque la
  Configuración los usa y el núcleo no depende de otros bloques. Sin fila en `docs/licencias.md` por decisión de la
  persona del 13-oct-2026 (ese archivo se revisa después; ver `ESTADO.md`).
- Casos: `menu_configuracion.guion` pasa de 46 a 53 y `guardado.guion` de 40 a 46. `validar.ps1` y los 120 guiones
  en verde.
- Fallo encontrado: la música de prueba sin pantalla dejaba a veces recursos vivos al salir; ya no se toca sin
  pantalla (`docs/errores/2026-10-13-musica-sin-pantalla.md`).
- Hito 4: capturas en ventana de 1280 y 1440 de ancho (lista, panel Audio, brillo en 60 y 150): nada se sale.
- Hito 5: en el S50 (adb) el panel cabe encima del aviso, el brillo oscurece y Android registra un reproductor
  activo. Que se oiga y cómo se siente la curva del brillo los juzga la persona (`audio-y-brillo-telefono`). El S20
  quedó sin autorizar la depuración USB.
- Comparte `configuracion.gd`, `configuracion.tscn` y su prueba con las ranuras: van en el mismo commit.
