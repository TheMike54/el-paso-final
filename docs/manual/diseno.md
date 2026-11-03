# Diseño del juego

> Contiene la historia completa del juego, incluido el final.

Qué juego se quiere construir. Este texto se escribió de nuevo para el manual a partir del diseño original y se cotejó con el código el 2-nov-2026. Cada apartado separa lo hecho de lo previsto. Lo pendiente lleva el número de la tabla de decisiones abiertas de [decisiones.md](decisiones.md).

## Premisa

*El Paso Final* es un juego de exploración y plataformas en 2D para Android. Estás por titularte de ESCOM. Ensayas la presentación de tu Trabajo Terminal con tus dos compañeros, ellos salen un momento y te quedas dormido en la biblioteca. Llegan tres sinodales, te llevan en un elevador y despiertas debajo de la escuela: «No permitiremos que te titules». Hay que subir, zona por zona, hasta el salón.

El nombre juega con tres sentidos: el último paso antes de titularse, subir paso a paso, y «pasar» como aprobar. El tono usa referencias divertidas a ESCOM, pero el juego se ve y se juega en serio. El mundo mezcla guiños a la escuela con lugares que no tienen nada que ver.

## Personajes

**Protagonista.** Se elige mujer u hombre y se le pone nombre. Sudadera guinda, pantalón gris oscuro, tenis altos, mochila pequeña. En la intro se le ve la cara. Abajo ya trae una máscara blanca con ojos negros, la marca de quienes no se titularon. Al firmar el acta, la máscara se rompe.

**Los tres sinodales.** Figuras inventadas con máscara, que nunca se parecen a una persona real.

| | La Rúbrica | El Algoritmo | El Ausente |
|---|---|---|---|
| Tipo | Obsesionada con el formato | Las preguntas técnicas más difíciles | No leyó tu documento |
| Frase | «¿Dónde está su estado del arte?» | «¿Y la complejidad de su algoritmo?» | «No entiendo qué hace su sistema.» |
| Pelea | Tacha el suelo con tinta roja, lanza hojas, encierra la arena en márgenes | Lanza símbolos y rayos de puntero láser; golpe cargado que quita 3 | Desaparece, ataca al azar, a veces se duerme |

Cada ataque se anuncia con una pregunta en gis en el pizarrón. Orden: La Rúbrica, El Algoritmo, El Ausente y los tres a la vez. Arena: el salón, con tu primera diapositiva proyectada.

**El Eterno.** Alumno que llegó en 2009 y nunca se tituló. Guía sin nombre, junto al primer banco de cada zona, con pocas líneas; en La Celda no: él está en `celda_3` y el único banco, en `celda_1`. Da la Pluma, regala el mapa de Las Raíces y vende los de las zonas 2 a 5; la brújula se vende en la tienda de `raices_3`. Su protocolo sellado «NO APROBADO» está en un archivo que solo se alcanza al regresar con el impulso fantasma. Al final se ve a alguien con su ropa caminar hacia la salida de ESCOM; nunca se explica.

**Otros.** El vagonero atiende las estaciones. Sin definir: la vendedora del Barrio, el de la papelería, los Irregulares de la Ciudad Perdida y los compañeros de la llamada final.

**Estado.** Hecho: el Eterno en `celda_3`, con su tira de animación y dos conversaciones. Previsto: todo lo demás. El arte de la protagonista mujer no existe.

## El mundo

El juego va de abajo hacia arriba. La Celda baja una vez a Las Raíces, el punto más bajo; desde ahí todo sube hasta ESCOM. Entre zonas hay salas de transición que mezclan las dos paletas y adelantan pistas de la siguiente.

| # | Zona | Qué es | Peligros y enemigos | Jefe y premio | Estado |
|---|---|---|---|---|---|
| 0 | La Celda | Sótano donde te encierran. Tutorial de movimiento | Varillas, cables, aspas | Sin jefe. La Pluma | Hecho |
| 1 | Las Raíces | Cavernas con raíces, hongos que brillan y cosas caídas hace décadas | Cucaracha, Polilla, Hongo escupidor, raíces con espinas | Sin jefe. Impulso, con un objeto | Previsto |
| 2 | Los Drenajes | Túneles inundados, luz por rejillas | Ajolote, Caracol de tubería, enjambre de moscos, aguas negras, vapor | Ajolote Gigante. Salto en pared | Previsto |
| 3 | El Barrio Otaku | Mercado subterráneo de neón, pueblo central, con centro seguro y Callejones peligrosos | Gato de la suerte, máquina de cápsulas con patas, figura de colección, cables de neón | La Idol del Barrio, al ritmo de la música. Doble salto | Previsto |
| 4 | La Ciudad Perdida | Ciudad melancólica de quienes no se titularon; prototipos abandonados | Robot seguidor de línea, dron casero, brazo robótico, Desvelado, engranes, pozo del olvido | Mini jefe: Ventanilla de Control Escolar. Jefe: El Perdido. Caída en picada | Previsto |
| 5 | El Metro | Metro fantasma, andenes vacíos | Vagonero fantasma, torniquete, ratas, barras electrificadas, el tren que pasa | Mini jefe: La Hora Pico. Jefe: El Último Tren. Impulso fantasma; nadar, escondido | Previsto |
| 6 | El Estacionamiento | Primera luz de día; llega la llamada | Sin enemigos | Sin jefe | Previsto |
| — | ESCOM y el salón | Recorrido y pelea final | Sin enemigos, hasta el salón | Los tres sinodales | Previsto |

