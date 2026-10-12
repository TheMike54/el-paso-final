REEMPLAZADO POR nucleo-cierre-antes-de-la-sala.md

# Núcleo: el suelo frágil roto se queda roto y se guarda

Decidido por la persona el 06-oct-2026 («se queda roto y se guarda») y pedido otra vez el 07-oct-2026. Toca el
guardado: plan aprobado por la persona y `revisor` antes de cerrar. Plan por aprobar: no se programa antes.

## 1. Lo que hay (leído el 07-oct-2026)

- `nucleo/suelo_fragil.gd`: `romper()` lo quita (`queue_free`); al volver a la sala reaparece. Sin id.
- Enemigos fuertes, el modelo a seguir: `@export var id` único en su sala, clave `"<escena de la sala>#<id>"`,
  `push_error` en `_ready` si falta el id (hace fallar validador y guiones), y la lista en `Partida`.
- `nucleo/guardado.gd`: versión 2, esquema `banco`, `sala`, `vidas_maximas`, `habilidades`; otra versión es
  `INCOMPATIBLE`, sin migración. Solo se guarda al descansar en un banco (`nucleo/banco.gd`).
- Único uso: `herramientas/salas/sala_picada.tscn`.

## 2. Propuesta

| Qué | Cómo |
|---|---|
| ID estable | `SueloFragil` gana `@export var id: StringName`, único en su sala; sin id, `push_error` en `_ready`, como `Enemigo`. Clave `"<escena de la sala>#<id>"` |
| Al romperse | `Partida.romper_suelo(clave)` lo anota en `Partida.suelos_rotos: Array[String]` |
| Al entrar a la sala | Si su clave está en la lista, el suelo se quita en `_ready` sin efectos (sin temblor ni vibración) |
| Morir y descansar | No lo reponen (como Hollow Knight: lo roto sigue roto). Solo Nueva partida vacía la lista |
| Guardado | Campo nuevo `suelos_rotos` (lista de texto) en el esquema; versión 3. Se escribe al descansar, como todo lo demás: si la app se cierra antes de descansar, el suelo vuelve, igual que una habilidad recién tomada |
| Continuar | `Partida.desde_diccionario` lee la lista |

## 3. Decisión: la versión 2 no se migra

Una partida de versión 2 queda `INCOMPATIBLE` y el menú dice «La partida guardada es de otra versión del juego»;
se empieza una nueva. Por qué: el juego no tiene jugadores; las únicas partidas de versión 2 son de prueba (el S20
de la persona). La regla del contrato («cualquier otra versión es incompatible, sin migración») sigue igual y ese
camino ya está probado (`prueba_guardado.gd`). Migrar costaría unas 10 líneas en `Guardado.cargar` (agregar
`suelos_rotos: []` a una versión 2) y un caso más de prueba; se hará cuando haya partidas que valga la pena
conservar.

## 4. Cómo se comprueba

- `prueba_guardado.gd` (escena `sala_guardado.tscn`): casos nuevos: una partida con `suelos_rotos` se guarda y se
  carga igual; una sin el campo o con otro tipo es `DANADA`; una de versión 2 es `INCOMPATIBLE`.
- Guion en `sala_picada`: romper el suelo, salir y volver a entrar (o morir y reaparecer): el suelo sigue roto y el
  jugador cae por el hueco. Falla sin la lista.
- `validar.ps1` y todos los guiones; `revisor` (guardado).

## 5. Archivos

`nucleo/suelo_fragil.gd`, `nucleo/partida.gd`, `nucleo/guardado.gd`, `herramientas/salas/sala_picada.tscn` (id del
suelo), `herramientas/salas/prueba_guardado.gd`, guion nuevo, `docs/contrato.md` (esquema versión 3 y la clave),
`docs/pruebas.md`. Entrada nueva en `nucleo/funciones.json` (la aprueba la persona): `suelo-fragil-guardado`.

## Avance

- [ ] Plan aprobado por la persona.
- [ ] Código, pruebas y guion.
- [ ] `revisor`.
