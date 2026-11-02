# Permisos de uso

Qué se puede usar del repositorio y con qué condiciones. La fuente es `LICENSE` y `docs/uso-de-ia.md`; si este resumen difiere de ellos, mandan esos archivos. Este texto no es asesoría legal.

## Resumen

| Parte | Licencia | Se puede reutilizar |
|---|---|---|
| Código: scripts, escenas, configuración y herramientas | MIT (`LICENSE`) | Sí, conservando el aviso de copyright y de permiso |
| Documentación y manual, salvo `docs/manual/diseno.md` y `docs/manual/recorrido.md` | MIT (`LICENSE`) | Sí, conservando el aviso de copyright y de permiso |
| `docs/manual/diseno.md` y `docs/manual/recorrido.md`: historia y diseño | Todos los derechos reservados | No, sin permiso de sus titulares |
| Arte, música y textos del juego | Todos los derechos reservados | No, sin permiso de sus titulares |
| Arte, música y video generados con IA | Todos los derechos reservados, igual que el resto | No, sin permiso |
| Fuente Cabin Sketch | SIL Open Font License 1.1 | Sí, según esa licencia |

## El código

`LICENSE` es la licencia MIT y aplica al código. Permite usarlo, copiarlo, modificarlo, publicarlo, distribuirlo y venderlo, siempre que el aviso de copyright y el de permiso vayan en las copias. Se entrega sin garantía. Los titulares son los que figuran en `LICENSE`.

## Lo que queda fuera de la licencia

`docs/uso-de-ia.md`, «Términos», deja fuera de MIT:

- imágenes y texturas: fondos, piezas de sala, personajes, íconos;
- video: cinemáticas y fondo del menú;
- música y efectos de sonido;
- textos del juego: diálogos, nombres y descripciones.

Consecuencia práctica: quien publique un juego derivado del código debe reemplazar esos recursos por los suyos, o conseguir permiso de los titulares. Las carpetas donde vive hoy ese material son, entre otras, `nucleo/arte/`, `nucleo/video/`, `nucleo/sonidos/`, `contenido/cinematicas/`, `contenido/salas/celda/arte/`, `contenido/objetos/` y `contenido/npc/`.

Hay casos sin definir:

- Los textos de diálogo viven dentro de fichas `.tres`, y las imágenes se nombran desde escenas `.tscn`: el formato es de código, pero el texto y el arte siguen fuera de MIT.
- `docs/uso-de-ia.md` no dice bajo qué términos están la documentación y este manual. Sin comprobar: si les aplica MIT.
- El nombre del juego no aparece en la licencia. Sin comprobar: si tiene alguna protección.

## Recursos de terceros

Según `docs/uso-de-ia.md`, «De terceros»:

| Recurso | Autor | Licencia | Dónde |
|---|---|---|---|
| Fuente Cabin Sketch, normal y negrita | The Cabin Project Authors (Copyright 2011) | SIL Open Font License 1.1 | `nucleo/fuentes/cabin_sketch.ttf`, `nucleo/fuentes/cabin_sketch_bold.ttf`, texto en `nucleo/fuentes/ofl.txt` |

Regla para agregar otro: un recurso hecho por otra persona entra solo con una licencia que permita usarlo en el juego, y se anota ahí su autor y su licencia. Sin eso no entra.

El motor Godot y las plantillas de exportación no aparecen en esa tabla. Quien distribuya el juego debe revisar por su cuenta los avisos que pide el motor; aquí no se comprobó qué exige.

## Herramientas de IA usadas

`docs/uso-de-ia.md`, «Herramientas de IA», las lista por herramienta, no por archivo:

| Tipo | Herramienta |
|---|---|
| Código y documentación | Claude Code; Codex desde el 29-oct-2026 |
| Imágenes | Google Flow con Nano Banana Pro, y Gemini en lo anterior |
| Imágenes dibujadas por código | Scripts de Godot, sin IA generativa de imágenes |
| Video | Google Flow con Veo 3.1 Lite, y Veo 3.1 Quality |
| Escalado de video | Real-ESRGAN, en una computadora local |
| Voces | edge-tts |
| Música | Google Flow Music, con Lyria 3.5 |
| Sonidos | Script propio con numpy, sin muestras ajenas |

Para arte nuevo solo se usa Google Flow. Una herramienta nueva agrega su fila en `docs/uso-de-ia.md` antes de que su resultado entre al repositorio. Los términos de cada servicio no se revisaron aquí: quien genere arte nuevo debe leerlos.

## Lo que nunca entra al repositorio

Claves de firma, credenciales, paquetes exportados (`.gitignore`) y recursos sin licencia clara.
