CERRADO

# Núcleo: equipar amuletos solo sentado en el banco (base mínima)

La persona lo pidió el 12-oct-2026 (en Hollow Knight los amuletos solo se cambian sentado en un banco) y aprobó el
13-oct-2026 la base mínima recomendada: la regla y la forma de equipar, sin carga ni efectos nuevos. Hoy hay un
solo amuleto con efecto (la brújula, que lee el mapa); la carga y la suma de efectos esperan a tener tres casos.

## Decisiones (13-oct-2026)

- `Partida` gana `equipar(id)`, `desequipar(id)`, `puede_equipar(id)` y `esta_equipado(id)`. Equipar exige que el
  amuleto se tenga, que no esté puesto y que haya lugar: `MAX_EQUIPADOS` (provisional, 3) en lugar de carga.
  Devuelven `false` si no se puede. Equipar y quitar autoguardan. El guardado no cambia (ya tiene las dos listas).
- La regla «solo sentado» vive en la pantalla: consulta `Jugador.descansando`. De pie, la pantalla solo muestra.
  `Partida` no conoce al jugador y el bus de eventos no cambia.
- Pantalla `nucleo/pantalla_amuletos.gd` («Amuletos», gris, sin arte), encima del juego como el mapa (juego
  detenido, pausa bloqueada). Se abre con la acción `mochila` y con un botón «Amuletos» en la pausa (el táctil no
  tiene botón de mochila). No se llama «mochila»: `Partida.mochila` es lo perdido al morir.
- Lo que hoy escribe la lista directo (`interruptor_brujula.gd`, `prueba_mapa.gd`) pasa por `equipar()` y
  `desequipar()`.

## Hitos

1. API en `Partida` y su prueba (`prueba_amuletos.gd`: tenido, repetido, lugar, quitar, guardar y cargar).
2. Pantalla y botón en la pausa; guion: de pie solo se consulta, sentado se pone y se quita.
3. `validar.ps1` y todos los guiones; documentos (`docs/contrato.md` «Partida» y «Pantalla», `docs/pruebas.md`).
4. Prueba en el teléfono: sala del banco, sentarse, poner y quitar la brújula y ver el marcador en el mapa.

## Cierre (13-oct-2026)

- Hitos 1 a 3 hechos: `Partida` con `MAX_EQUIPADOS`, `puede_equipar`, `equipar`, `desequipar` y `esta_equipado`;
  `nucleo/pantalla_amuletos.gd` creada por cada sala; botón «Amuletos» en la pausa; el interruptor de la brújula y
  `prueba_mapa.gd` pasan por la API. `amuletos.guion` con 22 casos; `validar.ps1` y los 121 guiones en verde.
- `revisor`: el código cumple el plan; 2 fallos corregidos: el contrato y `controles_tactiles.gd` decían que
  `mochila` no hacía nada (ahora: el táctil entra por la pausa a propósito), y ningún caso usaba las acciones
  `mochila` y `pausa` (4 casos nuevos, con una mutación comprobada: sin abrir con `mochila`, 3 fallos).
- Capturas en ventana de 1280: de pie, sentado y la pausa con su botón. En el S50 (adb): «Amuletos» desde la pausa
  y Atrás de vuelta con el foco en «Amuletos». El banco con la brújula y el mapa quedan para la persona
  (`amuletos-telefono`, fila «Amuletos en el banco» de `docs/pruebas.md`).
- Provisional: el nombre en pantalla es el id con mayúsculas («Brujula», sin acento) hasta que haya fichas de amuleto.
