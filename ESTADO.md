# Estado (se sobrescribe; ver `CLAUDE.md`)

## Ahora (25-oct-2026)

- **#6 fusionado** el 24-oct (`ea7bfd6`). Sus fallos menores y observaciones del QA van en este PR (`nucleo-arreglos-qa-6`).
- Rama `feature/contenido-celda`, desde `ea7bfd6` y sin PR: arreglos del QA del #6, La Celda, Avanzado, video del
  menú y cinemática, trazo del ataque, partida nueva con cinemática, el arte aprobado y los arreglos de la auditoría
  del 25-oct. Un solo PR.
- Fase actual: **implementación terminada** (tercera tanda del 25-oct); faltan pruebas manuales, commits y PR.
- `export_presets.cfg`: «Publicacion» y «Desarrollo» (32 y 64 bits, con los `.mp4`, sin los `.ogv`, con el ícono),
  puestos a mano en esta rama (decisión 1b): `chore/android-export` sobra (H23 de la auditoría resuelto aquí).
- Ruleset `main`: solo por PR, 1 aprobación, `validar` en verde, Squash and merge. Un push nuevo quita la aprobación.
- Al 25-oct (tras los efectos): `validar.ps1` `archivos=288 fallos=0`; `correr-guiones.ps1` `RESUMEN total=166 OK=166 MALOS=0`.

## Decidido el 25-oct

- Video sin plugin: `JavaClassWrapper` y `ExternalTexture`, H.264 a 1080 copiado a `user://video/`. Theora 480p solo
  en la PC y los guiones; en el teléfono, si falla, imagen fija en el menú y la cinemática pasa a La Celda. Si el
  video se traba (sin avanzar 5 s) o avisa un error a mitad, también termina. APK de desarrollo: 96 MB.
- Partida nueva como Hollow Knight: la ranura vacía va a la cinemática y a La Celda sin escribir nada; el archivo nace
  con el primer guardado. Continuar sin banco lleva a La Celda. La caja gris se quitó.
- `posicion_mapa`: cada zona en su franja del plano (La Celda en (0, 1440)); el validador falla si se enciman.
- Arte aprobado integrado: ícono de la app, mochila perdida flotando, marcadores del mapa (máscara y mochila),
  PejeCoin y disquete que respira (`FigurasVector`). El Eterno no entra en este PR.
- El ataque (jugador y enemigos) se ve solo con el trazo blanco; el área, con «Ver hitbox». Zona de pruebas en negro.
- Auditoría: arreglado lo factible (plan `nucleo-arreglos-auditoria`, con lo que no se hace y por qué). Los textos
  propuestos a los `CLAUDE.md` y `funciones.json`, aprobados y aplicados.
- Avanzado (maqueta aprobada): Recursos, FPS, Luces 2D (bloqueadas en bajo; en alto, encendidas), Niebla (apagada),
  Mostrar FPS; con el modo desarrollador, Pruebas y Ver hitbox. Menús a 60 FPS como máximo.

## Pruebas manuales pendientes

- **25-oct, S50 y S21:** pasa todo lo pedido, los efectos del jugador (M1 sin tirón) y, en el S21, La Celda sin la
  línea negra y la cinemática completa. Se quedan así el disquete y la carga blanca de Android.
- **QA:** Vic repite la fila 7 sin captura; Ian, la 7.4, la 1.2 y la 1.3. M1, M2 y Recursos auto en el S21 (elige alto, 120 FPS) hechos.
- **Esperan hardware o firma:** `menu-desarrollo`, `paquete-publicacion` y `recursos-medicion-publicacion`
  (keystore). `sonidos-telefono` falla hasta que el golpe recibido tenga su propio sonido.

## Planes activos

- `contenido-celda` (v2), `nucleo-ajustes-avanzados`, `nucleo-video-hardware`, `nucleo-trazo-ataque`,
  `nucleo-arreglos-auditoria`, `nucleo-efectos-jugador`: hechos; cada uno dice lo medido y lo que falta de la persona. Se cierran con el PR.
- `nucleo-arreglos-qa-6`: F1, F2, O3, O5, M1 y M2 hechos. Falta la prueba del QA.
- `nucleo-auditoria-codigo`: pasos 1 a 12 cerrados; el 13 (H17-H19) diferido por la persona el 18-oct.

## Conocido, sin arreglar

- Dormido en el banco, el jugador animado se ve sentado en el aire.
- En el teclado de la PC, Espacio es `ui_accept` y `atacar`: cerrar un menú con Espacio también ataca.
- Guiones intermitentes por `--quit-after`, sin causa: `habilidad_caida_en_picada_desde_suelo` y `sala_puerta_b_pared`.
- S50 con Recursos en alto elegido a mano (luces 2D): ~10,8 FPS en La Celda; en automático (bajo), 59,4.
- Un ataque enemigo que no se puede parar no se ve sin «Ver hitbox» hasta que el enemigo tenga arte.

## Decisiones abiertas (la persona)

- 25-oct, tras la prueba: hueco de Enemigos móviles arreglado; personaje oculto (`NuevaPartida.ELEGIR_PERSONAJE`). Falta verlo.
- Copia de pruebas rehecha desde esta rama el 25-oct; ahí se arman las salas 2 a 4 de La Celda (Eterno y banco en
  la 3, sin ataque en la 1 y la 2, la 4 lleva a Las Raíces).
- Borrar `chore/android-export`. Sin decidir: sonidos, keystore, color del foco. Tras la v1 base: sala de música,
  NPC al tocarlo, sonido de daño.
