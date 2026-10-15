CERRADO

# Herramientas: poda de salas y guiones de prueba

Propuesto el 07-oct-2026 tras inventariar 24 escenas de `herramientas/salas/`, 69 guiones y 29 casos manuales;
aprobado por la persona y aplicado el 07-oct-2026. El análisis completo, sala por sala y guion por guion, quedó
fuera del repo.

## Qué se decidió

- Salas: ninguna se quita. Las que parecían sin uso las usa otra sala (`sala_capas` hereda de `sala_camara`;
  `sala_enemigos_banco` y `sala_puerta_b` son destino de puertas).
- Guiones: se fusionan los que tienen exactamente las mismas entradas, la misma escena y el mismo `fin`; el
  `.esperado` que queda suma las líneas del que se va, con su comentario.

| Queda | Se fusionó en él |
|---|---|
| `nucleo/habilidad_caida_en_picada` | `nucleo/habilidad_caida_en_picada_onda` |
| `nucleo/jugador_curar` | `nucleo/vibracion` e `interfaz/curacion` |
| `nucleo/banco_sentarse` | `nucleo/vibracion_banco` e `interfaz/aviso_guardado` |
| `nucleo/estado_partida` | `interfaz/al_entrar` |

- No se fusionan los que solo parecen repetidos (picada, caída, temblor): tienen otro `fin` u otras entradas y
  cada uno falla por una causa distinta; juntarlos pediría leer el estado en varios cuadros.

## Qué se verificó

- En una copia, con los originales borrados, cada fusionado pasa y falla por cada causa de los que absorbió: sin la
  onda o sin la invulnerabilidad de la picada; si curarse no vibra o la interfaz solo escucha el daño; si descansar
  no vibra o guardar no avisa; si la interfaz no lee `Partida` al crearse.
- Corrida completa antes y después: 75 guiones antes de la poda y 69 después, todos `GUION OK`.
- `nucleo/funciones.json` (`vibracion`) e `interfaz/funciones.json` (`vidas-en-pantalla`, `aviso-partida-guardada`)
  apuntan su `comprobacion` al guion fusionado; ningún `"pasa"` cambió. `docs/pruebas.md` ya no lista los seis.
