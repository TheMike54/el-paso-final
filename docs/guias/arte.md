# Cómo entra el arte de una pieza al juego

**Para qué sirve:** llevar una imagen de escenario (capa, pieza de piso, orilla, calcomanía) desde que se genera
hasta que la sala la usa y queda declarada.
**Antes de empezar:** leer `CLAUDE.md` («Entorno y trampas»), `docs/contrato.md` («Recursos», viñetas «Tamaño del
arte», «Importación del arte del mundo» y «Receta del arte de una sala») y «Arte de zona».

1. Generar la imagen con una herramienta que ya conste en `docs/uso-de-ia.md`, «Herramientas de IA», fila
   «Imágenes». Una herramienta que no esté ahí se agrega primero (paso 8). Los textos con que se genera no se
   guardan en el repo.
2. Procesar la imagen fuera del juego a PNG con transparencia: recortar al contenido, escalar y ajustar el tono. El
   tamaño al que se pinta y la reducción de las capas de fondo están en `docs/contrato.md`, «Recursos», viñetas
   «Tamaño del arte» y «Receta del arte de una sala».
3. Comprobar que ningún lado pasa del máximo de textura (`MAXIMO_LADO_TEXTURA` en `herramientas/validar.gd`; la
   decisión está en `CLAUDE.md`, «Decisiones cerradas»).
4. Nombrar el archivo en minúsculas, ASCII y snake_case (`CLAUDE.md`, «Entorno y trampas») y guardarlo en
   `contenido/salas/<zona>/arte/` (ejemplo existente: `contenido/salas/celda/arte/`).
5. Importar el proyecto para que nazca el `.import` junto a la imagen:
   `& $env:GODOT_PATH --headless --path . --import`.
6. En el panel Import del editor, fijar la compresión y los mipmaps según `docs/contrato.md`, «Recursos», viñeta
   «Importación del arte del mundo». VRAM Compressed solo en los casos y con la captura en el teléfono que
   describen esa viñeta y «Arte de zona», viñeta «Compresión».
7. Colocarla en la escena de la sala (o en su pieza de `contenido/objetos/<zona>/`), siguiendo «Arte de zona»:
   - capas y `scroll_scale` (viñeta «Capas»), color (viñeta «Color») y escala exacta y uniforme («Escala de capa»);
   - cada borde de capa o de pared que la cámara alcance a ver, con pieza de orilla o degradado, nunca recto
     (viñeta «Bordes»);
   - hueco, losa o pared que se rompe: su orilla rota, la tira de degradado y su arte de estado roto, según
     «Huecos y roturas» y «Lo que se ve por un hueco».
   Una escena escrita a mano conserva los `uid` y lleva el `uid` de cada `ext_resource` (`docs/contrato.md`, «Sala»,
   viñeta «uid»); las escenas no se duplican copiando el archivo, se heredan (`CLAUDE.md`, «Entorno y trampas»).
8. Declarar la herramienta en `docs/uso-de-ia.md`: una fila por herramienta, no por archivo; la fila existente se
   amplía con la carpeta nueva. Un recurso ajeno va en «De terceros», con autor y licencia.
9. Validar: `.\herramientas\validar.ps1` debe imprimir `OK  VALIDACION ... fallos=0`. Si la sala suma capas
   translúcidas, partículas o luces, revisar el presupuesto de «Recursos» y la skill `rendimiento-gama-baja`.
10. Medir en el teléfono lo que se sospecha de rendimiento, con A/B (`docs/guias/medir-en-el-telefono.md`).
11. Entregar: el commit lo hace la persona que responde por el cambio, con el bloque que da la skill
    `funcionalidad`, paso «Entregar» (`CLAUDE.md`, «Reglas de este proyecto»). El PR declara la herramienta y la
    parte.

## Si algo falla
- `validar.ps1` con fallos de tamaño, importación o `uid`: la regla está en «Recursos» y «Sala» de
  `docs/contrato.md`; el recorrido, en `docs/guias/cuando-algo-falla.md`. Una imagen sin uso no es un fallo: sale
  como `AVISO` y no cuenta en `fallos` (`docs/contrato.md`, «Sala», viñeta «Avisos del validador»).
- Un fallo parecido a uno anterior: buscarlo en `docs/errores/` (por ejemplo
  `docs/errores/2026-10-27-hueco-niebla.md`, el hueco de una capa que se repite).
