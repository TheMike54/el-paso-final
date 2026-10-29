# El muro rompible y el portón no tenían dónde poner su sonido

- **Síntoma:** romper un muro rompible o abrir un portón nunca sonaba, y no había forma de que sonara: `FichaSonidos`
  no tenía campo donde poner el archivo. `Sonido` sí escuchaba `muro_roto` y `porton_abierto` y llamaba a
  `tocar(&"muro_roto")` y `tocar(&"porton")`, y el contrato decía que esos eventos suenan. No salía ningún aviso. Lo
  encontró la auditoría del código (P1), no una partida.
- **Causa:**
  - `FichaSonidos.efecto(evento)` hace `get(evento)`. Con un nombre que no es propiedad de la ficha, `get()` devuelve
    `null` en silencio, igual que con un campo vacío, y `tocar()` lo trataba como «sin efecto».
  - Los nombres de los eventos vivían solo en las llamadas a `tocar(&"...")`; nada los comparaba con los campos de la
    ficha. Al agregar el muro y el portón a `Sonido` no se agregaron sus campos.
- **Arreglo:**
  - `FichaSonidos` gana los campos `muro_roto` y `porton` (vacíos en la ficha de prueba: todavía no hay archivo) y
    `campos_de_efecto()`, que lista sus campos `AudioStream`.
  - `Sonido.EVENTOS` lista cada evento que `Sonido` toca.
  - `tocar()` avisa con `push_warning` si le llega un evento que no es campo de la ficha. Es un `WARNING`, no un
    `ERROR:`: no hace fallar `validar.ps1` ni los guiones.
- **Lo cubre:** `herramientas/guiones/nucleo/sonido.guion` (`prueba_sonido.gd`). Desde el 27-oct-2026 ya no hay
  `Sonido.EVENTOS` ni `campos_de_efecto()`: la prueba arma una ficha con todos los campos, emite cada señal que
  `Sonido` escucha y exige que toque su evento, así una conexión a un evento mal escrito falla.
