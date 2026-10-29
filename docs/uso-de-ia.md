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
| Imágenes | Gemini (Google), app de Gemini; Google Flow (imágenes con Nano Banana Pro) | Fondos, fotos nocturnas de ESCOM y adornos de la sala de arte (`herramientas/salas/arte/`); las hojas de animación del personaje, recortadas y juntadas por un script en el atlas del jugador (`nucleo/arte/jugador_hombre/`); las piezas de escenario de La Celda (`contenido/salas/celda/arte/`), con Google Flow (Nano Banana Pro), recortadas, escaladas y ajustadas de tono por un script escrito con Claude Code; la máscara del ícono de la app (`nucleo/arte/icono/`) y la mochila perdida (`nucleo/arte/`), igual. Con Google Flow, el coleccionable del juego (`nucleo/arte/`), recortado y reducido por un script escrito con Claude Code. El Eterno (`contenido/npc/eterno/`): su hoja de animación, hecha en chat como las del personaje, cortada en una tira de cuadros por un script escrito con Claude Code. |
| Imágenes dibujadas por código | Scripts de Godot escritos con Claude Code, sin IA generativa de imágenes | Los marcadores del mapa, la PejeCoin y el ícono de guardado, en vector (`nucleo/figuras_vector.gd`); el destello del parry, la bola de fuego, el aura de curar (detrás y delante del jugador), el ruido de la niebla y el montón de PejeCoins del mundo (`nucleo/arte/efecto_*.png`, `niebla_ruido.png`, `monedas_sueltas.png`), calculados pixel por pixel desde esas figuras (`herramientas/generar_efectos.gd`); la media luna blanca del trazo del ataque (`nucleo/arte/trazo_ataque.png`, `herramientas/generar_trazo.gd`) |
| Video | Google Flow (Veo 3.1 Lite) y Veo 3.1 Quality (Google) | La cinemática de La Celda y la de la Pluma (`contenido/cinematicas/`) y el fondo animado del menú (`nucleo/video/`), a partir de cuadros hechos con las herramientas de «Imágenes»; el montaje y los efectos de sonido, con programas escritos con Claude Code |
| Escalado de video | Real-ESRGAN, modelo `realesr-animevideov3`, en la computadora local | Los dos videos, de 720p a 1080p, antes de convertirlos a H.264 y Theora |
| Voces | edge-tts (Microsoft) | El coro de los sinodales en la cinemática de La Celda |
| Música | Google Flow Music (modelo Lyria 3.5) | El tema del menú (`nucleo/sonidos/`); el corte del silencio final y la conversión a Ogg, con un script escrito con Claude Code |
| Sonidos | Script escrito con Claude Code | Los efectos del jugador y de lo que toca (`nucleo/sonidos/jugador/`: pasos, aterrizaje, picada, impulso, golpe, daño, curar, banco, muro roto y portón), sintetizados con numpy (ruido filtrado, barridos, parciales y reverb corta), sin muestras ajenas; el equipo eligió entre varias propuestas |

## De terceros

Un recurso hecho por otra persona (fuente, sonido, imagen) entra solo con una licencia que permita usarlo en el
juego, y aquí se anota su autor y su licencia.

| Recurso | Autor | Licencia |
|---|---|---|
| Fuente Cabin Sketch, normal y negrita (`nucleo/fuentes/cabin_sketch.ttf`, `cabin_sketch_bold.ttf`), letra de los menús | The Cabin Project Authors (Copyright 2011) | SIL Open Font License 1.1, texto en `nucleo/fuentes/ofl.txt` |
