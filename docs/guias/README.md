# Guías para el equipo

Recetas cortas para quien llega nuevo. Cada una remite a `docs/` por archivo y sección; no copia reglas ni cifras,
así que ante una diferencia manda el documento al que remite.

| Guía | Cuándo leerla |
|---|---|
| `empezar.md` | Al clonar: entorno, importación, validación y primera corrida |
| `como-trabajamos.md` | Antes de la primera rama: ciclo de una funcionalidad, plan, evidencia y PR |
| `armar-una-sala.md` | Para agregar una sala o una zona nueva en `contenido/` |
| `agregar-un-enemigo.md` | Para crear la ficha y el comportamiento de un enemigo |
| `arte.md` | Para incorporar al juego una pieza de arte ya aprobada |
| `sonido-y-musica.md` | Para agregar un sonido, un tema de sala o una región de música |
| `medir-en-el-telefono.md` | Para exportar el APK de desarrollo y medir en el teléfono |
| `cuando-algo-falla.md` | Cuando el validador, un guion o el editor dan un error |

## Glosario

Piezas y términos que las guías nombran sin explicar:

| Término | Qué es |
|---|---|
| `Interactuable` | Base de lo que se usa con `interactuar` estando encima: Npc, reto, mochila, tienda, estación, banco, entrega y puerta (`nucleo/interactuable.gd`) |
| `FondoTapado` | Agrupa capas de fondo que una pared opaca tapa: las recorta donde acaba la pared y las oculta si la vista cae dentro de ella; la pared puede estar a la izquierda o a la derecha de lo visible (`lado`, `nucleo/fondo_tapado.gd`) |
| `LuzSala` | Fuente de luz de una sala (tubo, hongo, chispa): un halo aditivo y, solo con las luces 2D encendidas, una `PointLight2D` (`nucleo/luz_sala.gd`) |
| `ZonaCamara` | Área que, mientras el jugador está dentro, limita lo que muestra la cámara además de los límites de la sala (`nucleo/zona_camara.gd`) |
| `Terreno`, `Peligros`, `Encima`, `Luces`, `Frente` | Nodos contenedores de la base de una zona, no grupos de Godot |
| Ficha | Recurso `.tres` de solo lectura con datos (`FichaEnemigo`, `FichaDialogo`, `FichaSonidos`) |
| Guion | Entradas por cuadro y estado esperado para correr el juego sin ventana (`docs/guiones.md`); no es un script de GDScript |

Los fragmentos de código de las guías son copias de archivos reales del repo: ante una diferencia manda el archivo.

Fuera de estas guías, la referencia está en `docs/contrato.md` (qué ofrece cada bloque), `docs/jugador.md`,
`docs/guiones.md`, `docs/pruebas.md` y `docs/errores/`.
