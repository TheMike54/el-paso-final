# Vidas o monedas negativas en un archivo pasaban como partida válida

**Síntoma.** Un archivo con `vidas_maximas` en 0 o negativo, `monedas` o `tiempo_jugado` negativos, o una mochila con `monto` negativo daba `VALIDA` (reproducido el 1-nov-2026 en `prueba_guardado`): se entraba al juego con esos valores.

**Causa.** `Guardado.cargar` solo revisaba que cada campo existiera y tuviera su tipo, y `Partida.desde_diccionario` confía en lo que `cargar` dio por válido.

**Arreglo.** `Guardado.MINIMOS` da el mínimo de cada número y `cargar` da `DANADA` por debajo de él o con un `monto` negativo. `carga_maxima` e `inspiracion_maxima` no entran: sus setters ya los recortan al rango.

**Guion.** `nucleo/guardado`, casos «vidas_maximas en 0.0 da DANADA», «vidas_maximas en -2.0 da DANADA», «monedas en -1.0 da DANADA», «tiempo_jugado en -0.5 da DANADA» y «mochila con monto negativo da DANADA».
