CERRADO

# Sensación del jugador: valores y curar como en Hollow Knight

Propuestas de la comparación con Hollow Knight y Silksong (14-oct-2026), probadas por la persona en el Galaxy S21 con
un APK de prueba armado fuera del repo (15-oct-2026) y aceptadas, con el coyote en 4 ticks en lugar de 5 para
que no quede tan fácil. Rama: `feature/nucleo-mando-menus`. Toca física y movimiento del jugador: `revisor` al final.

## H1. Valores

| Propiedad | Antes | Después | Archivo |
|---|---|---|---|
| `ticks_hit_stop` | 4 | 10 | `nucleo/jugador.gd` |
| `altura_salto` | 200 | 230 | `nucleo/jugador.gd` |
| `ticks_coyote` | 3 | 4 | `nucleo/jugador.gd` |
| `velocidad_retroceso` (enemigo golpeado) | 240 px/s × 6 ticks = 24 px | 600 px/s × 6 = 60 px | `nucleo/golpeable.gd` |

Las salas de prueba que ponen `velocidad_retroceso = 0` (muñecos fijos) no cambian.

## H2. Curar: soltar pronto devuelve la Inspiración

- Nueva propiedad exportada `ticks_devolver_curacion` = 27 (grupo «Curar»). En `_seguir_curando`, si se suelta
  `curar` con `ticks_curados < ticks_devolver_curacion`, `Partida.inspiracion` vuelve a `_inspiracion_al_empezar`
  (el valor exacto de antes de empezar: nunca más). Un golpe o dejar el suelo siguen perdiendo lo gastado.
- Guion nuevo `jugador_curar_soltar.guion`: soltar a los 10 ticks (vuelve entera) y a los 40 (se pierde lo
  gastado); en los dos la Inspiración final no pasa de la inicial y las vidas no suben.

## H3. Adelanto de cámara

- Nueva propiedad exportada `adelanto_camara` = 43 px: en `_objetivo_camara`, `objetivo.x += adelanto_camara *
  _mirando` antes del recorte a los límites (el suavizado en x ya existente hace el paso suave al voltear).
- Revisar `_colocar_camara` al entrar y al reaparecer (incluye el adelanto desde el primer tick).

## H4. Comprobación y documentos

- `validar.ps1` y todos los guiones de `herramientas/guiones/nucleo/`. Los `.esperado` que cambien por las cifras
  nuevas (alturas de salto, posiciones de cámara, tiempos del congelado, distancia del empuje) se actualizan
  revisando cada diferencia: que la explique uno de estos cambios y nada más.
- `jugador_coyote.guion`: que salte en el tick 4 tras la orilla y no en el 5.
- `docs/jugador.md`: la tabla con los valores nuevos y su fuente (coyote: Silksong 4 pasos ≈ 0,08 s, ajustado a
  4 ticks por la persona); la regla de curar; el adelanto de cámara. `nucleo/funciones.json`: el texto de
  `jugador-curar` no se reescribe; si hace falta, entrada nueva `jugador-curar-soltar` con su guion.
- `revisor` (física y movimiento del jugador), luego bloque de commit.
