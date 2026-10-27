# Uso de IA y recursos

## Términos

- **Código** (scripts, escenas, configuración y herramientas): licencia MIT, archivo `LICENSE`.
- **Arte, música y textos del juego**: son del equipo, con todos los derechos reservados; los generados con IA
  también. No están cubiertos por la licencia MIT.
- Ninguna textura mide más de 2048 px por lado.

## Herramientas de IA

Se registra cada herramienta y para qué se usa, no cada archivo. Herramienta nueva: una fila nueva.

| Tipo | Herramienta | Para qué |
|---|---|---|
| Código y documentación | Claude Code (Anthropic) | Scripts, escenas, pruebas y documentos, con revisión del equipo; cada PR dice qué parte |
| Imágenes | Gemini (Google), app de Gemini | Fondos, fotos nocturnas de ESCOM y adornos de la sala de arte (`herramientas/salas/arte/`); las hojas de animación del personaje, recortadas y juntadas por un script en el atlas del jugador (`nucleo/arte/jugador_hombre/`); las piezas de La Celda (`contenido/salas/celda/arte/`), recortadas y reducidas por un script escrito con Claude Code; la máscara del ícono de la app (`nucleo/arte/icono/`) y la mochila perdida (`nucleo/arte/mochila_perdida.png`), igual. Los marcadores del mapa, la PejeCoin y el ícono de guardado se dibujan en código (`nucleo/figuras_vector.gd`), sin IA de imágenes |
| Video | Google Flow (imágenes con Nano Banana Pro, video con Veo 3.1 Lite) y Veo 3.1 Quality (Google) | La cinemática de La Celda (`contenido/cinematicas/`) y el fondo animado del menú (`nucleo/video/`); el montaje y los efectos de sonido, con programas escritos con Claude Code |
| Escalado de video | Real-ESRGAN, modelo `realesr-animevideov3`, en la computadora local | Los dos videos, de 720p a 1080p, antes de convertirlos a H.264 y Theora |
| Voces | edge-tts (Microsoft) | El coro de los sinodales en la cinemática de La Celda |
| Sonidos | Script escrito con Claude Code | Los sonidos de prueba de `nucleo/sonidos/` (efectos y música sintetizados, sin muestras ajenas) |

## De terceros

Un recurso hecho por otra persona (fuente, sonido, imagen) entra solo con una licencia que permita usarlo en el
juego, y aquí se anota su autor y su licencia.

| Recurso | Autor | Licencia |
|---|---|---|
| Fuente Cabin Sketch, normal y negrita (`nucleo/fuentes/cabin_sketch.ttf`, `cabin_sketch_bold.ttf`), letra de los menús | The Cabin Project Authors (Copyright 2011) | SIL Open Font License 1.1, texto en `nucleo/fuentes/ofl.txt` |