Las zonas usan enemigos con referencia real reconocible, para que el arte salga consistente. Cada una trae 3 enemigos comunes y un peligro; el jefe da habilidad y el mini jefe, amuleto.

**Las Raíces.** La Cucaracha camina, se entierra y sale debajo de ti, con polvo de aviso. La Polilla revolotea, se queda quieta y embiste. El Hongo escupidor es fijo, lanza esporas en arco y se cierra al golpearlo. La zona enseña el combate y la curación.

**Los jefes tardíos.** Ajolote Gigante: salta desde la fosa; luego se le arrancan las branquias, que vuelven a crecer si tardas; al final inunda la arena. El Perdido: pilota un robot hecho con trabajos abandonados, suelta drones y termina a pie. El Último Tren: embiste, azota el andén y te persigue por el túnel hasta que escapas rompiendo una rejilla.

## Progresión

| Habilidad | Se obtiene en | Estado en código |
|---|---|---|
| La Pluma (arma) | La Celda | Hecho, en la campaña |
| Impulso | Las Raíces | Hecho en el núcleo; sin colocar |
| Salto en pared | Los Drenajes | Hecho en el núcleo; sin colocar |
| Doble salto | El Barrio Otaku | Hecho en el núcleo; sin colocar |
| Caída en picada | La Ciudad Perdida | Hecho en el núcleo; sin colocar |
| Impulso fantasma | El Metro | Previsto; no está en `nucleo/habilidades.gd` |
| Nadar en aguas negras | El Metro | Previsto; no está en `nucleo/habilidades.gd` |
| La bola (proyectil) | Por decidir | Hecho en el núcleo; lugar y sentido por decidir |
| Pluma de mapa | El Eterno en raices_3, junto con el mapa raices | Hecho en el núcleo; entrega sin colocar |

**Uso obligado.** El tramo donde se obtiene una habilidad no tiene salida que no la requiera: la geometría enseña, sin texto. Es el espejo de los secretos visibles e inalcanzables del inicio.

**Regresos.** Cada habilidad abre algo en zonas anteriores: fragmentos de vida con impulso, salto en pared y nadar; tres cartuchos de tinta con doble salto, caída en picada e impulso fantasma; la parte secreta del Barrio, y el protocolo del Eterno. Nada de esto está colocado.

**Peligros.** Dos tipos: fijos (espinas, varillas, ácido, vacío), que quitan vida y regresan al último punto seguro; y que se mueven (sierras, trampas), que golpean como un enemigo y no mueven de lugar. Hecho: el parámetro `peligro` de `nucleo/dano_contacto.gd`.

**Daño previsto.** Zona 1, todo quita 1. Zona 2, el jefe quita 2. Zona 3, algunos enemigos quitan 2. Zona 5, todo quita 2. Golpe cargado final, 3. Hecho: el daño es un dato de cada pieza y de cada ficha.

## Sistemas

