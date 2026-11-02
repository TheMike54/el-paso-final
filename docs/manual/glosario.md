# Glosario

Términos del juego y del proyecto. Las piezas de escena (`FondoTapado`, `LuzSala`, `ZonaCamara`…) están en el glosario de `docs/guias/README.md`.

## Del juego

| Término | Qué es |
|---|---|
| Amuleto | Objeto que se pone sentado en un banco y cambia un valor del jugador. Gasta carga (`nucleo/ficha_amuleto.gd`) |
| Aterrizaje duro | Caer desde muy alto: temblor y unos ticks sin control. No quita vida |
| Azulito | El coleccionable del juego. Cada uno tiene un id que empieza con `coleccionable` |
| Banco | Mesa donde el jugador se sienta a descansar: guarda, fija dónde reaparece y permite cambiar el equipo (`nucleo/banco.gd`) |
| Bloque de Inspiración | Lo que muestra la barra: 11 puntos de Inspiración |
| Bola | El proyectil del jugador: un toque del botón de poderes (habilidad `proyectil`) |
| Brújula | Útil que hace que el mapa muestre dónde estás |
| Caída en picada | Bajar recto y rápido; gasta Inspiración (habilidad `caida_en_picada`) |
| Carga | Cuánto pueden costar juntos los amuletos puestos. Empieza en 3 y su tope es 11 |
| Carrera | Si al acabar el impulso hay dirección, el jugador sigue corriendo |
| Coyote | Unos ticks después de dejar una orilla en que todavía se puede saltar |
| El Eterno | Personaje guía de La Celda; entrega la Pluma (`contenido/npc/eterno/`) |
| ESCOM | La escuela donde pasa la historia |
| Golpe normal | Daño con retroceso e invulnerabilidad; no mueve al jugador de lugar |
| Impulso | Lanzamiento horizontal sin gravedad (habilidad `impulso`) |
| Inspiración | Recurso que se gana golpeando enemigos y se gasta en curar y en los poderes. Se pierde al morir |
| La Celda | Primera zona, el sótano donde empieza el juego |
| Las Raíces | Segunda zona, sin construir |
| Mochila | Lo que queda donde moriste con tus PejeCoins. Hay una sola: morir con monedas borra la anterior (`nucleo/mochila.gd`) |
| Modo desarrollador | Configuración, Avanzado: muestra la zona de pruebas y deja saltar cinemáticas |
| Parry | Parar un ataque enemigo marcado con un ataque propio |
| PejeCoins | La moneda del juego |
| Peligro | Daño que quita vida aunque seas invulnerable y te devuelve al punto seguro (`peligro` en `nucleo/dano_contacto.gd`) |
| Pizarrón | Aviso dibujado en una sala que enseña una acción (`nucleo/aviso_accion.gd`) |
| Pluma, la | El arma. Tiene forma de katana. Sin ella no se ataca (habilidad `pluma`) |
| Pluma de mapa | Habilidad que dibuja en el mapa lo visitado al descansar (`pluma_mapa`) |
| Pogo | Rebote al atacar hacia abajo en el aire |
| Punto seguro | Último suelo firme, al que devuelve un peligro |
| Ranura | Una de las cuatro partidas guardadas. En equipo, también el lugar de un útil puesto |
| Reto de preguntas | Preguntas de opción múltiple que dan una recompensa (`nucleo/reto_preguntas.gd`) |
| Salto en cola | Pulsar saltar justo antes de aterrizar y que el salto salga al tocar el suelo |
| Sinodales | Los tres antagonistas de la historia |
| Útil | Objeto que se pone sin gastar carga (`nucleo/ficha_util.gd`). El código tiene hoy una ranura |

## Del proyecto

| Término | Qué es |
|---|---|
| AAB | Paquete Android que pide Google Play. Lo produce el preset «Publicacion» |
| APK | Paquete instalable directamente en un teléfono. Lo produce el preset «Desarrollo» |
| Autoload | Nodo global de Godot. Aquí son `Eventos`, `Partida` y `Arranque` |
| Autoguardado | Guardado sin banco, disparado por determinados progresos, la muerte o el paso de la app a segundo plano. Recoger PejeCoins no lo dispara |
| Base de zona | Escena que heredan todas las salas de una zona (`contenido/zonas/celda/sala_celda.tscn`) |
| Bloque | Cada carpeta con dueño propio de reglas: `nucleo/`, `contenido/`, `interfaz/`, `mapa/` y `herramientas/` |
| Bloque de commit | Comandos de git que un asistente deja escritos para que los corra quien responde por el cambio |
| Bus de eventos | Autoload `Eventos`: señales compartidas (`nucleo/eventos.gd`) |
| Caja gris | Sala o enemigo sin arte final, para probar primero la jugabilidad |
| Catálogo | Lista de amuletos y útiles (`contenido/equipo.tres`) |
| Comportamiento | Script que da a un enemigo su forma de actuar (`nucleo/comportamiento_enemigo.gd`) |
| Congelado | Pausa muy breve del juego al golpear (`nucleo/congelado.gd`) |
| Contrato | Lo que un bloque ofrece a otro (`docs/contrato.md`) |
| Ficha | Recurso `.tres` con datos, sin lógica, de solo lectura en ejecución |
| Fundido | Paso a negro entre salas; también lleva el cambio de sala (`nucleo/fundido.gd`) |
| `funciones.json` | Lista de funcionalidades de un bloque, con su comprobación y si `pasa` |
| Gama baja | Teléfonos baratos para los que se mide el juego; el de referencia es de 32 bits |
| Guion | Entradas por cuadro y estado esperado para correr el juego sin ventana (`docs/guiones.md`) |
| Marco de menús | Las páginas en ciclo del juego: Inventario, Amuletos, Útiles y las demás (`nucleo/marco_menus.gd`) |
| Núcleo | El código común: `nucleo/` |
| Plan | Documento de una funcionalidad compleja, en `planes/` |
| Preset | Configuración de exportación (`export_presets.cfg`) |
| Puerta | Salida de una sala. Tipos: `LADO`, `PUERTA` (con interactuar), `ARRIBA` y `ABAJO` (`nucleo/puerta.gd`) |
| Puerto de depuración | Lo que corre los guiones; solo en builds de depuración |
| Recursos | Ajuste de calidad: automático, bajo o alto (`nucleo/recursos.gd`) |
| Sala | Escena con un `id`, `limites`, entrada y puertas (`docs/sala.md`) |
| Tick | Un paso de física: 60 por segundo |
| Validador | `herramientas/validar.ps1`: compila y revisa reglas de contenido (`docs/validador.md`) |
| Zona | Grupo de salas con su ficha, nombre, color y lugar en el mapa (`nucleo/ficha_zona.gd`) |
| Zona de pruebas | Salas para ejercitar cada pieza del núcleo (`docs/salas-de-prueba.md`) |
