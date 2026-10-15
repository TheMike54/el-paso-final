CERRADO

# Núcleo: reglas pendientes de la auditoría Hollow Knight

Lo decidido por la persona en la auditoría (`planes/cerrados/nucleo-auditoria-hollow-knight.md`) y todavía sin
programar: el 07-oct-2026, filas 5, 6 y plataformas sólidas; el 11-oct-2026, fila 15 como Hollow Knight y fila 10
sin cambios. Aprobado el 11-oct-2026, con sus dos entradas. Rama `feature/nucleo-reglas-pendientes`, que sale de
`feature/nucleo-configuracion-menu` (`b096585`).

## 1. Lo que hay (leído el 11-oct-2026)

- Peligros (`nucleo/jugador.gd`, `recibir_dano(..., peligro)`): quitan una vida y devuelven al último suelo firme
  (`_volver_al_punto_seguro`, el más viejo de los últimos 15 puntos con 6 ticks en el suelo), con 20 ticks quieto.
  Invulnerable, un peligro no quita vida pero igual lo saca de ahí. Salir por abajo de la sala cuenta como peligro.
- Enemigos fuertes (`nucleo/partida.gd`): `enemigos_vencidos` se vacía solo al descansar (`_al_descansar`); al morir
  (`Eventos.jugador_muerto`), no.
- Plataformas atravesables: las 5 de `herramientas/salas/sala_camara.tscn` (`one_way_collision`); ninguna más.
- Cola de salto (fila 10): 3 ticks desde la pulsación, sin pedir el botón mantenido. Se queda así (persona,
  11-oct-2026).

## 2. Propuesta

| # | Regla | Cómo | Archivos |
|---|---|---|---|
| 1 | Anti-bucle (fila 5, como Silksong) | Si un peligro toca al jugador antes de 30 ticks (0,5 s) de haber vuelto de otro peligro, va al punto por el que entró a la sala (su puerta de llegada o la `Entrada`), sin perder vida | `nucleo/jugador.gd` (contador desde la última vuelta, `ticks_anti_bucle` exportado); `nucleo/sala.gd` le pasa al jugador su punto de llegada al crearlo |
| 2 | Los peligros quitan vida aunque el jugador sea invulnerable (fila 15) | Quitar la excepción de `recibir_dano` para `peligro`; el anti-bucle es lo único que evita la vida | `nucleo/jugador.gd` |
| 3 | Morir repone a los fuertes (fila 6) | `Partida` también vacía `enemigos_vencidos` con `Eventos.jugador_muerto`, como al descansar | `nucleo/partida.gd` |
| 4 | Plataformas todas sólidas | Las 5 de `sala_camara` pasan a sólidas, y la regla queda en el contrato: el núcleo no ofrece plataformas atravesables | `herramientas/salas/sala_camara.tscn`, `docs/contrato.md` |

El 1 y el 2 van juntos: sin el anti-bucle, la fila 15 haría perder vidas en un bucle de peligros (la observación del
`revisor` del 07-oct-2026 sobre un punto seguro bajo los límites queda cubierta por el anti-bucle).

## 3. Cómo se comprueba

- Guion por regla, en salas de `herramientas/salas/` (las que existan o una nueva):
  - anti-bucle: caer a un pincho, volver al punto seguro y tocar otro peligro antes de 0,5 s → aparece en la puerta
    de llegada con las mismas vidas; después de 0,5 s → vuelve al punto seguro y pierde una;
  - invulnerable: un peligro durante la invulnerabilidad de un golpe quita una vida;
  - fuertes: vencer a un fuerte, morir, y al reaparecer el fuerte está otra vez (sin descansar).
- Los guiones de hoy que dependan de la regla vieja (`jugador_peligro`, `boton_poderes_peligro`, `enemigo_descanso`,
  los de cámara en `sala_camara`) se revisan: si cambian porque la regla cambió a propósito, se actualiza su
  `.esperado` y se dice cuál.
- `revisor`: sí (física del jugador y contrato).
- Manual, en el teléfono: el caso «Aterrizaje duro sobre un peligro o un banco» y la sala de pared con la regla nueva;
  en la sala de cámara, que las plataformas ya no se atraviesan desde abajo.

Entradas nuevas para `nucleo/funciones.json` (las aprueba la persona):

- `peligro-anti-bucle`: «Un peligro que toca al jugador antes de 0,5 s de volver de otro lo lleva a su punto de
  llegada a la sala sin quitarle vida; los peligros quitan vida aunque el jugador sea invulnerable» ·
  comprobación: `herramientas/guiones/nucleo/jugador_peligro_anti_bucle.guion`.
- `fuertes-al-morir`: «Morir hace reaparecer a los enemigos fuertes vencidos, igual que descansar» · comprobación:
  `herramientas/guiones/nucleo/enemigo_al_morir.guion`.

Las plataformas sólidas no llevan entrada: es un cambio de una sala de prueba y del contrato.

## 4. También entra en el commit de esta rama (decidido el 11-oct-2026)

Cierres de documentos: plan de pantalla completa y auditoría a `planes/cerrados/`, `ESTADO.md`, `docs/pruebas.md`
(publicación sin la zona de pruebas, pared de `sala_puerta_b` en el S50), `herramientas/funciones.json`
(`etiqueta-qa-pending`), la precisión del modo desarrollador en su plan, y la regla de commits en `CLAUDE.md` y en la
skill `funcionalidad`.

## Avance

- [x] Plan aprobado por la persona, con las dos entradas nuevas de `funciones.json` (11-oct-2026).
- [x] Anti-bucle e invulnerable (`jugador_peligro_anti_bucle`: 11 de 11; `jugador_peligro_anti_bucle_contacto`, contacto
  real). Al probarlo con contacto real salió un fallo: el peligro avisaba dos veces tras el teletransporte
  (`docs/errores/2026-10-11-peligro-avisado-dos-veces.md`); ahora los peligros no cuentan mientras el jugador
  reaparece. El punto de llegada lo guarda el jugador al entrar (su posición en `_ready`): `sala.gd` no cambia.
- [x] Fuertes al morir (`enemigo_al_morir`: 3 de 3).
- [x] Plataformas sólidas: las 5 de `sala_camara`; ningún guion las usaba. `aterrizaje.guion`: un caso mandaba un
  peligro en el mismo tick de la reaparición, que ahora se ignora a propósito; se ajustó para mandarlo con control.
  78 de 78 guiones.
- [x] `revisor` (11-oct-2026): código aprobado; cuatro líneas de documentos corregidas después (picada en el contrato,
  fuertes en `ESTADO.md`, la prueba manual «Pinchos» y una nota del error).
- [x] Prueba en el teléfono (persona, 11-oct-2026, Senwa S50): pasan las cuatro reglas. En la sala de cámara el
  escalón más bajo tapaba el salto al pedestal: los escalones se separaron (huecos de 160 px) y lo cubre
  `camara_escalera.guion` (79 de 79). Pantalla completa, con `adb` en el S50: pasa.
- [x] Pinchos durante la invulnerabilidad (11-oct-2026): se propuso atravesarlos; la persona decidió dejarlos como
  Hollow Knight (su código, `HeroController.TakeDamage`, resta vida con pinchos aunque el Caballero sea invulnerable).
- [x] Picada sobre pinchos (11-oct-2026): la persona lo probó en Hollow Knight. Caer en Desolate Dive sobre pinchos
  cuenta como peligro, igual que caer sin picada: pantalla en negro y reaparece en el último punto seguro. Queda como
  hoy. Lo que falta, el fundido a negro al reaparecer, va aparte.
