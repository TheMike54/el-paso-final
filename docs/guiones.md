# Guiones de entrada

Formato y reglas de los guiones (`herramientas/guiones/`). Es parte de `docs/contrato.md` (mismas reglas: se
actualiza en el mismo cambio que el puerto de depuración) y se separó por largo.

Un guion reproduce entradas por cuadro de física y compara el estado con un archivo de valores esperados. Lo
corre el puerto de depuración (`herramientas/puerto_depuracion.gd`), en local y en el CI:

```powershell
& $env:GODOT_PATH --headless --path . --fixed-fps 60 --quit-after 7200 -- --guion=herramientas/guiones/<bloque>/<nombre>.guion
```

- `<nombre>.guion`: líneas `<cuadro> <acción> press|release` y una línea `fin <cuadro>`. Los cuadros de las
  entradas van de 1 a `fin` menos 1.
- Línea opcional `escena <ruta res://>`: el puerto cambia a esa escena al empezar y el cuadro 1 es el primer
  cuadro de física con ella ya cargada. Sin la línea, el guion corre sobre la escena principal. Una ruta que no
  existe hace fallar el guion.
- Medido el 06-oct-2026: una acción que el jugador lee como sostenida (caminar) se nota en el estado del cuadro
  N+1; una que lee como recién presionada (`saltar`), en el del cuadro N+2. Los cuadros de un guion se miden con
  una corrida, no se calculan.
- `<nombre>.esperado`, junto al guion: líneas `<clave> <valor> [tolerancia]`.

  | Clave | Valor | Se compara |
  |---|---|---|
  | `x`, `y` | Posición global del nodo del grupo `jugador`, en píxeles | Con tolerancia; 0,5 si no se indica |
  | `en_suelo` | `true` o `false` | Exacto |
  | `escena` | Ruta `res://` de la escena actual | Exacto |
  | `valor <nodo> <propiedad>` | Valor de una propiedad de un nodo; admite subpropiedades (`position:x`) | Un número, con tolerancia (0,5 si no se indica); otro valor, por su texto |
  | `senal <nodo> <señal>` | Cuántas veces se emitió la señal desde el cuadro 1 | Exacto |

  `<nodo>` es una ruta relativa a la escena actual (`.` es su raíz, `Jugador` el jugador que crea la sala) o
  absoluta (`/root/<autoload>`). El puerto se conecta a las señales en el cuadro 1: un nodo o una señal que no
  existen hacen fallar el guion. Como las líneas se parten por espacios, `valor` no compara valores cuyo texto
  lleva espacios (un `Rect2`, un `Vector2`): se usa una subpropiedad (`position:x`).

- En los dos archivos se ignoran las líneas vacías y las que empiezan con `#`.
- El estado se lee al empezar el cuadro `fin`. El puerto sigue contando cuadros con el juego en pausa.
- `Input.action_press` del puerto cambia el estado de la acción pero no genera un evento: lo que debe responder a
  un guion lee la acción (`Input.is_action_just_pressed`), no `_input` ni `_unhandled_input`.
- Resultado: una línea `GUION OK <ruta> cuadro=<n>` y salida 0, o `GUION FALLA <ruta>: <motivo>` y salida 1.
  Falla si el guion o su `.esperado` no existen, si una línea no es válida, si una acción no está en el
  `InputMap` o si el estado no coincide.
- Un guion comprueba lo que importa (llegó, está en el suelo, cambió de sala) con tolerancia; no todos los
  decimales.
