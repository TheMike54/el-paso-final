# La muerte del jugador parecía un atorón

- **Síntoma**: en el teléfono, quedarse sobre el bloque rojo de la sala de combate dejaba al jugador sin poder
  moverse ni saltar, sin ninguna señal en pantalla.
- **Causa**: no era un atorón. Cada golpe quitaba una de las cuatro vidas y al cuarto el jugador moría
  (`muerto = true`), que lo deja sin responder. No había contador de vidas, ni color de muerte, ni reaparición:
  volver al banco se había dejado para cuando existan los bancos.
- **Arreglo**: el jugador muerto se pinta oscuro y, 1,5 s después, la sala recarga su escena y lo hace reaparecer
  en `Entrada` con las vidas llenas (`nucleo/sala.gd`). Con bancos, reaparecerá en el último banco.
- **Guion que lo cubre**: `herramientas/guiones/nucleo/jugador_reaparecer.guion`. Sin recargar la sala da
  `x obtenido=999.93` y `muerto obtenido=true`.
