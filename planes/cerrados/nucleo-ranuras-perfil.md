CERRADO

# Núcleo: selección de perfil con 4 ranuras

La persona lo pidió el 12-oct-2026 tras ver la selección de perfil de Silksong y aprobó la propuesta el
13-oct-2026 con las opciones recomendadas. Es una funcionalidad de guardado: pasa por el `revisor`.

## Decisiones (13-oct-2026)

- El menú principal deja «Nueva partida» y «Continuar» y muestra «Jugar», que abre 4 ranuras
  (`user://partida_1.json` a `partida_4.json`). La vacía dice «Nueva partida» y empieza en ella (se escribe al
  crearla); la ocupada muestra ubicación, vidas máximas y tiempo jugado y continúa en ella.
- El tiempo jugado ya existía (`Partida.tiempo_jugado`, solo dentro de una `Sala`): el formato del guardado no
  cambia y `Guardado.VERSION` sigue en 3.
- Ubicación: la sala del banco; sin banco, la última sala visitada; sin ninguna, «Inicio».
- Las 4 fichas en una fila cuando caben (todas las vistas de 1280 a 1760) y en 2×2 si el área segura recorta mucho.
- «Borrar» siempre visible en la ficha ocupada, dañada o de otra versión, con confirmación. Borra también la copia.
- Restaurar: al entrar a una ranura válida se copia a `.bak`; «Restaurar» vuelve la ranura al inicio de esa sesión,
  con confirmación. Solo aparece si hay copia.
- Toque propio: «rastro de pasos», una fila de cuadritos por habilidad, jefe y coleccionable obtenidos.
- La partida de antes de las ranuras (`user://partida.json`) pasa una vez a la ranura 1 al abrir el menú y nunca
  pisa una ranura 1 que exista. `Guardado.RUTA` se queda como esa ruta heredada y como centinela de `Banco`.
- «Borrar partida» sale de Configuración: ahora se borra por ranura.
- Todo camino que entra a una ranura fija `Partida.ruta_guardado`; si no, el autoguardado iría a
  `prueba_partida.json`. La pantalla deja libre la franja del aviso de pocos toques, como el menú.

## Hitos

1. `Guardado`: `ruta_ranura`, `migrar`, `respaldar`, `restaurar`, `tiene_respaldo`; `borrar` quita la copia.
2. `nucleo/ranuras.gd` (pantalla armada en código) y el menú con «Jugar»; Configuración sin «Borrar partida».
3. `prueba_ranuras.gd` con su guion: rutas independientes, migración, respaldo y restaurar, ficha (texto,
   ubicación, tiempo), borrar con confirmación, Atrás un nivel a la vez y que la ranura fija `ruta_guardado`.
4. `validar.ps1` y todos los guiones; medición en ventana de 1280×720, 1440×720 y 1760×720, con y sin el aviso.
5. `revisor`; documentos (`docs/contrato.md` «Guardado» y «Menú», `docs/pruebas.md`); prueba en el S50.

## Cierre (13-oct-2026)

- Hitos 1 a 3 hechos: `prueba_ranuras.gd` con 44 casos (`ranuras.guion`); `menu.guion` y `menu_configuracion.guion`
  al día. `validar.ps1` y los 120 guiones en verde.
- Hito 4: capturas en ventana de 1280, 1440 y 1760 de ancho, con y sin aviso: las 4 fichas en una fila y por encima del
  aviso.
- Hito 5: dos pasadas del `revisor`. La primera dio 7 fallos (ranura dañada que se pisaba, copia sin temporal, copia
  dañada que contaba como respaldo, casos que faltaban y documentos); la segunda, 3 de documentos (filas de
  `docs/pruebas.md` que nombraban «Borrar partida» y «Continuar», y el conteo de casos que cambió el plan de audio).
  Todo corregido.
- En el S50 (adb, 13-oct-2026): las 4 fichas en una fila encima del aviso. Falta la prueba de la persona
  (`ranuras-telefono`) y el S20.
- Para la persona: la entrada `configuracion-opciones` todavía nombra «Borrar partida» (Claude no reescribe entradas).
