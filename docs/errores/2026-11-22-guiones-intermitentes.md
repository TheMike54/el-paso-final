# Guiones intermitentes: `habilidad_caida_en_picada_desde_suelo` y `sala_puerta_b_pared`

- **Síntoma:** los dos guiones fallaban a veces y pasaban otra vez sin ningún cambio. El único fallo con salida
  anotada es de `sala_puerta_b_pared`, en una corrida completa del 18-oct-2026: «sin GUION OK ni lineas de error: no
  termino antes de --quit-after» (`planes/cerrados/nucleo-auditoria-5-guardado.md`). Del de la picada no quedó la
  salida. Issue #56.
- **Causa:** no encontrada; no se reprodujo. Medido el 22-nov-2026, en la PC de desarrollo, con el árbol de la rama
  `fix/sprint-4-miguel`:
  - cada guion solo, 20 corridas seguidas como las corre `correr-guiones.ps1` (headless, `--fixed-fps 60`,
    `--quit-after 7200`): 20 de 20 en verde los dos;
  - lo mismo con la CPU cargada por un proceso que gira en vacío por cada núcleo lógico (20), para sacar lo que dependa
    del tiempo real: 20 de 20 los dos;
  - `correr-guiones.ps1` completo: `RESUMEN total=241 OK=241 MALOS=0`;
  - en GitHub Actions, ninguna de las últimas 100 corridas falló.

  Leído sin hallar la causa: el arranque del guion en `herramientas/puerto_depuracion.gd` (`_escena_lista` cambia de
  escena una vez y espera a que sea la actual; ni `nucleo/menu.gd` ni `nucleo/arranque.gd` cambian de escena solos) y
  lo que depende del reloj real en `nucleo/` (solo `Sala.cambio_pedido_ms`, que no decide nada, y el temporizador del
  video sin ventana).
- **Arreglo:** ninguno en el juego. `correr-guiones.ps1` pisaba `.godot/correr-guiones.log` con cada guion y de un fallo
  solo quedaban las 12 líneas impresas; ahora copia el log completo de cada guion que falla a
  `.godot/guiones-fallidos/<bloque>_<nombre>-<fecha>.log` e imprime la ruta. El próximo fallo de uno de los dos deja
  su salida entera para buscar la causa.
- **Lo cubre:** nada nuevo: los dos guiones siguen como estaban. La copia del log se comprobó con `mutar.ps1` sobre el
  `.esperado` de `sala_puerta_b_pared` (`x 1200 2` por `x 1100 2`): `MATADA restaurado=SI arbol=IGUAL` en pwsh 7 y en
  powershell.exe 5.1, y cada corrida dejó su archivo en `.godot/guiones-fallidos/`.
