# Cómo se agrega un sonido o una música

**Para qué sirve:** sumar un efecto de jugador o de evento, o el tema de una sala o de un tramo de sala, y dejarlo
declarado.
**Antes de empezar:** leer `docs/contrato.md` («Ajustes y vibración», viñetas de audio: efectos y `Musica`;
«Componentes», fila `RegionMusica`; «Sala», propiedades `tema_musica` y `volumen_musica_db`; «Contenido que viene»,
viñeta «Audio») y `docs/uso-de-ia.md`.

## Efecto de jugador o de evento
1. Producir el sonido como WAV (formato de efectos, `docs/contrato.md`, «Contenido que viene», viñeta «Audio»). La
   herramienta con que se hacen los efectos consta en `docs/uso-de-ia.md`, fila «Sonidos».
2. Guardarlo en `nucleo/sonidos/jugador/` en snake_case (`CLAUDE.md`, «Entorno y trampas») e importar:
   `& $env:GODOT_PATH --headless --path . --import`.
3. Si el evento ya es un campo de `FichaSonidos` (`nucleo/ficha_sonidos.gd`): asignar el WAV a ese campo en
   `nucleo/sonidos/sonidos_jugador.tres` desde el editor. Para variar el tono, usar un `AudioStreamRandomizer` con
   `random_pitch` como en `paso`, `aterrizaje` y `golpe` (`docs/contrato.md`, viñeta de efectos).
4. Si el evento es nuevo: agregar su campo en `FichaSonidos` y su línea de conexión en `nucleo/sonido.gd` (bloque de
   `Eventos.<señal>.connect(tocar.bind(&"<campo>"))`). Un evento que no es campo de la ficha hace que `tocar()` avise
   con `push_warning`.
5. Correr el guion `nucleo/sonido` (comando en `docs/guiones.md`) y `.\herramientas\validar.ps1`.

## Música de sala o de región
1. Producir el tema en Ogg Vorbis. La herramienta con que se hace la música consta en `docs/uso-de-ia.md`, fila
   «Música».
2. Guardarlo junto al tema existente (`nucleo/sonidos/musica_menu.ogg`) e importar. En el panel Import, encender el bucle (`loop` en un Ogg o MP3;
   `loop_mode` en un WAV). Dónde lo exige el validador y qué tipos de audio acepta: `docs/contrato.md`, «Sala»,
   viñeta de `tema_musica`.
3. Música de toda una zona: asignar el mismo recurso a `tema_musica` en la base de la zona
   (`contenido/zonas/<zona>/sala_<zona>.tscn`, «Arte de zona», viñeta «Base de la zona»), para que no reinicie al
   cruzar una puerta. Una sala sin música propia deja `tema_musica` vacío (sigue la que suena) o le asigna
   `nucleo/sonidos/silencio.tres`, el recurso de `Musica.SILENCIO` (`docs/contrato.md`, «Ajustes y vibración»).
4. Cambio dentro de una sala: agregar un nodo `RegionMusica` con su `CollisionShape2D` hija directa y dar `tema` y
   los volúmenes (`docs/contrato.md`, «Componentes», fila `RegionMusica`).
5. Correr el guion `nucleo/musica` y `.\herramientas\validar.ps1`. Cómo suena solo se comprueba oyéndolo: se
   pide la prueba manual a la persona, diciendo qué escuchar (`CLAUDE.md`, «Comandos»).

## Declarar
1. En `docs/uso-de-ia.md`, «Herramientas de IA»: la fila «Sonidos» o «Música» se amplía con la carpeta nueva; una
   herramienta nueva lleva fila propia. Un sonido o tema ajeno entra solo con autor y licencia en «De terceros».
2. El commit lo hace la persona que responde por el cambio (skill `funcionalidad`, paso «Entregar»); el PR dice
   herramienta y parte (`CLAUDE.md`, «Reglas de este proyecto»).

## Si algo falla
- El validador falla con «… el tema … no se repite: activar Loop al importarlo» (falta el bucle) o con «… que el
  validador no sabe revisar: Ogg, MP3 o WAV» (tipo no válido). La regla es la entrada `validador-musica` de
  `herramientas/funciones.json`; el detalle, en `docs/contrato.md`, «Sala».
- Un efecto que corta a otro o un tema que sube o baja raro: `docs/errores/2026-10-27-sonido-corta-voces.md` y
  `docs/errores/2026-10-27-musica-sube-al-callar.md`.
- Otros fallos: `docs/guias/cuando-algo-falla.md`.