| Sistema | Diseño | Estado en código |
|---|---|---|
| Arma | La pluma con que el Eterno nunca firmó se vuelve katana al sostenerla; al final vuelve a ser pluma | Hecho el arma. Mejoras en la papelería, por PejeCoins y cartuchos: previsto |
| Vidas | 4 al empezar; más con fragmentos | Hecho el valor y la recompensa `VIDA_MAXIMA`; sin fragmentos en la primera versión |
| Inspiración | Cada golpe llena un bloque; curar 1 vida cuesta 3 bloques; capacidad de 3 a 9 con módulos de RAM | Hecho: 11 puntos por bloque, 33 por curación, tope 99 |
| Amuletos | 10, comprados o encontrados; carga de 3 a 11; cuestan de 1 a 3 | Hecho el sistema, con 4 efectos. En el catálogo, solo Patas de Cucaracha. Se ponen sentado en un banco. En la primera versión hay 2: Patas y Caparazón de Cucaracha |
| Útiles | 5, en 4 cupos, sin gastar carga: siempre sobra uno | Hecho con 1 ranura y solo la Brújula. Los 4 cupos están en un plan por aprobar (`planes/activos/nucleo-menus-pausa.md`) |
| Muerte | Sin pantalla de muerte. Reapareces en el banco; tus PejeCoins quedan en una mochila | Hecho. La mochila queda en el último punto seguro |
| Reto de la mochila | Una pregunta con examen | Hecho el sistema: una sola oportunidad; sin la meta, lo perdido se va. Faltan las preguntas (tarjeta #28) |
| Enemigos que vuelven | Débiles al volver a entrar; fuertes al descansar | Hecho (`reaparicion` de `nucleo/ficha_enemigo.gd`) |
| Retos de pregunta | Preguntas sencillas de programación o matemáticas que dan vida o monedas | Hecho el sistema; sin colocar |
| Bancos | Mesas de ESCOM; guardar no abre recuadro | Hecho |
| Viaje rápido | La Línea Fantasma: una estación por zona, atendida por el vagonero, con fundido a negro | Hecho el sistema, con pago único opcional; sin estación en la primera versión |
| Tienda | La vendedora del Barrio: fragmentos, mejora de carga, coleccionable | Hecho el sistema; sin colocar. En la primera versión, la tienda de `raices_3` vende la brújula |
| Pachislot | Tragamonedas de PejeCoins, sin dinero real, con límite por descanso | Previsto; no hay código |
| Mapa | Se descubre al andar; el Eterno da o vende los mapas | Hecho el sistema; sin colocar |
| Jefes | 12 peleas con fases, aviso y cierre de arena | Hecho `nucleo/arena_jefe.gd` y fases; sin jefes en la campaña |

**Amuletos previstos.** Patas de Cucaracha (más rapidez), Caparazón de Cucaracha (más invulnerabilidad), Pase Preferente (ataque más rápido), Corriendo a Clase (impulso mejor), Caché (Inspiración extra), Compilación rápida (curar en la mitad de tiempo), Compilación incremental (curar más barato), Poder de la Amistad (más daño con 1 vida), Tinta Extra (más alcance) y Camión-kun (revives una vez por descanso). Sus íconos entran como PNG sueltos; cada ficha llega con su efecto. Caché queda fuera de la primera versión y su ícono no se pinta.

**Útiles previstos.** Brújula, Gato de la Suerte (×1,5 PejeCoins), Log de Errores (Inspiración al recibir golpes), Cartera de Emergencia (conservas la mitad al morir) y Suela Antiderrapante (la mitad de empuje). Log, Cartera y Suela no se consiguen en la primera versión: se definen después de publicar.

## Controles

Táctil, teclado y control se traducen a las mismas acciones con nombre. En el teléfono, un joystick invisible que aparece donde tocas y botones que el jugador puede mover y escalar. El botón de curar es también el de poderes: mantener cura, tocar lanza la bola, abajo más curar en el aire da la caída en picada. Las habilidades nuevas no agregan botones. Hecho: `docs/ajustes-y-entrada.md`.

## Principios

- El núcleo no se toca para agregar contenido: zonas, enemigos y diálogos son datos.
- Cada zona se puede jugar sola dando las habilidades previas.
- Los controles se enseñan con dibujos en gis en pizarrones, casi sin texto.
- Todo debe correr en un teléfono de gama baja; hay un modo de recursos bajos.
- Cada número de balance vive en una ficha, para ajustarlo sin programar.

## Primera versión

Entran: inicio con nombre, cinemáticas, La Celda y Las Raíces completas sin jefe, impulso, Pluma y dos amuletos, vidas, curación, bancos, mochila con reto, tienda de PejeCoins, el Eterno, controles táctiles y zona de pruebas. Se aplazan: las zonas restantes y el final, las demás habilidades, el pachislot, las mejoras de la Pluma, la Línea Fantasma y la música completa. La lista vigente está en `docs/idea.md`.

## Diferencias con el diseño original

| Tema | Diseño original | Lo que rige |
|---|---|---|
| Jefes de Las Raíces | Reina Cucaracha y mini jefe | Sin jefes, por decisión del 1-nov-2026 |
| Fallar el reto de la mochila | Recuperar la mitad | Se pierde todo: una sola oportunidad (17-oct-2026) |
| Reto de la mochila | Una pregunta con examen | Tres preguntas por intento; se recupera con al menos dos aciertos |
| Curación | Con café | Con Inspiración |
| Menú | Continuar y Nueva partida | Jugar y cuatro ranuras |
| Modos de recursos | Bajo, Medio y Alto | Automático, Bajo y Alto |
| Zona de pruebas | Fuera del paquete publicado | Viaja en él, oculta tras el modo desarrollador |

## Pendiente de definir

Números de precios, parte secreta del Barrio, NPC sin definir, qué es la bola en el mundo, moneda definitiva (PejeCoins es provisional en el diseño, aunque el código ya usa ese nombre) y texto de la pantalla de cierre de Las Raíces (decisión 13).
