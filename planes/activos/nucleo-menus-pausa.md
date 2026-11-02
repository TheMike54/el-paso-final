ACTIVO (escrito el 1-nov-2026; por aprobar, sin empezar)

# Menús de pausa según los mockups aprobados

Lleva al juego Inventario, Amuletos, Útiles y el cambio de página de la propuesta D. Los mockups mandan en cómo se ve y
se comporta; su HTML no se copia. Sus 10 reglas de UX son criterio de aceptación de cada pantalla.

## Decisiones cerradas (la persona, 1-nov-2026)

1. Una flecha a cada lado, a media altura, con zona de toque de 108×240 desde el borde, dentro del área segura y con su
   botón del control. Arriba, el título y los nombres de las vecinas, sin «‹ ›» y tocables.
2. Inventario: La Pluma con su katana, Azulitos y 6 habilidades con símbolo y detalle. Nombres escritos, no sacados del id.
3. Los símbolos de las habilidades se dibujan con código, de gis, iguales a los de los mockups.
4. Amuletos y Útiles: tocar solo elige; poner o quitar va en su botón. El detalle siempre a la derecha, y explica por
   qué algo no se puede poner.
5. Útiles: 4 cupos, solo poner o quitar, sin colores ni tipos. La mochila se dibuja con código, en línea de gis y sin relleno.
6. Son 5 útiles: Brújula, Gato de la Suerte (deja de ser amuleto), Log de Errores, Cartera de Emergencia y Suela Antiderrapante.
7. Entran los íconos aprobados de los 5 útiles y de Caparazón de Cucaracha. Los otros 8 amuletos conservan la forma de gis;
   su arte lo hace un integrante del equipo.

## Falta decidir (la persona)

| Tema | Propuesta |
|---|---|
| Amuletos que entran ahora | Patas, Caparazón y Caché, que no piden código. Los otros 7 van en un plan aparte, después de publicar |
| Costos | Caparazón 2, Caché 1. Los demás se deciden con su plan |
| Valores de esos dos | Caparazón `invulnerable_extra` 30 (0,5 s). Caché `inspiracion_extra` 6: el medio bloque no existe con enteros, y 5 no acorta la curación |
| Dónde se consiguen | Brújula: el Eterno, como dice el diseño. Suela: Las Raíces. Log: La Ciudad Perdida. Cartera: tienda del Barrio Otaku. Mientras esas zonas no existan, solo se prueban en la sala «Equipo» |
| Mecánicas nuevas | Ninguna en este plan: casi todas dependen de zonas o jefes que no existen. Van en su propio plan |
| Imagen de la katana | No tiene estado de aprobada y no estaba en la lista de arte: hace falta el visto bueno para que entre al repo |

## Choques con el código

1. **Bloques 57 y 58 sin correr.** Este plan toca archivos que esos bloques agregan (`docs/contrato.md`, `nucleo/partida.gd`,
   ESTADO y otros): si se empieza antes, el 58 se llevaría cambios de menús. Se corren primero. Rama propia:
   `feature/nucleo-menus-pausa`, con su propio PR.
2. **Log de Errores y las aspas.** `recibir_dano` no sabe de dónde viene el golpe, y las aspas son `DanoContacto` sin
   `peligro`: darían Inspiración. `DanoContacto` debe decir si viene de un enemigo.
3. **Gato de la Suerte.** `botin_factor` vive en `FichaAmuleto` y en `efectos_amuletos()`, y ningún amuleto del diseño lo usa.
   Se quita (ficha, suma, `amuleto_botin` de `equipo_prueba.tres`, sus pruebas y `docs/contrato.md`) y `enemigo.gd`
   multiplica por 1,5 con el útil puesto.
4. **Cartera de Emergencia.** Con 1 PejeCoin no hay mitades. La mochila se lleva el redondeo hacia arriba: siempre lleva
   algo, y `dejar_mochila` mantiene que un monto guardado sea mayor que 0. Morir sin monedas sigue sin crear mochila.
5. **Dos cosas llamadas mochila** (regla 6): la de los cupos y la que se pierde al morir, que también nombra la Cartera. En
   pantalla los útiles hablan de cupos («Cupos llenos: quita uno primero»), y la Cartera dice «la otra mitad se queda donde
   caíste». La clase nueva no puede llamarse `Mochila`: ya existe la pieza.
6. **En el juego no se consigue ningún útil ni amuleto.** Ni La Celda ni otra sala de `contenido/` los da; la Brújula tampoco
   se vende aún. Las páginas solo se llenan en la sala «Equipo», que tendrá que dar los 5 útiles y los amuletos.
7. **Las filas dejan de estar `disabled`,** porque ahora se tocan para leer. Sale `_al_tocar`, y los guiones que pulsan una
   fila para poner un amuleto cambian a propósito: `prueba_amuletos`, `prueba_utiles`, `prueba_efectos_amuletos`,
   `prueba_sala_equipo`, `prueba_marco`, `prueba_mapa` y sus `.esperado`.
8. **Medidas.** `Tema.CELDA` mide 420 y las filas del mockup, unas 336. `MARGEN_LATERAL` (64) cae bajo la flecha: el contenido
   empieza en área segura + 108. El mockup no probó 4:3 ni más de 2:1: con `aspect="expand"` hay que probarlos aquí.
9. **El reporte quedó atrás.** El texto de «puesto» está hoy en `nucleo/pantalla_utiles.gd:98`, no en la 129.
   Fallo 1: `Sala.nombre_de` ya da el nombre de la zona.
10. **No hay sonido de toque en los menús.** Regla 8 y hallazgo 11: la respuesta es visual (la selección cambia en el acto).
    El sonido necesita un archivo y queda fuera.
11. **Íconos.** Los recortes miden de 849 a 991 px y pesan cerca de 1 MB. Entran reducidos a 112 px, el tamaño de Patas,
    sin mipmaps, y se revisan a 56 px y en el detalle.

## Hallazgos del estudio de UX

| # | Resolución |
|---|---|
| 1 | Lo perdido, Mapas y Azulitos pierden el marco. Solo Arma y habilidades tienen marco y detalle; no hay que inventar textos |
| 2 | Un solo botón en el Mapa, con el nombre de lo que hace: «Ver todo» y «Ver zona» |
| 3 | Marca visible en la fila puesta, además del texto |
| 4 | Indicador fijo de que hay más abajo; filas con letra 28 y hasta 3 líneas |
| 5 | Inspiración siempre con número y bloques juntos, como en el mockup |
| 6 | El costo también en círculos |
| 7 | De pie, una línea fija: «Siéntate en un banco para cambiarlos» |
| 9 | Contorno oscuro en las flechas |
| 10 | El mensaje de cupos llenos dice que se toca un cupo para elegirlo |
| 8 y 12 | Sin cambios: 8 espera la prueba con personas; 12 no se salta la página vacía |

Con control: el foco elige, A en una fila lleva el foco a Poner o Quitar y A otra vez actúa. Las flechas no toman foco; las
manejan `pagina_anterior` y `pagina_siguiente`.

## Funcionalidades, en orden

Cada una entra al final de su `funciones.json`, con `validar.ps1`, su guion y su bloque de commit. Al cerrar, y antes del PR,
`correr-guiones.ps1` completo.

| # | Id | Qué | Archivos | Comprobación | `revisor` |
|---|---|---|---|---|---|
| 1 | `marco-flechas` | Flechas laterales, vecinas tocables, margen del contenido | `nucleo/marco_menus.gd`, `tema.gd` | `nucleo/marco`: toque, ciclo, área segura, sin pisar controles en 4 proporciones | No |
| 2 | `utiles-cuatro-cupos` | `MAX_UTILES` 4, clase `Utiles` con los ids, fichas e íconos, sala «Equipo» | `nucleo/partida.gd`, `ficha_util.gd`, `contenido/equipo.tres`, `herramientas/salas/`, `docs/uso-de-ia.md` | `nucleo/utiles`: el quinto no entra; se guarda y se lee | Sí, guardado |
| 3 | `utiles-efectos` | Gato, Log, Cartera y Suela; `DanoContacto` sabe si es de enemigo; sale `botin_factor` | `nucleo/enemigo.gd`, `jugador.gd`, `partida.gd`, `dano_contacto.gd`, `ficha_amuleto.gd` | Un caso por útil, con y sin él; aspas sin Inspiración; Cartera con 0, 1 y número impar | Sí, jugador y guardado |
| 4 | `detalle-de-menu` | Panel común: nombre, imagen, texto, motivo y botón. Tres páginas lo usan | Nuevo en `nucleo/`, `pagina_marco.gd` | Se prueba con las dos siguientes | No |
| 5 | `pagina-amuletos-d` | Lista en 2 columnas, carga en círculos, lo puesto arriba, elegir y actuar por separado | `nucleo/pantalla_amuletos.gd`, `contenido/equipo.tres` | `nucleo/amuletos`: tocar no cambia nada; explica por qué no cabe | No |
| 6 | `pagina-utiles-d` | Mochila de gis con 4 cupos tocables y lista | `nucleo/pantalla_utiles.gd`, clase nueva | `nucleo/utiles`: llena, vacía, de pie, quitar desde un cupo | No |
| 7 | `pagina-inventario-d` | Estado, Arma, Lo perdido, 6 símbolos con detalle, Mapas y Azulitos. Nombres escritos; ficha de habilidad | `nucleo/pagina_inventario.gd`, clase de símbolos y datos nuevos | Guion nuevo: nombre de zona en Lo perdido, sin ids, inicio vacío | No |
| 8 | `mapa-boton-vista` | Un solo botón de vista | `mapa/pantalla_mapa.gd` | `mapa`: dice la vista y alterna | No |
| 9 | Cierre | Documentos (`docs/interfaz.md`, `docs/contrato.md`, guía de amuletos y útiles, `docs/pruebas.md`), `revisor` del conjunto, APK en el S50 | | Batería completa y pruebas manuales | Sí |

Pruebas que solo puede hacer la persona: leer letra 28 en el teléfono; flechas cómodas y sin toques por error; cómo se ven
mochila, Inventario y Mapa; todo con el dedo y con el control. El S21 no está disponible, así que el S50 es la referencia.

Reparto: `jugador.gd`, `partida.gd`, guardado y contrato los escribe Claude; Sol puede construir la clase de símbolos y
los guiones en un worktree.

## Fuera de este plan

Los otros 7 amuletos, el arte de los 8 sin ícono, las mecánicas nuevas, el sonido de toque, mover Volver (hallazgo 8)
y dar útiles en salas de zonas que aún no existen.

## Avance

Sin empezar.
